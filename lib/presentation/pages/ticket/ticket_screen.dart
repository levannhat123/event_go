import 'package:event_go/core/constants/app_strings.dart';
import 'package:event_go/core/widgets/custom_tab_bar.dart';
import 'package:event_go/presentation/pages/ticket/ticket_order_screen.dart';
import 'package:flutter/material.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final List<Tab> tabs = [
    const Tab(text: AppStrings.all),
    const Tab(text: AppStrings.success),
    const Tab(text: AppStrings.processing),
    const Tab(text: AppStrings.cancelled),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
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
          AppStrings.myTickets,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF596DC3),
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
                TicketOrderScreen(statusFilter: 'completed'),
                TicketOrderScreen(statusFilter: 'failed'),
                TicketOrderScreen(statusFilter: 'cancelled'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
