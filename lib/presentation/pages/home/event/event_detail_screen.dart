import 'dart:math';

import 'package:event_go/core/base/base_view.dart';
import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/constants/app_image.dart';
import 'package:event_go/core/widgets/app_elevated_button.dart';
import 'package:event_go/core/widgets/event_card.dart';
import 'package:event_go/injection/injection.dart';
import 'package:event_go/presentation/pages/home/event/widget/event_ticket_card.dart';
import 'package:event_go/presentation/pages/home/location_card.dart';
import 'package:event_go/presentation/pages/home/ticket_item_row.dart';
import 'package:event_go/presentation/view_models/home_view_model.dart';
import 'package:event_go/routers/router_name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:slider_captcha/slider_captcha.dart';

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({Key? key}) : super(key: key);

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  @override
  Widget build(BuildContext context) {
    // 1. Bọc bằng BaseView
    return BaseView<HomeViewModel>(
      viewModelBuilder: () => getIt<HomeViewModel>(),
      autoDispose: false, // Vì là Singleton
      onModelReady: (viewModel) {
        viewModel.initEventDetail(); // 2. Reset state của màn hình này
      },
      builder: (context, viewModel, child) {
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
                      TextSpan(text: 'Giá từ '), // Sửa 'Giá từ` '
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
                    // 3. Đọc state từ VM
                    if (viewModel.isLockedOut) {
                      final remainingSeconds =
                          viewModel.lockoutRemainingSeconds;
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

                    viewModel.refreshCaptchaImage();

                    showDialog(
                      context: context,
                      builder: (dialogContext) {
                        final SliderController controller = SliderController();

                        // 5. Cung cấp VM cho Dialog
                        return ChangeNotifierProvider.value(
                          value: viewModel,
                          // 6. Dùng Consumer theo yêu cầu của bạn
                          child: Consumer<HomeViewModel>(
                            builder: (context, vm, _) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Xác Minh Người Dùng',
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              dialogContext.pop();
                                            },
                                            child: Icon(
                                              Icons.close,
                                              size: 20,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 20),
                                      Text(
                                        'Chống bot tự động mua vé',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'Kéo mũi tên qua phải để hoàn thiện bức hình, giúp EventGo xác minh bạn là người mua thực sự.',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      SizedBox(height: 20),
                                      SliderCaptcha(
                                        controller: controller,
                                        image: Image.asset(
                                          vm.currentCaptchaImage, // 7. Dùng ảnh đã lưu
                                          fit: BoxFit.cover,
                                        ),
                                        colorBar: Colors.blue,
                                        colorCaptChar: Colors.blue,
                                        onConfirm: (success) async {
                                          // 8. Gọi logic VM
                                          final result = vm.onCaptchaConfirm(
                                            success,
                                          );

                                          if (result == CaptchaResult.success) {
                                            dialogContext.pop();
                                            context.push(RouterPath.booking);
                                          } else if (result ==
                                              CaptchaResult.lockedOut) {
                                            dialogContext.pop();
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Bạn đã thử quá 5 lần. Vui lòng thử lại sau 1 phút.',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          } else {
                                            // Fail
                                            // VM đã set lỗi, Consumer tự rebuild
                                            await Future.delayed(
                                              const Duration(milliseconds: 500),
                                            );
                                            controller.create();
                                            // Lấy ảnh mới cho lần thử sau
                                            vm.refreshCaptchaImage();
                                            vm.clearCaptchaError(); // Xóa lỗi
                                          }
                                        },
                                      ),
                                      SizedBox(height: 20),
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              controller.create();
                                              // Lấy ảnh mới
                                              vm.refreshCaptchaImage();
                                              vm.clearCaptchaError();
                                            },
                                            child: Icon(
                                              Icons.refresh,
                                              size: 16,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Tải lại',
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // 9. Hiển thị lỗi từ VM
                                      if (vm.captchaErrorText != null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8.0,
                                          ),
                                          child: Text(
                                            vm.captchaErrorText!,
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        )
                                      else
                                        SizedBox.shrink(),
                                    ],
                                  ),
                                ),
                              );
                            },
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
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: EventTicketCard(
                          imagePath: AppImage.banner_1,
                          title: 'ART WORKSHOP "SNICKERS MOUSSE STICK"',
                          date: '17:30 - 19:30, 17 Tháng 10, 2025',
                          location: 'Garden Art',
                          address:
                              'Lầu 1, 386/17C Lê Văn Sỹ, Phường 14, Quận 3, Thành Phố Hồ Chí Minh',
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
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
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
                            viewModel.eventFullText, // 10. Đọc text từ VM
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.4,
                              color: Colors.black,
                            ),
                          ),
                          secondChild: Text(
                            viewModel.eventFullText, // 10. Đọc text từ VM
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.4,
                              color: Colors.black,
                            ),
                          ),
                          crossFadeState:
                              viewModel
                                  .isExpanded // 11. Đọc state từ VM
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: IconButton(
                            icon: AnimatedRotation(
                              turns: viewModel.isExpanded
                                  ? 0.5
                                  : 0, // 11. Đọc state từ VM
                              duration: const Duration(milliseconds: 300),
                              child: const Icon(
                                Icons.keyboard_arrow_down,
                                size: 26,
                              ),
                            ),
                            onPressed: () {
                              viewModel
                                  .toggleDescriptionExpanded(); // 12. Gọi VM
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
                              onPressed: () {
                                // TODO: Bạn có thể gọi lại logic show dialog ở đây
                                // (Giống hệt nút ở bottomNavigationBar)
                              },
                              height: 40,
                              width: 125,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(4),
                              ),
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
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
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
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 50,
                                color: Colors.grey[700],
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.white,
                                  size: 30,
                                ),
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
                            title:
                                "LULULOLA SHOW TĂNG PHÚC | MONG MANH NỖI ĐAU",
                            price: 'Từ 570.000đ',
                            date: '13 tháng 12, 2025',
                          ),
                          EventCard(
                            height: 100,
                            width: 200,
                            imageUrl: AppImage.banner_2,
                            title:
                                "LULULOLA SHOW TĂNG PHÚC | MONG MANH NỖI ĐAU",
                            price: 'Từ 570.000đ',
                            date: '13 tháng 12, 2025',
                          ),
                          EventCard(
                            height: 100,
                            width: 200,
                            imageUrl: AppImage.banner_3,
                            title:
                                "LULULOLA SHOW TĂNG PHÚC | MONG MANH NỖI ĐAU",
                            price: 'Từ 570.000đ',
                            date: '13 tháng 12, 2025',
                          ),
                          EventCard(
                            height: 100,
                            width: 200,
                            imageUrl: AppImage.banner_4,
                            title:
                                "LULULOLA SHOW TĂNG PHÚC | MONG MANH NỖI ĐAU",
                            price: 'Từ 570.000đ',
                            date: '13 tháng 12, 2025',
                          ),
                          EventCard(
                            height: 100,
                            width: 200,
                            imageUrl: AppImage.banner_1,
                            title:
                                "LULULOLA SHOW TĂNG PHÚC | MONG MANH NỖI ĐAU",
                            price: 'Từ 570.000đ',
                            date: '13 tháng 12, 2025',
                          ),
                          EventCard(
                            height: 100,
                            width: 200,
                            imageUrl: AppImage.banner_2,
                            title:
                                "LULULOLA SHOW TĂNG PHÚC | MONG MANH NỖI ĐAU",
                            price: 'Từ 570.000đ',
                            date: '13 tháng 12, 2025',
                          ),
                          EventCard(
                            height: 100,
                            width: 200,
                            imageUrl: AppImage.banner_3,
                            title:
                                "LULULOLA SHOW TĂNG PHÚC | MONG MANH NỖI ĐAU",
                            price: 'Từ 570.000đ',
                            date: '13 tháng 12, 2025',
                          ),
                          EventCard(
                            height: 100,
                            width: 200,
                            imageUrl: AppImage.banner_4,
                            title:
                                "LULULOLA SHOW TĂNG PHÚC | MONG MANH NỖI ĐAU",
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
      },
    );
  }
}
