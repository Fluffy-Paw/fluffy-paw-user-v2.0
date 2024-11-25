import 'package:fluffypawuser/controllers/misc/misc_provider.dart';
import 'package:fluffypawuser/controllers/notification/notification_controller.dart';
import 'package:fluffypawuser/models/notification/notification_model.dart';
import 'package:fluffypawuser/models/notification/notification_state.dart';
import 'package:fluffypawuser/views/notification/components/notification_card.dart';
import 'package:fluffypawuser/views/notification/components/notification_filter_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:timeago/timeago.dart' as timeago;

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationControllerProvider);
    final controller = ref.read(notificationControllerProvider.notifier);
    final notifications = ref.watch(filteredNotificationsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildAppBar(context, controller),
          _buildFilterBar(context),
        ],
        body: _buildNotificationList(notifications, notificationState),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, NotificationController controller) {
    final unreadCount = ref.watch(unreadCountProvider(null));
    
    return SliverAppBar(
      expandedHeight: 150,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.purple.shade800,
                Colors.purple.shade500,
              ],
            ),
          ),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
      ),
      actions: [
        if (unreadCount > 0)
          IconButton(
            icon: Icon(Icons.mark_email_read, color: Colors.white),
            onPressed: controller.markAllAsRead,
            tooltip: 'Mark all as read',
          ),
        IconButton(
          icon: Icon(Icons.clear_all, color: Colors.white),
          onPressed: controller.clearAllNotifications,
          tooltip: 'Clear all notifications',
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: _buildConnectionStatus(
          ref.watch(notificationControllerProvider).connectionStatus,
        ),
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _NotificationFilterDelegate(
        child: NotificationFilterBar(),
      ),
    );
  }

  Widget _buildConnectionStatus(String status) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case "Connected":
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = "Connected to notifications";
        break;
      case "Disconnected":
        statusColor = Colors.red;
        statusIcon = Icons.error_outline;
        statusText = "Disconnected - Tap to reconnect";
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.warning_amber_rounded;
        statusText = "Connection error - Tap to retry";
    }

    return GestureDetector(
      onTap: status != "Connected" 
        ? () => ref.read(notificationControllerProvider.notifier).initializeSignalR()
        : null,
      child: Container(
        height: 40,
        padding: EdgeInsets.symmetric(horizontal: 16),
        color: statusColor.withOpacity(0.1),
        child: Row(
          children: [
            Icon(statusIcon, size: 16, color: statusColor),
            SizedBox(width: 8),
            Text(
              statusText,
              style: TextStyle(color: statusColor, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationList(
    List<PetNotification> notifications,
    NotificationState state,
  ) {
    if (state.isLoading) {
      return _buildLoadingState();
    }

    if (notifications.isEmpty) {
      return _buildEmptyState(ref.watch(selectedFilterProvider));
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(notificationControllerProvider.notifier).initializeSignalR();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.only(bottom: 100),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return NotificationCard(
            notification: notification,
            index: index,
          ).animate()
            .fadeIn(delay: Duration(milliseconds: 50 * index))
            .slideX(
              begin: 0.2,
              curve: Curves.easeOutQuad,
              delay: Duration(milliseconds: 50 * index),
            );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade800),
          ),
          SizedBox(height: 16),
          Text(
            'Loading notifications...',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(NotificationType? selectedFilter) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (selectedFilter != null)
            Icon(
              selectedFilter.icon,
              size: 80,
              color: selectedFilter.color.withOpacity(0.5),
            )
          else
            Icon(
              Icons.notifications_off_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
          SizedBox(height: 16),
          Text(
            selectedFilter != null
                ? 'No ${selectedFilter.name} notifications'
                : 'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'When you receive notifications, they will appear here',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationFilterDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _NotificationFilterDelegate({required this.child});

  @override
  Widget build(context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    );
  }

  @override
  double get maxExtent => 100;

  @override
  double get minExtent => 100;

  @override
  bool shouldRebuild(covariant _NotificationFilterDelegate oldDelegate) => false;
}

