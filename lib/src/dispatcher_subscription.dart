import 'dart:async';
import 'dart:mirrors';

import 'package:rxdart/rxdart.dart';

import 'action.dart';
import 'dispatcher.dart';

/**
 * Custom class that handles [Dispatcher] subscriptions.
 */
class DispatcherSubscription<T extends Action> {
  ClassMirror tag;
  int id;
  int priority;
  Function(T) _onAction;
  Dispatcher _dispatcher;
  Subject<T> _subject = null;
  bool _disposed = false;

  DispatcherSubscription(Dispatcher reducer, ClassMirror tag, int id,
      int priority, Function(T) onAction) {
    this._dispatcher = reducer;
    this.tag = tag;
    this.id = id;
    this.priority = priority;
    this._onAction = onAction;
  }

  void onActionCall(T action) {
    if (_disposed) {
      return;
    }
    _onAction(action);
  }

  Observable<T> asObservable() {
    if (_subject == null) {
      _subject = PublishSubject();
    }
    return _subject;
  }

  bool isDisposed() => _disposed;

  void dispose() {
    if (_disposed) return null;
    _dispatcher.unregisterInternal(this);
    if (_subject != null) {
      _subject.close();
    }
    _disposed = true;
    return null;
  }

  Future disposeFuture() {
    if (_disposed) return Future.value(null);
    _dispatcher.unregisterInternal(this);
    if (_subject != null) {
      return _subject.close();
    }
    _disposed = true;
    return Future.value(null);
  }
}
