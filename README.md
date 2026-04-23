# Event Go

Ứng dụng Flutter đặt vé sự kiện (nhạc, thể thao, nghệ thuật), tích hợp:
- Đăng nhập/đăng ký với Supabase Auth
- Danh sách sự kiện từ Firestore
- Tìm kiếm/lọc sự kiện
- Đặt vé và thanh toán qua ZaloPay / VNPay
- Quản lý vé đã mua

## Công nghệ chính

- Flutter (Dart SDK `^3.8.1`)
- State management: `provider`
- DI: `get_it`
- Routing: `go_router`
- Backend/Auth: `supabase_flutter`
- Database: `cloud_firestore`
- Payment: `flutter_zalopay_sdk`, VNPay WebView (`webview_flutter`)
- Local config: `flutter_dotenv`

## Cấu trúc thư mục (rút gọn)

```text
lib/
  core/
    config/        # env/config, payment config
    constants/     # app colors/sizes/strings
  data/
    models/
    repositories/
  domain/
    usecase/
  presentation/
    pages/
    view_models/
  routers/
  injection/
```

## Yêu cầu môi trường

- Flutter SDK (khuyến nghị bản stable mới)
- Dart SDK tương thích Flutter
- Android Studio / Xcode (nếu build mobile)

Kiểm tra nhanh:

```bash
flutter --version
flutter doctor
```

## Cài đặt

```bash
flutter pub get
```

## Cấu hình biến môi trường

Project dùng file `.env` (được load trong `main.dart`).

1. Tạo file `.env` từ mẫu:

```bash
cp .env.example .env
```

2. Cập nhật giá trị thật trong `.env`:

```env
SUPABASE_URL=...
SUPABASE_ANON_KEY=...

ZALOPAY_APP_ID=...
ZALOPAY_KEY1=...
ZALOPAY_KEY2=...
ZALOPAY_APP_USER=...

VNPAY_URL=...
VNPAY_TMN_CODE=...
VNPAY_HASH_KEY=...
```

> Lưu ý: `.env` đã được ignore trong git. Không commit key thật.

## Chạy ứng dụng

```bash
flutter run
```

Build release:

```bash
flutter build apk
# hoặc
flutter build ios
```

## Lệnh hữu ích

Phân tích code:

```bash
flutter analyze
```

Format:

```bash
dart format lib test
```

Generate code (nếu chỉnh model dùng `freezed/json_serializable`):

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Routing chính

Các màn hình được khai báo trong `lib/routers/app_route.dart`, gồm:
- Splash / Auth
- Home / Search / Event Detail
- Booking / Payment / Payment Result
- Ticket / User

## Ghi chú bảo mật

- Không hardcode API key/secret trong code.
- Luôn để key trong `.env`.
- Nếu nghi ngờ lộ key, rotate key trên hệ thống tương ứng (Supabase, ZaloPay, VNPay).

