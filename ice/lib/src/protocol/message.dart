part of ice.protocol;

typedef WriteParams = void Function(OutputStream output);

void _writeEmptyParams(OutputStream output) {}

/// For build and parse request/reply message
/// Ice Protocol:
/// ```
///   magic 0-4(Int)             <--- header begin
///   ProtocolVersion, EncodingVersion
///   MessgeType, Compress
///   totalBytes
///   RequestId(Int)             <--- body begin
///   identity(String)
///   0 0 <- List<facet>
///   operation(String)
///   OperationMode(Byte)
///   Context(Map)
///   ParamsBytes + 6 = Encapsulation.size(Int)
///   1,1 (2Byte)
///   Param1                     <--- param begin
///   Param2
/// ```
class Message {
  final Identity? identity;
  final String operation;
  final OperationMode operationMode;
  final Context context;
  final Header header;
  final bool sync;
  final WriteParams writeParams;

  late int? requestId;
  late ReplyStatus? status;

  Message({
    required this.identity,
    required this.operation,
    required this.operationMode,
    required this.context,
    required this.header,
    required this.requestId,
    required this.sync,
    this.writeParams = _writeEmptyParams,
    this.status,
  });

  /// return request message
  OutputStream encodeRequest() {
    assert(header.type == MessageType.request);

    // generate body first
    final body = OutputStream();
    {
      body.writeInt(requestId!);

      body.writeString(identity.toString());
      // TODO: facet support
      body.writeSize(0); // List<facet>
      body.writeSize(0); // secure
      body.writeString(operation); // operation
      body.writeByte(operationMode.index);
      body.writeContext(context);
    }

    final bodyByteLength = body.lengthInBytes;

    // params
    final paramsStream = OutputStream();
    writeParams(paramsStream);

    final int encapByteLength = paramsStream.lengthInBytes + 6;

    final out = OutputStream();

    // prepare header
    out.writeHeader(
      header.apply(size: headerSize + bodyByteLength + encapByteLength),
    );

    // body
    out.writeBlob(body.finished());

    out.writeEncapsulation(Encapsulation(
      size: encapByteLength,
      major: 1,
      minor: 1,
    ));

    out.writeBlob(paramsStream.finished());
    return out;
  }

  /// return reply message, it is diff from request
  OutputStream encodeReply() {
    assert(header.type == MessageType.reply);

    final out = OutputStream();

    // params
    final paramsStream = OutputStream();
    writeParams(paramsStream);
    final int encapByteLength = paramsStream.lengthInBytes + 6;

    // prepare header
    // body length = 5
    out.writeHeader(
      header.apply(size: headerSize + 5 + encapByteLength),
    );

    // reply body
    out.writeInt(requestId!);
    out.writeByte(status!.index);

    out.writeEncapsulation(Encapsulation(
      size: encapByteLength,
      major: 1,
      minor: 1,
    ));

    out.writeBlob(paramsStream.finished());
    return out;
  }

  ///
  factory Message.reply(
          ReplyStatus status, WriteParams writeParams, Message request) =>
      Message(
        header: request.header.apply(type: MessageType.reply),
        identity: request.identity,
        operation: request.operation,
        operationMode: request.operationMode,
        context: request.context,
        requestId: request.requestId,
        writeParams: writeParams,
        status: status,
        sync: true,
      );

  ///
  static Header parseHeader(InputStream input) {
    assert(input.byteLength >= headerSize);
    // Treat 4-bytes magic as an Int
    final magic = input.readInt();
    if (magic != magicLittleEndian) {
      throw Exception('BadMagicException: 0x${magic.hex8}');
    }

    final pv = input.readProtocol();
    checkSupportedProtocol(pv);
    final ev = input.readEncoding();
    checkSupportedEncoding(ev);

    //
    final type = input.readMessageType();

    final compress = input.readBool();
    assert(compress == false);
    int size = input.readInt();
    if (size < headerSize) {
      throw IllegalMessageSizeException();
    }
    // if (size > messageSizeMax)

    if (size != input.byteLength) {
      // input.resize
      // read(more)
      assert(false, 'TODO: data size < message size');
    }

    return Header(
      magic: magic,
      protocol: pv,
      encoding: ev,
      type: type,
      compress: compress,
      size: size,
    );
  }
}
