import 'package:event_go/core/constants/app_colors.dart';
import 'package:event_go/core/widgets/app_elevated_button.dart';
import 'package:event_go/presentation/pages/home/interactive_map.dart';
import 'package:event_go/presentation/pages/home/zone_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marquee/marquee.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class EventBookingScreen extends StatefulWidget {
  const EventBookingScreen({super.key});

  @override
  State<EventBookingScreen> createState() => _EventBookingScreenState();
}

class _EventBookingScreenState extends State<EventBookingScreen> {
  final Map<String, ZoneData> zones = createDummyZones();
  final PanelController _panelController = PanelController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 50,
          child: Marquee(
            text: 'Bấm vào khu vực để chọn vé   ',
            style: const TextStyle(fontSize: 18, color: Colors.white),
            velocity: 50.0,
            blankSpace: 30.0,
            pauseAfterRound: const Duration(seconds: 1),
            startPadding: 10.0,
          ),
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
      ),
      body: SlidingUpPanel(
        controller: _panelController,
        minHeight: 140,
        maxHeight: MediaQuery.of(context).size.height * 0.8,
        parallaxEnabled: true,
        parallaxOffset: 0.5,
        color: const Color(0xFF323138),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
        body: InteractiveMap(zones: zones),
        collapsed: _buildCollapsedPanel(),
        panel: _buildPriceListPanel(),
      ),
    );
  }

  Widget _buildCollapsedPanel() {
    return GestureDetector(
      onTap: () => _panelController.open(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        decoration: const BoxDecoration(
          color: Color(0xFF2C2C2E),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.keyboard_arrow_up, color: Colors.grey),
            SizedBox(height: 4),
            Text(
              "Y-CONCERT BY YEAH1",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              "14:00, 20 Tháng 12, 2025",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            SizedBox(height: 8),
            AppElevatedButton(
              text: 'Vui lòng chọn vé',
              onPressed: () {},
              height: 40,
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              textColor: AppColors.grey,
              color: Color(0xFFDEE0E4),
              fontSize: 15.0,
              borderColor: AppColors.transparent,
              splashColor: AppColors.transparent,
              highlightColor: AppColors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceListPanel() {
    final currencyFormatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
    );
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Y-CONCERT BY YEAH1 Y-CONCERT BY YEAH1 Y-CONCERT BY YEAH1 Y-CONCERT BY YEAH1",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(color: Color(0xFF27272E),thickness: 3,),
          const ListTile(
            leading: Icon(Icons.location_on, color: Colors.green,size: 20,),
            title: Text(
              "VINHOMES OCEAN PARK 3",
              style: TextStyle(color: Colors.white,fontSize: 12,fontWeight: FontWeight.w600),
            ),
            contentPadding: EdgeInsets.zero,
          ),
          const ListTile(
            leading: Icon(Icons.calendar_today, color: Colors.green,size: 20,),
            title: Text(
              "14:00 - 23:59, 20 Tháng 12, 2025",
              style: TextStyle(color: Colors.white,fontSize: 12,fontWeight: FontWeight.w600),
            ),
            contentPadding: EdgeInsets.zero,
          ),
          const Divider(color: Color(0xFF27272E),thickness: 3,),
          Expanded(
            child: ListView.builder(
              itemCount: zones.length,
              itemBuilder: (context, index) {
                final zone = zones.values.elementAt(index);
                return ListTile(
                  leading: Container(
                    width: 20,
                    height: 20,
                    color: zone.isAvailable ? zone.color : Colors.grey,
                  ),
                  title: Text(
                    zone.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: Text(
                    currencyFormatter.format(zone.price),
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16),
          AppElevatedButton(
            text: 'Vui lòng chọn vé',
            onPressed: () {},
            height: 40,
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            textColor: AppColors.grey,
            color: Color(0xFFDEE0E4),
            fontSize: 15.0,
            borderColor: AppColors.transparent,
            splashColor: AppColors.transparent,
            highlightColor: AppColors.white,
          ),
        ],
      ),
    );
  }
}
