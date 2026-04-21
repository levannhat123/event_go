import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_go/data/repositories/order/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> watchUserOrders(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Future<String> createUserOrder({
    required String userId,
    required Map<String, dynamic> orderData,
  }) async {
    final docRef = await _firestore
        .collection('users')
        .doc(userId)
        .collection('orders')
        .add(orderData);
    return docRef.id;
  }

  @override
  Future<void> createGlobalTicket({
    required String orderId,
    required Map<String, dynamic> orderData,
  }) async {
    await _firestore.collection('tickets').doc(orderId).set(orderData);
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> watchCompletedTicketsByEvent(
    String eventId,
  ) {
    return _firestore
        .collection('tickets')
        .where('eventId', isEqualTo: eventId)
        .where('paymentStatus', isEqualTo: 'completed')
        .snapshots();
  }

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getCompletedTickets() {
    return _firestore
        .collection('tickets')
        .where('paymentStatus', isEqualTo: 'completed')
        .get();
  }

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getAllCategories() {
    return _firestore.collection('categories').get();
  }
}
