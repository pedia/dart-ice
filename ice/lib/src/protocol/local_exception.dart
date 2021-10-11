part of ice.protocol;

class _IceException implements Exception {
  @override
  String toString() => '::Ice::${runtimeType}';
}

class _IceDetailException extends _IceException {
  final String detail;
  _IceDetailException(this.detail);
  @override
  String toString() => '::Ice::${runtimeType}\n  $detail';
}

class InitializationException extends _IceException {}

class PluginInitializationException extends _IceException {}

class CollocationOptimizationException extends _IceException {}

class AlreadyRegisteredException extends _IceException {}

class NotRegisteredException extends _IceException {}

class TwowayOnlyException extends _IceException {}

class CloneNotImplementedException extends _IceException {}

class UnknownException extends _IceDetailException {
  UnknownException(String detail) : super(detail);
}

class UnknownLocalException extends _IceDetailException {
  UnknownLocalException(String detail) : super(detail);
}

class UnknownUserException extends _IceDetailException {
  UnknownUserException(String detail) : super(detail);
}

class VersionMismatchException extends _IceException {}

class CommunicatorDestroyedException extends _IceException {}

class ObjectAdapterDeactivatedException extends _IceException {}

class ObjectAdapterIdInUseException extends _IceException {}

class NoEndpointException extends _IceException {}

class EndpointParseException extends _IceDetailException {
  EndpointParseException([String detail = '']) : super(detail);
}

class EndpointSelectionTypeParseException extends _IceException {}

class VersionParseException extends _IceDetailException {
  VersionParseException([String detail = '']) : super(detail);
}

class IdentityParseException extends _IceDetailException {
  IdentityParseException([String detail = '']) : super(detail);
}

class ProxyParseException extends _IceDetailException {
  ProxyParseException([String detail = '']) : super(detail);
}

class IllegalIdentityException extends _IceDetailException {
  IllegalIdentityException([String detail = '']) : super(detail);
}

class IllegalServantException extends _IceException {}

// src/Ice/OutgoingAsync.cpp:1019: ::Ice::OperationNotExistException:
// operation does not exist:
// identity: `hello'
// facet:
// operation: `sth. wrong'
class RequestFailedException implements Exception {
  final Identity identity;
  final String facet;
  final String operation;
  RequestFailedException(this.identity, this.facet, this.operation);
  @override
  String toString() {
    return '::Ice::${runtimeType}\n'
        '  operation does not exist:\n'
        '  identity: `$identity\'\n'
        '  facet: $facet\n'
        '  operation: `$operation\'';
  }
}

class ObjectNotExistException extends RequestFailedException {
  ObjectNotExistException(Identity identity, String facet, String operation)
      : super(identity, facet, operation);
}

class FacetNotExistException extends RequestFailedException {
  FacetNotExistException(Identity identity, String facet, String operation)
      : super(identity, facet, operation);
}

class OperationNotExistException extends RequestFailedException {
  OperationNotExistException(Identity identity, String facet, String operation)
      : super(identity, facet, operation);
}

class SyscallException extends _IceException {}

class SocketException extends _IceException {}

class CFNetworkException extends _IceException {}

class FileException extends _IceException {}

class ConnectFailedException extends _IceException {}

class ConnectionRefusedException extends _IceException {}

class ConnectionLostException extends _IceException {}

class DNSException extends _IceException {}

class OperationInterruptedException extends _IceException {}

class TimeoutException extends _IceException {}

class ConnectTimeoutException extends _IceException {}

class CloseTimeoutException extends _IceException {}

class ConnectionTimeoutException extends _IceException {}

class InvocationTimeoutException extends _IceException {}

class InvocationCanceledException extends _IceException {}

class ProtocolException extends _IceException {}

class BadMagicException extends _IceException {}

class UnsupportedProtocolException extends _IceException {}

class UnsupportedEncodingException extends _IceException {}

class UnknownMessageException extends _IceException {}

class ConnectionNotValidatedException extends _IceException {}

class UnknownRequestIdException extends _IceException {}

class UnknownReplyStatusException extends _IceException {}

class CloseConnectionException extends _IceException {}

class ConnectionManuallyClosedException extends _IceException {}

class IllegalMessageSizeException extends _IceException {}

class CompressionException extends _IceException {}

class DatagramLimitException extends _IceException {}

class MarshalException extends _IceException {}

class ProxyUnmarshalException extends _IceException {}

class UnmarshalOutOfBoundsException extends _IceException {}

class NoValueFactoryException extends _IceException {}

class UnexpectedObjectException extends _IceException {}

class MemoryLimitException extends _IceException {}

class StringConversionException extends _IceException {}

class EncapsulationException extends _IceException {}

class FeatureNotSupportedException extends _IceException {}

class SecurityException extends _IceException {}

class FixedProxyException extends _IceException {}

class ResponseSentException extends _IceException {}
