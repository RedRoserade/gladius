part of gladius;

class HttpRouter extends Component {

  Map<String, Map<Pattern, List<Middleware>>> _methods = {};

  void on(String method, Pattern route, Middleware delegate) {
    _methods.putIfAbsent(method, () => {});
    _methods[method].putIfAbsent(route, () => []);
    _methods[method][route].add(delegate);
  }

  void get(Pattern route, Middleware delegate) {
    on('GET', route, delegate);
  }

  void put(Pattern route, Middleware delegate) {
    on('PUT', route, delegate);
  }

  void post(Pattern route, Middleware delegate) {
    on('POST', route, delegate);
  }

  void delete(Pattern route, Middleware delegate) {
    on('DELETE', route, delegate);
  }

  void patch(Pattern route, Middleware delegate) {
    on('PATCH', route, delegate);
  }

  void options(Pattern route, Middleware delegate) {
    on('OPTIONS', route, delegate);
  }

  @override
  Future call(Context ctx, Future next()) async {
    var routes = _methods[ctx.request.method];

    if (routes == null) {
      ctx.response.statusCode = 404;
      ctx.response.write('Cannot ${ctx.request.method} ${ctx.request.path}');

      return next();
    }

    var middleware = routes[ctx.request.path];

    if (middleware == null) {
      ctx.response.statusCode = 404;
      ctx.response.write('Cannot ${ctx.request.method} ${ctx.request.path}');

      return next();
    }

    await _runPipeline(middleware, ctx);
  }
}