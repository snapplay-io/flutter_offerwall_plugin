import 'package:flutter/material.dart';
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
        // S2OfferwallFlutter.requestOfferwallData("cpu_click", false).then( (data) {
        //   print("Offerwall Data: $data");
        // });
        print("SDK 초기화 성공");
      } 
      else {
        print("SDK 초기화 실패");
      }
    });

    S2OfferwallFlutter.onLoginRequested((param) {
      print("로그인 이벤트 수신: $param");
      S2OfferwallFlutter.setUserName("flutter@gmail.com","Flutter 사용자");
      // S2OfferwallFlutter.closeAll().then((_) {
      //   print("Close ALL done!");
      // });
    });

    S2OfferwallFlutter.setAppIdForIOS("0d724e96d380f016521e1bba1d9142eae52893d29f484033cb06c3ad0f2ca651");
    S2OfferwallFlutter.setAppIdForAndroid("0d724e96d380f016521e1bba1d9142eae52893d29f484033cb06c3ad0f2ca651");

    S2OfferwallFlutter.initSdk();

    
    S2OfferwallFlutter.resetUserName();
    S2OfferwallFlutter.presentATTPopup();
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
