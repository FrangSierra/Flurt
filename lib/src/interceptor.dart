import 'dart:collection';
import 'dart:mirrors';

import 'action.dart';
import 'dispatcher_subscription.dart';

typedef Interceptor = Action Function(Action action, Chain chain);

/**
 * A chain of interceptors. Call [.proceed] with
 * the intercepted action or directly handle it.
 */
abstract class Chain {
  Action proceed(Action action);
}

/**
 * A default chain of interceptors.
 */
class InterceptorChain extends Chain {
  Interceptor interceptor;
  Chain chain;

  InterceptorChain(Interceptor interceptor, Chain chain) {
    this.interceptor = interceptor;
    this.chain = chain;
  }

  @override
  Action proceed(Action action) {
    return interceptor(action, chain);
  }
}

/**
 * A default chain of interceptors.
 */
class ActionMapChain extends Chain {
  HashMap<ClassMirror, SplayTreeSet<DispatcherSubscription>> _subscriptionMap;

  ActionMapChain(
      HashMap<ClassMirror, SplayTreeSet<DispatcherSubscription>>
          subscriptionMap) {
    this._subscriptionMap = subscriptionMap;
  }

  @override
  Action proceed(Action action) {
    action.tags().forEach((tag) {
      if (_subscriptionMap[tag] == null) return;
      _subscriptionMap[tag]
          .forEach((subscription) => subscription.onActionCall(action));
    });
    return action;
  }
}
