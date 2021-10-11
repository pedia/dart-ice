import '../../slice.dart';

abstract class Output {
  final Slice slice;

  /// Add header: part of library
  final String? library;

  /// Used internal only
  /// if true, do not import package:ice/ice.dart
  /// iif false, import package:ice/ice.dart as ice
  final bool system;

  /// Generate comments from slice file
  final bool comment;

  Output(
    this.slice, {
    this.library,
    this.system = false,
    this.comment = true,
  });

  /// Generated filename, since Dart recommend style: builtin_sequences.dart
  String filename();

  /// Process generation, return String of file content.
  String generate();

  String emitModule(Module module) {
    final o = StringBuffer();

    module.children.forEach((c) {
      if (c is Module) {
        o.writeln(emitModule(c));
      } else if (c is Interface) {
        o.writeln(emitInterface(c));
      } else if (c is Class) {
        o.writeln(emitClass(c));
      } else if (c is Enum) {
        o.writeln(emitEnum(c));
      } else if (c is Typo) {
        o.writeln(emitTypo(c));
      } else
        assert(false, 'TODO: Unknown $c');
    });

    return o.toString();
  }

  String emitInterface(Interface interface);
  String emitClass(Class c);
  String emitEnum(Enum e);
  String emitTypo(Typo typo);
}
