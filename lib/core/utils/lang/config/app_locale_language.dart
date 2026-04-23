import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_locale_language_en.dart';
import 'app_locale_language_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'config/app_locale_language.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appName.
  ///
  /// In vi, this message translates to:
  /// **'EventGo'**
  String get appName;

  /// No description provided for @heading.
  ///
  /// In vi, this message translates to:
  /// **'Tổ Chức Sự Kiện'**
  String get heading;

  /// No description provided for @slogan.
  ///
  /// In vi, this message translates to:
  /// **'Khám phá và đặt chỗ cho những sự kiện hấp dẫn nhất chỉ với vài thao tác. Trải nghiệm sự tiện lợi khi tham gia sự kiện cùng EventGo ngay hôm nay!'**
  String get slogan;

  /// No description provided for @getStarted.
  ///
  /// In vi, this message translates to:
  /// **'Bắt Đầu'**
  String get getStarted;

  /// No description provided for @login.
  ///
  /// In vi, this message translates to:
  /// **'Đăng Nhập'**
  String get login;

  /// No description provided for @register.
  ///
  /// In vi, this message translates to:
  /// **'Đăng Ký'**
  String get register;

  /// No description provided for @loading.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải...'**
  String get loading;

  /// No description provided for @signUpTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đăng Ký'**
  String get signUpTitle;

  /// No description provided for @signUpDescription.
  ///
  /// In vi, this message translates to:
  /// **'Tạo, chia sẻ và quản lý các sự kiện đáng nhớ chỉ với vài lần chạm!'**
  String get signUpDescription;

  /// No description provided for @loginTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get loginTitle;

  /// No description provided for @loginDescription.
  ///
  /// In vi, this message translates to:
  /// **'Tham gia trực tuyến với chúng tôi để tìm các sự kiện thú vị phù hợp với sở thích và nhu cầu của bạn!'**
  String get loginDescription;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In vi, this message translates to:
  /// **'Quên mật khẩu'**
  String get forgotPasswordTitle;

  /// No description provided for @newPasswordTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đặt mật khẩu mới'**
  String get newPasswordTitle;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đặt lại mật khẩu'**
  String get resetPasswordTitle;

  /// No description provided for @otpVerificationTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xác thực OTP'**
  String get otpVerificationTitle;

  /// No description provided for @otpInputTitle.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mã OTP'**
  String get otpInputTitle;

  /// No description provided for @otpDescription.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mã 6 chữ số được gửi đến email của bạn'**
  String get otpDescription;

  /// No description provided for @verify.
  ///
  /// In vi, this message translates to:
  /// **'Xác thực'**
  String get verify;

  /// No description provided for @emailHint.
  ///
  /// In vi, this message translates to:
  /// **'Email'**
  String get emailHint;

  /// No description provided for @passwordHint.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu'**
  String get passwordHint;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập lại mật khẩu'**
  String get confirmPasswordHint;

  /// No description provided for @newPasswordHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mật khẩu mới'**
  String get newPasswordHint;

  /// No description provided for @confirmNewPasswordHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập lại mật khẩu mới'**
  String get confirmNewPasswordHint;

  /// No description provided for @newPasswordLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu mới'**
  String get newPasswordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận mật khẩu'**
  String get confirmPasswordLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mật khẩu'**
  String get passwordLabel;

  /// No description provided for @signUpButton.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký'**
  String get signUpButton;

  /// No description provided for @loginButton.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get loginButton;

  /// No description provided for @forgotPasswordButton.
  ///
  /// In vi, this message translates to:
  /// **'Quên mật khẩu?'**
  String get forgotPasswordButton;

  /// No description provided for @resetPasswordButton.
  ///
  /// In vi, this message translates to:
  /// **'Đặt lại mật khẩu'**
  String get resetPasswordButton;

  /// No description provided for @updatePasswordButton.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật mật khẩu'**
  String get updatePasswordButton;

  /// No description provided for @verifyButton.
  ///
  /// In vi, this message translates to:
  /// **'Xác thực'**
  String get verifyButton;

  /// No description provided for @resendOtpButton.
  ///
  /// In vi, this message translates to:
  /// **'Gửi lại mã OTP'**
  String get resendOtpButton;

  /// No description provided for @backToLoginButton.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại đăng nhập'**
  String get backToLoginButton;

  /// No description provided for @nextButton.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp theo'**
  String get nextButton;

  /// No description provided for @okayButton.
  ///
  /// In vi, this message translates to:
  /// **'Đồng ý'**
  String get okayButton;

  /// No description provided for @tryAgainButton.
  ///
  /// In vi, this message translates to:
  /// **'Thử lại'**
  String get tryAgainButton;

  /// No description provided for @adminLoginOnWeb.
  ///
  /// In vi, this message translates to:
  /// **'Admin vui lòng đăng nhập ở trang quản trị.'**
  String get adminLoginOnWeb;

  /// No description provided for @signingUp.
  ///
  /// In vi, this message translates to:
  /// **'Đang đăng ký...'**
  String get signingUp;

  /// No description provided for @signingIn.
  ///
  /// In vi, this message translates to:
  /// **'Đang đăng nhập...'**
  String get signingIn;

  /// No description provided for @updating.
  ///
  /// In vi, this message translates to:
  /// **'Đang cập nhật...'**
  String get updating;

  /// No description provided for @verifying.
  ///
  /// In vi, this message translates to:
  /// **'Đang xác thực...'**
  String get verifying;

  /// No description provided for @hasAccount.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã có tài khoản?'**
  String get hasAccount;

  /// No description provided for @noAccount.
  ///
  /// In vi, this message translates to:
  /// **'Bạn chưa có tài khoản?'**
  String get noAccount;

  /// No description provided for @forgotPasswordDescription.
  ///
  /// In vi, this message translates to:
  /// **'Nhập email của bạn và chúng tôi sẽ gửi cho bạn liên kết để đặt lại mật khẩu!'**
  String get forgotPasswordDescription;

  /// No description provided for @newPasswordDescription.
  ///
  /// In vi, this message translates to:
  /// **'Tạo mật khẩu mới cho tài khoản'**
  String get newPasswordDescription;

  /// No description provided for @resetPasswordDescription.
  ///
  /// In vi, this message translates to:
  /// **'Tạo mật khẩu mới cho tài khoản'**
  String get resetPasswordDescription;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng xác nhận mật khẩu'**
  String get pleaseConfirmPassword;

  /// No description provided for @passwordMismatch.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu không khớp'**
  String get passwordMismatch;

  /// No description provided for @pleaseReenterPassword.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập lại mật khẩu'**
  String get pleaseReenterPassword;

  /// No description provided for @confirmPasswordMismatch.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu xác nhận không khớp'**
  String get confirmPasswordMismatch;

  /// No description provided for @signUpSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký thành công!'**
  String get signUpSuccess;

  /// No description provided for @loginSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập thành công!'**
  String get loginSuccess;

  /// No description provided for @loginSuccessTitle.
  ///
  /// In vi, this message translates to:
  /// **'ĐĂNG NHẬP THÀNH CÔNG'**
  String get loginSuccessTitle;

  /// No description provided for @loginSuccessMessage.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã đăng nhập thành công!'**
  String get loginSuccessMessage;

  /// No description provided for @signUpSuccessTitle.
  ///
  /// In vi, this message translates to:
  /// **'ĐĂNG KÝ THÀNH CÔNG'**
  String get signUpSuccessTitle;

  /// No description provided for @signUpSuccessMessage.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã đăng ký thành công!'**
  String get signUpSuccessMessage;

  /// No description provided for @resetPasswordSuccessTitle.
  ///
  /// In vi, this message translates to:
  /// **'ĐẶT LẠI MẬT KHẨU THÀNH CÔNG'**
  String get resetPasswordSuccessTitle;

  /// No description provided for @passwordUpdatedMessage.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu của bạn đã được cập nhật.'**
  String get passwordUpdatedMessage;

  /// No description provided for @otpResentSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã gửi lại OTP'**
  String get otpResentSuccess;

  /// No description provided for @signUpFailed.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký thất bại'**
  String get signUpFailed;

  /// No description provided for @loginFailed.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập thất bại'**
  String get loginFailed;

  /// No description provided for @unknownError.
  ///
  /// In vi, this message translates to:
  /// **'Đã xảy ra lỗi không xác định'**
  String get unknownError;

  /// No description provided for @logoutFailed.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất thất bại'**
  String get logoutFailed;

  /// No description provided for @logoutError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi khi đăng xuất'**
  String get logoutError;

  /// No description provided for @sendEmailFailed.
  ///
  /// In vi, this message translates to:
  /// **'Gửi email thất bại'**
  String get sendEmailFailed;

  /// No description provided for @sendVerificationFailed.
  ///
  /// In vi, this message translates to:
  /// **'Gửi xác thực email thất bại'**
  String get sendVerificationFailed;

  /// No description provided for @updatePasswordFailed.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật mật khẩu thất bại'**
  String get updatePasswordFailed;

  /// No description provided for @verificationFailed.
  ///
  /// In vi, this message translates to:
  /// **'Xác thực thất bại'**
  String get verificationFailed;

  /// No description provided for @sendEmailError.
  ///
  /// In vi, this message translates to:
  /// **'Gửi email thất bại'**
  String get sendEmailError;

  /// No description provided for @loginFailedTitle.
  ///
  /// In vi, this message translates to:
  /// **'ĐĂNG NHẬP THẤT BẠI'**
  String get loginFailedTitle;

  /// No description provided for @wrongEmailOrPasswordMessage.
  ///
  /// In vi, this message translates to:
  /// **'Sai email hoặc mật khẩu'**
  String get wrongEmailOrPasswordMessage;

  /// No description provided for @signUpFailedTitle.
  ///
  /// In vi, this message translates to:
  /// **'ĐĂNG KÝ THẤT BẠI'**
  String get signUpFailedTitle;

  /// No description provided for @errorOccurredMessage.
  ///
  /// In vi, this message translates to:
  /// **'Đã có lỗi xảy ra, vui lòng thử lại.'**
  String get errorOccurredMessage;

  /// No description provided for @verificationFailedTitle.
  ///
  /// In vi, this message translates to:
  /// **'XÁC THỰC THẤT BẠI'**
  String get verificationFailedTitle;

  /// No description provided for @invalidOtpMessage.
  ///
  /// In vi, this message translates to:
  /// **'Mã OTP không hợp lệ hoặc đã hết hạn.'**
  String get invalidOtpMessage;

  /// No description provided for @resendFailed.
  ///
  /// In vi, this message translates to:
  /// **'Gửi lại thất bại'**
  String get resendFailed;

  /// No description provided for @resetPasswordFailedTitle.
  ///
  /// In vi, this message translates to:
  /// **'ĐẶT LẠI MẬT KHẨU THẤT BẠI'**
  String get resetPasswordFailedTitle;

  /// No description provided for @errorOccurredTryAgain.
  ///
  /// In vi, this message translates to:
  /// **'Có lỗi xảy ra, vui lòng thử lại.'**
  String get errorOccurredTryAgain;

  /// No description provided for @enterFullOtp.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập đầy đủ 6 chữ số'**
  String get enterFullOtp;

  /// No description provided for @otpSentTo.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mã 6 chữ số được gửi đến\n'**
  String get otpSentTo;

  /// No description provided for @enterVerificationCode.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mã xác thực'**
  String get enterVerificationCode;

  /// No description provided for @resendOtpAfter.
  ///
  /// In vi, this message translates to:
  /// **'Gửi lại mã sau'**
  String get resendOtpAfter;

  /// No description provided for @otpIncorrectAttempts.
  ///
  /// In vi, this message translates to:
  /// **'Mã OTP không đúng. Còn {remaining} lần thử.'**
  String otpIncorrectAttempts(Object remaining);

  /// No description provided for @seconds.
  ///
  /// In vi, this message translates to:
  /// **'giây'**
  String get seconds;

  /// No description provided for @passwordRequirements.
  ///
  /// In vi, this message translates to:
  /// **'Yêu cầu mật khẩu:'**
  String get passwordRequirements;

  /// No description provided for @passwordRequirementsText.
  ///
  /// In vi, this message translates to:
  /// **'• Ít nhất 6 ký tự\n• Bao gồm chữ và số\n• Không chứa ký tự đặc biệt'**
  String get passwordRequirementsText;

  /// No description provided for @verifyingLink.
  ///
  /// In vi, this message translates to:
  /// **'Đang xác thực liên kết...'**
  String get verifyingLink;

  /// No description provided for @invalidLink.
  ///
  /// In vi, this message translates to:
  /// **'Liên kết không hợp lệ'**
  String get invalidLink;

  /// No description provided for @tryAgainOrRequestNew.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng thử lại hoặc yêu cầu liên kết mới'**
  String get tryAgainOrRequestNew;

  /// No description provided for @unknownErrorWithDetails.
  ///
  /// In vi, this message translates to:
  /// **'Đã xảy ra lỗi không xác định:'**
  String get unknownErrorWithDetails;

  /// No description provided for @logoutErrorWithDetails.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi khi đăng xuất:'**
  String get logoutErrorWithDetails;

  /// No description provided for @noUserToDelete.
  ///
  /// In vi, this message translates to:
  /// **'Không có người dùng để xóa'**
  String get noUserToDelete;

  /// No description provided for @deleteAccountError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi khi xóa tài khoản:'**
  String get deleteAccountError;

  /// No description provided for @wrongEmailOrPassword.
  ///
  /// In vi, this message translates to:
  /// **'Email hoặc mật khẩu không đúng'**
  String get wrongEmailOrPassword;

  /// No description provided for @pleaseVerifyEmail.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng xác thực email trước khi đăng nhập. Kiểm tra hộp thư của bạn.'**
  String get pleaseVerifyEmail;

  /// No description provided for @emailAlreadyRegistered.
  ///
  /// In vi, this message translates to:
  /// **'Email này đã được đăng ký'**
  String get emailAlreadyRegistered;

  /// No description provided for @passwordTooShort.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu phải có ít nhất 6 ký tự'**
  String get passwordTooShort;

  /// No description provided for @invalidEmail.
  ///
  /// In vi, this message translates to:
  /// **'Email không hợp lệ'**
  String get invalidEmail;

  /// No description provided for @accountNotFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy tài khoản với email này'**
  String get accountNotFound;

  /// No description provided for @tooManyRequests.
  ///
  /// In vi, this message translates to:
  /// **'Quá nhiều yêu cầu, vui lòng thử lại sau'**
  String get tooManyRequests;

  /// No description provided for @errorOccurred.
  ///
  /// In vi, this message translates to:
  /// **'Đã xảy ra lỗi:'**
  String get errorOccurred;

  /// No description provided for @searchTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tìm Kiếm'**
  String get searchTitle;

  /// No description provided for @searchHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập từ khóa'**
  String get searchHint;

  /// No description provided for @filterButton.
  ///
  /// In vi, this message translates to:
  /// **'Bộ lọc'**
  String get filterButton;

  /// No description provided for @recentSearches.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm gần đây'**
  String get recentSearches;

  /// No description provided for @trendingSearches.
  ///
  /// In vi, this message translates to:
  /// **'Xu hướng tìm kiếm'**
  String get trendingSearches;

  /// No description provided for @exploreByCategory.
  ///
  /// In vi, this message translates to:
  /// **'Khám phá theo thể loại'**
  String get exploreByCategory;

  /// No description provided for @exploreByCity.
  ///
  /// In vi, this message translates to:
  /// **'Khám phá theo thành phố'**
  String get exploreByCity;

  /// No description provided for @suggestionsForYou.
  ///
  /// In vi, this message translates to:
  /// **'Gợi ý dành cho bạn'**
  String get suggestionsForYou;

  /// No description provided for @noResultsFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy kết quả nào.'**
  String get noResultsFound;

  /// No description provided for @comingSoon.
  ///
  /// In vi, this message translates to:
  /// **'Sắp diễn ra'**
  String get comingSoon;

  /// No description provided for @free.
  ///
  /// In vi, this message translates to:
  /// **'Miễn phí'**
  String get free;

  /// No description provided for @location.
  ///
  /// In vi, this message translates to:
  /// **'Vị trí'**
  String get location;

  /// No description provided for @category.
  ///
  /// In vi, this message translates to:
  /// **'Thể loại'**
  String get category;

  /// No description provided for @price.
  ///
  /// In vi, this message translates to:
  /// **'Giá tiền'**
  String get price;

  /// No description provided for @resetButton.
  ///
  /// In vi, this message translates to:
  /// **'Thiết lập lại'**
  String get resetButton;

  /// No description provided for @applyButton.
  ///
  /// In vi, this message translates to:
  /// **'Áp dụng'**
  String get applyButton;

  /// No description provided for @selectTime.
  ///
  /// In vi, this message translates to:
  /// **'Chọn thời gian'**
  String get selectTime;

  /// No description provided for @allDays.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả các ngày'**
  String get allDays;

  /// No description provided for @today.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In vi, this message translates to:
  /// **'Ngày mai'**
  String get tomorrow;

  /// No description provided for @thisWeekend.
  ///
  /// In vi, this message translates to:
  /// **'Cuối tuần này'**
  String get thisWeekend;

  /// No description provided for @thisMonth.
  ///
  /// In vi, this message translates to:
  /// **'Tháng này'**
  String get thisMonth;

  /// No description provided for @monthFormat.
  ///
  /// In vi, this message translates to:
  /// **'Tháng {month}, {year}'**
  String monthFormat(Object month, Object year);

  /// No description provided for @liveMusic.
  ///
  /// In vi, this message translates to:
  /// **'Nhạc sống'**
  String get liveMusic;

  /// No description provided for @sports.
  ///
  /// In vi, this message translates to:
  /// **'Thể Thao'**
  String get sports;

  /// No description provided for @sportsCategory.
  ///
  /// In vi, this message translates to:
  /// **'Thể thao'**
  String get sportsCategory;

  /// No description provided for @theaterAndArtsSimple.
  ///
  /// In vi, this message translates to:
  /// **'Sân khấu nghệ thuật'**
  String get theaterAndArtsSimple;

  /// No description provided for @other.
  ///
  /// In vi, this message translates to:
  /// **'Khác'**
  String get other;

  /// No description provided for @nationwide.
  ///
  /// In vi, this message translates to:
  /// **'Toàn quốc'**
  String get nationwide;

  /// No description provided for @hanoi.
  ///
  /// In vi, this message translates to:
  /// **'Hà Nội'**
  String get hanoi;

  /// No description provided for @hoChiMinh.
  ///
  /// In vi, this message translates to:
  /// **'TP Hồ Chí Minh'**
  String get hoChiMinh;

  /// No description provided for @dalat.
  ///
  /// In vi, this message translates to:
  /// **'Đà Lạt'**
  String get dalat;

  /// No description provided for @otherLocation.
  ///
  /// In vi, this message translates to:
  /// **'Vị trí khác'**
  String get otherLocation;

  /// No description provided for @unknownTime.
  ///
  /// In vi, this message translates to:
  /// **'không rõ'**
  String get unknownTime;

  /// No description provided for @eventDetailTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết sự kiện'**
  String get eventDetailTitle;

  /// No description provided for @priceFrom.
  ///
  /// In vi, this message translates to:
  /// **'Giá từ'**
  String get priceFrom;

  /// No description provided for @fromPrice.
  ///
  /// In vi, this message translates to:
  /// **'Từ'**
  String get fromPrice;

  /// No description provided for @buyTicketNow.
  ///
  /// In vi, this message translates to:
  /// **'Mua vé ngay'**
  String get buyTicketNow;

  /// No description provided for @introduction.
  ///
  /// In vi, this message translates to:
  /// **'Giới thiệu'**
  String get introduction;

  /// No description provided for @ticketInfo.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin vé'**
  String get ticketInfo;

  /// No description provided for @organizer.
  ///
  /// In vi, this message translates to:
  /// **'Ban tổ chức'**
  String get organizer;

  /// No description provided for @youMayAlsoLike.
  ///
  /// In vi, this message translates to:
  /// **'Có thể bạn cũng thích'**
  String get youMayAlsoLike;

  /// No description provided for @seeMore.
  ///
  /// In vi, this message translates to:
  /// **'Xem thêm'**
  String get seeMore;

  /// No description provided for @captchaTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xác Minh Người Dùng'**
  String get captchaTitle;

  /// No description provided for @captchaDescription.
  ///
  /// In vi, this message translates to:
  /// **'Chống bot tự động mua vé'**
  String get captchaDescription;

  /// No description provided for @captchaInstruction.
  ///
  /// In vi, this message translates to:
  /// **'Kéo mũi tên qua phải để hoàn thiện bức hình, giúp EventGo xác minh bạn là người mua thực sự.'**
  String get captchaInstruction;

  /// No description provided for @captchaReload.
  ///
  /// In vi, this message translates to:
  /// **'Tải lại'**
  String get captchaReload;

  /// No description provided for @captchaLockoutMessage.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã thử quá 5 lần. Vui lòng thử lại sau {seconds} giây.'**
  String captchaLockoutMessage(Object seconds);

  /// No description provided for @captchaLockoutMessage1Min.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã thử quá 5 lần. Vui lòng thử lại sau 1 phút.'**
  String get captchaLockoutMessage1Min;

  /// No description provided for @clickToSelectTicket.
  ///
  /// In vi, this message translates to:
  /// **'Bấm vào khu vực để chọn vé'**
  String get clickToSelectTicket;

  /// No description provided for @pleaseSelectTicket.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng chọn vé'**
  String get pleaseSelectTicket;

  /// No description provided for @paymentFormat.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán {amount}'**
  String paymentFormat(Object amount);

  /// No description provided for @paymentTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán'**
  String get paymentTitle;

  /// No description provided for @ticketHoldTimeRemaining.
  ///
  /// In vi, this message translates to:
  /// **'Thời gian giữ vé còn lại: {time}'**
  String ticketHoldTimeRemaining(Object time);

  /// No description provided for @recipientInfoTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin nhận vé'**
  String get recipientInfoTitle;

  /// No description provided for @paymentMethodTitle.
  ///
  /// In vi, this message translates to:
  /// **'Phương thức thanh toán'**
  String get paymentMethodTitle;

  /// No description provided for @bookingInfoTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin đặt vé'**
  String get bookingInfoTitle;

  /// No description provided for @electronicTicketInfo.
  ///
  /// In vi, this message translates to:
  /// **'Vé điện tử sẽ được hiển thị trong mục \"Vé của tôi\" của tài khoản'**
  String get electronicTicketInfo;

  /// No description provided for @zalopay.
  ///
  /// In vi, this message translates to:
  /// **'Zalopay'**
  String get zalopay;

  /// No description provided for @ticketType.
  ///
  /// In vi, this message translates to:
  /// **'Loại vé'**
  String get ticketType;

  /// No description provided for @quantity.
  ///
  /// In vi, this message translates to:
  /// **'Số lượng'**
  String get quantity;

  /// No description provided for @orderInfoTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin đơn hàng'**
  String get orderInfoTitle;

  /// No description provided for @subtotal.
  ///
  /// In vi, this message translates to:
  /// **'Tạm tính'**
  String get subtotal;

  /// No description provided for @totalAmount.
  ///
  /// In vi, this message translates to:
  /// **'Tổng tiền'**
  String get totalAmount;

  /// No description provided for @paymentButton.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán'**
  String get paymentButton;

  /// No description provided for @myTickets.
  ///
  /// In vi, this message translates to:
  /// **'Vé của tôi'**
  String get myTickets;

  /// No description provided for @all.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get all;

  /// No description provided for @success.
  ///
  /// In vi, this message translates to:
  /// **'Thành công'**
  String get success;

  /// No description provided for @processing.
  ///
  /// In vi, this message translates to:
  /// **'Thất bại'**
  String get processing;

  /// No description provided for @cancelled.
  ///
  /// In vi, this message translates to:
  /// **'Đã hủy'**
  String get cancelled;

  /// No description provided for @failed.
  ///
  /// In vi, this message translates to:
  /// **'Thất bại'**
  String get failed;

  /// No description provided for @unknown.
  ///
  /// In vi, this message translates to:
  /// **'Không xác định'**
  String get unknown;

  /// No description provided for @pleaseLoginToViewTickets.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng đăng nhập để xem vé của bạn.'**
  String get pleaseLoginToViewTickets;

  /// No description provided for @errorLoadingOrders.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi khi tải đơn hàng: {error}'**
  String errorLoadingOrders(Object error);

  /// No description provided for @noOrdersYet.
  ///
  /// In vi, this message translates to:
  /// **'Bạn chưa có đơn hàng nào.'**
  String get noOrdersYet;

  /// No description provided for @noOrdersInThisCategory.
  ///
  /// In vi, this message translates to:
  /// **'Không có đơn hàng nào trong mục này.'**
  String get noOrdersInThisCategory;

  /// No description provided for @eventName.
  ///
  /// In vi, this message translates to:
  /// **'Tên sự kiện'**
  String get eventName;

  /// No description provided for @accountSettings.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt tài khoản'**
  String get accountSettings;

  /// No description provided for @accountInfo.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin tài khoản'**
  String get accountInfo;

  /// No description provided for @appSettings.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt ứng dụng'**
  String get appSettings;

  /// No description provided for @logout.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get logout;

  /// No description provided for @version.
  ///
  /// In vi, this message translates to:
  /// **'Phiên bản 3.1.13(30284)'**
  String get version;

  /// No description provided for @changeLanguage.
  ///
  /// In vi, this message translates to:
  /// **'Thay đổi ngôn ngữ'**
  String get changeLanguage;

  /// No description provided for @languageVietnamese.
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Việt'**
  String get languageVietnamese;

  /// No description provided for @languageEnglish.
  ///
  /// In vi, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @complete.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn thành'**
  String get complete;

  /// No description provided for @profileInfoDescription.
  ///
  /// In vi, this message translates to:
  /// **'Cung cấp thông tin chính xác sẽ hỗ trợ bạn trong quá trình mua vé, hoặc khi cần xác thực vé'**
  String get profileInfoDescription;

  /// No description provided for @fullName.
  ///
  /// In vi, this message translates to:
  /// **'Họ và tên'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In vi, this message translates to:
  /// **'Số điện thoại'**
  String get phoneNumber;

  /// No description provided for @updateProfileSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật thông tin thành công!'**
  String get updateProfileSuccess;

  /// No description provided for @scanCheckInCode.
  ///
  /// In vi, this message translates to:
  /// **'Quét mã Check-in'**
  String get scanCheckInCode;

  /// No description provided for @processingCheckIn.
  ///
  /// In vi, this message translates to:
  /// **'Đang xử lý: {orderId}...'**
  String processingCheckIn(Object orderId);

  /// No description provided for @successPrefix.
  ///
  /// In vi, this message translates to:
  /// **'THÀNH CÔNG'**
  String get successPrefix;

  /// No description provided for @guest.
  ///
  /// In vi, this message translates to:
  /// **'Khách'**
  String get guest;

  /// No description provided for @noEmail.
  ///
  /// In vi, this message translates to:
  /// **'Không có email'**
  String get noEmail;

  /// No description provided for @trendingEventsTitle.
  ///
  /// In vi, this message translates to:
  /// **'🔥 Sự kiện xu hướng'**
  String get trendingEventsTitle;

  /// No description provided for @recommendedForYouTitle.
  ///
  /// In vi, this message translates to:
  /// **'Dành cho bạn'**
  String get recommendedForYouTitle;

  /// No description provided for @chooseLocationTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chọn địa điểm'**
  String get chooseLocationTitle;

  /// No description provided for @captchaInvalid.
  ///
  /// In vi, this message translates to:
  /// **'Xác minh không đúng! (Thử lại: {count}/5)'**
  String captchaInvalid(Object count);

  /// No description provided for @mapOpenError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể mở bản đồ cho: {address}'**
  String mapOpenError(Object address);

  /// No description provided for @genericErrorWithDetails.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi: {error}'**
  String genericErrorWithDetails(Object error);

  /// No description provided for @transactionResultTitle.
  ///
  /// In vi, this message translates to:
  /// **'Kết quả giao dịch'**
  String get transactionResultTitle;

  /// No description provided for @paymentSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán thành công'**
  String get paymentSuccess;

  /// No description provided for @paymentSuccessWithExclamation.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán thành công!'**
  String get paymentSuccessWithExclamation;

  /// No description provided for @paymentFailure.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán thất bại'**
  String get paymentFailure;

  /// No description provided for @transactionCodeLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mã giao dịch:'**
  String get transactionCodeLabel;

  /// No description provided for @backToHomeButton.
  ///
  /// In vi, this message translates to:
  /// **'Về trang chủ'**
  String get backToHomeButton;

  /// No description provided for @invalidAmount.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền không hợp lệ'**
  String get invalidAmount;

  /// No description provided for @paymentErrorWithDetails.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi: {error}'**
  String paymentErrorWithDetails(Object error);

  /// No description provided for @eventNotFound.
  ///
  /// In vi, this message translates to:
  /// **'Sự kiện không tồn tại.'**
  String get eventNotFound;

  /// No description provided for @userNotFound.
  ///
  /// In vi, this message translates to:
  /// **'Người dùng không tồn tại.'**
  String get userNotFound;

  /// No description provided for @ticketTypeNotFound.
  ///
  /// In vi, this message translates to:
  /// **'Loại vé không tồn tại.'**
  String get ticketTypeNotFound;

  /// No description provided for @noTicketsSelected.
  ///
  /// In vi, this message translates to:
  /// **'Không có vé nào được chọn.'**
  String get noTicketsSelected;

  /// No description provided for @orderSaveError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi lưu đơn hàng: {error}. Vui lòng liên hệ hỗ trợ.'**
  String orderSaveError(Object error);

  /// No description provided for @invalidTicket.
  ///
  /// In vi, this message translates to:
  /// **'LỖI: Vé không hợp lệ hoặc không tồn tại.'**
  String get invalidTicket;

  /// No description provided for @ticketDataError.
  ///
  /// In vi, this message translates to:
  /// **'LỖI: Không thể đọc dữ liệu vé.'**
  String get ticketDataError;

  /// No description provided for @unpaidTicket.
  ///
  /// In vi, this message translates to:
  /// **'LỖI: Vé này chưa hoàn tất thanh toán.'**
  String get unpaidTicket;

  /// No description provided for @ticketAlreadyCheckedIn.
  ///
  /// In vi, this message translates to:
  /// **'LỖI: Vé này ĐÃ ĐƯỢC CHECK-IN lúc {time}.'**
  String ticketAlreadyCheckedIn(Object time);

  /// No description provided for @checkInSuccessMessage.
  ///
  /// In vi, this message translates to:
  /// **'THÀNH CÔNG: Check-in cho [{email}] thành công!'**
  String checkInSuccessMessage(Object email);

  /// No description provided for @systemErrorTryAgain.
  ///
  /// In vi, this message translates to:
  /// **'LỖI HỆ THỐNG: Đã xảy ra lỗi. Vui lòng thử lại.'**
  String get systemErrorTryAgain;

  /// No description provided for @orderStreamUserIdMissing.
  ///
  /// In vi, this message translates to:
  /// **'Không thể lấy order stream: UserID is null.'**
  String get orderStreamUserIdMissing;

  /// No description provided for @orderStreamError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi khi lấy orders stream: {error}'**
  String orderStreamError(Object error);

  /// No description provided for @searchHistoryLoadError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi khi tải lịch sử tìm kiếm: {error}'**
  String searchHistoryLoadError(Object error);

  /// No description provided for @searchHistorySaveError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi khi lưu lịch sử tìm kiếm: {error}'**
  String searchHistorySaveError(Object error);

  /// No description provided for @searchHistoryDeleteError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi khi xóa 1 mục lịch sử tìm kiếm: {error}'**
  String searchHistoryDeleteError(Object error);

  /// No description provided for @categoriesFetchError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi khi lấy categories: {error}'**
  String categoriesFetchError(Object error);

  /// No description provided for @failedToWatchEvents.
  ///
  /// In vi, this message translates to:
  /// **'Không thể theo dõi sự kiện: {error}'**
  String failedToWatchEvents(Object error);

  /// No description provided for @failedToStartWatchingEvents.
  ///
  /// In vi, this message translates to:
  /// **'Không thể bắt đầu theo dõi sự kiện: {error}'**
  String failedToStartWatchingEvents(Object error);

  /// No description provided for @homeTabLabel.
  ///
  /// In vi, this message translates to:
  /// **'Trang chủ'**
  String get homeTabLabel;

  /// No description provided for @myTicketsTabLabel.
  ///
  /// In vi, this message translates to:
  /// **'Vé của tôi'**
  String get myTicketsTabLabel;

  /// No description provided for @accountTabLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản'**
  String get accountTabLabel;

  /// No description provided for @theaterAndArts.
  ///
  /// In vi, this message translates to:
  /// **'Sân khấu Nghệ thuật'**
  String get theaterAndArts;

  /// No description provided for @conference.
  ///
  /// In vi, this message translates to:
  /// **'Hội thảo'**
  String get conference;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
