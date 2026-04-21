import 'package:event_go/core/constants/app_colors.dart'; // Đảm bảo import đúng file màu của bạn
import 'package:event_go/routers/router_name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PaymentResultVnPlayScreen extends StatelessWidget {
  final bool isSuccess;
  final String message;
  final String transactionId;

  const PaymentResultVnPlayScreen({
    super.key,
    required this.isSuccess,
    required this.message,
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context) {
    final Color statusColor = isSuccess ? AppColors.green : AppColors.red;
    final IconData statusIcon = isSuccess ? Icons.check_circle : Icons.error;
    final String title = isSuccess ? "Thanh toán thành công" : "Thanh toán thất bại";
    final String btnText = isSuccess ? "Xem vé của tôi" : "Thử lại";

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Mã giao dịch: $transactionId",
                  style: const TextStyle(
                    color: AppColors.white70,
                    fontSize: 12,
                    fontFamily: "Courier",
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // 2 Nút bấm
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        context.go(RouterPath.home);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          ),
                      ),
                      child: const Text(
                         "Về trang chính",
                        style: TextStyle(color: AppColors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (isSuccess) {

                          context.go(RouterPath.ticket);
                        } else {
                          context.pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: statusColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        btnText,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}