import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_go/core/base/base_view.dart';
import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/constants/app_image.dart';
import 'package:event_go/core/constants/app_strings.dart';
import 'package:event_go/core/utils/extension.dart';
import 'package:event_go/core/widgets/app_elevated_button.dart';
import 'package:event_go/core/widgets/event_card.dart';
import 'package:event_go/core/widgets/order_history_card.dart';
import 'package:event_go/injection/injection.dart';
import 'package:event_go/presentation/view_models/home_view_model.dart';
import 'package:event_go/routers/router_name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TicketOrderScreen extends StatefulWidget {
  final String? statusFilter;

  const TicketOrderScreen({Key? key, this.statusFilter}) : super(key: key);

  @override
  State<TicketOrderScreen> createState() => _TicketOrderScreenState();
}

class _TicketOrderScreenState extends State<TicketOrderScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  Map<String, dynamic> _getStatusDisplay(String? status) {
    switch (status) {
      case 'completed':
        return {'text': context.appLocaleLanguage.success, 'color': Colors.green};
      case 'cancelled':
        return {'text': context.appLocaleLanguage.cancelled, 'color': Colors.red};
      case 'failed':
        return {'text': context.appLocaleLanguage.failed, 'color': Colors.orange};
      default:
        return {'text': context.appLocaleLanguage.unknown, 'color': Colors.grey};
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BaseView<HomeViewModel>(
      viewModelBuilder: () => getIt<HomeViewModel>(),
      padding: false,
      autoDispose: false,
      onModelReady: (viewModel) {
        viewModel.watchAll();
      },
      builder: (context, viewModel, child) {
        final ordersStream = viewModel.ordersStream;
        if (ordersStream == null) {
          return _buildEmptyState(
            context.appLocaleLanguage.pleaseLoginToViewTickets,
            Icons.login,
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            children: [
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: ordersStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return _buildEmptyState(
                      AppStrings.errorLoadingOrders.replaceAll(
                        '{error}',
                        snapshot.error.toString(),
                      ),
                      Icons.error,
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmptyState(
                      context.appLocaleLanguage.noOrdersYet,
                      Icons.receipt_long,
                    );
                  }
                  final allOrders = snapshot.data!.docs;
                  final filteredOrders = allOrders.where((doc) {
                    if (widget.statusFilter == null) {
                      return true;
                    }
                    final data = doc.data();
                    final status = data['paymentStatus'] as String?;
                    if (widget.statusFilter == 'failed') {
                      return status == 'failed';
                    }
                    return status == widget.statusFilter;
                  }).toList();
                  if (filteredOrders.isEmpty) {
                    return _buildEmptyState(
                      context.appLocaleLanguage.noOrdersInThisCategory,
                      Icons.inventory_2,
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      ListView.builder(
                        itemCount: filteredOrders.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final orderDoc = filteredOrders[index];
                          final data = orderDoc.data();
                          final String orderId = orderDoc.id;
                          final statusInfo = _getStatusDisplay(
                            data['paymentStatus'] as String?,
                          );
                          final orderDate =
                              (data['createdAt'] as Timestamp?)?.toDate() ??
                              DateTime.now();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: OrderHistoryCard(
                              title:
                                  data['eventName'] as String? ??
                                  context.appLocaleLanguage.eventName,
                              statusText: statusInfo['text'],
                              statusColor: statusInfo['color'],
                              orderCode: orderId,
                              orderDate: orderDate,
                              amount:
                                  (data['totalAmount'] as num?)?.toDouble() ??
                                  0.0,
                              onTap: () {},
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 20),
              Divider(color: Colors.grey, thickness: 1),
              SizedBox(height: 25),
              Center(
                child: Text(
                  context.appLocaleLanguage.youMayAlsoLike,
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              SizedBox(height: 25),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: viewModel.events.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  final event = viewModel.events[index];
                  return EventCard(
                    height: 100,
                    width: 200,
                    imageUrl: event.bannerURL ?? AppImage.banner_1,
                    title: event.title,
                    price: event.minTicketPrice != null
                        ? event.minTicketPrice.toString()
                        : context.appLocaleLanguage.free,
                    date: event.startTime.toString(),
                    onTap: () {
                      context.push(RouterPath.event_detail, extra: event);
                    },
                  );
                },
              ),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.center,
                child: AppElevatedButton(
                  text: context.appLocaleLanguage.seeMore,
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
        );
      },
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
