import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppState extends ChangeNotifier {
  String _accountID = "";
  String _customerName = "";
  bool _isGettingBalance = false;
  bool _isLoadingHome = false;
  int _transactionsCount = 0;

  String get accountID => _accountID;

  bool get isGettingBalance => _isGettingBalance;

  bool get isLoadingHome => _isLoadingHome;

  String get customerName => _customerName;

  int get transactionsCount => _transactionsCount;

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
}

var currentAccountID = ''.obs;
