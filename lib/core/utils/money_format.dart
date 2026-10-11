import 'package:intl/intl.dart';

/// Formats an amount in its own ISO currency.
///
/// Admin reports return money per currency: a Lao shop's kip and a Thai
/// shop's baht are never added together, so every amount is shown with the
/// currency it was taken in.
abstract final class MoneyFormat {
  static const Map<String, String> _symbols = {
    'LAK': '₭',
    'THB': '฿',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'VND': '₫',
    'CNY': '¥',
    'JPY': '¥',
    'KRW': '₩',
    'INR': '₹',
    'PHP': '₱',
    'BDT': '৳',
  };

  /// Currencies priced without fractions at a till (backend V35/V92 rule).
  static const Set<String> _wholeUnits = {
    'LAK',
    'VND',
    'JPY',
    'KRW',
    'IDR',
    'KHR',
    'MMK',
    'TWD',
  };

  static final Map<String, NumberFormat> _cache = {};

  /// "₭ 1,250,000", "฿ 1,200.00", or "BND 15.00" when no symbol is known.
  static String format(num amount, String currency) {
    final code = currency.toUpperCase();
    final formatter = _cache.putIfAbsent(
      code,
      () => NumberFormat.currency(
        symbol: '${_symbols[code] ?? code} ',
        decimalDigits: _wholeUnits.contains(code) ? 0 : 2,
      ),
    );
    return formatter.format(amount);
  }

  /// A `{"LAK": 1000, "THB": 25}` JSON map as amounts per currency, LAK first.
  /// [fallbackLak] is used when the field is missing (a backend older than the
  /// per-currency reports, whose single total was LAK).
  static Map<String, double> amountsFromJson(Object? json, {num? fallbackLak}) {
    if (json is Map) {
      final amounts = {
        for (final entry in json.entries)
          entry.key as String: (entry.value as num?)?.toDouble() ?? 0,
      };
      return {for (final code in ordered(amounts.keys)) code: amounts[code]!};
    }
    return fallbackLak == null ? {} : {'LAK': fallbackLak.toDouble()};
  }

  /// Sorts currencies LAK first, then alphabetically: most shops are Lao.
  static List<String> ordered(Iterable<String> currencies) {
    final list = currencies.toSet().toList()
      ..sort((a, b) {
        if (a == b) return 0;
        if (a == 'LAK') return -1;
        if (b == 'LAK') return 1;
        return a.compareTo(b);
      });
    return list;
  }
}
