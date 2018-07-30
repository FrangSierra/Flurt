import 'package:flurt/flurt.dart';
import 'package:test/test.dart';

import 'dispatcher_test.dart';

class InterceptedAction extends Action {
  int value;

  InterceptedAction(int value) {
    this.value = value;
  }
}

void main() {
  Dispatcher dispatcher = new Dispatcher();

  group('Interceptors', () {
    Interceptor dummyInterceptor = (action, chain) {
      Action intercepted = action;
      if (action is DummyAction) {
        intercepted = InterceptedAction(action.dummyValue + 1);
      }
      chain.proceed(intercepted);
    };

    test('interceptors are called', () async {
      dispatcher.addInterceptor(dummyInterceptor);

      bool called = false;
      dispatcher.subscribe(InterceptedAction, (InterceptedAction action) {
        called = true;
        expect(action.value, equals(3));
      });

      dispatcher.dispatch(DummyAction(2));
      expect(called, equals(true));
    });

    test('interceptors are removed', () async {
      expect(dispatcher.interceptorCount, equals(1));
      dispatcher.removeInterceptor(dummyInterceptor);
      expect(dispatcher.interceptorCount, equals(0));
    });
  });
}
