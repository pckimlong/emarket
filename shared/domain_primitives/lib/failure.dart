class Failure implements Exception {
  Failure({
    required this.error,
    required this.stackTrace,
    this.message,
  });

  final Object error;
  final StackTrace stackTrace;

  /// Optional custom message to override the default message.
  final String? message;

  String get displayMessage {
    final custom = message?.trim();
    return custom ?? 'Error';
  }

  Failure copyWith({
    Object? error,
    StackTrace? stackTrace,
    String? message,
  }) {
    return Failure(
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
      message: message ?? this.message,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Failure &&
        other.runtimeType == runtimeType &&
        other.error == error &&
        other.stackTrace == stackTrace &&
        other.message == message;
  }

  @override
  int get hashCode => Object.hash(runtimeType, error, stackTrace, message);

  String toDebugString() {
    return 'Failure(message: $displayMessage, error: $error, stackTrace: $stackTrace)';
  }

  @override
  String toString() => toDebugString();
}
