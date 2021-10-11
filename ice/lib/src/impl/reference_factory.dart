part of ice;

class ReferenceFactory {
  final Instance instance;
  final referenceList = <Reference>[];

  ReferenceFactory(this.instance);

  Reference createFixed(Identity identity, ConnectionI connection) {
    final r = FixedReference(
        instance: instance, identity: identity, connectionI: connection);
    referenceList.add(r);
    return r;
  }

  /// RoutableReference:
  ///   identity -f facet -{t|o|O|d|D} -s -p {protocolVersion} -e {EncodingVersion}:tcp -h:udp: -ttl 33
  ///   identity -f facet -{t|o|O|d|D} -s -p {protocolVersion} -e {EncodingVersion} @adapterId
  ///
  Reference? create(String s, String propertyPrefix) {
    final r = parseReference(instance, s);
    referenceList.add(r);
    return r;
  }

  Reference? createFromStream(Identity identity, InputStream input) {
    if (identity.isEmpty) return null;

    // For compatibility with the old FacetPath.
    final facetPath = input.readStringList();
    if (facetPath.length > 1) {
      throw ProxyUnmarshalException();
    }
    final facet = facetPath.isNotEmpty ? facetPath[0] : '';

    final Mode mode = Mode.values[input.readByte()];
    bool secure = input.readBool();

    late ProtocolVersion protocol;
    late EncodingVersion encoding;

    // Weired code from ReferenceFactory.cpp:582
    // not work
    // if (input.encoding != encoding_1_0) {
    //   protocol = input.readProtocol();
    //   encoding = input.readEncoding();
    // } else {
    //   protocol = protocol_1_0;
    //   encoding = encoding_1_0;
    // }

    // Change to:
    protocol = input.readProtocol();
    encoding = input.readEncoding();
    assert(encoding == encoding_1_1);
    protocol = protocol_1_0;
    encoding = encoding_1_0;

    final endpointList = <IPEndpoint>[];
    String? adapterId;

    int sz = input.readSize();
    if (sz > 0) {
      while (sz-- != 0) {
        Endpoint? endpoint = EndpointFactory().read(input);
        if (endpoint != null) {
          endpointList.add(endpoint as IPEndpoint);
        }
      }
    } else {
      adapterId = input.readString();
    }

    final r = RoutableReference(
      instance: instance,
      mode: mode,
      secure: secure,
      identity: identity,
      context: {},
      facet: facet,
      protocol: protocol,
      encoding: encoding,
      endpointList: endpointList,
      adapterId: adapterId ?? '',
    );
    referenceList.add(r);
    return r;
  }

  void destory() {
    referenceList.forEach((i) {
      i.destory();
    });
    referenceList.clear();
  }
}
