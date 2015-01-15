part of gladius;

class WeightedRoute {
  /// The route.
  String route;

  /// The priority. Lower number means higher priority.
  int priority;

  WeightedRoute(this.route, this.priority);
}

class HttpRouter extends Component with Pipeline {

  Map<String, Map<String, List<AppFunc>>> _methods = {};

  Map<String, HttpRouter> _subRouters = {};

  String basePath;

  HttpRouter({this.basePath: ''});

  bool _matches(String route, String template) {
    var routeSegments = (basePath + route).split('/');
    var templateSegments = template.split('/');
  }

  void mount(String path, HttpRouter router) {

    if (path == '/') { throw new StateError('Bad path: Mounting at "$path" is not allowed.'); }

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

  /// Returns the closest-matching child router
  /// for the specified [uri], or `null` if no
  /// suitable match is found.
  ///
  /// Example:
  ///
  /// Consider you have `r1` mounted at `/r1`
  /// and `r1a` mounted at `/r1/a`.
  ///
  /// If `[uri.path] == '/r1/a/somethingelse'`, `r1a`
  /// will be returned, as its mount path matches the
  /// requested path better than `r1`'s mount path.
  ///
  /// If, however, `[uri.path]` == '/r1/hello', `r1`
  /// would be returned.
  HttpRouter getChild(Uri uri) {
    var uriPath = uri.path;

    var closestRoute = null as WeightedRoute;

    _subRouters.keys
        .where((mountPath) => uriPath.contains(mountPath))
        .map((mountPath) => new WeightedRoute(mountPath, uriPath.replaceFirst(mountPath, '').length))
        .forEach((route) {
          if (closestRoute == null) {
            closestRoute = route;
          } else if (closestRoute.priority > route.priority) {
            closestRoute = route;
          }
        });

    if (closestRoute == null) { return null; }

    return _subRouters[closestRoute.route];

//    var uriPath = uri.path;
//
//    var weightedRoutes = _subRouters.keys
//        .where((path) => uriPath.contains(path))
//        .map((path) => new WeightedRoute(path, uriPath.replaceFirst(path, '').length))
//        .toList() as List<WeightedRoute>;
//
//    weightedRoutes.sort((p1, p2) => p1.priority - p2.priority);
//
//    return _subRouters[
//      weightedRoutes
//        .map((r) => r.route)
//        .firstWhere((_) => true, orElse: () => null)
//    ];
  }

  @override Future call(Context ctx, Future next()) async {

    var routes = _methods[ctx.request.method];
    var path = ctx.request.uri.path;

    var subRouter = getChild(ctx.request.uri);

    if (routes == null || routes.isEmpty) {
      if (subRouter != null) { return subRouter(ctx, next); }

      ctx.response.statusCode = 404;
      ctx.response.write('Cannot ${ctx.request.method} ${path}');

      return next();
    }

    var route = _addTrailingSlash(path);

    if (basePath.isNotEmpty) {
      route = route.substring(basePath.length);
    }

    var middleware = routes[route];

    if (middleware == null || middleware.isEmpty) {
      if (subRouter != null) {
        return subRouter(ctx, next);
      }

      ctx.response.statusCode = 404;
      ctx.response.write('Cannot ${ctx.request.method} ${path}');

      return next();
    }

    await _runPipeline(functions, ctx);
    await _runPipeline(middleware, ctx);

    return next();
  }

  String toString() => 'Router mounted at $basePath';
}