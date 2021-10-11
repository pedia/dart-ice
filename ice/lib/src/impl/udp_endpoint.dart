part of ice;

class UdpEndpoint extends IPEndpoint {
  @override
  EndpointType get type => EndpointType.udp;

  @override
  bool get datagram => true;

  @override
  final bool secure;

  final int ttl;

  final String interface;

  final bool connect;

  UdpEndpoint({
    required String host,
    required int port,
    this.ttl = 1,
    required this.interface,
    this.connect = false,
    this.secure = false,
    required List<InternetAddress> addressList,
    Endpoint? underlying,
    bool compress = false,
  }) : super(
          protocol: 'udp',
          host: host,
          port: port,
          sourceAddress: '',
          addressList: addressList,
          underlying: underlying,
          timeout: 0,
          compress: compress,
        );

  @override
  void streamWriteImpl(OutputStream out) {}

  @override
  String toString() => [
        '$protocol',
        if (host.isNotEmpty) '-h $host',
        '--interface $interface',
        if (ttl != -1) '--ttl $ttl',
        if (connect) '-c',
        if (compress) '-z',
      ].join(' ');
}
