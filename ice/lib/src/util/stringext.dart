extension IntExt on int {
  /// width 3, prefix fill with 0
  String get oct => toRadixString(8).padLeft(3);

  /// not pad left
  String get hex => toRadixString(16);

  /// width 4, prefix fill with 0
  String get hex4 => toRadixString(16).padLeft(4, '0');

  /// width 8, prefix fill with 0
  String get hex8 => toRadixString(16).padLeft(8, '0');
}

enum ToStringMode {
  unicode,
  ascii,
  compat,
}

enum _SplitState {
  normal,
  quoteBegin,
  quoteEnd,
}

extension StringExt on String {
  // TODO: use escape implement of uri, Regexp.escape
  ///
  /// Add escape sequences (like "\n", or "\123") to the input string
  /// (first parameter).
  /// The second parameter adds characters to escape, and can be empty.
  ///
  String escape(String special, {ToStringMode mode = ToStringMode.unicode}) {
    String result = '';
    for (var c in special.codeUnits) {
      if (c < 32 || c > 126) throw ArgumentError();
    }

    for (var c in codeUnits) {
      switch (c) {
        case 92: // \
          result += '\\\\';
          break;
        case 39: // '
          result += "'";
          break;

        case 34: // "
          result += '"';
          break;

        case 7: // \a
          if (mode == ToStringMode.compat) {
            // Octal escape for compatibility with 3.6 and earlier
            result += "\\007";
          } else {
            result += "\\a";
          }
          break;

        case 8: // \b
          result += "\\b";
          break;

        case 12: // \f
          result += "\\f";
          break;

        case 10: // \n
          result += "\\n";
          break;

        case 13: // \r
          result += "\\r";
          break;

        case 9: // \t
          result += "\\t";
          break;

        case 11: // \v
          if (mode == ToStringMode.compat) {
            // Octal escape for compatibility with 3.6 and earlier
            result += "\\013";
          } else {
            result += "\\v";
          }
          break;

        default:
          if (!special.codeUnits.contains(c)) {
            result += '\\${String.fromCharCode(c)}';
          } else {
            if (c < 32 || c > 126) {
              if (mode == ToStringMode.compat) {
                // append octal string

                // Add leading zeroes so that we avoid problems during
                // decoding. For example, consider the escaped string
                // \0013 (i.e., a character with value 1 followed by the
                // character '3'). If the leading zeroes were omitted, the
                // result would be incorrectly interpreted as a single
                // character with value 11.
                //
                result += '\\${c.oct}';
              } else if (c < 32 || c == 127) {
                // append \u00nn
                result += '\\u${c.hex}';
              } else if (mode == ToStringMode.ascii) {
                // append \unnnn or \Unnnnnnnn after reading more UTF-8 bytes
                result += '\\U${c.hex}';
              } else {
                result += String.fromCharCode(c);
              }
            } else {
              result += String.fromCharCode(c);
            }
          }
          break;
      }
    }

    if (mode == ToStringMode.unicode) {
      // TODO:
    }
    return result;
  }

  /// Remove escape sequences added by escape.
  String unescape({int start = 0, int? end, required String special}) {
    end ??= length;
    return substring(start, end);
  }

  /// Find index that first char not in pattern
  /// 'abc'.indexOfNot(' ') == 0
  /// ' ab'.indexOfNot(' ') == 1
  int indexOfNot(String pattern, [int start = 0]) {
    for (var i = start; i < length; ++i) {
      if (!pattern.codeUnits.contains(codeUnitAt(i))) {
        return i;
      }
    }
    return -1;
  }

  /// safe split with quote
  /// 'a "b b" c'.split(' ') == [a, 'b b', 'c']
  List<String> splitWithQuote(String pattern) {
    final pcs = pattern.codeUnits;
    final qcs = '\'"'.codeUnits;

    final res = <String>[];
    _SplitState state = _SplitState.normal;

    final left = <int>[];

    final pushOnce = () {
      res.add(String.fromCharCodes(left));
      left.clear();
    };

    for (var i = 0; i < length; ++i) {
      int c = codeUnitAt(i);

      switch (state) {
        case _SplitState.normal:
          if (pcs.contains(c)) {
            if (left.isNotEmpty) {
              pushOnce();
            }
          } else if (qcs.contains(c)) {
            state = _SplitState.quoteBegin;
            assert(left.isEmpty);
          } else {
            left.add(c);
          }
          break;
        case _SplitState.quoteBegin:
          if (!qcs.contains(c)) {
            left.add(c);
          } else {
            state = _SplitState.quoteEnd;

            pushOnce();
          }
          break;
        case _SplitState.quoteEnd:
          state = _SplitState.normal;
          if (!pcs.contains(c)) {
            throw FormatException('quote not end with pattern');
          }
          break;
        default:
          break;
      }
    } // loop end

    if (state == _SplitState.quoteBegin) {
      throw FormatException('quote not end');
    }

    if (left.isNotEmpty) {
      res.add(String.fromCharCodes(left));
    }

    return res;
  }
}
