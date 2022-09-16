import 'package:brightcove_flutter/brightcove_flutter.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: const MyHomePage(title: 'Flutter Demo Home Page'),
  ));
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: PlayerWidget(
        key: UniqueKey(),
        videoId: '6312352211112',
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class PlayerWidget extends StatefulWidget {
  const PlayerWidget({Key? key, this.videoId}) : super(key: key);

  final String? videoId;

  @override
  State<PlayerWidget> createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> {
  late final BrightcoveVideoPlayerController _controller =
      BrightcoveVideoPlayerController.playVideoById(
    widget.videoId ?? '6311532572112',
    options: BrightcoveOptions(
      account: "6314458267001",
      policy:
          "BCpkADawqM3B3oh6cCokobfYe88EwiIADRJ0_8IuKI4GbwP4LN-MzKbgX40HDjJvBEon1ZRmX6krlKOjum8CfTjHuYMUebWTcPKlAZgxlp8H7JJJRNaqGJ9SAy-tTpV_qXAKrYHONp8PQ0m5",
    ),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned.fill(child: BrightcoveVideoPlayer(_controller)),
          _VideoPlayerControls(_controller),
        ],
      ),
    );
  }
}

class _VideoPlayerControls extends StatefulWidget {
  const _VideoPlayerControls(this.controller, {Key? key}) : super(key: key);

  final BrightcoveVideoPlayerController controller;

  @override
  State<_VideoPlayerControls> createState() => _VideoPlayerControlsState();
}

class _VideoPlayerControlsState extends State<_VideoPlayerControls> {
  BrightcoveVideoPlayerController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, child) {
        if (!value.isInitialized) {
          return Container();
        }
        return Container(
          height: 80,
          color: Colors.green,
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 32,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(value.position.convertToTime),
                    Expanded(
                      child: SeekBar(controller),
                    ),
                    Text(value.duration.convertToTime),
                  ],
                ),
              ),
              SizedBox(
                height: 32,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                          value.isPlaying ? Icons.pause : Icons.play_arrow),
                      onPressed:
                          value.isPlaying ? controller.pause : controller.play,
                    ),
                    IconButton(
                      icon: Icon(
                          !value.isMuted ? Icons.volume_off : Icons.volume_up),
                      onPressed:
                          value.isMuted ? controller.unMute : controller.mute,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SeekBar extends StatefulWidget {
  const SeekBar(this.controller, {Key? key}) : super(key: key);

  final BrightcoveVideoPlayerController controller;

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double? _value;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, value, child) {
        return LayoutBuilder(builder: (context, constraints) {
          return SizedBox(
            height: 8,
            width: constraints.maxWidth,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 8,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 8,
                ),
                thumbColor: Colors.white,
                activeTrackColor: Colors.orange,
                inactiveTrackColor: Colors.white,
                trackShape: const RectangularSliderTrackShape(),
              ),
              child: Slider(
                min: 0.0,
                value: _value ?? value.position.inMilliseconds.toDouble(),
                max: value.duration.inMilliseconds.toDouble(),
                onChangeStart: (value) => setState(() => _value = value),
                onChangeEnd: (value) {
                  widget.controller
                      .seekTo(Duration(milliseconds: value.toInt()));
                  _value = null;
                },
                onChanged: (value) {
                  setState(() => _value = value);
                },
              ),
            ),
          );
        });
      },
    );
  }
}
