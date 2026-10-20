import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../controllers/settings_controller.dart';
import '../../../controllers/wallet_controller.dart';
import '../../../core/constants/screen_dict.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../core/utils/enum_types.dart';
import '../../../core/utils/number_utils.dart';
import '../../../models/wallet_model.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_table.dart';

/// Modal for create/edit wallet/pocket.
///
/// Four modes:
///   1. Create new (from wallet details) — both tabs visible, nothing locked.
///   2. Edit parent — tabs hidden, initial-amount hidden, can change name/type/savings/emergency.
///      Changing type cascades to children.
///   3. Create pocket (tambah kantong) — tabs hidden, parentId locked to [parentIdForPocket],
///      user fills name, initial amount, savings/emergency.
///   4. Edit pocket — tabs hidden, parentId locked, initial-amount hidden,
///      can change name/savings/emergency.
class WalletModal extends StatefulWidget {
  final WalletModel? wallet;
  final bool lock;

  /// Non-null when creating a pocket from WalletInfoModal.
  /// Forces tab=kantong and locks parent to this id.
  final int? parentIdForPocket;

  const WalletModal({
    super.key,
    this.wallet,
    this.lock = false,
    this.parentIdForPocket,
  });

  @override
  State<WalletModal> createState() => _WalletModalState();
}

class _WalletModalState extends State<WalletModal>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  TabController? _tabController;

  late WalletType _selectedType;
  int? _selectedParentId;
  late bool _isSavings;
  late bool _isEmergency;
  int _tabIndex = 0;

  bool get _isEditing => widget.wallet != null;

  /// True when creating a new pocket via the "Tambah Kantong" button.
  bool get _isCreatingPocket => !_isEditing && widget.parentIdForPocket != null;

  /// True when we should show the tab bar (only fresh create, no parentIdForPocket).
  bool get _showTabs => !_isEditing && !_isCreatingPocket;

  /// True when the initial-amount field should be visible (only on create, not edit).
  bool get _showInitialAmount => !_isEditing;

  @override
  void initState() {
    super.initState();

    final wallet = widget.wallet;

    // Determine initial tab index.
    if (_isCreatingPocket) {
      // Create pocket mode: force kantong tab.
      _tabIndex = 1;
      _selectedParentId = widget.parentIdForPocket;
    } else if (wallet != null && wallet.isPocket) {
      // Edit pocket mode.
      _tabIndex = 1;
      _selectedParentId = wallet.parentId;
    }

    _nameController.text = wallet?.name ?? '';
    _selectedType = wallet?.type ?? WalletType.bank;
    _isSavings = wallet?.isSavings ?? false;
    _isEmergency = wallet?.isEmergency ?? false;
    NumberUtils.formatInput(
      _amountController,
      wallet?.amount.toString() ?? '0',
    );

    // Only build tab controller when tabs are visible.
    if (_showTabs) {
      _tabController = TabController(
        length: 2,
        vsync: this,
        initialIndex: _tabIndex,
      );
      _tabController!.addListener(() {
        if (_tabController!.indexIsChanging) {
          setState(() {
            _tabIndex = _tabController!.index;
            if (_tabIndex == 0) {
              _selectedParentId = null;
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final bool isPocket = _tabIndex == 1;
      final WalletType type;

      if (isPocket && _selectedParentId != null) {
        final walletController = context.read<WalletController>();
        final parent = walletController.getWalletById(_selectedParentId);
        type = parent.type;
      } else {
        type = _selectedType;
      }

      final result = WalletModel(
        id: widget.wallet?.id,
        name: _nameController.text.trim(),
        type: type,
        amount:
            widget.wallet?.amount ??
            NumberUtils.parseToDecimal(_amountController.text),
        parentId: isPocket ? _selectedParentId : null,
        isSavings: _isSavings,
        isEmergency: _isEmergency,
      );

      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isRpg = context.read<SettingsController>().isRpgMode;
    final colorScheme = Theme.of(context).colorScheme;
    final walletController = context.read<WalletController>();
    final parentWallets = walletController.wallets
        .where((w) => w.isParent)
        .toList();

    // Whether it's a pocket (either editing a pocket or creating one).
    final bool isPocketMode = _tabIndex == 1;
    // Whether the parent dropdown should be locked.
    final bool lockParent = _isEditing || _isCreatingPocket;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: 24 + bottomInset,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                _buildTitle(isRpg),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Tab bar — only for fresh create (mode 1)
              if (_showTabs) ...[
                Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.5),
                      ),
                    ),
                    labelColor: colorScheme.primary,
                    labelStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    unselectedLabelColor: colorScheme.onSurfaceVariant,
                    tabs: const [
                      Tab(text: 'Dompet'),
                      Tab(text: 'Kantong'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Parent wallet dropdown — only when in pocket mode
              if (isPocketMode) ...[
                DropdownButtonFormField<int>(
                  initialValue: _selectedParentId,
                  decoration: InputDecoration(
                    labelText: 'Dompet Induk',
                    border: OutlineInputBorder(),
                  ),
                  items: parentWallets
                      .map(
                        (w) =>
                            DropdownMenuItem(value: w.id, child: Text(w.name)),
                      )
                      .toList(),
                  onChanged: lockParent
                      ? null
                      : (val) => setState(() => _selectedParentId = val),
                  validator: (val) => val == null ? 'Pilih dompet induk' : null,
                ),

                const SizedBox(height: 16),
              ],

              // Name field — always visible
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: isPocketMode
                      ? 'Nama Kantong'
                      : ScreenDict.walletName,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? UiDict.requiredName : null,
              ),

              // Wallet type dropdown — only for parent mode (tab 0)
              if (!isPocketMode) ...[
                const SizedBox(height: 16),

                DropdownButtonFormField<WalletType>(
                  initialValue: _selectedType,
                  decoration: InputDecoration(
                    labelText: ScreenDict.walletType,
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    if (widget.lock)
                      DropdownMenuItem(
                        value: WalletType.cash,
                        child: Text('Cash'),
                      ),
                    DropdownMenuItem(
                      value: WalletType.bank,
                      child: Text('Bank'),
                    ),
                    DropdownMenuItem(
                      value: WalletType.eWallet,
                      child: Text('e-Wallet'),
                    ),
                    DropdownMenuItem(
                      value: WalletType.platform,
                      child: Text('Platform (RDN)'),
                    ),
                  ],
                  onChanged: !widget.lock
                      ? (val) => setState(() => _selectedType = val!)
                      : null,
                  validator: (val) => val == null ? 'Pilih jenis dompet' : null,
                ),
              ],
              // Initial amount — only when creating (not editing)
              if (_showInitialAmount) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: UiDict.initialAmount,
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) =>
                      NumberUtils.formatInput(_amountController, val),
                ),
              ],

              // isSavings switch
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Tabungan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Tandai sebagai tabungan',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                value: _isSavings,
                onChanged: (val) {
                  setState(() {
                    _isSavings = val;
                    if (!val) _isEmergency = false;
                  });
                },
              ),

              // isEmergency switch — only enabled when isSavings is true
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Dana Darurat',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Tandai sebagai dana darurat',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                value: _isEmergency,
                onChanged: _isSavings
                    ? (val) => setState(() => _isEmergency = val)
                    : null,
              ),

              // Balance info table — only when editing
              if (_isEditing) ...[
                const SizedBox(height: 24),
                _buildBalanceTable(colorScheme, walletController),
              ],

              if (!widget.lock) ...[
                const SizedBox(height: 24),
                CustomButton(
                  title: _isEditing ? UiDict.saveChanges : UiDict.addNew,
                  color: colorScheme.primary,
                  onTap: _submit,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceTable(
    ColorScheme colorScheme,
    WalletController walletController,
  ) {
    final wallet = widget.wallet!;
    final walletId = wallet.id ?? 0;
    final walletPockets = walletController.getPocketsForWallet(walletId);
    final hasPockets = walletPockets.isNotEmpty;
    final int? decimalDigits = wallet.type != WalletType.platform ? null : 3;

    return CustomTable(
      color: colorScheme.surfaceContainerHighest,
      borderColor: colorScheme.primary,
      children: [
        CustomRowTable(
          label: 'Saldo',
          value: NumberUtils.toIdr(wallet.amount, decimalDigits: decimalDigits),
          valueColor: colorScheme.onSurface,
          boldValue: true,
        ),
        if (hasPockets) ...[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(
              color: colorScheme.onSurface.withValues(alpha: 0.1),
              height: 1,
            ),
          ),
          CustomRowTable(
            label: 'Total (termasuk kantong)',
            value: NumberUtils.toIdr(
              walletController.getParentTotalBalance(walletId),
              decimalDigits: decimalDigits,
            ),
            valueColor: colorScheme.onSurface,
            boldValue: true,
          ),
          for (WalletModel pocket in walletPockets) ...[
            const SizedBox(height: 12),
            CustomRowTable(
              label: pocket.name,
              value: NumberUtils.toIdr(
                pocket.amount,
                decimalDigits: decimalDigits,
              ),
            ),
          ],
        ],
      ],
    );
  }

  String _buildTitle(bool isRpg) {
    return _isEditing
        ? ScreenDict.updateWallet.get(isRpg)
        : ScreenDict.addWallet.get(isRpg);
  }
}
