import 'package:flutter/material.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/app_navigation.dart';
import '../../../shared/widgets/custom_app_bar.dart';

class ProviderDashboard extends StatelessWidget {
  const ProviderDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Transport Provider Dashboard'),
      drawer: const AppDrawer(),
      body: const Center(
        child: Text('Transport provider dashboard is under construction.'),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }
}

