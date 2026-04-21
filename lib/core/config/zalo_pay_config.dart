
import 'package:dio/dio.dart';
import 'package:event_go/core/config/app_env.dart';
import 'package:event_go/data/models/payment/endpoints.dart';
import 'package:sprintf/sprintf.dart';

import '../../data/models/payment/create_order_response.dart';
import '../../data/models/payment/util.dart' as utils;

class ZaloPayConfig {
  static String get appId => AppEnv.get('ZALOPAY_APP_ID');
  static String get key1 => AppEnv.get('ZALOPAY_KEY1');
  static String get key2 => AppEnv.get('ZALOPAY_KEY2');
  static String get appUser => AppEnv.get('ZALOPAY_APP_USER');
  static int transIdDefault = 1;
}

Future<CreateOrderResponse?> createOrder(int price) async {
  final Dio dio = Dio();

  var body = new Map<String, String>();
  body["app_id"] = ZaloPayConfig.appId;
  body["app_user"] = ZaloPayConfig.appUser;
  body["app_time"] = DateTime.now().millisecondsSinceEpoch.toString();
  body["amount"] = price.toStringAsFixed(0);
  body["app_trans_id"] = utils.getAppTransId();
  body["embed_data"] = "{}";
  body["item"] = "[]";
  body["bank_code"] = utils.getBankCode();
  body["description"] = utils.getDescription(body["app_trans_id"]!);

  var dataGetMac = sprintf("%s|%s|%s|%s|%s|%s|%s", [
    body["app_id"],
    body["app_trans_id"],
    body["app_user"],
    body["amount"],
    body["app_time"],
    body["embed_data"],
    body["item"],
  ]);
  body["mac"] = utils.getMacCreateOrder(dataGetMac);
  print("mac: ${body["mac"]}");

  print("body_request: $body");

  try {
    Response response = await dio.post(
      Endpoints.createOrderUrl,
      data: body,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    var data = response.data;
    return CreateOrderResponse.fromJson(data);
  } on DioException catch (e) {
    print("DioError: ${e.message}");
    if (e.response != null) {
      print("DioError response: ${e.response?.data}");
    }
    return null;
  } catch (e) {
    print("Unexpected error: $e");
    return null;
  }
}
