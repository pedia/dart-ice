part of ice;

class _PropertyValue {
  _PropertyValue(this.value, [this.used = false]);

  final String value;
  bool used;
}

enum _ParseState {
  key,
  value,
}

class PropertiesI extends Properties {
  @override
  String getProperty(String key) {
    return getPropertyWithDefault(key, '');
  }

  @override
  String getPropertyWithDefault(String key, String value) {
    var r = _properties[key];
    if (r != null) {
      r.used = true;
      return r.value;
    }
    return value;
  }

  @override
  int getPropertyAsInt(String key) {
    return getPropertyAsIntWithDefault(key, 0);
  }

  @override
  int getPropertyAsIntWithDefault(String key, int value) {
    var r = _properties[key];
    if (r != null) {
      r.used = true;
      final parsed = int.tryParse(r.value);
      if (parsed != null) {
        return parsed;
      }
    }

    return value;
  }

  @override
  StringSeq getPropertyAsList(String key) {
    return getPropertyAsListWithDefault(key, <String>[]);
  }

  @override
  StringSeq getPropertyAsListWithDefault(String key, StringSeq value) {
    var r = _properties[key];
    if (r != null) {
      r.used = true;
      var res = r.value.split(RegExp('[ \t\r\n]'));

      return res;
    }

    return value;
  }

  @override
  PropertyDict getPropertiesForPrefix(String prefix) {
    final result = PropertyDict();
    _properties.forEach((key, value) {
      if (key.startsWith(prefix)) {
        result[key] = value.value;
        value.used = true;
      }
    });
    return result;
  }

  @override
  void setProperty(String key, String value) {
    var current_key = key.trim();

    if (current_key.isEmpty) {
      throw Exception('Attempt to set property with empty key');
    }

    // TODO: Check if the property is legal.

    // Set or clear the property.
    _properties[current_key] = _PropertyValue(value);
  }

  @override
  StringSeq getCommandLineOptions() {
    return <String>[];
  }

  @override
  StringSeq parseCommandLineOptions(String prefix, StringSeq options) {
    var pfx = prefix;
    if (pfx.isNotEmpty && pfx.endsWith('.')) {
      pfx += '.';
    }
    pfx = '--$pfx';

    var result = <String>[];
    options.forEach((opt) {
      if (opt.contains(pfx)) {
        if (!opt.contains('=')) {
          opt += '=1';
        }

        _parseLine(opt.substring(2));
      } else {
        result.add(opt);
      }
    });
    return result;
  }

  @override
  StringSeq parseIceCommandLineOptions(StringSeq options) {
    var args = options; // TODO: copy
    clPropNames.forEach((prefix) {
      args = parseCommandLineOptions(prefix, args);
    });
    return args;
  }

  @override
  void load(String file) {
    // TODO: UWP applications cannot access Windows registry.

    final lines = File(file).readAsLinesSync();
    // TODO: Skip UTF8 BOM if present.
    if (lines.isNotEmpty) {}

    lines.forEach((line) {
      _parseLine(line);
    });
  }

  @override
  Properties clone() {
    return PropertiesI._(_properties); // TODO: copy
  }

  bool iceDispatch(Incoming incoming, Current current) {
    return false;
  }

  PropertiesI._(this._properties);

  PropertiesI(StringSeq args, [Properties? defaults]) : _properties = {} {
    if (defaults != null) {
      final other = defaults as PropertiesI;
      // just copy, diff from cpp impliments;
      other._properties.forEach((key, value) {
        _properties[key] = value;
      });

      String p = getProperty('Ice.ProgramName');
      if (p.isEmpty) {
        if (args.isNotEmpty) {
          //
          // Use the first argument as the value for Ice.ProgramName. Replace
          // any backslashes in this value with forward slashes, in case this
          // value is used by the event logger.
          final name = args[0].replaceAll('\\', '/');
          _properties['Ice.ProgramName'] = _PropertyValue(name, true);
        }
      } else {
        _properties['Ice.ProgramName']!.used = true;
      }
    }

    final tmp = <String>[];

    bool loadConfigFiles = false;
    args.forEach((s) {
      if (s.startsWith('--Ice.Config')) {
        if (!s.contains('=')) {
          s += '=1';
        }
        _parseLine(s.substring(2));
        loadConfigFiles = true;
      } else {
        tmp.add(s);
      }
    });

    args = tmp;

    if (!loadConfigFiles) {
      // If Ice.Config is not set, load from ICE_CONFIG (if set)
      loadConfigFiles = !_properties.containsKey('Ice.Config');
    }

    if (loadConfigFiles) _loadConfig();

    parseIceCommandLineOptions(args);
  }

  void _parseLine(String line) {
    String key = '';
    String value = '';

    _ParseState state = _ParseState.key;

    String whitespace = '';
    String escapedspace = '';
    bool finished = false;

    for (var i = 0; i < line.length; ++i) {
      var c = line[i];
      switch (state) {
        case _ParseState.key:
          if (c == '\\') {
            if (i < line.length - 1) {
              c = line[++i];
              switch (c) {
                case '\\':
                case '#':
                case '=':
                  key += whitespace;
                  whitespace = '';
                  key += c;
                  break;
                case ' ':
                  if (key.isNotEmpty) whitespace += c;
                  break;
                default:
                  key += whitespace;
                  whitespace = '';
                  key += '\\';
                  key += c;
                  break;
              }
            } else {
              key += whitespace;
              key += c;
            }
          } else if (c == ' ' || c == '\t' || c == '\r' || c == '\n') {
            if (key.isNotEmpty) whitespace += c;
          } else if (c == '=') {
            whitespace = '';
            state = _ParseState.value;
          } else if (c == '#') {
            finished = true;
          } else {
            key += whitespace;
            whitespace = '';
            key += c;
          }
          break;
        case _ParseState.value:
          if (c == '\\') {
            if (i < line.length - 1) {
              c = line[++i];
              switch (c) {
                case '\\':
                case '#':
                case '=':
                  value += value.isEmpty ? escapedspace : whitespace;
                  whitespace = '';
                  escapedspace = '';
                  value += c;
                  break;
                case ' ':
                  whitespace += c;
                  escapedspace += c;
                  break;
                default:
                  value += value.isEmpty ? escapedspace : whitespace;
                  whitespace = '';
                  escapedspace = '';
                  value += '\\';
                  value += c;
                  break;
              }
            } else {
              value += value.isEmpty ? escapedspace : whitespace;
              value += c;
            }
          } else if (c == ' ' || c == '\t' || c == '\r' || c == '\n') {
            if (value.isNotEmpty) whitespace += c;
          } else if (c == '#') {
            finished = true;
          } else {
            value += value.isEmpty ? escapedspace : whitespace;
            whitespace = '';
            escapedspace = '';
            value += c;
          }
          break;
      }
      if (finished) break;
    }
    value += escapedspace;

    if ((state == _ParseState.key && key.isNotEmpty) ||
        (state == _ParseState.value && key.isEmpty)) {
      // "invalid config file entry: \"" + line + "\"")
    } else if (key.isEmpty) {
      return;
    }

    setProperty(key, value);
  }

  /// Ice.Config or load enviroment ICE_CONFIG
  /// muliple file support with comma
  void _loadConfig() {
    var value = getProperty('Ice.Config');
    if (value.isEmpty || value == '1') {
      value = String.fromEnvironment('ICE_CONFIG');
    }

    if (value.isNotEmpty) {
      final fs = value.split(',');
      fs.forEach((fn) => load(fn.trim()));

      _properties['Ice.Config'] = _PropertyValue(value, true);
    }
  }

  final Map<String, _PropertyValue> _properties;
}
