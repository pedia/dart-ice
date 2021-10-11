part of ice;

abstract class ResponseHandler {
  void sendResponse(int, OutputStream, Byte, bool);
  void sendNoResponse();
  bool systemException(Int, SystemException, bool);
  void invokeException(Int, LocalException, int, bool);
}
