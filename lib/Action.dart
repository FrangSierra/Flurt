/**
 * Abstraction over anything that can be dispatched
 * to avoid type bugs (dispatching a non-action object).
 */
abstract class Action {
  /**
   * List of type names this action may be observed by.
   */
  Set<String> tags; //TODO Class reflection?
}
