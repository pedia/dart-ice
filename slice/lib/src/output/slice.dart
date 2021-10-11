library slice.output.slice;

import 'package:path/path.dart' as path;
import '../../slice.dart';
import 'output.dart';

import '../util/colors.dart';

class SliceOutput extends Output {
  /// ANSI/xterm color.
  final bool color;

  SliceOutput(
    Slice slice, {
    this.color = true,
    bool comment = true,
  }) : super(slice, comment: comment);

  String filename() => path.basename(slice.filename);

  String generate() {
    enableColors = color;
    final o = StringBuffer();

    slice.root.forEach((id, m) => o.writeln(emitModule(m)));

    return o.toString();
  }

  String emitModule(Module module) {
    final o = StringBuffer();
    if (module.comment != null) {
      o.writeln('${green(module.comment!)}');
    }
    o.writeln('module ${module.name} {\n'); // follow a blank line

    o.write(super.emitModule(module));

    o.writeln('}');
    return o.toString();
  }

  String emitMethod(Method m) => [
        if (comment && m.comment != null) '  ${green(m.comment!)}',
        ...m.metaList.map((x) => ('  [${magenta(x)}]')).toList(),
        '  ${m.mode == OperationMode.idempotent ? "idempotent " : ""}${m.returnType.type} ${cyan(m.name)}(${m.prameterList.join(', ')});',
      ].join('\n');

  String emitInterface(Interface i) => [
        if (comment && i.comment != null) '${green(i.comment!)}',
        if (i.metaList.isNotEmpty) magenta(i.metaList.toString()),
        '${i.local ? "local " : ""}interface ${i.name} '
            '${i.base != null ? "extends $i.base" : ""} '
            '{',
        ...i.methodList.map((x) => emitMethod(x)).toList(),
        '}\n',
      ].join('\n');

  String emitClass(Class c) => [
        if (comment && c.comment != null) '${green(c.comment!)}',
        if (c.base != null)
          '${c.local ? "local " : ""}${c.type} ${c.name} extends ${c.base} {',
        if (c.base == null) '${c.local ? "local " : ""}${c.type} ${c.name} {',
        ...c.children
            .map((x) => [
                  if (comment && x.comment != null) '  ${green(x.comment!)}',
                  '  ${x.optional != 0 ? "optional(${x.optional}) " : ""}${x.type} ${x.name};',
                ].join('\n'))
            .toList(),
        '}\n',
      ].join('\n');

  String emitEnum(Enum e) => [
        if (comment && e.comment != null) '${green(e.comment!)}',
        '${e.local ? "local " : ""}enum ${e.name} {',
        ...e.children
            .map((x) => [
                  if (comment && x.comment != null) '  ${green(x.comment!)}',
                  '  $x,',
                ].join('\n'))
            .toList(),
        '}\n',
      ].join('\n');

  String emitTypo(Typo t) => [
        if (comment && t.comment != null) '  ${green(t.comment!)}',
        if (t.name.isNotEmpty) '${t.type} ${t.name};',
      ].join(('\n'));
}
