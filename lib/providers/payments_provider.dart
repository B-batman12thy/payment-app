import 'package:flutter/foundation.dart';
import '../models/payment.dart';
import '../services/payment_service.dart';

class PaymentsProvider with ChangeNotifier {
  final _service = PaymentService();

  bool loading = false;
  List<Payment> items = [];
  String? day;
  String? month;
  String? year;

  Future<void> fetch() async {
    loading = true; notifyListeners();
    try {
      final data = await _service.list(day: day, month: month, year: year);
      items = data.map((e) => Payment.fromJson(e)).toList();
    } finally {
      loading = false; notifyListeners();
    }
  }

  Future<Payment?> create({
    required String description,
    required num amount,
    required String category,
    List<int>? receiptBytes,
    String? receiptFileName,
  }) async {
    final json = await _service.create(
      description: description,
      amount: amount,
      category: category,
      receiptBytes: receiptBytes,
      receiptFileName: receiptFileName,
    );
    final p = Payment.fromJson(json);
    items.insert(0, p);
    notifyListeners();
    return p;
  }
}
