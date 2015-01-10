part of owin;

abstract class Service {

}

class HttpApp {
  List<RequestDelegate> _middleware = <RequestDelegate>[];

  String address;
  int port;

  Logger logger = new Logger('app');

  void use(RequestDelegate middleware) {
    _middleware.add(middleware);
  }

  void addService(String key, Service service) {

  }

  void useComponent(Component c) {
    _middleware.add((next) {
      c.next = next;
      return c;
    });
  }

  Future _onRequest(HttpRequest req) async {
    var context = new Context.fromRequest(req);
    context.app = this;
    var index = 0;

    Future _next(Context ctx) async {
      if (index < _middleware.length) {
        var fn = _middleware[index++](_next);
        await fn(ctx);
      }
    }

    try {
      await _next(context);
    } catch (e, st) {
      context.response
        ..statusCode = 500
        ..write('500 Internal Server Error');
    }

    await context.response.send();
  }

  Future run() async {
    HttpServer server = await HttpServer.bind(address, port);

    server.listen(_onRequest);

    logger.info('Started on $address:$port');
  }
}