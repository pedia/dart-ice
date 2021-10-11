part of ice.protocol;

/// Interface for input streams used to extract Slice types from a sequence of bytes.
class InputStream {
  final ByteData buf;
  final int byteLength;
  int offset = 0;

  ProtocolVersion? protocol;
  EncodingVersion? encoding;

  InputStream(this.buf, this.byteLength);

  int get byteLeft => byteLength - offset;

  bool readBool() {
    assert(offset + 1 <= byteLength);
    return buf.getInt8(offset++) == 1;
  }

  int readByte() {
    assert(offset + 1 <= byteLength);
    return buf.getInt8(offset++);
  }

  int readUint8() {
    assert(offset + 1 <= byteLength);
    return buf.getUint8(offset++);
  }

  int readShort() {
    assert(offset + Int16List.bytesPerElement <= byteLength);
    final res = buf.getInt16(offset, Endian.little);
    offset += Int16List.bytesPerElement;
    return res;
  }

  int readInt() {
    assert(offset + Int32List.bytesPerElement <= byteLength);
    final res = buf.getInt32(offset, Endian.little);
    offset += Int32List.bytesPerElement;
    return res;
  }

  // test only
  int readUint() {
    assert(offset + Uint32List.bytesPerElement <= byteLength);
    final res = buf.getUint32(offset, Endian.little);
    offset += Uint32List.bytesPerElement;
    return res;
  }

  int readLong() {
    assert(offset + Int64List.bytesPerElement <= byteLength);
    final res = buf.getInt64(offset, Endian.little);
    offset += Int64List.bytesPerElement;
    return res;
  }

  double readFloat() {
    assert(offset + Float32List.bytesPerElement <= byteLength);
    final res = buf.getFloat32(offset, Endian.little);
    offset += Float32List.bytesPerElement;
    return res;
  }

  double readDouble() {
    assert(offset + Float64List.bytesPerElement <= byteLength);
    final res = buf.getFloat64(offset, Endian.little);
    offset += Float64List.bytesPerElement;
    return res;
  }

  List<int> readBlob(int sz) {
    assert(offset + sz <= byteLength);

    final blob = ByteData(sz);
    blob.buffer.asInt8List(0).setRange(0, sz, buf.buffer.asInt8List(offset));
    offset += sz;
    return Uint8List.view(blob.buffer);
  }

  int readSize() {
    int b = readUint8(); // this should be Uint8
    if (b == 255) {
      final v = readInt();
      if (v < 0) {
        throw UnmarshalOutOfBoundsException();
      }
      return v;
    } else {
      return b;
    }
  }

  String readString() {
    int sz = readSize();
    return String.fromCharCodes(readBlob(sz));
  }

  List<String> readStringList() =>
      List<String>.generate(readSize(), (i) => readString());

  EncodingVersion readEncoding() {
    final major = readByte();
    final minor = readByte();
    return EncodingVersion(major, minor);
  }

  ProtocolVersion readProtocol() {
    final major = readByte();
    final minor = readByte();
    return ProtocolVersion(major, minor);
  }

  MessageType readMessageType() {
    final b = readByte();
    if (b < MessageType.values.length) {
      return MessageType.values[b];
    }
    throw Exception('Not valid MessageType value: `$b`');
  }

  Identity readIndentity() {
    return Identity(
      name: readString(),
      category: readString(),
    );
  }

  Map<String, String> readContext() => Map.fromEntries(
        List.generate(
          readSize(),
          (index) => MapEntry(readString(), readString()),
        ),
      );

  Encapsulation readEncapsulation() {
    return Encapsulation(
      size: readInt(),
      major: readByte(),
      minor: readByte(),
    );
  }

  SliceFlag readFlag() => SliceFlag(readByte());
}
