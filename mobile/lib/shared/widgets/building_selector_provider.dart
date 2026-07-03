// Presentation facade — building selection provider'larını ekranlara sunar.
//
// Ekranlar doğrudan buildings_store.dart
// import etmek yerine bu facade üzerinden buildingsStoreProvider
// ve BuildingEntity kullanır.
export '../../features/buildings/data/buildings_store.dart'
    show buildingsStoreProvider;
export '../../features/buildings/domain/entities/building_entity.dart';
