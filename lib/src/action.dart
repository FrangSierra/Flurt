import 'dart:mirrors';

/**
 * Abstraction over anything that can be dispatched
 * to avoid type bugs (dispatching a non-action object).
 */
abstract class Action {
  /**
   * List of type names this action may be observed by.
   */
  Set<ClassMirror> tags() {
    Set<ClassMirror> tags = Set();
    ClassMirror actionMirror = reflectClass(this.runtimeType);
    tags.add(actionMirror);
    tags.addAll(reflectActionTypes(actionMirror));
    return tags;
  }
}

Iterable<ClassMirror> reflectActionTypes(ClassMirror classMirror) sync* {
  if (classMirror != reflectClass(Action)) {
    yield classMirror.superclass;
    yield* reflectActionTypes(classMirror.superclass);
  }
}
