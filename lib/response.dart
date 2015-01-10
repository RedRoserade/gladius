part of owin;

class Response implements IOSink {

  HttpResponse _res;
  List<int> _buffer;

  /// If true, content sent
  /// to the response will be
  /// sent directly to the response,
  /// instead of being buffered.
  ///
  /// This is useful to send files
  /// directly to the response.
  ///
  /// **NOTICE** if this is `true`,
  /// make sure to set content headers
  /// before content is sent.
  bool writeDirectly = false;

  Response.fromResponse(this._res) {
    _buffer = <int>[];
  }

  HttpHeaders get headers =>
      _res.headers;

  int get statusCode =>
      _res.statusCode;

  set statusCode(int value) =>
      _res.statusCode = value;

  String get reasonPhrase =>
      _res.reasonPhrase;

  set reasonPhrase(String value) =>
      _res.reasonPhrase = value;

  int get contentLength =>
      _res.contentLength;

  @override
  Future close() async {

  }

  /// Sends this response to
  /// the client.
  ///
  /// From this point onward,
  /// data cannot be added, and headers
  /// cannot be removed.
  Future send() async {
    if (!writeDirectly) {
      _res.add(_buffer);
    }

    await _res.close();
  }

  @override
  void addError(error, [StackTrace stackTrace]) {
    // TODO: implement addError
  }

  // TODO: implement done
  @override
  Future get done => _res.done;

  // TODO: implement encoding
  @override
  Encoding get encoding => _res.encoding;

  void _write(List<int> data) {
    if (writeDirectly) {
      _res.add(data);
    } else {
      _buffer.addAll(data);
    }
  }

  @override
  void set encoding(Encoding encoding) {
    _res.encoding = encoding;
  }

  @override
  Future flush() {
    // TODO: implement flush
  }

  void reset() {
    _buffer.clear();
  }

  @override
  void write(Object obj) {
    _write(encoding.encode(obj.toString()));
  }

  @override
  void writeAll(Iterable objects, [String separator = ""]) {
    _write(
        encoding.encode(objects
          .map((o) => o.toString())
          .join(separator))
    );
  }

  @override
  void writeCharCode(int charCode) {
    _write(<int>[charCode]);
  }

  @override
  void writeln([Object obj = ""]) {
    _write(encoding.encode(obj.toString() + '\r\n'));
  }

  @override
  void add(List<int> data) {
    _write(data);
  }

  @override
  Future addStream(Stream<List<int>> stream) async {
    await stream.forEach(_write);
  }
}