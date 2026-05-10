import 'package:flutter/material.dart';
import 'screens/loginScreen.dart';
import 'screens/HomePage.dart';
import 'screens/TransactionPage.dart';

void main() {
  runApp(const BudgtInApp());
}

class BudgtInApp extends StatelessWidget {
  const BudgtInApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budgt.in',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/add_transaction': (context) => const AddTransactionPage(),
      },
    );
  }
}