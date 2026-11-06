import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ufin_admin_system/core/icons/app_icons.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';
import 'package:ufin_admin_system/features/admin/presentation/widgets/shop_ownership_forms.dart';

// Empties a shop that was keyed in wrong - usually a test shop - so it can be
// set up again from scratch. Unlike Delete shop, nothing can be restored, so
// the form shows what will go before it can be sent.

final _count = NumberFormat('#,##0');

/// Resets [shop]'s data. Resolves to what was removed, `null` when cancelled.
Future<ShopDataReset?> showResetShopDataForm(
  BuildContext context,
  AdminShop shop,
) => showAppFormModal<ShopDataReset>(
  context,
  builder: (_) => _ResetShopDataForm(shop: shop),
);

/// Confirms a finished reset with what was removed.
Future<void> showShopDataResetResultDialog(
  BuildContext context,
  ShopDataReset result,
) => showDialog<void>(
  context: context,
  builder: (ctx) => AlertDialog(
    icon: AppIcon(AppIcons.checkCircle, color: ctx.status.success),
    title: Text(context.tr(ShopText.shopDataReset)),
    content: SizedBox(
      width: 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.isEmpty
                ? context.tr(ShopText.hadNothingToRemove(result.shopName))
                : context.tr(ShopText.isEmptyAndReadyTo(result.shopName)),
          ),
          if (!result.isEmpty) ...[
            const SizedBox(height: 12),
            _CountList(result),
          ],
        ],
      ),
    ),
    actions: [
      FilledButton(
        onPressed: () => Navigator.of(ctx).pop(),
        child: Text(context.tr(CommonText.done)),
      ),
    ],
  ),
);

/// One line per kind of record, the total, then the pictures in storage.
class _CountList extends StatelessWidget {
  final ShopDataReset reset;
  const _CountList(this.reset);

  @override
  Widget build(BuildContext context) {
    Widget line(String label, int count, {bool bold = false}) {
      final style = bold
          ? context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600)
          : context.text.bodyMedium;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Expanded(child: Text(label, style: style)),
            Text(_count.format(count), style: style),
          ],
        ),
      );
    }

    Widget note(String text) => Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(text, style: context.text.bodySmall),
    );

    final files = reset.files;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (label, count) in reset.summary) line(label, count),
        const Divider(height: 16),
        line(context.tr(ShopText.totalRecords), reset.totalRows, bold: true),
        if (files != null && files > 0)
          line(context.tr(ShopText.picturesInStorage), files),
        if (files == null)
          note(
            reset.done
                ? context.tr(ShopText.storageCouldNotBeReached)
                : context.tr(ShopText.picturesInStorageCouldNot),
          ),
        if (reset.filesFailed > 0)
          note(
            context.tr(
              ShopText.picturesCouldNotBeDeleted(
                _count.format(reset.filesFailed),
              ),
            ),
          ),
      ],
    );
  }
}

class _ResetShopDataForm extends ConsumerStatefulWidget {
  final AdminShop shop;
  const _ResetShopDataForm({required this.shop});

  @override
  ConsumerState<_ResetShopDataForm> createState() => _ResetShopDataFormState();
}

class _ResetShopDataFormState extends ConsumerState<_ResetShopDataForm> {
  final _formKey = GlobalKey<FormState>();
  final _confirmName = TextEditingController();
  final _reason = TextEditingController();
  late Future<ShopDataReset> _preview = _loadPreview();
  bool _saving = false;
  String? _error;

  Future<ShopDataReset> _loadPreview() =>
      ref.read(shopsProvider.notifier).previewShopDataReset(widget.shop.id);

  @override
  void dispose() {
    _confirmName.dispose();
    _reason.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final result = await ref
          .read(shopsProvider.notifier)
          .resetShopData(
            widget.shop.id,
            ResetShopDataRequest(
              confirmShopName: _confirmName.text.trim(),
              reason: _reason.text.trim(),
            ),
          );
      if (mounted) Navigator.of(context).pop(result);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = friendlyError(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final shop = widget.shop;
    return AppFormModal(
      formKey: _formKey,
      icon: AppIcons.reset,
      title: context.tr(ShopText.resetShopData),
      subtitle: '${shop.name} · #${shop.id}',
      submitLabel: context.tr(ShopText.resetData2),
      onSubmit: _submit,
      saving: _saving,
      error: _error,
      children: [
        FormNotice(
          context.tr(ShopText.deletesTheRecordsBelowFor),
          warning: true,
        ),
        const SizedBox(height: 20),
        FormSection(
          title: context.tr(ShopText.willBeRemoved),
          children: [
            FutureBuilder<ShopDataReset>(
              future: _preview,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const LinearProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.tr(
                            ShopText.couldNotCountTheRecords(
                              friendlyError(snapshot.error!),
                            ),
                          ),
                          style: context.text.bodySmall,
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            setState(() => _preview = _loadPreview()),
                        child: Text(context.tr(ShopText.retry)),
                      ),
                    ],
                  );
                }
                final preview = snapshot.data!;
                if (preview.otherShopsRows > 0) {
                  return FormNotice(
                    context.tr(
                      ShopText.recordsOfAnotherShopAre(
                        _count.format(preview.otherShopsRows),
                      ),
                    ),
                    warning: true,
                  );
                }
                if (preview.isEmpty) {
                  return Text(
                    context.tr(ShopText.nothingToRemoveTheShop),
                    style: context.text.bodyMedium,
                  );
                }
                return _CountList(preview);
              },
            ),
          ],
        ),
        FormSection(
          title: context.tr(ShopText.staysAsItIs),
          children: [
            Text(
              context.tr(ShopText.theShopAndItsSettings),
              style: context.text.bodyMedium,
            ),
          ],
        ),
        FormNotice(context.tr(ShopText.haveTheShopSTills)),
        const SizedBox(height: 20),
        FormSection(
          title: context.tr(CommonText.confirm),
          children: [
            confirmShopNameField(_confirmName, shop.name),
            TextFormField(
              controller: _reason,
              maxLines: 3,
              maxLength: 500,
              decoration: InputDecoration(
                labelText: context.tr(CommonText.reason),
                hintText: context.tr(ShopText.eGTestShopProducts),
                helperText: context.tr(ShopText.keptInTheShopS2),
              ),
              validator: FormValidators.required(context.tr(CommonText.reason)),
            ),
          ],
        ),
      ],
    );
  }
}
