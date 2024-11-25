import 'dart:ui';
import 'package:fluffypawuser/controllers/misc/misc_provider.dart';
import 'package:fluffypawuser/models/notification/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationFilterBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(selectedFilterProvider);

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              _buildFilterChip(
                context,
                null,
                ref,
                ref.watch(unreadCountProvider(null)),
              ),
              ...NotificationType.values.map((type) {
                return _buildFilterChip(
                  context,
                  type,
                  ref,
                  ref.watch(unreadCountProvider(type)),
                );
              }),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedFilter == null
                    ? 'All Notifications'
                    : '${selectedFilter.name.toUpperCase()} Notifications',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                '${ref.watch(notificationCountProvider(selectedFilter))} total',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    NotificationType? type,
    WidgetRef ref,
    int unreadCount,
  ) {
    final selected = ref.watch(selectedFilterProvider) == type;
    final color = type?.color ?? Colors.grey;

    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: selected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (type != null)
              Icon(
                type.icon,
                size: 16,
                color: selected ? Colors.white : color,
              ),
            if (type != null) SizedBox(width: 4),
            Text(type?.name.toUpperCase() ?? 'ALL'),
            if (unreadCount > 0) ...[
              SizedBox(width: 4),
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: selected 
                    ? Colors.white.withOpacity(0.2)
                    : color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  unreadCount.toString(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: selected ? Colors.white : color,
                  ),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: type?.color.withOpacity(0.1) ?? Colors.grey.shade100,
        selectedColor: type?.color ?? Colors.grey,
        labelStyle: TextStyle(
          color: selected ? Colors.white : color,
          fontWeight: FontWeight.bold,
        ),
        onSelected: (_) {
          ref.read(selectedFilterProvider.notifier).state = type;
        },
      ),
    );
  }
}