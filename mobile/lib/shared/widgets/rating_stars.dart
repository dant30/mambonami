// mobile/lib/shared/widgets/rating_stars.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final int starCount;
  final double size;

  final Color? filledColor;
  final Color? emptyColor;

  const RatingStars({
    super.key,
    required this.rating,
    this.starCount = 5,
    this.size = 20,
    this.filledColor,
    this.emptyColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final fillColor = filledColor ?? theme.colorScheme.secondary;
    final bgColor = emptyColor ?? theme.disabledColor;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (index) {
        final starIndex = index + 1;

        // Calculate fill percentage (0.0 → 1.0)
        double fillPercent;

        if (rating >= starIndex) {
          fillPercent = 1.0;
        } else if (rating <= index) {
          fillPercent = 0.0;
        } else {
          fillPercent = rating - index;
        }

        // 👇 Snap to nearest quarter (0.0, 0.25, 0.5, 0.75, 1.0)
        fillPercent = (fillPercent * 4).round() / 4;

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              // Empty star (background)
              Icon(Icons.star, size: size, color: bgColor),

              // Filled portion
              ClipRect(
                clipper: _StarClipper(fillPercent),
                child: Icon(Icons.star, size: size, color: fillColor),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class InteractiveRatingStars extends StatefulWidget {
  final int initialRating;
  final ValueChanged<int> onRatingChanged;
  final int starCount;
  final double size;
  final Color? filledColor;
  final Color? emptyColor;

  const InteractiveRatingStars({
    super.key,
    this.initialRating = 0,
    required this.onRatingChanged,
    this.starCount = 5,
    this.size = 24,
    this.filledColor,
    this.emptyColor,
  });

  @override
  State<InteractiveRatingStars> createState() => _InteractiveRatingStarsState();
}

class _InteractiveRatingStarsState extends State<InteractiveRatingStars> {
  late int _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.starCount, (index) {
        final isSelected = index < _rating;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _rating = index + 1);
            widget.onRatingChanged(_rating);
          },
          child: AnimatedScale(
            scale: isSelected ? 1.06 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            child: Icon(
              isSelected ? Icons.star : Icons.star_border,
              color: isSelected
                  ? (widget.filledColor ?? theme.colorScheme.secondary)
                  : (widget.emptyColor ?? theme.disabledColor),
              size: widget.size,
            ),
          ),
        );
      }),
    );
  }
}

class _StarClipper extends CustomClipper<Rect> {
  final double fillPercent;

  _StarClipper(this.fillPercent);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(
      0,
      0,
      size.width * fillPercent,
      size.height,
    );
  }

  @override
  bool shouldReclip(_StarClipper oldClipper) {
    return oldClipper.fillPercent != fillPercent;
  }
}