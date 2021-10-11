part of ice;

enum ConnectionState {
  stateNotInitialized,
  stateNotValidated,
  stateActive,
  stateHolding,
  stateClosing,
  stateClosingPending,
  stateClosed,
  stateFinished,
}

abstract class ConnectionI extends Connection {
  ConnectionState state = ConnectionState.stateNotInitialized;
  final ObjectAdapter? adapter;
  final IPEndpoint endpoint;

  ConnectionI(this.adapter, this.endpoint);

  ObjectPrx? createProxy(Identity id) {}
  void setAdapter(ObjectAdapter adapter) => adapter = adapter;
  ObjectAdapter? getAdapter() => adapter;
  Endpoint getEndpoint() => endpoint;
  void flushBatchRequests(CompressBatch compress) {}
  void setCloseCallback(CloseCallback callback) {}
  void setHeartbeatCallback(HeartbeatCallback callback) {}

  bool validated = false;
  final connectionValidated = Completer<bool>();

  OutputStream buildHeartbeat() {
    return OutputStream()
      ..writeHeader(Header(type: MessageType.validateConnection));
  }

  OutputStream buildCloseMsg() {
    return OutputStream()..writeHeader(Header.close());
  }

  void sendRequest(OutputStream out, int requestId, ReplyHandle handle);
  void sendClose();
  void sendReply(Message reply);

  void parseMessage(InputStream input) {
    final header = Message.parseHeader(input);
    input.protocol = header.protocol;
    input.encoding = header.encoding;
    handleMessage(header, input);
  }

  // requestId -> ReplyHandle
  final replyHandleMap = <int, ReplyHandle>{};

  @mustCallSuper
  void handleMessage(Header header, InputStream body) {
    switch (header.type) {
      case MessageType.validateConnection:
        if (validated == false) {
          connectionValidated.complete(true);
          validated = true;
        }
        break;
      case MessageType.reply:
        final requestId = body.readInt();

        final b = body.readByte();
        assert(b < ReplyStatus.values.length);
        final status = ReplyStatus.values[b];

        assert(replyHandleMap.containsKey(requestId));
        replyHandleMap[requestId]!(status, body);

        replyHandleMap.remove(requestId);
        break;
      default:
        break;
    }
  }
}
