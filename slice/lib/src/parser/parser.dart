import '../scanner/token.dart' show Token, StringToken, TokenType;
import '../parser/parser_error.dart' show ParserError;
import '../parser/util.dart' show optional;

import '../../slice.dart';

class Parser {
  bool get hasError => errors.isNotEmpty;
  final errors = <ParserError>[];

  final Slice? visitor;
  Parser(this.visitor);

  parseUnit(Token t) {
    //
    t = syntheticPreviousToken(t);

    t = t.next!;

    /// preprocess if/ifndef endif
    /// it's diffcult to remove tokens

    while (!t.isEof) {
      t = parseTopLevelDeclaration(t);
    }
  }

  /// TopLevelDeclaration:
  ///   module
  ///   #
  ///
  parseTopLevelDeclaration(Token t) {
    if (optional('module', t)) {
      t = parseModule(t, <String>[]);
    } else if (optional('#', t)) {
      t = parseHash(t);
    } else {
      t = t.next!;
    }

    return t;
  }

  Token parseMetadataStar(Token t, metaList) {
    while (optional('[[', t) || optional('[', t)) {
      t = parseMetadata(t, (meta) => metaList.add(meta));
    }
    return t;
  }

  Token parseMetadata(Token t, void Function(String) feed) {
    assert(optional('[[', t) || optional('[', t));

    final at = t;
    String meta = '';

    while (!identical(at.endGroup, t)) {
      if (!optional('[[', t) &&
          !optional(']]', t) &&
          !optional('[', t) &&
          !optional(']', t)) {
        meta += t.lexeme;
      }
      t = t.next!;
    }
    feed(meta);
    return t.next!;
  }

  /// Create and return a t whose next t is the given [t].
  Token syntheticPreviousToken(Token t) {
    // Return the previous t if there is one so that any t inserted
    // before `t` will be properly inserted into the t stream.
    if (t.previous != null) {
      return t.previous!;
    }
    Token before = new Token.eof(/* offset = */ -1);
    before.next = t;
    return before;
  }

  ///
  /// #include <xx>
  /// #pragma once
  /// #ifndef xx
  /// #endif
  /// #if !defined() && ...
  Token parseHash(Token t) {
    final Token at = t;
    assert(optional('#', at));
    final Token n = at.next!;

    if (optional('include', n)) {
      final Token beg = n.next!;
      assert(optional('<', beg) || optional('"', beg));
      assert(beg.endGroup != null);

      t = beg.next!;

      String f = '';
      while (!identical(t, beg.endGroup)) {
        f += t.lexeme;
        t = t.next!;
      }

      visitor?.include(f);

      t = t.next!;
    } else if (optional('pragma', n)) {
      assert('once' == n.next!.lexeme);
      t = n.next!.next!;
    } else if (optional('ifndef', n) ||
        optional('if', n) ||
        optional('ifdef', n)) {
      // find endif
      while (!optional('endif', t)) {
        t = t.next!;
      }
      t = t.next!;
    } else if (optional('endif', n)) {
      t = t.next!;
    } else if (optional('define', n)) {
      // TODO: add keyword define
      t = t.next!;
    } else {
      assert(false, '#${n.stringValue} not support');
    }

    return t;
  }

  /// Handle structure like:
  ///    struct name {}
  ///    class name extends yyy {}
  /// and forward declaration like:
  ///    struct name;
  ///
  Token _parseBracket(Token t, String typeName,
      [Token Function(Token, Token)? parseInner]) {
    assert(optional(typeName, t));
    final Token name = t.next!;

    // forward declare: interface Router;
    if (optional(';', name.next!)) {
      parseForwardDeclaration(t);
      return name.next!.next!;
    }

    while (!optional('{', t)) {
      t = t.next!;
    }
    final Token bracket = t;

    assert(optional('{', bracket));
    while (!identical(t, bracket.endGroup)) {
      if (parseInner != null)
        t = parseInner(name, bracket);
      else
        t = t.next!;
    }

    assert(optional('}', t));
    return t.next!;
  }

  ///
  /// ["swift:nonnull"] local sequence<Endpoint> EndpointSeq;;
  ///   local interface Communicator;
  ///   interface Router;
  ///   local class EndpointInfo;
  ///   ["swift:nonnull"] local sequence<Endpoint> EndpointSeq;
  ///   const short TCPEndpointType = 1;
  ///
  void parseForwardDeclaration(Token name) {
    Token t = name.previous!;
  }

  Token parseException(Token t) {
    return t.next!;
  }

  /// Ice:
  ///   submodule, enumerations, structures, sequences, and dictionaries
  ///
  /// Since classes with operations are deprecated, we dropped class's method,
  /// treat it as `struct`
  /// Serialization of `class` and `struct` are same.
  ///
  Token parseModule(Token t, metaList) {
    assert(optional('module', t));

    final Token name = t.next!;
    final Token bracet = name.next!;
    assert(optional('{', bracet));

    final Token at = t;
    t = bracet;
    visitor?.enterModule(Module(name.lexeme, [], metaList));

    while (!identical(t, bracet.endGroup)) {
      // some #ifdef in interface
      if (optional('#', t)) {
        t = parseHash(t);
      }

      if (optional('interface', t)) {
        t = _parseBracket(t, 'interface', parseInterface);
      } else if (optional('class', t)) {
        t = _parseBracket(t, t.lexeme, parseClass);
      } else if (optional('exception', t)) {
        t = _parseBracket(
          t,
          'exception',
          (Token name, Token bracet) => parseClass(name, bracet, 'exception'),
        );
      } else if (optional('struct', t)) {
        t = _parseBracket(
          t,
          'struct',
          (Token name, Token bracet) => parseClass(name, bracet, 'struct'),
        );
      } else if (optional('enum', t)) {
        t = _parseBracket(t, 'enum', parseEnum);
      } else if (optional('module', t)) {
        t = parseModule(t, <String>[]);
      }
      //
      else if (optional('sequence', t) || optional('dictionary', t)) {
        t = parseSequence(t);
      } else
        t = t.next!;
    }

    visitor?.leaveModule();

    assert(optional('}', t));
    return t.next!;
  }

  Token parseSequence(Token t) {
    assert(optional('<', t.next!));
    // ignore local

    final comment = t.precedingComments ?? t.previous?.precedingComments;

    String type = '${t.lexeme}<';

    t = t.next!.next!;

    // sequence<Object*> ObjectProxySeq;
    // sequence<int> IntSeq;
    // dictionary<string, ["swift:nonnull"] Object> FacetMap;
    bool garbage = false;
    while (!optional('>', t)) {
      if (optional('[', t)) {
        garbage = true;
        t = t.next!;
        continue;
      } else if (optional(']', t)) {
        garbage = false;
        t = t.next!;
        continue;
      }

      if (!garbage) type += t.lexeme;

      t = t.next!;
    }
    final gt = t;
    type += '>';

    visitor?.add(Typo(
      type: '$type',
      name: gt.next!.lexeme,
      comment: comment?.lexeme,
    ));

    t = gt.next!.next!;

    assert(optional(';', t));
    return t.next!;
  }

  Token parseClass(Token name, Token bracet, [String classType = 'class']) {
    assert(optional('{', bracet));

    bool local = false;
    Token? base;

    if (optional('extends', name.next!)) {
      base = name.next!.next!;
    }

    if (optional('local', name.previous!.previous!)) {
      local = true;
    }

    final children = <Typo>[];

    Token t = bracet.next!;
    while (!optional('}', t)) {
      // optional worked in exception/class
      //  optional(1) Ice::Type a = 1;
      //  [] short a();

      Token first = t;

      // skip []
      if (optional('[', t)) {
        t = t.endGroup!.next!;
      }

      int opt = 0;
      if (optional('optional', t)) {
        assert(optional('(', t.next!));
        opt = int.parse(t.next!.next!.lexeme);
        t = t.next!.next!.next!.next!;
      }

      String type = t.lexeme;
      if (optional('::', t.next!)) {
        t = t.next!;
        type += '::${t.lexeme}';
        t = t.next!;
        type += t.lexeme;
        t = t.next!;
      } else {
        type = t.lexeme;
        t = t.next!;
      }

      String name = t.lexeme;

      // skip method
      if (optional('(', t.next!)) {
        while (!optional(';', t)) {
          t = t.next!;
        }
        t = t.next!;
        continue;
      }

      children.add(Typo(
          type: type,
          name: name,
          comment: first.precedingComments?.lexeme,
          optional: opt));

      while (!optional(';', t)) {
        t = t.next!;
      }

      t = t.next!;
    }

    final c = Class(
      name: name.lexeme,
      children: children,
      local: local,
      base: base?.lexeme,
      type: classType,
    );
    visitor?.add(c);

    assert(optional('}', t));
    return t;
  }

  Token parseEnum(Token name, Token bracet) {
    assert(optional('{', bracet));
    assert(identical(name.next, bracet));

    bool local = false;
    if (optional('local', name.previous!.previous!)) {
      local = true;
    }

    final e = Enum(
      name: name.lexeme,
      local: local,
      children: [],
    );

    Token t = bracet.next!;
    while (!identical(t, bracet.endGroup)) {
      // \Idempotent, Idempotent,
      Token name, wc;
      if (optional('\\', t)) {
        name = t.next!;
        wc = t;
        t = t.next!.next!;
      } else {
        name = t;
        wc = t;
        t = t.next!;
      }

      e.children.add(Member(
        name.lexeme,
        wc.precedingComments?.lexeme,
      ));

      if (optional('=', t)) {
        t = t.next!.next!;
      }

      if (optional(',', t)) {
        t = t.next!;
      }
    }

    visitor?.add(e);

    assert(optional('}', t));
    return t;
  }

  Token parseInterface(Token name, Token bracet) {
    // final metaList = <String>[];
    // t = parseMetadataStar(t, metaList);

    bool local = false;
    Token? base;

    if (optional('local', name.previous!.previous!)) {
      local = true;
    }

    if (optional('extends', name.next!)) {
      base = name.next!.next!;
    }

    final methodList = <Method>[];

    // {; .next()
    Token startFunction = bracet.next!;

    Token t = bracet.next!;

    while (!identical(t, bracet.endGroup)) {
      // empty
      if (optional('}', t)) {
        break;
      } else if (optional('(', t)) {
        t = parseMethod(startFunction, t, (m) => methodList.add(m));
        startFunction = t.next!;
      } else if (optional('#', t)) {
        t = parseHash(t);
      }
      t = t.next!;
    }

    final i = Interface(
      name: name.lexeme,
      local: local,
      base: base?.lexeme,
      methodList: methodList,
      metaList: [],
    );

    visitor?.add(i);

    assert(optional('}', t));
    return t;
  }

  Token parseMethod(Token t, Token paren, void Function(Method) feed) {
    assert(optional('(', paren));

    final at = t;

    final metaList = <String>[];
    t = parseMetadataStar(t, metaList);

    // return value
    int opt = 0;
    if (optional('optional', t)) {
      // optional(1) int op();
      assert(optional('(', t.next!));
      opt = int.parse(t.next!.next!.lexeme);
      t = t.next!.next!.next!.next!;
    }

    bool star = false;
    Token returnType;
    OperationMode mode = OperationMode.normal;
    // normal, nonmutating idempotent
    if (optional('idempotent', t)) {
      t = t.next!;
      returnType = t;
      mode = OperationMode.idempotent;
    } else if (optional('nonmutating', t)) {
      t = t.next!;
      returnType = t;
      mode = OperationMode.nonmutating;
    } else {
      // Ice::Endpoint
      if (optional('::', t.next!)) {
        returnType = StringToken(
            TokenType.STRING, '${t.lexeme}::${t.next!.next!.lexeme}', 0);
        t = t.next!.next!;
      } else {
        returnType = t;
      }
    }

    if (optional('*', t.next!)) {
      star = true;
    }

    // method name
    String name = paren.previous!.lexeme;

    final parameters = <Typo>[];

    t = parseParameterStar(paren.next!, parameters);

    final m = Method(
      name: name,
      returnType:
          Typo.ret(star ? returnType.lexeme + '*' : returnType.lexeme, opt),
      metaList: metaList,
      prameterList: parameters,
      comment: at.precedingComments?.lexeme,
      mode: mode,
    );
    feed(m);

    assert(optional(')', t));

    t = t.next!;

    // throws AdapterNotFoundException, AdapterAlreadyActiveException, InvalidReplicaGroupIdException;
    if (optional('throws', t)) {
      while (!optional(';', t)) {
        t = t.next!;
      }
      return t;
    }

    return t;
  }

  Token parseParameterStar(Token t, parameters) {
    while (!optional(')', t)) {
      t = parseParameter(t, (p) => parameters.add(p));
    }
    assert(optional(')', t));
    return t;
  }

  Token parseParameter(Token t, void Function(Typo) feed) {
    final metaList = <String>[];
    t = parseMetadataStar(t, metaList);

    bool out = false;
    int opt = 0;
    bool star = false;
    late String type;

    // out optional(1) Ice::Entry* name;
    if (optional('out', t)) {
      out = true;
      t = t.next!;
    }

    if (optional('optional', t)) {
      assert(optional('(', t.next!));
      opt = int.parse(t.next!.next!.lexeme);

      t = t.next!.next!.next!.next!;
    }

    if (optional('::', t.next!)) {
      type = '${t.lexeme}::${t.next!.next!.lexeme}';
      t = t.next!.next!.next!;
    } else {
      type = t.lexeme;
      t = t.next!;
    }

    if (optional('*', t)) {
      star = true;
      t = t.next!;
    }

    final nameToken = optional('\\', t) ? t.next! : t;
    t = nameToken.next!;

    final p = Typo(
      out: out,
      optional: opt,
      type: star ? type + '*' : type,
      name: nameToken.lexeme,
      meta: metaList.isNotEmpty ? metaList[0] : null,
    );

    feed(p);

    if (optional(',', t)) {
      t = t.next!;
    }

    return t;
  }
}

List<ParserError> parse(Token tokens, [Slice? visitor]) {
  final p = Parser(visitor)..parseUnit(tokens);
  return p.errors;
}
