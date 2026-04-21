import 'package:event_go/core/constants/app_strings.dart';
import 'package:event_go/core/constants/app_storage_key.dart';
import 'package:event_go/core/utils/extension.dart';
import 'package:event_go/core/widgets/custom_tab_bar.dart';
import 'package:event_go/presentation/pages/ticket/ticket_order_screen.dart';
import 'package:flutter/material.dart';
import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/constants/app_sizes.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late List<Tab> tabs;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    tabs = [
      Tab(text: context.appLocaleLanguage.all),
      Tab(text: context.appLocaleLanguage.success),
      Tab(text: context.appLocaleLanguage.processing),
      Tab(text: context.appLocaleLanguage.cancelled),
    ];
    _tabController = TabController(
      length: tabs.length,
      vsync: this,
      initialIndex: 0,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.appLocaleLanguage.myTickets,
          style: TextStyle(fontSize: AppSizes.size20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.homePrimaryBlue,
        centerTitle: true,
      ),
      body: Column(
        children: [
          CustomTabBar(controller: _tabController, tabs: tabs),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                TicketOrderScreen(statusFilter: null),
                TicketOrderScreen(statusFilter: AppStorageKey.completed),
                TicketOrderScreen(statusFilter: AppStorageKey.failed),
                TicketOrderScreen(statusFilter: AppStorageKey.cancelled),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
