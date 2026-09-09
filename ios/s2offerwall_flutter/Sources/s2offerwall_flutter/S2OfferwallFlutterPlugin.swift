import Flutter
import UIKit
import s2offerwall

public class S2OfferwallFlutterPlugin: NSObject, FlutterPlugin, FlutterStreamHandler,
                                      S2OfferwallEventListener, S2OfferwallInitializeListener,
                                      S2RewardedAdListener {
  private var eventSink: FlutterEventSink?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "s2offerwall_flutter", binaryMessenger: registrar.messenger())
    let eventChannel = FlutterEventChannel(name: "s2offerwall_flutter/events", binaryMessenger: registrar.messenger())

    let instance = S2OfferwallFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    eventChannel.setStreamHandler(instance)
  }

  // 화면을 띄울 ViewController 를 찾는다.
  //
  // UIApplication.shared.delegate?.window 는 scene 을 사용하지 않는 앱에서만 유효하다.
  // Flutter 최신 iOS 템플릿은 UIScene(FlutterSceneDelegate) 을 사용하므로 window 가
  // AppDelegate 가 아니라 scene 에 속하고, 그 경우 위 경로는 항상 nil 이 된다.
  // 그래서 connectedScenes 에서 key window 를 찾도록 보완한다.
  //
  // 또한 이미 다른 화면이 present 되어 있으면 그 위에 띄워야 하므로 최상단까지 따라간다.
  private func topViewController() -> UIViewController? {
    var root = UIApplication.shared.delegate?.window??.rootViewController

    if root == nil {
      let windowScenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }

      // 활성 상태인 scene 을 우선 찾고, 없으면 아무 scene 에서나 찾는다.
      let activeWindows = windowScenes.filter { $0.activationState == .foregroundActive }.flatMap { $0.windows }
      let allWindows = windowScenes.flatMap { $0.windows }

      let keyWindow = activeWindows.first(where: { $0.isKeyWindow })
                        ?? allWindows.first(where: { $0.isKeyWindow })
                        ?? allWindows.first

      root = keyWindow?.rootViewController
    }

    var top = root
    while let presented = top?.presentedViewController {
      top = presented
    }

    return top
  }

  // FlutterStreamHandler
  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }

  // 네이티브 이벤트 → Flutter 전송
  private func registerOfferwallListener() {
    S2Offerwall.setEventListener(self)
    S2Offerwall.setRewardedAdListener(self)

    // S2Offerwall.setEventListener { [weak self] in
    //   self?.eventSink?("onLoginRequested")
    // }
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "initSdk":
      registerOfferwallListener()
      S2Offerwall.initSdk(self)
      result(nil)
    case "showOfferwall":
      if let args = call.arguments as? [String: Any],
         let placementName = args["placementName"] as? String,
         let vc = topViewController() {
        registerOfferwallListener()
        S2Offerwall.presentOfferwall(vc, placementName: placementName)
        result(nil)
      } 
      else {
        result(FlutterError(code: "NO_VIEWCONTROLLER", message: "No root view controller", details: nil))
      }
    case "setAppId":
      if let args = call.arguments as? [String: Any],
         let appId = args["appId"] as? String {
        S2Offerwall.setAppId(appId)
        result(nil)
      }
      else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "App ID is required", details: nil))
      }
    case "setAppIdForIOS":
      if let args = call.arguments as? [String: Any],
         let appId = args["appId"] as? String {
        S2Offerwall.setAppId(appId)
        result(nil)
      }
      else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "App ID is required", details: nil))
      }
    case "setAppIdForAndroid":
      //NSLog("setAppIdForAndroid called on iOS platform : no action taken.")
      result(nil)
    case "setUserName":
      if let args = call.arguments as? [String: Any],
         let userName = args["userName"] as? String,
         let displayName = args["displayName"] as? String {
        S2Offerwall.setUserName(userName, displayName: displayName)
        result(nil)
      } 
      else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "User name is required", details: nil))
      }
    case "getUserName":
      let userName = S2Offerwall.getUserName()
      result(userName)
    case "resetUserName":
      S2Offerwall.resetUserName()
      result(nil)
    case "presentATTPopup":
      if let vc = topViewController() {
        S2Offerwall.presentATTPopup(vc)
        result(nil)
      }
      else {
        result(FlutterError(code: "NO_VIEWCONTROLLER", message: "No root view controller", details: nil))
      }
    case "setConsentDialogRequired":
      if let args = call.arguments as? [String: Any],
         let _ = args["required"] as? Bool {
        //S2Offerwall.setConsentDialogRequired(required)
        result(nil)
      }
      else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "Required flag is needed", details: nil))
      }
    case "requestMaxPointData":
      // Swift SDK 함수 호출
      S2Offerwall.requestMaxPointData() { data in
        result(data)  // completion -> Flutter 로 전달
      }
    case "requestOfferwallData":
      guard let args = call.arguments as? [String: Any],
            let placementName = args["placementName"] as? String else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "placementName is required", details: nil))
        return
      }

      let isEmbeded = args["isEmbeded"] as? Bool ?? false

      // Swift SDK 함수 호출
      S2Offerwall.requestOfferwallData(placementName: placementName, isEmbeded: isEmbeded) { data in
        result(data)  // completion -> Flutter 로 전달
      }
    case "openAdItem":
      guard let args = call.arguments as? [String: Any],
            let advId = args["advId"] as? Int,
            let needDetail = args["needDetail"] as? Bool,
            let placementFrom = args["placementFrom"] as? String else {
          result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid arguments", details: nil))
          return
      }

      if let vc = topViewController() {
        // S2Offerwall SDK 호출
        S2Offerwall.openAdItem(vc, advId: advId, needDetail: needDetail, placementFrom: placementFrom)
        result(nil)
      }
      else {
        result(FlutterError(code: "NO_VIEWCONTROLLER", message: "No root view controller", details: nil))
      }
    case "closeTop":
      S2Offerwall.closeTop() {
        result(nil)
      }
    case "closeAll":
      S2Offerwall.closeAll() {
        result(nil)
      }
    case "reportRewardedAdResult":
      // 앱 RV 결과. Dart 는 네이티브 request 객체를 들 수 없으므로 requestId 로 결과를 알린다.
      guard let args = call.arguments as? [String: Any],
            let requestId = args["requestId"] as? String,
            let rvResult = args["result"] as? String else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "requestId and result are required", details: nil))
        return
      }

      S2Offerwall.reportRewardedAdResult(requestId, rvResult)
      result(nil)
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public func onLoginRequested(_ param:String?) {
    NSLog("onLoginRequested: \(param ?? "nil")")
    DispatchQueue.main.async {
      self.eventSink?(["event":"onLoginRequested", "param": param])
    }
  }

  public func onSuccess() {
    NSLog("S2Offerwall initialized successfully.")
    DispatchQueue.main.async {
      self.eventSink?(["event":"onInitCompleted", "flag": true])
    }
  }
    
  public func onFailure() {
    NSLog("S2Offerwall initialization failed.")
    DispatchQueue.main.async {
      self.eventSink?(["event":"onInitCompleted", "flag": false])
    }
  }

  // MARK: S2RewardedAdListener

  public func onRewardedAdRequested(_ request: S2RewardedAdRequest) {
    sendRewardedAdEvent("onRewardedAdRequested", request)
  }

  public func onRewardedAdShow(_ request: S2RewardedAdRequest) {
    sendRewardedAdEvent("onRewardedAdShow", request)
  }

  // 앱 RV 요청을 Dart 로 전달한다.
  // Dart 는 네이티브 request 객체를 가질 수 없으므로 requestId 문자열만 넘기고,
  // 결과는 reportRewardedAdResult 메서드 호출로 되돌려 받는다.
  private func sendRewardedAdEvent(_ eventName: String, _ request: S2RewardedAdRequest) {
    DispatchQueue.main.async {
      guard let eventSink = self.eventSink else {
        // Dart 쪽 이벤트 스트림이 아직 연결되지 않았다.
        // 이벤트 페이지가 타임아웃까지 기다리지 않도록 즉시 응답한다.
        NSLog("no event sink. reply to rewarded-ad request. \(eventName)")
        if eventName == "onRewardedAdShow" {
          request.onDismissed()
        }
        else {
          request.onNoAd()
        }
        return
      }

      eventSink(["event": eventName,
                 "requestId": request.requestId,
                 "slot": request.slot])
    }
  }
}
