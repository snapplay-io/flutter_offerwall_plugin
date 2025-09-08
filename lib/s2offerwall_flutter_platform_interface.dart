import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 's2offerwall_flutter_method_channel.dart';

abstract class S2OfferwallFlutterPlatform extends PlatformInterface {
  /// Constructs a S2offerwallFlutterPlatform.
  S2OfferwallFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static S2OfferwallFlutterPlatform _instance = MethodChannelS2OfferwallFlutter();

  /// The default instance of [S2OfferwallFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelS2OfferwallFlutter].
  static S2OfferwallFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [S2OfferwallFlutterPlatform] when
  /// they register themselves.
  static set instance(S2OfferwallFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> showOfferwall(String placementName) {
    throw UnimplementedError('showOfferwall() has not been implemented.');
  }

  Future<void> presentATTPopup() {
    throw UnimplementedError('presentATTPopup() has not been implemented.');
  }

  Future<void> setConsentDialogRequired(bool required) {
    throw UnimplementedError('setConsentDialogRequired() has not been implemented.');
  }
  
  Future<void> setUserName(String username) {
    throw UnimplementedError('setUserName() has not been implemented.');
  }

  Future<String> getUserName() {
    throw UnimplementedError('getUserName() has not been implemented.');
  }

  Future<void> resetUserName() {
    throw UnimplementedError('resetUserName() has not been implemented.');
  }

  Future<void> setAppId(String appId) {
    throw UnimplementedError('setAppId() has not been implemented.');
  }

  Future<void> setAppIdForAndroid(String appId) {
    throw UnimplementedError('setAppIdForAndroid() has not been implemented.');
  }

  Future<void> setAppIdForIOS(String appId) {
    throw UnimplementedError('setAppIdForIOS() has not been implemented.');
  }

  Stream<String> get onLoginRequested {
    throw UnimplementedError('onLoginRequest() has not been implemented.');
  }

  Stream<String> get onPermissionRequested {
    throw UnimplementedError('onPermissionRequest() has not been implemented.');
  }



  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
