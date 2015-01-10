
library owin.test;
import 'dart:async';
import 'dart:mirrors';

import '../lib/owin.dart';
import 'dart:io';

var defaultLogger = (l) {
  print(l);
};

var logger = (next) {
  var sw = new Stopwatch();

  var func = (Context ctx) async {
    var startDate = new DateTime.now();
    sw.start();

    await next(ctx);

    sw.stop();

    print('[${startDate}] ${ctx.request.method} ${ctx.request.path} - ${ctx.response.statusCode} - ${sw.elapsed.inMilliseconds}ms ${ctx.response.contentLength} B');

    sw.reset();
  };

  return func;
};

var fileTransfer = (next) => (Context ctx) async {
  if (ctx.request.path == '/file') {

    var f = new File.fromUri(new Uri.file(r'C:\codeschool_1369.mp4'));

    ctx.response.headers.contentType = ContentType.parse('video/mp4');

    ctx.response.writeDirectly = true;

    var file = await f.openRead() as Stream<List<int>>;

    var count = 0;

    await file
      .takeWhile((l) {
        print('length: ${l.length}, total: $count');
        count += l.length;
        return count < 5 * 1000000;
      })
      .pipe(ctx.response);

  } else {
    await next(ctx);
  }
};

main() async {
  var app = new HttpApp();

  app.address = '0.0.0.0';
  app.port = 8080;

  app.logger.onRecord.listen(defaultLogger);

  app.use(logger);

  app.useComponent(new ErrorLogger(writeToResponse: true));

  var router = new HttpRouter();

  router.get('/', (next) => (ctx) => throw 'oh dear');

  router.get('/awesome', (next) => (ctx) {
    ctx.response.write('GET /awesome');
    return next(ctx);
  });

  router.get('/another/route', (next) => (ctx) => ctx.response.write('GET /another/route'));

  app.useComponent(router);

  await app.run();
}