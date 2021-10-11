part of ice.protocol;

/// A version structure for the protocol version.
class ProtocolVersion {
  final int major;
  final int minor;
  const ProtocolVersion(this.major, this.minor);

  @override
  bool operator ==(Object? other) {
    return other is ProtocolVersion &&
        major == other.major &&
        minor == other.minor;
  }
}

/// A version structure for the encoding version.
class EncodingVersion {
  final int major;
  final int minor;
  const EncodingVersion(this.major, this.minor);

  @override
  bool operator ==(Object? other) {
    return other is EncodingVersion &&
        major == other.major &&
        minor == other.minor;
  }
}
