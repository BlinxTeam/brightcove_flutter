library brightcove_flutter_platform_interface;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// The interface that implementations of brightcove_flutter must implement.
///
/// Platform implementations should extend this class rather than implement it as `video_player`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [BrightcoveFlutterPlatform] methods.
abstract class BrightcoveFlutterPlatform extends PlatformInterface {
  /// Constructs a BrightcoveFlutterPlatform.
  BrightcoveFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static BrightcoveFlutterPlatform _instance = _PlaceholderImplementation();

  /// The instance of [BrightcoveFlutterPlatform] to use.
  ///
  /// Defaults to a placeholder that does not override any methods, and thus
  /// throws `UnimplementedError` in most cases.
  static BrightcoveFlutterPlatform get instance => _instance;

  /// Platform-specific plugins should override this with their own
  /// platform-specific class that extends [BrightcoveFlutterPlatform] when they
  /// register themselves.
  static set instance(BrightcoveFlutterPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  Future create(DataSource dataSource, BrightcoveOptions options) {
    throw UnimplementedError();
  }

  /// Initializes the platform interface and disposes all existing players.
  ///
  /// This method is called when the plugin is first initialized
  /// and on every full restart.
  Future<void> init() {
    throw UnimplementedError('init() has not been implemented.');
  }

  /// Clears one video.
  Future<void> dispose(String playerId) {
    throw UnimplementedError('dispose() has not been implemented.');
  }

  /// Sets the looping attribute of the video.
  Future<void> setLooping(int playerId, bool looping) {
    throw UnimplementedError('setLooping() has not been implemented.');
  }

  /// Returns a Stream of [VideoEventType]s.
  Stream<VideoEvent> videoEventsFor(String playerId) {
    throw UnimplementedError('videoEventsFor() has not been implemented.');
  }

  /// Starts the video playback.
  Future<void> play(String playerId) {
    throw UnimplementedError('play() has not been implemented.');
  }

  /// Stops the video playback.
  Future<void> pause(String playerId) {
    throw UnimplementedError('pause() has not been implemented.');
  }

  /// Sets the volume to a range between 0.0 and 1.0.
  Future<void> setVolume(String playerId, double volume) {
    throw UnimplementedError('setVolume() has not been implemented.');
  }

  /// Sets the video position to a [Duration] from the start.
  Future<void> seekTo(String playerId, Duration position) {
    throw UnimplementedError('seekTo() has not been implemented.');
  }

  /// Sets the playback speed to a [speed] value indicating the playback rate.
  Future<void> setPlaybackSpeed(String playerId, double speed) {
    throw UnimplementedError('setPlaybackSpeed() has not been implemented.');
  }

  /// Gets the video position as [Duration] from the start.
  Future<Duration> getPosition(int playerId) {
    throw UnimplementedError('getPosition() has not been implemented.');
  }

  /// Returns a widget displaying the video with a given playerId.
  Widget buildView(String playerId) {
    throw UnimplementedError('buildView() has not been implemented.');
  }
}

class _PlaceholderImplementation extends BrightcoveFlutterPlatform {}

enum VideoSourceType {
  videoById,
  playlistById,
}

@immutable
class BrightcoveOptions {
  BrightcoveOptions({
    required this.account,
    required this.policy,
    this.catalogBaseUrl,
  });

  /// Your Brightcove's account id.
  final String account;

  /// The catalog's base url.
  ///
  /// Use the default if this field is null.
  final String? catalogBaseUrl;

  /// The policy key usedd to get the videos from your Brightcove account.
  final String policy;
}

class DataSource {
  /// Constructs a video with the given values. Only [duration] is required. The
  /// rest will initialize with default values when unset.
  DataSource({
    required this.dataSource,
    required this.sourceType,
  });

  final String dataSource;
  final VideoSourceType sourceType;

  /// Returns a new instance that has the same values as this current instance,
  /// except for any overrides passed in as arguments to [copyWith].
  DataSource copyWith({
    String? dataSource,
    VideoSourceType? sourceType,
  }) {
    return DataSource(
      sourceType: sourceType ?? this.sourceType,
      dataSource: dataSource ?? this.dataSource,
    );
  }

  @override
  String toString() {
    return '${objectRuntimeType(this, 'VideoPlayerValue')}('
        'dataSource: $dataSource, '
        'sourceType: $sourceType)';
  }
}

enum VideoEventType {
  /// The video has been initialized.
  initialized,

  /// The playback has ended.
  completed,

  /// Updated information on the buffering state.
  bufferingUpdate,

  /// The video started to buffer.
  bufferingStart,

  /// The video stopped to buffer.
  bufferingEnd,
  playProgress,

  /// An unknown event has been received.
  unknown,
}

/// Event emitted from the platform implementation.
@immutable
class VideoEvent {
  /// Creates an instance of [VideoEvent].
  ///
  /// The [eventType] argument is required.
  ///
  /// Depending on the [eventType], the [duration], [size],
  /// [rotationCorrection], and [buffered] arguments can be null.
  // ignore: prefer_const_constructors_in_immutables
  VideoEvent({
    required this.eventType,
    this.duration,
    this.size,
    this.currentPosition,
    this.rotationCorrection,
  });

  /// The type of the event.
  final VideoEventType eventType;

  /// Duration of the video.
  ///
  /// Only used if [eventType] is [VideoEventType.initialized].
  final Duration? duration;

  final double? currentPosition;

  /// Size of the video.
  ///
  /// Only used if [eventType] is [VideoEventType.initialized].
  final Size? size;

  /// Degrees to rotate the video (clockwise) so it is displayed correctly.
  ///
  /// Only used if [eventType] is [VideoEventType.initialized].
  final int? rotationCorrection;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is VideoEvent &&
            runtimeType == other.runtimeType &&
            eventType == other.eventType &&
            duration == other.duration &&
            currentPosition == other.currentPosition &&
            size == other.size &&
            rotationCorrection == other.rotationCorrection;
  }

  @override
  int get hashCode => Object.hash(
        eventType,
        currentPosition,
        duration,
        size,
        rotationCorrection,
      );
}
