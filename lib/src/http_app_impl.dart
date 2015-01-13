part of gladius;

Future _runPipeline(List<AppFunc> middleware, Context ctx) async {
  var index = 0;

  Future next() {
    if (index < middleware.length) {
      var fn = middleware[index++];
      return fn(ctx, next);
    }
  };

  return next();
}

class _HttpAppImpl implements HttpApp {

  List<AppFunc> pipeline = <AppFunc>[];

  String address;

  int port;

  Logger logger = new Logger('app');

  void use(AppFunc del) {
    pipeline.add(del);
  }

  Future handleRequest(HttpRequest req) async {
    var context = new Context.fromRequest(req);
    context.app = this;

    try {
      if (pipeline.isNotEmpty) {
        await _runPipeline(pipeline, context);
      } else {
        throw new EmptyPipelineException();
      }
    } catch (e, st) {
      var emptyPipeline = e is EmptyPipelineException;

      context.response
        ..reset()
        ..statusCode = emptyPipeline ? 501 : 500
        ..write(emptyPipeline ? e : '500 Internal Server Error');

      print(e);
      print(st);
    }

    await context.response.close();
  }

  Future start() async {
    var server = await HttpServer.bind(address, port);

    server.listen(handleRequest);

    logger.info('Started on $address:$port');
  }
}

class EmptyPipelineException implements Exception {
  String toString() => 'Empty pipeline; nothing to do.';
}
