import 'package:flutter/material.dart';
import '../../../shared/layouts/app_drawer.dart';
import '../../../shared/layouts/app_navigation.dart';
import '../../../shared/layouts/custom_app_bar.dart';

class FarmerDashboard extends StatelessWidget {
  const FarmerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Farmer Dashboard', showNotificationAction: true),
      drawer: const AppDrawer(),
      body: const Center(
        child: Text('Farmer dashboard is under construction.'),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }
}

