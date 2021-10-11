part of ice;

/// Information about the current method invocation for servers. Each
/// operation on the server has a <code>Current</code> as its implicit final
/// parameter. <code>Current</code> is mostly used for Ice services. Most
/// applications ignore this parameter.
class Current {
  /// The object adapter.
  final ObjectAdapter? adapter;

  /// Information about the connection over which the current method
  /// invocation was received. If the invocation is direct due to
  /// collocation optimization, this value is set to null.
  final Connection con;

  /// The Ice object identity.
  final Identity id;

  /// The facet.
  final String facet;

  /// The operation name.
  final String operation;

  /// The mode of the operation.
  final OperationMode mode;

  /// The request context, as received from the client.
  final Context ctx;

  /// The request id unless oneway (0).
  final int requestId;

  /// The encoding version used to encode the input and output parameters.
  final EncodingVersion encoding;

  Current({
    required this.adapter,
    required this.con,
    required this.id,
    required this.facet,
    required this.operation,
    required this.mode,
    required this.ctx,
    required this.requestId,
    required this.encoding,
  });
}
