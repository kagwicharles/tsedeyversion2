import 'package:blur/blur.dart';
import 'package:craft_dynamic/craft_dynamic.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tsedeybnk/src/theme/app_theme.dart';

import '../../appstate/app_state.dart';

final _profileRepo = ProfileRepository();

class AccountsWidget extends StatefulWidget {
  final List<BankAccount> accounts;

  const AccountsWidget({required this.accounts, super.key});

  @override
  State<AccountsWidget> createState() => _AccountsWidgetState();
}

class _AccountsWidgetState extends State<AccountsWidget> {
  int _currentIndex = 0;
  final CarouselController _controller = CarouselController();

  @override
  void initState() {
    super.initState();
    setAccountID(widget.accounts[_currentIndex].bankAccountId);
  }

  @override
  Widget build(BuildContext context) => SizedBox(
      width: double.infinity,
      child: SizedBox(
          height: 250,
          width: double.infinity,
          child: Column(children: [
            CarouselSlider.builder(
                carouselController: _controller,
                options: CarouselOptions(
                  height: 200,
                  viewportFraction: 0.9,
                  initialPage: 0,
                  enableInfiniteScroll: false,
                  enlargeCenterPage: true,
                  scrollDirection: Axis.horizontal,
                  onPageChanged: onSwipe,
                ),
                itemCount: widget.accounts.length,
                itemBuilder:
                    (BuildContext context, int itemIndex, int pageViewIndex) {
                  var account = widget.accounts[itemIndex];

                  return BankAccountWidget(bankAccount: account);
                }),
            widget.accounts.length <= 1
                ? const SizedBox()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.accounts.asMap().entries.map((entry) {
                      return GestureDetector(
                        onTap: () => _controller.animateToPage(entry.key),
                        child: Container(
                          width: 12.0,
                          height: 12.0,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 4.0),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : APIService.appPrimaryColor)
                                  .withOpacity(
                                      _currentIndex == entry.key ? 0.9 : 0.4)),
                        ),
                      );
                    }).toList(),
                  ),
          ])));

  getBankAccounts() => _profileRepo.getUserBankAccounts();

  onSwipe(int index, CarouselPageChangedReason? reason) {
    setState(() {
      _currentIndex = index;
      setAccountID(widget.accounts[_currentIndex].bankAccountId);
    });
  }

  void setAccountID(String accountID) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppState>(context, listen: false)
          .setCurrentAccountID(accountID);
    });
  }
}

class BankAccountWidget extends StatefulWidget {
  final BankAccount bankAccount;

  const BankAccountWidget({super.key, required this.bankAccount});

  @override
  State<BankAccountWidget> createState() => _BankAccountWidgetState();
}

class _BankAccountWidgetState extends State<BankAccountWidget> {
  String accountBalance = "";
  String balancePlaceHolder = "*****";
  bool balanceLoading = false;
  bool accountBalanceError = false;
  bool balanceHidden = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Material(
      elevation: 0,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: const BoxDecoration(
            color: Colors.amber,
            image: DecorationImage(
                image: AssetImage(
                  "assets/img/card.png",
                ),
                fit: BoxFit.cover),
            borderRadius: BorderRadius.all(Radius.circular(12))),
        child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 24,
                ),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      "Available Balance",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    )),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        flex: 8,
                        child: Container(
                            padding: const EdgeInsets.all(4),
                            child: Center(
                                child: Text(
                              balanceHidden
                                  ? balancePlaceHolder
                                  : StringUtil
                                      .formatNumberWithThousandsSeparator(
                                          accountsAndBalances[widget
                                                  .bankAccount.bankAccountId] ??
                                              "Balance unavailable"),
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[50]),
                            )))),
                    Expanded(
                        flex: 2,
                        child: accountBalanceError
                            ? IconButton(
                                onPressed: () {
                                  // _getAccountBalance();
                                },
                                icon: const Row(
                                  children: [
                                    Icon(
                                      Icons.replay_outlined,
                                      size: 34,
                                      color: Colors.grey,
                                    ),
                                    Text(
                                      "Retry",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ))
                            : IconButton(
                                onPressed: () async {
                                  setState(() {
                                    balanceHidden = !balanceHidden;
                                  });
                                  // if (!balanceHidden) {
                                  //   await _getAccountBalance();
                                  // }
                                },
                                icon: Icon(
                                  balanceHidden
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  size: 34,
                                  color: Colors.white,
                                )))
                  ],
                ),
                const Spacer(),
                Container(
                  height: 55,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      color: Color(0xff121826),
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12))),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.bankAccount.bankAccountId
                              .replaceRange(4, 9, "****"),
                          style: TextStyle(
                              fontSize: 20, color: AppTheme.secondaryAccent),
                        ),
                      ]),
                )
              ],
            )),
      ));

  String getDateTime() {
    DateTime now = DateTime.now();
    return DateFormat("yyyy-MM-dd hh:mm").format(now);
  }

  _getAccountBalance() async {
    setState(() {
      balanceLoading = true;
    });
    var res = await _profileRepo
        .checkAccountBalance(widget.bankAccount.bankAccountId);

    setState(() {
      accountBalance = _profileRepo.getActualBalanceText(res!);
      if (accountBalance == "error") {
        accountBalanceError = true;
      } else {
        accountBalanceError = false;
      }
      balanceLoading = false;
    });
  }
}
