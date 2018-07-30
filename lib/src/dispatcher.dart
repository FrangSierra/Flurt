import 'dart:collection';
import 'dart:mirrors';

import 'package:synchronized/synchronized.dart';

import 'action.dart';
import 'dispatcher_subscription.dart';
import 'interceptor.dart';

class Dispatcher {
  bool _dispatching = false;
  int subscriptionCounter = 0;

  int get interceptorCount {
    return _interceptors.length;
  }

  Chain _chain;
  Chain _rootChain;
  List<Interceptor> _interceptors = List();
  Lock _dispatcherLock = Lock();
  HashMap<ClassMirror, SplayTreeSet<DispatcherSubscription>> _subscriptionMap =
      HashMap();

  Dispatcher() {
    _rootChain = ActionMapChain(_subscriptionMap);
    _chain = _rootChain;
  }

  Chain buildChain() {
    return _interceptors.fold(_chain, (chain, interceptor) {
      return InterceptorChain(interceptor, chain);
    });
  }

  void addInterceptor(Interceptor interceptor) {
    _dispatcherLock.synchronized(() async {
      _interceptors.add(interceptor);
      _chain = buildChain();
    });
  }

  void removeInterceptor(Interceptor interceptor) {
    _dispatcherLock.synchronized(() async {
      _interceptors.remove(interceptor);
      _chain = buildChain();
    });
  }

  /**
   * Returns a subscription to listen to given action emissions.
   */
  DispatcherSubscription<T> subscribe<T extends Action>(
      Type tag, Function(T) cb,
      {int priority = 100}) {
    DispatcherSubscription<T> subscription = DispatcherSubscription(
        this, reflectClass(tag), subscriptionCounter, priority, cb);
    subscriptionCounter++;
    return registerInternal(subscription);
  }

  DispatcherSubscription<T> registerInternal<T extends Action>(
      DispatcherSubscription<T> dispatcherSubscription) {
    if (_subscriptionMap[dispatcherSubscription.tag] == null) {
      _subscriptionMap[dispatcherSubscription.tag] = SplayTreeSet((a, b) {
        int comparation = Comparable.compare(a.priority, b.priority);
        if (comparation == 0)
          return Comparable.compare(a.id, b.id);
        else
          return comparation;
      });
    }
    _subscriptionMap[dispatcherSubscription.tag].add(dispatcherSubscription);
    return dispatcherSubscription;
  }

  void unregisterInternal<T extends Action>(
      DispatcherSubscription<T> dispatcherSubscription) {
    Set set = _subscriptionMap[dispatcherSubscription.tag];
    if (set == null) return;
    bool removed = set.remove(dispatcherSubscription);
    if (!removed) {
      print("Failed to remove dispatcherSubscription, multiple dispose calls?");
    } else {
      subscriptionCounter--;
    }
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
    _chain.proceed(action);
    _dispatching = false;
  }

  /**
   * Resets the dispatcher value for tests purposes.
   */
  void clearDispatcher() {
    _subscriptionMap.clear();
    subscriptionCounter = 0;
  }
}
