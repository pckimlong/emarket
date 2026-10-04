import 'dart:io';

import 'package:mason/mason.dart';

void run(HookContext context) {
  final rawName = context.vars['name'] as String;
  final featureName = rawName.trim();

  if (!RegExp(r'^[a-z][a-z0-9]*(?:_[a-z0-9]+)*$').hasMatch(featureName)) {
    throw ArgumentError.value(
      rawName,
      'name',
      'Use lower_snake_case, for example product_category.',
    );
  }

  _requireWorkspaceRoot();

  final featureDirectory = Directory('features/$featureName');
  if (featureDirectory.existsSync()) {
    throw StateError('${featureDirectory.path} already exists.');
  }
  final idFile = File(
    'shared/domain_primitives/lib/ids/${featureName}_id.dart',
  );
  if (idFile.existsSync()) {
    context.logger.detail(
      '${idFile.path} already exists; ignoring and reusing existing ID primitive.',
    );
  }

  final className = _toPascalCase(featureName);
  context.vars = {
    ...context.vars,
    'feature_name': featureName,
    'class_name': className,
    'singular_label': _toSentenceCase(featureName),
    'plural_label': _pluralize(_toSentenceCase(featureName)),
  };

  final progress = context.logger.progress('Initializing Flutter packages');
  final createdDirectories = <Directory>[];

  try {
    featureDirectory.createSync(recursive: true);
    for (final layer in ['domain', 'data', 'admin_presentation', 'customer_presentation']) {
      final packageName = '${featureName}_$layer';
      final directory = Directory('features/$featureName/$packageName');
      final result = Process.runSync('flutter', [
        'create',
        '--template=package',
        '--project-name',
        packageName,
        '--description',
        '$className feature $layer layer.',
        '--no-pub',
        directory.path,
      ]);

      if (result.exitCode != 0) {
        throw ProcessException(
          'flutter',
          ['create', '--template=package', directory.path],
          '${result.stdout}\n${result.stderr}',
          result.exitCode,
        );
      }

      createdDirectories.add(directory);
      _removeFlutterStarterFiles(directory, packageName);
    }
    progress.complete('Initialized Flutter packages');
  } catch (error) {
    progress.fail('Could not initialize Flutter packages');
    for (final directory in createdDirectories.reversed) {
      if (directory.existsSync()) {
        directory.deleteSync(recursive: true);
      }
    }
    if (featureDirectory.existsSync()) {
      featureDirectory.deleteSync(recursive: true);
    }
    rethrow;
  }
}

void _requireWorkspaceRoot() {
  final pubspec = File('pubspec.yaml');
  final primitives = File('shared/domain_primitives/lib/ids/ids.dart');
  if (!pubspec.existsSync() || !primitives.existsSync()) {
    throw StateError(
      'Run this brick from the E-Market repository root. Expected pubspec.yaml '
      'and shared/domain_primitives/lib/ids/ids.dart.',
    );
  }
}

void _removeFlutterStarterFiles(Directory directory, String packageName) {
  final paths = [
    '.gitignore',
    '.metadata',
    'analysis_options.yaml',
    'CHANGELOG.md',
    'LICENSE',
    'README.md',
    'pubspec.yaml',
    '$packageName.iml',
    'lib/$packageName.dart',
    'test/${packageName}_test.dart',
  ];

  for (final path in paths) {
    final file = File('${directory.path}/$path');
    if (file.existsSync()) file.deleteSync();
  }

  final testDirectory = Directory('${directory.path}/test');
  if (testDirectory.existsSync() && testDirectory.listSync().isEmpty) {
    testDirectory.deleteSync();
  }

  final ideaDirectory = Directory('${directory.path}/.idea');
  if (ideaDirectory.existsSync()) {
    ideaDirectory.deleteSync(recursive: true);
  }
}

String _toPascalCase(String value) => value
    .split('_')
    .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
    .join();

String _toSentenceCase(String value) {
  final words = value.split('_').join(' ');
  return '${words[0].toUpperCase()}${words.substring(1)}';
}

String _pluralize(String value) {
  final lower = value.toLowerCase();
  if (lower.endsWith('y') &&
      lower.length > 1 &&
      !'aeiou'.contains(lower[lower.length - 2])) {
    return '${value.substring(0, value.length - 1)}ies';
  }
  if (lower.endsWith('s') ||
      lower.endsWith('x') ||
      lower.endsWith('z') ||
      lower.endsWith('ch') ||
      lower.endsWith('sh')) {
    return '${value}es';
  }
  return '${value}s';
}
