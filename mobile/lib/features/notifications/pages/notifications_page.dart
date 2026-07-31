// lib/features/notifications/pages/notifications_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/notification/notification_bloc.dart';
import '../../../core/deep_link_handler.dart';
import '../../../data/models/notification.dart';
import '../../../shared/layouts/app_drawer.dart';
import '../../../shared/layouts/app_navigation.dart';
import '../../../shared/layouts/custom_app_bar.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/skeleton.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(FetchNotificationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Notifications',
        showBackButton: true,
        fallbackRoute: '/profile',
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
              child: SkeletonList(itemCount: 8),
            );
          }

          if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return RefreshIndicator(
                onRefresh: _refresh,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: constraints.maxHeight,
                        child: EmptyState(
                          title: 'No notifications',
                          description:
                              'Order updates, account alerts, and delivery activity will appear here.',
                          icon: Icons.notifications_none_outlined,
                          buttonText: 'Refresh',
                          onButtonPressed: _refresh,
                        ),
                      ),
                    );
                  },
                ),
              );
            }

            final groupedItems = _buildGroupedNotificationItems(state.notifications);

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                itemCount: groupedItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = groupedItems[index];

                  // Group header (String)
                  if (item is String) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 4),
                      child: Text(
                        item,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.dark,
                        ),
                      ),
                    );
                  }

                  // Notification tile
                  final notification = item as NotificationModel;
                  return _NotificationTile(
                    notification: notification,
                    onTap: () => _handleNotificationTap(context, notification),
                    onMarkRead: notification.isUnread
                        ? () => context
                            .read<NotificationBloc>()
                            .add(MarkNotificationReadEvent(notification.id))
                        : null,
                  );
                },
              ),
            );
          }

          if (state is NotificationError) {
            return AppErrorWidget(
              message: state.message,
              buttonText: 'Retry',
              onRetry: _refresh,
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Future<void> _refresh() async {
    context.read<NotificationBloc>().add(FetchNotificationsEvent());
  }

  /// Groups notifications by date (Today, Yesterday, then by month/day)
  List<dynamic> _buildGroupedNotificationItems(List<NotificationModel> notifications) {
    final sorted = [...notifications]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final items = <dynamic>[];
    String? currentGroup;

    for (final notification in sorted) {
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
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${monthNames[date.month - 1]} ${date.day}';
  }

  void _handleNotificationTap(BuildContext context, NotificationModel notification) {
    // Try deep link first
    final deepLinkInfo = DeepLinkHandler.parseNotificationPayload(notification.metadata);
    final routePath = deepLinkInfo?.toRoutePath();
    if (routePath != null) {
      if (notification.isUnread) {
        context.read<NotificationBloc>().add(MarkNotificationReadEvent(notification.id));
      }
      context.go(routePath);
      return;
    }

    // Fallback: show details modal
    _showNotificationDetails(context, notification);
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
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
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

// ─── Internal Notification Tile Widget ──────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback? onMarkRead;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    this.onMarkRead,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = notification.isUnread;
    final (icon, color) = _iconForType(notification.type);

    return CustomCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: EdgeInsets.zero,
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon with colored background
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: AppColors.dark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notification.body,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _timeAgo(notification.createdAt),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            // Mark as read button (if unread)
            if (isUnread && onMarkRead != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onMarkRead!.call();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  (IconData, Color) _iconForType(String type) {
    switch (type) {
      case 'payment':
        return (Icons.payments_rounded, AppColors.success);
      case 'order':
        return (Icons.shopping_bag_rounded, AppColors.primary);
      case 'delivery':
        return (Icons.local_shipping_rounded, AppColors.secondary);
      case 'review':
        return (Icons.star_rounded, AppColors.gold);
      case 'alert':
        return (Icons.warning_amber_rounded, AppColors.warning);
      default:
        return (Icons.notifications_rounded, AppColors.primary);
    }
  }

  String _timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}