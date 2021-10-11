part of ice;

class TcpConnection extends ConnectionI {
  late Socket socket;

  TcpConnection({
    ObjectAdapter? adapter,
    required this.socket,
    required IPEndpoint endpoint,
  }) : super(adapter, endpoint);

  factory TcpConnection.attach(Socket socket, ObjectAdapterI adapter) {
    // socket -> Endpoint
    final ep = TcpEndpoint(
      host: '', // TODO: is this right?
      port: socket.port,
      sourceAddress: '',
      secure: false,
      addressList: [socket.address],
    );

    return TcpConnection(
      socket: socket,
      adapter: adapter,
      endpoint: ep,
    )..init();
  }

  void init() {
    socket.listen(onData, onError: onError, onDone: onDone);

    heartbeat();
  }

  @override
  void close(ConnectionClose mode) {
    switch (mode) {
      case ConnectionClose.forcefully:
        socket.close();
        break;
      case ConnectionClose.gracefully:
        sendClose();
        socket.close();
        break;
      case ConnectionClose.gracefullyWithWait:
        sendClose();
        socket.flush().then((v) {
          socket.close();
        });
        break;
    }

    if (replyHandleMap.isNotEmpty) {
      print('warning: ResponseHandlers not empty');
    }
  }

  void heartbeat() {
    socket.add(buildHeartbeat().finished());
  }

  void setBufferSize(int rcvSize, int sndSize) {}

  Future get done => socket.done;

  void onData(data) {
    parseMessage(InputStream(
      ByteData.view(data.buffer),
      data.buffer.lengthInBytes,
    ));
  }

  void onError(err) {
    print('got error: $err');
  }

  void onDone() {
    print('done');
  }

  @override
  void sendClose() {
    socket.add(buildCloseMsg().finished());
  }

  void sendReply(Message reply) {
    try {
      socket.add(reply.encodeReply().finished());
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
      socket.add(buf);
    } else {
      connectionValidated.future.then((v) {
        socket.add(buf);
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
