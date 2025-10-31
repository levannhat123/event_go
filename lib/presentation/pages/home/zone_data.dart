import 'package:flutter/material.dart';
Rect _inflateRect(Rect rect, double amount) {
  return rect.inflate(amount);
}
Path _inflatePolygon(Path path, double amount) {
  if (path.toString().contains('MoveTo(100.0, 100.0)')) {
    return Path()
      ..moveTo(100 - amount, 100 - amount)
      ..lineTo(170 + amount, 100 - amount)
      ..lineTo(160 + amount, 150 + amount)
      ..lineTo(100 - amount, 150 + amount)
      ..close();
  }
  if (path.toString().contains('MoveTo(230.0, 100.0)')) {
    return Path()
      ..moveTo(230 - amount, 100 - amount)
      ..lineTo(300 + amount, 100 - amount)
      ..lineTo(300 + amount, 150 + amount)
      ..lineTo(240 - amount, 150 + amount)
      ..close();
  }
  return path;
}


class ZoneData {
  final String name;
  final Path path;
  final Path hitboxPath;
  final Color color;
  final double price;
  final bool isAvailable;

  ZoneData({
    required this.name,
    required this.path,
    required this.hitboxPath,
    required this.color,
    required this.price,
    this.isAvailable = true,
  });
}

Map<String, ZoneData> createDummyZones() {
  const double hitPadding = 2.5;

  // --- STAGE ---
  final Rect stageRect = const Rect.fromLTWH(80, 50, 240, 40);
  final Path stagePath = Path()..addRect(stageRect);

  // --- VIP L ---
  final Path vipLPath = Path()
    ..moveTo(100, 100)
    ..lineTo(170, 100)
    ..lineTo(160, 150)
    ..lineTo(100, 150)
    ..close();

  // --- VIP R ---
  final Path vipRPath = Path()
    ..moveTo(230, 100)
    ..lineTo(300, 100)
    ..lineTo(300, 150)
    ..lineTo(240, 150)
    ..close();

  // --- A1 L ---
  final Rect a1LRect = const Rect.fromLTWH(100, 155, 60, 30);
  final Path a1LPath = Path()..addRect(a1LRect);

  // --- A1 R ---
  final Rect a1RRect = const Rect.fromLTWH(240, 155, 60, 30);
  final Path a1RPath = Path()..addRect(a1RRect);

  // --- B2 L ---
  final Rect b2LRect = const Rect.fromLTWH(65, 100, 30, 85);
  final Path b2LPath = Path()..addRect(b2LRect);

  // --- B2 R ---
  final Rect b2RRect = const Rect.fromLTWH(305, 100, 30, 85);
  final Path b2RPath = Path()..addRect(b2RRect);

  // --- S1 L (Giữa) ---
  final Rect s1LRect = const Rect.fromLTWH(100, 190, 60, 30);
  final Path s1LPath = Path()..addRect(s1LRect);

  // --- S1 R (Giữa) ---
  final Rect s1RRect = const Rect.fromLTWH(240, 190, 60, 30);
  final Path s1RPath = Path()..addRect(s1RRect);

  // --- S2 L ---
  final Rect s2LRect = const Rect.fromLTWH(20, 100, 40, 120);
  final Path s2LPath = Path()..addRect(s2LRect);

  // --- S2 R ---
  final Rect s2RRect = const Rect.fromLTWH(340, 100, 40, 120);
  final Path s2RPath = Path()..addRect(s2RRect);

  // --- RVIP L ---
  final Rect rvipLRect = const Rect.fromLTWH(65, 230, 125, 30);
  final Path rvipLPath = Path()..addRect(rvipLRect);

  // --- RVIP R ---
  final Rect rvipRRect = const Rect.fromLTWH(210, 230, 125, 30);
  final Path rvipRPath = Path()..addRect(rvipRRect);

  // --- FOH ---
  final Rect fohRect = const Rect.fromLTWH(180, 235, 40, 20);
  final Path fohPath = Path()..addRect(fohRect);

  // --- S1 L (Dưới) ---
  final Rect s1LBottomRect = const Rect.fromLTWH(65, 270, 125, 40);
  final Path s1LBottomPath = Path()..addRect(s1LBottomRect);

  // --- S1 R (Dưới) ---
  final Rect s1RBottomRect = const Rect.fromLTWH(210, 270, 125, 40);
  final Path s1RBottomPath = Path()..addRect(s1RBottomRect);

  return {
    'STAGE': ZoneData(
      name: 'STAGE',
      path: stagePath,
      hitboxPath: Path()..addRect(_inflateRect(stageRect, hitPadding)),
      color: Colors.grey.shade700,
      price: 0,
      isAvailable: false,
    ),
    'VIP L': ZoneData(
      name: 'VIP L',
      path: vipLPath,
      hitboxPath: _inflatePolygon(vipLPath, hitPadding), // Dùng helper cho đa giác
      color: Colors.red.shade400,
      price: 5000000,
      isAvailable: true,
    ),
    'VIP R': ZoneData(
      name: 'VIP R',
      path: vipRPath,
      hitboxPath: _inflatePolygon(vipRPath, hitPadding), // Dùng helper cho đa giác
      color: Colors.red.shade400,
      price: 5000000,
      isAvailable: true,
    ),
    'A1 L': ZoneData(
      name: 'A1 L',
      path: a1LPath,
      hitboxPath: Path()..addRect(_inflateRect(a1LRect, hitPadding)),
      color: Colors.purple.shade400,
      price: 3500000,
      isAvailable: true,
    ),
    'A1 R': ZoneData(
      name: 'A1 R',
      path: a1RPath,
      hitboxPath: Path()..addRect(_inflateRect(a1RRect, hitPadding)),
      color: Colors.purple.shade400,
      price: 3500000,
      isAvailable: true,
    ),
    'B2 L': ZoneData(
      name: 'B2 L',
      path: b2LPath,
      hitboxPath: Path()..addRect(_inflateRect(b2LRect, hitPadding)),
      color: Colors.yellow.shade600,
      price: 2500000,
      isAvailable: true,
    ),
    'B2 R': ZoneData(
      name: 'B2 R',
      path: b2RPath,
      hitboxPath: Path()..addRect(_inflateRect(b2RRect, hitPadding)),
      color: Colors.yellow.shade600,
      price: 2500000,
      isAvailable: true,
    ),
    'S2 L': ZoneData(
      name: 'S2 L',
      path: s2LPath,
      hitboxPath: Path()..addRect(_inflateRect(s2LRect, hitPadding)),
      color: Colors.blue.shade600,
      price: 2000000,
      isAvailable: true,
    ),
    'S2 R': ZoneData(
      name: 'S2 R',
      path: s2RPath,
      hitboxPath: Path()..addRect(_inflateRect(s2RRect, hitPadding)),
      color: Colors.blue.shade600,
      price: 2000000,
      isAvailable: true,
    ),
    'S1 L (Giữa)': ZoneData(
      name: 'S1 L',
      path: s1LPath,
      hitboxPath: Path()..addRect(_inflateRect(s1LRect, hitPadding)),
      color: Colors.yellow.shade600,
      price: 2500000,
      isAvailable: true,
    ),
    'S1 R (Giữa)': ZoneData(
      name: 'S1 R',
      path: s1RPath,
      hitboxPath: Path()..addRect(_inflateRect(s1RRect, hitPadding)),
      color: Colors.yellow.shade600,
      price: 2500000,
      isAvailable: true,
    ),
    'RVIP L': ZoneData(
      name: 'RVIP L',
      path: rvipLPath,
      hitboxPath: Path()..addRect(_inflateRect(rvipLRect, hitPadding)),
      color: Colors.lightGreen.shade400,
      price: 3000000,
      isAvailable: true,
    ),
    'RVIP R': ZoneData(
      name: 'RVIP R',
      path: rvipRPath,
      hitboxPath: Path()..addRect(_inflateRect(rvipRRect, hitPadding)),
      color: Colors.lightGreen.shade400,
      price: 3000000,
      isAvailable: true,
    ),
    'FOH': ZoneData(
      name: 'FOH',
      path: fohPath,
      hitboxPath: Path()..addRect(_inflateRect(fohRect, hitPadding)),
      color: Colors.grey.shade800,
      price: 0,
      isAvailable: false,
    ),
    'S1 L (Dưới)': ZoneData(
      name: 'S1 L',
      path: s1LBottomPath,
      hitboxPath: Path()..addRect(_inflateRect(s1LBottomRect, hitPadding)),
      color: Colors.cyan.shade300,
      price: 1500000,
      isAvailable: true,
    ),
    'S1 R (Dưới)': ZoneData(
      name: 'S1 R',
      path: s1RBottomPath,
      hitboxPath: Path()..addRect(_inflateRect(s1RBottomRect, hitPadding)),
      color: Colors.cyan.shade300,
      price: 1500000,
      isAvailable: true,
    ),
  };
}