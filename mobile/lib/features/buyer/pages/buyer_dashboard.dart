import 'package:flutter/material.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/app_navigation.dart';
import '../../../shared/widgets/custom_app_bar.dart';

class BuyerDashboard extends StatelessWidget {
  const BuyerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Buyer Dashboard'),
      drawer: const AppDrawer(),
      body: const Center(
        child: Text('Buyer dashboard is under construction.'),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }
}
