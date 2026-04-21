import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_go/data/repositories/order/order_repository.dart';

class WatchSoldTicketsByEventUsecase {
  WatchSoldTicketsByEventUsecase(this._orderRepository);

  final OrderRepository _orderRepository;

  Stream<QuerySnapshot<Map<String, dynamic>>> call(String eventId) {
    return _orderRepository.watchCompletedTicketsByEvent(eventId);
  }
}
