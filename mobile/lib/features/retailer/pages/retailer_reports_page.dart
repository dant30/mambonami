import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/route_paths.dart';
import '../../../shared/layouts/app_drawer.dart';
import '../../../shared/layouts/app_navigation.dart';
import '../../../shared/themes/app_colors.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/section_header.dart';

class RetailerReportsPage extends StatelessWidget {
  const RetailerReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = <Map<String, String>>[
      {
        'title': 'Weekly spend',
        'subtitle': 'Track inventory and bulk purchase costs',
        'value': 'KES 298,400',
      },
      {
        'title': 'Top suppliers',
        'subtitle': 'Most trusted farms for your business',
        'value': 'Kamau Farm',
      },
      {
        'title': 'Order frequency',
        'subtitle': 'Average replenishment cycle across categories',
        'value': 'Every 2 days',
      },
    ];

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Retailer insights',
              subtitle: 'Review order trends and supplier performance.',
            ),
            const SizedBox(height: 16),
            ...reports.map((report) {
              return CustomCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  title: Text(
                    report['title']!,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(report['subtitle']!),
                  trailing: Text(
                    report['value']!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
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
