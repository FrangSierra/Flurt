import 'package:rxdart/rxdart.dart';

typedef StateCallback<S> = void Function(S);

abstract class Store<S extends Object> {
  Map<String, Object> _properties = new Map();
  List<StoreObserver<S>> observers = new List();
  PublishSubject<S> processor = new PublishSubject();
  StateCallback<S> processorObserver;

  Store(this._properties, this.observers, this.processor) {
    processorObserver = (S newState) => processor.add(newState);
  }

  S _state = null;

  S get state {
    if (_state == null)
      return _state = initialState();
    else
      return _state;
  }

  set state(S newState) {
    if (newState != _state) {
      _state = newState;
      observers.forEach((storeObserver) => storeObserver.onStateChanged(state));
    }
  }

  /**
   * Returns the initial state of the store.
   */
  S initialState();

  /**
   * Initialize the store after dependency injection is complete.
   */
  void init() {
    //No-op
  }

  Observable<S> asObservable() {
    return processor.startWith(state);
  }

  StoreObserver<S> observe(StateCallback<S> cb) {
    StoreObserver<S> observer = StoreObserver(this, cb);
    observers.add(observer);
    return observer;
  }
}

class StoreObserver<S extends Object> {
  Store<S> store;
  StateCallback<S> cb;

  StoreObserver(Store<S> store, StateCallback<S> cb) {
    this.store = store;
    this.cb = cb;
  }

  void onStateChanged(S state) {
    cb(state);
  }

  void dispose() {
    store.observers.remove(this);
  }
}
