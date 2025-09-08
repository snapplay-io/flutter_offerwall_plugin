import Flutter
import UIKit
import s2offerwall

public class S2OfferwallFlutterPlugin: NSObject, FlutterPlugin, FlutterStreamHandler, S2OfferwallEventListener {
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
    case "showOfferwall":
      if let args = call.arguments as? [String: Any],
         let placementName = args["placementName"] as? String,
         let vc = UIApplication.shared.delegate?.window??.rootViewController {
        S2Offerwall.presentOfferwall(vc, placementName: placementName)
        registerOfferwallListener()
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
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public func onLoginRequested(_ param:String?) {
    NSLog("onLoginRequested: \(param ?? "nil")")
    eventSink?(["event":"onLoginRequested", "param": param])
  }
}
