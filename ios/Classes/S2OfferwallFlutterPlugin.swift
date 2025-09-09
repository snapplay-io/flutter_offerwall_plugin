import Flutter
import UIKit
import s2offerwall

public class S2OfferwallFlutterPlugin: NSObject, FlutterPlugin, FlutterStreamHandler, 
                                      S2OfferwallEventListener, S2OfferwallInitializeListener {
  private var eventSink: FlutterEventSink?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "s2offerwall_flutter", binaryMessenger: registrar.messenger())
    let eventChannel = FlutterEventChannel(name: "s2offerwall_flutter/events", binaryMessenger: registrar.messenger())

    let instance = S2OfferwallFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    eventChannel.setStreamHandler(instance)
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
         let vc = UIApplication.shared.delegate?.window??.rootViewController {
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
         let userName = args["userName"] as? String {
        S2Offerwall.setUserName(userName)
        result(nil)
      } 
      else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "User name is required", details: nil))
      }
    case "getUserName":
      let userName = S2Offerwall.getUserName() ?? ""
      result(userName)
    case "resetUserName":
      S2Offerwall.resetUserName()
      result(nil)
    case "presentATTPopup":
      if let vc = UIApplication.shared.delegate?.window??.rootViewController {
        S2Offerwall.presentATTPopup(vc)
        result(nil)
      }
      else {
        result(FlutterError(code: "NO_VIEWCONTROLLER", message: "No root view controller", details: nil))
      }
    case "setConsentDialogRequired":
      if let args = call.arguments as? [String: Any],
         let required = args["required"] as? Bool {
        //S2Offerwall.setConsentDialogRequired(required)
        result(nil)
      }
      else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "Required flag is needed", details: nil))
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

      if let vc = UIApplication.shared.delegate?.window??.rootViewController {
        // S2Offerwall SDK 호출
        S2Offerwall.openAdItem(vc, advId: advId, needDetail: needDetail, placementFrom: placementFrom)
        result(nil)
      }
      else {
        result(FlutterError(code: "NO_VIEWCONTROLLER", message: "No root view controller", details: nil))
      }
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
}
