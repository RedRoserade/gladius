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

  HttpRouter({ this.basePath: '' });

  bool _matches(Uri route, String template) {
    var routeSegments = route.pathSegments;
    var templateSegments = template.split('/');
  }

  void mount(String path, HttpRouter router, { bool replaceExisting: false }) {

    if (path == '/') { throw new StateError('Mounting at / is not allowed.'); }

    if (_subRouters[path] != null && !replaceExisting) {
      throw new StateError('A router is already mounted at $path and replaceExisting is false.');
    }

    _subRouters[path] = router;
    router.basePath = path;
  }

  HttpRouter unmount(String path) =>
      _subRouters.remove(path);

  void on(String method, Pattern route, AppFunc func) {
    _methods.putIfAbsent(method, () => {});

    route = _addTrailingSlash(route);

    _methods[method].putIfAbsent(route, () => []);
    _methods[method][route].add(func);
  }

  void get(Pattern route, AppFunc func) {
    on('GET', route, func);
  }

  void head(Pattern route, AppFunc func) {
    on('HEAD', route, func);
  }

  void post(Pattern route, AppFunc func) {
    on('POST', route, func);
  }

  void put(Pattern route, AppFunc func) {
    on('PUT', route, func);
  }

  void delete(Pattern route, AppFunc func) {
    on('DELETE', route, func);
  }

  void trace(Pattern route, AppFunc func) {
    on('TRACE', route, func);
  }

  void options(Pattern route, AppFunc func) {
    on('OPTIONS', route, func);
  }

  void patch(Pattern route, AppFunc func) {
    on('PATCH', route, func);
  }

  /// Returns the closest-matching child router
  /// for the specified [uri], or `null` if no
  /// suitable match is found.
  ///
  /// The matching is done in a similar way to
  /// route matching in a TCP/IP layer 3 router, with
  /// longest prefix matching.
  ///
  /// Example:
  ///
  /// Consider you have `r1` mounted at `/r1`
  /// and `r1a` mounted at `/r1/a`.
  ///
  /// If `[uri.path] == '/r1/a/hello'`, `r1a`
  /// will be returned, as its mount path matches the
  /// requested path better than `r1`'s mount path.
  ///
  /// If, however, `[uri.path]` == '/r1/hello', `r1`
  /// would be returned.
  HttpRouter getChild(String path) {
    // TODO Investigate speed. This is at least O(n) complexity.
    var closestRoute = null as WeightedRoute;

    path = _addTrailingSlash(path);

    var elligiblePaths = _subRouters.keys
        .map(_addTrailingSlash)
        .where((p) => path.contains(p));

    for (var mountPath in elligiblePaths) {
      var priority = path.replaceFirst(mountPath, '').length;

      if (closestRoute == null || closestRoute.priority > priority) {
        closestRoute = new WeightedRoute(_removeTrailingSlash(mountPath), priority);
      }

      if (priority == 0) { break; }
    }

//    _subRouters.keys
//        .where((mountPath) => path.contains(mountPath))
//        .map((mountPath) => new WeightedRoute(mountPath, path.replaceFirst(mountPath, '').length))
//        .forEach((route) {
//          if (closestRoute == null) {
//            closestRoute = route;
//          } else if (closestRoute.priority > route.priority) {
//            closestRoute = route;
//          }
//        });

    if (closestRoute == null) { return null; }

    return _subRouters[closestRoute.route];
  }

  @override
  Future call(Context ctx, Future next()) async {

    var routes = _methods[ctx.request.method];
    var path = ctx.request.uri.path;

    var subRouter = getChild(path);

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