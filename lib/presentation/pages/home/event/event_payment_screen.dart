import 'package:event_go/core/base/base_view.dart';
import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/constants/app_spacing.dart';
import 'package:event_go/core/utils/extension.dart';
import 'package:event_go/data/models/event/event_detail_model.dart';
import 'package:event_go/injection/injection.dart';
import 'package:event_go/presentation/pages/home/event/widget/event_payment_sections.dart';
import 'package:event_go/presentation/pages/home/event/widget/payment_countdown_banner.dart';
import 'package:event_go/presentation/pages/home/event/widget/payment_event_info_card.dart';
import 'package:event_go/presentation/pages/home/event/widget/payment_footer.dart';
import 'package:event_go/presentation/pages/home/event/widget/payment_method_card.dart';
import 'package:event_go/presentation/pages/home/event/widget/recipient_info_card.dart';
import 'package:event_go/presentation/view_models/event_order_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:event_go/core/constants/app_sizes.dart';

class EventPaymentScreen extends StatefulWidget {
  const EventPaymentScreen({
    super.key,
    required this.token,
    required this.event,
  });

  final String token;
  final EventDetailModel event;

  @override
  State<EventPaymentScreen> createState() => _EventPaymentScreenState();
}

class _EventPaymentScreenState extends State<EventPaymentScreen> {
  @override
  void dispose() {
    getIt<EventOrderViewModel>().disposePaymentTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<EventOrderViewModel>(
      viewModelBuilder: () => getIt<EventOrderViewModel>(),
      padding: false,
      autoDispose: false,
      onModelReady: (viewModel) {
        viewModel.event = widget.event;
        viewModel.initPaymentScreen(widget.token, context);
      },
      builder: (context, viewModel, child) {
        final vmReader = context.read<EventOrderViewModel>();
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.homePrimaryBlue,
            elevation: 0,
            title: Text(context.appLocaleLanguage.paymentTitle),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  PaymentCountdownBanner(
                    formattedTime: viewModel.formattedTimeRemaining,
                  ),
                  PaymentEventInfoCard(event: widget.event),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.space10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionTitle(
                            title: context.appLocaleLanguage.recipientInfoTitle,
                          ),
                          const SizedBox(height: AppSpacing.space12),
                          RecipientInfoCard(email: viewModel.userEmail ?? ''),
                          const SizedBox(height: AppSpacing.space24),
                          _SectionTitle(
                            title: context.appLocaleLanguage.paymentMethodTitle,
                          ),
                          const SizedBox(height: AppSpacing.space12),
                          PaymentMethodCard(
                            selectedMethod: viewModel.selectedPaymentMethod,
                            onChanged: vmReader.selectPaymentMethod,
                          ),
                          const SizedBox(height: AppSpacing.space24),
                          _SectionTitle(
                            title: context.appLocaleLanguage.bookingInfoTitle,
                          ),
                          const SizedBox(height: AppSpacing.space12),
                          OrderInfoCard(viewModel: vmReader),
                          const SizedBox(height: AppSpacing.space20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (viewModel.isLoading)
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: AppColors.black.withValues(alpha: 0.85),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.green),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: viewModel.isLoading
              ? const SizedBox.shrink()
              : PaymentFooter(
                  total: vmReader.grandTotal,
                  onSubmit: () => vmReader.handlePayment(context),
                ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.white,
        fontSize: AppSizes.size18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
