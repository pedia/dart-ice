part of ice;

class UdpConnection extends ConnectionI {
  late RawDatagramSocket socket;

  UdpConnection({
    ObjectAdapter? adapter,
    required this.socket,
    required UdpEndpoint endpoint,
  }) : super(adapter, endpoint);

  factory UdpConnection.attach(
      RawDatagramSocket socket, ObjectAdapterI adapter) {
    // socket -> Endpoint
    final ep = UdpEndpoint(
      host: '', // TODO: is this right?
      interface: '', // TODO:
      port: socket.port,
      secure: false,
      addressList: [socket.address],
    );

    return UdpConnection(
      socket: socket,
      adapter: adapter,
      endpoint: ep,
    )..init();
  }

  void init() {
    socket.listen(onData, onError: onError, onDone: onDone);

    connectionValidated.complete(true);
  }

  @override
  void close(ConnectionClose mode) {
    switch (mode) {
      case ConnectionClose.forcefully:
        socket.close();
        break;
      case ConnectionClose.gracefully:
      case ConnectionClose.gracefullyWithWait:
        sendClose();
        socket.close();
        break;
    }

    if (replyHandleMap.isNotEmpty) {
      print('warning: ResponseHandlers not empty');
    }
  }

  void heartbeat() {
    send(buildHeartbeat().finished());
  }

  void setBufferSize(int rcvSize, int sndSize) {}

  void onData(event) {
    print('udp: $event');
    switch (event) {
      case RawSocketEvent.read:
        final foo = socket.receive();
        print('udp got $foo');
        break;
      case RawSocketEvent.write:
        break;
    }
  }

  void onError(err) {
    print('udp got error: $err');
  }

  void onDone() {
    print('udp done');
  }

  @override
  void sendClose() {} // udp, server ignored close

  void send(Uint8List data) {
    socket.send(data, endpoint.addressList[0], endpoint.port);
  }

  void sendReply(Message reply) {
    try {
      send(reply.encodeReply().finished());
    } catch (err, stackTrace) {
      print('got `$err`, maybe already deactived');
    }
  }

  @override
  void sendRequest(OutputStream out, int requestId, ReplyHandle handle) {
    assert(!replyHandleMap.containsKey(requestId));
    replyHandleMap[requestId] = handle;

    final buf = out.finished();

    if (validated) {
      send(buf);
    } else {
      connectionValidated.future.then((v) {
        send(buf);
      });
    }
  }

  Message reply(Header header, Current current) => Message(
        header: header,
        identity: current.id,
        operation: current.operation,
        operationMode: current.mode,
        context: current.ctx,
        requestId: current.requestId,
        sync: true,
      );

  Object? getObject(Identity identity, String facet) {
    final fm = (adapter as ObjectAdapterI).servantMap[identity];
    if (fm != null) return fm[facet];
  }

  void handleMessage(Header header, InputStream body) {
    super.handleMessage(header, body);
    switch (header.type) {
      case MessageType.request:
        late ReplyStatus status;
        final requestId = body.readInt();
        final idstr = body.readString();
        final Identity identity = stringToIdentity(idstr);

        // For compatibility with the old FacetPath.
        final facetPath = body.readStringList();
        final facet = facetPath.isNotEmpty ? facetPath[0] : '';

        final operation = body.readString();
        final mode = body.readByte();
        final operationMode = OperationMode.values[mode];

        final context = body.readContext();
        final encap = body.readEncapsulation();

        final o = getObject(identity, facet);

        final Current current = Current(
          adapter: adapter,
          con: this,
          id: identity,
          facet: facet,
          operation: operation,
          mode: operationMode,
          ctx: context,
          requestId: requestId,
          encoding: encap.encoding,
        );
        final message = reply(header, current);

        Incoming incoming = Incoming(message, body, current);

        if (o == null) {
          status = ReplyStatus.replyObjectNotExist;
        } else {
          bool handled = o.iceDispatch(incoming, current);
          if (!handled) {
            status = ReplyStatus.replyOperationNotExist;
          }
        }

        if (incoming.reply == null) {
          incoming.createReply((output) {}, status);
        }

        sendReply(incoming.reply!);
        break;
      case MessageType.closeConnection:
        socket.close();
        break;
      default:
        break;
    }
  }

  @override
  String type() => 'tcp';
}
