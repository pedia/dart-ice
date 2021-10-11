part of ice;

// 暂时在 Instance 里实现
class ProxyFactory {
  ObjectPrx? stringToProxy(String str) {
    return null;
  }

  String proxyToString(ObjectPrx o) {
    return '';
  }

  ObjectPrx? propertyToProxy(String str) {
    return null;
  }

  PropertyDict proxyToProperty(ObjectPrx o, String str) {
    return PropertyDict();
  }

  // ObjectPrx streamToProxy(Ice::InputStream*) ;

  // ObjectPrx referenceToProxy( ReferencePtr) ;

  // int checkRetryAfterException( Ice::LocalException,  ReferencePtr, int) ;

  ProxyFactory(this._instance);

  final Instance _instance;
  final List<int> _retryIntervals = <int>[];
}
