import 'package:carousel_slider/carousel_slider.dart';
import 'package:craft_dynamic/craft_dynamic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:tsedeybnk/src/appstate/app_state.dart';
import 'package:tsedeybnk/src/ui/home/ministatement.dart';

class RecentsTab extends StatefulWidget {
  RecentsTab({super.key});

  @override
  State<RecentsTab> createState() => _RecentsTabState();
}

class _RecentsTabState extends State<RecentsTab> {
  final _profileRepo = ProfileRepository();
  final CarouselController _controller = CarouselController();
  List<BankAccount> userAccounts = [];

  int _currentIndex = 0;
  bool _isLoading = true;
  String _currentValue = "";

  @override
  void initState() {
    super.initState();
    getBankAccounts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppState>(context, listen: false).setTransactionsCount(0);
    });
  }

  getBankAccounts() async {
    var accounts = await _profileRepo.getUserBankAccounts();
    setState(() {
      _isLoading = false;
      userAccounts = accounts;
      _currentValue = userAccounts[0].bankAccountId;
    });
  }

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(
            height: 16,
          ),
          const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Recent Transactions",
                style: TextStyle(fontWeight: FontWeight.w600),
              )),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              const Text("Account:"),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                  child: DropdownButtonFormField(
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
                onChanged: (value) {
                  setState(() {
                    _currentValue = value.toString();
                  });
                },
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 14),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor)),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor),
                        borderRadius: BorderRadius.circular(4))),
              )),
            ],
          ),
          const SizedBox(
            height: 12,
          ),
          Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Consumer<AppState>(
                          builder: (context, state, child) => Text(
                                state.transactionsCount.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 28,
                                    color: APIService.appPrimaryColor),
                              ).animate().fadeIn()),
                      const SizedBox(
                        width: 12,
                      ),
                      const Text("Transactions")
                    ],
                  )
                ],
              )),
          Card(
              child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 2,
                          child: Container(
                              padding: const EdgeInsets.all(2),
                              child: const Text(
                                "Date/Time",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff3bb1bd)),
                              ))),
                      Expanded(
                          flex: 4,
                          child: Container(
                              padding: const EdgeInsets.all(2),
                              child: const Text(
                                "Narration",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff3bb1bd)),
                              ))),
                      Expanded(
                          flex: 2,
                          child: Container(
                              padding: const EdgeInsets.all(2),
                              child: const Text(
                                "TRX Type",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff3bb1bd)),
                              ))),
                      Expanded(
                          flex: 2,
                          child: Container(
                              padding: const EdgeInsets.all(2),
                              child: const Text(
                                "Amount",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff3bb1bd)),
                              )))
                    ],
                  ))),
          userAccounts.isNotEmpty && !_isLoading
              ? MinistatementScreen(accountID: _currentValue)
              : const SizedBox(),
        ],
      ));

  onSwipe(int index, CarouselPageChangedReason reason) {}
}
