
import 's2offerwall_flutter_platform_interface.dart';

typedef EventCallback = void Function(dynamic data);

class S2Offerwall {
  static const String main = "main";
}

class S2OfferwallFlutter {

  static Map<String, EventCallback> eventHandlers = {};

  static void onLoginRequested(EventCallback callback) {
    eventHandlers["onLoginRequested"] = callback;
  }

  static void onInitCompleted(EventCallback callback) {
    eventHandlers["onInitCompleted"] = callback;
  }

  static void onPermissionRequested(EventCallback callback) {
    eventHandlers["onPermissionRequested"] = callback;
  }

  static Future<void> initSdk() {
    // 내부에서 모든 이벤트를 공통적으로 수신
    S2OfferwallFlutterPlatform.instance.events.listen((event) {
      String eventName = event["event"];
      if (eventHandlers.containsKey(eventName)) {
        eventHandlers[eventName]?.call(event["param"] ?? event["flag"]);
      }
    });

    return S2OfferwallFlutterPlatform.instance.initSdk();
  }

  static Future<void> showOfferwall(String placementName) {
    return S2OfferwallFlutterPlatform.instance.showOfferwall(placementName);
  }

  static Future<void> setUserName(String username) {
    return S2OfferwallFlutterPlatform.instance.setUserName(username);
  }

  static Future<String> getUserName() {
    return S2OfferwallFlutterPlatform.instance.getUserName();
  }

  static Future<void> resetUserName() {
    return S2OfferwallFlutterPlatform.instance.resetUserName();
  }

  static Future<void> setAppId(String appId) {
    return S2OfferwallFlutterPlatform.instance.setAppId(appId);
  }

  static Future<void> setAppIdForAndroid(String appId) {
    return S2OfferwallFlutterPlatform.instance.setAppIdForAndroid(appId);
  }

  static Future<void> setAppIdForIOS(String appId) {
    return S2OfferwallFlutterPlatform.instance.setAppIdForIOS(appId);
  }

  static Future<void> presentATTPopup() {
    return S2OfferwallFlutterPlatform.instance.presentATTPopup();
  }

  static Future<void> setConsentDialogRequired(bool required) {
    return S2OfferwallFlutterPlatform.instance.setConsentDialogRequired(required);
  }
  
  static Future<String> requestOfferwallData(String placementName, bool isEmbeded) {
    return S2OfferwallFlutterPlatform.instance.requestOfferwallData(placementName, isEmbeded);
  }

  static Future<void> openAdItem(int advId, bool needDetail, String placementFrom) {
    return S2OfferwallFlutterPlatform.instance.openAdItem(advId, needDetail, placementFrom);
  }

  static Future<void> closeTop() {
    return S2OfferwallFlutterPlatform.instance.closeTop();
  }

  static Future<void> closeAll() {
    return S2OfferwallFlutterPlatform.instance.closeAll();
  }
  
  // static Stream<String> get onLoginRequested {
  //   return S2OfferwallFlutterPlatform.instance.onLoginRequested;
  // }

  // static Stream<bool> get onInitCompleted {
  //   return S2OfferwallFlutterPlatform.instance.onInitCompleted;
  // }

  static Future<String?> getPlatformVersion() {
    return S2OfferwallFlutterPlatform.instance.getPlatformVersion();
  }
}
