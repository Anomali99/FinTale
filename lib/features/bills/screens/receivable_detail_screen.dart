import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/bill_controller.dart';
import '../../../controllers/settings_controller.dart';
import '../../../controllers/wallet_controller.dart';
import '../../../core/constants/screen_dict.dart';
import '../../../core/constants/ui_dict.dart';
import '../../../core/utils/enum_types.dart';
import '../../../models/receivable_model.dart';
import '../../../models/transaction_detail_model.dart';
import '../../../models/transaction_model.dart';
import '../../../widgets/custom_button.dart';
import '../widgets/pay_receivable_modal.dart';
import '../widgets/receivable_detail_card.dart';

class ReceivableDetailScreen extends StatefulWidget {
  final String borrowerName;
  final List<ReceivableModel> initialRecords;

  const ReceivableDetailScreen({
    super.key,
    required this.borrowerName,
    required this.initialRecords,
  });

  @override
  State<ReceivableDetailScreen> createState() => _ReceivableDetailScreenState();
}

class _ReceivableDetailScreenState extends State<ReceivableDetailScreen> {
  late List<ReceivableModel> _records;
  final List<TransactionModel> _transaction = [];
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _records = widget.initialRecords
        .map((e) => ReceivableModel.fromMap(e.toMap()))
        .toList();
  }

  void _openUpdateReceivableModal(
    BuildContext context, {
    required int index,
    required ReceivableModel initialReceivable,
  }) async {
    final billController = context.read<BillController>();

    final borrowerNames = billController.borrowerNames;

    final result =
        await Navigator.pushNamed(
              context,
              '/add-receivable',
              arguments: {
                "existingNames": borrowerNames,
                "initialReceivable": initialReceivable,
              },
            )
            as Map<String, dynamic>?;

    if (result != null && context.mounted) {
      ReceivableModel receivable = result['receivable'];
      setState(() {
        _records[index] = receivable;
        _hasChanges = true;
      });
    }
  }

  Future<void> _openPayReceivableModal(
    BuildContext context, {
    required int? id,
    required int index,
    required String title,
  }) async {
    final wallets = context.read<WalletController>().wallets;
    final isRpg = context.read<SettingsController>().isRpgMode;

    final result = await showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      builder: (context) => PayReceivableModal(
        wallets: wallets,
        title: '${ScreenDict.billsPayAction.get(false)} $title',
        isRpg: isRpg,
      ),
    );

    if (result != null && context.mounted) {
      Decimal amount = result['amount'];
      Decimal? fee = result['fee'];
      int? walletId = result['wallet_id'];
      int datetime = result['datetime'];

      List<TransactionDetailModel> details = [
        TransactionDetailModel(
          title: '${ScreenDict.billsPayAction.get(false)} $title',
          amount: amount,
          category: TransactionCategory.debtCollection,
          flow: FlowType.income,
        ),
      ];

      if (fee != null) {
        amount -= fee;
        details.add(
          TransactionDetailModel(
            title: 'Fee',
            amount: fee,
            category: TransactionCategory.utilities,
            flow: FlowType.expense,
          ),
        );
      }

      setState(() {
        _transaction.add(
          TransactionModel(
            type: TransactionType.income,
            title: '${widget.borrowerName} ${UiDict.menuPayDebt.get(false)}',
            amount: amount,
            status: StatusType.paid,
            walletId: walletId,
            receivableId: id,
            dateTimestamp: datetime,
            detailTransaction: details,
          ),
        );
        _records[index].addPayment(amount);
        if (_records[index].isFinished) {
          _records[index].setIntTargetDate(datetime);
        }
        _hasChanges = true;
      });
    }
  }

  void _submit() {
    Navigator.pop(context, {
      "receivables": _records,
      "transactions": _transaction,
    });
  }

  void _clear() {
    setState(() {
      _transaction.clear();

      _records = widget.initialRecords
          .map((e) => ReceivableModel.fromMap(e.toMap()))
          .toList();
      _hasChanges = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsController = context.watch<SettingsController>();
    final colorScheme = Theme.of(context).colorScheme;

    final isRpg = settingsController.isRpgMode;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(title: Text(widget.borrowerName), centerTitle: true),
      bottomNavigationBar: _hasChanges ? _buildBottomBar(isRpg) : null,
      body: ListView.builder(
        padding: const EdgeInsets.all(24.0),
        itemCount: _records.length,
        itemBuilder: (context, index) {
          final item = _records[index];

          return ReceivableDetailCard(
            data: item,
            isRpg: isRpg,
            onPay: () => _openPayReceivableModal(
              context,
              index: index,
              id: item.id,
              title: item.title,
            ),
            onEdit: () => _openUpdateReceivableModal(
              context,
              index: index,
              initialReceivable: item,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomBar(bool isRpg) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: 24 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.onPrimary.withOpacity(0.2),
            offset: const Offset(0, -4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 10.0,
        children: [
          Flexible(
            child: CustomButton(
              title: UiDict.saveChanges,
              color: colorScheme.primary,
              onTap: _submit,
            ),
          ),
          CustomButton(
            title: UiDict.cancel,
            color: colorScheme.error,
            onTap: _clear,
          ),
        ],
      ),
    );
  }
}
