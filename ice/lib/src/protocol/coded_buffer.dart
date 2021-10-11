import 'dart:typed_data';

/// Access binary data in Dart way.
class CodedBuffer {
  ByteData? _data;

  int get lengthInBytes => _data?.lengthInBytes ?? 0;

  void writeByte(int v) {
    assert(v <= 255); // -128-127 or 0-255
    commit(1).setInt8(0, v);
  }

  /// Use [Int16List.bytesPerElement] better?
  void writeBool(bool v) => commit(1).setInt8(0, v ? 1 : 0);
  void writeShort(int v) => commit(2).setInt16(0, v, Endian.little);
  void writeInt(int v) => commit(4).setInt32(0, v, Endian.little);
  void writeLong(int v) => commit(8).setInt64(0, v, Endian.little);
  void writeFloat(double v) => commit(4).setFloat32(0, v, Endian.little);
  void writeDouble(double v) => commit(8).setFloat64(0, v, Endian.little);

  void writeBlob(Uint8List v) {
    if (v.isNotEmpty) {
      final b = commit(v.lengthInBytes);
      assert(b != _data);
      _copy(b, ByteData.view(v.buffer));
    }
  }

  void writeString(String v) {
    final b = Uint8List.fromList(v.codeUnits);
    writeSize(b.lengthInBytes);
    writeBlob(b);
  }

  // TODO: Is this right?
  void writeByteList(Int8List v) {
    writeSize(v.length);
    final b = commit(v.length);
    _copy(b, ByteData.view(v.buffer));
  }

  void writeBoolList(List<bool> v) {
    writeSize(v.length);
    v.forEach((i) => writeBool(i));
  }

  void writeShortList(Int16List v) {
    writeSize(v.length);
    v.forEach((i) => writeShort(i));
  }

  void writeIntList(Int32List v) {
    writeSize(v.length);
    v.forEach((i) => writeInt(i));
  }

  void writeLongList(Int64List v) {
    writeSize(v.length);
    v.forEach((i) => writeLong(i));
  }

  void writeFloatList(List<double> v) {
    writeSize(v.length);
    v.forEach((i) => writeFloat(i));
  }

  void writeDoubleList(List<double> v) {
    writeSize(v.length);
    v.forEach((i) => writeDouble(i));
  }

  void writeStringList(List<String> v) {
    writeSize(v.length);
    v.forEach((i) => writeString(i));
  }

  /// Writes a size value.
  /// [v] A non-negative integer.
  void writeSize(int v) {
    assert(v >= 0);
    if (v > 254) {
      writeByte(255);
      writeInt(v);
    } else {
      writeByte(v);
    }
  }

  /// Enhance memory, return added part.
  ByteData commit(int size) {
    assert(size > 0);

    // Create new memory and copy old data into it
    final nd = ByteData(lengthInBytes + size);
    if (_data != null) {
      _copy(nd, _data!);
    }

    // Return added memory
    final res = nd.buffer.asByteData(lengthInBytes);

    // Set
    _data = nd;

    assert(res.lengthInBytes == size);
    return res;
  }

  static void _copy(ByteData dst, ByteData src) {
    assert(dst.lengthInBytes >= src.lengthInBytes);
    // for (var i = 0; i < src.lengthInBytes; i++) {
    //   dst.setUint8(i, src.getUint8(i));
    // }
    dst.buffer
        .asInt8List(dst.offsetInBytes)
        .setRange(0, src.lengthInBytes, src.buffer.asInt8List());
  }

  Uint8List finished() {
    if (_data == null) {
      return Uint8List(0);
    }
    return _data!.buffer.asUint8List();
  }
}
