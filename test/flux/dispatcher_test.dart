import 'package:flurt/flurt.dart';
import 'package:test/test.dart';

class DummyAction extends Action {
  int dummyValue;

  DummyAction(int dummyValue) {
    this.dummyValue = dummyValue;
  }
}

void main() {
  Dispatcher dispatcher = new Dispatcher();

  group('Dispatcher', () {
    test('adds subscriptions correctly', () async {
      bool called = false;

      dispatcher.subscribe(DummyAction, (DummyAction action) {
        called = true;
        expect(action.dummyValue, equals(3));
      });

      dispatcher.dispatch(DummyAction(3));

      expect(called, equals(true));
      dispatcher.clearDispatcher();
    });

    test('subscriptions should be ordered', () async {
      List<int> callOrder = List();

      dispatcher.subscribe(DummyAction, (action) {
        callOrder.add(2);
      }, priority: 30);
      dispatcher.subscribe(DummyAction, (action) {
        callOrder.add(3);
      }, priority: 30);
      dispatcher.subscribe(DummyAction, (action) {
        callOrder.add(1);
      }, priority: 0);

      dispatcher.dispatch(DummyAction(3));

      expect(dispatcher.subscriptionCounter, equals(3));
      expect(callOrder, equals([1, 2, 3]));
      dispatcher.clearDispatcher();
    });

    test('subscriptions are cancelled', () async {
      bool called = false;

      DispatcherSubscription subscription =
          dispatcher.subscribe(DummyAction, (action) {
        prints("disposed");
      });
      subscription
          .asObservable()
          .doOnDone(() => called = true)
          .listen((action) {});

      await subscription.disposeFuture();
      dispatcher.dispatch(DummyAction(3));

      expect(dispatcher.subscriptionCounter, equals(0));
      expect(called, true);
      dispatcher.clearDispatcher();
    });
  });
}
