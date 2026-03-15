import 'dart:async';

/// Singleton event bus for auth-related events
/// This allows the DioClient to notify the app when authentication fails
class AuthEventBus {
  AuthEventBus._();

  static final AuthEventBus _instance = AuthEventBus._();
  static AuthEventBus get instance => _instance;

  final _controller = StreamController<AuthEvent>.broadcast();

  /// Stream of auth events
  Stream<AuthEvent> get stream => _controller.stream;

  /// Emit an auth event
  void emit(AuthEvent event) {
    _controller.add(event);
  }

  /// Emit unauthorized event (401)
  void emitUnauthorized() {
    emit(AuthEvent.unauthorized);
  }

  /// Dispose the event bus (call on app shutdown)
  void dispose() {
    _controller.close();
  }
}

/// Auth events that can be broadcast
enum AuthEvent {
  /// User session is unauthorized (401 error)
  unauthorized,

  /// Session expired
  sessionExpired,

  /// Force logout requested
  forceLogout,
}
