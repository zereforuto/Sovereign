/// Typed application failure base class.
sealed class Failure implements Exception {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

/// Offline or network connectivity failure.
class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'Unable to connect to the network. Please check your connection and retry.',
  ]);
}

/// Authentication or credential failure.
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Resource not found (e.g. Postgres PGRST116 single-row missing).
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Requested resource was not found.']);
}

/// Generic unexpected failure.
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred. Please try again.']);
}
