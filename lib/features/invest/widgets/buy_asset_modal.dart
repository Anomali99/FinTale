import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/history_dict.dart';
import '../../../core/constants/shared_dict.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/assets_model.dart';
import '../../../models/transaction_detail_model.dart';
import '../../../models/transaction_model.dart';
import '../../../models/wallet_model.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/note_container.dart';

class BuyAssetModal extends StatefulWidget {
  final List<WalletModel> wallets;
  final AssetsModel? initialAsset;
  final RiskType? initialRisk;
  final List<AssetsModel> assets;
  final bool isRpg;

  const BuyAssetModal({
    super.key,
    required this.wallets,
    required this.assets,
    this.initialAsset,
    this.initialRisk,
    this.isRpg = false,
  });

  @override
  State<BuyAssetModal> createState() => _BuyAssetModalState();
}

class _BuyAssetModalState extends State<BuyAssetModal>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  final _nameController = TextEditingController();
  final _unitNameController = TextEditingController(text: 'Unit');
  final _unitAmountController = TextEditingController();
  final _priceController = TextEditingController();
  final _totalController = TextEditingController(text: '0');

  AssetsModel? _selectedAsset;
  WalletModel? _selectedWallet;
  AssetsCategory? _selectedCategory;
  RiskType? _selectedRisk;

  bool _isNewAssetTab = true;
  bool _isHideTab = false;
  bool _isLockRisk = false;
  bool _isLockWallet = false;

  @override
  void initState() {
    super.initState();

    int initialIndex = widget.initialAsset != null ? 1 : 0;
    _isNewAssetTab = initialIndex == 0;

    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: initialIndex,
    );

    if (widget.assets.isEmpty || widget.initialAsset != null) {
      _isHideTab = true;
    }

    if (widget.wallets.length == 1) {
      _isLockWallet = true;
      _selectedWallet = widget.wallets[0];
    }

    if (widget.initialRisk != null) {
      _isLockRisk = true;
      _selectedRisk = widget.initialRisk;
    }

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _isNewAssetTab = _tabController.index == 0;
          _resetForm();
        });
      }
    });

    if (widget.initialAsset != null) {
      _selectedAsset = widget.initialAsset;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _unitNameController.dispose();
    _unitAmountController.dispose();
    _priceController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _nameController.clear();
    _unitAmountController.clear();
    _priceController.clear();
    _totalController.text = '0';
    _selectedAsset = widget.initialAsset;
    _selectedCategory = null;
    _selectedRisk = null;
  }

  void _onNumberChanged(
    TextEditingController controller,
    String value, {
    bool isDecimal = false,
  }) {
    String cleanText = isDecimal
        ? value.replaceAll(',', '.')
        : value.replaceAll('.', '');

    if (cleanText.isEmpty) {
      controller.text = '';
      _calculateTotal();
      return;
    }

    if (!isDecimal) {
      BigInt currentValue = BigInt.tryParse(cleanText) ?? BigInt.zero;
      String formattedText = currentValue.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );

      if (controller.text != formattedText) {
        controller.value = TextEditingValue(
          text: formattedText,
          selection: TextSelection.collapsed(offset: formattedText.length),
        );
      }
    }
    _calculateTotal();
  }

  void _calculateTotal() {
    try {
      String cleanUnit = _unitAmountController.text.replaceAll(',', '.');
      String cleanPrice = _priceController.text.replaceAll('.', '');

      if (cleanUnit.isEmpty || cleanPrice.isEmpty) {
        _totalController.text = '0';
        return;
      }

      Decimal unit = Decimal.parse(cleanUnit);
      BigInt price = BigInt.parse(cleanPrice);

      BigInt total = BigInt.from((unit.toDouble() * price.toDouble()).round());

      String formattedTotal = total.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );

      setState(() {
        _totalController.text = formattedTotal;
      });
    } catch (e) {
      _totalController.text = '0';
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      BigInt totalAmount = BigInt.parse(
        _totalController.text.replaceAll('.', ''),
      );
      Decimal unitInput = _unitAmountController.text.isNotEmpty
          ? Decimal.parse(_unitAmountController.text.replaceAll(',', '.'))
          : Decimal.zero;

      AssetsModel assetToReturn;
      TransactionCategory tCategory;
      String transactionTitle;

      if (_isNewAssetTab) {
        assetToReturn = AssetsModel(
          name: _nameController.text,
          type: _selectedRisk!,
          category: _selectedCategory!,
          unitName: _unitNameController.text,
          invested: totalAmount,
          value: totalAmount,
          unit: unitInput,
        );

        transactionTitle = 'Beli ${assetToReturn.name}';
        tCategory = switch (_selectedRisk!) {
          RiskType.low => TransactionCategory.lowRisk,
          RiskType.medium => TransactionCategory.mediumRisk,
          RiskType.high => TransactionCategory.highRisk,
        };
      } else {
        BigInt inputPrice = BigInt.parse(
          _priceController.text.replaceAll('.', ''),
        );
        Decimal newTotalUnit = _selectedAsset!.unit + unitInput;
        BigInt newTotalValue = BigInt.from(
          (newTotalUnit.toDouble() * inputPrice.toDouble()).round(),
        );

        assetToReturn = AssetsModel(
          id: _selectedAsset!.id,
          name: _selectedAsset!.name,
          type: _selectedAsset!.type,
          category: _selectedAsset!.category,
          unitName: _selectedAsset!.unitName,
          invested: _selectedAsset!.invested + totalAmount,
          value: newTotalValue,
          unit: newTotalUnit,
        );

        transactionTitle = 'Top-Up ${assetToReturn.name}';
        tCategory = switch (assetToReturn.type) {
          RiskType.low => TransactionCategory.lowRisk,
          RiskType.medium => TransactionCategory.mediumRisk,
          RiskType.high => TransactionCategory.highRisk,
        };
      }

      TransactionModel transaction = TransactionModel(
        type: TransactionType.expense,
        title: transactionTitle,
        amount: totalAmount,
        status: StatusType.paid,
        walletId: _selectedWallet?.id,
        assetsId: assetToReturn.id,
        detailTransaction: [
          TransactionDetailModel(
            title: '${assetToReturn.name} $unitInput ${assetToReturn.unitName}',
            amount: totalAmount,
            category: tCategory,
            flow: FlowType.expense,
          ),
        ],
        dateTimestamp: DateTime.now().millisecondsSinceEpoch,
      );

      Navigator.pop(context, {
        "asset": assetToReturn,
        "transaction": transaction,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: 24 + bottomInset,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              if (_isHideTab)
                Text(
                  _isNewAssetTab ? 'Aset Baru' : 'Tambah Modal',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )
              else
                Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.5),
                      ),
                    ),
                    labelColor: AppColors.primary,
                    labelStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    unselectedLabelColor: AppColors.textSecondary,
                    tabs: [
                      const Tab(text: 'Aset Baru'),
                      const Tab(text: 'Tambah Modal'),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              if (_isNewAssetTab) ...[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Aset',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? SharedDict.requiredTitle
                      : null,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<AssetsCategory>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                  ),
                  items: AssetsCategory.values
                      .map(
                        (cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(
                            cat.value,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val),
                  validator: (val) => val == null ? 'Pilih kategori' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<RiskType>(
                  initialValue: _selectedRisk,
                  decoration: const InputDecoration(
                    labelText: 'Tingkat Risiko',
                    border: OutlineInputBorder(),
                  ),
                  items: RiskType.values
                      .map(
                        (risk) => DropdownMenuItem(
                          value: risk,
                          child: Text(risk.name.toUpperCase()),
                        ),
                      )
                      .toList(),
                  onChanged: (val) =>
                      !_isLockRisk ? setState(() => _selectedRisk = val) : null,
                  validator: (val) => val == null ? 'Pilih risiko' : null,
                ),
                const SizedBox(height: 16),
              ] else ...[
                DropdownButtonFormField<AssetsModel>(
                  initialValue: _selectedAsset,
                  decoration: const InputDecoration(
                    labelText: 'Pilih Aset untuk Ditambah',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.assets
                      .map(
                        (a) => DropdownMenuItem(value: a, child: Text(a.name)),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (widget.initialAsset != null) return;
                    setState(() {
                      _selectedAsset = val;
                      _unitNameController.text = val?.unitName ?? 'Unit';
                    });
                  },
                  validator: (val) => val == null && !_isNewAssetTab
                      ? 'Pilih aset terlebih dahulu'
                      : null,
                ),
                const SizedBox(height: 16),
              ],

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _unitAmountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Jumlah',
                        border: OutlineInputBorder(),
                        hintText: 'Misal: 10',
                      ),
                      onChanged: (val) => _onNumberChanged(
                        _unitAmountController,
                        val,
                        isDecimal: true,
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Wajib diisi' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _unitNameController,
                      decoration: const InputDecoration(
                        labelText: 'Satuan',
                        border: OutlineInputBorder(),
                        hintText: 'Unit/Lot/Gram',
                      ),
                      readOnly: !_isNewAssetTab,
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Wajib diisi' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Harga Beli per Satuan',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                  hintText: 'Misal: 100.000',
                ),
                onChanged: (val) =>
                    _onNumberChanged(_priceController, val, isDecimal: false),
                validator: (val) => val == null || val.isEmpty
                    ? 'Harga tidak boleh kosong'
                    : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<WalletModel>(
                initialValue: _selectedWallet,
                decoration: const InputDecoration(
                  labelText: 'Dompet Sumber Dana',
                  border: OutlineInputBorder(),
                ),
                items: widget.wallets
                    .map(
                      (wallet) => DropdownMenuItem(
                        value: wallet,
                        child: Text(wallet.name),
                      ),
                    )
                    .toList(),
                onChanged: (val) => !_isLockWallet
                    ? setState(() => _selectedWallet = val)
                    : null,
                validator: (val) =>
                    val == null ? SharedDict.requiredWallet : null,
              ),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, -4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_selectedWallet != null) ...[
                      NoteContainer(
                        text: HistoryDict.generateNote(
                          _selectedWallet?.name ?? '',
                          CurrencyFormatter.convertToIdr(
                            _selectedWallet?.amount,
                          ),
                        ),
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          HistoryDict.expenseAmount,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          'Rp ${_totalController.text}',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      title: _isNewAssetTab
                          ? 'Beli Aset Baru'
                          : 'Tambah Modal Investasi',
                      color: AppColors.primary,
                      onTap: _submit,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
