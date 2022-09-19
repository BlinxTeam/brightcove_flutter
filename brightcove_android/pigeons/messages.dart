// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  //dartTestOut: 'test/test_api.dart',
  javaOut:
      'android/src/main/kotlin/com/monstarlab/brightcove_android//Messages.java',
  javaOptions: JavaOptions(
    package: 'com.monstarlab.brightcove_android',
  ),
  //copyrightHeader: 'pigeons/copyright.txt',
))
class TextureMessage {
  TextureMessage(this.playerId);

  String playerId;
}

class LoopingMessage {
  LoopingMessage(this.playerId, this.isLooping);

  String playerId;
  bool isLooping;
}

class VolumeMessage {
  VolumeMessage(this.playerId, this.volume);

  String playerId;
  double volume;
}

class PlaybackSpeedMessage {
  PlaybackSpeedMessage(this.playerId, this.speed);

  String playerId;
  double speed;
}

class PositionMessage {
  PositionMessage(this.playerId, this.position);

  String playerId;
  int position;
}

class PictureInPictureMessage {
  PictureInPictureMessage(this.enabled);

  bool enabled;
}

enum DataSourceType {videoById, playlistById}

class PlayMessage {
  PlayMessage(this.dataSource, this.dataSourceType, this.account, this.catalogBaseUrl, this.policy);

  String account;
  String policy;
  String dataSource;
  String? catalogBaseUrl;
  DataSourceType dataSourceType;
}

@HostApi(dartHostTestHandler: 'TestHostBrightcoveVideoPlayerApi')
abstract class BrightcoveVideoPlayerApi {
  void initialize();

  TextureMessage create(PlayMessage msg);

  void dispose(TextureMessage msg);

  void setVolume(VolumeMessage msg);

  void enterPictureInPictureMode(TextureMessage msg);

  void play(TextureMessage msg);

  void pause(TextureMessage msg);

  void seekTo(PositionMessage msg);
}
