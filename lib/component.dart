part of gladius;

/// An object-oriented way
/// of implementing middleware
/// for use in [HttpApp].
///
/// To use one of these,
/// derive this class, and use
/// [HttpApp.use]
/// with an instance of your
/// derived class.
abstract class Component {
  Future call(Context ctx, Future next());
}
