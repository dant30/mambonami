// mobile/lib/shared/widgets/notification_badge.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../config/route_paths.dart';
import '../../blocs/notification/notification_bloc.dart';

class NotificationBadge extends StatefulWidget {
  final double size;
  final VoidCallback? onTap;
  final int maxCount;
  final bool showZero;

  const NotificationBadge({
    super.key,
    this.size = 24,
    this.onTap,
    this.maxCount = 99,
    this.showZero = false,
  });

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  int _lastCount = 0;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _scale = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_ctrl);

    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0.3, -0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleNewCount(int count) {
    if (count > _lastCount) {
      _ctrl.forward(from: 0.0);
    }
    _lastCount = count;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<NotificationBloc, NotificationState>(
      listenWhen: (prev, curr) => curr is NotificationLoaded,
      listener: (context, state) {
        if (state is NotificationLoaded) {
          _handleNewCount(state.unreadCount);
        }
      },
      child: BlocBuilder<NotificationBloc, NotificationState>(
        buildWhen: (prev, curr) => curr is NotificationLoaded,
        builder: (context, state) {
          int unread = 0;
          if (state is NotificationLoaded) unread = state.unreadCount;

          final showBadge = unread > 0 || widget.showZero;

          final displayText = unread > widget.maxCount
              ? '${widget.maxCount}+'
              : unread.toString();

          return Semantics(
            button: true,
            label: unread > 0
                ? '$unread unread notifications'
                : 'No unread notifications',
            child: InkResponse(
              onTap: () {
                HapticFeedback.lightImpact();
                (widget.onTap ??
                        () => context.go(RoutePaths.notifications))
                    .call();
              },
              radius: widget.size,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  SizedBox(
                    width: widget.size,
                    height: widget.size,
                    child: Icon(
                      unread > 0
                          ? Icons.notifications
                          : Icons.notifications_outlined,
                    ),
                  ),

                  /// BADGE
                  Positioned(
                    right: -2,
                    top: -2,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, anim) {
                        return FadeTransition(
                          opacity: anim,
                          child: ScaleTransition(
                            scale: anim,
                            child: child,
                          ),
                        );
                      },
                      child: showBadge
                          ? SlideTransition(
                              position: _slide,
                              child: FadeTransition(
                                opacity: _fade,
                                child: ScaleTransition(
                                  scale: _scale,
                                  child: Container(
                                    key: ValueKey(unread),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.error,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      displayText,
                                      style: TextStyle(
                                        color:
                                            theme.colorScheme.onError,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
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
        },
      ),
    );
  }
}