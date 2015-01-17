import 'package:unittest/unittest.dart';
import '../lib/gladius.dart';

class StringService extends Service {

  String returnedString;

  String get() {
    return returnedString;
  }
}

/// Mock HttpApp which counts how many times
/// [getService] for a key is called.
///
/// Used for testing whether whether [Context]
/// caches services and uses lazy loading.
class CountingMockHttpApp extends HttpApp {

  Map<String, int> calledCount = {};

  void inject(String key, ServiceInjector injector) {
    calledCount.putIfAbsent(key, () => 0);
    super.inject(key, injector);
  }

  @override
  Service getService(String key) {
    calledCount[key]++;
    return super.getService(key);
  }
}

main() {
  group('app attribute injection', () {

    test('maps object to a key', () {
      var app = new HttpApp();

      var s = new StringService();
      s.returnedString = 'hello';

      app.inject('myService', () => s);

      expect(app.getService('myService'), equals(s));
    });
  });

  group('context attribute retrieval', () {
    test('context returns null if service doesn\'t exist', () {
      var app = new HttpApp();

      var s = new StringService();
      s.returnedString = 'hello';

      app.inject('myStringService', () => s);

      var ctx = new Context();
      ctx.app = app;

      expect(ctx.get('myService'), isNull);
    });

    test('context returns serviced object if it exists', () {
      var app = new HttpApp();

      var s = new StringService();
      s.returnedString = 'hello';

      app.inject('myService', () => s);

      var ctx = new Context();
      ctx.app = app;

      expect(ctx.get('myService'), equals(s.returnedString));
    });

    test('context only calls app.getService() once', () {
      var app = new CountingMockHttpApp();

      var s = new StringService();
      s.returnedString = 'count should be 1';

      app.inject('myService', () => s);
      app.inject('myOtherService', () => s);

      var ctx = new Context();
      ctx.app = app;

      expect(ctx.get('myService'), s.returnedString);
      expect(ctx.get('myService'), s.returnedString);

      expect(app.calledCount['myService'], equals(1));
      expect(app.calledCount['myOtherService'], equals(0));
    });
  });
}
