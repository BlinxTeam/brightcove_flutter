import 'package:brightcove_android/src/messages.g.dart';
import 'package:brightcove_flutter_platform_interface/brightcove_flutter_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BrightcoveAndroidPlatform extends BrightcoveFlutterPlatform {
  static const String viewTypeId = 'brightcove_videoplayer';
  final BrightcoveVideoPlayerApi _api = BrightcoveVideoPlayerApi();

  static void registerWith() {
    BrightcoveFlutterPlatform.instance = BrightcoveAndroidPlatform();
  }

  DataSourceType _convertTypes(VideoSourceType type) {
    switch (type) {
      case VideoSourceType.videoById:
        return DataSourceType.videoById;
      case VideoSourceType.playlistById:
        return DataSourceType.playlistById;
    }
  }

  @override
  Future create(DataSource dataSource, BrightcoveOptions options) async {
    final msg = PlayMessage(
      dataSource: dataSource.dataSource,
      dataSourceType: _convertTypes(dataSource.sourceType),
      account: options.account,
      policy: options.policy,
    );
    final playerId = (await _api.create(msg)).playerId;
    return playerId;
  }

  @override
  Stream<VideoEvent> videoEventsFor(String playerId) {
    return EventChannel("brightcove_videoplayer/videoEvents$playerId")
        .receiveBroadcastStream()
        .map((event) {
      final Map<dynamic, dynamic> map = event as Map<dynamic, dynamic>;
      switch (map['event']) {
        case 'bufferingStart':
          return VideoEvent(eventType: VideoEventType.bufferingStart);
        case 'bufferedUpdate':
          // TODO load missing properties
          return VideoEvent(eventType: VideoEventType.bufferingUpdate);
        case 'bufferingCompleted':
          return VideoEvent(eventType: VideoEventType.bufferingEnd);
        case 'initialized':
          return VideoEvent(
            eventType: VideoEventType.initialized,
            duration: Duration(milliseconds: map['duration'] as int),
          );
        case 'playProgress':
          return VideoEvent(
            eventType: VideoEventType.playProgress,
            currentPosition: (map['position'] as int).toDouble(),
          );
        default:
          return VideoEvent(eventType: VideoEventType.unknown);
      }
    });
  }

  @override
  Widget buildView(String playerId) {
    return AndroidView(
      viewType: '$viewTypeId#$playerId',
      creationParamsCodec: const StandardMessageCodec(),
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory<OneSequenceGestureRecognizer>(
          () => EagerGestureRecognizer(),
        ),
      },
    );
  }

  @override
  Future<void> init() {
    return _api.initialize();
  }

  @override
  Future<void> dispose(String playerId) {
    return _api.dispose(TextureMessage(playerId: playerId));
  }

  @override
  Future<void> play(String playerId) {
    return _api.playOrPause(TextureMessage(playerId: playerId));
  }

  @override
  Future<void> pause(String playerId) {
    return _api.playOrPause(TextureMessage(playerId: playerId));
  }
  

  @override
  Future<void> seekTo(String playerId, Duration position) {
    return _api.seekTo(PositionMessage(
        playerId: playerId, position: position.inMilliseconds));
  }

  @override
  Future<void> setVolume(String playerId, double volume) {
    return _api.setVolume(VolumeMessage(playerId: playerId, volume: volume));
  }
}
