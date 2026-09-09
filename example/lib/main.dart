import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:s2offerwall_flutter/s2offerwall_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();

    S2OfferwallFlutter.onInitCompleted((success) {
      if (success) {
        S2OfferwallFlutter.requestMaxPointData().then( (data) {
          print("MaxPoint Data: $data");
        });
        print("SDK 초기화 성공");
      } 
      else {
        print("SDK 초기화 실패");
      }
    });

    _initRewardedAd();

    S2OfferwallFlutter.onLoginRequested((param) {
      print("로그인 이벤트 수신: $param");
      S2OfferwallFlutter.setUserName("flutter@gmail.com","Flutter 사용자");
      // S2OfferwallFlutter.closeAll().then((_) {
      //   print("Close ALL done!");
      // });
      //S2OfferwallFlutter.closeAll();
    });

    S2OfferwallFlutter.setAppIdForIOS("0d724e96d380f016521e1bba1d9142eae52893d29f484033cb06c3ad0f2ca651");
    S2OfferwallFlutter.setAppIdForAndroid("0d724e96d380f016521e1bba1d9142eae52893d29f484033cb06c3ad0f2ca651");

    S2OfferwallFlutter.initSdk();

    
    S2OfferwallFlutter.resetUserName();
    S2OfferwallFlutter.presentATTPopup();
  }

  // 앱 RV 연동 테스트 모드
  // false 로 두면 광고 없이 더미로 동작하므로 연동 흐름만 먼저 확인할 수 있다.
  static const bool useAdMob = false;

  // 구글이 공개한 테스트용 리워드 광고 단위 ID 이다. 실제 매체 앱은 자신의 광고 단위를 사용한다.
  static final String _rewardedAdUnitId = Platform.isAndroid
      ? "ca-app-pub-3940256099942544/5224354917"
      : "ca-app-pub-3940256099942544/1712485313";

  RewardedAd? _loadedAd;

  // 이벤트 페이지의 앱 RV 요청을 매체 앱이 처리하도록 콜백을 등록한다.
  // 등록하지 않으면 이벤트 페이지는 기존처럼 웹 리워드 광고를 사용한다.
  // initSdk() 보다 먼저 등록해야 한다.
  void _initRewardedAd() {
    if (useAdMob) {
      MobileAds.instance.initialize();
    }

    S2OfferwallFlutter.onRewardedAdRequested((request) async {
      print("RV 로딩 요청: $request");

      if (!useAdMob) {
        // 더미 : 광고 없이 흐름만 확인한다.
        await Future.delayed(const Duration(milliseconds: 1500));
        request.onLoaded();
        //request.onNoAd();   // 광고 없음 -> 웹 광고로 폴백되는지 확인용
        return;
      }

      if (_loadedAd != null) {
        // 미리 로딩해둔 광고가 있으면 즉시 응답한다.
        // 이벤트 페이지는 로딩을 몇 초만 기다리고 웹 광고로 넘어가므로
        // 실제 매체 앱에서는 미리 로딩해두는 것이 좋다.
        print("RV 이미 로딩됨");
        request.onLoaded();
        return;
      }

      RewardedAd.load(
        adUnitId: _rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            print("RV 로딩 완료");
            _loadedAd = ad;
            request.onLoaded();
          },
          onAdFailedToLoad: (error) {
            print("RV 로딩 실패: $error");
            _loadedAd = null;
            request.onNoAd();
          },
        ),
      );
    });

    S2OfferwallFlutter.onRewardedAdShow((request) async {
      print("RV 재생 요청: $request");

      if (!useAdMob) {
        await Future.delayed(const Duration(seconds: 3));
        //request.onGranted();
        request.onDismissed();   // 시청 중단 시 버튼이 원복되는지 확인용
        return;
      }

      final ad = _loadedAd;
      _loadedAd = null; // 리워드 광고는 1회만 재생할 수 있다.

      if (ad == null) {
        // 재생 단계의 실패는 onNoAd() 가 아니라 onDismissed() 로 알려야 한다.
        print("RV 재생할 광고 없음");
        request.onDismissed();
        return;
      }

      // 적립 콜백은 광고가 닫히기 전에 호출된다.
      // 적립 여부를 기억해두었다가 닫히는 시점에 한 번만 결과를 알린다.
      var earned = false;

      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          print("RV 닫힘. earned=$earned");
          ad.dispose();
          earned ? request.onGranted() : request.onDismissed();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print("RV 재생 실패: $error");
          ad.dispose();
          request.onDismissed();
        },
      );

      ad.show(onUserEarnedReward: (ad, reward) {
        print("RV 적립: ${reward.amount} ${reward.type}");
        earned = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await S2OfferwallFlutter.showOfferwall("main");
                    //await S2OfferwallFlutter.openAdItem(292387, true, "cpu_click");
                    //appState.getNext();
                  }, 
                  child: Text('Next'),
                ),
              ],
            ),
          
        ),
      ),
    );
  }
}
