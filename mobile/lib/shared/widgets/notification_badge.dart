import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../config/route_paths.dart';
import '../../blocs/notification/notification_bloc.dart';

class NotificationBadge extends StatefulWidget {
  final double size;
  final VoidCallback? onTap;
  const NotificationBadge({super.key, this.size = 24, this.onTap});

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  int _lastCount = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 320));
    _scale = Tween<double>(begin: 1.0, end: 1.25).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant NotificationBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.size != widget.size) {
      _lastCount = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationBloc, NotificationState>(
      listener: (context, state) {
        if (state is NotificationLoaded) {
          final count = state.unreadCount;
          if (count > _lastCount) {
            // New unread arrived — pulse animation
            _ctrl.forward(from: 0.0);
          }
          _lastCount = count;
        }
      },
      child: BlocBuilder<NotificationBloc, NotificationState>(builder: (context, state) {
        int unread = 0;
        if (state is NotificationLoaded) unread = state.unreadCount;

        return Semantics(
          button: true,
          label: 'Notifications',
          child: InkResponse(
            onTap: widget.onTap ?? () => context.go(RoutePaths.notifications),
            radius: widget.size,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                  width: widget.size,
                  height: widget.size,
                  child: const Icon(Icons.notifications_outlined),
                ),
                Positioned(
                  right: -2,
                  top: -2,
                  child: ScaleTransition(
                    scale: _scale,
                    child: unread > 0
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              unread > 99 ? '99+' : unread.toString(),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
