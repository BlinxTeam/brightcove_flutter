/*import 'package:flutter_test/flutter_test.dart';
import 'package:brightcove_android/brightcove_android.dart';
import 'package:brightcove_android/android_brightcove_impl.dart';
import 'package:brightcove_android/src/brightcove_android_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockBrightcoveAndroidPlatform
    with MockPlatformInterfaceMixin
    implements BrightcoveAndroidPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final BrightcoveAndroidPlatform initialPlatform = BrightcoveAndroidPlatform.instance;

  test('$MethodChannelBrightcoveAndroid is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelBrightcoveAndroid>());
  });

  test('getPlatformVersion', () async {
    BrightcoveAndroid brightcoveAndroidPlugin = BrightcoveAndroid();
    MockBrightcoveAndroidPlatform fakePlatform = MockBrightcoveAndroidPlatform();
    BrightcoveAndroidPlatform.instance = fakePlatform;

    expect(await brightcoveAndroidPlugin.getPlatformVersion(), '42');
  });
}*/
