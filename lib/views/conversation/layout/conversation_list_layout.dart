// conversation_screen.dart
import 'package:fluffypawuser/config/app_color.dart';
import 'package:fluffypawuser/config/app_text_style.dart';
import 'package:fluffypawuser/controllers/conversation/conversation_controller.dart';
import 'package:fluffypawuser/models/conversation/conversation_model.dart';
import 'package:fluffypawuser/views/conversation/layout/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(conversationController.notifier).getAllConversations(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).scaffoldBackgroundColor == AppColor.blackColor;
    final isLoading = ref.watch(conversationController);
    final conversations =
        ref.watch(conversationController.notifier).conversations;

    return Scaffold(
      backgroundColor: isDark ? AppColor.blackColor : AppColor.offWhiteColor,
      appBar: AppBar(
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Messages',
          style: AppTextStyle(context).title.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
        ),
        toolbarHeight: 70.h,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : conversations == null || conversations.isEmpty
              ? _buildEmptyState()
              : AnimationLimiter(
                  child: ListView.builder(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = conversations[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: _buildConversationCard(conversation),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80.sp,
            color: AppColor.greyColor.withOpacity(0.5),
          ),
          Gap(16.h),
          Text(
            'No conversations yet',
            style: AppTextStyle(context).bodyText.copyWith(
                  color: AppColor.greyColor,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationCard(ConversationModel conversation) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.blackColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () => _navigateToChat(context, conversation),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                _buildAvatar(conversation),
                Gap(12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              conversation.poName,
                              style: AppTextStyle(context).bodyText.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.blackColor,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            conversation.timeSinceLastMessage,
                            style: AppTextStyle(context).bodyTextSmall.copyWith(
                                  color: AppColor.greyColor,
                                  fontSize: 12.sp,
                                ),
                          ),
                        ],
                      ),
                      Gap(4.h),
                      Text(
                        conversation.lastMessage,
                        style: AppTextStyle(context).bodyTextSmall.copyWith(
                              color: AppColor.greyColor,
                              height: 1.5,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToChat(BuildContext context, ConversationModel conversation) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ChatScreen(
        conversationId: conversation.id,
        poAccountId: conversation.poAccountId,
        storeName: conversation.storeName ?? 'store name',
      ),
    ),
  ).then((_) {
    // Refresh conversations list when returning from chat
    ref.read(conversationController.notifier).getAllConversations();
  });
}

  Widget _buildAvatar(ConversationModel conversation) {
    return Container(
      width: 56.w,
      height: 56.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColor.violetColor.withOpacity(0.1),
      ),
      clipBehavior: Clip.hardEdge,
      child: conversation.storeAvatar != null && conversation.storeAvatar!.isNotEmpty
          ? Image.network(
              conversation.poAvatar!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Text(
                    conversation.poName[0].toUpperCase(),
                    style: AppTextStyle(context).title.copyWith(
                      color: AppColor.violetColor,
                      fontSize: 24.sp,
                    ),
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColor.violetColor),
                  ),
                );
              },
            )
          : Center(
              child: Text(
                conversation.poName[0].toUpperCase(),
                style: AppTextStyle(context).title.copyWith(
                  color: AppColor.violetColor,
                  fontSize: 24.sp,
                ),
              ),
            ),
    );
}
}
