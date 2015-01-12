
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

  print(sw.elapsedMilliseconds);
};

Middleware composer(Object o) {
  print('composing... for $o');

  return (Context ctx, Future next()) {
    print('from composed stuff!! o is: $o');
    return next();
  };
}

main() async {
  var app = new HttpApp();

  app.address = '0.0.0.0';
  app.port = 8080;

  app.use((ctx, next) async {
    ctx.response.writeln('inbound 1');
    await next(ctx);
    ctx.response.writeln('outbound 1');
  });

  app.use((ctx, next) async {
    ctx.response.writeln('inbound 2');
    await next(ctx);
    ctx.response.writeln('outbound 2');
  });

  app.use((ctx, next) async {
    ctx.response.writeln('inbound 3');
    await next(ctx);
    ctx.response.writeln('outbound 3');
  });

  await app.start();
}