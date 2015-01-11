part of gladius;


abstract class HttpApp {

  List<Middleware> middleware;

  String address;
  int port;

  Logger logger;

  factory HttpApp() {
    return new _HttpAppImpl();
  }


  void use(Middleware del);

  Future handleRequest(HttpRequest req);

  Future start();
}