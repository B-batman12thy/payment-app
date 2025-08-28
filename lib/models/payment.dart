class Payment {
  final int id;
  final int userId;
  final String description;
  final double amount;
  final String status;
  final String category;
  final String? receiptUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? paidAt;

  Payment({
    required this.id,
    required this.userId,
    required this.description,
    required this.amount,
    required this.status,
    required this.category,
    required this.receiptUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.paidAt,
  });

  factory Payment.fromJson(Map<String, dynamic> j) => Payment(
    id: j['id'] as int,
    userId: j['user_id'] as int,
    description: j['description'] as String,
    amount: double.tryParse(j['amount'].toString()) ?? 0,
    status: j['status'] as String,
    category: j['category'] as String,
    receiptUrl: j['receipt_url'] as String?,
    createdAt: DateTime.parse(j['created_at'] as String),
    updatedAt: DateTime.parse(j['updated_at'] as String),
    paidAt: j['paid_at'] != null ? DateTime.parse(j['paid_at'] as String) : null,
  );
}
