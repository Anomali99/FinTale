import 'package:flutter/material.dart';

import '../data/local/dao/transaction_dao.dart';
import '../models/transaction_model.dart';

class TransactionController extends ChangeNotifier with WidgetsBindingObserver {
  final TransactionDao _transactionDao;

  TransactionController(this._transactionDao);

  Future<void> createTransaction(TransactionModel transaction) =>
      _transactionDao.create(transaction);
}
