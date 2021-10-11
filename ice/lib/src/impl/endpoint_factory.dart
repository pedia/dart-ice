part of ice;

class EndpointFactory {
  Endpoint? read(InputStream input) {
    final type = EndpointType.values[input.readShort()];
    Encapsulation encap = input.readEncapsulation();

    Endpoint? ep;

    switch (type) {
      case EndpointType.tcp:
        final host = input.readString();
        final port = input.readInt();
        final timeout = input.readInt();
        final compress = input.readBool();
        return TcpEndpoint(
            host: host,
            port: port,
            timeout: timeout,
            compress: compress,
            sourceAddress: '',
            addressList: []);
      case EndpointType.udp:
        final host = input.readString();
        final port = input.readInt();

        // if Encoding_1_0, ignore 4Byte
        final compress = input.readBool();
        return UdpEndpoint(
            host: host,
            port: port,
            compress: compress,
            interface: '',
            addressList: []);
      case EndpointType.ws:
      case EndpointType.wss:
      default:
        // final res = input.readString();
        // print('TODO: wss $res');

        final buf = input.readBlob(encap.size - 6);
        print('TODO: $type, $buf');
        break;
    }

    if (ep == null) {
      // TODO: OpqueEndpoint
    }
    return ep;
  }
}
