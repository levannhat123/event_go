import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/constants/app_image.dart';
import 'package:event_go/core/widgets/app_elevated_button.dart';
import 'package:event_go/core/widgets/event_card.dart';
import 'package:event_go/core/widgets/order_history_card.dart';
import 'package:flutter/material.dart';

class TicketOrderScreen extends StatefulWidget {
  const TicketOrderScreen({Key? key}) : super(key: key);

  @override
  State<TicketOrderScreen> createState() => _TicketOrderScreenState();
}

class _TicketOrderScreenState extends State<TicketOrderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OrderHistoryCard(
                title: '[Hồ Chí Minh] Xe bus 2 tầng City Sightseeing',
                statusText: 'Đã hủy',
                statusColor: Colors.red,
                orderCode: '5AIT69YD',
                orderDate: DateTime(2025, 10, 15, 21, 34),
                amount: 200000,
                onTap: () {
                  print('Card Đã hủy được nhấn!');
                },
              ),
              SizedBox(height: 10),
              OrderHistoryCard(
                title: '[Đà Nẵng] Vé cáp treo Bà Nà Hills',
                statusText: 'Thành công',
                statusColor: Colors.green,
                orderCode: 'DN2B3C4D',
                orderDate: DateTime(2025, 10, 14, 10, 05),
                amount: 850000,
                onTap: () {
                  print('Card Thành công được nhấn!');
                },
              ),
              SizedBox(height: 10),
              OrderHistoryCard(
                title: '[Hà Nội] Tour ẩm thực phố cổ',
                statusText: 'Đang xử lý',
                statusColor: Colors.orange,
                orderCode: 'HN5F6G7H',
                orderDate: DateTime.now(),
                amount: 550000,
                onTap: () {
                  print('Card Đang xử lý được nhấn!');
                },
              ),
              SizedBox(height: 20),
              Divider(color: Colors.grey, thickness: 1),
              SizedBox(height: 25),
              Center(
                child: Text(
                  'Có thể bạn cũng thích',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              SizedBox(height: 25),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.8,
                children: [
                  EventCard(
                    height: 100,
                    width: 200,
                    imageUrl: AppImage.banner_1,
                    title: "LULULOLA SHOW TĂNG PHÚC | MONG MANH NỖI ĐAU",
                    price: 'Từ 570.000đ',
                    date: '13 tháng 12, 2025',
                  ),
                  EventCard(
                    height: 100,
                    width: 200,
                    imageUrl: AppImage.banner_2,
                    title: "LULULOLA SHOW TĂNG PHÚC | MONG MANH NỖI ĐAU",
                    price: 'Từ 570.000đ',
                    date: '13 tháng 12, 2025',
                  ),
                  EventCard(
                    height: 100,
                    width: 200,
                    imageUrl: AppImage.banner_3,
                    title: "LULULOLA SHOW TĂNG PHÚC | MONG MANH NỖI ĐAU",
                    price: 'Từ 570.000đ',
                    date: '13 tháng 12, 2025',
                  ),
                  EventCard(
                    height: 100,
                    width: 200,
                    imageUrl: AppImage.banner_4,
                    title: "LULULOLA SHOW TĂNG PHÚC | MONG MANH NỖI ĐAU",
                    price: 'Từ 570.000đ',
                    date: '13 tháng 12, 2025',
                  ),
                  EventCard(
                    height: 100,
                    width: 200,
                    imageUrl: AppImage.banner_1,
                    title: "LULULOLA SHOW TĂNG PHÚC | MONG MANH NỖI ĐAU",
                    price: 'Từ 570.000đ',
                    date: '13 tháng 12, 2025',
                  ),
                  EventCard(
                    height: 100,
                    width: 200,
                    imageUrl: AppImage.banner_2,
                    title: "LULULOLA SHOW TĂNG PHÚC | MONG MANH NỖI ĐAU",
                    price: 'Từ 570.000đ',
                    date: '13 tháng 12, 2025',
                  ),
                  EventCard(
                    height: 100,
                    width: 200,
                    imageUrl: AppImage.banner_3,
                    title: "LULULOLA SHOW TĂNG PHÚC | MONG MANH NỖI ĐAU",
                    price: 'Từ 570.000đ',
                    date: '13 tháng 12, 2025',
                  ),
                  EventCard(
                    height: 100,
                    width: 200,
                    imageUrl: AppImage.banner_4,
                    title: "LULULOLA SHOW TĂNG PHÚC | MONG MANH NỖI ĐAU",
                    price: 'Từ 570.000đ',
                    date: '13 tháng 12, 2025',
                  ),
                ],
              ),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.center,
                child: AppElevatedButton(
                  text: 'Xem thêm',
                  onPressed: () {},
                  height: 40,
                  width: 120,
                  textColor: AppColors.white,
                  color: Color(0xFFf49415),
                  fontSize: 15.0,
                  borderColor: Color(0xFFf49415),
                  splashColor: AppColors.transparent,
                  highlightColor: AppColors.white,
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
