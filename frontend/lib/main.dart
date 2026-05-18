import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/app_theme.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/Dashboard.dart';
import 'screens/ManageFinance.dart';
import 'screens/Budget_Alocation.dart';
import 'screens/Saving_Goals.dart';
import 'screens/Reports.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const BudgtInApp());
}

class BudgtInApp extends StatelessWidget {
  const BudgtInApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budgt.in',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      initialRoute: '/login',
      scrollBehavior: const ScrollBehavior().copyWith(overscroll: false),
      
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/manage-finance': (context) => const ManageFinancePage(),
        '/budget-allocation': (context) => const BudgetAllocationPage(),
        '/saving-goals': (context) => const SavingGoalsPage(),
        '/reports': (context) => const ReportsPage(),
      },
    );
  }
}