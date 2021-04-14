import 'dart:io';

import 'package:actors/actors.dart';
import 'package:args/args.dart';
import 'package:path/path.dart' as path;
import 'package:process_run/shell.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()..addOption('prefix', abbr: 'p');
  final argsResult = parser.parse(arguments);
  final prefix = argsResult['prefix'];

  if (prefix == null) {
    throw 'You must provide a package prefix parameter (-p)';
  }

  var subDirectories = Directory.current
      .listSync()
      .where((e) => checkDirectoryValidForTest(e, prefix))
      .map((e) => startTestForDirectory(e, prefix));

  await Future.wait(subDirectories);
  print('All tests passed.');
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

Future<void> startTestForDirectory(
    FileSystemEntity entity, String prefix) async {
  var folderName = path.basename(entity.path);

  if (folderName.startsWith(prefix)) {
    var actor = Actor.of(executeFlutterTest);
    try {
      final result = await actor.send(path.canonicalize(entity.path));
      actor.close();

      if (result.exitCode != 0) {
        throw 'Failed tests on $folderName';
      }
    } catch (e) {
      print(e);
      actor.close();
      throw 'Failed tests on $folderName';
    }
  }
}

Future<ProcessResult> executeFlutterTest(String folderPath) async {
  final shell = Shell(
    workingDirectory: path.canonicalize(folderPath),
    runInShell: false,
  );

  return shell.run('flutter test').then((value) => value.first);
}
