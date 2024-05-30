import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechRecognitionService {
    SpeechToText _speechToText = SpeechToText();
    bool _speechEnabled = false;
    String _lastWords = '';

    // Callback for when speech is recognized
    void Function(String)? onSpeechRecognized;

    // Initialize the speech-to-text service
    Future<void> initialize() async {
        _speechEnabled = await _speechToText.initialize();
    }
    
    // Start listening for speech
    Future<void> startListening() async {
        await _speechToText.listen(onResult: _onSpeechResult);
    }

    // Stop listening for speech
    Future<void> stopListening() async {
        await _speechToText.stop();
    }

    // Callback for when speech is recognized
    void _onSpeechResult(SpeechRecognitionResult result) {

        String recognizedWords = result.recognizedWords;
        if(recognizedWords.split(' ').isNotEmpty ) {
          _lastWords=recognizedWords.split(' ').last.toLowerCase();
        }
        print(_lastWords);
        // Invoke the callback to pass the recognized words to the UI
        onSpeechRecognized?.call(_lastWords);

    }
    void setLastWords(){
      _lastWords='';
      onSpeechRecognized?.call('');
    }
    // Get the last recognized words
    String get lastWords => _lastWords;

    // Check whether speech recognition is enabled
    bool get isSpeechEnabled => _speechEnabled;

    // Check whether the service is currently listening
    bool get isListening => _speechToText.isListening;
}
