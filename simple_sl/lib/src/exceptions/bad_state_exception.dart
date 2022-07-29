class BadStateException implements Exception {
  final String message;
  BadStateException([this.message = '']);

  @override
  String toString() {
    return 'Bad State${message.isNotEmpty ? ': $message' : ''}';
  }
}
