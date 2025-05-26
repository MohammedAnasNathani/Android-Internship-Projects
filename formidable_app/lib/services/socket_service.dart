import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService extends ChangeNotifier {
  static final SocketService _instance = SocketService._internal();
  IO.Socket? _socket; // Made nullable

  SocketService._internal();

  static SocketService get instance => _instance;

  IO.Socket? get socket => _socket;

  void connectSocket() {
    _socket = IO.io('http://10.0.2.2:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    _socket!.connect();

    _socket!.on('connect', (_) {
      print('Socket connected');
    });

    _socket!.on('disconnect', (reason) {
      print('Socket disconnected. Reason: $reason');
    });

    _socket!.on('connect_error', (error) {
      print('Socket connection error: $error');
    });

    _socket!.on('error', (error) {
      print('Socket error: $error');
    });

    _socket!.on('form-updated', (data) {
      print('Form updated received: $data');
      notifyListeners();
    });
  }

  void joinForm(String formId) {
    if (_socket != null) {
      _socket!.emit('join-form', formId);
      print('join-form event emitted with formId: $formId');
    }
  }

  void emitFormUpdate(Map<String, dynamic> data) {
    if (_socket != null) {
      _socket!.emit('form-update', data);
      print('form-update event emitted with data: $data');
    }
  }

  void listenToFormUpdates(Function(dynamic) onFormUpdate) {
    if (_socket != null) {
      _socket!.on('form-updated', (data) {
        print('Form updated received: $data');
        onFormUpdate(data);
        notifyListeners();
      });
    }
  }

  void disconnectSocket() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
    }
  }
}