import 'package:talker/talker.dart';

/// A [TalkerObserver] that forwards errors, exceptions, and critical logs
/// to Firebase Crashlytics.
///
/// Placeholder/stub implementation: override [onError] and [onException]
/// to call `FirebaseCrashlytics.instance.recordError(...)`.
class CrashlyticsTalkerObserver extends TalkerObserver {
  const CrashlyticsTalkerObserver();

  @override
  void onError(TalkerError err) {
    // TODO: Implement actual Crashlytics reporting when ready:
    // FirebaseCrashlytics.instance.recordError(
    //   err.error,
    //   err.stackTrace,
    //   reason: err.message,
    //   fatal: true,
    // );
  }

  @override
  void onException(TalkerException err) {
    // TODO: Implement actual Crashlytics reporting when ready:
    // FirebaseCrashlytics.instance.recordError(
    //   err.exception,
    //   err.stackTrace,
    //   reason: err.message,
    //   fatal: false,
    // );
  }
}
