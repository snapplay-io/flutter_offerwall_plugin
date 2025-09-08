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

    // 플러그인에서 제공하는 스트림 구독
    S2OfferwallFlutter.onLoginRequested.listen((param) {
      print("로그인 이벤트 수신: $param");
      S2OfferwallFlutter.setUserName("flutter@gmail.com");
    });

    S2OfferwallFlutter.setAppIdForIOS("1555143e4a58eccb607f014e7b1b3bdfe52893d29f484033cb06c3ad0f2ca651");
    S2OfferwallFlutter.setAppIdForAndroid("44df5b010a0766445c0f554f209e5bb9ee7f63e1ce0639238630020aa45ace49");
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
