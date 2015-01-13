part of gladius;


abstract class HttpApp {
  String address;
  int port;

  Logger logger;

  factory HttpApp() {
    return new _HttpAppImpl();
  }

  void use(AppFunc func);

  Future handleRequest(HttpRequest req);

  Future start();
}