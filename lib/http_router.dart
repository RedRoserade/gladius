part of gladius;

class HttpRouter extends Component {

  Map<String, Map<String, List<AppFunc>>> _methods = {};

  Map<String, HttpRouter> _subRouters = {};

  String basePath;

  HttpRouter({this.basePath: ''});

  bool _matches(String route, String template) {
    var routeSegments = (basePath + route).split('/');
    var templateSegments = template.split('/');
  }

  void mount(String path, HttpRouter router) {
    _subRouters[path] = router;
    router.basePath = path;
  }

  void on(String method, Pattern route, AppFunc func) {
    _methods.putIfAbsent(method, () => {});

    route = _addTrailingSlash(route);

    _methods[method].putIfAbsent(route, () => []);
    _methods[method][route].add(func);
  }

  void get(Pattern route, AppFunc func) {
    on('GET', route, func);
  }

  void put(Pattern route, AppFunc func) {
    on('PUT', route, func);
  }

  void post(Pattern route, AppFunc func) {
    on('POST', route, func);
  }

  void delete(Pattern route, AppFunc func) {
    on('DELETE', route, func);
  }

  void patch(Pattern route, AppFunc func) {
    on('PATCH', route, func);
  }

  void options(Pattern route, AppFunc func) {
    on('OPTIONS', route, func);
  }

  HttpRouter _getSubRouter(Map<String, HttpRouter> subRouters, String path) {
    var key = subRouters.keys.firstWhere((k) => path.contains(k), orElse: () => null);

    if (key == null) { return null; }

    return subRouters[key];
  }

  @override
  Future call(Context ctx, Future next()) async {
    var routes = _methods[ctx.request.method];
    var subRouter = _getSubRouter(_subRouters, ctx.request.path);

    if (routes == null || routes.isEmpty) {
      if (subRouter != null) { return subRouter(ctx, next); }

      ctx.response.statusCode = 404;
      ctx.response.write('Cannot ${ctx.request.method} ${ctx.request.path}');

      return next();
    }

    var route = _addTrailingSlash(ctx.request.path);

    if (basePath.isNotEmpty) {
      route = route.substring(basePath.length);
    }

    var middleware = routes[route];

    if (middleware == null || middleware.isEmpty) {
      if (subRouter != null) {
        return subRouter(ctx, next);
      }

      ctx.response.statusCode = 404;
      ctx.response.write('Cannot ${ctx.request.method} ${ctx.request.path}');

      return next();
    }

    await _runPipeline(middleware, ctx);

    return next();
  }
}