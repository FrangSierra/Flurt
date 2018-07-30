import 'package:flurt/flurt.dart';
import 'package:test/test.dart';

void main() {
  Dispatcher dispatcher = new Dispatcher();
  DynamicActionReducer reducer = DynamicActionReducer();
  dispatcher.addActionReducer(reducer);

  group('Dispatcher', () {
    test('adds subscriptions correctly', () async {
      bool called = false;
    });
  });
}