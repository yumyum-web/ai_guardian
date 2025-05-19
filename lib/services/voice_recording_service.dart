import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class VoiceRecordingService {
  static final VoiceRecordingService _instance =
      VoiceRecordingService._internal();
  factory VoiceRecordingService() => _instance;
  VoiceRecordingService._internal();

  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  String? _currentFilePath;
  final StreamController<bool> _recordingController =
      StreamController<bool>.broadcast();

  Stream<bool> get isRecordingStream => _recordingController.stream;
  bool get isRecording => _isRecording;
  String? get currentFilePath => _currentFilePath;

  Future<void> startRecording() async {
    if (_isRecording) return;
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) throw Exception('No mic permission');
    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
    final filePath = '${dir.path}/$fileName';
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: filePath,
    );
    _isRecording = true;
    _currentFilePath = filePath;
    _recordingController.add(true);
  }

  Future<String?> stopRecording() async {
    if (!_isRecording) return null;
    final path = await _recorder.stop();
    _isRecording = false;
    _recordingController.add(false);
    return path;
  }

  Future<void> cancelRecording() async {
    if (!_isRecording) return;
    await _recorder.cancel();
    if (_currentFilePath != null) {
      final file = File(_currentFilePath!);
      if (await file.exists()) {
        await file.delete();
      }
    }
    _isRecording = false;
    _recordingController.add(false);
  }

  Future<List<FileSystemEntity>> listRecordings() async {
    final dir = await getApplicationDocumentsDirectory();
    final files =
        await dir.list().where((f) {
          // Exclude the file currently being recorded (if any)
          if (f.path.endsWith('.m4a')) {
            if (_isRecording &&
                _currentFilePath != null &&
                f.path == _currentFilePath) {
              return false;
            }
            return true;
          }
          return false;
        }).toList();
    return files;
  }

  Future<void> deleteRecording(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  void dispose() {
    _recordingController.close();
    _recorder.dispose();
  }
}
