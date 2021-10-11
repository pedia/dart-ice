part of ice;

class InitializationData {
  final Properties properties;
  final Logger? logger;

  InitializationData({required this.properties, this.logger});
}

void _checkIceVersion(int version) {
  // TODO:
}

///
/// Initializes a new communicator.
///
Communicator initialize({
  List<String>? args,
  InitializationData? initData,
  String? configFile,
  Properties? properties,
  int version = iceIntVersion,
}) {
  _checkIceVersion(version);

  initData ??= InitializationData(
    properties: properties ?? createProperties(args, initData?.properties),
  );

  if (configFile != null) {
    initData.properties.load(configFile);
  }

  return CommunicatorI.create(initData);
}

Properties createProperties([StringSeq? args, Properties? defaults]) {
  return PropertiesI(args ?? [], defaults);
}

class CommunicatorHolder {
  CommunicatorHolder({
    List<String>? args,
    String? configFile,
    Properties? properties,
  }) : communicator = initialize(
            args: args, configFile: configFile, properties: properties);

  final Communicator communicator;

  Properties get properties => communicator.getProperties();
}

Identity stringToIdentity(String s) {
  String name = '', category = '';

  // Find unescaped separator; note that the string may contain an escaped
  // backslash before the separator.
  int slash = -1;
  int pos = 0;
  while ((pos = s.indexOf('/', pos)) != -1) {
    int escapes = 0;

    while ((pos - escapes > 0) && s[pos - escapes - 1] == '\\') {
      escapes++;
    }

    // We ignore escaped escapes
    if (escapes.isEven) {
      if (slash == -1) {
        slash = pos;
      } else {
        throw IdentityParseException("unescaped '/' in identity `$s'");
      }
    }

    pos++;
  }

  if (slash == -1) {
    name = s.unescape(start: 0, special: '/');
  } else {
    category = s.unescape(start: 0, end: slash, special: '/');

    if (slash + 1 < s.length) {
      name = s.unescape(start: slash + 1, special: '/');
    }
  }

  return Identity(name: name, category: category);
}

///
typedef PluginFacotry = Plugin Function(
    Communicator communicator, String name, List<String> args);

void registerPluginFactory(
    String name, PluginFacotry factory, bool loadOnInit) {
  return PluginManagerI.registerPluginFactory(name, factory, loadOnInit);
}
