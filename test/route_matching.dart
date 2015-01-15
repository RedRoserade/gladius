
import '../lib/gladius.dart';
import 'package:unittest/unittest.dart';

main() {
  group('route matching', () {

    test('throws StateError if mounting child router at root path', () {
      var router = new HttpRouter();
      expect(() => router.mount('/', new HttpRouter()), throwsStateError);
    });


    test('returns router if one was mounted in that exact path', () {
      var router = new HttpRouter();
      var c1 = new HttpRouter();
      router.mount('/c1', c1);

      var c2 = new HttpRouter();

      router.mount('/c2', c2);

      expect(router.getChild(new Uri(path: '/c2')), equals(c2));
    });

    test('returns closest matching router', () {
      var router = new HttpRouter();
      var c2 = new HttpRouter();
      router.mount('/c2', c2);

      var c2a = new HttpRouter();

      router.mount('/c2/a', c2a);

      expect(router.getChild(new Uri(path: '/c2/a')), equals(c2a));
    });

    test('returns null if no children routers are suitable', () {
      var router = new HttpRouter();
      var c2 = new HttpRouter();
      router.mount('/c2', c2);

      var c2a = new HttpRouter();

      router.mount('/c2/a', c2a);

      expect(router.getChild(new Uri(path: '/c3/')), isNull);
    });
  });
}