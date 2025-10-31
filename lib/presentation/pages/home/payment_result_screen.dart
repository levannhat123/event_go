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
    // ZaloPay trả về '1' là thành công
    final bool isSuccess = code == '1';

    String decodedMessage;
    if (message != null) {
      try {
        // 1. Dùng hàm decodeQueryComponent
        decodedMessage = Uri.decodeQueryComponent(message!);
      } catch (e) {
        // 2. Nếu giải mã vẫn lỗi, hiển thị tạm message gốc
        decodedMessage = message!;
      }
    } else {
      decodedMessage = isSuccess ? "Thanh toán thành công" : "Thanh toán thất bại";
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Màu nền giống app của bạn
      appBar: AppBar(
        title: Text("Kết quả giao dịch"),
        backgroundColor: const Color(0xFF596DC3), // Màu AppBar giống của bạn
        centerTitle: true,
        automaticallyImplyLeading: false, // Ẩn nút back
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
                isSuccess ? "Thanh toán thành công!" : "Thanh toán thất bại",
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
                  "Mã giao dịch: $appTransID",
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
                  // Quay về trang chủ (hoặc trang vé)
                  context.go(RouterPath.home);
                },
                child: const Text(
                  "Về trang chủ",
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