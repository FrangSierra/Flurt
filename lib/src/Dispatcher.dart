import 'Interceptor.dart';
import 'ActionReducer.dart';
import 'package:synchronized/synchronized.dart';
import 'Action.dart';

class Dispatcher {
  
  bool verifyThreads;
  bool dispatching = false;
  Chain actionReducerLink;
  Chain interceptorChain;
  List<Interceptor> interceptors = List();
  List<ActionReducer> actionReducers = List();
  Lock dispatcherLock = Lock();

  Dispatcher(this.interceptors, this.actionReducers,
      {bool verifyThreads = false}) {
    this.verifyThreads = verifyThreads;
    actionReducerLink = ActionReducerChain(actionReducers);
    interceptorChain = buildChain();
  }

  Chain buildChain() {
    return interceptors.fold(actionReducerLink, (chain, interceptor) {
      return InterceptorChain(interceptor, chain);
    });
  }

  void addActionReducer(ActionReducer actionReducer) {
    dispatcherLock.synchronized(() async {
      actionReducers.add(actionReducer);
    });
  }

  void removeActionReducer(ActionReducer actionReducer) {
    dispatcherLock.synchronized(() async {
      actionReducers.remove(actionReducer);
    });
  }

  void addInterceptor(Interceptor interceptor) {
    dispatcherLock.synchronized(() async {
      interceptors.add(interceptor);
      interceptorChain = buildChain();
    });
  }

  void removeInterceptor(Interceptor interceptor) {
    dispatcherLock.synchronized(() async {
      actionReducers.remove(interceptor);
      interceptorChain = buildChain();
    });
  }

  /**
   * Post an event that will dispatch the action on the Ui thread
   * and return immediately.
   */
  void dispatchOnUi(Action action) {
    //onUi { dispatch(action) }
  }

  /**
   * Post and event that will dispatch the action on the Ui thread
   * and block until the dispatch is complete.
   *
   * Can't be called from the main thread.
   */
  void dispatchOnUiSync(Action action) {
    //if (verifyThreads) assertNotOnUiThread()
    //onUiSync { dispatch(action) }
  }

  void dispatch(Action action) {
    //if (verifyThreads) assertOnUiThread()
    if (dispatching) throw Exception("Nested dispatch calls");
    dispatching = true;
    interceptorChain.proceed(action);
    dispatching = false;
  }
}
