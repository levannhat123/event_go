import 'dart:math';

import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/constants/app_image.dart';
import 'package:event_go/core/widgets/app_elevated_button.dart';
import 'package:event_go/core/widgets/event_card.dart';
import 'package:event_go/presentation/pages/home/location_card.dart';
import 'package:event_go/presentation/pages/home/ticket_item_row.dart';
import 'package:event_go/routers/router_name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

import 'package:slider_captcha/slider_captcha.dart';

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({Key? key}) : super(key: key);

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  int _captchaFailCount = 0;
  DateTime? _lockoutEndTime;
  bool isComboSoldOut = true;
  bool _isExpanded = false;
  final List<String> _captchaImages = [AppImage.logo, AppImage.banner_1, AppImage.banner_2];

  String _getRandomImage() {
    final random = Random();
    return _captchaImages[random.nextInt(_captchaImages.length)];
  }

  final String fullText = '''
Với không gian được đầu tư hệ thống ánh sáng - âm thanh đẳng cấp quốc tế với sức chứa lên đến 350 người, cùng quầy bar phục vụ cocktail pha chế độc đáo bởi bartender chuyên nghiệp.

Mùa cuối năm, liệu bạn đã sẵn sàng để tâm hồn đắm mình trong giai điệu, để trái tim tan chảy bởi giọng hát cảm xúc của Hương Tràm vào 20g00 - 9/11/2025 (Chủ nhật) tại Cat&Mouse?

Với những ca khúc quen thuộc đạt hàng trăm triệu lượt xem như “Duyên mình lỡ”, “Em gái mưa”, “Cho em gần anh thêm chút nữa”… kết hợp với hệ thống âm thanh Adamson chuẩn quốc tế của Cat&Mouse sẽ tạo nên một đêm diễn sâu lắng và khó quên dành cho bạn.
''';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE6EAF5),
      appBar: AppBar(
        title: const Text(
          'Chi tiết sự kiện',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF596DC3),
        centerTitle: true,
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.share))],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(color: Colors.black),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: const TextSpan(
                style: TextStyle(color: Colors.white, fontSize: 16),
                children: [
                  TextSpan(text: 'Giá từ` '),
                  TextSpan(
                    text: '500.000 đ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            AppElevatedButton(
              text: 'Mua vé ngay',
              onPressed: () {
                if (_lockoutEndTime != null && DateTime.now().isBefore(_lockoutEndTime!)) {
                  final remaining = _lockoutEndTime!.difference(DateTime.now());
                  final remainingSeconds = remaining.inSeconds + 1;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Bạn đã thử quá 5 lần. Vui lòng thử lại sau $remainingSeconds giây.',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                showDialog(
                  context: context,
                  builder: (dialogContext) {
                    final SliderController controller = SliderController();
                    final ValueNotifier<String?> errorNotifier = ValueNotifier<String?>(null);
                    final ValueNotifier<String> imageNotifier = ValueNotifier<String>(
                      _getRandomImage(),
                    );
                    return Dialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Xác Minh Người Dùng', style: TextStyle(color: Colors.black)),
                                InkWell(
                                  onTap: () {
                                    dialogContext.pop();
                                  },
                                  child: Icon(Icons.close, size: 20, color: Colors.black),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Text('Chống bot tự động mua vé', style: TextStyle(color: Colors.black)),
                            SizedBox(height: 10),
                            Text(
                              'Kéo mũi tên qua phải để hoàn thiện bức hình, giúp EventGo xác minh bạn là người mua thực sự.',
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(height: 20),
                            SliderCaptcha(
                              controller: controller,
                              image: ValueListenableBuilder<String>(
                                valueListenable: imageNotifier,
                                builder: (context, currentImagePath, child) {
                                  return Image.asset(currentImagePath, fit: BoxFit.cover);
                                },
                              ),
                              colorBar: Colors.blue,
                              colorCaptChar: Colors.blue,
                              onConfirm: (success) async {
                                if (success) {
                                  setState(() {
                                    _captchaFailCount = 0;
                                  });
                                  dialogContext.pop();
                                  context.push(RouterPath.booking);
                                } else {
                                  setState(() {
                                    _captchaFailCount++;
                                  });

                                  if (_captchaFailCount >= 5) {
                                    setState(() {
                                      _lockoutEndTime = DateTime.now().add(
                                        const Duration(minutes: 1),
                                      );
                                      _captchaFailCount = 0;
                                    });

                                    dialogContext.pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Bạn đã thử quá 5 lần. Vui lòng thử lại sau 1 phút.',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } else {
                                    errorNotifier.value =
                                        'Xác minh không đúng! (Thử lại: $_captchaFailCount/5)';
                                    await Future.delayed(const Duration(milliseconds: 500));
                                    controller.create();
                                    errorNotifier.value = null;
                                  }
                                }
                              },
                            ),
                            SizedBox(height: 20),

                            Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    controller.create();
                                    errorNotifier.value = null;
                                  },
                                  child: Icon(Icons.refresh, size: 16, color: Colors.grey),
                                ),
                                SizedBox(width: 8),
                                Text('Tải lại', style: TextStyle(color: Colors.black)),
                              ],
                            ),
                            ValueListenableBuilder<String?>(
                              valueListenable: errorNotifier,
                              builder: (context, errorMessage, child) {
                                if (errorMessage != null) {
                                  return Text(errorMessage, style: TextStyle(color: Colors.red));
                                } else {
                                  return SizedBox.shrink();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              height: 40,
              width: 125,
              textColor: AppColors.white,
              color: AppColors.green,
              fontSize: 15.0,
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              borderColor: AppColors.green,
              splashColor: AppColors.transparent,
              highlightColor: AppColors.white,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.6,
              width: double.infinity,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage(AppImage.banner_1),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(decoration: BoxDecoration(color: Colors.black.withOpacity(0.5))),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: EventTicketCard(
                      imagePath: AppImage.banner_1,
                      title: 'ART WORKSHOP "SNICKERS MOUSSE STICK"',
                      date: '17:30 - 19:30, 17 Tháng 10, 2025',
                      location: 'Garden Art',
                      address: 'Lầu 1, 386/17C Lê Văn Sỹ, Phường 14, Quận 3, Thành Phố Hồ Chí Minh',
                    ),
                  ),
                ],
              ),
            ),
            ImprovedLocationCard(
              title: "Làng Marathon: Global City",
              line1: "Đường Đỗ Xuân Hợp, Phường An Khánh,",
              line2: "Thành Phố Hồ Chí Minh",
            ),
            Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Giới thiệu',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const Divider(color: Colors.grey),
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 300),
                      firstChild: Text(
                        fullText,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 15, height: 1.4, color: Colors.black),
                      ),
                      secondChild: Text(
                        fullText,
                        style: const TextStyle(fontSize: 15, height: 1.4, color: Colors.black),
                      ),
                      crossFadeState: _isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                    ),

                    Align(
                      alignment: Alignment.center,
                      child: IconButton(
                        icon: AnimatedRotation(
                          turns: _isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: const Icon(Icons.keyboard_arrow_down, size: 26),
                        ),
                        onPressed: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF2A2D34),
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Text(
                      'Thông tin vé',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Divider(color: Color(0xFF27272A)),
                  ExpansionTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    shape: const Border(),
                    collapsedShape: const Border(),
                    iconColor: Colors.white,
                    collapsedIconColor: Colors.white,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '20:00 - 23:00,',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              '09 tháng 11, 2025',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        AppElevatedButton(
                          text: 'Mua vé ngay',
                          onPressed: () {},
                          height: 40,
                          width: 125,
                          borderRadius: const BorderRadius.all(Radius.circular(4)),
                          textColor: AppColors.white,
                          color: AppColors.green,
                          fontSize: 15.0,
                          borderColor: AppColors.green,
                          splashColor: AppColors.transparent,
                          highlightColor: AppColors.white,
                        ),
                      ],
                    ),
                    childrenPadding: const EdgeInsets.all(12),
                    children: [
                      TicketItemRow(
                        ticketName: 'Regular Ticket',
                        price: '755.000 đ',
                        isSoldOut: false,
                      ),
                      const SizedBox(height: 16),

                      TicketItemRow(
                        ticketName: 'Combo 1 Regular Ticket + 1...',
                        price: '1.081.920 đ',
                        isSoldOut: false,
                      ),
                      const SizedBox(height: 16),

                      TicketItemRow(
                        ticketName: 'Combo 10 Regular Ticket (-15%)',
                        price: '641.750 đ',
                        isSoldOut: true,
                      ),
                      const SizedBox(height: 16),

                      TicketItemRow(
                        ticketName: 'Combo 4 Regular Ticket (-5%)',
                        price: '717.250 đ',
                        isSoldOut: true,
                      ),
                      const SizedBox(height: 16),

                      TicketItemRow(
                        ticketName: 'Early Bird Ticket',
                        price: '620.000 đ',
                        isSoldOut: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ban tổ chức',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const Divider(color: Colors.grey),
                    Image.asset(
                      AppImage.logo,
                      height: 50,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 50,
                        color: Colors.grey[700],
                        child: Icon(Icons.image_not_supported, color: Colors.white, size: 30),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Công ty TNHH Sự Kiện Và Giải Trí Event Go',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Event Go là công ty hàng đầu trong lĩnh vực tổ chức sự kiện và giải trí tại Việt Nam, với nhiều năm kinh nghiệm và đội ngũ chuyên nghiệp, chúng tôi cam kết mang đến những trải nghiệm tuyệt vời và đáng nhớ cho khách hàng.',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
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
          ],
        ),
      ),
    );
  }
}

class EventTicketCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String date;
  final String location;
  final String address;
  final double imageHeight;

  const EventTicketCard({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.date,
    required this.location,
    required this.address,
    this.imageHeight = 250.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: TicketClipper(notchCenterY: imageHeight),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF39383D),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [_buildImageSection(), _buildDetailsSection()],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return ClipPath(
      clipper: JaggedEdgeClipper(),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          height: imageHeight,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) => Container(
            height: imageHeight,
            color: Colors.grey[700],
            child: Icon(Icons.image_not_supported, color: Colors.white, size: 50),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            icon: Icons.calendar_today,
            iconColor: Color(0xFF6AFB92),
            primaryText: date,
            showSecondaryButton: true,
          ),
          const SizedBox(height: 15),
          _buildInfoRow(
            icon: Icons.location_on,
            iconColor: Color(0xFF6AFB92),
            primaryText: location,
            secondaryText: address,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String primaryText,
    String? secondaryText,
    bool showSecondaryButton = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[300], size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                primaryText,
                style: TextStyle(color: iconColor, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              if (secondaryText != null) ...[
                const SizedBox(height: 4),
                Text(
                  secondaryText,
                  style: TextStyle(color: Colors.grey[300], fontSize: 14, height: 1.4),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class TicketClipper extends CustomClipper<Path> {
  final double notchCenterY;
  TicketClipper({required this.notchCenterY});

  @override
  Path getClip(Size size) {
    final path = Path();
    const double notchRadius = 16.0;
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, notchCenterY - notchRadius);
    path.arcToPoint(
      Offset(size.width, notchCenterY + notchRadius),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, notchCenterY + notchRadius);
    path.arcToPoint(
      Offset(0, notchCenterY - notchRadius),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant TicketClipper oldClipper) {
    return oldClipper.notchCenterY != notchCenterY;
  }
}

class JaggedEdgeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height);
    double toothHeight = 4.0;
    double toothWidth = 8.0;
    double gapWidth = 10.0;
    double cornerRadius = 1.0;
    if (cornerRadius > toothHeight / 2) {
      cornerRadius = toothHeight / 2;
    }
    if (cornerRadius > gapWidth / 2) {
      cornerRadius = gapWidth / 2;
    }
    double currentX = 0;
    while (currentX < size.width) {
      currentX += toothWidth;
      if (currentX > size.width) {
        path.lineTo(size.width, size.height);
        break;
      }
      path.lineTo(currentX, size.height);
      if (currentX + gapWidth > size.width) {
        path.lineTo(size.width, size.height);
        break;
      }
      path.lineTo(currentX, size.height - toothHeight + cornerRadius);
      path.arcToPoint(
        Offset(currentX + cornerRadius, size.height - toothHeight),
        radius: Radius.circular(cornerRadius),
        clockwise: false,
      );
      path.lineTo(currentX + gapWidth - cornerRadius, size.height - toothHeight);
      path.arcToPoint(
        Offset(currentX + gapWidth, size.height - toothHeight + cornerRadius),
        radius: Radius.circular(cornerRadius),
        clockwise: false,
      );
      path.lineTo(currentX + gapWidth, size.height);
      currentX += gapWidth;
    }
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
