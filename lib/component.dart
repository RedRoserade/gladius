part of owin;

/// An object-oriented way
/// of implementing middleware
/// for use in [HttpApp].
///
/// To use one of these,
/// derive this class, and use
/// [HttpApp.useComponent]
/// with an instance of your
/// derived class.
abstract class Component {
  AppFunc next;

  Component();

  Future call(Context ctx);
}
