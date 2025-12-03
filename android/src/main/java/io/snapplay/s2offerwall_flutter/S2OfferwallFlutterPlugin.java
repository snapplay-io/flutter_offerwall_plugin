package io.snapplay.s2offerwall_flutter;

import androidx.annotation.NonNull;
import android.app.Activity;
import android.util.Log;
import android.os.Handler;
import android.os.Looper;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.embedding.engine.plugins.FlutterPlugin;

import s2.adapi.sdk.offerwall.S2Offerwall;

public class S2OfferwallFlutterPlugin implements FlutterPlugin, MethodChannel.MethodCallHandler, EventChannel.StreamHandler, ActivityAware {
    private MethodChannel methodChannel;
    private EventChannel eventChannel;
    private EventChannel.EventSink eventSink;

    private Activity activity;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        methodChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "s2offerwall_flutter");
        methodChannel.setMethodCallHandler(this);

        eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), "s2offerwall_flutter/events");
        eventChannel.setStreamHandler(this);

        registerOfferwallListener();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        methodChannel.setMethodCallHandler(null);
        eventChannel.setStreamHandler(null);
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        this.activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        activity = null;
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivity() {
        activity = null;
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        Log.e("S2OfferwallPlugin", "EventChannel onListen called " + arguments);
        this.eventSink = events;
    }

    @Override
    public void onCancel(Object arguments) {
        Log.e("S2OfferwallPlugin", "EventChannel onCancel called " + arguments);
        this.eventSink = null;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (activity == null) {
            Log.e("S2OfferwallPlugin", "Activity is null when " + call.method + " called!");
            result.error("NO_ACTIVITY", "Activity is not attached", null);
            return;
        }

        if ("initSdk".equals(call.method)) {
            S2Offerwall.initSdk(activity, new S2Offerwall.InitializeListener() {
                @Override
                public void onSuccess() {
                    activity.runOnUiThread(() -> {
                        if (eventSink != null) {
                            Map<String, Object> event = new HashMap<>();
                            event.put("event", "onInitCompleted");
                            event.put("flag", true);
                            eventSink.success(event);
                        }
                    });
                }

                @Override
                public void onFailure() {
                    activity.runOnUiThread(() -> {
                        if (eventSink != null) {
                            Map<String, Object> event = new HashMap<>();
                            event.put("event", "onInitCompleted");
                            event.put("flag", false);
                            eventSink.success(event);
                        }
                    });
                }
            });

            result.success(null);
        }
        else if ("showOfferwall".equals(call.method)) {
            String placementName = call.argument("placementName");
            S2Offerwall.startActivity(activity, placementName);
            result.success(null); 
        }
        else if ("setAppId".equals(call.method)) {
            String appId = call.argument("appId");
            S2Offerwall.setAppId(activity, appId);
            result.success(null);
        }
        else if ("setAppIdForAndroid".equals(call.method)) {
            String appId = call.argument("appId");
            S2Offerwall.setAppId(activity, appId);
            result.success(null);
        }
        else if ("setAppIdForIOS".equals(call.method)) {
            //Log.d("S2OfferwallPlugin", "setAppIdForIOS called on Android platform : no action taken.");
            result.success(null);
        }
        else if ("setUserName".equals(call.method)) {
            String userName = call.argument("userName");
            String displayName = call.argument("displayName");
            Log.d("S2OfferwallPlugin", "setUserName called with userName: " + userName + ", displayName: " + displayName);
            S2Offerwall.setUserName(activity, userName, displayName);
            result.success(null);
        }
        else if ("getUserName".equals(call.method)) {
            String userName = S2Offerwall.getUserName(activity);
            result.success(userName);
        }
        else if ("resetUserName".equals(call.method)) {
            S2Offerwall.resetUserName(activity);
            result.success(null);
        }
        else if ("presentATTPopup".equals(call.method)) {
            result.success(null);
        }
        else if ("setConsentDialogRequired".equals(call.method)) {
            Boolean required = call.argument("required");
            S2Offerwall.setConsentDialogRequired(activity, required != null ? required : false);
            result.success(null);
        }
        else if ("setConsentAgreed".equals(call.method)) {
            Boolean agreed = call.argument("agreed");
            S2Offerwall.setConsentAgreed(activity, agreed != null ? agreed : false);
            result.success(null);
        }
        else if ("requestOfferwallData".equals(call.method)) {
            final String placementName = call.argument("placementName");
            final Boolean isEmbeded = call.argument("isEmbeded");

            new Thread(() -> {
                String data = S2Offerwall.requestOfferwallData(activity, placementName, isEmbeded);
                result.success(data);
            }).start();
        }
        else if ("openAdItem".equals(call.method)) {
            Number advId = call.argument("advId");
            boolean needDetail = call.argument("needDetail");
            String placementFrom = call.argument("placementFrom");

            S2Offerwall.openAdItem(activity, advId.longValue(), needDetail, placementFrom);
            result.success(null);
        }
        else if ("closeTop".equals(call.method)) {
            S2Offerwall.closeTop();
            result.success(null);
        }
        else if ("closeAll".equals(call.method)) {
            S2Offerwall.closeAll();
            result.success(null);
        }
        else if ("getPlatformVersion".equals(call.method)) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        }
        else {
            result.notImplemented();
        }
    }

    private void registerOfferwallListener() {
        S2Offerwall.setEventListener(new S2Offerwall.EventListener() {
            @Override
            public void onLoginRequested(String param) {
                new Handler(Looper.getMainLooper()).post(() -> {
                    if (eventSink != null) {
                        Map<String, Object> event = new HashMap<>();
                        event.put("event", "onLoginRequested");
                        event.put("param", param);
                        eventSink.success(event);
                    }
                });
            }

            @Override
            public void onCloseRequested(String param) {
                
            }

            @Override
            public void onPermissionRequested(String permission) {
                
            }
        });
    }
}