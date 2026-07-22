import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../data/models/product.dart';
import '../../../shared/themes/app_colors.dart';

class BuyerHeroCarousel extends StatefulWidget {
  final List<Product> products;
  final VoidCallback onShopNow;

  const BuyerHeroCarousel({
    super.key,
    required this.products,
    required this.onShopNow,
  });

  @override
  State<BuyerHeroCarousel> createState() => _BuyerHeroCarouselState();
}

class _BuyerHeroCarouselState extends State<BuyerHeroCarousel> {
  late final PageController _pageController;
  Timer? _timer;
  int _page = 0;

  List<_HeroSlide> _buildSlides() {
    if (widget.products.isEmpty) {
      return const [
        _HeroSlide(
          title: 'Fresh from the Farm',
          subtitle: 'Discover produce picked for your table.',
          imageUrl:
              'https://images.unsplash.com/photo-1542838132-92c53300491e?w=900&h=420&fit=crop&auto=format',
        ),
        _HeroSlide(
          title: 'Stock up for less',
          subtitle: 'Find seasonal produce and value-packed baskets.',
          imageUrl:
              'https://images.unsplash.com/photo-1488459716781-31db52582fe9?w=900&h=420&fit=crop&auto=format',
        ),
        _HeroSlide(
          title: 'Know your farmer',
          subtitle: 'Shop traceable produce from nearby growers.',
          imageUrl:
              'https://images.unsplash.com/photo-1500651230702-0e2d8a49d4ad?w=900&h=420&fit=crop&auto=format',
        ),
      ];
    }

    final featuredProducts = widget.products.take(3).toList();
    return featuredProducts.map((product) {
      final subtitle =
          '${product.name} from ${product.farmerName} · KES ${product.pricePerUnit.toStringAsFixed(0)}/${product.unit}';
      return _HeroSlide(
        title: product.name,
        subtitle: subtitle,
        imageUrl: product.imageUrl ??
            'https://images.unsplash.com/photo-1542838132-92c53300491e?w=900&h=420&fit=crop&auto=format',
      );
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final slides = _buildSlides();
      if (slides.isEmpty) return;
      final next = (_page + 1) % slides.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = _buildSlides();
    if (slides.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: SizedBox(
        height: 172,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: slides.length,
                onPageChanged: (page) => setState(() => _page = page),
                itemBuilder: (context, index) =>
                    _buildSlide(context, slides[index]),
              ),
              Positioned(
                left: 20,
                bottom: 14,
                child: Row(
                  children: List.generate(
                    slides.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 5),
                      width: index == _page ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: index == _page ? Colors.white : Colors.white54,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlide(BuildContext context, _HeroSlide slide) {
    final theme = Theme.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: slide.imageUrl,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => Container(color: AppColors.primary),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary.withValues(alpha: 0.9), Colors.transparent],
              stops: const [0, 0.72],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MAMBONAMI PICKS', style: theme.textTheme.labelSmall?.copyWith(color: Colors.white70, letterSpacing: 1.1)),
              const SizedBox(height: 5),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 220),
                child: Text(slide.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800, height: 1.05)),
              ),
              const SizedBox(height: 5),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 220),
                child: Text(slide.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.82))),
              ),
              const Spacer(),
              SizedBox(
                height: 30,
                child: ElevatedButton(
                  onPressed: widget.onShopNow,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text('Shop now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroSlide {
  final String title;
  final String subtitle;
  final String imageUrl;

  const _HeroSlide({required this.title, required this.subtitle, required this.imageUrl});
}
