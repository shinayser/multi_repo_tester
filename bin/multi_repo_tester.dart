import 'dart:io';

import 'package:actors/actors.dart';
import 'package:args/args.dart';
import 'package:path/path.dart' as path;
import 'package:process_run/cmd_run.dart';
import 'package:process_run/shell.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('prefix', abbr: 'p')
    ..addFlag('fvm', abbr: 'f');

  final argsResult = parser.parse(arguments);
  final prefix = argsResult['prefix'] as String?;
  final fvm = argsResult['fvm'] as bool;

  if (prefix == null) {
    throw 'You must provide a package prefix parameter (-p)';
  }

  var subDirectories = Directory.current
      .listSync()
      .where((e) => checkDirectoryValidForTest(e, prefix))
      .map((e) => startTestForDirectory(
            directoryPath: e.path,
            prefix: prefix,
            usesFVM: fvm,
          ));

  try {
    await Future.wait(subDirectories);
    print('All tests passed.');
    exit(0);
  } catch (e) {
    print('Some testes failed.');
    exit(1);
  }
}

bool checkDirectoryValidForTest(FileSystemEntity entity, String prefix) {
  var directoryStatus = Directory(entity.path).statSync();

  if (directoryStatus.type == FileSystemEntityType.directory) {
    var folderName = path.basename(entity.path);

    if (folderName.startsWith(prefix)) {
      return true;
    }
  }

  return false;
}

Future<void> startTestForDirectory({
  required String directoryPath,
  required String prefix,
  bool usesFVM = false,
}) async {
  var folderName = path.basename(directoryPath);

  if (folderName.startsWith(prefix)) {
    var actor = Actor.of(executeFlutterTest);
    try {
      print('Starting tests for $folderName');

      var timeBeforeTests = DateTime.now();
      final result = await actor.send(directoryPath);
      var timeAfterTests = DateTime.now();
      actor.close();

      if (result.exitCode != 0) {
        throw 'Failed tests on $folderName';
      }

      print(
          'All tests passed for $folderName (took ${timeAfterTests.difference(timeBeforeTests).inMilliseconds / 1000.0} seconds)');
    } catch (e) {
      print(e);
      actor.close();
      throw 'Failed tests on $folderName';
    }
  }
}

Future<ProcessResult> executeFlutterTest(
  String folderPath, [
  bool usesFVM = false,
]) async {
  final cmd = ProcessCmd(
    usesFVM ? 'fvm flutter test' : 'flutter test',
    [],
    workingDirectory: path.canonicalize(folderPath),
  );

  return runCmd(cmd).then((value) => value);
}
