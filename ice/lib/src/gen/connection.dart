part of ice;

/// The batch compression option when flushing queued batch requests.
enum CompressBatch {
  /// Compress the batch requests.
  yes,

  /// Don't compress the batch requests.
  no,

  /// Compress the batch requests if at least one request was
  /// made on a compressed proxy.
  basedOnProxy
}

/// Base class providing access to the connection details.
abstract class ConnectionInfo {
  ///  The information of the underyling transport or null if there's no underlying transport.
  final ConnectionInfo? underlying;

  ///  Whether or not the connection is an incoming or outgoing connection.
  final bool incoming;

  ///  The name of the adapter associated with the connection.
  final String adapterName;

  ///  The connection id.
  final String connectionId;

  ConnectionInfo({
    this.underlying,
    required this.incoming,
    required this.adapterName,
    required this.connectionId,
  });
}

/// An application can implement this interface to receive notifications when
/// a connection closes.
abstract class CloseCallback {
  void closed(Connection con);
}

/// An application can implement this interface to receive notifications when
/// a connection receives a heartbeat message.
abstract class HeartbeatCallback {
  void heartbeat(Connection con);
}

/// Determines the behavior when manually closing a connection.
enum ConnectionClose {
  /// Close the connection immediately without sending a close connection protocol message to the peer
  /// and waiting for the peer to acknowledge it.
  ///
  forcefully,

  /// Close the connection by notifying the peer but do not wait for pending outgoing invocations to complete.
  /// On the server side, the connection will not be closed until all incoming invocations have completed.
  ///
  gracefully,

  /// Wait for all pending invocations to complete before closing the connection.
  ///
  gracefullyWithWait
}

/// The user-level interface to a connection.
abstract class Connection {
  void close(ConnectionClose mode);

  ObjectPrx? createProxy(Identity id);
  void setAdapter(ObjectAdapter adapter);
  ObjectAdapter? getAdapter();
  Endpoint getEndpoint();
  void flushBatchRequests(CompressBatch compress);
  void setCloseCallback(CloseCallback callback);
  void setHeartbeatCallback(HeartbeatCallback callback);

  void heartbeat();

  /// Return the connection type. This corresponds to the endpoint
  /// type, i.e., "tcp", "udp", etc.
  String type();

  void setBufferSize(int rcvSize, int sndSize);
}

abstract class IPConnectionInfo implements ConnectionInfo {
  /// The local address.
  String localAddress = '';

  /// The local port.
  int localPort = -1;

  /// The remote address.
  String remoteAddress = '';

  /// The remote port.
  int remotePort = -1;
}

abstract class TcpConnectionInfo implements IPConnectionInfo {
  /// The connection buffer receive size.
  int rcvSize = 0;

  /// The connection buffer send size.
  int sndSize = 0;
}
