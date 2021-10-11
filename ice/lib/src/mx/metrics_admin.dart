part of ice;

class MetricsAdminI extends MetricsAdmin with Object {
  List<StringSeq> getMetricsViewNames([Current? current]) {
    return [List.from(views.keys), List.from(disabledViews)];
  }

  void enableMetricsView(String name, [Current? current]) {
    properties.setProperty("IceMX.Metrics.$name.Disabled", "0");
  }

  void disableMetricsView(String name, [Current? current]) {
    properties.setProperty("IceMX.Metrics.$name.Disabled", "1");
  }

  MetricsView getMetricsView(String view, [Current? current]) {
    final i = views[view];
    if (i == null) {
      return {};
    }

    if (disabledViews.contains(view)) {
      return {};
    }

    return i;
  }

  MetricsFailuresSeq getMapMetricsFailures(String view, String map,
      [Current? current]) {
    return [];
  }

  MetricsFailures getMetricsFailures(String view, String map, String id,
      [Current? current]) {
    return MetricsFailures(id);
  }

  bool iceDispatch(Incoming incoming, Current current) {
    return false;
  }

  final views = Map<String, MetricsView>();
  final Set<String> disabledViews = <String>{};
  final Properties properties;

  MetricsAdminI(this.properties);
}
