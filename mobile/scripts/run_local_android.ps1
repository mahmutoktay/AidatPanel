# Yerel backend + Android emülatör testi
# Önce backend: cd backend; npm run dev

flutter run -t lib/main_local.dart `
  --dart-define=USE_LOCAL_BACKEND=true `
  --dart-define=LOCAL_API_BASE_URL=http://10.0.2.2:4200 `
  @args
