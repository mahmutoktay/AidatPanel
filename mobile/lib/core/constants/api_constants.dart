class ApiConstants {
  static const String baseUrl = 'https://api.aidatpanel.com';
  static const String apiVersion = '/api/v1';

  /// `wss://api.aidatpanel.com/api/v1/realtime?token=...`
  static Uri realtimeWebSocketUri(String accessToken) {
    final https = Uri.parse(baseUrl);
    final scheme = https.scheme == 'https' ? 'wss' : 'ws';
    return Uri(
      scheme: scheme,
      host: https.host,
      port: https.hasPort ? https.port : null,
      path: '$apiVersion/realtime',
      queryParameters: {'token': accessToken},
    );
  }

  // Auth endpoints
  static const String register = '$apiVersion/auth/register';
  static const String login = '$apiVersion/auth/login';
  static const String refresh = '$apiVersion/auth/refresh';
  static const String logout = '$apiVersion/auth/logout';
  static const String logoutAllDevices =
      '$apiVersion/auth/logout-all-devices';
  static const String join = '$apiVersion/auth/join';
  static const String forgotPassword = '$apiVersion/auth/forgot-password';
  static const String resetPassword = '$apiVersion/auth/reset-password';

  // Buildings endpoints
  static const String buildings = '$apiVersion/buildings';
  static const String buildingsCollectionPresets =
      '$apiVersion/buildings/collection-presets';
  static String buildingDetail(String buildingId) =>
      '$apiVersion/buildings/$buildingId';
  static String buildingCollection(String buildingId) =>
      '$apiVersion/buildings/$buildingId/collection';
  static String buildingApartments(String buildingId) =>
      '$apiVersion/buildings/$buildingId/apartments';
  static String buildingDues(String buildingId) =>
      '$apiVersion/buildings/$buildingId/dues';
  static String buildingDueStatus(String buildingId, String dueId) =>
      '$apiVersion/buildings/$buildingId/dues/$dueId/status';
  static String buildingDueAmount(String buildingId) =>
      '$apiVersion/buildings/$buildingId/due-amount';
  static String buildingDuesRemind(String buildingId) =>
      '$apiVersion/buildings/$buildingId/dues/remind';
  static String buildingExpenses(String buildingId) =>
      '$apiVersion/buildings/$buildingId/expenses';
  static String buildingExpensesSummary(String buildingId) =>
      '$apiVersion/buildings/$buildingId/expenses/summary';
  static String buildingTickets(String buildingId) =>
      '$apiVersion/buildings/$buildingId/tickets';
  static String buildingAnnouncements(String buildingId) =>
      '$apiVersion/buildings/$buildingId/announcements';
  static String apartmentTickets(String apartmentId) =>
      '$apiVersion/apartments/$apartmentId/tickets';
  static String buildingReports(String buildingId) =>
      '$apiVersion/buildings/$buildingId/reports';

  // Apartments endpoints
  // Belge §6: daire CRUD'u nested path altında (/buildings/:bId/apartments[/:id])
  // ApartmentRemoteDataSource bu nested path'i kullanır; düz /apartments/:id
  // ucu backend'de yoktur, bu yüzden burada sabit tanımlanmaz.
  static String apartmentInviteCode(String apartmentId) =>
      '$apiVersion/apartments/$apartmentId/invite-code';

  /// Tur 5 / §3.1 — Manager bir daireden sakini çıkarır (hesap silinmez,
  /// sadece bağlantı kopar). Backend `apartments/data/...` koleksiyonu döner.
  static String apartmentResident(String buildingId, String apartmentId) =>
      '$apiVersion/buildings/$buildingId/apartments/$apartmentId/resident';

  // Dues endpoints
  static const String myDues = '$apiVersion/me/dues';

  // Dekont endpoints
  static const String myPaymentCollection = '$apiVersion/me/payment-collection';
  static const String myDekonts = '$apiVersion/me/dekonts';
  static const String dekontUpload = '$apiVersion/dekonts/upload';
  static String dekont(String dekontId) => '$apiVersion/dekonts/$dekontId';
  static String dekontReview(String dekontId) =>
      '$apiVersion/dekonts/$dekontId/review';
  static String dekontFile(String dekontId) =>
      '$apiVersion/dekonts/$dekontId/file';
  static String buildingDekonts(String buildingId) =>
      '$apiVersion/buildings/$buildingId/dekonts';

  // Expenses endpoints
  static String expense(String expenseId) => '$apiVersion/expenses/$expenseId';
  static String expenseProof(String expenseId) =>
      '$apiVersion/expenses/$expenseId/proof';

  // Tickets endpoints
  static String ticket(String ticketId) => '$apiVersion/tickets/$ticketId';
  static String ticketUpdates(String ticketId) =>
      '$apiVersion/tickets/$ticketId/updates';
  static String ticketStatus(String ticketId) =>
      '$apiVersion/tickets/$ticketId/status';
  static const String myTickets = '$apiVersion/me/tickets';

  // Notifications endpoints
  static const String notifications = '$apiVersion/notifications';
  static const String notificationsUnreadCount =
      '$apiVersion/notifications/unread-count';
  static const String notificationsReadAll =
      '$apiVersion/notifications/read-all';
  static String notificationRead(String notificationId) =>
      '$apiVersion/notifications/$notificationId/read';
  static const String fcmToken = '$apiVersion/me/fcm-token';

  // Profile endpoints
  static const String profile = '$apiVersion/me';
  static const String changePassword = '$apiVersion/me/password';
  static const String changeLanguage = '$apiVersion/me/language';

  // Subscription endpoints
  static const String subscription = '$apiVersion/me/subscription';
  static const String revenuecatWebhook =
      '$apiVersion/subscription/webhook/revenuecat';
}
