
import 's2offerwall_flutter_platform_interface.dart';

class S2OfferwallFlutter {
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
  
  static Stream<String> get onLoginRequested {
    return S2OfferwallFlutterPlatform.instance.onLoginRequested;
  }

  static Future<String?> getPlatformVersion() {
    return S2OfferwallFlutterPlatform.instance.getPlatformVersion();
  }
}
