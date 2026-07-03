/// Yerel backend ile gerçek API + Twilio OTP testi.
///
///   cd backend && npm run dev
///   cd mobile && flutter run -t lib/main_local.dart
///
/// API: http://10.0.2.2:4200 (Android emülatör)
/// OTP: Twilio → Verified numaranız (5315635049)
/// SMS gelmezse: backend terminalinde `otp_dev` satırına bakın.
library;

import 'core/constants/api_constants.dart';
import 'main.dart' as app;

void main() {
  ApiConstants.enableLocalBackend();
  app.main();
}
