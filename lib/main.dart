import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WebSocketDemo(),
    );
  }
}

class WebSocketDemo extends StatefulWidget {
  @override
  _WebSocketDemoState createState() => _WebSocketDemoState();
}

class _WebSocketDemoState extends State<WebSocketDemo> {
  final TextEditingController _controller = TextEditingController();
  late WebSocketChannel channel;
  String _connectionStatus = 'در حال اتصال';
  List<String> _messages = [];

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  void _connectWebSocket() {
    try {
      final wsUrl = 'ws://192.168.88.110:8080/app/hjyaqdg45tsxnq7dmanf';
      channel = IOWebSocketChannel.connect(wsUrl);

      // Subscribe to the channel
      final subscribeMessage = {
        'event': 'pusher:subscribe',
        'data': {'channel': 'test-channel'}
      };
      channel.sink.add(jsonEncode(subscribeMessage));

      channel.stream.listen(
        (message) {
          print('پیام دریافتی: $message');
          setState(() {
            _connectionStatus = 'متصل به وب‌سوکت';
            _messages.add('دریافت شد: $message');
          });
        },
        onError: (error) {
          print('خطای اتصال به وب‌سوکت: $error');
          setState(() {
            _connectionStatus = 'خطای اتصال: $error';
          });
        },
        onDone: () {
          print('اتصال وب‌سوکت بسته شد');
          setState(() {
            _connectionStatus = 'اتصال بسته شد';
          });
        },
      );
    } catch (e) {
      print('خطا در اتصال به وب‌سوکت: $e');
      setState(() {
        _connectionStatus = 'خطا در اتصال به وب‌سوکت: $e';
      });
    }
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      final sendMessage = {
        'event': "TestEvent",
        'data': {'message': _controller.text}
      };
      channel.sink.add(jsonEncode(sendMessage));
      setState(() {
        _messages.add('ارسال شد: ${_controller.text}');
        _controller.clear();
      });
    } else {
      setState(() {
        _connectionStatus = 'پیام نمی‌تواند خالی باشد';
      });
    }
  }

  @override
  void dispose() {
    channel.sink.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ارتباط با وب‌سوکت'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _connectionStatus,
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'پیام خود را وارد کنید'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _sendMessage,
              child: Text('ارسال پیام'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_messages[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
