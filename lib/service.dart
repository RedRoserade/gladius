part of gladius;

abstract class Service {
  /// Gets the associated value.
  Object get();

  /// Handler that can be used to do
  /// cleanup when a context ends.
  Future destroy() { /* Nothing by default */ }
}