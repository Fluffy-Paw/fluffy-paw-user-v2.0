import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fluffypawuser/config/app_constants.dart';
import 'package:fluffypawuser/utils/api_clients.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class ConversationProvider {
  Future<Response> getAllConversations();
  Future<Response> createConversation(int personId);
}

class ConversationServiceProvider implements ConversationProvider {
  final Ref ref;

  ConversationServiceProvider(this.ref);

  @override
  Future<Response> getAllConversations() async {
    final response = await ref
        .read(apiClientProvider)
        .get(AppConstants.getAllConversation);
    return response;
  }
  @override
  Future<Response> createConversation(int personId) async {
    final response = await ref
        .read(apiClientProvider)
        .post(AppConstants.createConversation, data: {
      'personId': personId,
    });
    return response;
  }
  
}

final conversationServiceProvider = 
    Provider((ref) => ConversationServiceProvider(ref));