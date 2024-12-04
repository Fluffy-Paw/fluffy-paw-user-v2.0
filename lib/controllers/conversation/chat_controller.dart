import 'dart:convert';
import 'dart:io';
import 'package:fluffypawuser/controllers/hiveController/hive_controller.dart';
import 'package:fluffypawuser/models/conversation/message_model.dart';
import 'package:fluffypawuser/services/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatController extends StateNotifier<AsyncValue<ChatPagination>> {
  final Ref ref;
  final int conversationId;
  late final ChatService _chatService;
  
  ChatController(this.ref, this.conversationId) : super(const AsyncValue.loading()) {
    _chatService = ref.read(chatServiceProvider(_handleNewMessage));
    _initialize();
  }

  Future<void> _initialize() async {
    await _chatService.connectToSignalR();
    getMessages();
  }
  Future<int> _getCurrentUserId() async {
    try {
      final token = await ref.read(hiveStoreService).getAuthToken();
      if (token == null) return 7; // Default to user ID if no token
      
      final parts = token.split('.');
      final payload = base64Url.normalize(parts[1]);
      final resp = utf8.decode(base64Url.decode(payload));
      final map = json.decode(resp);
      
      return int.parse(map['id'].toString());
    } catch (e) {
      print('Error getting user ID: $e');
      return 7; // Default to user ID on error
    }
  }

  void _handleNewMessage(String content, int messageConversationId, int targetId) {
    if (messageConversationId == conversationId) {
      if (state.hasValue) {
        final currentState = state.value!;
        
        final newMessage = Message(
          id: DateTime.now().millisecondsSinceEpoch,
          conversationId: messageConversationId,
          senderId: targetId, // Use target ID as sender
          content: content,
          createTime: DateTime.now(),
          isSeen: false,
          isDelete: false,
          replyMessageId: 0,
          deleteAt: null,
          files: [],
        );

        final updatedMessages = [...currentState.items, newMessage];
        state = AsyncValue.data(ChatPagination(
          items: updatedMessages,
          totalItems: currentState.totalItems + 1,
          currentPage: currentState.currentPage,
          totalPages: currentState.totalPages,
          pageSize: currentState.pageSize,
          hasPreviousPage: currentState.hasPreviousPage,
          hasNextPage: currentState.hasNextPage,
        ));
      }
    }
  }

  Future<void> getMessages() async {
    try {
      state = const AsyncValue.loading();
      final response = await _chatService.getMessages(conversationId);
      
      if (response.data['statusCode'] == 200 && response.data['data'] != null) {
        final chatPagination = ChatPagination.fromMap(response.data['data']);
        state = AsyncValue.data(chatPagination);
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e, stack) {
      debugPrint('Error getting messages: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> sendMessage({
    required String content,
    int? replyMessageId,
    List<File>? files,
  }) async {
    try {
      // Add optimistic update before sending
      if (state.hasValue) {
        final currentState = state.value!;
        final userId = await _getCurrentUserId();
        
        final optimisticMessage = Message(
          id: DateTime.now().millisecondsSinceEpoch,
          conversationId: conversationId,
          senderId: userId, // Get actual user ID from token
          content: content,
          createTime: DateTime.now(),
          isSeen: false,
          isDelete: false,
          replyMessageId: replyMessageId ?? 0,
          deleteAt: null,
          files: [],
        );

        final updatedMessages = [...currentState.items, optimisticMessage];
        state = AsyncValue.data(ChatPagination(
          items: updatedMessages,
          totalItems: currentState.totalItems + 1,
          currentPage: currentState.currentPage,
          totalPages: currentState.totalPages,
          pageSize: currentState.pageSize,
          hasPreviousPage: currentState.hasPreviousPage,
          hasNextPage: currentState.hasNextPage,
        ));
      }

      final response = await _chatService.sendMessage(
        conversationId: conversationId,
        content: content,
        replyMessageId: replyMessageId,
        files: files,
      );

      return response.data['statusCode'] == 200;
    } catch (e) {
      debugPrint('Error sending message: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _chatService.disconnect();
    super.dispose();
  }
}

final chatControllerProvider = StateNotifierProvider.family<ChatController, AsyncValue<ChatPagination>, int>(
  (ref, conversationId) => ChatController(ref, conversationId),
);