part of ice;

/// An administrative interface for process management. Managed servers must
/// implement this interface.

/// A servant implementing this interface is a potential target
/// for denial-of-service attacks, therefore proper security precautions
/// should be taken. For example, the servant can use a UUID to make its
/// identity harder to guess, and be registered in an object adapter with
/// a secured endpoint.
abstract class Process {
  /// Initiate a graceful shut-down.

  /// @see [Communicator.shutdown]
  void shutdown();

  /// Write a message on the process' stdout or stderr.

  /// @param message The message.

  /// @param fd 1 for stdout, 2 for stderr.
  void writeMessage(String message, int fd);
}
