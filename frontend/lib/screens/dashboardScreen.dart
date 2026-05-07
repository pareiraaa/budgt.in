import 'package:flutter/material.dart';
import 'package:frontend/widgets/headerSection.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  //  final List<StatData> stats = [
  //   StatData(title: 'Revenue', value: '12.4K', icon: Icons.attach_money, color: Colors.green),
  //   StatData(title: 'Users', value: '1,280', icon: Icons.people, color: Colors.blue),
  //   StatData(title: 'Orders', value: '320', icon: Icons.shopping_cart, color: Colors.orange),
  //   StatData(title: 'Growth', value: '+8.5%', icon: Icons.trending_up, color: Colors.purple),
  // ];
  // final List<ProgressData> progressItems = [
  //   ProgressData(label: 'Design', percentage: 0.85, color: Colors.blue),
  //   ProgressData(label: 'Development', percentage: 0.62, color: Colors.green),
  //   ProgressData(label: 'Marketing', percentage: 0.45, color: Colors.orange),
  // ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Headersection(),
              const SizedBox(height: 24)
            ],
          )
        )
      ),
    );
  }
}
