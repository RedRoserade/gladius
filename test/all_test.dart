
library owin.test;

import '../lib/gladius.dart';

main() async {
  var app = new HttpApp();

  app.address = '0.0.0.0';
  app.port = 8080;

  var router = new HttpRouter();

  router.get('/awesome', (ctx, next) {
    print('on totally awesome!!');
    ctx.response.writeln('totally awesome!!!');
  });

  app.use(router);

  app.use((ctx, next) {
    ctx.response.writeln('hello, world');
    app.use((ctx, next) {
      ctx.response.write('yet again!!');
      return next(ctx);
    });
    return next(ctx);
  });

  app.use((ctx, next) {
    ctx.response.writeln('hello, world');
    return next(ctx);
  });


//  app.useComponent(new ErrorLogger(writeToResponse: true));
//
//  var router = new HttpRouter();
//
//  router.get('/', (next) => (ctx) => print('/'));
//
//  router.get('/awesome', (next) => (ctx) async {
//    ctx.response.write('GET /awesome');
//    return next(ctx);
//  });
//
//  router.get('/another/route', (next) => (ctx) => ctx.response.write('GET /another/route'));
//
//  app.useComponent(router);

  await app.start();
}