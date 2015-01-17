import 'package:unittest/unittest.dart';
import '../lib/gladius.dart';

main() {
  group('child router matching', () {
    test('returns router if one was mounted in that exact path', () {
      var router = new HttpRouter();
      var c1 = new HttpRouter();
      router.mount('/c1', c1);

      var c2 = new HttpRouter();

      router.mount('/c2', c2);

      expect(router.getChild('/c2'), equals(c2));
    });

    test('returns closest matching router if multiple are available', () {
      var router = new HttpRouter();
      var c2 = new HttpRouter();
      router.mount('/c2', c2);

      var c2a = new HttpRouter();

      router.mount('/c2/a', c2a);

      var c2b = new HttpRouter();

      router.mount('/c2/b', c2b);

      expect(router.getChild('/c2/a/b'), equals(c2a));

    });

    test('returns null if no children routers are suitable', () {
      var router = new HttpRouter();
      var c2 = new HttpRouter();
      router.mount('/c2', c2);

      var c2a = new HttpRouter();

      router.mount('/c2/a', c2a);

      expect(router.getChild('/c3'), isNull);
      expect(router.getChild('/c2ab'), isNull);
    });
  });
}
