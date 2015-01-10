part of owin;

class HttpRouter extends Component {

  Map<String, Map<Pattern, List<RequestDelegate>>> _methods = {};

  void on(String method, Pattern route, RequestDelegate delegate) {
    _methods.putIfAbsent(method, () => {});
    _methods[method].putIfAbsent(route, () => []);
    _methods[method][route].add(delegate);
  }

  void get(Pattern route, RequestDelegate delegate) {
    on('GET', route, delegate);
  }

  void put(Pattern route, RequestDelegate delegate) {
    on('PUT', route, delegate);
  }

  void post(Pattern route, RequestDelegate delegate) {
    on('POST', route, delegate);
  }

  void delete(Pattern route, RequestDelegate delegate) {
    on('DELETE', route, delegate);
  }

  void patch(Pattern route, RequestDelegate delegate) {
    on('PATCH', route, delegate);
  }

  void options(Pattern route, RequestDelegate delegate) {
    on('OPTIONS', route, delegate);
  }

  @override
  Future call(Context ctx) async {
    var routes = _methods[ctx.request.method];

    if (routes == null) {
      ctx.response.statusCode = 404;
      ctx.response.write('Cannot ${ctx.request.method} ${ctx.request.path}');

      return next(ctx);
    }

    var _middleware = routes[ctx.request.path];

    if (_middleware == null) {
      ctx.response.statusCode = 404;
      ctx.response.write('Cannot ${ctx.request.method} ${ctx.request.path}');

      return next(ctx);
    }

    var index = 0;

    Future _next(Context ctx) async {
      if (index < _middleware.length) {
        var fn = _middleware[index++](_next);
        await fn(ctx);
      }
    }

    await _next(ctx);
  }
}