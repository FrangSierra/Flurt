import 'package:flurt/src/Action.dart';
import 'ReducerSubscription.dart';
import 'ActionReducer.dart';
import 'dart:collection';
import 'dart:mirrors';

class DynamicActionReducer extends ActionReducer {
  final int DEFAULT_PRIORITY = 100;

  int _subscriptionCounter = 0;
  HashMap<ClassMirror, SplayTreeSet<ReducerSubscription>> _subscriptionMap =
      Map();

  @override
  void reduce(Action action) {
    action.tags().forEach((tag) {
      Set<ReducerSubscription> set = _subscriptionMap[tag];
      if (_subscriptionMap[tag] == null) return;
      set.forEach((reducer) => reducer.onActionCall(action));
    });
  }

  ReducerSubscription<T> subscribe<T>(ClassMirror tag, Function(T) cb,
      {int priority = 100}) {
    ReducerSubscription subscription =
        ReducerSubscription(this, tag, _subscriptionCounter, priority, cb);
    _subscriptionCounter++;
    return registerInternal(subscription);
  }

  ReducerSubscription<T> registerInternal<T>(
      ReducerSubscription<T> dispatcherSubscription) {
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

  void unregisterInternal<T>(ReducerSubscription<T> dispatcherSubscription) {
    Set set = _subscriptionMap[dispatcherSubscription.tag];
    if (set == null) return;
    bool removed = set.remove(dispatcherSubscription);
    if (!removed) {
      print("Failed to remove dispatcherSubscription, multiple dispose calls?");
    }
  }
}
