import 'dart:convert';
import 'package:frontend/screens/Dashboard.dart';
import 'package:frontend/services/api_client.dart';
import 'package:http/http.dart' as http;

class PocketService {
  static Future<List<Pocket>> getPockets() async {
    final res = await http.get(
      Uri.parse('${ApiClient.baseUrl}/pockets'),
      headers: await ApiClient.headers(authorized: true),
    );

    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);  
      return data.map((json) => Pocket.fromJson(json)).toList();
    } else {
      throw Exception('Gagal ambil data pockets');
    }
  }

  static Future<void> createPocket({
    required String name,
    required String pocketType,
    double? targetAmount,
    String? deadline,
  }) async {
    final res = await http.post(
      Uri.parse('${ApiClient.baseUrl}/pockets'),
      headers: await ApiClient.headers(authorized: true),
      body: jsonEncode({
        'name': name,                    
        'pocketType': pocketType,
        'targetAmount': targetAmount,
        'deadline': deadline,
      }),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Gagal membuat pocket');
    }
  }

  static Future<void> transferPocket({
    required String fromPocketId,
    required String toPocketId,
    required double amount,
  }) async {
    final res = await http.post(
      Uri.parse('${ApiClient.baseUrl}/pockets/transfer'),
      headers: await ApiClient.headers(authorized: true),
      body: jsonEncode({
        'fromPocketId': int.parse(fromPocketId),   // String -> int (backend minta number)
        'toPocketId': int.parse(toPocketId),
        'amount': amount,
      }),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      String msg = 'Gagal transfer';
      try {
        final data = jsonDecode(res.body);
        if (data['message'] != null) msg = data['message'].toString();
      } catch (_) {}
      throw Exception(msg);
    }
  }

  static Future<void> deletePocket(String id) async {
    final res = await http.delete(
      Uri.parse('${ApiClient.baseUrl}/pockets/$id'),
      headers: await ApiClient.headers(authorized: true),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      String msg = 'Gagal menghapus kantong';
      try {
        final data = jsonDecode(res.body);
        if (data['message'] != null) msg = data['message'].toString();
      } catch (_) {}
      throw Exception(msg);
    }
  }
}