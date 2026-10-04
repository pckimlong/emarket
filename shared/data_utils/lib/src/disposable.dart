/// An interface for objects that hold disposable resources (such as streams,
/// subscriptions, or controllers) and need explicit cleanup when discarded.
abstract interface class Disposable {
  /// Releases all resources held by this object.
  void dispose();
}
