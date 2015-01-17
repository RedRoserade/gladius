part of gladius;

class Context {

  Map<String, Service> _serviceCache = {};

  HttpApp app;
  Request request;
  Response response;

  Context();

  Context.fromRequest(HttpRequest req) {
    request = new Request.fromRequest(req);
    response = new Response.fromResponse(req.response);
  }

  InternetAddress localIpAddress;
  int get localPort => request._req.connectionInfo.localPort;

  Stream<Context> onSendingHeaders;

  Object get(String key) {

    var s = _serviceCache[key];

    if (s != null) { return s.get(); }

    s = app.getService(key);

    if (s == null) { return null; }

    _serviceCache[key] = s;

    return s.get();
  }
}