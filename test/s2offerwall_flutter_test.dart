import 'package:flutter_test/flutter_test.dart';
import 'package:s2offerwall_flutter/s2offerwall_flutter.dart';
import 'package:s2offerwall_flutter/s2offerwall_flutter_platform_interface.dart';
import 'package:s2offerwall_flutter/s2offerwall_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockS2offerwallFlutterPlatform
    with MockPlatformInterfaceMixin
    implements S2OfferwallFlutterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final S2OfferwallFlutterPlatform initialPlatform = S2OfferwallFlutterPlatform.instance;

  test('$MethodChannelS2OfferwallFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelS2OfferwallFlutter>());
  });

  test('getPlatformVersion', () async {

    expect(await S2OfferwallFlutter.getPlatformVersion(), '42');
  });
}
