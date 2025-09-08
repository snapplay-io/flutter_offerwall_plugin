import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:s2offerwall_flutter/s2offerwall_flutter_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelS2OfferwallFlutter platform = MethodChannelS2OfferwallFlutter();
  const MethodChannel channel = MethodChannel('s2offerwall_flutter');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
