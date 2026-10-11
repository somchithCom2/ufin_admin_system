import 'package:flutter_test/flutter_test.dart';
import 'package:ufin_admin_system/core/utils/money_format.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';

void main() {
  group('MoneyFormat', () {
    test('uses the currency symbol and its till decimals', () {
      expect(MoneyFormat.format(1250000, 'LAK'), '₭ 1,250,000');
      expect(MoneyFormat.format(1200, 'THB'), '฿ 1,200.00');
      expect(MoneyFormat.format(15, 'bnd'), 'BND 15.00');
    });

    test('orders LAK first, then alphabetically, without duplicates', () {
      expect(MoneyFormat.ordered(['USD', 'LAK', 'BDT', 'LAK']), [
        'LAK',
        'BDT',
        'USD',
      ]);
    });

    test('reads per-currency maps, falling back to a LAK-only total', () {
      expect(MoneyFormat.amountsFromJson({'THB': 25, 'LAK': 1000}), {
        'LAK': 1000.0,
        'THB': 25.0,
      });
      expect(MoneyFormat.amountsFromJson(null, fallbackLak: 500), {
        'LAK': 500.0,
      });
      expect(MoneyFormat.amountsFromJson(null), isEmpty);
    });
  });

  group('Daily sales per currency', () {
    Map<String, dynamic> shop(int id, String currency, num net) => {
      'shopId': id,
      'shopName': 'Shop $id',
      'currency': currency,
      'totalOrders': 1,
      'totalNetIncome': net,
    };

    test('never adds kip and baht together', () {
      final data = DailySalesData.fromJson({
        'date': '2026-10-11',
        'totalNetIncome': null,
        'shopSales': [
          shop(1, 'THB', 300),
          shop(2, 'LAK', 500000),
          shop(3, 'LAK', 200000),
        ],
      });
      expect(data.totalNetIncome, isNull);
      expect(data.netIncomeByCurrency, {'LAK': 700000.0, 'THB': 300.0});
      expect(data.netIncomeByCurrency.keys.first, 'LAK');
      // Lao shops first, by income; the baht shop after them.
      expect(data.shopSalesInOrder.map((s) => s.shopId), [2, 3, 1]);
    });
  });

  group('Revenue report currency', () {
    test('keeps the selected currency listed even with no payments in it', () {
      final report = AdminRevenueReport.fromJson({
        'startDate': '2026-10-01',
        'endDate': '2026-10-11',
        'currency': 'USD',
        'availableCurrencies': ['THB', 'LAK'],
        'totalRevenue': 0,
      });
      expect(report.currency, 'USD');
      expect(report.availableCurrencies, ['LAK', 'THB', 'USD']);
    });
  });
}
