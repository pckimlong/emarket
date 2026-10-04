import 'dart:io';

import 'package:mason/mason.dart';

void run(HookContext context) {
  final featureName = context.vars['feature_name'] as String;
  final className = context.vars['class_name'] as String;

  _registerAppDependencies(featureName);
  _exportDomainId(featureName, className);
  _formatGeneratedSources(featureName, context);

  final progress = context.logger.progress('Resolving workspace dependencies');
  final result = Process.runSync('flutter', ['pub', 'get']);
  if (result.exitCode != 0) {
    progress.fail('flutter pub get failed');
    context.logger.err('${result.stdout}\n${result.stderr}');
    throw ProcessException(
      'flutter',
      ['pub', 'get'],
      '${result.stdout}\n${result.stderr}',
      result.exitCode,
    );
  }
  progress.complete('Resolved workspace dependencies');

  final failedCodegenLayers = _runBuildRunner(featureName, context);

  context.logger.success(
    'Created $className feature and attempted build_runner in all four layers.',
  );
  if (failedCodegenLayers.isNotEmpty) {
    context.logger.warn(
      'build_runner did not complete in: ${failedCodegenLayers.join(', ')}. '
      'You can rerun those packages after prerequisites such as generated '
      'Serverpod client types are available.',
    );
  }
}

void _registerAppDependencies(String featureName) {
  _addDependenciesToPubspec(
    'apps/admin/pubspec.yaml',
    [
      '${featureName}_admin_presentation',
      '${featureName}_data',
      '${featureName}_domain',
    ],
  );

  _addDependenciesToPubspec(
    'apps/customer/pubspec.yaml',
    [
      '${featureName}_customer_presentation',
      '${featureName}_data',
      '${featureName}_domain',
    ],
  );
}

void _addDependenciesToPubspec(String pubspecPath, List<String> packageNames) {
  final file = File(pubspecPath);
  if (!file.existsSync()) return;

  final content = file.readAsStringSync();
  final lines = content.split('\n');

  final depsIndex = lines.indexWhere((line) => line.trim() == 'dependencies:');
  if (depsIndex == -1) return;

  var nextSectionIndex = lines.indexWhere(
    (line) => line.isNotEmpty && !line.startsWith(' ') && !line.startsWith('#'),
    depsIndex + 1,
  );
  if (nextSectionIndex == -1) {
    nextSectionIndex = lines.length;
  }

  final missingPackages = packageNames.where((pkg) {
    final regex = RegExp(r'^\s+' + RegExp.escape(pkg) + r':', multiLine: true);
    return !regex.hasMatch(content);
  }).toList();

  if (missingPackages.isEmpty) return;

  var insertIndex = nextSectionIndex;
  while (insertIndex > depsIndex + 1 && lines[insertIndex - 1].trim().isEmpty) {
    insertIndex--;
  }

  final newLines = missingPackages.map((pkg) => '  $pkg: ^0.0.1').toList();
  lines.insertAll(insertIndex, newLines);
  file.writeAsStringSync(lines.join('\n'));
}

List<String> _runBuildRunner(String featureName, HookContext context) {
  final failedLayers = <String>[];

  for (final layer in ['domain', 'data', 'admin_presentation', 'customer_presentation']) {
    final packageName = '${featureName}_$layer';
    final packagePath = 'features/$featureName/$packageName';
    final progress = context.logger.progress(
      'Running build_runner in $packageName',
    );

    try {
      final result = Process.runSync(
        'dart',
        ['run', 'build_runner', 'build'],
        workingDirectory: packagePath,
      );
      if (result.exitCode == 0) {
        progress.complete('Ran build_runner in $packageName');
        continue;
      }

      failedLayers.add(layer);
      progress.fail('build_runner failed in $packageName');
      context.logger.detail('${result.stdout}\n${result.stderr}');
    } catch (error) {
      failedLayers.add(layer);
      progress.fail('build_runner failed in $packageName');
      context.logger.detail('$error');
    }
  }

  return failedLayers;
}

void _formatGeneratedSources(String featureName, HookContext context) {
  final progress = context.logger.progress('Formatting generated sources');
  final result = Process.runSync('dart', [
    'format',
    'features/$featureName',
    'shared/domain_primitives/lib/ids/${featureName}_id.dart',
  ]);
  if (result.exitCode != 0) {
    progress.fail('dart format failed');
    context.logger.err('${result.stdout}\n${result.stderr}');
    throw ProcessException(
      'dart',
      ['format', 'features/$featureName'],
      '${result.stdout}\n${result.stderr}',
      result.exitCode,
    );
  }
  progress.complete('Formatted generated sources');
}

void _exportDomainId(String featureName, String className) {
  final exportsFile = File('shared/domain_primitives/lib/ids/ids.dart');
  final exportLine = "export '${featureName}_id.dart';";
  final lines = exportsFile.readAsLinesSync().where((line) => line.trim().isNotEmpty).toSet();
  lines.add(exportLine);
  final sortedLines = lines.toList()..sort();
  exportsFile.writeAsStringSync('${sortedLines.join('\n')}\n');

  final idFile = File(
    'shared/domain_primitives/lib/ids/${featureName}_id.dart',
  );
  if (!idFile.existsSync()) {
    throw StateError(
      'Expected generated ${className}Id source at ${idFile.path}.',
    );
  }
}
