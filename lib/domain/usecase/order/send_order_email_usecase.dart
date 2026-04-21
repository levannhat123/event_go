import 'package:dio/dio.dart';

class SendOrderEmailUsecase {
  SendOrderEmailUsecase();

  final String _emailJSServiceID = 'service_ylcyotg';
  final String _emailJSTemplateID = 'template_w5qexdc';
  final String _emailJSPublicKey = 'eU0EwYJSkgAxSxz3K';

  Future<void> call({
    required String orderId,
    required String userEmail,
    required String eventName,
  }) async {
    final dio = Dio();
    final qrCodeUrl =
        'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=$orderId';

    await dio.post(
      'https://api.emailjs.com/api/v1.0/email/send',
      data: {
        'service_id': _emailJSServiceID,
        'template_id': _emailJSTemplateID,
        'user_id': _emailJSPublicKey,
        'template_params': {
          'email': userEmail,
          'order_id': orderId,
          'event_name': eventName,
          'qr_code_url': qrCodeUrl,
        },
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http://localhost',
        },
      ),
    );
  }
}
