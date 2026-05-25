import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/services/api_client.dart';

class SummaryService {
  static Future<Map<String, dynamic>> getMonthlySummary(int month, int year) async {
    final res = await http.get(
      Uri.parse('${ApiClient.baseUrl}/summary?month=$month&year=$year'),
      headers: await ApiClient.headers(authorized: true),
    );

    if (res.statusCode != 200) {
      throw Exception('Gagal memuat ringkasan');
    }

    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}