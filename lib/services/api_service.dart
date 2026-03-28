import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/report.dart';

class ApiService {
  static Future<String> get deviceId async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('device_id') ?? 'AND-UNKNOWN';
  }

  static Future<Map<String, String>> get headers async {
    return {
      'X-Device-ID': await deviceId,
      'Content-Type': 'application/json',
    };
  }

  // ── جلب البلاغات ──────────────────────────────────────────
  static Future<List<Report>> getReports({
    String? status,
    String? category,
    int limit = 50,
  }) async {
    final params = <String, String>{'limit': limit.toString()};
    if (status != null) params['status'] = status;
    if (category != null) params['category'] = category;

    final uri = Uri.parse('${AppConstants.baseUrl}/reports')
        .replace(queryParameters: params);

    final response = await http.get(uri, headers: await headers);
    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((r) => Report.fromJson(r)).toList();
    }
    throw Exception('فشل جلب البلاغات');
  }

  // ── إرسال بلاغ ────────────────────────────────────────────
  static Future<Report> submitReport({
    required File image,
    required String category,
    required String severity,
    required double latitude,
    required double longitude,
    String? description,
  }) async {
    final id = await deviceId;
    final uri = Uri.parse('${AppConstants.baseUrl}/reports').replace(
      queryParameters: {
        'category': category,
        'severity': severity,
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        if (description != null && description.isNotEmpty)
          'description': description,
      },
    );

    final request = http.MultipartRequest('POST', uri)
      ..headers['X-Device-ID'] = id
      ..files.add(await http.MultipartFile.fromPath('image', image.path));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 201) {
      return Report.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else if (response.statusCode == 429) {
      throw Exception('تجاوزت الحد اليومي (30 بلاغات/يوم)');
    }
    throw Exception('فشل إرسال البلاغ: ${response.statusCode}');
  }

  // ── جلب بلاغاتي ───────────────────────────────────────────
  static Future<List<Report>> getMyReports() async {
    final id = await deviceId;
    final uri = Uri.parse('${AppConstants.baseUrl}/reports')
        .replace(queryParameters: {'limit': '100'});

    final response = await http.get(uri, headers: await headers);
    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));
      return data
          .map((r) => Report.fromJson(r))
          .where((r) => r.deviceId == id)
          .toList();
    }
    throw Exception('فشل جلب بلاغاتك');
  }

  // ── تسجيل FCM Token ───────────────────────────────────────
  static Future<void> registerFCMToken({
    required String fcmToken,
    double? latitude,
    double? longitude,
  }) async {
    final id = await deviceId;
    await http.post(
      Uri.parse('${AppConstants.baseUrl}/device/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'device_id': id,
        'fcm_token': fcmToken,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      }),
    );
  }

  // ── تأكيد البلاغ ──────────────────────────────────────────
  static Future<void> confirmReport(String reportId) async {
    await http.post(
      Uri.parse('${AppConstants.baseUrl}/reports/$reportId/confirm'),
      headers: await headers,
    );
  }

  // ── التصويت للبلاغ ────────────────────────────────────────
  static Future<void> voteReport(String reportId) async {
    await http.post(
      Uri.parse('${AppConstants.baseUrl}/reports/$reportId/vote'),
      headers: await headers,
    );
  }

  // ── متابعة البلاغ ─────────────────────────────────────────
  static Future<bool> toggleSubscribe(String reportId) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/reports/$reportId/subscribe'),
      headers: await headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['subscribed'] as bool;
    }
    return false;
  }
}
