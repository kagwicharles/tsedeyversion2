import 'package:carousel_slider/carousel_slider.dart';
import 'package:craft_dynamic/craft_dynamic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:tsedeybnk/src/appstate/app_state.dart';
import 'package:tsedeybnk/src/ui/home/all_transactions_screen.dart';

import 'transaction_details_screen.dart';

class RecentsTab extends StatefulWidget {
  const RecentsTab({super.key});

  @override
  State<RecentsTab> createState() => _RecentsTabState();
}

class _RecentsTabState extends State<RecentsTab> {
  final _profileRepo = ProfileRepository();
  List<BankAccount> userAccounts = [];
  List<Transaction> transactionList = [];
  bool isLoading = false;

  String _currentValue = "";

  @override
  void initState() {
    super.initState();
    getBankAccounts();
  }

  Future<DynamicResponse?> _checkMiniStatement(String accountID) async {
    return await _profileRepo.checkMiniStatement(accountID,
        merchantID: "STATEMENT");
  }

  getBankAccounts() async {
    var accounts = await _profileRepo.getUserBankAccounts();
    userAccounts = accounts;
    _currentValue = userAccounts[0].bankAccountId;
    setState(() {});
  }

  void setAccountID(String accountID) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppState>(context, listen: false).setTrxAccountID(accountID);
    });
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(
            height: 12,
          ),
          DropdownButtonFormField(
            value: _currentValue,
            items: userAccounts
                .asMap()
                .entries
                .map((item) {
                  return DropdownMenuItem(
                    value: item.value.bankAccountId,
                    child: Text(
                      item.value.aliasName.isEmpty
                          ? item.value.bankAccountId
                          : item.value.aliasName,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  );
                })
                .toList()
                .toSet()
                .toList(),
            decoration: const InputDecoration(
                label: Text("Select Account"),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 16, horizontal: 14)),
            onChanged: (value) {
              setState(() {
                _currentValue = value.toString();
              });
            },
          ),
          const SizedBox(
            height: 12,
          ),
          const StatementHeader(),
          _currentValue.isEmpty
              ? const SizedBox()
              : FutureBuilder<DynamicResponse?>(
                  future: _checkMiniStatement(
                      _currentValue), // a previously-obtained Future<String> or null
                  builder: (BuildContext context,
                      AsyncSnapshot<DynamicResponse?> snapshot) {
                    var color = Theme.of(context).primaryColor;

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularLoadUtil());
                    }

                    Widget child = Center(child: LoadUtil());
                    if (snapshot.hasData) {
                      var ministatement = snapshot.data?.accountStatement;

                      if (snapshot.data?.status !=
                          StatusCode.success.statusCode) {
                        CommonUtils.showToast(snapshot.data?.message ??
                            "Ministatement request failed");
                        return _buildRetryButton();
                      }

                      if (ministatement == null) {
                        return _buildRetryButton();
                      } else if (ministatement.isEmpty) {
                        CommonUtils.showToast("No transactions yet");
                        return const EmptyUtil();
                      }

                      addTransactions(list: ministatement);

                      child = Column(children: [
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: transactionList.length > 2 ? 2 : 0,
                          itemBuilder: (BuildContext context, index) {
                            Transaction? trx = transactionList[index];
                            var date = transactionList[index].date ?? "";
                            var type =
                                transactionList[index].transactionType ?? "";
                            var amount = transactionList[index].amount ?? "";

                            bool isCredit = transactionList[index]
                                    .type
                                    ?.toLowerCase()
                                    .contains("credit") ??
                                false;

                            return Card(
                                elevation: 0,
                                child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      context.navigate(TransactionDetailsScreen(
                                        transactionlist: ministatement[index],
                                      ));
                                    },
                                    child: Container(
                                        padding: const EdgeInsets.all(8),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                                flex: 2,
                                                child: Container(
                                                    padding:
                                                        const EdgeInsets.all(2),
                                                    child: Text(
                                                      date.isEmpty
                                                          ? "****"
                                                          : date,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                      softWrap: true,
                                                      textAlign:
                                                          TextAlign.center,
                                                    ))),
                                            Expanded(
                                                flex: 4,
                                                child: Container(
                                                    padding:
                                                        const EdgeInsets.all(2),
                                                    child: Text(
                                                      type.isEmpty
                                                          ? "N/A"
                                                          : type,
                                                      style: TextStyle(
                                                          color: color,
                                                          fontSize: 16),
                                                      softWrap: true,
                                                    ))),
                                            Expanded(
                                                flex: 2,
                                                child: Container(
                                                    padding:
                                                        const EdgeInsets.all(2),
                                                    child: Text(
                                                      isCredit
                                                          ? "CREDIT"
                                                          : "DEBIT",
                                                      style: TextStyle(
                                                          color: isCredit
                                                              ? Colors.green
                                                              : Colors
                                                                  .redAccent),
                                                      softWrap: true,
                                                    ))),
                                            Expanded(
                                                flex: 2,
                                                child: Container(
                                                    padding:
                                                        const EdgeInsets.all(2),
                                                    child: Text(
                                                      amount,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      softWrap: true,
                                                    ))),
                                          ],
                                        ))));
                          },
                          separatorBuilder: (BuildContext context, int index) =>
                              const SizedBox(),
                        ).animate().moveY(duration: 700.ms, begin: 100, end: 0),
                        transactionList.length > 2
                            ? TextButton(
                                onPressed: () {
                                  context.navigate(AllTransactionsScreen(
                                      allTransactions: transactionList,
                                      ministatement: ministatement));
                                },
                                child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "View all",
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      Icon(Icons.arrow_forward)
                                    ]))
                            : const SizedBox()
                      ]);
                    } else if (snapshot.hasError) {
                      child = const EmptyUtil();
                      CommonUtils.showToast("Error getting ministatement");
                    }
                    return child;
                  },
                )
        ],
      );

  onSwipe(int index, CarouselPageChangedReason reason) {}

  addTransactions({required List<dynamic> list}) {
    transactionList.clear();
    if (list.isNotEmpty) {
      for (var item in list) {
        transactionList.add(Transaction.fromJson(item));
      }
    }
  }

  Widget _buildRetryButton() {
    var color = Theme.of(context).primaryColor;

    return Center(
        child: InkWell(
            onTap: () {
              setState(() {});
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.replay_outlined,
                  size: 44,
                  color: color,
                ),
                const Text(
                  "Reload",
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              ],
            )));
  }
}

class Transaction {
  String? date;
  String? amount;
  String? transactionType;
  String? type;

  Transaction(
      {required this.date,
      required this.amount,
      required this.transactionType,
      required this.type});

  Transaction.fromJson(Map<String, dynamic> json)
      : date = json["Transaction Time"],
        amount = json["Amount"],
        transactionType = json["Narration"],
        type = json["Transaction Type"];
}
