import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

Future<void> main() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AudioPlayer _player;
  final _playlist = ConcatenatingAudioSource(children: [
    AudioSource.uri(
      Uri.parse("asset:///audio/nature.mp3"),
      tag: MediaItem(
        id: '0',
        album: "Public Domain",
        title: "Nature Sounds",
        artUri: Uri.parse(
            "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
      ),
    ),
  ]);

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _init();
    _player.positionStream.listen((event) {
      setState(() {});
    });
  }

  Future<void> _init() async {
    await _player.setAudioSource(_playlist);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> setYoutubeAudio() async {
    while (_playlist.length > 0) {
      _playlist.removeAt(0);
    }

    // https://music.youtube.com/watch?v=1vrEljMfXYo
    String vid = '1vrEljMfXYo';
    var yt = YoutubeExplode();
    var video = await yt.videos.get(vid);
    var audioUrl = (await yt.videos.streamsClient.getManifest(vid))
        .audioOnly
        .where((streamInfo) => streamInfo.container.name == 'mp4')
        .withHighestBitrate()
        .url;
    log(audioUrl.toString());

    await _playlist.add(AudioSource.uri(
      audioUrl,
      tag: MediaItem(
        id: vid,
        title: video.title,
        album: 'test',
        artist: video.author,
        artUri: Uri.parse(video.thumbnails.lowResUrl),
      ),
    ));

    _player.play();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
            child: Text('Duration: ${_player.duration.toString()}\n'
                'Position: ${_player.position}')),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.play_arrow),
          onPressed: setYoutubeAudio,
        ),
      ),
    );
  }
}
