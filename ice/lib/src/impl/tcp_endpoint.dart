part of ice;

class TcpEndpoint extends IPEndpoint {
  @override
  EndpointType get type => EndpointType.tcp;

  @override
  bool get datagram => false;

  @override
  final bool secure;

  TcpEndpoint({
    required String host,
    required int port,
    required String sourceAddress,
    this.secure = false,
    required List<InternetAddress> addressList,
    Endpoint? underlying,
    int timeout = 0,
    bool compress = false,
  }) : super(
          protocol: 'tcp',
          host: host,
          port: port,
          sourceAddress: sourceAddress,
          addressList: addressList,
          underlying: underlying,
          timeout: timeout,
          compress: compress,
        );

  @override
  void streamWriteImpl(OutputStream out) {}

  @override
  String toString() => [
        '$protocol',
        if (host.isNotEmpty) '-h $host',
        '-p $port',
        if (sourceAddress.isNotEmpty) '--sourceAddress $sourceAddress',
        if (timeout == -1) '-t infinite',
        if (timeout != -1 && timeout != 0) '-t $timeout',
        if (compress) '-z',
      ].join(' ');
}
