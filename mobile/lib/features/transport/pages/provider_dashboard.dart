import 'package:flutter/material.dart';
import '../../../shared/layouts/app_drawer.dart';
import '../../../shared/layouts/app_navigation.dart';
import '../../../shared/layouts/custom_app_bar.dart';

class ProviderDashboard extends StatelessWidget {
  const ProviderDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Transport Provider Dashboard', showNotificationAction: true),
      drawer: const AppDrawer(),
      body: const Center(
        child: Text('Transport provider dashboard is under construction.'),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }
}

