import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SocketService {
  late IO.Socket _socket;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  void connect(String token) {
    _socket = IO.io('https://your-projectree-domain.vercel.app', 
      IO.OptionBuilder()
        .setTransports(['websocket'])
        .setExtraHeaders({'Authorization': 'Bearer $token'})
        .build()
    );

    _socket.onConnect((_) {
      _isConnected = true;
      print('Connected to socket server');
    });

    _socket.onDisconnect((_) {
      _isConnected = false;
      print('Disconnected from socket server');
    });
  }

  void disconnect() {
    _socket.disconnect();
    _isConnected = false;
  }

  void joinRoom(String roomId) {
    _socket.emit('join-room', roomId);
  }

  void leaveRoom(String roomId) {
    _socket.emit('leave-room', roomId);
  }

  void sendMessage(Map<String, dynamic> message) {
    _socket.emit('send-message', message);
  }

  void onMessage(Function(dynamic) callback) {
    _socket.on('new-message', callback);
  }

  void onTyping(Function(dynamic) callback) {
    _socket.on('typing', callback);
  }

  void sendTyping(String roomId, bool isTyping) {
    _socket.emit('typing', {'roomId': roomId, 'isTyping': isTyping});
  }
}

final socketServiceProvider = Provider<SocketService>((ref) {
  return SocketService();
});
