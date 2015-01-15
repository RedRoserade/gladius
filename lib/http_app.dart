part of gladius;

class HttpApp extends Object with Pipeline {
  String address;
  int port;

  Logger logger = new Logger('app');

  Future handleRequest(HttpRequest req) async {
    var context = new Context.fromRequest(req);
    context.app = this;

    try {
      if (functions.isNotEmpty) {
        await _runPipeline(functions, context);
      } else {
        throw new EmptyPipelineError();
      }
    } catch (e, st) {
      context.response
        ..reset()
        ..statusCode = 500
        ..write(e is EmptyPipelineError ? e : '500 Internal Server Error');

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