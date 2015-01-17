import '../lib/gladius.dart';
import 'package:unittest/unittest.dart';

main() {
  group('child router mounting', () {

    test('throws StateError if mounting child router at root path', () {
      var router = new HttpRouter();

      expect(() => router.mount('/', new HttpRouter()), throwsStateError);
    });

    test('throws StateError if mounting a router in a path where one already exists and replaceExisting is false', () {
      var router = new HttpRouter();

      router.mount('/path1', new HttpRouter());
      expect(() => router.mount('/path1', new HttpRouter()), throwsStateError);
    });

    test('replaces router if replaceExisting is true when mounting on an existing path', () {
      var router = new HttpRouter();

      var r1 = new HttpRouter();

      router.mount('/path1', r1);

      var r2 = new HttpRouter();

      router.mount('/path1', r2, replaceExisting: true);

      expect(router.getChild('/path1'), equals(r2));
    });
  });
}