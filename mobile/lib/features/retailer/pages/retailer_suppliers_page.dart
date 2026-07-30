import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/route_paths.dart';
import '../../../shared/layouts/app_drawer.dart';
import '../../../shared/layouts/app_navigation.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/section_header.dart';

class RetailerSuppliersPage extends StatelessWidget {
  const RetailerSuppliersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final suppliers = <Map<String, String>>[
      {
        'name': 'Kamau Farm',
        'location': 'Kiambu',
        'status': 'Fresh stock available',
        'leadTime': '24h',
      },
      {
        'name': 'Wanjiku Farm',
        'location': 'Nakuru',
        'status': 'Organic vegetables',
        'leadTime': '2 days',
      },
      {
        'name': 'Thika Farms',
        'location': 'Thika',
        'status': 'Ready for pickup',
        'leadTime': '12h',
      },
    ];

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Suppliers'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Your supplier network',
              subtitle: 'Browse trusted farms supplying your store.',
            ),
            const SizedBox(height: 16),
            ...suppliers.map((supplier) {
              return CustomCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  title: Text(
                    supplier['name']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(supplier['location']!),
                      const SizedBox(height: 4),
                      Text(supplier['status']!,
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(supplier['leadTime']!,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          )),
                      const SizedBox(height: 4),
                      Text('Lead time',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: AppColors.muted)),
                    ],
                  ),
                  onTap: () => context.go(RoutePaths.retailerReports),
                ),
              );
            }).toList(),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }
}
