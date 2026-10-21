/// Sealed class for application exception hierarchy per Step 4 Dart 3 rules.
sealed class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Network connectivity exception.
class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection.', super.code = 'NETWORK_ERROR']);
}

/// Data parsing exception.
class DataParseException extends AppException {
  const DataParseException([super.message = 'Failed to parse data payload.', super.code = 'PARSE_ERROR']);
}

/// Storage exception.
class StorageException extends AppException {
  const StorageException([super.message = 'Local storage operation failed.', super.code = 'STORAGE_ERROR']);
}

/// General fallback application exception.
class GenericAppException extends AppException {
  const GenericAppException([super.message = 'An unexpected error occurred.', super.code = 'GENERIC_ERROR']);
}
