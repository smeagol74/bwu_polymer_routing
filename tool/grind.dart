library bwu_polymer_routing.tool.grind;

export 'package:bwu_grinder_tasks/bwu_grinder_tasks.dart'; // hide main;
import 'package:bwu_grinder_tasks/bwu_grinder_tasks.dart'
    hide main
    show grind, analyzeTask, checkTask, checkSubProjects, existingSourceDirs;
import 'package:grinder/grinder.dart' as gr;
import 'package:path/path.dart' as path;
import 'dart:io';

// TODO(zoechi) workaround because tuneup reports false negative
main(args) {
  analyzeTask =
      () => gr.Analyzer.analyze(
          findDartSourceFiles(coerceToPathList(existingSourceDirs))
              .where((p) => !p.endsWith('route_provider.dart') &&
                  !p.endsWith('routing.dart'))
              .toList());
//  checkTask = () => checkSubProjects();
  grind(args);
}

/// Given a [String], [File], or list of strings or files, coerce the
/// [filesOrPaths] param into a list of strings.
List<String> coerceToPathList(filesOrPaths) {
  if (filesOrPaths is! Iterable) filesOrPaths = [filesOrPaths];
  return filesOrPaths.map((item) {
    if (item is String) return item;
    if (item is FileSystemEntity) return item.path;
    return '${item}';
  }).toList();
}

/// Takes a list of paths and if an element is a directory it expands it to
/// the Dart source files contained by this directory, otherwise the element is
/// added to the result unchanged.
Set<String> findDartSourceFiles(Iterable<String> paths) {
  /// Returns `true` if this [fileName] is a Dart file.
  bool _isDartFileName(String fileName) => fileName.endsWith('.dart');

  /// Returns `true` if this relative path is a hidden directory.
  bool _isInHiddenDir(String relative) =>
      path.split(relative).any((part) => part.startsWith("."));

  Set<String> _findDartSourceFiles(Directory directory) {
    var files = new Set<String>();
    if (directory.existsSync()) {
      for (var entry
          in directory.listSync(recursive: true, followLinks: false)) {
        var relative = path.relative(entry.path, from: directory.path);
        if (_isDartFileName(entry.path) && !_isInHiddenDir(relative)) {
          files.add(entry.path);
        }
      }
    }
    return files;
  }

  var files = new Set<String>();

  paths.forEach((p) {
    if (FileSystemEntity.typeSync(p) == FileSystemEntityType.DIRECTORY) {
      files.addAll(_findDartSourceFiles(new Directory(p)));
    } else {
      files.add(p);
    }
  });
  return files;
}
