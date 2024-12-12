import 'package:fluffypawuser/controllers/hiveController/hive_controller.dart';
import 'package:fluffypawuser/models/conversation/conversation_model.dart';
import 'package:fluffypawuser/services/conversation_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConversationController extends StateNotifier<bool> {
  final Ref ref;
  List<ConversationModel>? _conversations;
  List<ConversationModel>? get conversations => _conversations;

  ConversationController(this.ref) : super(false);

  Future<void> getAllConversations() async {
    try {
      state = true;
      final response =
          await ref.read(conversationServiceProvider).getAllConversations();

      if (response.data['data'] is List) {
        _conversations = ConversationModel.fromMapList(response.data['data']);
      } else {
        // Handle single conversation response
        _conversations = [ConversationModel.fromMap(response.data['data'])];
      }

      if (_conversations != null) {
        await ref
            .read(hiveStoreService)
            .saveConversations(conversations: _conversations!);
      }

      state = false;
    } catch (e) {
      state = false;
      debugPrint('Error getting conversations: ${e.toString()}');
      rethrow;
    }
  }

  Future<ConversationModel?> createConversation(int personId) async {
    try {
      state = true;
      final response = await ref
          .read(conversationServiceProvider)
          .createConversation(personId);

      state = false;

      if (response.data['statusCode'] == 200 && response.data['data'] != null) {
        final newConversation =
            ConversationModel.fromMap(response.data['data']);

        // Update the conversations list if it exists
        if (_conversations != null) {
          // Check if conversation already exists
          final existingIndex = _conversations!
              .indexWhere((conv) => conv.id == newConversation.id);

          if (existingIndex >= 0) {
            // Update existing conversation
            _conversations![existingIndex] = newConversation;
          } else {
            // Add new conversation to the beginning of the list
            _conversations!.insert(0, newConversation);
          }

          // Save updated conversations to local storage
          await ref
              .read(hiveStoreService)
              .saveConversations(conversations: _conversations!);
        } else {
          // If no conversations exist yet, initialize the list
          _conversations = [newConversation];
          await ref
              .read(hiveStoreService)
              .saveConversations(conversations: _conversations!);
        }

        return newConversation;
      }
      return null;
    } catch (e) {
      state = false;
      debugPrint('Error creating conversation: ${e.toString()}');
      rethrow;
    }
  }
  ConversationModel? findExistingConversation(int accountId) {
    if (_conversations == null) return null;
    
    try {
      return _conversations!.firstWhere(
        (conversation) => conversation.poAccountId == accountId || conversation.staffAccountId == accountId,
      );
    } catch (e) {
      return null;
    }
  }

  Future<ConversationModel?> createOrGetConversation(int accountId) async {
    try {
      // First, ensure we have the latest conversations
      if (_conversations == null) {
        await getAllConversations();
      }

      // Check if conversation exists
      final existingConversation = findExistingConversation(accountId);
      if (existingConversation != null) {
        return existingConversation;
      }

      // If no existing conversation, create new one
      state = true;
      final response = await ref
          .read(conversationServiceProvider)
          .createConversation(accountId);

      state = false;

      if (response.data['statusCode'] == 200 && response.data['data'] != null) {
        final newConversation = ConversationModel.fromMap(response.data['data']);
        
        // Update the conversations list
        if (_conversations != null) {
          _conversations!.insert(0, newConversation);
          await ref.read(hiveStoreService)
              .saveConversations(conversations: _conversations!);
        } else {
          _conversations = [newConversation];
          await ref.read(hiveStoreService)
              .saveConversations(conversations: _conversations!);
        }
        
        return newConversation;
      }
      return null;
    } catch (e) {
      state = false;
      debugPrint('Error in createOrGetConversation: ${e.toString()}');
      rethrow;
    }
  }
}

final conversationController =
    StateNotifierProvider<ConversationController, bool>(
        (ref) => ConversationController(ref));
