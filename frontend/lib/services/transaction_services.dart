import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/services/api_client.dart';

class TransactionService {
  static Future<void> createIncome({
    required int amount,
    String? note,
    String? incomeSource,
    DateTime? date,
  }) async {
    final res = await http.post(
      Uri.parse('${ApiClient.baseUrl}/transactions'),
      headers: await ApiClient.headers(authorized: true),
      body: jsonEncode({
        'amount': amount,
        'type': 'Income',
        'date': (date ?? DateTime.now()).toIso8601String(),
        'note': note,
        'incomeSource': incomeSource,
      }),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      String msg = 'Gagal mencatat pemasukan';
      try {
        final data = jsonDecode(res.body);
        if (data['message'] != null) msg = data['message'].toString();
      } catch (_) {}
      throw Exception(msg);
    }
  }

  static Future<List<Map<String, dynamic>>> getTransactions() async {
    final res = await http.get(
      Uri.parse('${ApiClient.baseUrl}/transactions'),
      headers: await ApiClient.headers(authorized: true),
    );

    if (res.statusCode != 200) {
      throw Exception('Gagal memuat transaksi');
    }

    final List<dynamic> data = jsonDecode(res.body);
    return data.cast<Map<String, dynamic>>();
  }

  static Future<void> voidTransaction(String id) async {
    if (int.tryParse(id) == null) {
      throw Exception('Transaksi ini belum tersimpan di server');
    }
    final res = await http.delete(
      Uri.parse('${ApiClient.baseUrl}/transactions/$id'),
      headers: await ApiClient.headers(authorized: true),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      String msg = 'Gagal membatalkan transaksi';
      try {
        final data = jsonDecode(res.body);
        if (data['message'] != null) msg = data['message'].toString();
      } catch (_) {}
      throw Exception(msg);
    }
  }

  static Future<void> createExpense({
    required int amount,
    required String pocketId,
    String? note,
    DateTime? date,
  }) async {
    final res = await http.post(
      Uri.parse('${ApiClient.baseUrl}/transactions'),
      headers: await ApiClient.headers(authorized: true),
      body: jsonEncode({
        'amount': amount,
        'type': 'Expense',
        'date': (date ?? DateTime.now()).toIso8601String(),
        'pocketId': int.parse(pocketId),   // backend minta number
        'note': note,
      }),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      String msg = 'Gagal mencatat pengeluaran';
      try {
        final data = jsonDecode(res.body);
        if (data['message'] != null) msg = data['message'].toString();
      } catch (_) {}
      throw Exception(msg);
    }
  }
}