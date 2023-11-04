import 'package:craft_dynamic/craft_dynamic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:tsedeybnk/src/appstate/app_state.dart';
import 'package:tsedeybnk/src/ui/home/transaction_details_screen.dart';

class MinistatementScreen extends StatefulWidget {
  final String accountID;

  const MinistatementScreen({required this.accountID, super.key});

  @override
  State<MinistatementScreen> createState() => _MinistatementScreenState();
}

class _MinistatementScreenState extends State<MinistatementScreen> {
  List<dynamic> ministatement = [];

  @override
  Widget build(BuildContext context) => widget.accountID.isEmpty
      ? const EmptyUtil()
      : TransactionsList(accountID: widget.accountID);
}

class TransactionsList extends StatefulWidget {
  final String accountID;

  const TransactionsList({required this.accountID, super.key});

  @override
  State<TransactionsList> createState() => _TransactionsListState();
}

class _TransactionsListState extends State<TransactionsList> {
  List<Transaction> transactionList = [];
  final _profileRepo = ProfileRepository();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<DynamicResponse?> _checkMiniStatement(String accountID) async {
    return await _profileRepo.checkMiniStatement(accountID,
        merchantID: "STATEMENT");
  }

  @override
  Widget build(BuildContext context) {
    var color = Theme.of(context).primaryColor;

    return FutureBuilder<DynamicResponse?>(
      future: _checkMiniStatement(
          widget.accountID), // a previously-obtained Future<String> or null
      builder:
          (BuildContext context, AsyncSnapshot<DynamicResponse?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Expanded(child: Center(child: CircularLoadUtil()));
        }

        Widget child = Center(child: LoadUtil());
        if (snapshot.hasData) {
          var ministatement = snapshot.data?.accountStatement;

          if (snapshot.data?.status != StatusCode.success.statusCode) {
            CommonUtils.showToast(
                snapshot.data?.message ?? "Ministatement request failed");
            return _buildRetryButton();
          }

          if (ministatement == null) {
            return _buildRetryButton();
          } else if (ministatement.isEmpty) {
            CommonUtils.showToast("No transactions yet");
            return const EmptyUtil();
          }

          addTransactions(list: ministatement);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<AppState>(context, listen: false)
                .setTransactionsCount(transactionList.length);
          });

          child = Expanded(
              child: ListView.separated(
            shrinkWrap: true,
            itemCount: transactionList.length,
            itemBuilder: (BuildContext context, index) {
              var date = transactionList[index].date ?? "";
              var type = transactionList[index].transactionType ?? "";
              var amount = transactionList[index].amount ?? "";
              bool isCredit =
                  transactionList[index].type == "CREDIT" ? true : false;

              return Card(
                  child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        context.navigate(TransactionDetailsScreen(
                          transaction: transactionList[index],
                          transactionlist: ministatement[index],
                        ));
                      },
                      child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: Container(
                                      padding: const EdgeInsets.all(2),
                                      child: Text(
                                        date.isEmpty ? "****" : date,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                        ),
                                        softWrap: true,
                                        textAlign: TextAlign.center,
                                      ))),
                              Expanded(
                                  flex: 4,
                                  child: Container(
                                      padding: const EdgeInsets.all(2),
                                      child: Text(
                                        type.isEmpty ? "N/A" : type,
                                        style: TextStyle(
                                            color: color, fontSize: 16),
                                        softWrap: true,
                                      ))),
                              Expanded(
                                  flex: 2,
                                  child: Container(
                                      padding: const EdgeInsets.all(2),
                                      child: Text(
                                        isCredit ? "CREDIT" : "DEBIT",
                                        style: TextStyle(
                                            color: isCredit
                                                ? Colors.green
                                                : Colors.redAccent),
                                        softWrap: true,
                                      ))),
                              Expanded(
                                  flex: 2,
                                  child: Container(
                                      padding: const EdgeInsets.all(2),
                                      child: Text(
                                        amount,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        softWrap: true,
                                      ))),
                            ],
                          ))));
            },
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(),
          )
                  .animate(onPlay: (controller) => controller.isAnimating)
                  .moveY(duration: 700.ms, begin: 50, end: 0));
        } else if (snapshot.hasError) {
          child = const EmptyUtil();
          CommonUtils.showToast("Error getting ministatement");
        }
        return child;
      },
    );
  }

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

    return Expanded(
        child: Center(
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
                ))));
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
