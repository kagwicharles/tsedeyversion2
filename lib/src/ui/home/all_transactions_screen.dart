import 'package:craft_dynamic/craft_dynamic.dart';
import 'package:flutter/material.dart';

import 'recents_tab.dart';
import 'transaction_details_screen.dart';

class AllTransactionsScreen extends StatelessWidget {
  final List<Transaction> allTransactions;
  final List<dynamic> ministatement;

  const AllTransactionsScreen(
      {super.key, required this.allTransactions, required this.ministatement});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Column(
          children: [
            const SizedBox(
              height: 24,
            ),
            Row(children: [
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.arrow_back)),
              const SizedBox(
                width: 12,
              ),
              const Text(
                "All Transactions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              )
            ]),
            const SizedBox(
              height: 16,
            ),
            const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: StatementHeader()),
            const SizedBox(
              height: 4,
            ),
            Expanded(
                child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: allTransactions.length,
              itemBuilder: (BuildContext context, index) {
                var color = Theme.of(context).primaryColor;

                Transaction? trx = allTransactions[index];
                var date = allTransactions[index].date ?? "";
                var type = allTransactions[index].transactionType ?? "";
                var amount = allTransactions[index].amount ?? "";
                bool isCredit = allTransactions[index]
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
            )),
          ],
        ),
      );
}

class StatementHeader extends StatelessWidget {
  const StatementHeader({super.key});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
              flex: 2,
              child: Container(
                  padding: const EdgeInsets.all(2),
                  child: const Text(
                    "Date/Time",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xff3bb1bd)),
                  ))),
          Expanded(
              flex: 4,
              child: Container(
                  padding: const EdgeInsets.all(2),
                  child: const Text(
                    "Narration",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xff3bb1bd)),
                  ))),
          Expanded(
              flex: 2,
              child: Container(
                  padding: const EdgeInsets.all(2),
                  child: const Text(
                    "TRX Type",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xff3bb1bd)),
                  ))),
          Expanded(
              flex: 2,
              child: Container(
                  padding: const EdgeInsets.all(2),
                  child: const Text(
                    "Amount",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xff3bb1bd)),
                  )))
        ],
      );
}
