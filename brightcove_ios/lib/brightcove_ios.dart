import 'package:brightcove_flutter_platform_interface/brightcove_flutter_platform_interface.dart';
import 'package:flutter/material.dart';


class BrightcoveIosPlatform extends BrightcoveFlutterPlatform {


  static void registerWidth() {
    BrightcoveFlutterPlatform.instance = BrightcoveIosPlatform();
  }

  @override
  Future create(DataSource dataSource, BrightcoveOptions options) async {

  }

  @override
  Widget buildView(String playerId) {
    return UiKitView(
      viewType: playerId,
    );
  }

  @override
  Future<void> init() async {
  }

  @override
  Future<void> play(String playerId) {

  }

  @override
  Future<void> pause(String playerId) {
    // TODO: implement pause
    return super.pause(playerId);
  }
}
