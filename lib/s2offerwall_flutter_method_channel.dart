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

  // 내부에서 모든 이벤트를 공통적으로 수신
  Stream<Map<String, dynamic>> get events {
      return eventChannel.receiveBroadcastStream().map((event) {
        return Map<String, dynamic>.from(event);
      });
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
  Future<void> setUserName(String username) async {
    await methodChannel.invokeMethod('setUserName', {"userName": username});
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

  // 로그인 요청 전용 스트림
  @override
  Stream<String> get onLoginRequested {
      return events.where((e) => e["event"] == "onLoginRequested")
                   .map((e) => e["param"] as String);
  }

  // 권한 요청 전용 스트림
  @override
  Stream<String> get onPermissionRequested {
    return events.where((e) => e["event"] == "onPemissionRequested")
                   .map((e) => e["param"] as String);
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
