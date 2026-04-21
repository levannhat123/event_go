import 'package:event_go/data/repositories/order/order_repository.dart';

class CreateOrderUsecase {
  CreateOrderUsecase(this._orderRepository);

  final OrderRepository _orderRepository;

  Future<String> call({
    required String userId,
    required Map<String, dynamic> orderData,
    required bool createGlobalTicket,
  }) async {
    final orderId = await _orderRepository.createUserOrder(
      userId: userId,
      orderData: orderData,
    );
    if (createGlobalTicket) {
      await _orderRepository.createGlobalTicket(
        orderId: orderId,
        orderData: orderData,
      );
    }
    return orderId;
  }
}
