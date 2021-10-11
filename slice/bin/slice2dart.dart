import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as path;

import '../lib/src/scanner/token.dart';
import '../lib/src/scanner/scanner.dart';
import '../lib/src/scanner/io.dart';
import '../lib/src/util/colors.dart';

import '../lib/src/parser/parser.dart';
import '../lib/slice.dart';

import '../lib/src/output/dart.dart';
import '../lib/src/output/slice.dart';

int main(List<String> args) {
  final ap = ArgParser()
    ..addFlag('help',
        abbr: 'h',
        defaultsTo: false,
        negatable: false,
        help: 'Print this usage information.')
    ..addMultiOption('include',
        abbr: 'I', help: 'Add folder in the search path of include file.')
    ..addOption('output-dir', abbr: 'o', help: 'Output folder.')
    ..addFlag('comment', defaultsTo: true, help: 'Genrate with comments.')
    ..addOption('library', abbr: 'l', help: 'Generate as part of library.')
    ..addSeparator('Advance debugging options:')
    ..addFlag('color', abbr: 'c', defaultsTo: true, help: 'ANSI/xterm color.')
    ..addFlag('justprint',
        abbr: 'n',
        defaultsTo: false,
        help: 'Donnt actually write anything; just print them.')
    ..addFlag('debug',
        abbr: 'd',
        defaultsTo: false,
        negatable: false,
        help: 'Print debug messages.')
    ..addFlag('dump',
        defaultsTo: false,
        negatable: false,
        help: 'Parse only, Dump parsed slice content.')
    ..addFlag('system',
        defaultsTo: false, negatable: false, help: 'Genrate ice internal.')
    ..addOption('filename', abbr: 'f', help: 'Forced change filename.');

  final opt = ap.parse(args);

  if (opt['help']) {
    print('A command-line utility for generating Dart code from Slice.\n');
    print('Usage: slice2dart [options] slice-files...\n');
    print(ap.usage);
    return 0;
  }

  if (opt.rest.isEmpty) {
    // debug only
    deal('bin/test.ice', opt);
  } else {
    opt.rest.forEach((filename) => deal(filename, opt));
  }

  return 0;
}

int deal(String filename, opt) {
  var bytes = readBytesFromFileSync(Uri.parse(filename));

  // preprceoss, remove #if ifdef ifndef endif
  {
    var s = String.fromCharCodes(bytes);
    s = s.replaceAll(RegExp('#if [^\n]*\n'), '');
    s = s.replaceAll(RegExp('#ifdef [^\n]*\n'), '');
    s = s.replaceAll(RegExp('#ifndef [^\n]*\n'), '');
    s = s.replaceAll(RegExp('#endif[^\n]*\n'), '');
    s = s.replaceAll(RegExp('#define [^\n]*\n'), '');
    bytes = s.codeUnits;
  }

  // scan
  final tree = scan(
    bytes,
    configuration: ScannerConfiguration(),
    includeComments: true,
    languageVersionChanged: (scanner, languageVersion) => {},
  );

  if (tree.hasErrors || opt['debug']) {
    Token? t = tree.tokens;
    while (t != null && !t.isEof) {
      if (t.precedingComments != null) {
        print(green(t.precedingComments!.lexeme));
      }
      print(
          '${blue(t.toString())} ${t.type} ${t.isKeyword} ${t.endGroup ?? ""}');
      t = t.next;
    }

    if (tree.hasErrors) return -1;
  }

  // create Slice
  final target = Slice(filename, []);
  final errs = parse(tree.tokens, target);
  errs.forEach((e) => print(e));

  // dump parsed slice
  if (opt['dump']) {
    print(SliceOutput(
      target,
      color: opt['color'],
      comment: opt['comment'],
    ).generate());
    return 0;
  }

  // generate
  final o = DartOutput(
    target,
    system: opt['system'],
    library: opt['library'],
    comment: opt['comment'],
  );
  final content = o.generate();

  if (opt['justprint']) {
    print(content);
    return 0;
  }

  // write to file
  if (target.isEmpty) {
    print('empty module, write nothing');
    return 1;
  }

  final fp =
      path.join(opt['output-dir'] ?? '', opt['filename'] ?? o.filename());
  File(fp).writeAsStringSync(content);
  return 0;
}
