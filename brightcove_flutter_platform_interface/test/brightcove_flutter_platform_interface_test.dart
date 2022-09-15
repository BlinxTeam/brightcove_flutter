import 'package:brightcove_flutter_platform_interface/brightcove_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Store the initial instance before any tests change it.
  final BrightcoveFlutterPlatform initialInstance = BrightcoveFlutterPlatform.instance;

  test('default implementation throws uninimpletemented', () async {
    await expectLater(() => initialInstance.init(), throwsUnimplementedError);
  });
}