import 'package:event_go/core/widgets/custom_tab_bar.dart';
import 'package:event_go/presentation/pages/ticket/ticket_order_screen.dart';
import 'package:flutter/material.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final List<Tab> tabs = [
    const Tab(text: 'Tất cả'),
    const Tab(text: 'Thành công'),
    const Tab(text: 'Đang xử lý'),
    const Tab(text: 'Đã hủy'),
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
        title: Text('Vé của tôi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF596DC3),
        centerTitle: true,
      ),
      body: Column(
        children: [
          CustomTabBar(controller: _tabController, tabs: tabs),
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: [
                TicketOrderScreen(),
                TicketOrderScreen(),
                TicketOrderScreen(),
                TicketOrderScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
