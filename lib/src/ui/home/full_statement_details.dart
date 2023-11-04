import 'package:craft_dynamic/craft_dynamic.dart';
import 'package:flutter/material.dart';
import 'package:tsedeybnk/src/theme/app_theme.dart';
import 'package:tsedeybnk/src/ui/home/ministatement.dart';
import 'package:tsedeybnk/src/ui/home/transaction_details_screen.dart';

class FullStatementDetails extends StatefulWidget {
  final List<dynamic> transactions;

  const FullStatementDetails({super.key, required this.transactions});

  @override
  State<FullStatementDetails> createState() => _FullStatementDetailsState();
}

class _FullStatementDetailsState extends State<FullStatementDetails> {
  bool isLoadingPDF = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Full Statement"),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                const SizedBox(
                  height: 12,
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          widget.transactions.length.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: AppTheme.primaryColor),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        const Text("Transactions"),
                        const Spacer(),
                        TextButton(
                            onPressed: widget.transactions.isNotEmpty
                                ? () {
                                    downloadFullPDF(widget.transactions);
                                  }
                                : null,
                            child: Row(
                              children: [
                                const Text("Download"),
                                const SizedBox(
                                  width: 4,
                                ),
                                Icon(
                                  Icons.download,
                                  color: AppTheme.primaryColor,
                                )
                              ],
                            ))
                      ],
                    )),
                Expanded(
                    child: ListView.separated(
                  itemCount: widget.transactions.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> map = widget.transactions[index];

                    return InkWell(
                        onTap: isLoadingPDF
                            ? null
                            : () {
                                context.navigate(TransactionDetailsScreen(
                                  transactionlist: map,
                                  transaction: Transaction.fromJson(map),
                                ));
                              },
                        child: Container(
                            padding: const EdgeInsets.all(4),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: map.entries.length,
                              itemBuilder: (context, index) {
                                var item = map.entries.toList()[index];
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                        flex: 4, child: Text("${item.key}:")),
                                    Expanded(
                                        flex: 6,
                                        child: Text(
                                          item.value,
                                          style: TextStyle(
                                              color:
                                                  APIService.appPrimaryColor),
                                        ))
                                  ],
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      const SizedBox(
                                height: 8,
                              ),
                            )));
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(
                    height: 1,
                  ),
                )),
              ],
            ),
            isLoadingPDF
                ? Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: CircularLoadUtil())
                : const SizedBox()
          ],
        ));
  }

  downloadFullPDF(List<dynamic> transactions) async {
    setState(() {
      isLoadingPDF = true;
    });
    await PDFUtil.downloadReceipt(
        transactionlist: transactions, isShare: false, drawMultipleGrids: true);
    setState(() {
      isLoadingPDF = false;
    });
  }

  Map<String, dynamic> convertToMap(List<dynamic> list) {
    Map<String, dynamic> map = {};
    for (var item in list) {
      if (item is Map<String, dynamic>) {
        map.addAll(item);
      }
    }
    AppLogger.appLogD(tag: "full_statement_details", message: map);
    return map;
  }
}
