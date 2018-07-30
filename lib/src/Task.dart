/** State of the task. Idle is not a terminal state*/
enum TaskStatus { IDLE, RUNNING, SUCCESS, ERROR }

typedef TypedTask<Object> Task();

/**
 * Basic object to represent an ongoing process.
 */
class TypedTask<T> {
  TaskStatus status;
  T metadata;
  Exception error;

  TypedTask(T metadata,
      {TaskStatus status = TaskStatus.IDLE, Exception error = null}) {
    this.status = status;
    this.metadata = metadata;
    this.error = error;
  }

  bool isRunning() => status == TaskStatus.RUNNING;

  bool isFailure() => status == TaskStatus.ERROR;

  bool isTerminal() => isFailure() || isSuccessful();

  bool isSuccessful() => status == TaskStatus.SUCCESS;

  //Factory functions

  /** Idle task **/
  factory TypedTask.taskIdle() => TypedTask(null);

  /** Sets the task as succeeded with data. */
  factory TypedTask.taskSuccess() =>
      TypedTask(null, status: TaskStatus.SUCCESS);

  /** Sets the task as running. */
  factory TypedTask.taskRunning() =>
      TypedTask(null, status: TaskStatus.RUNNING);

  /** Sets the task as error, with its cause. */
  factory TypedTask.taskFailure(Exception error) =>
      TypedTask(null, status: TaskStatus.ERROR, error: error);
}

//Utilities for task collections

/** Find the first failed task or throw an exception. */
TypedTask<T> firstFailure<T>(Iterable<TypedTask<T>> iterable) {
  TypedTask<T> first =
      iterable.firstWhere((item) => item.isFailure() && item.error != null);
  if (first == null) throw Exception("Null value found during the iteration");
  return first;
}

/** Find the first failed task or throw an exception. */
TypedTask<T> firstFailureOrNull<T>(Iterable<TypedTask<T>> iterable) =>
    iterable.firstWhere((item) => item.isFailure() && item.error != null);

/** Find the first failed task or throw an exception. */
bool allCompleted<T>(Iterable<TypedTask<T>> iterable) =>
    iterable.every((item) => item.isTerminal());

/** Find the first failed task or throw an exception. */
bool allSuccessful<T>(Iterable<TypedTask<T>> iterable) =>
    iterable.every((item) => item.isSuccessful());

/** Find the first failed task or throw an exception. */
bool anyFailure<T>(Iterable<TypedTask<T>> iterable) =>
    iterable.any((item) => item.isFailure());

/** Find the first failed task or throw an exception. */
bool anyRunning<T>(Iterable<TypedTask<T>> iterable) =>
    iterable.any((item) => item.isRunning());
