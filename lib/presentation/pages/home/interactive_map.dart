import 'package:event_go/presentation/pages/home/map_painter.dart';
import 'package:event_go/presentation/pages/home/ticket_selection_sheet.dart';
import 'package:event_go/presentation/pages/home/zone_data.dart';
import 'package:flutter/material.dart';
class InteractiveMap extends StatefulWidget {
  final Map<String, ZoneData> zones;

  const InteractiveMap({super.key, required this.zones});

  @override
  State<InteractiveMap> createState() => _InteractiveMapState();
}

class _InteractiveMapState extends State<InteractiveMap> {
  String? _selectedZoneName;
  static const double _canvasWidth = 400.0;
  static const double _canvasHeight = 600.0;
  void _handleTap(
      BuildContext context,
      TapDownDetails details,
      BoxConstraints constraints,
      ) {
    final double offsetX = (constraints.maxWidth - _canvasWidth) / 2.0;
    final double offsetY = (constraints.maxHeight - _canvasHeight) / 2.0;
    final Offset canvasPosition = Offset(
      details.localPosition.dx - offsetX,
      details.localPosition.dy - offsetY,
    );
    ZoneData? tappedZone;
    for (final zone in widget.zones.values) {
      if (zone.hitboxPath.contains(canvasPosition)) {
        tappedZone = zone;
        break;
      }
    }

    if (tappedZone != null) {
      if (!tappedZone.isAvailable) {
        setState(() {
          _selectedZoneName = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Không thể chọn khu vực màu xám. Vui lòng chọn khu vực khác!'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        setState(() {
          _selectedZoneName = tappedZone!.name;
        });
        _showTicketSelectionSheet(context, tappedZone);
      }
    } else {
      setState(() {
        _selectedZoneName = null;
      });
    }
  }

  void _showTicketSelectionSheet(BuildContext context, ZoneData zone) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return TicketSelectionSheet(zone: zone);
      },
    ).whenComplete(() {
      setState(() {
        _selectedZoneName = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF121212),
      child: InteractiveViewer(
        maxScale: 5.0,
        minScale: 0.5,
        boundaryMargin: const EdgeInsets.all(50.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              onTapDown: (details) => _handleTap(context, details, constraints),
              child: Center(
                child: CustomPaint(
                  size: const Size(_canvasWidth, _canvasHeight),
                  painter: MapPainter(
                    zones: widget.zones,
                    selectedZoneName: _selectedZoneName,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}