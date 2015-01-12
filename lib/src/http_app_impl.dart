part of gladius;

Future _runPipeline(List<Middleware> middleware, Context ctx) async {
  var index = 0;

  Future next(Context ctx) {
    if (index < middleware.length) {
      var fn = middleware[index++];
      return fn(ctx, next);
    }
  };

  return next(ctx);
}

class _HttpAppImpl implements HttpApp {

  List<Middleware> middleware = <Middleware>[];

  String address;
  int port;

  int _currentIndex = 0;

  Logger logger = new Logger('app');

  void use(Middleware del) {
    middleware.add(del);
  }

  Future handleRequest(HttpRequest req) async {
    var context = new Context.fromRequest(req);
    context.app = this;

    try {
      if (middleware.isNotEmpty) {
        await _runPipeline(middleware, context);
      } else {
        throw new EmptyPipelineException();
      }
    } catch (e, st) {
      var emptyPipeline = e is EmptyPipelineException;

      context.response
        ..reset()
        ..statusCode = emptyPipeline ? 501 : 500
        ..write(emptyPipeline ? e : '500 Internal Server Error');
    }

    await context.response.send();
  }

  Future start() async {
    HttpServer server = await HttpServer.bind(address, port);

    server.listen(handleRequest);

    logger.info('Started on $address:$port');
  }
}

class EmptyPipelineException implements Exception {
  String toString() => 'Empty pipeline; nothing to do.';
}
