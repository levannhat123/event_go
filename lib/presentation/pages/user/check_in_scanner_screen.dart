import 'package:flutter/material.dart';
import 'package:event_go/core/base/base_view.dart';
import 'package:event_go/core/constants/app_strings.dart';
import 'package:event_go/injection/injection.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../view_models/home_view_model.dart';

class CheckInScannerScreen extends StatefulWidget {
  const CheckInScannerScreen({Key? key}) : super(key: key);

  @override
  State<CheckInScannerScreen> createState() => _CheckInScannerScreenState();
}

class _CheckInScannerScreenState extends State<CheckInScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;
  String? _scanResult;

  // Thêm state tùy chỉnh để theo dõi đèn và camera
  bool _isTorchOn = false;
  bool _isFrontCamera = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<HomeViewModel>(
      viewModelBuilder: () => getIt<HomeViewModel>(),
      autoDispose: false,
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppStrings.scanCheckInCode),
            actions: [
              // Nút bật/tắt đèn flash
              IconButton(
                icon: Icon(
                  _isTorchOn ? Icons.flash_on : Icons.flash_off,
                  color: Colors.white,
                ),
                onPressed: () {
                  _scannerController.toggleTorch();
                  setState(() {
                    _isTorchOn = !_isTorchOn;
                  });
                },
              ),
              // Nút lật camera
              IconButton(
                icon: Icon(
                  _isFrontCamera ? Icons.camera_front : Icons.camera_rear,
                  color: Colors.white,
                ),
                onPressed: () {
                  _scannerController.switchCamera();
                  setState(() {
                    _isFrontCamera = !_isFrontCamera;
                  });
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              MobileScanner(
                controller: _scannerController,
                onDetect: (BarcodeCapture capture) {
                  _handleDetection(context, viewModel, capture);
                },
              ),
              // Lớp phủ hiển thị tạm thời trạng thái xử lý
              if (_scanResult != null)
                Container(
                  color: Colors.black.withOpacity(0.7),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      _scanResult!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Xử lý khi phát hiện mã
  void _handleDetection(BuildContext context, HomeViewModel viewModel, BarcodeCapture capture) {
    if (_isProcessing) return; // Nếu đang xử lý thì bỏ qua

    final String? orderId = capture.barcodes.first.rawValue;
    if (orderId != null && orderId.isNotEmpty) {
      setState(() {
        _isProcessing = true;
        _scanResult = AppStrings.processingCheckIn.replaceAll('{orderId}', orderId);
      });

      _processCheckIn(context, viewModel, orderId);
    }
  }

  /// Hàm xử lý logic check-in
  Future<void> _processCheckIn(BuildContext context, HomeViewModel viewModel, String orderId) async {
    final String message = await viewModel.processCheckIn(orderId);
    final bool isSuccess = message.startsWith(AppStrings.successPrefix);

    setState(() {
      _scanResult = message;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isSuccess ? Colors.green : Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() {
        _isProcessing = false;
        _scanResult = null; // Ẩn thông báo
      });
    }
  }
}
