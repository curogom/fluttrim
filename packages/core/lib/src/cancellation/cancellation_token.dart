/// Cooperative cancellation token shared across long-running operations.
class CancellationToken {
  bool _isCancelled = false;

  /// Returns `true` when cancellation was requested.
  bool get isCancelled => _isCancelled;

  /// Requests cancellation.
  void cancel() {
    _isCancelled = true;
  }

  /// Throws [CancelledException] when cancellation was requested.
  void throwIfCancelled() {
    if (_isCancelled) {
      throw const CancelledException();
    }
  }
}

/// Exception thrown by [CancellationToken.throwIfCancelled].
class CancelledException implements Exception {
  /// Creates a cancellation exception.
  const CancelledException();

  @override
  String toString() => 'CancelledException';
}
