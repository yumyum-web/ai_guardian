import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:ai_guardian/services/voice_recording_service.dart';

class VoiceRecordingsScreen extends StatefulWidget {
  const VoiceRecordingsScreen({super.key});

  @override
  State<VoiceRecordingsScreen> createState() => _VoiceRecordingsScreenState();
}

class _VoiceRecordingsScreenState extends State<VoiceRecordingsScreen> {
  List<FileSystemEntity> _recordings = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _playingPath;

  @override
  void initState() {
    super.initState();
    _loadRecordings();
  }

  Future<void> _loadRecordings() async {
    final files = await VoiceRecordingService().listRecordings();
    setState(() {
      _recordings =
          files..sort(
            (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
          );
    });
  }

  Future<void> _playRecording(String path) async {
    await _audioPlayer.stop();
    await _audioPlayer.play(DeviceFileSource(path));
    setState(() {
      _playingPath = path;
    });
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _playingPath = null;
      });
    });
  }

  Future<void> _deleteRecording(String path) async {
    await VoiceRecordingService().deleteRecording(path);
    await _audioPlayer.stop();
    setState(() {
      _playingPath = null;
    });
    _loadRecordings();
  }

  void _showDownloadSuccess(String path) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Downloaded to $path',
          style: const TextStyle(color: Colors.white),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Recordings')),
      body:
          _recordings.isEmpty
              ? const Center(child: Text('No recordings found.'))
              : ListView.builder(
                itemCount: _recordings.length,
                itemBuilder: (context, index) {
                  final file = _recordings[index];
                  final fileName = file.path.split('/').last;
                  final isPlaying = _playingPath == file.path;
                  return ListTile(
                    title: Text(fileName),
                    subtitle: Text(
                      File(file.path).statSync().modified.toString(),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
                          onPressed: () {
                            if (isPlaying) {
                              _audioPlayer.stop();
                              setState(() => _playingPath = null);
                            } else {
                              _playRecording(file.path);
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () async {
                            final downloadDir = Directory(
                              '/storage/emulated/0/Download/AI Guardian',
                            );
                            if (!await downloadDir.exists()) {
                              await downloadDir.create(recursive: true);
                            }
                            await File(
                              file.path,
                            ).copy('${downloadDir.path}/$fileName');
                            _showDownloadSuccess(
                              'Successfully saved to Downloads',
                            );
                          },
                          tooltip: 'Download',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteRecording(file.path),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
