import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'First Hidden App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ImageStreamPage(),
    );
  }
}

class ImageStreamPage extends StatefulWidget {
  const ImageStreamPage({super.key});

  @override
  State<ImageStreamPage> createState() => _ImageStreamPageState();
}

class _ImageStreamPageState extends State<ImageStreamPage> {
  final String wsUrl = "ws://178.63.171.244:8000/ws"; // آدرس سرور WebSocket
  late WebSocketChannel channel;

  Uint8List? imageData;
  String? filename;

  @override
  void initState() {
    super.initState();
    channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    channel.stream.listen(
      (message) {
        final decoded = jsonDecode(message);
        setState(() {
          filename = decoded['filename'];
          imageData = base64Decode(decoded['data']);
        });
      },
      onError: (error) {
        print("❌ WebSocket error: $error");
      },
      onDone: () {
        print("⚠️ WebSocket closed!");
      },
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('First Hidden Images')),
      body: Center(
        child: imageData != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(filename ?? "", style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  Image.memory(imageData!),
                ],
              )
            : const Text(
                'در انتظار تصویر جدید...',
                style: TextStyle(fontSize: 18),
              ),
      ),
    );
  }
}
