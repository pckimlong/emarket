import 'package:app_logger/app_logger.dart';
import 'package:test/test.dart';

void main() {
  group('NoOpAppLogger', () {
    test('does not throw on any log level', () {
      const logger = NoOpAppLogger();
      expect(() => logger.debug('debug'), returnsNormally);
      expect(() => logger.info('info'), returnsNormally);
      expect(() => logger.warning('warning'), returnsNormally);
      expect(() => logger.error('error'), returnsNormally);
      expect(() => logger.critical('critical'), returnsNormally);
      expect(
        () => logger.handle(Exception('test'), StackTrace.current, 'handled'),
        returnsNormally,
      );
    });
  });

  group('TalkerAppLogger', () {
    test('forwards log calls to underlying Talker instance', () {
      final talker = Talker(
        settings: TalkerSettings(useConsoleLogs: false),
      );
      final logger = AppLogger.talker(talker);

      logger.info('Info message');
      logger.warning('Warning message');
      logger.error('Error message');
      logger.debug('Debug message');
      logger.critical('Critical message');
      logger.handle(Exception('boom'), StackTrace.current, 'boom msg');

      expect(talker.history.length, equals(6));
    });
  });

  group('AppLogger.root', () {
    tearDown(() {
      AppLogger.root = const NoOpAppLogger();
    });

    test('can be assigned and used globally as ambient logger', () {
      expect(AppLogger.root, isA<NoOpAppLogger>());

      final talker = Talker(
        settings: TalkerSettings(useConsoleLogs: false),
      );
      AppLogger.root = AppLogger.talker(talker);

      expect(AppLogger.root, isA<TalkerAppLogger>());
      AppLogger.root.info('Ambient info');
      expect(talker.history.length, equals(1));
    });
  });

  group('LoggerMixin', () {
    tearDown(() {
      AppLogger.root = const NoOpAppLogger();
    });

    test('automatically tags log messages with runtimeType', () {
      final talker = Talker(
        settings: TalkerSettings(useConsoleLogs: false),
      );
      AppLogger.root = AppLogger.talker(talker);

      final service = _SampleService();
      service.performAction();

      expect(
        talker.history.any(
          (log) =>
              log.message?.contains('[_SampleService] performing action') ??
              false,
        ),
        isTrue,
      );
    });

    test('supports custom loggerTag', () {
      final talker = Talker(
        settings: TalkerSettings(useConsoleLogs: false),
      );
      AppLogger.root = AppLogger.talker(talker);

      final customService = _CustomTaggedService();
      customService.performAction();

      expect(
        talker.history.any(
          (log) => log.message?.contains('[CustomTag] custom action') ?? false,
        ),
        isTrue,
      );
    });
  });
}

class _SampleService with LoggerMixin {
  void performAction() {
    logInfo('performing action');
    logDebug('debug action');
    logWarning('warning action');
    logError('error action');
    logCritical('critical action');
    logException(Exception('err'), StackTrace.current, 'failed');
  }
}

class _CustomTaggedService with LoggerMixin {
  @override
  String get loggerTag => 'CustomTag';

  void performAction() {
    logInfo('custom action');
  }
}
