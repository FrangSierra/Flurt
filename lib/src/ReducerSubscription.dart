import 'DynamicActionReducer.dart';
import 'dart:mirrors';

class ReducerSubscription<T> {
  ClassMirror tag;
  int id;
  int priority;
  Function(T) _onAction;
  DynamicActionReducer _reducer;
  bool _disposed = false;

  ReducerSubscription(DynamicActionReducer reducer, ClassMirror tag, int id,
      int priority, void Function(T) onAction) {
    this._reducer = reducer;
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

  bool isDisposed() => _disposed;

  void dispose() {
    if (_disposed) return;
    _reducer.unregisterInternal(this);
    _disposed = true;
  }
}
