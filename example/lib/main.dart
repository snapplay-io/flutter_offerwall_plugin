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
      S2OfferwallFlutter.setUserName("flutter@gmail.com");
      S2OfferwallFlutter.closeAll().then((_) {
        print("Close ALL done!");
      });
    });

    S2OfferwallFlutter.setAppIdForIOS("ebfd98301e2a42f3b2f03af03d938200ac1d89d1702d966dd95d013bbf736253");
    S2OfferwallFlutter.setAppIdForAndroid("44df5b010a0766445c0f554f209e5bb9ee7f63e1ce0639238630020aa45ace49");

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
