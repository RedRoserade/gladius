# gladius

A basic, middleware-based application that runs on top of a dart `HttpServer`. Heavily inspired by Express and OWIN. Not intended for use (at least, not yet).

## Usage

Similar to OWIN, this works based on request delegates and app functions. 

An app function (`AppFunc`) is a function that uses a `Context` and returns a `Future`.

A request delegate is a function that takes an `AppFunc` and returns an `AppFunc`,
and these are used to compose the request pipeline. The `AppFunc` that is received through
parameter is the next middleware in the pipeline.

There are many ways `next()` can be called. One can call it at the end of the method,
which means the only processing done will be in the inbound request, before it's passed along. 
It can also be called in the "middle" of the method (see below). This can be used for logging,
or error handling. One can also call it immediately, and have the middleware process the response
itself (for example, compression).
Of course, one can also not call `next()` at all, in which, the pipeline is short-circuited,
the preceeding middleware finishes processing, and the response is sent.  

```dart
main() {
  var app = new HttpApp();
  
  app.address = '0.0.0.0';
  app.port = 8080;
  
  // A simple request logger.
  // Here, next() is called in the middle of
  // the method, so that timing can be done.
  app.use((AppFunc next) => (Context ctx) async {
    var sw = new Stopwatch();
    sw.start();
    
    await next(ctx);
    
    sw.stop();
    
    print('${ctx.request.method} ${ctx.request.path} - ${sw.elapsed.inMilliseconds}');
  });
  
  // A simple 'hello, world'. Since next() isn't
  // called, the pipeline ends here.
  // This is invoked when the logger calls next(),
  // so, when this ends, the logger will continue execution.
  app.use((AppFunc next) => (Context ctx) {
    ctx.response.write('Hello, world!');
  });
  
  app.start();
}
```

