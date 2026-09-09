
import 's2offerwall_flutter_platform_interface.dart';

typedef EventCallback = void Function(dynamic data);

/// 앱 RV 요청을 전달받는 콜백이다.
typedef RewardedAdCallback = void Function(S2RewardedAdRequest request);

class S2Offerwall {
  static const String main = "main";
}

/// 광고 길이 구분
class S2RewardedAdSlot {
  static const String short = "short";
  static const String middle = "middle";
  static const String long = "long";
  static const String random = "random";
}

/// 오퍼월 이벤트 페이지가 리워드 광고(RV)를 필요로 할 때 전달되는 요청이다.
///
/// 매체 앱은 자신의 리워드 광고(admob 등)를 재생하고 아래 메서드 중 하나로 결과를 알린다.
/// 각 요청은 반드시 한 번만 완료해야 하며, 추가 호출은 무시된다.
///
/// 로딩 단계 - [S2OfferwallFlutter.onRewardedAdRequested]
///  - [onLoaded] : 광고 준비 완료
///  - [onNoAd] : 광고 없음. 이벤트 페이지는 기존 웹 광고로 폴백한다
///
/// 재생 단계 - [S2OfferwallFlutter.onRewardedAdShow]
///  - [onGranted] : 유저가 끝까지 시청함
///  - [onDismissed] : 유저가 광고를 닫았거나 재생에 실패함
///
/// 주의 : [onNoAd] 는 로딩 단계 전용이다. 재생 단계의 실패는 [onDismissed] 로 알려야 한다.
/// 재생 중에 광고 없음을 보고하면 이벤트 페이지가 폴백 처리를 하지 못해 버튼이 묶인다.
class S2RewardedAdRequest {
  /// 이 요청의 식별자. 결과를 되돌려 보낼 때 사용된다.
  final String requestId;

  /// 요청된 광고 길이. [S2RewardedAdSlot] 참고.
  final String slot;

  const S2RewardedAdRequest(this.requestId, this.slot);

  /// 리워드 광고가 준비되었음을 알린다. (로딩 단계)
  Future<void> onLoaded() {
    return S2OfferwallFlutter.reportRewardedAdResult(requestId, "loaded");
  }

  /// 재생할 광고가 없음을 알린다. (로딩 단계)
  Future<void> onNoAd() {
    return S2OfferwallFlutter.reportRewardedAdResult(requestId, "noad");
  }

  /// 유저가 광고를 끝까지 시청했음을 알린다. (재생 단계)
  Future<void> onGranted() {
    return S2OfferwallFlutter.reportRewardedAdResult(requestId, "granted");
  }

  /// 유저가 광고를 닫았거나 재생에 실패했음을 알린다. (재생 단계)
  Future<void> onDismissed() {
    return S2OfferwallFlutter.reportRewardedAdResult(requestId, "dismissed");
  }

  @override
  String toString() => "S2RewardedAdRequest(requestId: $requestId, slot: $slot)";
}

class S2OfferwallFlutter {

  static Map<String, EventCallback> eventHandlers = {};

  // 앱 RV 이벤트는 requestId, slot 두 값을 함께 전달해야 하므로 별도 핸들러로 관리한다.
  static Map<String, RewardedAdCallback> rewardedAdHandlers = {};

  static const String _eventRewardedAdRequested = "onRewardedAdRequested";
  static const String _eventRewardedAdShow = "onRewardedAdShow";

  static void onLoginRequested(EventCallback callback) {
    eventHandlers["onLoginRequested"] = callback;
  }

  /// 이벤트 페이지가 리워드 광고 로딩을 요청할 때 호출된다.
  ///
  /// 광고가 준비되면 `request.onLoaded()`, 광고가 없으면 `request.onNoAd()` 를 호출한다.
  /// 등록하지 않으면 이벤트 페이지는 기존처럼 웹 리워드 광고를 사용한다.
  ///
  /// [initSdk] 보다 먼저 등록해야 한다.
  static void onRewardedAdRequested(RewardedAdCallback callback) {
    rewardedAdHandlers[_eventRewardedAdRequested] = callback;
  }

  /// 로딩된 리워드 광고를 재생할 때 호출된다.
  ///
  /// 시청이 완료되면 `request.onGranted()`,
  /// 유저가 닫았거나 재생에 실패하면 `request.onDismissed()` 를 호출한다.
  ///
  /// [initSdk] 보다 먼저 등록해야 한다.
  static void onRewardedAdShow(RewardedAdCallback callback) {
    rewardedAdHandlers[_eventRewardedAdShow] = callback;
  }

  /// 리워드 광고 요청의 결과를 알린다.
  /// 보통은 [S2RewardedAdRequest] 의 메서드를 사용하면 되고, 이 함수를 직접 쓸 일은 없다.
  ///
  /// [result] 는 loaded, noad, granted, dismissed 중 하나이다.
  static Future<void> reportRewardedAdResult(String requestId, String result) {
    return S2OfferwallFlutterPlatform.instance.reportRewardedAdResult(requestId, result);
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

      // 앱 RV 이벤트는 파라메터 구성이 달라서 별도로 처리한다.
      if (eventName == _eventRewardedAdRequested || eventName == _eventRewardedAdShow) {
        _handleRewardedAdEvent(eventName, event);
        return;
      }

      if (eventHandlers.containsKey(eventName)) {
        eventHandlers[eventName]?.call(event["param"] ?? event["flag"]);
      }
    });

    return S2OfferwallFlutterPlatform.instance.initSdk();
  }

  static void _handleRewardedAdEvent(String eventName, Map<String, dynamic> event) {
    final request = S2RewardedAdRequest(
      event["requestId"] as String? ?? "",
      event["slot"] as String? ?? S2RewardedAdSlot.random,
    );

    final callback = rewardedAdHandlers[eventName];
    if (callback == null) {
      // 매체 앱이 앱 RV 를 연동하지 않았다.
      // 이벤트 페이지가 타임아웃으로 기다리지 않도록 즉시 광고 없음으로 응답한다.
      // (재생 단계는 발생할 수 없지만, 방어적으로 중단 처리한다)
      if (eventName == _eventRewardedAdShow) {
        request.onDismissed();
      }
      else {
        request.onNoAd();
      }
      return;
    }

    callback(request);
  }

  static Future<void> showOfferwall(String placementName) {
    return S2OfferwallFlutterPlatform.instance.showOfferwall(placementName);
  }

  static Future<void> setUserName(String username, [String displayName = ""]) {
    return S2OfferwallFlutterPlatform.instance.setUserName(username, displayName);
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

  static Future<String> requestMaxPointData() {
    return S2OfferwallFlutterPlatform.instance.requestMaxPointData();
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
