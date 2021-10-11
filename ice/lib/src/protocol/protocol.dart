part of ice.protocol;

///
/// Size of the Ice protocol header
///
/// Magic number (4 bytes)
/// Protocol version major (Byte)
/// Protocol version minor (Byte)
/// Encoding version major (Byte)
/// Encoding version minor (Byte)
/// Message type (Byte)
/// Compression status (Byte)
/// Message size (Int)
///
const int headerSize = 14;

///
/// The magic number at the front of each message
///
/// 'I', 'c', 'e', 'P'
final Uint8List magic = Uint8List.fromList([0x49, 0x63, 0x65, 0x50]);

/// Speed up read and write magic.
const int magicLittleEndian = 0x50656349;

///
/// The Ice protocol message types
///
enum MessageType {
  request, // = 0;
  requestBatch, // = 1;
  reply, // = 2;
  validateConnection, // = 3;
  closeConnection, // = 4;
}

//
// IPv4/IPv6 support enumeration.
//
enum ProtocolSupport {
  enableIPv4,
  enableIPv6,
  enableBoth,
}

const ProtocolVersion protocol_1_0 = ProtocolVersion(1, 0);

const EncodingVersion encoding_1_0 = EncodingVersion(1, 0);
const EncodingVersion encoding_1_1 = EncodingVersion(1, 1);

/// Identifies the latest protocol version
const ProtocolVersion currentProtocol = ProtocolVersion(1, 0);

/// Identifies the latest protocol encoding version
const EncodingVersion currentProtocolEncoding = EncodingVersion(1, 0);

/// Identifies the latest protocol encoding version.
const EncodingVersion currentEncoding = EncodingVersion(1, 1);

List<int> stringToMajorMinor(String s) {
  int pos = s.indexOf('.');
  if (pos == -1) {
    throw VersionParseException("malformed version value `$s'");
  }

  late int major, minor;

  try {
    major = int.tryParse(s.substring(0, pos))!;
  } catch (e) {
    throw VersionParseException("invalid major version value `$s'");
  }

  try {
    minor = int.tryParse(s.substring(pos + 1))!;
  } catch (e) {
    throw VersionParseException("invalid minor version value `$s'");
  }

  if (major < 1 || major > 255 || minor < 0 || minor > 255) {
    throw VersionParseException("range error in version `$s'");
  }

  return [major, minor];
}

ProtocolVersion stringToProtocolVersion(String s) {
  final pair = stringToMajorMinor(s);
  return ProtocolVersion(pair[0], pair[1]);
}

EncodingVersion stringToEncodingVersion(String s) {
  final pair = stringToMajorMinor(s);
  return EncodingVersion(pair[0], pair[1]);
}

void checkSupportedProtocol(ProtocolVersion pv) {}
void checkSupportedEncoding(EncodingVersion pv) {}

/// Helper class, used to extract/puut header from/to a sequence of bytes.
class Header {
  final int magic; // littel endian
  final ProtocolVersion protocol;
  final EncodingVersion encoding;
  final MessageType type;
  final bool compress;
  final int size;

  int get byteLength => headerSize;

  const Header({
    this.magic = magicLittleEndian,
    this.protocol = currentProtocol,
    this.encoding = currentProtocolEncoding,
    this.type = MessageType.request,
    this.compress = false,
    this.size = headerSize,
  });

  factory Header.close() => Header(
        type: MessageType.closeConnection,
        compress: true, // only true worked!!!
      );

  Header apply({
    int? magic,
    ProtocolVersion? protocol,
    EncodingVersion? encoding,
    MessageType? type,
    bool? compress,
    int? size,
  }) =>
      Header(
        magic: magic ?? this.magic,
        protocol: protocol ?? this.protocol,
        encoding: encoding ?? this.encoding,
        type: type ?? this.type,
        compress: compress ?? this.compress,
        size: size ?? this.size,
      );
}

/// All the data in an encapsulation is context-free, that is, nothing inside
/// an encapsulation can refer to anything outside the encapsulation.
/// This feature allows encapsulations to be forwarded among address
/// spaces as a blob of data.
class Encapsulation {
  final int size;
  final int major;
  final int minor;

  const Encapsulation({
    required this.size,
    required this.major,
    required this.minor,
  });

  EncodingVersion get encoding => EncodingVersion(major, minor);
}

enum ReplyStatus {
  replyOK,
  replyUserException, // 1
  replyObjectNotExist, // 2
  replyFacetNotExist, // 3
  replyOperationNotExist, // 4
  replyUnknownLocalException, // 5
  replyUnknownUserException, // 6
  replyUnknownException, // 7
}

class ReplyData {
  final int requestId;
  final ReplyStatus status; // Byte
  final Encapsulation body; // messageSize - 19 bytes

  ReplyData({
    required this.requestId,
    required this.status,
    required this.body,
  });
}

/// A request context. <code>Context</code> is used to transmit metadata about a
/// request from the server to the client, such as Quality-of-Service
/// (QoS) parameters. Each operation on the client has a <code>Context</code> as
/// its implicit final parameter.
typedef Context = Map<String, String>;

/// Determines the retry behavior an invocation in case of a (potentially) recoverable error.

//
// Note: The order of definitions here *must* match the order of
// definitions for ::Slice::Operation::Mode in include/Slice/Parser.h!
//
enum OperationMode {
  /// Ordinary operations have <code>Normal</code> mode.  These operations
  /// modify object state; invoking such an operation twice in a row
  /// has different semantics than invoking it once. The Ice run time
  /// guarantees that it will not violate at-most-once semantics for
  /// <code>Normal</code> operations.
  normal,

  /// Operations that use the Slice <code>nonmutating</code> keyword must not
  /// modify object state. For C++, nonmutating operations generate
  /// <code>const</code> member functions in the skeleton. In addition, the Ice
  /// run time will attempt to transparently recover from certain
  /// run-time errors by re-issuing a failed request and propagate
  /// the failure to the application only if the second attempt
  /// fails.
  ///
  /// <p class="Deprecated"><code>Nonmutating</code> is deprecated; Use the
  /// <code>idempotent</code> keyword instead. For C++, to retain the mapping
  /// of <code>nonmutating</code> operations to C++ <code>const</code>
  /// member functions, use the <code>\["cpp:const"]</code> metadata
  /// directive.
  nonmutating,

  /// Operations that use the Slice <code>idempotent</code> keyword can modify
  /// object state, but invoking an operation twice in a row must
  /// result in the same object state as invoking it once.  For
  /// example, <code>x = 1</code> is an idempotent statement,
  /// whereas <code>x += 1</code> is not. For idempotent
  /// operations, the Ice run-time uses the same retry behavior
  /// as for nonmutating operations in case of a potentially
  /// recoverable error.
  idempotent,
}

/// Slice Class Encoding 1.1
///
/// Flags, write in Byte, support partly
///
const int flagHasTypeIdString = 1 << 0; // 0x01
const int flagHasTypeIdIndex = 1 << 1; // 0x02
const int flagHasOptionalMember = 1 << 2; // 0x04
const int flagHasSize = 1 << 4; // 0x10
const int flagIsLast = 1 << 5; // 0x20

class SliceFlag {
  static const int mask = 0xff;

  int value = 0;

  SliceFlag(this.value) : assert(value < mask);

  void set(int flag) => value |= (flag & mask);
  void unset(int flag) => value &= ~flag;

  bool get hasTypeIdString =>
      value & flagHasTypeIdString == flagHasTypeIdString;
  bool get hasTypeIdIndex => value & flagHasTypeIdIndex == flagHasTypeIdIndex;
  bool get hasOptionalMember =>
      value & flagHasOptionalMember == flagHasOptionalMember;
  bool get hasSize => value & flagHasSize == flagHasSize;
  bool get isLast => value & flagIsLast == flagIsLast;
}
