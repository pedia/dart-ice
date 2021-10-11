part of ice;

/// Determines the order in which the Ice run time uses the endpoints
/// in a proxy when establishing a connection.
enum EndpointSelectionType {
  /// [Random] causes the endpoints to be arranged in a random order.
  Random,

  /// [Ordered] forces the Ice run time to use the endpoints in the
  /// order they appeared in the proxy.
  Ordered
}
