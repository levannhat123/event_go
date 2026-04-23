import 'package:event_go/data/repositories/order/order_repository.dart';

class GetSoldTicketsByEventUsecase {
  GetSoldTicketsByEventUsecase(this._orderRepository);

  final OrderRepository _orderRepository;

  Future<Map<String, int>> call() async {
    final snapshot = await _orderRepository.getCompletedTickets();
    final Map<String, int> soldMap = {};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final eventId = data['eventId'] as String?;
      final List tickets = data['tickets'] ?? [];
      if (eventId == null) continue;
      int totalQty = 0;
      for (final t in tickets) {
        totalQty += (t['quantity'] ?? 0) as int;
      }
      soldMap[eventId] = (soldMap[eventId] ?? 0) + totalQty;
    }
    return soldMap;
  }
}
