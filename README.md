# Flurt
Flurt is a minimal Flux architecture written in Dart. I'm not a Dart developer, this is an implementation of one of my android team architectures ported to Dart. The library could be not 100% stable and the implementation could be not the best one. 

### Purpose
You should use this library if you aim to develop a reactive application with good performance (no reflection using code-gen).
Feature development using Flurt is fast compared to traditional architectures (like CLEAN or MVP), low boilerplate and state based models make feature integration and bugfixing easy as well as removing several families of problems like concurrency or view consistency across screens.

## How to Use
### Actions
Actions are helpers that pass data to the Dispatcher. They represent use cases of our application and are the start point of any state change made during the application lifetime. 

```dart
class LoginAction extends Action {
  String username;
  String password;

  LoginAction(String username, String password) {
    this.username = username;
    this.password = password;
  }
}
```

### Dispatcher
The dispatcher receives Actions and broadcast payloads to registered callbacks. The instance of the Dispatcher must be unique across the whole application and it will execute all the logic in the main thread making state mutations synchronous. 

```dart
dispatcher.dispatch(LoginAction("user","123"));
```

### Store
The Stores are holders for application state and state mutation logic. In order to do so they expose pure reducer functions that are later invoked by the dispatcher.

The state is plain object (usually a data class) that holds all information needed to display the view. State should always be immutable. State classes should avoid using framework elements (View, Camera, Cursor...) in order to facilitate testing.

Stores subscribe to actions though the `Dispatcher` to change the application state after a dispatch. 
```dart

class SessionState {
  String loggedUsername;

  SessionState({String loggedUsername = null}) {
    this.loggedUsername = loggedUsername;
  }
}

class SessionStore extends Store<SessionState> {
  Dispatcher dispatcher;

  SessionStore(Dispatcher dispatcher) {
    this.dispatcher = dispatcher;
  }

  @override
  SessionState initialState() => SessionState();
  
  @override
  void init() {
    dispatcher.subscribe(LoginAction, (LoginAction action) {
      state = SessionState(loggedUsername: action.username)
    });
  }
}
```

### View changes
Each ``Store`` exposes an `Observable` making use of RxJava. It emits changes produced on the store state, allowing the view to listen reactive the state changes. Being able to update the UI according to the new `Store` state.

```dart
  store
      .asObservable()
      .map((state) => state.loggedUsername)
      .listen((loggedUser) => toGoHome());
```  

You can make use of the `SubscriptionTracker` class to keep track of the `StreamSubscription` used on your views.

### Tasks
A Task is a basic object to represent an ongoing process. They should be used in the state of our `Store` to represent ongoing processes that must be represented in the UI.

Using a task an example workflow will be:

- View dispatch `LoginAction`.
- Store changes his `LoginTask` status to running and call though his SessionController which will do all the async work to log in the given user.
- View shows an Spinner when `LoginTask` is in running state.
- The async call ends and `LoginCompleteAction` is dispatched on UI, sending a null `User` and an error state `Task` if the async work failed or a success `Task` and an `User`.
- The Store changes his state to the given values from `LoginCompleteAction`.
- The View redirect to the HomeActivity if the task was success or shows an error if not.