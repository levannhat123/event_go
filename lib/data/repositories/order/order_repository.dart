import 'package:cloud_firestore/cloud_firestore.dart';

abstract class OrderRepository {
  Stream<QuerySnapshot<Map<String, dynamic>>> watchUserOrders(String userId);

  Future<String> createUserOrder({
    required String userId,
    required Map<String, dynamic> orderData,
  });

  Future<void> createGlobalTicket({
    required String orderId,
    required Map<String, dynamic> orderData,
  });

  Stream<QuerySnapshot<Map<String, dynamic>>> watchCompletedTicketsByEvent(
    String eventId,
  );

  Future<QuerySnapshot<Map<String, dynamic>>> getCompletedTickets();

  Future<QuerySnapshot<Map<String, dynamic>>> getAllCategories();
}
