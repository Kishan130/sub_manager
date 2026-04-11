import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/firestore_service.dart';
import '../../../../services/firebase_auth_service.dart';
import '../../../../models/subscription.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final userSubscriptionsProvider = StreamProvider<List<Subscription>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  
  final service = ref.watch(firestoreServiceProvider);
  return service.getUserSubscriptions(user.uid);
});
