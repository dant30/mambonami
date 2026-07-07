// mobile/lib/features/notifications/pages/notifications_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

import '../../../blocs/notification/notification_bloc.dart';
import '../../../core/deep_link_handler.dart';
import '../../../data/models/notification.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/layouts/app_drawer.dart';
import '../../../shared/layouts/app_navigation.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/skeleton.dart';
import '../widgets/notification_tile.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Notifications',
        showBackButton: true,
        fallbackRoute: '/profile', // fallback if needed
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            buildWhen: (prev, curr) => curr is NotificationLoaded,
            builder: (context, state) {
              if (state is NotificationLoaded && state.unreadCount > 0) {
                return IconButton(
                  tooltip: 'Mark all read',
                  icon: const Icon(Icons.mark_email_read_outlined),
                  onPressed: () async {
                    HapticFeedback.lightImpact();
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Mark all as read'),
                        content: const Text('Mark all notifications as read?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Confirm'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      context.read<NotificationBloc>().add(MarkAllReadEvent());
                    }
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNavigationBar(),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Padding(
              padding: EdgeInsets.only(top: 8),
              child: SkeletonList(itemCount: 6),
            );
          } else if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<NotificationBloc>().add(FetchNotificationsEvent());
                },
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: constraints.maxHeight,
                        child: EmptyState(
                          title: 'No notifications',
                          description: 'Order updates, account alerts, and delivery activity will appear here.',
                          icon: Icons.notifications_none_outlined,
                          buttonText: 'Refresh',
                          onButtonPressed: () {
                            context.read<NotificationBloc>().add(FetchNotificationsEvent());
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            }

            final groupedItems = _buildGroupedNotificationItems(state.notifications);
            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotificationBloc>().add(FetchNotificationsEvent());
              },
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(0, 8, 0, 8 + MediaQuery.of(context).padding.bottom),
                itemCount: groupedItems.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = groupedItems[index];
                  if (item is String) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        item,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    );
                  }

                  final notif = item as NotificationModel;
                  return NotificationTile(
                    notification: notif,
                    onTap: () => _handleNotificationTap(context, notif),
                    onMarkRead: notif.isUnread
                        ? () {
                            context.read<NotificationBloc>().add(
                                  MarkNotificationReadEvent(notif.id),
                                );
                          }
                        : null,
                  );
                },
              ),
            );
          } else if (state is NotificationError) {
            return AppErrorWidget(
              message: state.message,
              buttonText: 'Retry',
              onRetry: () => context.read<NotificationBloc>().add(FetchNotificationsEvent()),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  void _handleNotificationTap(BuildContext context, NotificationModel notification) {
    final deepLinkInfo = DeepLinkHandler.parseNotificationPayload(notification.metadata);
    final routePath = deepLinkInfo?.toRoutePath();
    if (routePath != null) {
      if (notification.isUnread) {
        context.read<NotificationBloc>().add(MarkNotificationReadEvent(notification.id));
      }
      context.go(routePath);
      return;
    }

    _showNotificationDetails(context, notification);
  }

  List<dynamic> _buildGroupedNotificationItems(List<NotificationModel> notifications) {
    final sortedNotifications = [...notifications]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final items = <dynamic>[];
    String? currentGroup;
    for (final notification in sortedNotifications) {
      final group = _groupLabel(notification.createdAt);
      if (group != currentGroup) {
        currentGroup = group;
        items.add(group);
      }
      items.add(notification);
    }
    return items;
  }

  String _groupLabel(DateTime date) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    }
    if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      return 'Yesterday';
    }
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${monthNames[date.month - 1]} ${date.day}';
  }

  void _showNotificationDetails(BuildContext context, NotificationModel notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                notification.body,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (notification.metadata.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  'Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: notification.metadata.entries.map<Widget>((entry) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${entry.key}: ${entry.value}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}