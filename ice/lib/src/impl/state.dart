part of ice;

/// Common state
enum State {
  uninitialized,
  initialized,
  activating,
  active,
  deactivating,
  deactivated,
  destroying,
  destroyed
}
