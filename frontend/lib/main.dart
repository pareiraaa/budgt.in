import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/app_theme.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/Dashboard.dart';
import 'screens/Reports.dart';
import 'screens/settings.dart';

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
      initialRoute: '/dashboard',
      scrollBehavior: const ScrollBehavior().copyWith(overscroll: false),
      
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/reports': (context) => const ReportsPage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}