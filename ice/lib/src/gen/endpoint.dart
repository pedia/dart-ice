part of ice;

enum EndpointType {
  // force tcp as 1
  unknown,

  /// TCP endpoints
  tcp,

  /// SSL endpoints
  ssl,

  /// UDP endpoints
  udp,

  /// TCP-based WebSocket endpoints
  ws,

  /// SSL-based WebSocket endpoints
  wss,

  /// Bluetooth endpoints.
  bt,

  /// SSL Bluetooth endpoints.
  bts,

  /// iAP-based endpoints.
  iap,

  /// SSL iAP-based endpoints.
  iaps,
}

/// The user-level interface to an endpoint.
/// Combine EndpointInfo and Endpoint to [Endpoint]
abstract class Endpoint {
  /// Returns the type of the endpoint.
  EndpointType get type;

  /// Returns true if this endpoint is a datagram endpoint.
  bool get datagram;

  /// Returns true if this endpoint is a secure endpoint.
  bool get secure;

  /// The information of the underyling endpoint of null if there's
  /// no underlying endpoint.
  Endpoint? underlying;

  /// The timeout for the endpoint in milliseconds. 0 means
  /// non-blocking, -1 means no timeout.
  int timeout;

  bool compress;

  Endpoint({
    this.underlying,
    this.timeout = 0,
    this.compress = false,
  });
}

typedef EndpointSeq = List<Endpoint>;

abstract class IPEndpoint extends Endpoint {
  final String protocol;

  /// The host or address configured with the endpoint.
  String host;

  /// The port number.
  final int port;

  /// The source IP address.
  final String sourceAddress;

  /// Resolved address
  final List<InternetAddress> addressList;

  Future resolve() async {
    assert(addressList.isEmpty);
    assert(host.isNotEmpty);

    addressList.addAll(await InternetAddress.lookup(host));
  }

  IPEndpoint({
    required this.protocol,
    required this.host,
    required this.port,
    required this.sourceAddress,
    required this.addressList,
    Endpoint? underlying,
    int timeout = 0,
    bool compress = false,
  }) : super(
          underlying: underlying,
          timeout: timeout,
          compress: compress,
        );

  void streamWriteImpl(OutputStream out);

  //  void connectors_async(EndpointSelectionType,  EndpointI_connectorsPtr&);
  //  std::vector<EndpointIPtr> expandIfWildcard();
  //  std::vector<EndpointIPtr> expandHost(EndpointIPtr&);
  //  bool equivalent(const EndpointIPtr&);
  //  ::Ice::Int hash();
  //  std::string options();
}

/// Endpoint:
///
///   tcp -h *|{host} -p {port} -t infinite|{timeout} -z(compress) --sourceAddress {sourceAddress}
///   udp --interface {host} --ttl {} -c(connect) -z(compress)
///   ws -r {resource}
///
/// FixedReference:
///   Identity, ConnectionI
///
/// RoutableReference:
///   identity -f facet -{t|o|O|d|D} -s -p {protocolVersion} -e {EncodingVersion}:tcp -h:udp: -ttl 33
///   identity -f facet -{t|o|O|d|D} -s -p {protocolVersion} -e {EncodingVersion} @adapterId
///
