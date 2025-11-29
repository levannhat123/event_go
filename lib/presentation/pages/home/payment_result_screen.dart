import 'package:event_go/core/constants/app_strings.dart';
import 'package:event_go/routers/router_name.dart'; // Đảm bảo bạn có RouterPath.home
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PaymentResultScreen extends StatelessWidget {
  final String? code;
  final String? appTransID;
  final String? message;

  const PaymentResultScreen({
    Key? key,
    this.code,
    this.appTransID,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSuccess = code == '1';

    String decodedMessage;
    if (message != null) {
      try {
        decodedMessage = Uri.decodeQueryComponent(message!);
      } catch (e) {
        decodedMessage = message!;
      }
    } else {
      decodedMessage = isSuccess ? AppStrings.paymentSuccess : AppStrings.paymentFailure;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(AppStrings.transactionResultTitle),
        backgroundColor: const Color(0xFF596DC3),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSuccess ? Icons.check_circle_outline : Icons.highlight_off,
                color: isSuccess ? Colors.green : Colors.red,
                size: 100,
              ),
              const SizedBox(height: 24),
              Text(
                isSuccess ? AppStrings.paymentSuccessWithExclamation : AppStrings.paymentFailure,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                decodedMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 16,
                ),
              ),
              if (appTransID != null) ...[
                const SizedBox(height: 16),
                Text(
                  "${AppStrings.transactionCodeLabel}$appTransID",
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ],
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF596DC3),
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                   context.go(RouterPath.ticket);
                },
                child: Text(
                  AppStrings.backToHomeButton,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}