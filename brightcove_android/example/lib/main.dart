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
      body: ListView(
        children: [
          PlayerWidget(
            key: UniqueKey(),
          ),
          PlayerWidget(
            key: UniqueKey(),
          ),
        ],
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
    return SizedBox(
      height: 250,
      child: Column(
        children: [
          Expanded(
            child: BrightcoveVideoPlayer(_controller),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  onPressed: _controller.play,
                  icon: const Icon(Icons.play_arrow_outlined)),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 1,
                  height: 24,
                  color: Colors.black,
                ),
              ),
              IconButton(
                  onPressed: _controller.pause, icon: const Icon(Icons.pause)),
            ],
          )
        ],
      ),
    );
  }
}
