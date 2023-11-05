import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppState extends ChangeNotifier {
  String _accountID = "";
  String _customerName = "";
  bool _isGettingBalance = false;
  bool _isLoadingHome = false;
  int _transactionsCount = 0;
  String _trxAccountID = "";

  String get accountID => _accountID;

  bool get isGettingBalance => _isGettingBalance;

  bool get isLoadingHome => _isLoadingHome;

  String get customerName => _customerName;

  int get transactionsCount => _transactionsCount;

  String get trxAccountID => _trxAccountID;

  void setCurrentAccountID(String accountID) {
    _accountID = accountID;
    notifyListeners();
  }

  void setGettingBalance(bool status) {
    _isGettingBalance = status;
    notifyListeners();
  }

  void setIsLoadingHome(bool status) {
    _isLoadingHome = status;
    notifyListeners();
  }

  void setCustomerName(String customerName) {
    _customerName = customerName;
    notifyListeners();
  }

  void setTransactionsCount(int count) {
    _transactionsCount = count;
    notifyListeners();
  }

  void setTrxAccountID(String accID) {
    _trxAccountID = accID;
    notifyListeners();
  }
}

var currentAccountID = ''.obs;
