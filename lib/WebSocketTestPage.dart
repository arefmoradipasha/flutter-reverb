import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketService {
  final String url;
  final String token;
  late WebSocketChannel channel;

  WebSocketService(this.url, this.token) {
    _connect();
  }

  void _connect() {
    channel = WebSocketChannel.connect(
      Uri.parse('$url?token=$token'),
    );

    channel.stream.listen(
      (message) {
        _handleMessage(message);
      },
      onDone: () {
        _reconnect();
      },
      onError: (error) {
        print('WebSocket error: $error');
        _reconnect();
      },
    );
  }

  void _handleMessage(String message) {
    // اینجا پیام دریافتی از سرور 
    print('Message from server: $message');
  }

  void _reconnect() async {
    await Future.delayed(Duration(seconds: 5));
    _connect();
  }

  void sendMessage(String message) {
    if (channel != null) {
      channel.sink.add(message);
    }
  }

  void dispose() {
    channel.sink.close(status.goingAway);
  }
}