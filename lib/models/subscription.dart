import 'package:cloud_firestore/cloud_firestore.dart';

class Subscription {
  final String id;
  final String userId;
  final String name;
  final String category;
  final double cost;
  final String billingCycle;
  final DateTime nextBillingDate;
  final String logoAssetPath;
  final bool isActive;
  final String androidPackageName;
  final List<DateTime> usageHistory;

  Subscription({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.cost,
    required this.billingCycle,
    required this.nextBillingDate,
    required this.logoAssetPath,
    required this.isActive,
    required this.androidPackageName,
    required this.usageHistory,
  });

  factory Subscription.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Subscription(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      cost: (data['cost'] ?? 0).toDouble(),
      billingCycle: data['billingCycle'] ?? 'monthly',
      nextBillingDate: (data['nextBillingDate'] as Timestamp).toDate(),
      logoAssetPath: data['logoAssetPath'] ?? '',
      isActive: data['isActive'] ?? true,
      androidPackageName: data['androidPackageName'] ?? '',
      usageHistory: (data['usageHistory'] as List<dynamic>?)
              ?.map((ts) => (ts as Timestamp).toDate())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'category': category,
      'cost': cost,
      'billingCycle': billingCycle,
      'nextBillingDate': Timestamp.fromDate(nextBillingDate),
      'logoAssetPath': logoAssetPath,
      'isActive': isActive,
      'androidPackageName': androidPackageName,
      'usageHistory': usageHistory.map((d) => Timestamp.fromDate(d)).toList(),
    };
  }

  Subscription copyWith({
    String? id,
    String? userId,
    String? name,
    String? category,
    double? cost,
    String? billingCycle,
    DateTime? nextBillingDate,
    String? logoAssetPath,
    bool? isActive,
    String? androidPackageName,
    List<DateTime>? usageHistory,
  }) {
    return Subscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      cost: cost ?? this.cost,
      billingCycle: billingCycle ?? this.billingCycle,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      logoAssetPath: logoAssetPath ?? this.logoAssetPath,
      isActive: isActive ?? this.isActive,
      androidPackageName: androidPackageName ?? this.androidPackageName,
      usageHistory: usageHistory ?? this.usageHistory,
    );
  }
}
