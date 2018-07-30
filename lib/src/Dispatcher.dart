import 'Interceptor.dart';
import 'ActionReducer.dart';
import 'package:synchronized/synchronized.dart';
import 'Action.dart';

class Dispatcher {
  bool _dispatching = false;
  Chain _actionReducerLink;
  Chain _interceptorChain;
  List<Interceptor> _interceptors = List();
  List<ActionReducer> _actionReducers = List();
  Lock _dispatcherLock = Lock();

  Dispatcher() {
    _actionReducerLink = ActionReducerChain(_actionReducers);
    _interceptorChain = buildChain();
  }

  Chain buildChain() {
    return _interceptors.fold(_actionReducerLink, (chain, interceptor) {
      return InterceptorChain(interceptor, chain);
    });
  }

  void addActionReducer(ActionReducer actionReducer) {
    _dispatcherLock.synchronized(() async {
      _actionReducers.add(actionReducer);
    });
  }

  void removeActionReducer(ActionReducer actionReducer) {
    _dispatcherLock.synchronized(() async {
      _actionReducers.remove(actionReducer);
    });
  }

  void addInterceptor(Interceptor interceptor) {
    _dispatcherLock.synchronized(() async {
      _interceptors.add(interceptor);
      _interceptorChain = buildChain();
    });
  }

  void removeInterceptor(Interceptor interceptor) {
    _dispatcherLock.synchronized(() async {
      _actionReducers.remove(interceptor);
      _interceptorChain = buildChain();
    });
  }

  /**
   * Post an event that will dispatch the action and return immediately.
   *
   * Since Flutter is single threaded and runs an event loop (like Node.js),
   * you don’t have to worry about thread management or spawning background threads
   */
  void dispatch(Action action) {
    if (_dispatching) throw new Exception("Nested dispatch calls");
    _dispatching = true;
    _interceptorChain.proceed(action);
    _dispatching = false;
  }
}
