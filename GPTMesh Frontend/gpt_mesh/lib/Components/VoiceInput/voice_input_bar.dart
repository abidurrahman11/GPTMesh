import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceInputBar extends StatefulWidget {
  // parameters
  final Function (String) onSendText;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;

  // constructor
  const VoiceInputBar({
    super.key,
    required this.onSendText,
    required this.onStartRecording,
    required this.onStopRecording,
  });

  @override
  State<VoiceInputBar> createState() => VoiceInputBarState();
}

class VoiceInputBarState extends State<VoiceInputBar> with SingleTickerProviderStateMixin {
  // states, controllers and functions
  final TextEditingController _inputController = TextEditingController();
  late AnimationController _animationController; // initialize later
  // speech to text
  late stt.SpeechToText _speech;
  bool _isListening = false;
  // audio recording
  bool _isRecording = false;
  final AudioRecorder _recorder = AudioRecorder();
  String? _audioPath;
  // recording timer
  int _seconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _inputController.addListener(() {
      setState(() {}); // update the UI when the text changes
    });

    _speech = stt.SpeechToText();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      lowerBound: 1.0,
      upperBound: 1.3,
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _sendText() {
    if (_inputController.text.trim().isEmpty) {
      return;
    }
    // pass the text, which will be used in API call
    widget.onSendText(_inputController.text.trim());
    _inputController.clear();
  }

  // record handling functions
  Future<bool> _startRecording() async {
    if (await _recorder.hasPermission()) {
      final dir = await getTemporaryDirectory();
      _audioPath = '${dir.path}/recording.m4a';

      await _recorder.start(
        const RecordConfig(),
        path: _audioPath!,
      );
      return true;
    } else {
      // Show permission denied message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is required to record audio')),
        );
      }
      return false;
    }
  }

  void _startTimer() {
    _seconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _seconds = 0;
  }

  Future<String?> _stopRecording() async {
    final path = await _recorder.stop();
    return path;
  }

  void _toggleRecording () async {
    if (_isListening) {
      // Stop recording
      final path = await _stopRecording();
      _stopListening();
      _stopTimer();
      setState(() {
        _isRecording = false;
      });
      widget.onStopRecording();
      // stop animation
      _animationController.stop();
      _animationController.reset();
      // Process the audio if path is not null
      if (path != null) {
        // await _sendAudioToBackend(path);
      }
    } else {
      // Start recording
      bool started = await _startRecording();
      _startListening();
      if (started) {
        setState(() {
          _isRecording = true;
        });
        _startTimer();
        widget.onStartRecording(); 
        // show animation while recording
        _animationController.repeat(reverse: true);
      }
    }
  }

  // start listening for speech to text
  Future<void> _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        print('Speech status: $status');
        if (status == 'done') {
          _stopListening();
        }
      },
      onError: (error) {
        print("Error: $error");
      },
    );
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            setState(() {
            appendTextFromVoice(result.recognizedWords);
            // keep cursor at end of new text
            _inputController.selection = TextSelection.fromPosition(TextPosition(offset: _inputController.text.length));
          });
          }
        },
      );
    }
  }

  // stop listening for speech to text
  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  void appendTextFromVoice(String text) {
    final currentText = _inputController.text;

    final newText = currentText.isEmpty ? text : '$currentText $text';
    _inputController.text = newText;
    _inputController.selection = TextSelection.fromPosition(TextPosition(offset: _inputController.text.length));
  }

  // private widgets for text field and recording bar
  Widget _buildTextField() {
    return TextField(
      controller: _inputController,
      enabled: !_isRecording, // disable text input when recording
      decoration: const InputDecoration(
        hintText: "Type something...",
        border: InputBorder.none,
      ),
      textInputAction: TextInputAction.send,
      onSubmitted: (_) => _sendText(),
    );
  }
  String get formattedTime {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
  // this will be shown when the user is recording
  Widget _buildRecordingBar(ThemeData theme) {
    return Row(
      children: [
        Icon(Icons.graphic_eq, color: theme.colorScheme.primary),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            "Listening...",
            style: theme.textTheme.bodyMedium,
          ),
        ),

        const SizedBox(width: 8),

        // optional timer
        Text(formattedTime),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        // container of the text and voice inputs
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ]
          ),
          // place the text field and voice button
          child: Row(
            children: [
              // show text feld when not recording, and show recording bar when recording
              Expanded(
                child: _isRecording ? _buildRecordingBar(theme) : _buildTextField(),
              ),

              // gap
              SizedBox(width: 8,),

              // voice button
              GestureDetector(
                onTap: _toggleRecording,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      // mic animation
                      scale: _isRecording ? _animationController.value : 1.0,

                      // mic button
                      child: Row(
                        children: [
                          // always show record button, and show send button when there is text
                          Container(
                            padding: EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isRecording ? Colors.red : theme.colorScheme.primary,
                            ),
                            child: Icon(
                              _isRecording ? Icons.stop : Icons.mic,
                              color: Colors.white,
                            ),
                          ),

                          // show send button when there is text
                          if (!_isRecording && _inputController.text.trim().isNotEmpty) ...[
                            SizedBox(width: 8,), // gap
                            GestureDetector(
                              onTap: _sendText,
                              child: Container(
                                padding: EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.colorScheme.primary,
                                ),
                                child: Icon(
                                  Icons.send,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ]
                        ],
                      )
                    );
                  }
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}