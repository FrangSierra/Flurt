import 'package:flurt/src/Action.dart';

/**
 * Coordinator for stores mutating state. Implementation is automatically generated
 * by the compiler as MiniActionReducer.
 */
abstract class ActionReducer {
  /**
   * Invoke the corresponding state reducer function for the stores bound to the action.
   */
  void reduce(Action action);
}
