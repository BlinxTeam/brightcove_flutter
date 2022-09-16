library brightcove_flutter;

import 'dart:async';
import 'dart:math' as math;

import 'package:brightcove_flutter_platform_interface/brightcove_flutter_platform_interface.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

export 'package:brightcove_flutter_platform_interface/brightcove_flutter_platform_interface.dart'
    show BrightcoveOptions;

BrightcoveFlutterPlatform? _lastPlayerPlatform;

BrightcoveFlutterPlatform get _videoPlayerPlatform {
  final BrightcoveFlutterPlatform currentInstance =
      BrightcoveFlutterPlatform.instance;
  if (_lastPlayerPlatform != currentInstance) {
    // This will clear all open videos on the platform when a full restart is
    // performed.
    currentInstance.init();
    _lastPlayerPlatform = currentInstance;
  }
  return currentInstance;
}

/// The duration, current position, buffering state, error state and settings
/// of a [BrightcoveVideoPlayerController].
class VideoPlayerValue {
  /// Constructs a video with the given values. Only [duration] is required. The
  /// rest will initialize with default values when unset.
  VideoPlayerValue({
    required this.duration,
    this.size = Size.zero,
    this.position = Duration.zero,
    this.isInitialized = false,
    this.isPlaying = false,
    this.isLooping = false,
    this.isBuffering = false,
    this.volume = 1.0,
    this.rotationCorrection = 0,
    this.errorDescription,
  });

  /// Returns an instance for a video that hasn't been loaded.
  VideoPlayerValue.uninitialized()
      : this(duration: Duration.zero, isInitialized: false);

  /// Returns an instance with the given [errorDescription].
  VideoPlayerValue.erroneous(String errorDescription)
      : this(
          duration: Duration.zero,
          isInitialized: false,
          errorDescription: errorDescription,
        );

  /// This constant is just to indicate that parameter is not passed to [copyWith]
  /// workaround for this issue https://github.com/dart-lang/language/issues/2009
  static const String _defaultErrorDescription = 'defaultErrorDescription';

  /// The total duration of the video.
  ///
  /// The duration is [Duration.zero] if the video hasn't been initialized.
  final Duration duration;

  /// The current playback position.
  final Duration position;

  /// True if the video is playing. False if it's paused.
  final bool isPlaying;

  /// True if the video is looping.
  final bool isLooping;

  /// True if the video is currently buffering.
  final bool isBuffering;

  /// The current volume of the playback.
  final double volume;

  /// A description of the error if present.
  ///
  /// If [hasError] is false this is `null`.
  final String? errorDescription;

  /// The [size] of the currently loaded video.
  final Size size;

  /// Degrees to rotate the video (clockwise) so it is displayed correctly.
  final int rotationCorrection;

  /// Indicates whether or not the video has been loaded and is ready to play.
  final bool isInitialized;

  /// Indicates whether or not the video is in an error state. If this is true
  /// [errorDescription] should have information about the problem.
  bool get hasError => errorDescription != null;

  /// Returns [size.width] / [size.height].
  ///
  /// Will return `1.0` if:
  /// * [isInitialized] is `false`
  /// * [size.width], or [size.height] is equal to `0.0`
  /// * aspect ratio would be less than or equal to `0.0`
  double get aspectRatio {
    if (!isInitialized || size.width == 0 || size.height == 0) {
      return 1.0;
    }
    final double aspectRatio = size.width / size.height;
    if (aspectRatio <= 0) {
      return 1.0;
    }
    return aspectRatio;
  }

  bool get isMuted => volume == 0;

  /// Returns a new instance that has the same values as this current instance,
  /// except for any overrides passed in as arguments to [copyWith].
  VideoPlayerValue copyWith({
    Duration? duration,
    Size? size,
    Duration? position,
    Duration? captionOffset,
    bool? isInitialized,
    bool? isPlaying,
    bool? isLooping,
    bool? isBuffering,
    double? volume,
    double? playbackSpeed,
    int? rotationCorrection,
    VideoSourceType? sourceType,
    String? errorDescription = _defaultErrorDescription,
  }) {
    return VideoPlayerValue(
      duration: duration ?? this.duration,
      size: size ?? this.size,
      position: position ?? this.position,
      isInitialized: isInitialized ?? this.isInitialized,
      isPlaying: isPlaying ?? this.isPlaying,
      isLooping: isLooping ?? this.isLooping,
      isBuffering: isBuffering ?? this.isBuffering,
      volume: volume ?? this.volume,
      rotationCorrection: rotationCorrection ?? this.rotationCorrection,
      errorDescription: errorDescription != _defaultErrorDescription
          ? errorDescription
          : this.errorDescription,
    );
  }

  @override
  String toString() {
    return '${objectRuntimeType(this, 'VideoPlayerValue')}('
        'duration: $duration, '
        'size: $size, '
        'position: $position, '
        'isInitialized: $isInitialized, '
        'isPlaying: $isPlaying, '
        'isLooping: $isLooping, '
        'isBuffering: $isBuffering, '
        'volume: $volume, '
        'errorDescription: $errorDescription)';
  }

  @override
  bool operator ==(other) {
    return (other is VideoPlayerValue &&
        other.isInitialized == isInitialized &&
        other.isLooping == isLooping &&
        other.isBuffering == isBuffering &&
        other.volume == volume &&
        other.errorDescription == errorDescription &&
        other.position == position &&
        other.size == size &&
        other.duration == duration &&
        other.isPlaying == isPlaying);
  }

  @override
  int get hashCode => Object.hash(
        isInitialized,
        isPlaying,
        isLooping,
        volume,
        size,
        duration,
        errorDescription,
        isBuffering,
        position,
      );
}

class BrightcoveVideoPlayerController extends ValueNotifier<VideoPlayerValue> {
  BrightcoveVideoPlayerController.playVideoById(
    this.dataSource, {
    required this.options,
  })  : dataSourceType = VideoSourceType.videoById,
        super(VideoPlayerValue(duration: Duration.zero));

  BrightcoveVideoPlayerController.playPlaylistById(
    this.dataSource, {
    required this.options,
  })  : dataSourceType = VideoSourceType.playlistById,
        super(VideoPlayerValue(duration: Duration.zero));

  final String dataSource;
  final VideoSourceType dataSourceType;
  final BrightcoveOptions options;

  bool _isDisposed = false;

  static const String kUninitializedTextureId = '';
  String _playerId = kUninitializedTextureId;

  StreamSubscription<VideoEvent>? _eventSubscription;

  Future _initialize() async {
    if (_playerId != kUninitializedTextureId) {
      return;
    }

    final dataSourceDescription =
        DataSource(dataSource: dataSource, sourceType: dataSourceType);
    _playerId =
        await _videoPlayerPlatform.create(dataSourceDescription, options);
    value = value.copyWith(isInitialized: true);

    void listener(VideoEvent event) {
      switch (event.eventType) {
        case VideoEventType.initialized:
          value = value.copyWith(
            size: event.size,
            duration: event.duration,
            isInitialized: event.duration != null,
          );
          break;
        case VideoEventType.playProgress:
          value = value.copyWith(
            position: Duration(milliseconds: event.currentPosition!.toInt()),
          );
          break;
        case VideoEventType.completed:
          pause().then((_) => seekTo(value.duration));
          break;
        case VideoEventType.bufferingStart:
          value = value.copyWith(isBuffering: true);
          break;
        case VideoEventType.bufferingEnd:
          value = value.copyWith(isBuffering: false);
          break;
        case VideoEventType.bufferingUpdate:
        case VideoEventType.unknown:
          break;
      }
    }

    void errorListener(Object obj) {
      value = VideoPlayerValue.erroneous(obj.toString());
    }

    _eventSubscription = _videoPlayerPlatform
        .videoEventsFor(_playerId)
        .listen(listener, onError: errorListener);
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) {
      return;
    }

    if (!_isDisposed) {
      _isDisposed = true;
      await _eventSubscription?.cancel();
      await _videoPlayerPlatform.dispose(_playerId);
    }
    _isDisposed = true;
    super.dispose();
  }

  Future setVolume(double volume) async {
    value = value.copyWith(volume: volume);
    await _videoPlayerPlatform.setVolume(_playerId, volume);
  }

  Future mute() async {
    await setVolume(0);
  }

  Future unMute() async {
    if (value.volume == 0) {
      await setVolume(100);
    }
  }

  Future play() async {
    if (value.isPlaying) return;
    value = value.copyWith(isPlaying: true);
    await _videoPlayerPlatform.play(_playerId);
  }

  Future pause() async {
    if (!value.isPlaying) return;
    value = value.copyWith(isPlaying: false);
    await _videoPlayerPlatform.pause(_playerId);
  }

  Future seekTo(Duration position) async {
    if (position > value.duration) {
      position = value.position;
    } else if (position < Duration.zero) {
      position = Duration.zero;
    }
    value = value.copyWith(position: position);
    await _videoPlayerPlatform.seekTo(_playerId, position);
  }

  @override
  void removeListener(VoidCallback listener) {
    if (!_isDisposed) {
      super.removeListener(listener);
    }
  }
}

class BrightcoveVideoPlayer extends StatefulWidget {
  const BrightcoveVideoPlayer(this.controller, {Key? key}) : super(key: key);

  final BrightcoveVideoPlayerController controller;

  @override
  State<BrightcoveVideoPlayer> createState() => _BrightcoveVideoPlayerState();
}

class _BrightcoveVideoPlayerState extends State<BrightcoveVideoPlayer> {
  _BrightcoveVideoPlayerState() {
    _textureIdUpdaterListener = () {
      final newTextureId = widget.controller._playerId;
      if (newTextureId != _playerId) {
        setState(() => _playerId = newTextureId);
      }
    };
  }

  late VoidCallback _textureIdUpdaterListener;

  late String _playerId;

  @override
  void initState() {
    super.initState();
    _playerId = BrightcoveVideoPlayerController.kUninitializedTextureId;
    widget.controller.addListener(_textureIdUpdaterListener);
    widget.controller._initialize();
  }

  @override
  void didUpdateWidget(BrightcoveVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.controller.removeListener(_textureIdUpdaterListener);
    _playerId = widget.controller._playerId;
    widget.controller.addListener(_textureIdUpdaterListener);
  }

  @override
  void deactivate() {
    super.deactivate();
    widget.controller.removeListener(_textureIdUpdaterListener);
  }

  @override
  Widget build(BuildContext context) {
    if (_playerId == BrightcoveVideoPlayerController.kUninitializedTextureId) {
      return Container();
    }
    return _VideoPlayerWithRotation(
      rotation: widget.controller.value.rotationCorrection,
      child: _videoPlayerPlatform.buildView(widget.controller._playerId),
    );
  }
}

class _VideoPlayerWithRotation extends StatelessWidget {
  const _VideoPlayerWithRotation(
      {Key? key, required this.rotation, required this.child})
      : super(key: key);
  final int rotation;
  final Widget child;

  @override
  Widget build(BuildContext context) => rotation == 0
      ? child
      : Transform.rotate(
          angle: rotation * math.pi / 180,
          child: child,
        );
}

extension DurationExt on Duration {
  String get getPaddedHours =>
      (inHours.remainder(60)).toString().padLeft(2, "0");

  String get getPaddedMinutes =>
      (inMinutes.remainder(60)).toString().padLeft(2, "0");

  String get getPaddedSeconds =>
      (inSeconds.remainder(60)).toString().padLeft(2, "0");

  String get convertToTime {
    if (inHours == 0) {
      return '$getPaddedMinutes:$getPaddedSeconds';
    }
    return '$getPaddedHours:$getPaddedMinutes:$getPaddedSeconds';
  }
}

/// Returns the [Duration] of a mm:ss formatted time [String].
/// For example '60:30', resulting in one hour and 30 seconds.
Duration parseDuration(String time) {
  final timeSplit = time.split(':');
  final minutes = int.tryParse(timeSplit.first) ?? 0;
  final seconds = int.tryParse(timeSplit.last) ?? 0;
  return Duration(minutes: minutes, seconds: seconds);
}
