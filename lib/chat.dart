// AIzaSyD6zkAwfdg8hlZiFlN2-9UpkSh-pAgP2Pk
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter/material.dart';
import 'dart:async';

// Replace with the actual channel name you define in your Kotlin code

void main() {

  /// Add this line
  Gemini.init(apiKey: 'AIzaSyD6zkAwfdg8hlZiFlN2-9UpkSh-pAgP2Pk');

  runApp(MyApp());
}

class GeminiSingleton {
    static final GeminiSingleton _instance = GeminiSingleton._internal();

    late final Gemini gemini;

    factory GeminiSingleton() {
        return _instance;
    }

    GeminiSingleton._internal() {
        // Initialize Gemini instance with API key
        gemini = Gemini.instance;
    }

    static Gemini get instance => _instance.gemini;
}

Future<String> sendUserMessage(String message) async {
    final gemini = Gemini.instance;
    String output = 'Khushboo';

    try {
        await for (var value in gemini.streamGenerateContent(message)) {
            // If the stream produces multiple outputs, this code will be run for each output
            output = value.output as String;
        }
    } catch (e) {
        print('streamGenerateContent exception');
        print(e);
        // You may choose how to handle the exception and what value to return in case of an error
        output = e.toString();
    }

    return output;
}
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<String> chatHistory = [];
  final TextEditingController _textController = TextEditingController();
  
  Future<void> _handleSendMessage() async {
    final message = _textController.text.trim();
    if (message.isNotEmpty) {
      setState(() {
        chatHistory.add(message);
        _textController.text = '';
      });
      final response = await sendUserMessage(message);
      setState(() {
        chatHistory.add(response);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Chatbot'),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: chatHistory.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(chatHistory[index]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(hintText: 'Type your message'),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _handleSendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}