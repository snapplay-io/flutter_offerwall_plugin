
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 's2offerwall_flutter_platform_interface.dart';

/// An implementation of [S2OfferwallFlutterPlatform] that uses method channels.
class MethodChannelS2OfferwallFlutter extends S2OfferwallFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('s2offerwall_flutter');

  @visibleForTesting
  final EventChannel eventChannel = EventChannel('s2offerwall_flutter/events');

  // // 내부에서 모든 이벤트를 공통적으로 수신
  // Stream<Map<String, dynamic>> get events {
  //     return eventChannel.receiveBroadcastStream().map((event) {
  //       return Map<String, dynamic>.from(event);
  //     });
  // }

  @override
  Future<void> initSdk() async {
    await methodChannel.invokeMethod('initSdk');
  }

  @override
  Future<void> showOfferwall(String placementName) async {
    await methodChannel.invokeMethod('showOfferwall', {"placementName": placementName});
  }

  @override
  Future<void> presentATTPopup() async {
    await methodChannel.invokeMethod('presentATTPopup');
  }

  @override
  Future<void> setConsentDialogRequired(bool required) async {
    await methodChannel.invokeMethod('setConsentDialogRequired', {"required": required});
  }
  
  @override
  Future<void> setUserName(String username, [String displayName = ""]) async {
    await methodChannel.invokeMethod('setUserName', {"userName": username, "displayName": displayName});
  }

  @override
  Future<String> getUserName() async {
    final userName = await methodChannel.invokeMethod<String>('getUserName');
    return userName ?? "";
  }

  @override
  Future<void> resetUserName() async {
    await methodChannel.invokeMethod('resetUserName');
  }

  @override
  Future<void> setAppId(String appId) async {
    await methodChannel.invokeMethod('setAppId', {"appId": appId});
  }

  @override
  Future<void> setAppIdForAndroid(String appId) async {
    await methodChannel.invokeMethod('setAppIdForAndroid', {"appId": appId});
  }

  @override
  Future<void> setAppIdForIOS(String appId) async {
    await methodChannel.invokeMethod('setAppIdForIOS', {"appId": appId});
  }

  @override
  Future<String> requestOfferwallData(String placementName, bool isEmbeded) async {
    final result = await methodChannel.invokeMethod<String>('requestOfferwallData',
                                  {'placementName': placementName,'isEmbeded': isEmbeded});
    return result ?? '';
  }

  @override
  Future<void> openAdItem(int advId, bool needDetail, String placementFrom) async {
    await methodChannel.invokeMethod('openAdItem', {
                                          'advId': advId,
                                          'needDetail': needDetail,
                                          'placementFrom': placementFrom
                                        });
  }

  @override
  Future<void> closeTop() async {
    await methodChannel.invokeMethod('closeTop');
  }

  @override
  Future<void> closeAll() async{
    await methodChannel.invokeMethod('closeAll');
  }

  @override
  Stream<Map<String, dynamic>> get events {
      return eventChannel.receiveBroadcastStream().map((event) {
        return Map<String, dynamic>.from(event);
      });
  }

  // // SDK 초기화 완료 전용 스트림
  // @override
  // Stream<bool> get onInitCompleted {
  //   return eventChannel.receiveBroadcastStream("onInitCompleted")
  //                   .where((e) => e["event"] == "onInitCompleted")
  //                   .map((e) => e["flag"] == true);
  // }

  // // 로그인 요청 전용 스트림
  // @override
  // Stream<String> get onLoginRequested {
  //     return eventChannel.receiveBroadcastStream("onLoginRequested")
  //                       .where((e) => e["event"] == "onLoginRequested")
  //                       .map((e) => e["param"] as String);
  // }

  // // 권한 요청 전용 스트림
  // @override
  // Stream<String> get onPermissionRequested {
  //   return eventChannel.receiveBroadcastStream("onPermissionRequested")
  //                   .where((e) => e["event"] == "onPermissionRequested")
  //                   .map((e) => e["param"] as String);
  // }



  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
