import 'package:dio/dio.dart';
import '../api/api_client.dart';

class PaymentService {
  final Dio _dio = ApiClient().dio;

  Future<List<dynamic>> list({String? day, String? month, String? year}) async {
    final qp = <String, dynamic>{};
    if (day != null && day.isNotEmpty) qp['day'] = day;
    if (month != null && month.isNotEmpty) qp['month'] = month;
    if (year != null && year.isNotEmpty) qp['year'] = year;
    final res = await _dio.get('/payments', queryParameters: qp);
    return List<dynamic>.from(res.data['data']);
  }

  Future<Map<String, dynamic>> create({
    required String description,
    required num amount,
    required String category,
    List<int>? receiptBytes,
    String? receiptFileName,
  }) async {
    if (receiptBytes == null) {
      final res = await _dio.post('/payments', data: {
        'description': description,
        'amount': amount,
        'category': category,
      });
      return Map<String, dynamic>.from(res.data['payment']);
    } else {
      final form = FormData.fromMap({
        'description': description,
        'amount': amount,
        'category': category,
        'receipt': MultipartFile.fromBytes(
          receiptBytes,
          filename: receiptFileName ?? 'receipt.bin',
        ),
      });
      final res = await _dio.post('/payments', data: form);
      return Map<String, dynamic>.from(res.data['payment']);
    }
  }

  Future<Map<String, dynamic>> dashboard() async {
    final res = await _dio.get('/dashboard');
    return Map<String, dynamic>.from(res.data['data']);
  }
}
