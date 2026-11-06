import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ufin_admin_system/core/icons/app_icons.dart';
import 'package:ufin_admin_system/core/widgets/widgets.dart';
import 'package:ufin_admin_system/features/admin/data/models/models.dart';
import 'package:ufin_admin_system/features/admin/presentation/providers/dashboard_provider.dart';
import 'package:ufin_admin_system/features/admin/presentation/widgets/shop_picker.dart';
import 'package:ufin_admin_system/features/admin/presentation/widgets/user_picker.dart';

// Support tools for branch groups and shop ownership. Every action here moves
// a whole business, so each one asks for the shop's name typed back and a
// reason, which the backend records in the shop's owner history.

/// Links [shop] under another shop as a branch. Resolves to the result when
/// done, `null` when cancelled.
Future<ShopOwnershipResult?> showLinkBranchForm(
  BuildContext context,
  AdminShop shop,
) => showAppFormModal<ShopOwnershipResult>(
  context,
  builder: (_) => _LinkBranchForm(shop: shop),
);

/// Turns branch [shop] back into a top-level shop.
Future<ShopOwnershipResult?> showUnlinkBranchForm(
  BuildContext context,
  AdminShop shop,
) => showAppFormModal<ShopOwnershipResult>(
  context,
  builder: (_) => _UnlinkBranchForm(shop: shop),
);

/// Hands top-level [shop] to another account.
Future<ShopOwnershipResult?> showChangeOwnerForm(
  BuildContext context,
  AdminShop shop,
) => showAppFormModal<ShopOwnershipResult>(
  context,
  builder: (_) => _ChangeOwnerForm(shop: shop),
);

/// The shop's name typed back, so a mistyped id moves nothing. Exact after
/// trimming, as the backend checks it. Also used by the data reset form.
TextFormField confirmShopNameField(
  TextEditingController controller,
  String name,
) => TextFormField(
  controller: controller,
  decoration: InputDecoration(
    labelText: ShopText.typeTheShopNameTo.current,
    hintText: name,
    helperText: ShopText.exactly(name).current,
  ),
  validator: (v) {
    final typed = v?.trim() ?? '';
    if (typed.isEmpty) return ShopText.typeTheShopName.current;
    if (typed != name.trim()) return ShopText.doesNotMatch(name).current;
    return null;
  },
);

TextFormField _reasonField(TextEditingController controller, String hint) =>
    TextFormField(
      controller: controller,
      maxLines: 3,
      maxLength: 500,
      decoration: InputDecoration(
        labelText: CommonText.reason.current,
        hintText: hint,
        helperText: ShopText.keptInTheShopS.current,
      ),
      validator: FormValidators.required(CommonText.reason.current),
    );

/// A short paragraph explaining what the action does.
class FormNotice extends StatelessWidget {
  final String text;
  final bool warning;
  const FormNotice(this.text, {super.key, this.warning = false});

  @override
  Widget build(BuildContext context) {
    final color = warning ? context.status.warning : context.status.info;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIcon(
            warning ? AppIcons.warning : AppIcons.info,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: context.text.bodySmall)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Link
// ---------------------------------------------------------------------------

class _LinkBranchForm extends ConsumerStatefulWidget {
  final AdminShop shop;
  const _LinkBranchForm({required this.shop});

  @override
  ConsumerState<_LinkBranchForm> createState() => _LinkBranchFormState();
}

class _LinkBranchFormState extends ConsumerState<_LinkBranchForm> {
  final _formKey = GlobalKey<FormState>();
  final _confirmName = TextEditingController();
  final _reason = TextEditingController();
  ShopSelection? _parent;
  bool _transferOwnership = false;
  bool _revokePreviousOwner = false;
  bool _ignorePlanCheck = false;
  bool _saving = false;
  String? _error;

  /// Owners are compared by username: the picker knows the parent's owner by
  /// name only. The backend compares ids and refuses a mismatch it was not
  /// told about, so a wrong guess here costs a refusal, not a wrong move.
  bool get _ownersDiffer =>
      _parent != null && _parent!.owner != widget.shop.ownerUsername;

  @override
  void dispose() {
    _confirmName.dispose();
    _reason.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) return;
    if (_ownersDiffer && !_transferOwnership) {
      setState(() => _error = context.tr(ShopText.theMainShopHasAnother));
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final result = await ref
          .read(shopsProvider.notifier)
          .linkAsBranch(
            widget.shop.id,
            LinkBranchRequest(
              parentShopId: _parent!.id,
              transferOwnership: _ownersDiffer && _transferOwnership,
              revokePreviousOwnerAccess:
                  _ownersDiffer && _transferOwnership && _revokePreviousOwner,
              ignorePlanCheck: _ignorePlanCheck,
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
      icon: AppIcons.network,
      title: context.tr(ShopText.linkAsBranch2),
      subtitle: '${shop.name} · #${shop.id}',
      submitLabel: context.tr(ShopText.linkAsBranch2),
      onSubmit: _submit,
      saving: _saving,
      error: _error,
      children: [
        FormNotice(context.tr(ShopText.forACustomerWhoOpened)),
        const SizedBox(height: 20),
        FormSection(
          title: context.tr(ShopText.mainShop),
          hint: context.tr(ShopText.theShopThatHoldsThe),
          children: [
            ShopPickerField(
              label: context.tr(ShopText.mainShop),
              validator: (v) {
                if (v == null) {
                  return context.tr(ShopText.pleaseSelectTheMainShop);
                }
                if (v.id == shop.id) {
                  return context.tr(ShopText.chooseADifferentShop);
                }
                return null;
              },
              onChanged: (v) => setState(() {
                _parent = v;
                _error = null;
              }),
            ),
            if (_ownersDiffer) ...[
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _transferOwnership,
                onChanged: (v) => setState(() => _transferOwnership = v),
                title: Text(context.tr(ShopText.moveToTheMainShop)),
                subtitle: Text(
                  context.tr(
                    ShopText.ownedByNowItWill(
                      shop.ownerUsername ?? 'another account',
                      _parent!.owner ?? 'the main shop\'s owner',
                    ),
                  ),
                ),
              ),
              if (_transferOwnership)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _revokePreviousOwner,
                  onChanged: (v) => setState(() => _revokePreviousOwner = v),
                  title: Text(context.tr(ShopText.switchOffThePreviousOwner)),
                  subtitle: Text(context.tr(ShopText.offByDefaultTillsMay)),
                ),
            ],
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _ignorePlanCheck,
              onChanged: (v) => setState(() => _ignorePlanCheck = v),
              title: Text(context.tr(ShopText.linkEvenIfThePlan)),
              subtitle: Text(context.tr(ShopText.onlyForADealAgreed)),
            ),
          ],
        ),
        FormSection(
          title: context.tr(CommonText.confirm),
          children: [
            confirmShopNameField(_confirmName, shop.name),
            _reasonField(_reason, context.tr(ShopText.eGOwnerAskedTo)),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Unlink
// ---------------------------------------------------------------------------

class _UnlinkBranchForm extends ConsumerStatefulWidget {
  final AdminShop shop;
  const _UnlinkBranchForm({required this.shop});

  @override
  ConsumerState<_UnlinkBranchForm> createState() => _UnlinkBranchFormState();
}

class _UnlinkBranchFormState extends ConsumerState<_UnlinkBranchForm> {
  final _formKey = GlobalKey<FormState>();
  final _confirmName = TextEditingController();
  final _reason = TextEditingController();
  UserSelection? _newOwner;
  bool _revokePreviousOwner = true;
  bool _saving = false;
  String? _error;

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
          .unlinkBranch(
            widget.shop.id,
            UnlinkBranchRequest(
              ownerUserId: _newOwner?.id,
              revokePreviousOwnerAccess: _revokePreviousOwner,
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
      icon: AppIcons.split,
      title: context.tr(ShopText.unlinkFromBranchGroup),
      subtitle: context.tr(
        ShopText.branchOf3(
          shop.name,
          shop.parentShopName ?? '#${shop.parentShopId}',
        ),
      ),
      submitLabel: context.tr(ShopText.unlink),
      onSubmit: _submit,
      saving: _saving,
      error: _error,
      children: [
        FormNotice(context.tr(ShopText.theShopBecomesASeparate), warning: true),
        const SizedBox(height: 20),
        FormSection(
          title: context.tr(CommonText.owner),
          hint: context.tr(ShopText.leaveEmptyToKeepIt),
          children: [
            UserPickerField(
              label: context.tr(ShopText.handToAnotherAccountOptional),
              required: false,
              excludeIds: {?shop.ownerId},
              onChanged: (v) => setState(() => _newOwner = v),
            ),
            if (_newOwner != null)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _revokePreviousOwner,
                onChanged: (v) => setState(() => _revokePreviousOwner = v),
                title: Text(context.tr(ShopText.switchOffTheGroupOwner)),
                subtitle: Text(context.tr(ShopText.onByDefaultOnceHanded)),
              ),
          ],
        ),
        FormSection(
          title: context.tr(CommonText.confirm),
          children: [
            confirmShopNameField(_confirmName, shop.name),
            _reasonField(_reason, context.tr(ShopText.eGBranchSoldTo)),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Change owner
// ---------------------------------------------------------------------------

class _ChangeOwnerForm extends ConsumerStatefulWidget {
  final AdminShop shop;
  const _ChangeOwnerForm({required this.shop});

  @override
  ConsumerState<_ChangeOwnerForm> createState() => _ChangeOwnerFormState();
}

class _ChangeOwnerFormState extends ConsumerState<_ChangeOwnerForm> {
  final _formKey = GlobalKey<FormState>();
  final _confirmName = TextEditingController();
  final _reason = TextEditingController();
  UserSelection? _newOwner;
  bool _revokePreviousOwner = true;
  bool _saving = false;
  String? _error;

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
          .changeOwner(
            widget.shop.id,
            ChangeOwnerRequest(
              newOwnerUserId: _newOwner!.id,
              revokePreviousOwnerAccess: _revokePreviousOwner,
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
      icon: AppIcons.swap,
      title: context.tr(ShopText.changeOwner2),
      subtitle: context.tr(
        ShopText.ownedBy(shop.name, shop.ownerUsername ?? '#${shop.ownerId}'),
      ),
      submitLabel: context.tr(ShopText.changeOwner2),
      onSubmit: _submit,
      saving: _saving,
      error: _error,
      children: [
        FormNotice(context.tr(ShopText.handsTheShopToAnother), warning: true),
        const SizedBox(height: 20),
        FormSection(
          title: context.tr(ShopText.newOwner),
          children: [
            UserPickerField(
              label: context.tr(ShopText.newOwner),
              excludeIds: {?shop.ownerId},
              onChanged: (v) => setState(() => _newOwner = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _revokePreviousOwner,
              onChanged: (v) => setState(() => _revokePreviousOwner = v),
              title: Text(context.tr(ShopText.switchOffThePreviousOwner)),
              subtitle: Text(context.tr(ShopText.onByDefaultSignsThem)),
            ),
          ],
        ),
        FormSection(
          title: context.tr(CommonText.confirm),
          children: [
            confirmShopNameField(_confirmName, shop.name),
            _reasonField(_reason, context.tr(ShopText.eGShopSoldId)),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// After a change: staff to review
// ---------------------------------------------------------------------------

/// Tells the admin what happened and who to look at: staff still active in
/// the shop who are the previous owner or also work for them elsewhere.
Future<void> showOwnershipResultDialog(
  BuildContext context, {
  required String title,
  required ShopOwnershipResult result,
}) {
  final staff = result.staffToReview;
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: AppIcon(AppIcons.checkCircle, color: ctx.status.success),
      title: Text(title),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.shop.isBranch
                  ? context.tr(
                      ShopText.isOwnedByAsA(
                        result.shop.name,
                        result.shop.ownerUsername ?? '#${result.shop.ownerId}',
                        result.shop.parentShopName ??
                            '#${result.shop.parentShopId}',
                      ),
                    )
                  : context.tr(
                      ShopText.isOwnedBy(
                        result.shop.name,
                        result.shop.ownerUsername ?? '#${result.shop.ownerId}',
                      ),
                    ),
            ),
            if (staff.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                context.tr(ShopText.staffToReview),
                style: ctx.text.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                context.tr(ShopText.stillActiveHereAndTied),
                style: ctx.text.bodySmall,
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 260),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final person in staff)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: AppIcon(
                          person.previousOwner ? AppIcons.key : AppIcons.person,
                        ),
                        title: Text(person.displayName),
                        subtitle: Text(
                          [
                            person.username,
                            if (person.roleName != null) person.roleName!,
                            if (person.previousOwner)
                              context.tr(ShopText.previousOwner),
                          ].join(' · '),
                        ),
                      ),
                  ],
                ),
              ),
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
}

// ---------------------------------------------------------------------------
// Branches and owner history
// ---------------------------------------------------------------------------

Future<void> _showSheet(BuildContext context, Widget child) {
  final wide = MediaQuery.sizeOf(context).width >= AppSpacing.tabletBreakpoint;
  if (wide) {
    return showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
          child: child,
        ),
      ),
    );
  }
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => FractionallySizedBox(heightFactor: 0.8, child: child),
  );
}

/// The shop's branches, deleted ones included.
Future<void> showBranchesSheet(BuildContext context, AdminShop shop) =>
    _showSheet(context, _BranchesSheet(shop: shop));

/// Every owner change made from the admin console.
Future<void> showOwnerHistorySheet(BuildContext context, AdminShop shop) =>
    _showSheet(context, _OwnerHistorySheet(shop: shop));

class _SheetScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget body;
  const _SheetScaffold({
    required this.title,
    required this.subtitle,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: context.text.titleLarge),
                      Text(
                        subtitle,
                        style: context.text.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: context.tr(CommonText.close),
                  icon: const AppIcon(AppIcons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class _BranchesSheet extends ConsumerStatefulWidget {
  final AdminShop shop;
  const _BranchesSheet({required this.shop});

  @override
  ConsumerState<_BranchesSheet> createState() => _BranchesSheetState();
}

class _BranchesSheetState extends ConsumerState<_BranchesSheet> {
  late Future<List<AdminShop>> _branches = _load();

  Future<List<AdminShop>> _load() =>
      ref.read(adminRepositoryProvider).getBranches(widget.shop.id);

  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      title: context.tr(ShopText.branches2),
      subtitle: '${widget.shop.name} · #${widget.shop.id}',
      body: FutureBuilder<List<AdminShop>>(
        future: _branches,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const AppLoadingView();
          }
          if (snapshot.hasError) {
            return AppErrorView(
              error: snapshot.error,
              title: context.tr(ShopText.couldnTLoadBranches),
              onRetry: () => setState(() => _branches = _load()),
            );
          }
          final branches = snapshot.data!;
          if (branches.isEmpty) {
            return AppEmptyView(
              icon: AppIcons.network,
              title: context.tr(ShopText.noBranches),
              message: context.tr(ShopText.linkAnExistingShopWith),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: branches.length,
            separatorBuilder: (_, _) => const Divider(indent: 72),
            itemBuilder: (context, i) {
              final branch = branches[i];
              final status = branch.isDeleted ? 'deleted' : branch.status;
              return ListTile(
                leading: IconBadge(
                  icon: AppIcons.shop,
                  color: StatusTone.fromStatus(status).foreground(context),
                  size: 40,
                ),
                title: Text(
                  branch.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  [
                    '#${branch.id}',
                    if (branch.ownerUsername != null) branch.ownerUsername!,
                    context.tr(ShopText.staff(branch.employeeCount)),
                    context.tr(ShopText.products2(branch.productCount)),
                  ].join(' · '),
                ),
                trailing: StatusBadge.fromStatus(status),
              );
            },
          );
        },
      ),
    );
  }
}

class _OwnerHistorySheet extends ConsumerStatefulWidget {
  final AdminShop shop;
  const _OwnerHistorySheet({required this.shop});

  @override
  ConsumerState<_OwnerHistorySheet> createState() => _OwnerHistorySheetState();
}

class _OwnerHistorySheetState extends ConsumerState<_OwnerHistorySheet> {
  late Future<(List<OwnerChange>, Map<int, String>)> _history = _load();

  /// The history carries account ids; looks each one up once for its
  /// username, falling back to the id when the lookup fails.
  Future<(List<OwnerChange>, Map<int, String>)> _load() async {
    final repository = ref.read(adminRepositoryProvider);
    final changes = await repository.getOwnerHistory(widget.shop.id);
    final ids = {
      for (final c in changes) ...[
        ?c.fromOwnerId,
        ?c.toOwnerId,
        ?c.performedById,
      ],
    };
    final names = <int, String>{};
    await Future.wait(
      ids.map((id) async {
        try {
          names[id] = (await repository.getUserById(id)).username;
        } catch (_) {
          // Shown as #id instead.
        }
      }),
    );
    return (changes, names);
  }

  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      title: context.tr(ShopText.ownerHistory2),
      subtitle: '${widget.shop.name} · #${widget.shop.id}',
      body: FutureBuilder<(List<OwnerChange>, Map<int, String>)>(
        future: _history,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const AppLoadingView();
          }
          if (snapshot.hasError) {
            return AppErrorView(
              error: snapshot.error,
              title: context.tr(ShopText.couldnTLoadOwnerHistory),
              onRetry: () => setState(() => _history = _load()),
            );
          }
          final (changes, names) = snapshot.data!;
          String who(int? id) => id == null ? '—' : names[id] ?? '#$id';
          if (changes.isEmpty) {
            return AppEmptyView(
              icon: AppIcons.history,
              title: context.tr(ShopText.noOwnerChanges),
              message: context.tr(ShopText.thisShopHasKeptThe),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: changes.length,
            separatorBuilder: (_, _) => const Divider(indent: 16),
            itemBuilder: (context, i) {
              final change = changes[i];
              return ListTile(
                isThreeLine: true,
                title: Text(
                  '${who(change.fromOwnerId)} → ${who(change.toOwnerId)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  [
                    change.sourceLabel,
                    if (change.createdAt != null)
                      change.createdAt!.toLocal().toString().split('.')[0],
                    context.tr(ShopText.by(who(change.performedById))),
                    if ((change.reason ?? '').isNotEmpty) '"${change.reason}"',
                  ].join(' · '),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
