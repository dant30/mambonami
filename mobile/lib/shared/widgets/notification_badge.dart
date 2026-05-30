import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/notification/notification_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../config/route_paths.dart';

class NotificationBadge extends StatefulWidget {
  final double size;
  const NotificationBadge({super.key, this.size = 24});

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

        return GestureDetector(
          onTap: () => context.go(RoutePaths.notifications),
          child: Stack(
            alignment: Alignment.center,
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
                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.circular(12)),
                          child: Text(unread > 99 ? '99+' : unread.toString(), style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 11, fontWeight: FontWeight.w700)),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
