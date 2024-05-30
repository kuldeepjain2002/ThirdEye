// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:flutter/services.dart';

// void main() async {
//   // Ensure that Flutter is initialized before retrieving cameras
//   WidgetsFlutterBinding.ensureInitialized();
//   // Fetch the list of available cameras
//   final cameras = await availableCameras();
//   // Get a specific camera from the list of available cameras.
//   final firstCamera = cameras.first;

//   final FlutterTts flutterTts = FlutterTts();

//   await flutterTts.speak(
//       "Welcome to the your third eye. Say Camera for opening camera , Repeat for repeating the instructions");

//   runApp(MyApp(firstCamera: firstCamera));
// }

// class MyApp extends StatelessWidget {
//   final CameraDescription firstCamera;
//   const MyApp({Key? key, required this.firstCamera}) : super(key: key);

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Hello World Demo Application',
//       theme: ThemeData(
//         primarySwatch: Colors.lightGreen,
//       ),
//       routes: {
//         '/': (context) => HomeScreen(title: 'Third Eye'),
//         '/camera': (context) => TakePictureScreen(camera: firstCamera),
//         // '/details': (context) => DetailScreen(),
//       },
//     );
//   }
// }

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({Key? key, required this.title}) : super(key: key);
//   final String title;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Center(
//             child: Column(
//               children: [
//                 Text(
//                   title,
//                   textAlign: TextAlign.center,
//                 ),
//                 SizedBox(height: 5), // Add some space between title and logo
//               ],
//             ),
//           ),
//         ),
//         body: Center(
//             child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             // Pushes the message towards the top
//             Text(
//               'Welcome to the app, follow these instructions:',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 10), // Add some space between text and button
//             Text(
//               '1. Say "Open camera" to open the camera.',
//               style: TextStyle(fontSize: 16),
//             ),
//             Text(
//               '2. Say "Repeat" to repeat the instructions.',
//               style: TextStyle(fontSize: 16),
//             ),
//             // SizedBox(height: 20),
//             Spacer(),
//             Text(
//               'Open camera to get details',
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pushNamed(context, '/camera');
//                 WidgetsFlutterBinding.ensureInitialized();
//               },

//               // style: ElevatedButton.styleFrom(
//               //   backgroundColor: Colors.blue,
//               //   elevation: 4,
//               // ),
//               child: Text(
//                 "📸",
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//             ),
//             Spacer(),
//           ],
//         )));
//   }
// }

// // A screen that allows users to take a picture using a given camera.
// class TakePictureScreen extends StatefulWidget {
//   const TakePictureScreen({
//     super.key,
//     required this.camera,
//   });

//   final CameraDescription camera;

//   @override
//   TakePictureScreenState createState() => TakePictureScreenState();
// }

// class TakePictureScreenState extends State<TakePictureScreen> {
//   late CameraController _controller;
//   late Future<void> _initializeControllerFuture;

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

//     // Next, initialize the controller. This returns a Future.
//     _initializeControllerFuture = _controller.initialize();
//   }

//   @override
//   void dispose() {
//     // Dispose of the controller when the widget is disposed.
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
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

// // A widget that displays the picture taken by the user.
// class DisplayPictureScreen extends StatelessWidget {
//   final String imagePath;
//   DisplayPictureScreen({super.key, required this.imagePath});

//   Future<dynamic> apiCall(String imgPath) async { 
//     print((await http.get(Uri.parse(imgPath))).bodyBytes);
//     http.Response response = await http.post(Uri.http('172.18.40.68:6969', '/predict'),
//         body: jsonEncode((await http.get(Uri.parse(imgPath))).bodyBytes));
//     if (response.statusCode == 200) {
//       String data = response.body;
//       var decodedData = jsonDecode(data);
//       return decodedData;
//     } else {
//       return response.statusCode;
//     }
//   }
//   String generatedCaption = "sd";
//   // generatedCaption = "helloi";
//   @override
//   Widget build(BuildContext context) {
//     apiCall(imagePath).then((dynamic result) {
//       setState((){
//       generatedCaption = "this is genrted caption";
//       });
//       print(result);

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