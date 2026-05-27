import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/notification/notification_bloc.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/app_navigation.dart';
import '../widgets/notification_tile.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Notifications'),
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNavigationBar(),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<NotificationBloc>().add(FetchNotificationsEvent());
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [SizedBox(height: 200), Center(child: Text('No notifications'))],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotificationBloc>().add(FetchNotificationsEvent());
              },
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.notifications.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final notif = state.notifications[index];
                  return NotificationTile(
                    notification: notif,
                    onTap: () => _showNotificationDetails(context, notif),
                    onMarkRead: notif.isUnread
                        ? () {
                            context.read<NotificationBloc>().add(MarkNotificationReadEvent(notif.id));
                          }
                        : null,
                  );
                },
              ),
            );
          } else if (state is NotificationError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<NotificationBloc>().add(FetchNotificationsEvent()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  void _showNotificationDetails(BuildContext context, dynamic notification) {
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
              Text(notification.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text(notification.body, style: Theme.of(context).textTheme.bodyMedium),
              if (notification.metadata.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text('Details', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: notification.metadata.entries.map<Widget>((entry) {
                    return Chip(label: Text('${entry.key}: ${entry.value}'));
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
