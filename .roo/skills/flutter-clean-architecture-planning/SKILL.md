---
name: flutter-clean-architecture-planning
description: Flutter projesinde yeni bir özellik eklemeden, yeni dosya/sınıf oluşturmadan veya önemli bir kod değişikliğine başlamadan ÖNCE mutlaka bu beceriyi kullan. Kullanıcı "yeni feature ekle", "şunu implemente et", "bu özelliği nasıl yapmalıyım", "yeni bir ekran/sayfa oluştur", "API entegrasyonu ekle" gibi bir istekte bulunduğunda, kod yazmaya başlamadan önce Clean Architecture katmanlarını (presentation/domain/data), olası yaklaşımları ve trade-off'ları değerlendirmek için kullan. Doğrudan koda atlamak yerine önce planlama yapmak istendiğinde devreye gir.
---

# Flutter Clean Architecture - Kodlamadan Önce Planlama

Bu beceri, kod yazmaya başlamadan önce sistematik düşünmeyi zorunlu kılar. Amaç: doğrudan dosya oluşturup kod yazmak yerine, önce mimariyi ve alternatifleri değerlendirmek.

## Kullanım Kuralı

Bu beceri tetiklendiğinde, **kod yazmadan önce** aşağıdaki adımları sırayla uygula ve kullanıcıya kısa bir plan sun. Kullanıcı onaylamadan dosya oluşturma/kod yazma adımına geçme (kullanıcı açıkça "direkt yaz" demediği sürece).

### Adım 1: Katman Tespiti

Her yeni iş için şu soruları cevapla:
- Bu bir **Presentation** katmanı işi mi? (UI, widget, state yönetimi - Bloc/Cubit/Riverpod/Provider)
- Bir **Domain** katmanı işi mi? (Entity, UseCase, Repository interface - saf Dart, framework bağımsız)
- Bir **Data** katmanı işi mi? (Repository implementation, DataSource, Model/DTO, mapper)

### Adım 2: Bağımlılık Yönü Kontrolü

Clean Architecture'da bağımlılık her zaman içe doğru akar:

```
Presentation  →  Domain  ←  Data
```

- Domain katmanı hiçbir zaman Data veya Presentation'a bağımlı olmamalı (Flutter/http/dio importu olmamalı)
- Presentation sadece Domain'i (UseCase, Entity) bilmeli, Data katmanından doğrudan haberi olmamalı
- Data katmanı, Domain'deki Repository interface'ini implemente eder

### Adım 3: Alternatifleri Listele

Kod yazmadan önce en az 2 yaklaşımı kısaca karşılaştır:

| Yaklaşım | Artı | Eksi |
|---|---|---|
| Örnek: Tek UseCase'de tüm mantık | Basit, az dosya | Test edilebilirlik düşük |
| Örnek: Ayrı UseCase'ler + Repository | Test edilebilir, SOLID | Daha fazla boilerplate |

Mevcut state management aracını (Bloc/Cubit/Riverpod/Provider/GetX) projede ne kullanılıyorsa onunla tutarlı öner — kullanıcı açıkça istemedikçe yeni bir tane önerme.

### Adım 4: Klasör/Dosya Planı Sun

```
lib/
└── features/
    └── {feature_adi}/
        ├── domain/
        │   ├── entities/{entity}.dart
        │   ├── repositories/{feature}_repository.dart   # interface
        │   └── usecases/{usecase_adi}.dart
        ├── data/
        │   ├── models/{model}.dart                       # fromJson/toJson
        │   ├── datasources/{feature}_remote_datasource.dart
        │   └── repositories/{feature}_repository_impl.dart
        └── presentation/
            ├── bloc/ (veya cubit/ veya providers/)
            ├── pages/
            └── widgets/
```

### Adım 5: Test Edilebilirlik Notu

Her UseCase ve Repository interface'i mock'lanabilir olmalı. Repository interface'leri her zaman abstract class olarak Domain'de tanımlanmalı.

## Şablonlar

### Entity (saf Dart, framework bağımsız)
```dart
class User extends Equatable {
  final String id;
  final String name;

  const User({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
```

### Repository Interface (Domain)
```dart
abstract class UserRepository {
  Future<Either<Failure, User>> getUser(String id);
}
```

### UseCase
```dart
class GetUser {
  final UserRepository repository;
  GetUser(this.repository);

  Future<Either<Failure, User>> call(String id) {
    return repository.getUser(id);
  }
}
```

### Repository Implementation (Data)
```dart
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  UserRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, User>> getUser(String id) async {
    try {
      final model = await remoteDataSource.getUser(id);
      return Right(model.toEntity());
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
```

## Sık Yapılan Hatalar (Bunlardan Kaçın)

- Domain katmanına `dart:io`, `http`, `dio`, `flutter/material.dart` import etmek
- Model sınıflarını (fromJson/toJson) Entity'ye map etmeden doğrudan UI'da kullanmak
- Business logic'i widget'ların `build()` metodu içine yazmak
- Bloc/Cubit içinde doğrudan HTTP çağrısı yapmak (Repository/UseCase atlamak)
- Basit bir CRUD için gereksiz katman şişirme — pragmatik ol, projenin boyutuna göre ayarla

## Çıktı Formatı

1. **Hangi katmanlar etkileniyor** (1-2 cümle)
2. **Önerilen yaklaşım ve neden** (alternatiflerle kısa karşılaştırma)
3. **Oluşturulacak/değiştirilecek dosyalar** (liste)
4. Kullanıcı onayladıktan sonra kodu yaz
