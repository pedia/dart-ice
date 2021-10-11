part of ice;

/// Help create Request, send it and handle Response.
class Outgoing {
  final MessageType messageType;

  final ObjectPrx prx;
  final String operation;
  final OperationMode mode;
  final Context? context;
  final WriteParams writeParams;

  final bool sync;

  Outgoing(
    this.prx,
    this.operation,
    this.mode,
    this.context,
    this.writeParams, {
    this.messageType = MessageType.request,
    this.sync = true,
  });

  void invoke() {
    final c = waitFor<ConnectionI>(prx.reference.createConnection());
    _sendOnce(c);
  }

  Future<void> invokeAsync() async {
    final c = await prx.reference.createConnection();
    _sendOnce(c);
  }

  void _sendOnce(ConnectionI c) {
    final requestId = prx.reference.nextRequestId;
    final request = prx.request(operation, requestId, context, writeParams,
        mode: mode, sync: sync);

    c.sendRequest(request.encodeRequest(), requestId, complete);
  }

  late ReplyStatus status;
  late InputStream body;
  final completer = Completer<ReplyStatus>();

  void complete(ReplyStatus status, InputStream inputStream) {
    this.status = status;
    this.body = inputStream;
    completer.complete(status);
  }

  dynamic handleReply([ReplyHandle? handle]) {
    waitFor<ReplyStatus>(completer.future);

    switch (status) {
      case ReplyStatus.replyOK:
        final encap = body.readEncapsulation();
        assert(encap.size - 6 == body.byteLeft);
        break;

      case ReplyStatus.replyObjectNotExist:
      case ReplyStatus.replyFacetNotExist:
      case ReplyStatus.replyOperationNotExist:
        final Identity identity = body.readIndentity();

        // For compatibility with the old FacetPath.
        final facetPath = body.readStringList();
        final facet = facetPath.isNotEmpty ? facetPath[0] : '';

        final operation = body.readString();
        throw _requstFail(status, identity, facet, operation);

      case ReplyStatus.replyUnknownException:
      case ReplyStatus.replyUnknownUserException:
      case ReplyStatus.replyUnknownLocalException:
      case ReplyStatus.replyUserException:
        final String detail = body.readString();
        throw _unknownFail(status, detail);
    }

    dynamic res = handle?.call(status, body);

    if (body.byteLeft != 0)
      print('warning: Response left ${body.byteLeft} not read');

    return res;
  }
}

///
typedef ReplyHandle = dynamic Function(ReplyStatus status, InputStream input);

_requstFail(
    ReplyStatus status, Identity identity, String facet, String operation) {
  if (status == ReplyStatus.replyObjectNotExist) {
    return ObjectNotExistException(identity, facet, operation);
  } else if (status == ReplyStatus.replyFacetNotExist) {
    return FacetNotExistException(identity, facet, operation);
  } else if (status == ReplyStatus.replyOperationNotExist) {
    return OperationNotExistException(identity, facet, operation);
  }
}

_unknownFail(ReplyStatus status, String detail) {
  if (status == ReplyStatus.replyUnknownException) {
    return UnknownException(detail);
  }
  if (status == ReplyStatus.replyUnknownUserException) {
    return UnknownUserException(detail);
  }
  if (status == ReplyStatus.replyUnknownLocalException) {
    return UnknownLocalException(detail);
  }
  if (status == ReplyStatus.replyUserException) {
    return UnknownUserException(detail);
  }
}
