# File Tree: lib

**Generated:** 09:56:38 16/11/2025
**Root Path:** `/Users/levannhat/Desktop/flutter/datn/event_go/lib`

```
├── core
│   ├── base
│   ├── config
│   ├── constants
│   ├── utils
│   └── widgets
├── data
│   ├── models
│   └── repositories
├── domain
│   ├── entities
│   ├── usecase
│   └── utils
├── injection
├── presentation
│   ├── pages
│   └── view_models
├── routers
└── main.dart


├── core                     # Core layer chứa config, base class, constants,...
│   ├── base                 # Class cơ bản dùng chung (BaseView, BaseViewModel)
│   ├── config               # Tập tin cấu hình (Supabase, ZaloPay, môi trường, API...)
│   ├── constants            # Chứa constants (màu, text, spacing, image path...)
│   ├── utils                # Hàm tiện ích (formatter, extension, validator...)
│   └── widgets              # Các widget tái sử dụng toàn app (button, dialogs, input field,...)
├── data                     # Data layer – xử lý dữ liệu
│   ├── models               # Định nghĩa model / DTO / JSON parser
│   └── repositories         # Triển khai repository (gọi dữ liệu từ API / DB)
├── domain                   # Business logic thuần (Không phụ thuộc Flutter)
│   ├── entities             # Entity chuẩn domain (model thuần - không JSON parser)
│   ├── usecase              # UseCase xử lý nghiệp vụ (login, getEvent, updateProfile,...)
├── injection                # Khởi tạo và đăng ký dependency (GetIt / Provider / Riverpod...)
├── presentation             # UI + ViewModels (MVVM)
│   ├── pages                # Màn hình UI (View)
│   └── view_models          # ViewModel (ChangeNotifier) xử lý logic cho từng màn
├── routers                  # File router điều hướng (Route name, GoRouter, etc)
└── main.dart                # Entry point – chạy app, inject DI, runApp()