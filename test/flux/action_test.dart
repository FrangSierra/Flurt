import 'dart:mirrors';

import 'package:flurt/flurt.dart';
import 'package:test/test.dart';

class ActionA extends Action {}

class ActionB extends ActionA {}

class ActionC extends ActionB {}

main() {
  group('Interceptors', () {
    test('Tags are reflected correctly', () async {
      ActionC action = ActionC();
      Set<ClassMirror> mirroreables = action.tags();
      expect(
          mirroreables,
          containsAll([
            reflectClass(ActionA),
            reflectClass(ActionB),
            reflectClass(ActionC)
          ]));
    });
  });
}
