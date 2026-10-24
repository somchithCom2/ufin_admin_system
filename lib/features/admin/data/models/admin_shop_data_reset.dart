/// Empties a shop's catalog, sales, stock and customers so it can be keyed in
/// again (POST /admin/shops/{id}/data-reset). Settings, staff, payment
/// methods, tables and the subscription stay.
class ResetShopDataRequest {
  final String confirmShopName;
  final String reason;

  const ResetShopDataRequest({
    required this.confirmShopName,
    required this.reason,
  });

  Map<String, dynamic> toJson() => {
    'confirmShopName': confirmShopName,
    'reason': reason,
  };
}

/// What a reset would remove (preview, `done` false) or removed, by table.
class ShopDataReset {
  final int shopId;
  final String shopName;
  final bool done;

  /// Rows per database table, in the order the backend deletes them.
  final Map<String, int> rows;
  final int totalRows;

  /// Product pictures and category icons in storage: to be removed (preview)
  /// or removed. Null when the backend could not reach storage. A picture a
  /// branch still shows from a catalog copy is kept and not counted.
  final int? files;

  /// Pictures a reset could not remove. Nothing shows them any more.
  final int filesFailed;

  /// Preview only: rows of other shops tied to this shop's data. Above zero
  /// the backend refuses the reset rather than touch another shop.
  final int otherShopsRows;

  const ShopDataReset({
    required this.shopId,
    required this.shopName,
    required this.done,
    required this.rows,
    required this.totalRows,
    this.files,
    this.filesFailed = 0,
    this.otherShopsRows = 0,
  });

  /// Nothing in the database or in storage to remove.
  bool get isEmpty => totalRows == 0 && (files ?? 0) == 0;

  factory ShopDataReset.fromJson(Map<String, dynamic> json) => ShopDataReset(
    shopId: json['shopId'] as int,
    shopName: json['shopName'] as String? ?? '',
    done: json['done'] as bool? ?? false,
    rows: (json['rows'] as Map<String, dynamic>? ?? const {}).map(
      (table, count) => MapEntry(table, (count as num).toInt()),
    ),
    totalRows: (json['totalRows'] as num?)?.toInt() ?? 0,
    files: (json['files'] as num?)?.toInt(),
    filesFailed: (json['filesFailed'] as num?)?.toInt() ?? 0,
    otherShopsRows: (json['otherShopsRows'] as num?)?.toInt() ?? 0,
  );

  /// The tables an operator recognises, by the name the shop app gives them.
  /// Everything else is a line, payment or link belonging to one of these.
  static const _labels = {
    'categories': 'Categories',
    'products': 'Products',
    'product_variants': 'Variants',
    'transactions': 'Orders',
    'customers': 'Customers',
    'debts': 'Debts',
    'inventory_movements': 'Stock movements',
    'product_batches': 'Stock batches',
    'purchase_orders': 'Purchase orders',
    'expenses': 'Expenses',
    'suppliers': 'Suppliers',
    'discounts': 'Discounts',
  };

  /// Non-empty named counts, then one line for the rest. Empty when there is
  /// nothing to remove.
  List<(String, int)> get summary {
    final lines = <(String, int)>[
      for (final MapEntry(key: table, value: label) in _labels.entries)
        if ((rows[table] ?? 0) > 0) (label, rows[table]!),
    ];
    final other = rows.entries
        .where((e) => !_labels.containsKey(e.key))
        .fold<int>(0, (sum, e) => sum + e.value);
    if (other > 0) lines.add(('Linked records', other));
    return lines;
  }
}
