part of ice;

class Incoming {
  final Current current;
  final InputStream stream;
  final Message request;
  Message? reply;

  Current getCurrent() => current;

  Message createReply(WriteParams writeParams,
      [ReplyStatus status = ReplyStatus.replyOK]) {
    reply = Message.reply(status, writeParams, request);
    return reply!;
  }

  Incoming(this.request, this.stream, this.current);
}
