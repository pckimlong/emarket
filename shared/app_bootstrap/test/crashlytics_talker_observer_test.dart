import 'package:app_bootstrap/app_bootstrap.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talker/talker.dart';

void main() {
  test('CrashlyticsTalkerObserver handles errors and exceptions safely', () {
    const observer = CrashlyticsTalkerObserver();
    final talkerError = TalkerError(
      ArgumentError('fatal test error'),
      message: 'fatal crash',
      stackTrace: StackTrace.current,
    );
    final talkerException = TalkerException(
      Exception('non-fatal test exception'),
      message: 'non fatal crash',
      stackTrace: StackTrace.current,
    );

    expect(() => observer.onError(talkerError), returnsNormally);
    expect(() => observer.onException(talkerException), returnsNormally);
  });
}
