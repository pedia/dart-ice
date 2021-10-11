part of ice;

enum Mode {
  modeTwoway,
  modeOneway,
  modeBatchOneway,
  modeDatagram,
  modeBatchDatagram,
}

abstract class Reference {
  final Instance instance;

  final Identity identity;
  final Context context; // SharedContext
  final String facet;
  final Mode mode;
  final bool secure;
  final ProtocolVersion protocol;
  final EncodingVersion encoding;
  final int invocationTimeout;
  bool overrideCompress;
  bool compress; // TODO:

  ConnectionI? currentConnection; // for FixedReference
  // ?
  int connectionId = 0;
  final connectionList = <Connection>[];

  int _requestId = 0;
  int get nextRequestId => ++_requestId;

  Reference({
    required this.instance,
    required this.identity,
    required this.context,
    required this.facet,
    required this.mode,
    required this.secure,
    required this.protocol,
    required this.encoding,
    required this.invocationTimeout,
    this.overrideCompress = false,
    this.compress = false,
  });

  Reference apply({
    Identity? identity,
    Context? context,
    String? facet,
    Mode? mode,
  });

  @override
  String toString() {
    return '';
  }

  Future<ConnectionI> createConnection([int connectionId = 0]);

  void onConnectionClosed(int connectionId, Connection connection) {
    print('got connection $connectionId closed');
  }

  void destory() {
    currentConnection?.close(ConnectionClose.gracefullyWithWait);
    currentConnection = null;
  }
}

class FixedReference extends Reference {
  final ConnectionI connectionI;
  FixedReference({
    required Instance instance,
    required Identity identity,
    required this.connectionI,
    Context context = const {},
    String facet = '',
    Mode mode = Mode.modeTwoway,
    bool secure: false,
    ProtocolVersion protocol = currentProtocol,
    EncodingVersion encoding = currentProtocolEncoding,
    int invocationTimeout = -1,
  }) : super(
          instance: instance,
          identity: identity,
          context: context,
          facet: facet,
          mode: mode,
          secure: secure, // connectionI.secure,
          protocol: protocol,
          encoding: encoding,
          invocationTimeout: invocationTimeout,
        );

  Reference apply({
    Identity? identity,
    Context? context,
    String? facet,
    Mode? mode,
  }) {
    final r = FixedReference(
      instance: instance,
      identity: identity ?? this.identity,
      connectionI: this.connectionI,
      context: context ?? this.context,
      facet: facet ?? this.facet,
      mode: mode ?? this.mode,
      secure: secure,
      protocol: protocol,
      encoding: encoding,
      invocationTimeout: invocationTimeout,
    );
    instance.referenceFactory.referenceList.add(r); // TODO: better
    return r;
  }

  Future<ConnectionI> createConnection([int connectionId = 0]) {
    throw Exception('NotImplement');
  }
}

//
class RoutableReference extends Reference {
  // Empty if indirect proxy.
  final List<IPEndpoint> endpointList;
  final List<Endpoint> proxy;
  final String adapterId;

  // TODO: LocatorInfo, RouterInfo

  RoutableReference({
    required Instance instance,
    required Mode mode,
    required bool secure,
    required Identity identity,
    required Context context,
    required String facet,
    required ProtocolVersion protocol,
    required EncodingVersion encoding,
    this.endpointList = const <IPEndpoint>[],
    int invocationTimeout = -1,
    bool compress = false,
    required this.adapterId,
    this.proxy = const [],
  }) : super(
          instance: instance,
          identity: identity,
          context: context,
          facet: facet,
          mode: mode,
          secure: secure,
          protocol: protocol,
          encoding: encoding,
          invocationTimeout: invocationTimeout,
          compress: compress,
        );

  RoutableReference apply({
    Identity? identity,
    Context? context,
    String? facet,
    Mode? mode,
  }) {
    final r = RoutableReference(
      instance: instance,
      identity: identity ?? this.identity,
      context: context ?? this.context,
      facet: facet ?? this.facet,
      mode: mode ?? this.mode,
      secure: secure,
      protocol: protocol,
      encoding: encoding,
      endpointList: this.endpointList,
      invocationTimeout: invocationTimeout,
      adapterId: this.adapterId,
    );
    instance.referenceFactory.referenceList.add(r); // TODO: better
    return r;
  }

  int findEndpoint() {
    for (int i = 0; i < endpointList.length; ++i) {
      final ep = endpointList[i];
      if (!secure) {
        if ((mode == Mode.modeTwoway ||
                mode == Mode.modeOneway ||
                mode == Mode.modeBatchOneway) &&
            !ep.datagram) {
          return i;
        } else if ((mode == Mode.modeDatagram ||
                mode == Mode.modeBatchDatagram) &&
            ep.datagram) {
          return i;
        }
      } else {
        // ssl
        if (ep.secure && ep.protocol == 'tcp') return i;
      }
    }
    return -1;
  }

  Future<ConnectionI> createConnection([int connectionId = 0]) async {
    if (currentConnection == null) {
      int i = findEndpoint();
      IPEndpoint ep = endpointList[i];
      if (ep.protocol == 'tcp')
        currentConnection = await createTcpConnect(ep);
      else if (ep.protocol == 'udp') {
        currentConnection = await createUdpConnect(ep as UdpEndpoint);
      }
    }

    return Future.value(currentConnection);
  }
}

/// Connect to the Endpoint
Future<ConnectionI> createTcpConnect(IPEndpoint endpoint) async {
  final c = Completer<ConnectionI>();
  //
  void Function(IPEndpoint) doConnect = (endpoint) {
    Socket.connect(endpoint.addressList[0], endpoint.port).then((socket) {
      final tc = TcpConnection(endpoint: endpoint, socket: socket)..init();
      c.complete(tc);
    });
  };

  if (endpoint.addressList.isEmpty) {
    endpoint.resolve().then((x) {
      doConnect(endpoint);
    });
  } else {
    doConnect(endpoint);
  }

  return c.future;
}

Future<ConnectionI> createUdpConnect(UdpEndpoint endpoint) async {
  final c = Completer<ConnectionI>();
  //
  void Function(UdpEndpoint) doConnect = (endpoint) {
    RawDatagramSocket.bind(endpoint.addressList[0], 0, ttl: endpoint.ttl)
        .then((socket) {
      final uc = UdpConnection(endpoint: endpoint, socket: socket)..init();
      c.complete(uc);
    });
  };

  if (endpoint.addressList.isEmpty) {
    endpoint.resolve().then((x) {
      doConnect(endpoint);
    });
  } else {
    doConnect(endpoint);
  }

  return c.future;
}

///   tcp -h *|{host} -p {port} -t infinite|{timeout} -z(compress) --sourceAddress {sourceAddress}
///   udp --interface {host} --ttl {} -c(connect) -z(compress)
///   ws -r {resource}
///
ArgParser endpointParser() => ArgParser()
      ..addOption('host', abbr: 'h')
      ..addOption('port', abbr: 'p')
      ..addOption('timeout', abbr: 't')
      ..addOption('sourceAddress')
      ..addOption('ttl')
      ..addOption('connect', abbr: 'c')
      ..addOption('interface', abbr: 'i')
      ..addOption('resource', abbr: 'r')
      ..addFlag('compress', abbr: 'z') //, defaultsTo: false);
    ;

ArgParser preferenceParser() => ArgParser()
      ..addOption('facet', abbr: 'f')
      ..addOption('protocol', abbr: 'p')
      ..addOption('encoding', abbr: 'e')
      ..addFlag('secure', abbr: 's') // , defaultsTo: false)
      ..addFlag('twoway', abbr: 't') // , defaultsTo: true)
      ..addFlag('oneway', abbr: 'o') // , defaultsTo: false)
      ..addFlag('batchOneway', abbr: 'O') // , defaultsTo: false)
      ..addFlag('datagram', abbr: 'd') // , defaultsTo: false)
      ..addFlag('batchDatagram', abbr: 'D') // , defaultsTo: false)
    ;

IPEndpoint? parseEndpoint(Instance instance, String s) {
  var e = endpointParser().parse(s.split(' '));

  if (e.arguments.first == 'tcp') {
    final host = e['host'] ?? instance.defaultHost;
    return TcpEndpoint(
      host: host,
      port: int.parse(e['port']),
      secure: false,
      compress: e['compress'] ?? false,
      timeout: e['timeout'] == 'infinite'
          ? -1
          : e['timeout'] != null
              ? int.parse(e['timeout'])
              : 0,
      sourceAddress: e['sourceAddress'] ?? '',
      addressList: host == '*' || host.isEmpty ? [InternetAddress.anyIPv4] : [],
    );
  } else if (e.arguments.first == 'udp') {
    final host = e['host'] ?? instance.defaultHost;
    return UdpEndpoint(
      host: host,
      port: int.parse(e['port']),
      ttl: e['ttl'] ?? 1,
      interface: e['interface'] ?? '',
      connect: e['connect'] ?? false,
      secure: false,
      compress: e['compress'] ?? false,
      addressList: host == '*' || host.isEmpty ? [InternetAddress.anyIPv4] : [],
    );
  }
}

/// RoutableReference:
///   identity -f facet -{t|o|O|d|D} -s -p {protocolVersion} -e {EncodingVersion}:tcp -h:udp: -ttl 33
///   identity -f facet -{t|o|O|d|D} -s -p {protocolVersion} -e {EncodingVersion} @adapterId
///
RoutableReference parseReference(Instance instance, String s) {
  Mode Function(ArgResults) flagsToMode = (results) => results['oneway']
      ? Mode.modeOneway
      : results['batchOneway']
          ? Mode.modeBatchOneway
          : results['datagram']
              ? Mode.modeDatagram
              : Mode.modeTwoway;

  final arr = s.split(':');
  if (arr.isNotEmpty) {
    final results = preferenceParser().parse(arr[0].split(' '));

    final eps = <IPEndpoint>[];

    arr.skip(1).forEach((s) {
      final ep = parseEndpoint(instance, s);
      if (ep != null) {
        eps.add(ep);
      }
    });

    final identity = stringToIdentity(results.arguments.first);

    final mode = flagsToMode(results);

    return RoutableReference(
        instance: instance,
        mode: mode,
        secure: false,
        identity: identity,
        context: {},
        facet: results['facet'] ?? '',
        protocol: currentProtocol, // TODO:
        encoding: currentProtocolEncoding,
        endpointList: eps,
        adapterId: '');
  } else {
    final results = preferenceParser().parse(arr);

    final identity = stringToIdentity(results.arguments.first);
    final mode = flagsToMode(results);
    // TODO: check
    final adapterId = results.arguments.last;

    return RoutableReference(
      instance: instance,
      mode: mode,
      secure: false,
      identity: identity,
      context: {},
      facet: results['facet'],
      protocol: currentProtocol, // TODO:
      encoding: currentProtocolEncoding,
      adapterId: adapterId,
    );
  }
}
