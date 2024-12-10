import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_constants.dart';
import '../utils/api_clients.dart';
import '../controllers/hiveController/hive_controller.dart';
import 'package:signalr_core/signalr_core.dart';

class ChatService {
  final Ref ref;
  HubConnection? _hubConnection;
  bool _isConnecting = false;
  final void Function(String content, int conversationId, int targetId, List<String> attachments)? onMessageReceived;

  ChatService(this.ref, {this.onMessageReceived});

  Future<String?> _getAuthToken() async {
    try {
      final token = await ref.read(hiveStoreService).getAuthToken();
      if (token == null) throw Exception('Authentication token not found');
      return token;
    } catch (e) {
      print('Error getting auth token: $e');
      return null;
    }
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getAuthToken();
    if (token == null) throw Exception('No authentication token available');
    return {
      'Authorization': 'Bearer $token',
      'accept': '*/*',
    };
  }

  Future<void> connectToSignalR() async {
    if (_hubConnection?.state == HubConnectionState.connected || _isConnecting) return;

    try {
      _isConnecting = true;
      final token = await _getAuthToken();
      if (token == null) {
        _isConnecting = false;
        return;
      }

      _hubConnection = HubConnectionBuilder()
          .withUrl(
            'https://fluffypaw.azurewebsites.net/NotificationHub',
            HttpConnectionOptions(
              accessTokenFactory: () async => token,
              transport: HttpTransportType.webSockets,
              skipNegotiation: true,
              logging: (level, message) => print('SignalR Chat Log: $message'),
            ))
          .withAutomaticReconnect([0, 2000, 10000, 30000])
          .build();

      _hubConnection?.on("MessageNoti", _handleMessageNotification);
      
      await _hubConnection?.start();
      _isConnecting = false;
      print('SignalR Chat: Connected successfully');
    } catch (e) {
      _isConnecting = false;
      print('SignalR Chat Error: $e');
      await Future.delayed(const Duration(seconds: 5));
      connectToSignalR();
    }
  }

  void _handleMessageNotification(List<dynamic>? arguments) {
    if (arguments == null || arguments.length < 6) {
      print('Invalid message format: ${arguments?.length} arguments');
      return;
    }

    try {
      final senderId = int.parse(arguments[0].toString());
      final receiverId = int.parse(arguments[1].toString());
      final message = arguments[2].toString();
      final attachments = (arguments[3] as List).map((url) => url.toString()).toList();
      final type = arguments[4].toString();
      final conversationId = int.parse(arguments[5].toString());

      print('Parsed notification: senderId=$senderId, receiverId=$receiverId, '
          'message=$message, attachments=$attachments, type=$type, '
          'conversationId=$conversationId');

      if (type == "Message") {
        onMessageReceived?.call(message, conversationId, senderId, attachments);
      }
    } catch (e) {
      print('Error parsing message: $e\nRaw arguments: $arguments');
    }
  }

  Future<Response> getMessages(int conversationId, {int pageSize = 20}) async {
    return await ref.read(apiClientProvider).get(
      '${AppConstants.getAllConversationMessageByConversationId}/$conversationId',
      query: {'pageSize': pageSize},
    );
  }

  Future<Response> sendMessage({
    required int conversationId,
    required String content,
    int? replyMessageId,
    List<File>? files,
  }) async {
    final headers = await _getAuthHeaders();
    headers['Content-Type'] = 'multipart/form-data';

    final formMap = {
      'ConversationId': conversationId,
      'Content': content,
      if (replyMessageId != null) 'ReplyMessageId': replyMessageId,
      if (files != null && files.isNotEmpty)
        'Files': await Future.wait(
          files.map((file) async {
            final fileName = file.path.split('/').last;
            return await MultipartFile.fromFile(file.path, filename: fileName);
          }),
        ),
    };

    return await ref.read(apiClientProvider).post(
      AppConstants.sendMessage,
      data: FormData.fromMap(formMap),
      headers: headers,
    );
  }

  Future<void> reconnect() async {
    if (_hubConnection?.state != HubConnectionState.connected) {
      await connectToSignalR();
    }
  }

  void disconnect() {
    _hubConnection?.stop();
    _isConnecting = false;
  }
}

final chatServiceProvider = Provider.family<ChatService, void Function(String, int, int, List<String>)>(
  (ref, onMessageReceived) => ChatService(ref, onMessageReceived: onMessageReceived),
);