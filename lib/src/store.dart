import 'package:rxdart/rxdart.dart';

typedef StateCallback<S> = void Function(S);

abstract class Store<S extends Object> {
  Map<String, Object> _properties;
  List<StoreObserver<S>> _observers;
  PublishSubject<S> _processor;
  StateCallback<S> _processorObserver;

  Store() {
    this._properties = new Map();
    this._observers = new List();
    this._processor = new PublishSubject();
    _processorObserver = (S newState) => _processor.add(newState);
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
      _observers
          .forEach((storeObserver) => storeObserver.onStateChanged(state));
    }
  }

  /**
   * This a private api that needs to be public for code-gen purposes.
   * Never call this method.
   */
  setStateInternal(S newState) {
    if (newState != _state) {
      _state = newState;
      _observers.forEach((observer) => observer.onStateChanged(state));
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
    return _processor.startWith(state);
  }

  StoreObserver<S> observe(StateCallback<S> cb) {
    StoreObserver<S> observer = StoreObserver(this, cb);
    _observers.add(observer);
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
    store._observers.remove(this);
  }
}
