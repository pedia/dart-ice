part of ice.protocol;

enum SliceType { NoSlice, ValueSlice, ExceptionSlice }

/// Interface for output streams used to create a sequence of bytes from Slice types.
class OutputStream extends CodedBuffer {
  void writeHeader(Header header) {
    ByteData b = commit(header.byteLength);
    b.setInt32(0, header.magic, Endian.little);
    b.setInt8(4, header.protocol.major);
    b.setInt8(5, header.protocol.minor);
    b.setInt8(6, header.encoding.major);
    b.setInt8(7, header.encoding.minor);
    b.setInt8(8, header.type.index);
    b.setInt8(9, header.compress ? 1 : 0);
    b.setInt8(10, header.size);
  }

  void writeEncoding(EncodingVersion encodingVersion) {
    writeByte(encodingVersion.major);
    writeByte(encodingVersion.minor);
  }

  void writeProtocol(ProtocolVersion protocolVersion) {
    writeByte(protocolVersion.major);
    writeByte(protocolVersion.minor);
  }

  void writeMessageType(MessageType messageType) {
    writeByte(messageType.index);
  }

  void writeIdentity(Identity indentity) {
    writeString(indentity.name);
    writeString(indentity.category);
  }

  void writeContext(Map<String, String> context) {
    writeSize(context.length);
    context.forEach((key, value) {
      writeString(key);
      writeString(value);
    });
  }

  void writeEncapsulation(Encapsulation encap) {
    writeInt(encap.size);
    writeByte(encap.major);
    writeByte(encap.minor);
  }

  void writeFlag(SliceFlag flag) {
    writeByte(flag.value);
  }
}
