import 'dart:collection';

///
/// Base of all type of Module
///
class Member {
  final String name;
  final String? comment;

  Member(this.name, [this.comment]); // : assert(name.isNotEmpty);

  String toString() => name;
}

///
/// Represents ice module
/// like:
/// ```slice
/// module Ice {}
/// ```
class Module extends Member {
  /// global name, id = ::prent-name::name
  final String? id;
  final List<String> metaList;
  final List<Member> children;

  Module(String name, this.children, this.metaList, [this.id]) : super(name);

  bool get isRoot => id?.lastIndexOf('::') == 0;

  Module apply({String? name, String? id}) => Module(
        name ?? this.name,
        this.children,
        this.metaList,
        id ?? this.id,
      );

  String toString() => 'module $name';
}

///
/// Represents ice enum
/// like:
/// ```slice
/// enum OperationMode {
///   normal,
/// }
/// ```
class Enum extends Member {
  final bool local;
  final List<Member> children;

  Enum({
    required String name,
    required this.children,
    this.local = false,
    String? comment,
  }) : super(name, comment);

  String toString() => 'enum $name';
}

///
/// Represents parameter, struct member, return type and `typedef`.
/// like typedef:
///   sequence<int> IntSeq;
///
/// member of struct:
///   int a;
///
/// parameter of method:
///   [meta] out optional(1) Ice::Type value,
///
class Typo extends Member {
  final String type;

  /// optional index
  final int optional;

  /// If true, this Typo is an `out` parameter
  final bool out;

  final String? meta;

  Typo({
    required String name,
    required this.type,
    this.optional = 0,
    this.out = false,
    this.meta,
    String? comment,
  }) : super(name, comment);

  /// Return type of Method
  factory Typo.ret(String type, [int optional = 0]) =>
      Typo(name: '', type: type, optional: optional);

  String toString() => '$type $name';
}

///
/// Represents class, struct and exception in ice.
/// Method in class is deprecated.
class Class extends Member {
  /// struct, class, exception
  final String type;
  final bool local;
  final String? base;
  final List<Typo> children;
  Class({
    required String name,
    required this.children,
    this.base,
    this.local = false,
    this.type = 'class',
    String? comment,
  }) : super(name, comment);

  String toString() => '$type $name';
}

///
/// Represents ice interface
///
class Interface extends Member {
  final String? base;
  final bool local;
  final List<String> metaList;
  final List<Method> methodList;

  Interface({
    required String name,
    this.base,
    required this.metaList,
    required this.methodList,
    this.local = false,
    String? comment,
  }) : super(name, comment);

  String toString() => 'interface $name';
}

///
/// Copy from ice, make this package depend package:ice/ice.dart
enum OperationMode { normal, nonmutating, idempotent }

///
/// Represents method of ice interface.
/// like:
/// ```slice
///   [meta] optional(1) idempotent int foo([meta] out optional(1) int v);
/// ```
class Method {
  final String name;
  final String? comment;
  Typo returnType;
  final List<Typo> prameterList;
  final List<String> metaList;
  OperationMode mode;

  Method({
    required this.name,
    required this.returnType,
    required this.metaList,
    required this.prameterList,
    this.comment,
    this.mode = OperationMode.normal,
  });

  @override
  String toString() => '$returnType $name';
}

///
/// Represents slice file
///
class Slice {
  final String filename;
  final List<String> metaList;

  /// All modules. Map key is Module.id
  final root = <String, Module>{};

  /// In slice file, all `#include` filename [Set]
  final includes = <String>{};

  /// All includes files parsed and contained in this.
  Slice? reference;

  Slice(this.filename, this.metaList);

  /// Add include filename as [name].
  void include(String name) => includes.add(name);

  /// Used in [parse]
  Module? _current;
  final _q = Queue<Module>();

  bool get isEmpty {
    if (root.isEmpty) return true;
    return root.values
        .map((m) => m.children.isEmpty)
        .toList()
        .skipWhile((value) => false)
        .isEmpty;
  }

  /// In process of [parse], enter a module
  void enterModule(Module m) {
    // set id to module as ::Ice::Metrix
    // TODO: reopen module in one file
    String id = _current == null ? '::${m.name}' : '${_current!.id}::${m.name}';
    m = m.apply(id: id);

    if (m.isRoot) {
      root[m.id!] = m;
    }

    if (_current != null) {
      //
      _current!.children.add(m);
    }

    _q.addLast(m);
    _current = m;
  }

  /// In process of [parse], left a module
  void leaveModule() {
    assert(_current != null);
    _q.removeLast();
    _current = _q.isNotEmpty ? _q.last : null;
  }

  /// In process of [parse], add enum, class... into [Slice] as a member
  void add(Member m) {
    _current?.children.add(m);
  }
}
