import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/data/repositories/admin_repository.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';

/// Serves `/business-types/admin/all` (no counts) and `/stats` (counts only)
/// in the shapes the backend sends.
class FakeShopTypesRepository extends AdminRepository {
  FakeShopTypesRepository({this.statsFail = false}) : super(dio: Dio());
  final bool statsFail;

  @override
  Future<List<ShopType>> getAllShopTypes() async => [
    ShopType.fromJson({
      'id': 1,
      'code': 'RESTAURANT',
      'name': {'en': 'Restaurant'},
      'enabled': true,
      'features': ['restaurant'],
    }),
    ShopType.fromJson({
      'id': 2,
      'code': 'CAFE',
      'name': {'en': 'Cafe'},
      'enabled': true,
    }),
  ];

  @override
  Future<List<ShopType>> getShopTypesWithStats() async {
    if (statsFail) throw Exception('stats down');
    return [
      ShopType.fromJson({
        'id': 1,
        'code': 'RESTAURANT',
        'name': {'en': 'Restaurant'},
        'totalShops': 7,
        'activeShops': 5,
        'inactiveShops': 1,
        'suspendedShops': 1,
        'activePercentage': 71.4,
      }),
      // CAFE has no shops, so it is absent from the stats rows.
    ];
  }

  @override
  Future<ShopType> toggleShopType(int id) async => ShopType.fromJson({
    'id': id,
    'code': 'RESTAURANT',
    'name': {'en': 'Restaurant'},
    'enabled': false,
  });
}

void main() {
  test('shop counts are joined from the stats endpoint by id', () async {
    final notifier = ShopTypesNotifier(FakeShopTypesRepository());
    await notifier.loadShopTypes();

    final [restaurant, cafe] = notifier.state.shopTypes;
    expect(restaurant.usage!.total, 7);
    expect(restaurant.usage!.active, 5);
    expect(restaurant.usage!.suspended, 1);
    expect(restaurant.features, ['restaurant']);
    expect(cafe.usage!.total, 0);
    notifier.dispose();
  });

  test('a failed stats call still loads the list, counts unknown', () async {
    final notifier = ShopTypesNotifier(
      FakeShopTypesRepository(statsFail: true),
    );
    await notifier.loadShopTypes();

    expect(notifier.state.error, isNull);
    expect(notifier.state.shopTypes, hasLength(2));
    expect(notifier.state.shopTypes.every((t) => t.usage == null), isTrue);
    notifier.dispose();
  });

  test('toggling keeps the counts the toggle response lacks', () async {
    final notifier = ShopTypesNotifier(FakeShopTypesRepository());
    await notifier.loadShopTypes();
    await notifier.toggleShopType(1);

    final restaurant = notifier.state.shopTypes.first;
    expect(restaurant.enabled, isFalse);
    expect(restaurant.usage!.total, 7);
    notifier.dispose();
  });
}
