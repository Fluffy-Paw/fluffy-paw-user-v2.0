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
    final response = await ref.read(conversationServiceProvider).getAllConversations();
    
    if (response.data['data'] is List) {
      _conversations = ConversationModel.fromMapList(response.data['data']);
    } else {
      // Handle single conversation response
      _conversations = [ConversationModel.fromMap(response.data['data'])];
    }
    
    if (_conversations != null) {
      await ref.read(hiveStoreService).saveConversations(conversations: _conversations!);
    }
    
    state = false;
  } catch (e) {
    state = false;
    debugPrint('Error getting conversations: ${e.toString()}');
    rethrow;
  }
}
}

final conversationController =
    StateNotifierProvider<ConversationController, bool>(
        (ref) => ConversationController(ref));