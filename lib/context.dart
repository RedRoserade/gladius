part of owin;

class Context {

  HttpApp app;
  Request request;
  Response response;

  Context.fromRequest(HttpRequest req) {
    request = new Request.fromRequest(req);
    response = new Response.fromResponse(req.response);
  }

  InternetAddress localIpAddress;
  int get localPort => request._req.connectionInfo.localPort;

  Stream<Context> onSendingHeaders;
}