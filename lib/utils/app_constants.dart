import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';

// ============================================================
//  APP CONSTANTS
//  all values constant and static for application
//  use this file: import 'package:app_rental_room/utils/app_constants.dart';
// ============================================================

// ------------------------------------------------------------
//  API CONFIGURATION
// ------------------------------------------------------------
class AppApi {
  AppApi._(); // protect create a instance

  /// Host of the Laravel API based on platform
  static const String _dartDefinedBaseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: '',
  );

  static String get host {
    if (_dartDefinedBaseUrl.isNotEmpty) {
      return _dartDefinedBaseUrl;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://127.0.0.1:8080';
  }

  /// Base URL of the Laravel API
  static String get baseUrl => '$host/api';

  // Endpoints - Authentication
  static const String endpointRegister = '/register';
  static const String endpointLogin = '/login';
  static const String endpointLogout = '/logout';
  static const String endpointUser = '/user';

  // Endpoints - Rooms
  static const String endpointRooms = '/rooms';
  static const String endpointOwnerRooms = '/owner/rooms';
  static const String endpointAmenities = '/amenities';

  // Endpoints - Bookings
  static const String endpointBookings = '/bookings';
  static const String endpointOwnerBookings = '/owner/bookings';

  // Endpoints - Admin
  static const String endpointAdminUsers = '/admin/users';
  static const String endpointAdminRooms = '/admin/rooms';
  static const String endpointAdminBookings = '/admin/bookings';
  static const String endpointAdminStats = '/admin/stats';
}

// ------------------------------------------------------------
//  COLORS (Design System) — Warm Cozy Minimalist (Dynamic Light / Dark)
// ------------------------------------------------------------
class AppColors {
  AppColors._(); // prevent instantiation

  static bool get isDark => ThemeProvider.instance.isDarkMode;

  // Primary Brand Color
  static Color get primary =>
      isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5);
  static Color get secondary =>
      isDark ? const Color(0xFF312E81) : const Color(0xFFE0E7FF);

  // Background Colors
  static Color get background =>
      isDark ? const Color(0xFF181513) : const Color(0xFFFDFBF7);
  static Color get backgroundCard =>
      isDark ? const Color(0xFF231E1B) : Colors.white;
  static Color get backgroundLight =>
      isDark ? const Color(0xFF2C2521) : const Color(0xFFFAEDCD);
  static Color get backgroundField =>
      isDark ? const Color(0xFF2D2520) : const Color(0xFFFFFBF0);

  // Gradient Colors (used in Login / Register)
  static Color get gradientStart =>
      isDark ? const Color(0xFF1D1917) : const Color(0xFFFDFBF7);
  static Color get gradientEnd =>
      isDark ? const Color(0xFF2C2521) : const Color(0xFFFAEDCD);

  // Text Colors
  static Color get textDark =>
      isDark ? const Color(0xFFF5EFE9) : const Color(0xFF1E293B);
  static Color get textPrimary =>
      isDark ? const Color(0xFFFFFDFB) : const Color(0xFF333333);
  static Color get textSecondary =>
      isDark ? const Color(0xFFA5978F) : const Color(0xFF64748B);

  // Border Colors
  static Color get border =>
      isDark ? const Color(0xFF3D322C) : const Color(0xFFE2E8F0);
  static Color get borderLight =>
      isDark ? const Color(0xFF2E2622) : const Color(0xFFF1F5F9);

  // Status Colors
  static Color get success => Colors.green;
  static Color get error => Colors.red;
  static Color get warning => Colors.orange;
}

// ------------------------------------------------------------
//  SPACING / PADDING
// ------------------------------------------------------------
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  /// General screen padding
  static const EdgeInsets screenPadding = EdgeInsets.all(24.0);
  static const EdgeInsets screenPaddingH = EdgeInsets.symmetric(
    horizontal: 20.0,
    vertical: 24.0,
  );

  /// Padding for Card
  static const EdgeInsets cardPadding = EdgeInsets.all(20.0);
}

// ------------------------------------------------------------
//  FONT SIZES
// ------------------------------------------------------------
class AppFontSize {
  AppFontSize._();

  static const double xs = 10.0;
  static const double sm = 12.0;
  static const double md = 14.0;
  static const double body = 15.0;
  static const double lg = 16.0;
  static const double xl = 18.0;
  static const double xxl = 20.0;
  static const double title = 24.0;
  static const double heading = 32.0;
}

// ------------------------------------------------------------
//  BORDER RADIUS
// ------------------------------------------------------------
class AppRadius {
  AppRadius._();

  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 14.0;
  static const double xl = 16.0;
  static const double xxl = 18.0;
  static const double pill = 20.0;
  static const double round = 30.0;

  static BorderRadius get borderSm => BorderRadius.circular(sm);
  static BorderRadius get borderMd => BorderRadius.circular(md);
  static BorderRadius get borderLg => BorderRadius.circular(lg);
  static BorderRadius get borderXl => BorderRadius.circular(xl);
  static BorderRadius get borderXxl => BorderRadius.circular(xxl);
  static BorderRadius get borderPill => BorderRadius.circular(pill);
}

// ------------------------------------------------------------
//  ELEVATION / SHADOWS
// ------------------------------------------------------------
class AppShadow {
  AppShadow._();

  static List<BoxShadow> get card => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get avatar => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
}

// ------------------------------------------------------------
//  ROLE IDs
// ------------------------------------------------------------
class AppRoles {
  AppRoles._();

  static const int user = 1;
  static const int owner = 2;
  static const int admin = 3;

  static const String nameUser = 'User';
  static const String nameOwner = 'Owner';
  static const String nameAdmin = 'Admin';
}

// ------------------------------------------------------------
//  GENDER OPTIONS
// ------------------------------------------------------------
class AppGenders {
  AppGenders._();

  static const List<String> options = ['Male', 'Female', 'Other'];
}

// ------------------------------------------------------------
//  BOOKING STATUS
// ------------------------------------------------------------
class AppBookingStatus {
  AppBookingStatus._();

  static const String pending = 'pending';
  static const String approved = 'approved';
  static const String rejected = 'rejected';
  static const String cancelled = 'cancelled';
}
