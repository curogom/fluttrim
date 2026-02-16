class CancellationToken {
  bool _isCancelled = false;

  bool get isCancelled => _isCancelled;

  void cancel() {
    _isCancelled = true;
  }

  void throwIfCancelled() {
    if (_isCancelled) {
      throw const CancelledException();
    }
  }
}

class CancelledException implements Exception {
  const CancelledException();

  @override
  String toString() => 'CancelledException';
}
