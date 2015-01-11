part of gladius;

/// [Component] that logs errors
/// and their stack trace onto the
/// response.
///
/// If [writeToResponse] == `true` (it is by default),
/// the response's status code will be changed
/// to 500 (Internal Server Error),
/// all output from the response will be replaced
/// with the error's message and stack trace,
/// and the pipeline will be stopped.
class ErrorLogger extends Component {

  bool writeToResponse;

  ErrorLogger({this.writeToResponse: true});

  @override
  Future call(Context ctx) async {
    try {
      await next(ctx);
    } catch (e, stackTrace) {
      if (writeToResponse) {
        ctx.response.reset();

        ctx.response.headers.contentType = ContentType.HTML;
        ctx.response.statusCode = 500;

        ctx.response.writeln('<h1>:( Oops.</h1>');
        ctx.response.writeln('<p>Something went wrong.</p>');

        ctx.response.writeln('<strong>$e</strong>');

        ctx.response.writeln('<pre>');

        ctx.response.writeln(stackTrace);

        ctx.response.writeln('</pre>');
      } else {
        await next(ctx);
      }

      ctx.app.logger.severe('Error', e, stackTrace);
    }
  }
}
