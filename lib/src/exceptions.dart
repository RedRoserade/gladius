part of gladius;

class EmptyPipelineError {
  String toString() => 'Empty pipeline; nothing to do. Use add() to add middleware to this app.';
}