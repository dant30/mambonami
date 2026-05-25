import 'package:flutter/material.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/app_navigation.dart';
import '../../../shared/widgets/custom_app_bar.dart';

class FarmerDashboard extends StatelessWidget {
  const FarmerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Farmer Dashboard'),
      drawer: const AppDrawer(),
      body: const Center(
        child: Text('Farmer dashboard is under construction.'),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }
}

