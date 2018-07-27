import 'Action.dart';
import 'ActionReducer.dart';

typedef Interceptor = Action Function(Action action, Chain chain);

/**
 * A chain of interceptors. Call [.proceed] with
 * the intercepted action or directly handle it.
 */
abstract class Chain {
  Action proceed(Action action);
}

/**
 * A default chain of ActionReducers.
 */
class ActionReducerChain extends Chain {
  List<ActionReducer> actionReducers;

  ActionReducerChain(List<ActionReducer> interceptors) {
    this.actionReducers = actionReducers;
  }

  @override
  Action proceed(Action action) {
    actionReducers.forEach((reducer) => reducer.reduce(action));
    return action;
  }
}

/**
 * A default chain of interceptors.
 */
class InterceptorChain extends Chain {
  Interceptor interceptor;
  Chain chain;

  InterceptorChain(Interceptor interceptor, Chain chain) {
    this.interceptor = interceptor;
  }

  @override
  Action proceed(Action action) {
    return interceptor(action, chain);
  }
}
