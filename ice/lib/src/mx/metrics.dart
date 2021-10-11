part of ice;

typedef StringIntDict = Map<String, int>;

/**
 *
 * The base class for metrics. A metrics object represents a
 * collection of measurements associated to a given a system.
 *
 **/
class Metrics {
  /**
     *
     * The metrics identifier.
     *
     **/
  final String id;

  /**
     *
     * The total number of objects that were observed by this metrics.
     *
     **/
  int total = 0;

  /**
     *
     * The current number of objects observed by this metrics.
     *
     **/
  int current = 0;

  /**
     *
     * The sum of the lifetime of each observed objects. This does not
     * include the lifetime of objects which are currently observed.
     *
     **/
  int totalLifetime = 0;

  /**
     *
     * The number of failures observed.
     *
     **/
  int failures = 0;

  Metrics(
    this.id, {
    this.total = 0,
    this.current = 0,
    this.totalLifetime = 0,
    this.failures = 0,
  });
}

/**
 *
 * A structure to keep track of failures associated with a given
 * metrics.
 *
 **/
class MetricsFailures {
  /**
     *
     * The identifier of the metrics object associated to the
     * failures.
     *
     **/
  final String id;

  /**
     *
     * The failures observed for this metrics.
     *
     **/
  StringIntDict failures;

  MetricsFailures(this.id, {this.failures = const <String, int>{}});
}

/**
 *
 * A sequence of {@link MetricsFailures}.
 *
 **/
typedef MetricsFailuresSeq = List<MetricsFailures>;

/**
 *
 * A metrics map is a sequence of metrics. We use a sequence here
 * instead of a map because the ID of the metrics is already included
 * in the Metrics class and using sequences of metrics objects is more
 * efficient than using dictionaries since lookup is not necessary.
 *
 **/
typedef MetricsMap = List<Metrics>;

/**
 *
 * A metrics view is a dictionary of metrics map. The key of the
 * dictionary is the name of the metrics map.
 *
 **/
typedef MetricsView = Map<String, MetricsMap>;

/**
 *
 * Raised if a metrics view cannot be found.
 *
 **/
class UnknownMetricsView implements Exception {}

/**
 *
 * The metrics administrative facet interface. This interface allows
 * remote administrative clients to access metrics of an application
 * that enabled the Ice administrative facility and configured some
 * metrics views.
 *
 **/

abstract class MetricsAdmin {
  /**
     *
     * Get the names of enabled and disabled metrics.
     *
     * @param disabledViews The names of the disabled views.
     *
     * @return The name of the enabled views.
     *
     **/
  List<StringSeq> getMetricsViewNames();

  /**
     *
     * Enables a metrics view.
     *
     * @param name The metrics view name.
     *
     * @throws UnknownMetricsView Raised if the metrics view cannot be
     * found.
     *
     **/
  void enableMetricsView(String name);

  /**
     *
     * Disable a metrics view.
     *
     * @param name The metrics view name.
     *
     * @throws UnknownMetricsView Raised if the metrics view cannot be
     * found.
     *
     **/
  void disableMetricsView(String name);

  /**
     *
     * Get the metrics objects for the given metrics view. This
     * returns a dictionnary of metric maps for each metrics class
     * configured with the view. The timestamp allows the client to
     * compute averages which are not dependent of the invocation
     * latency for this operation.
     *
     * @param view The name of the metrics view.
     *
     * @param timestamp The local time of the process when the metrics
     * object were retrieved.
     *
     * @return The metrics view data.
     *
     * @throws UnknownMetricsView Raised if the metrics view cannot be
     * found.
     *
     **/
  // TODO: timestamp
  MetricsView getMetricsView(String view);

  /**
     *
     * Get the metrics failures associated with the given view and map.
     *
     * @param view The name of the metrics view.
     *
     * @param map The name of the metrics map.
     *
     * @return The metrics failures associated with the map.
     *
     * @throws UnknownMetricsView Raised if the metrics view cannot be
     * found.
     *
     **/
  MetricsFailuresSeq getMapMetricsFailures(String view, String map);

  /**
     *
     * Get the metrics failure associated for the given metrics.
     *
     * @param view The name of the metrics view.
     *
     * @param map The name of the metrics map.
     *
     * @param id The ID of the metrics.
     *
     * @return The metrics failures associated with the metrics.
     *
     * @throws UnknownMetricsView Raised if the metrics view cannot be
     * found.
     *
     **/
  MetricsFailures getMetricsFailures(String view, String map, String id);
}

/**
 *
 * Provides information on the number of threads currently in use and
 * their activity.
 *
 **/
class ThreadMetrics extends Metrics {
  /**
     *
     * The number of threads which are currently performing socket
     * read or writes.
     *
     **/
  int inUseForIO = 0;

  /**
     *
     * The number of threads which are currently calling user code
     * (servant dispatch, AMI callbacks, etc).
     *
     **/
  int inUseForUser = 0;

  /**
     *
     * The number of threads which are currently performing other
     * activities. These are all other that are not counted with
     * {@link #inUseForUser} or {@link #inUseForIO}, such as DNS
     * lookups, garbage collection).
     *
     **/
  int inUseForOther = 0;

  ThreadMetrics(String id,
      {this.inUseForIO = 0, this.inUseForUser = 0, this.inUseForOther = 0})
      : super(id);
}

/**
 *
 * Provides information on servant dispatch.
 *
 **/
class DispatchMetrics extends Metrics {
  /**
     *
     * The number of dispatch that failed with a user exception.
     *
     **/
  int userException = 0;

  /**
     *
     * The size of the dispatch. This corresponds to the size of the
     * marshalled input parameters.
     *
     **/
  int size = 0;

  /**
     *
     * The size of the dispatch reply. This corresponds to the size of
     * the marshalled output and return parameters.
     *
     **/
  int replySize = 0;

  DispatchMetrics(
    String id, {
    this.userException = 0,
    this.size = 0,
    this.replySize = 0,
  }) : super(id);
}

/**
 *
 * Provides information on child invocations. A child invocation is
 * either remote (sent over an Ice connection) or collocated. An
 * invocation can have multiple child invocation if it is
 * retried. Child invocation metrics are embedded within {@link
 * InvocationMetrics}.
 *
 **/
class ChildInvocationMetrics extends Metrics {
  /**
     *
     * The size of the invocation. This corresponds to the size of the
     * marshalled input parameters.
     *
     **/
  int size = 0;

  /**
     *
     * The size of the invocation reply. This corresponds to the size
     * of the marshalled output and return parameters.
     *
     **/
  int replySize = 0;

  ChildInvocationMetrics(
    String id, {
    this.size = 0,
    this.replySize = 0,
  }) : super(id);
}

/**
 *
 * Provides information on invocations that are collocated. Collocated
 * metrics are embedded within {@link InvocationMetrics}.
 *
 **/
class CollocatedMetrics extends ChildInvocationMetrics {
  CollocatedMetrics(String id) : super(id);
}

/**
 *
 * Provides information on invocations that are specifically sent over
 * Ice connections. Remote metrics are embedded within {@link InvocationMetrics}.
 *
 **/
class RemoteMetrics extends ChildInvocationMetrics {
  RemoteMetrics(String id) : super(id);
}

/**
 *
 * Provide measurements for proxy invocations. Proxy invocations can
 * either be sent over the wire or be collocated.
 *
 **/
class InvocationMetrics extends Metrics {
  /**
     *
     * The number of retries for the invocation(s).
     *
     **/
  int retry = 0;

  /**
     *
     * The number of invocations that failed with a user exception.
     *
     **/
  int userException = 0;

  /**
     *
     * The remote invocation metrics map.
     *
     * @see RemoteMetrics
     *
     **/
  final MetricsMap remotes;

  /**
     *
     * The collocated invocation metrics map.
     *
     * @see CollocatedMetrics
     *
     **/
  final MetricsMap collocated;

  InvocationMetrics(
    String id, {
    this.retry = 0,
    this.userException = 0,
    this.remotes = const <Metrics>[],
    this.collocated = const <Metrics>[],
  }) : super(id);
}

/**
 *
 * Provides information on the data sent and received over Ice
 * connections.
 *
 **/
class ConnectionMetrics extends Metrics {
  /**
     *
     * The number of bytes received by the connection.
     *
     **/
  int receivedBytes = 0;

  /**
     *
     * The number of bytes sent by the connection.
     *
     **/
  int sentBytes = 0;

  ConnectionMetrics(String id, {this.receivedBytes = 0, this.sentBytes = 0})
      : super(id);
}
