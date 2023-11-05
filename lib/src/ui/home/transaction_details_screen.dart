import 'package:craft_dynamic/craft_dynamic.dart';
import 'package:flutter/material.dart';
import 'package:tsedeybnk/src/theme/app_theme.dart';

import 'recents_tab.dart';

class TransactionDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> transactionlist;
  Transaction? transaction;
  bool isFullStatement;

  TransactionDetailsScreen(
      {super.key,
      required this.transactionlist,
      this.transaction,
      this.isFullStatement = false});

  @override
  State<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  bool loadingPDF = false;

  @override
  Widget build(BuildContext context) {
    AppLogger.appLogD(tag: 'message', message: widget.transactionlist);
    return Scaffold(
        appBar: AppBar(
          title: const Text("Transaction details"),
        ),
        body: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 16,
                  ),
                  widget.isFullStatement
                      ? const SizedBox()
                      : Icon(Icons.account_balance,
                          size: 77,
                          color: widget.transactionlist["Transaction Type"]
                                      .toLowerCase()
                                      .contains("credit") ??
                                  false
                              ? Colors.green.withOpacity(.6)
                              : Colors.redAccent.withOpacity(.6)),
                  widget.isFullStatement
                      ? const SizedBox()
                      : const SizedBox(
                          height: 8,
                        ),
                  widget.isFullStatement
                      ? const SizedBox()
                      : Text(
                          widget.transactionlist["Transaction Type"] ?? "",
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 24,
                              color: widget.transactionlist["Transaction Type"]
                                      .toLowerCase()
                                      .contains("credit")
                                  ? Colors.green
                                  : Colors.redAccent),
                        ),
                  widget.isFullStatement
                      ? const SizedBox()
                      : const SizedBox(
                          height: 4,
                        ),
                  const Text("See the transaction details below:"),
                  const SizedBox(
                    height: 20,
                  ),
                  ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.transactionlist.entries.length,
                      itemBuilder: (context, index) {
                        var map =
                            widget.transactionlist.entries.elementAt(index);
                        return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    flex: 4,
                                    child: Text(
                                      map.key,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )),
                                Expanded(
                                    flex: 6,
                                    child: Text(
                                      map.value,
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).primaryColor),
                                      overflow: TextOverflow.ellipsis,
                                    ))
                              ],
                            ));
                      },
                      separatorBuilder: (context, index) => const Divider(
                            color: Colors.grey,
                            height: 34,
                          )),
                  const SizedBox(
                    height: 64,
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: ElevatedButton(
                          onPressed: loadingPDF
                              ? null
                              : () async {
                                  setState(() {
                                    loadingPDF = true;
                                  });
                                  await PDFUtil.downloadReceipt(
                                      receiptdetails: widget.transactionlist,
                                      isShare: false);
                                  setState(() {
                                    loadingPDF = false;
                                  });
                                },
                          child: loadingPDF
                              ? CircularLoadUtil(
                                  colors: [
                                    AppTheme.secondaryAccent,
                                    Colors.white
                                  ],
                                )
                              : const Text("Download"))),
                  const SizedBox(
                    height: 16,
                  ),
                ]),
          ),
        ));
  }
}
