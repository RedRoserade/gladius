part of gladius;

class Request {
  HttpRequest _req;

  Request.fromRequest(this._req) {

  }

  Stream get body => _req;
  HttpHeaders get headers => _req.headers;
  String get method => _req.method;
  String get path => _req.uri.path;
  String get requestProtocol => _req.protocolVersion;
  String get queryString => _req.uri.query;
  String requestScheme;

  X509Certificate get certificate =>
      _req.certificate;

  InternetAddress get ipAddress =>
      _req.connectionInfo.remoteAddress;

  int get port =>
      _req.connectionInfo.remotePort;
}
