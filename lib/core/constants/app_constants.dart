class AppConstants {
  // App Info
  static const String appName = 'ETİSAN';
  static const String appVersion = '1.0.0';
  
  // Supabase Configuration (Bu bilgileri gerçek Supabase projenizden alacaksınız)
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  // Reservation Rules
  static const int maxAdvanceReservationDays = 7;
  static const int cancelDeadlineHours = 24;
  static const int swapDeadlineHours = 48;
  static const double cancelRefundPercentage = 0.5;
  
  // Balance Rules
  static const double minBalanceLoad = 10.0;
  static const double maxBalanceLoad = 1000.0;
  static const List<double> quickBalanceAmounts = [50, 100, 200, 500];
  
  // Date Formats
  static const String displayDateFormat = 'dd MMM yyyy';
  static const String displayTimeFormat = 'HH:mm';
  static const String displayDateTimeFormat = 'EEEE, MMM dd, yyyy';
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  
  // Demo Users
  static const String demoStudentEmail = 'student@etisan.com';
  static const String demoStudentPassword = 'password123';
  static const String demoAdminEmail = 'admin@etisan.com';
  static const String demoAdminPassword = 'password123';
}

