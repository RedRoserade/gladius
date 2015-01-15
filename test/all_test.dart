
library owin.test;

import '../lib/gladius.dart';
import 'dart:async';

var errorLogger = (Context ctx, Future next()) async {
  try {
    await next();
  } catch (e, st) {
    print(e);
    print(st);
  }
};

var logger = (Context ctx, Future next()) async {
  var sw = new Stopwatch();
  sw.start();

  await next();

  sw.stop();

  print('${ctx.request.method} ${ctx.request.uri.path} - ${ctx.response.statusCode}, ${sw.elapsedMilliseconds}ms');
};

AppFunc compose(Object o) {
  print('composing... for $o');

  return (Context ctx, next) {
    print('from composed stuff!! o is: $o');
    return next();
  };
}

main() async {
  var app = new HttpApp();

  app.address = '0.0.0.0';
  app.port = 8080;

  app.use(logger);

  app.use(errorLogger);

  _mountRouters(app);

  await app.start();

  print('Started on http://${app.address}:${app.port}');
}

void _mountRouters(HttpApp app) {
  var r1 = new HttpRouter();

  r1.get('/', (ctx, next) => ctx.response.writeln('r1 says /'));

  r1.get('/hello', (ctx, next) => ctx.response.writeln('r1 says /hello'));

  //r1.get('/r2/hello', (ctx, next) => ctx.response.writeln('r1 says /r2/hello'));

  var r2 = new HttpRouter();

  r2.get('/', (ctx, next) => ctx.response.writeln('r2 says /'));

  r2.get('/hello', (ctx, next) => ctx.response.writeln('r2 says /hello'));

  r1.mount('/r2', r2);

  app.use(r1);

  r1.use((ctx, next) => ctx.response.writeln('I will run before r1\'s contents, but not r2\'s.'));
}