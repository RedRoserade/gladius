part of gladius;

class Request {
  HttpRequest _req;

  Request.fromRequest(this._req);

  int get contentLength =>
      _req.contentLength;

  List<Cookie> get cookies =>
      _req.cookies;

  HttpSession get session =>
      _req.session;

  Stream get body =>
      _req;

  HttpHeaders get headers =>
      _req.headers;

  String get method =>
      _req.method;

  Uri get uri =>
      _req.uri;

  String get requestProtocol =>
      _req.protocolVersion;

  X509Certificate get certificate =>
      _req.certificate;

  HttpConnectionInfo get connectionInfo =>
      _req.connectionInfo;
}
