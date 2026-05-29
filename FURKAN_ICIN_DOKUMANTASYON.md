# Furkan İçin JWT ve Flutter Entegrasyon Rehberi

## � Clean Architecture Klasör Yapısı

AIDATPANEL.md'deki yapıya göre dosyalarını şu şekilde organize et:

```
lib/
├── core/
│   ├── constants/
│   │   └── api_constants.dart      # Base URL'ler burada
│   ├── network/
│   │   ├── dio_client.dart         # JWT interceptor burada
│   │   └── api_exception.dart
│   ├── storage/
│   │   └── secure_storage.dart     # Token saklama burada
│   └── router/
│       └── app_router.dart         # GoRouter tanımları burada
├── features/
│   └── auth/
│       ├── data/
│       │   ├── repositories/
│       │   │   └── auth_repository.dart
│       │   └── models/
│       │       └── user_model.dart
│       ├── domain/
│       │   └── providers/
│       │       └── auth_provider.dart
│       └── presentation/
│           ├── screens/
│           │   ├── login_screen.dart
│           │   ├── sign_up_screen.dart   # Birleşik kayıt (sakin + yönetici)
│           │   ├── splash_screen.dart
│           │   ├── forgot_password_screen.dart
│           │   └── reset_password_screen.dart
│           └── widgets/
│               └── sign_up_role_toggle.dart
└── main.dart
```

> **Not (2026-05-25):** Eski `register_screen.dart` ve `join_screen.dart` kaldırıldı. Router alias: `/register` ve `/join` → `SignUpScreen`.

**Önemli:** JWT kodlarını `core/` katmanına koy, `features/auth/` sadece business logic içersin.

---

## 🌐 Backend API Response Formatı

Backend'den gelen tüm response'lar şu standart formattadır:

```json
{
  "success": true,
  "message": "İşlem başarılı",
  "data": { ... }
}
```

### Login Response Örneği:

```json
{
  "success": true,
  "message": "Giriş başarılı.",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
    "user": {
      "id": "abc123",
      "email": "furkan@example.com",
      "name": "Furkan",
      "role": "MANAGER"
    }
  }
}
```

### Hata Response Örneği:

```json
{
  "success": false,
  "error": "Email veya şifre hatalı."
}
```

**Önemli:** `response.data['accessToken']` yerine `response.data['data']['accessToken']` kullan!

---

## 🔑 JWT Nedir? (Basit Açıklama)

JWT (JSON Web Token), kullanıcının kimliğini doğrulayan bir şifreli anahtardır. Backend'den login olunca şu şekilde bir token alırsın:

```json
{
  "success": true,
  "message": "Giriş başarılı.",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
    "user": {
      "id": "abc123",
      "email": "furkan@example.com",
      "name": "Furkan",
      "role": "MANAGER"
    }
  }
}
```

**İki tip token var:**
- **Access Token**: 15 dakika geçerli. API isteklerinde kullanılır.
- **Refresh Token**: 30 gün geçerli. Access token bittiğinde yeni access token almak için kullanılır.

**Neden ikisi var?** Güvenlik. Access token kısa ömürlü olsa bile ele geçirilirse zarar sınırlı kalır. Refresh token sadece token yenileme endpoint'inde kullanılır.

---

## 🔐 1. Token Saklama (Secure Storage)

Token'ları telefonun güvenli deposunda saklayacaksın. `flutter_secure_storage` paketi kullanılacak.

### pubspec.yaml'a ekle:
```yaml
dependencies:
  flutter_secure_storage: ^9.0.0
  dio: ^5.4.0
```

### Token Service Oluştur (lib/core/storage/token_storage.dart):

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();
  
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  
  /// Token'ları kaydet (Login başarılı olunca çağrılır)
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }
  
  /// Access token'ı oku (Her API isteğinde kullanılır)
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }
  
  /// Refresh token'ı oku (Token yenilemede kullanılır)
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }
  
  /// Access token'ı güncelle (Refresh sonrası)
  static Future<void> updateAccessToken(String newAccessToken) async {
    await _storage.write(key: _accessTokenKey, value: newAccessToken);
  }
  
  /// Tüm token'ları sil (Logout'ta kullanılır)
  static Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
  
  /// Token var mı kontrol et (Splash ekranında kullanılır)
  static Future<bool> hasTokens() async {
    final accessToken = await getAccessToken();
    return accessToken != null;
  }
}
```

---

## 🌐 2. API İsteklerine Token Ekleme (Dio Interceptor)

Her API isteğine otomatik olarak "Authorization: Bearer <token>" header'ı eklemelisin. Buna Interceptor denir.

### API Constants Oluştur (lib/core/constants/api_constants.dart):

```dart
import 'dart:io';

class ApiConstants {
  static const String _prod    = 'https://api.aidatpanel.com/api/v1';
  static const String _android = 'http://10.0.2.2:4200/api/v1';   // Android emülatör
  static const String _ios     = 'http://localhost:4200/api/v1';   // iOS simülatör

  static String get baseUrl {
    // Release build'de her zaman production URL kullan
    const bool isRelease = bool.fromEnvironment('dart.vm.product');
    if (isRelease) return _prod;
    return Platform.isAndroid ? _android : _ios;
  }
}
```

### Dio Client Oluştur (lib/core/network/dio_client.dart):

```dart
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/token_storage.dart';

class DioClient {
  static Dio? _dio;

  static Dio get dio {
    _dio ??= _createDio();
    return _dio!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },

        onResponse: (response, handler) {
          return handler.next(response);
        },

        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              final newToken = await TokenStorage.getAccessToken();
              error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              final response = await dio.fetch(error.requestOptions);
              return handler.resolve(response);
            }
            // Refresh başarısız: token'ları temizle, auth state'i unauthenticated yap
            await TokenStorage.clearTokens();
          }
          return handler.next(error);
        },
      ),
    );

    return dio;
  }

  // Refresh isteği için interceptor'sız ayrı Dio — sonsuz döngüyü önler
  static Future<bool> _refreshToken() async {
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final plainDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
      final response = await plainDio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final newAccessToken = response.data['data']['accessToken'];
      await TokenStorage.updateAccessToken(newAccessToken);
      return true;
    } catch (e) {
      return false;
    }
  }
}
```

---

## 🔑 3. Login Akışı

```dart
import 'package:dio/dio.dart';
import '../storage/token_storage.dart';
import '../network/dio_client.dart';

class AuthRepository {
  final _dio = DioClient.dio;
  
  Future<bool> login({required String email, required String password}) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      
      // Başarılı yanıt (yeni format: response.data['data'])
      final responseData = response.data;
      final data = responseData['data'];
      
      // Token'ları kaydet
      await TokenStorage.saveTokens(
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
      );
      
      // Kullanıcı bilgilerini kaydet (Riverpod state veya SharedPreferences)
      // ...
      
      return true;
    } on DioException catch (e) {
      // Hata yönetimi
      print('Login hatası: ${e.response?.data['error']}');
      return false;
    }
  }
}
```

---

## 🚪 4. Logout Akışı

```dart
class AuthRepository {
  final _dio = DioClient.dio;
  
  Future<void> logout() async {
    try {
      // Backend'e logout bildirimi (opsiyonel)
      await _dio.post('/auth/logout');
    } catch (e) {
      // Hata olsa bile devam et
    }
    
    // Token'ları temizle
    await TokenStorage.clearTokens();
    
    // Kullanıcı state'ini temizle (Riverpod)
    // ...
    
    // Login ekranına yönlendir
    // Navigator.pushReplacementNamed(context, '/login');
  }
}
```

---

## 🔄 4.1 Riverpod Auth State Management

AIDATPANEL.md'deki gibi Riverpod kullanarak auth state'i yönet.

### pubspec.yaml'a ekle:
```yaml
dependencies:
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0

dev_dependencies:
  riverpod_generator: ^2.3.0
  build_runner: ^2.4.0
```

### Auth State Provider (lib/features/auth/domain/providers/auth_provider.dart):

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../../core/storage/secure_storage.dart';

part 'auth_provider.g.dart';  // build_runner ile otomatik oluşturulur

/// Auth durumunu temsil eden enum
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

/// Auth state class
class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;
  
  AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });
  
  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Auth State Notifier
@riverpod
class AuthNotifier extends _$AuthNotifier {
  late final AuthRepository _authRepository;
  
  @override
  AuthState build() {
    _authRepository = ref.read(authRepositoryProvider);
    // Uygulama başlarken token kontrolü
    _checkAuth();
    return AuthState();
  }
  
  /// Token var mı kontrol et (Splash ekranında)
  Future<void> _checkAuth() async {
    final hasToken = await TokenStorage.hasTokens();
    if (hasToken) {
      state = state.copyWith(status: AuthStatus.authenticated);
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }
  
  /// Login
  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    
    try {
      final result = await _authRepository.login(
        email: email,
        password: password,
      );
      
      if (result.success) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: result.user,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: result.errorMessage,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Bir hata oluştu',
      );
    }
  }
  
  /// Logout
  Future<void> logout() async {
    await _authRepository.logout();
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      user: null,
    );
  }
}

/// Global auth provider
final authProvider = authNotifierProvider;
```

### Auth Repository Provider:

```dart
// lib/features/auth/data/repositories/auth_repository_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'auth_repository.dart';

part 'auth_repository_provider.g.dart';

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository();
}
```

### Ekranda Kullanımı:

```dart
// lib/features/auth/presentation/login_screen.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Auth state'i dinle
    final authState = ref.watch(authProvider);
    
    // Loading durumunda
    if (authState.status == AuthStatus.loading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    // Error durumunda
    if (authState.status == AuthStatus.error) {
      // Hata mesajını göster
      print('Hata: ${authState.errorMessage}');
    }
    
    return Scaffold(
      body: Column(
        children: [
          // Email/Password inputları...
          ElevatedButton(
            onPressed: () {
              // Login butonuna basınca
              ref.read(authProvider.notifier).login(
                'email@example.com',
                'password123',
              );
            },
            child: Text('Giriş Yap'),
          ),
        ],
      ),
    );
  }
}
```

---

## 🧭 5. GoRouter Navigation ve Auth Guard

AIDATPANEL.md'deki gibi GoRouter kullanarak yönlendirmeyi yap ve auth kontrolü ekle.

### pubspec.yaml'a ekle:
```yaml
dependencies:
  go_router: ^13.0.0
```

### App Router (lib/core/router/app_router.dart):

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/dashboard/presentation/screens/manager_dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/resident_dashboard_screen.dart';

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  
  return GoRouter(
    initialLocation: '/',
    // Her yönlendirme öncesi auth state kontrolü
    redirect: (context, state) {
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isUnauthenticated = authState.status == AuthStatus.unauthenticated;
      final isLoading = authState.status == AuthStatus.loading;
      
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/sign-up' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/join' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation == '/reset-password';
      final isSplashRoute = state.matchedLocation == '/';
      
      // Loading durumunda hiçbir yere gitme (Splash göster)
      if (isLoading && !isSplashRoute) {
        return '/';
      }
      
      // Kimliği doğrulanmamış kullanıcı sadece auth route'ları görebilir
      if (isUnauthenticated) {
        if (isAuthRoute || isSplashRoute) {
          return null;
        }
        return '/login';
      }
      
      // Kimliği doğrulanmış kullanıcı auth sayfalarına gitmeye çalışırsa dashboard'a
      if (isAuthenticated && (isAuthRoute || isSplashRoute) && !isSplashRoute) {
        final isManager = authState.user?.role == UserRole.manager;
        return isManager ? '/manager-dashboard' : '/resident-dashboard';
      }
      
      return null;  // Normal akışa devam et
    },
    routes: [
      // Splash / Initial route
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Auth Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/sign-up',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const SignUpScreen(initialIsManager: true),
      ),
      GoRoute(
        path: '/join',
        builder: (context, state) => const SignUpScreen(),
      ),
      
      GoRoute(
        path: '/manager-dashboard',
        builder: (context, state) => const ManagerDashboardScreen(),
      ),
      GoRoute(
        path: '/resident-dashboard',
        builder: (context, state) => const ResidentDashboardScreen(),
      ),
    ],
  );
});
```

### Splash Screen (lib/features/splash/splash_screen.dart):

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/domain/providers/auth_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStatus = ref.watch(authProvider).status;
    
    return Scaffold(
      body: Center(
        child: authStatus == AuthStatus.loading
            ? const CircularProgressIndicator()
            : const FlutterLogo(size: 100),
      ),
    );
  }
}
```

### Main.dart'ta Kullanımı:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'AidatPanel',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
      ),
    );
  }
}
```

### Ekran İçinde Navigation:

```dart
import 'package:go_router/go_router.dart';

// Login başarılı olunca
context.go('/manager');  // veya '/resident'

// Logout olunca
context.go('/login');

// Register sayfasına git
context.push('/register');

// Geri git
context.pop();
```

---

## 🔄 6. Token Akış Şeması (Adım Adım)

```
┌─────────────┐     Login      ┌─────────────┐
│   Kullanıcı │ ─────────────> │   Backend   │
│  (Flutter)  │                │  (Node.js)  │
└─────────────┘                └─────────────┘
                                      │
                                      │ {accessToken, refreshToken}
                                      ▼
┌─────────────┐              ┌─────────────┐
│   Kullanıcı │ <─────────── │   Backend   │
│  (Flutter)  │              └─────────────┘
└─────────────┘                      │
     │                               │
     │ Token'ları                    │
     │ Secure Storage'a kaydet       │
     ▼                               │
┌─────────────┐                      │
│  Her API    │                      │
│  isteğinde  │                      │
│  otomatik   │                      │
│  Authorization: Bearer <token>     │
│  header'ı ekle                     │
└─────────────┘                      │
     │                               │
     │ 401 hatası                    │
     │ (Token süresi doldu)          │
     ▼                               │
┌─────────────┐      /refresh        │
│  Refresh    │ ───────────────────> │
│  Token ile  │                      │
│  yeni       │ <─────────────────── │
│  Access     │  {accessToken}       │
│  Token al   │                      │
└─────────────┘                      │
     │                               │
     ▼                               ▼
┌─────────────┐              ┌─────────────┐
│  İsteği     │              │   Backend   │
│  yeni       │ ───────────> │             │
│  token ile  │              │             │
│  tekrar dene│              │             │
└─────────────┘              └─────────────┘
```

---

## 🎯 7. Önemli Notlar

### A. Token Süreleri
- **Access Token**: 15 dakika (Backend'de ayarlanmış)
- **Refresh Token**: 30 gün (Backend'de ayarlanmış)

Kullanıcı 15 dakika işlem yapmazsa, bir sonraki istekte otomatik olarak refresh çalışır. Kullanıcı bunu hissetmez.

### B. Secure Storage Avantajı
- iOS: Keychain kullanır (en güvenli)
- Android: EncryptedSharedPreferences kullanır
- Normal SharedPreferences'tan farkı: Şifrelenmiş saklar

### C. Hata Senaryoları

| Durum | Ne Olur | Çözüm |
|-------|---------|-------|
| Access token süresi doldu | 401 hatası | Interceptor otomatik refresh yapar |
| Refresh token süresi doldu | Refresh başarısız | Kullanıcı login ekranına yönlendirilir |
| İnternet yok | Timeout hatası | "İnternet bağlantınızı kontrol edin" mesajı |
| Yanlış şifre | 400 hatası | "Email veya şifre hatalı" mesajı |

---

## 📝 8. Test Senaryoları

### Test 1: Login
1. Login ekranına git
2. Email/şifre gir
3. Login butonuna bas
4. Başarılı yanıt bekleyen: Token'lar kaydedilmeli

### Test 2: Korumalı API
1. Login ol
2. Bina listeleme API'sini çağır
3. Header'da Authorization olmalı
4. 200 OK gelmeli

### Test 3: Token Yenileme
1. Login ol
2. 15 dakika bekle (veya backend'de token süresini 1 saniye yap test için)
3. Yeni bir API isteği yap
4. Otomatik olarak refresh çalışmalı, istek başarılı olmalı

### Test 4: Logout
1. Login ol
2. Logout butonuna bas
3. Token'lar silinmeli
4. Login ekranına yönlendirilmeli

---

## 🆘 Yardım İhtiyacı Olursa

Bu dokümanı anlamazsan:
1. `flutter_secure_storage` örneklerine bak
2. Dio interceptor dokümantasyonunu oku
3. JWT nedir videosu izle (YouTube'da "JWT explained" ara)

Soruların olursa Abdullah'a sor, backend tarafını o yönetiyor.

---

**Hazırlayan:** Backend (Abdullah)  
**Hedef:** Mobil (Furkan)  
**Amaç:** JWT mantığını ve Flutter implementasyonunu anlamak

---

## 📋 EK A: Backend API Endpoint Listesi

### Auth Endpoints (Kimlik Doğrulama)

| Method | Endpoint | Auth Gerekli | Açıklama |
|--------|----------|--------------|----------|
| POST | `/api/v1/auth/register` | Hayır | Yeni kullanıcı kaydı (MANAGER rolüyle) |
| POST | `/api/v1/auth/login` | Hayır | Giriş yap, token al |
| POST | `/api/v1/auth/refresh` | Hayır | Access token yenile |
| POST | `/api/v1/auth/logout` | Evet | Çıkış yap |

### Building Endpoints (Bina Yönetimi)

| Method | Endpoint | Auth Gerekli | Açıklama |
|--------|----------|--------------|----------|
| POST | `/api/v1/buildings` | Evet | Yeni bina oluştur |
| GET | `/api/v1/buildings` | Evet | Tüm binaları listele |
| GET | `/api/v1/buildings/:id` | Evet | Bina detayı getir |
| PUT | `/api/v1/buildings/:id` | Evet | Bina güncelle |
| DELETE | `/api/v1/buildings/:id` | Evet | Bina sil |

### Apartment Endpoints (Daire Yönetimi)

| Method | Endpoint | Auth Gerekli | Açıklama |
|--------|----------|--------------|----------|
| GET | `/api/v1/buildings/:buildingId/apartments` | Evet | Binadaki daireleri listele |
| POST | `/api/v1/buildings/:buildingId/apartments` | Evet | Daire ekle |
| DELETE | `/api/v1/buildings/:buildingId/apartments/:id` | Evet | Daire sil |

### Request/Response Örnekleri

**Register Request:**
```json
{
  "name": "Ahmet Yönetici",
  "email": "ahmet@site.com",
  "password": "sifre123"
}
```

**Register Response (201):**
```json
{
  "success": true,
  "message": "Hesabınız başarıyla oluşturuldu.",
  "data": {
    "user": {
      "id": "abc123",
      "name": "Ahmet Yönetici",
      "email": "ahmet@site.com",
      "role": "MANAGER"
    }
  }
}
```

**Building Create Request:**
```json
{
  "name": "Yıldız Apartmanı",
  "address": "Atatürk Cad. No:15",
  "city": "İstanbul"
}
```

**Building List Response (200):**
```json
{
  "success": true,
  "message": "Binalar başarıyla listelendi.",
  "data": [
    {
      "id": "bina123",
      "name": "Yıldız Apartmanı",
      "address": "Atatürk Cad. No:15",
      "city": "İstanbul",
      "managerId": "user123"
    }
  ]
}
```

---

## 🐛 EK B: Debugging Rehberi

### 1. API İsteklerini İzleme

Dio Interceptor'a log eklemek için `onRequest`, `onResponse`, `onError` callback'lerini kullan:

```dart
onRequest: (options, handler) {
  print('📤 REQUEST: ${options.method} ${options.path}');
  print('Headers: ${options.headers}');
  print('Body: ${options.data}');
  return handler.next(options);
},
onResponse: (response, handler) {
  print('✅ RESPONSE: ${response.statusCode}');
  print('Data: ${response.data}');
  return handler.next(response);
},
onError: (error, handler) {
  print('❌ ERROR: ${error.response?.statusCode}');
  print('Message: ${error.message}');
  print('Response Data: ${error.response?.data}');
  return handler.next(error);
},
```

### 2. Token Kontrolü

Secure Storage'daki token'ları görüntüleme:

```dart
// main.dart veya debug ekranında
Future<void> checkTokens() async {
  final accessToken = await TokenStorage.getAccessToken();
  final refreshToken = await TokenStorage.getRefreshToken();
  
  print('Access Token: $accessToken');
  print('Refresh Token: $refreshToken');
  print('Token Var mı: ${await TokenStorage.hasTokens()}');
}
```

### 3. Yaygın Hatalar ve Çözümleri

| Hata | Status Code | Nedeni | Çözüm |
|------|-------------|--------|-------|
| 401 Unauthorized | 401 | Token geçersiz/süresi dolmuş | Interceptor otomatik refresh yapar, refresh de başarısızsa login'e yönlendir |
| 400 Bad Request | 400 | Eksik/yanlış parametre | Request body'i kontrol et, tüm required alanları gönder |
| 404 Not Found | 404 | Kaynak bulunamadı | ID doğruluğunu kontrol et |
| Network Error | - | İnternet yok/Sunucu kapalı | Bağlantıyı kontrol et, backend'in çalıştığından emin ol |
| Timeout | - | İstek çok uzun sürdü | Internet bağlantısını kontrol et, tekrar dene |

### 4. Thunder Client / Postman ile Test

**Login Test (local):**
```
POST http://localhost:4200/api/v1/auth/login
Content-Type: application/json

{
  "email": "test@test.com",
  "password": "123456"
}
```

**Login Test (production):**
```
POST https://api.aidatpanel.com/api/v1/auth/login
Content-Type: application/json

{
  "email": "test@test.com",
  "password": "123456"
}
```

**Building List Test (Auth Gerekli):**
```
GET https://api.aidatpanel.com/api/v1/buildings
Authorization: Bearer <access_token>
```

### 5. Response Format Debug

Yeni response formatı ile debug:

```dart
// DOĞRU - Yeni format
final response = await dio.post('/auth/login', data: {...});
final responseData = response.data;  // {success: true, message: "...", data: {...}}
final data = responseData['data'];     // {accessToken: "...", refreshToken: "..."}
final accessToken = data['accessToken'];

// YANLIŞ - Eski formatı beklemek
final accessToken = response.data['accessToken'];  // null döner!
```

### 6. Token Yenileme Debug

Token yenileme sırasında log:

```dart
static Future<bool> _refreshToken() async {
  try {
    final refreshToken = await TokenStorage.getRefreshToken();
    print('Mevcut refresh token: $refreshToken');
    
    final response = await dio.post('/auth/refresh', ...);
    print('Refresh response: ${response.data}');
    
    final newAccessToken = response.data['data']['accessToken'];
    print('Yeni access token: $newAccessToken');
    
    await TokenStorage.updateAccessToken(newAccessToken);
    return true;
  } catch (e) {
    print('Refresh hatası: $e');
    return false;
  }
}
```
