import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter/material.dart';
import 'dart:async';

const backgroundColor = Color(0xFF05151C);

void main() async {
  Gemini.init(apiKey: 'AIzaSyD6zkAwfdg8hlZiFlN2-9UpkSh-pAgP2Pk');
  // Ensure that Flutter is initialized before retrieving cameras
  WidgetsFlutterBinding.ensureInitialized();
  var camera = (await availableCameras()).first;
  final FlutterTts flutterTts = FlutterTts();
  await flutterTts.speak(
      "Welcome to the your third eye. Say Camera for opening camera , Repeat for repeating the instructions. To capture the image say capture.");
  SpeechToText speechToText = SpeechToText();
  await speechToText.initialize();
  runApp(MyApp(camera: camera, speechToText: speechToText));
}

Future<String> sendUserMessage(String message,String imagePath) async {
    final gemini = Gemini.instance;
    String output = 'Wait....';
    Uint8List bytes = (await http.get(Uri.parse(imagePath))).bodyBytes;
    List<Uint8List> imageList=[bytes];

    try {
         
         final value = await gemini.textAndImage(text:message,images:imageList);
            // If the stream produces multiple outputs, this code will be run for each output
            output = value?.output as String;
    } catch (e) {
        print('streamGenerateContent exception');
        print(e);
        // You may choose how to handle the exception and what value to return in case of an error
        output = e.toString();
    }

    return output;
}

// void onSpeechRecognizedCallback(String recognizedWords) {
//     // Print the recognized words
//     print('Recognized Words: $recognizedWords');
// }
class MyApp extends StatelessWidget {
  final CameraDescription camera;
  final SpeechToText speechToText;
  // final FlutterTts flutterTts;
  const MyApp({Key? key, required this.camera, required this.speechToText}) : super(key: key);
  final imagePath = "", caption = "";

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hello World Demo Application',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
        scaffoldBackgroundColor: backgroundColor,
        textTheme: TextTheme(
          // Set the default text color to white
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white),
          headlineLarge: TextStyle(color: Colors.white),
          headlineMedium: TextStyle(color: Colors.white),
          headlineSmall: TextStyle(color: Colors.white),
          displayMedium: TextStyle(color: Colors.white),
          displayLarge: TextStyle(color: Colors.white),
          displaySmall: TextStyle(color: Colors.white),

          // overline: TextStyle(color: Colors.white),
        ),
      ),
      routes: {
        '/': (context) => HomeScreen(speechToText),
        '/camera': (context) => TakePictureScreen(camera, speechToText),
        '/chat': (context) => ChatScreen(imagePath, caption)
        // '/details': (context) => DetailScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  SpeechToText speechToText;
  HomeScreen(this.speechToText);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{
  bool _speechEnabled = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() async {
    _speechEnabled = true;
    await widget.speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  // void _initSpeech() async {
  //   print("Initialising speech");
    
  //   // print(!_speechToText.isListening);
  //   // if(!_speechToText.isListening)
  //     await _speechToText.listen(onResult: _onSpeechResult);
  //   setState(() {});
  // }

  void _onSpeechResult(SpeechRecognitionResult result) async {
    var recognizedWords = result.recognizedWords;
    if (recognizedWords.split(' ').isNotEmpty && recognizedWords.split(' ').last.toLowerCase() == "camera") {
      // print("Stopping listening service");
      // await widget.speechToText.stop();
      Navigator.pushNamed(context, "/camera");
    } 
    // else if (recognizedWords.contains("repeat")) {
    //   // await flutterTts.speak("Say Camera for opening camera , Repeat for repeating the instructions");
    // }
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  @override
  Widget build(BuildContext context) {
    // _speechToText.onSpeechRecognized = (String recognizedWords) async {
    //   // Provide context to the callback function
    //   // await onSpeechRecognizedCallback(recognizedWords, context, FlutterTts());
    //   if (recognizedWords.split(' ').isNotEmpty && recognizedWords.split(' ').last.toLowerCase() == "camera") {
    //     speechService.stopListening();
    //     speechService.setLastWords();
    //     Navigator.pushNamed(context, "/camera");
    //   } else if (recognizedWords.contains("repeat")) {
    //     // await flutterTts.speak(
    //     //     "Say Camera for opening camera , Repeat for repeating the instructions");
    //   } else if (recognizedWords.contains("click photo")) {}
    // };
    // print(speechService.lastWords);
    // final words = speechService.lastWords.split(' ');
    // if (words.isNotEmpty && words.last.toLowerCase() == "camera") {
    //   Navigator.pushNamed(context, '/camera');
    // }
    // speechService.onSpeechRecognized = (recognizedWords) => onSpeechRecognizedCallback(recognizedWords, context);
    return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          title: Center(
            child: Column(
              children: [
                Text(
                  "Home Page",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white, // Set the text color to white
                  ),
                ),
                SizedBox(height: 5), // Add some space between title and logo
              ],
            ),
          ),
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // // Pushes the message towards the top
            SizedBox(
              width: double.infinity, // Full width
              height: MediaQuery.of(context).size.height * 0.3, // 30% height
              child: Image.asset(
                '../assets/thirdeye.jpg', // Replace with your image path
                fit: BoxFit.cover, // Fills the container
              ),
            ),
            Text(
              'Welcome to the app, follow these instructions:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10), // Add some space between text and button
            Text(
              '1. Say "camera" to open the camera.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            Text(
              '2. Say "Repeat" to repeat the instructions.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            Text(
              '3. Say "Capture" to click the photo',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            // SizedBox(height: 20),
            Spacer(),
            Text(
              'Open camera to get details',
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/camera');

                WidgetsFlutterBinding.ensureInitialized();
              },
              style: ElevatedButton.styleFrom(fixedSize: Size(200, 50)),
              child: Text(
                "📸",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.all(16),
              child: Text(
                'Recognized words:',
                style: TextStyle(fontSize: 20.0),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                child: Text(
                  // If listening is active show the recognized words
                  widget.speechToText.isListening
                      ? '$_lastWords'
                      // If listening isn't active but could be tell the user
                      // how to start it, otherwise indicate that speech
                      // recognition is not yet ready or not supported on
                      // the target device
                      : _speechEnabled
                          ? 'Tap the microphone to start listening...'
                          : 'Speech not available',
                ),
              ),
            ),
          ],
        )));
  }
}

class TakePictureScreen extends StatefulWidget {
  dynamic camera;
  SpeechToText speechToText;
  TakePictureScreen(this.camera, this.speechToText);

  @override
  _TakePictureScreenState createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen>{
  // SpeechToText _speechToText = SpeechToText();
  dynamic _speechEnabled;
  String _lastWords = '';
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late BuildContext _context;

  @override
  void initState() {
    _initCamera();
    _startListening();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startListening() async {
    _speechEnabled = true;
    print("Here in camera capture");
    await widget.speechToText.initialize();
    await widget.speechToText.listen(onResult: _onSpeechResult);
    print(widget.speechToText.isListening);
    setState(() {});
  }

  void _initCamera() {
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.ultraHigh,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  // void _initSpeech() async {
  //   print("Enabling speech");
  //   await _speechToText.initialize();
  //   _speechEnabled = true;
  // }

  void _onSpeechResult(SpeechRecognitionResult result) async {
    print(result.recognizedWords);
    print("Speech enabled is ");
    print(_speechEnabled);
    var recognizedWords = result.recognizedWords;
    if (recognizedWords.split(' ').isNotEmpty && recognizedWords.split(' ').last.toLowerCase() == "capture" && _speechEnabled) {
      print("Stopping listening service");
      setState(() {
        _speechEnabled = false;
      });
      await widget.speechToText.stop();
      _controller.takePicture().then((image) {
        Navigator.of(_context).push(
          MaterialPageRoute(
            builder: (_context) => DisplayPictureScreen(imagePath: image.path),
          ),
        );
      }).catchError((error) {
        print(error);
      });
    }
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  @override
  Widget build(BuildContext context){
    _context = context;
    // _startListening();
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(title: const Text('Take a picture')),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
        
          try {
            await _initializeControllerFuture;

            final image = await _controller.takePicture();
            print("imaaaage");
            print(image);
            print("imaaaagepathhhhhh");
            print(image.path);
            if (!context.mounted) return;

            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  imagePath: image.path,
                ),
              ),
            );
          } catch (e) {
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

// // A screen that allows users to take a picture using a given camera.
// class TakePictureScreen extends StatefulWidget {
//   const TakePictureScreen({
//     super.key,
//     required this.camera,
//     required this.speechService,
//   });
//   final SpeechRecognitionService speechService;
//   final CameraDescription camera;

//   @override
//   TakePictureScreenState createState() => TakePictureScreenState();
// }

// class TakePictureScreenState extends State<TakePictureScreen> {
//   late CameraController _controller;
//   late Future<void> _initializeControllerFuture;
//   late SpeechRecognitionService speechService;
//   @override
//   void initState() {
//     super.initState();
//     // To display the current output from the Camera,
//     // create a CameraController.
//     _controller = CameraController(
//       // Get a specific camera from the list of available cameras.
//       widget.camera,

//       // Define the resolution to use.
//       ResolutionPreset.medium,
//     );
//     speechService = widget.speechService;
//     // speechService.initialize();
//     if (!speechService.isListening) {
//       speechService.startListening();
//     }

//     // Next, initialize the controller. This returns a Future.
//     _initializeControllerFuture = _controller.initialize();
//   }

//   @override
//   void dispose() {
//     // Dispose of the controller when the widget is disposed.
//     _controller.dispose();
//     super.dispose();
//   }

//   void onSpeechRecognizedCallback(
//       String recognizedWords, BuildContext context) {
//     if (recognizedWords.contains("click")) {
//       speechService.setLastWords();
//       _controller.takePicture().then((image) {
//         if (!context.mounted) return;
//         Navigator.of(context).push(
//           MaterialPageRoute(
//             builder: (context) => DisplayPictureScreen(imagePath: image.path),
//           ),
//         );
//       }).catchError((error) {
//         print(error);
//       });
//     }
//     // if (recognizedWords.contains("camera")) {
//     //   Navigator.pushNamed(context, "/camera");
//     // } else if (recognizedWords.contains("repeat")) {
//     //   // await flutterTts.speak(
//     //   //     "Say Camera for opening camera , Repeat for repeating the instructions");
//     // } else if (recognizedWords.contains("click photo")) {}
//   }

//   @override
//   Widget build(BuildContext context) {
//     speechService.onSpeechRecognized = (String recognizedWords) {
//       // Provide context to the callback function
//       onSpeechRecognizedCallback(recognizedWords, context);
//     };
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       appBar: AppBar(title: const Text('Take a picture')),
//       // You must wait until the controller is initialized before displaying the
//       // camera preview. Use a FutureBuilder to display a loading spinner until the
//       // controller has finished initializing.
//       body: FutureBuilder<void>(
//         future: _initializeControllerFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             // If the Future is complete, display the preview.
//             return CameraPreview(_controller);
//           } else {
//             // Otherwise, display a loading indicator.
//             return const Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         // Provide an onPressed callback.
//         onPressed: () async {
//           // Take the Picture in a try / catch block. If anything goes wrong,
//           // catch the error.
//           try {
//             // Ensure that the camera is initialized.
//             await _initializeControllerFuture;

//             // Attempt to take a picture and get the file `image`
//             // where it was saved.
//             final image = await _controller.takePicture();

//             if (!context.mounted) return;

//             // If the picture was taken, display it on a new screen.
//             await Navigator.of(context).push(
//               MaterialPageRoute(
//                 builder: (context) => DisplayPictureScreen(
//                   // Pass the automatically generated path to
//                   // the DisplayPictureScreen widget.
//                   imagePath: image.path,
//                 ),
//               ),
//             );
//           } catch (e) {
//             // If an error occurs, log the error to the console.
//             print(e);
//           }
//         },
//         child: const Icon(Icons.camera_alt),
//       ),
//     );
//   }
// }

// A widget that displays the picture taken by the user.
// class DisplayPictureScreen extends StatelessWidget {
//   final String imagePath;

//   DisplayPictureScreen({super.key, required this.imagePath});
//   Future<dynamic> apiCall(String imgPath) async {
//     print((await http.get(Uri.parse(imgPath))).bodyBytes);
//     http.Response response = await http.post(Uri.http('http://dnd5eapi.co/api/conditions/blinded', '/predict'),
//         body: jsonEncode((await http.get(Uri.parse(imgPath))).bodyBytes));
//     if (response.statusCode == 200) {
//       String data = response.body;
//       var decodedData = jsonDecode(data);
//       return decodedData;
//     } else {
//       return response.statusCode;
//     }}

//     String apiUrl = 'https://jsonplaceholder.typicode.com/posts';

//   // Make an HTTP GET request to the sample API endpoint
//   http.Response response = await http.get(Uri.parse(apiUrl));

//   // Check if the response status code is 200 (success)
//   if (response.statusCode == 200) {
//     // Parse the JSON data from the response body
//     List<dynamic> data = jsonDecode(response.body);

//     // Return the data
//     return data;
//   } else {
//     // If the request failed, return the response status code
//     return response.statusCode;
//   }
//   }
//   String generatedCaption = "sd";
//   @override
//   Widget build(BuildContext context) {
//     apiCall(imagePath).then((dynamic result) {
//       // setState((){
//       generatedCaption = "this is genrted caption";
//       print("inside api");
//       print(generatedCaption);
//       // print(result);

//     });

//     return Scaffold(
//       appBar: AppBar(title: const Text('Display the Picture')),
//       // The image is stored as a file on the device. Use the `Image.file`
//       // constructor with the given path to display the image.
//       body: SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           // Display the image
//           Image.network(imagePath),
//           // Display the caption text
//           Padding(
//             padding: const EdgeInsets.all(2.0),
//             child: Text(
//               generatedCaption,
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//           ),
//         ],
//       ),
//     ),
//     );
//   }
// }

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;

  DisplayPictureScreen({Key? key, required this.imagePath}) : super(key: key);
  // Future<dynamic> apiCall(String imgPath) async {
  //   print((await http.get(Uri.parse(imgPath))).bodyBytes);
  //   http.Response response = await http.post(Uri.http('172.18.40.68:', '/predict'),
  //       body: jsonEncode((await http.get(Uri.parse(imgPath))).bodyBytes));
  //   if (response.statusCode == 200) {
  //     String data = response.body;
  //     var decodedData = jsonDecode(data);
  //     return decodedData;
  //   } else {
  //     return response.statusCode;
  //   }}

  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  dynamic generatedCaption = "Generating caption...";

  @override
  void initState() {
    super.initState();
    // Call the API to get the generated caption when the widget initializes
    apiCall(widget.imagePath).then((dynamic result) {
      // Update the generatedCaption using setState to trigger a rebuild
      setState(() {
        // Here you can set the generated caption based on the API result
        print(result);

        generatedCaption = result["caption"];
      });
    });
  }

  Future<dynamic> apiCall(String imgPath) async {
    var request = await http.MultipartRequest(
        'POST', Uri.http('172.18.40.68:6969', '/predict'));
    Map<String, String> headers = {"Content-type": "multipart/form-data"};
    Uint8List bytes = (await http.get(Uri.parse(imgPath))).bodyBytes;
    request.files.add(http.MultipartFile.fromBytes(
      'image',
      bytes.cast(),
      filename: imgPath.split('/').last,
    ));
    request.headers.addAll(headers);
    // print("request: " + request.toString());
    http.StreamedResponse res = await request.send();
    var finalString = await res.stream.transform(utf8.decoder).join();
    dynamic jsonResponse = jsonDecode(finalString);

    final FlutterTts flutterTts = FlutterTts();
    // final SpeechRecognitionService speechService = SpeechRecognitionService();
    print(jsonResponse["caption"]);
    await flutterTts.speak(jsonResponse["caption"]);

    return jsonResponse;
    // print((await http.get(Uri.parse(imgPath))).bodyBytes);
    // http.Response response = await http.post(Uri.http('172.18.40.68:6969', '/predict'),
    //     body: jsonEncode((await http.get(Uri.parse(imgPath))).bodyBytes));
    // if (response.statusCode == 200) {
    //   String data = response.body;
    //   var decodedData = jsonDecode(data);
    //   return decodedData;
    // } else {
    //   return response.statusCode;
    // }
  }
// Future<dynamic> apiCall(String imgPath) async {
//   // Simulate an API call by waiting for a short duration
//   await Future.delayed(Duration(seconds: 5));

//   // Define a sample response
//   dynamic sampleResponse = {
//     "caption": "Two men standing in a room with one holding a blue phone"
//   };

//   final FlutterTts flutterTts = FlutterTts();
  
//   // Convert the sample response caption to speech and play it
//   await flutterTts.speak(sampleResponse["caption"]);

//   // Return the sample response
//   return sampleResponse;
// }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Display the image using Image.file with the image path
            Image.network(widget.imagePath),
            // Display the caption text
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                generatedCaption,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_context) => ChatScreen(widget.imagePath,  generatedCaption),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(fixedSize: Size(200, 50)),
              child: Text(
                "Lets talk",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  dynamic imagePath, caption;
  SpeechToText speechToText = SpeechToText();
  
  ChatScreen(this.imagePath, this.caption);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>{
  List<String> chatHistory = [];
  late bool _speechEnabled;
  final TextEditingController _textController = TextEditingController();
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() async {
    _speechEnabled = true;
    await widget.speechToText.initialize();
    await widget.speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) async {
    var recognizedWords = result.recognizedWords;
    print(result.recognizedWords);
    if (recognizedWords.split(' ').isNotEmpty){ 
      if(recognizedWords.split(' ').last.toLowerCase() == "stop") {
        _speechEnabled = false;
        print("Stopping listening service");
        await widget.speechToText.stop();
      }
      else if(recognizedWords.split(' ').last.toLowerCase() == "enter") {
        _speechEnabled = false;
        _handleSendMessage();
        _lastWords = recognizedWords;
      }
      else{
        List<String> recognizedWordsList = recognizedWords.split(" ");
        List<String> lastWordsList = _lastWords.split(" ");
        
        List<String> currentWordsList = [];
        
        // Add words from recognizedWordsList that are not in lastWordsList
        for (int i = lastWordsList.length; i < recognizedWordsList.length; i++) {
          currentWordsList.add(recognizedWordsList[i]);
        }
        
        String finalText = currentWordsList.join(" ");
        print(finalText); // Output: "am rajat
        _textController.text = finalText;
      }
    }
    if (recognizedWords.split(' ').isNotEmpty && !_speechEnabled && recognizedWords.split(' ').last.toLowerCase() == "next"){
      _speechEnabled = true;
    }
  }

  Future<void> _handleSendMessage() async {
    final message = _textController.text.trim();
    if (message.isNotEmpty) {
      setState(() {
        chatHistory.add(message);
        _textController.text = '';
      });
      final response = await sendUserMessage(message,widget.imagePath);
      final FlutterTts flutterTts = FlutterTts();
      await flutterTts.speak(response);
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
          title: Text('Q/A'),
        ),
        body: Column(
          children: [
            Image.network(widget.imagePath),
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
