import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subscription.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Subscription>> getUserSubscriptions(String userId) {
    return _db
        .collection('subscriptions')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Subscription.fromFirestore(doc))
            .toList());
  }

  Future<void> addSubscription(Subscription sub) {
    return _db.collection('subscriptions').doc(sub.id).set(sub.toFirestore());
  }

  Future<void> updateSubscription(Subscription sub) {
    return _db.collection('subscriptions').doc(sub.id).update(sub.toFirestore());
  }

  Future<void> deleteSubscription(String subId) {
    return _db.collection('subscriptions').doc(subId).delete();
  }

  Future<void> markUsedToday(Subscription sub) async {
    final now = DateTime.now();
    final updatedHistory = List<DateTime>.from(sub.usageHistory)..add(now);
    
    await _db.collection('subscriptions').doc(sub.id).update({
      'usageHistory': updatedHistory.map((d) => Timestamp.fromDate(d)).toList(),
    });
  }
}
