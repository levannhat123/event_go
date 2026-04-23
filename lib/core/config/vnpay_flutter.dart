import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:event_go/core/config/app_env.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:event_go/core/constants/app_colors.dart';

enum VNPayHashType { SHA256, HMACSHA512 }

class VNPAYFlutter {
  static final VNPAYFlutter _instance = VNPAYFlutter();
  static VNPAYFlutter get instance => _instance;
  static String get tmnCode => AppEnv.get('VNPAY_TMN_CODE');
  static String get hashKey => AppEnv.get('VNPAY_HASH_KEY');
  static String get paymentUrl =>
      AppEnv.get('VNPAY_URL');

  Map<String, dynamic> _sortParams(Map<String, dynamic> params) {
    final sortedParams = <String, dynamic>{};
    final keys = params.keys.toList()..sort();
    for (String key in keys) {
      sortedParams[key] = params[key];
    }
    return sortedParams;
  }

  String generatePaymentUrl({
    String url = 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html',
    required String version,
    String command = 'pay',
    required String tmnCode,
    String locale = 'vn',
    String currencyCode = 'VND',
    required String txnRef,
    String orderInfo = 'Pay Order',
    required double amount,
    required String returnUrl,
    required String ipAdress,
    String? createAt,
    String? expireAt,
    String orderType = "other",
    required String vnpayHashKey,
    VNPayHashType vnPayHashType = VNPayHashType.HMACSHA512,
  }) {
    final params = <String, dynamic>{
      'vnp_Version': version,
      'vnp_Command': command,
      'vnp_TmnCode': tmnCode,
      'vnp_Locale': locale,
      'vnp_CurrCode': currencyCode,
      'vnp_TxnRef': txnRef,
      'vnp_OrderInfo': orderInfo,
      'vnp_OrderType': orderType,
      'vnp_Amount': (amount * 100).toStringAsFixed(0),
      'vnp_ReturnUrl': returnUrl,
      'vnp_IpAddr': ipAdress,
      'vnp_CreateDate':
          createAt ??
          DateFormat('yyyyMMddHHmmss').format(DateTime.now()).toString(),
      'vnp_ExpireDate':
          expireAt ??
          DateFormat(
            'yyyyMMddHHmmss',
          ).format(DateTime.now().add(Duration(minutes: 15))).toString(),
    };
    var sortedParam = _sortParams(params);
    final hashDataBuffer = StringBuffer();
    sortedParam.forEach((key, value) {
      hashDataBuffer.write(key);
      hashDataBuffer.write('=');
      hashDataBuffer.write(value);
      hashDataBuffer.write('&');
    });
    String hashData = hashDataBuffer.toString().substring(
      0,
      hashDataBuffer.length - 1,
    );
    String query = Uri(queryParameters: sortedParam).query;

    String vnpSecureHash = "";

    if (vnPayHashType == VNPayHashType.SHA256) {
      List<int> bytes = utf8.encode(vnpayHashKey + hashData.toString());
      vnpSecureHash = sha256.convert(bytes).toString();
    } else {
      vnpSecureHash = Hmac(
        sha512,
        utf8.encode(vnpayHashKey),
      ).convert(utf8.encode(query)).toString();
    }
    String paymentUrl = "$url?$query&vnp_SecureHash=$vnpSecureHash";
    return paymentUrl;
  }

  void show({
    required BuildContext context,
    required String paymentUrl,
    Function(Map<String, dynamic>)? onPaymentSuccess,
    Function(Map<String, dynamic>)? onPaymentError,
    Function()? onWebPaymentComplete,
  }) async {
    if (kIsWeb) {
      await launchUrl(Uri.parse(paymentUrl), webOnlyWindowName: '_self');
      if (onWebPaymentComplete != null) {
        onWebPaymentComplete();
      }
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VNPAYWebView(
            paymentUrl: paymentUrl,
            onPaymentSuccess: onPaymentSuccess,
            onPaymentError: onPaymentError,
          ),
        ),
      );
    }
  }
}

class VNPAYWebView extends StatefulWidget {
  final String paymentUrl;
  final Function(Map<String, dynamic>)? onPaymentSuccess;
  final Function(Map<String, dynamic>)? onPaymentError;

  const VNPAYWebView({
    Key? key,
    required this.paymentUrl,
    this.onPaymentSuccess,
    this.onPaymentError,
  }) : super(key: key);

  @override
  State<VNPAYWebView> createState() => _VNPAYWebViewState();
}

class _VNPAYWebViewState extends State<VNPAYWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.color00000000)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},

          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains('vnp_ResponseCode')) {
              final params = Uri.parse(request.url).queryParameters;

              if (params['vnp_ResponseCode'] == '00') {
                if (widget.onPaymentSuccess != null) {
                  widget.onPaymentSuccess!(params);
                }
              } else {
                if (widget.onPaymentError != null) {
                  widget.onPaymentError!(params);
                }
              }
              Navigator.pop(context);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thanh toán VNPAY"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (widget.onPaymentError != null) {
              widget.onPaymentError!({'vnp_ResponseCode': '24'});
            }
            Navigator.pop(context);
          },
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
