import 'package:blur/blur.dart';
import 'package:craft_dynamic/craft_dynamic.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
          height: 220,
          width: double.infinity,
          child: Column(children: [
            CarouselSlider.builder(
                carouselController: _controller,
                options: CarouselOptions(
                  height: 184,
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
      elevation: 4,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      child: Container(
          height: 184,
          width: double.infinity,
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                    "assets/img/account_bg.png",
                  ),
                  opacity: 2,
                  fit: BoxFit.cover),
              borderRadius: BorderRadius.all(Radius.circular(12))),
          child: Stack(
            children: [
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Balance",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                              flex: 7,
                              child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                      color: const Color(0xff37b0b6)
                                          .withOpacity(.5),
                                      borderRadius: BorderRadius.circular(4)),
                                  child: Center(
                                      child: Text(
                                    balanceHidden
                                        ? balancePlaceHolder
                                        : StringUtil
                                            .formatNumberWithThousandsSeparator(
                                                accountsAndBalances[widget
                                                        .bankAccount
                                                        .bankAccountId] ??
                                                    "Balance unavailable"),
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red[50]),
                                  )))),
                          Expanded(
                              flex: 3,
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
                                            style:
                                                TextStyle(color: Colors.white),
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
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        size: 34,
                                        color: Colors.white,
                                      )))
                        ],
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Text(
                        "Account: ${widget.bankAccount.bankAccountId.replaceRange(4, 9, "****")}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        "Date/Time: ${getDateTime()}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      )
                    ],
                  )),
              balanceLoading
                  ? SpinKitWave(
                      itemBuilder: (BuildContext context, int index) {
                        return DecoratedBox(
                          decoration: BoxDecoration(
                            color: index.isEven
                                ? APIService.appPrimaryColor
                                : APIService.appSecondaryColor,
                          ),
                        );
                      },
                    ).frosted(
                      blur: 2,
                      borderRadius: BorderRadius.circular(12),
                    )
                  : const SizedBox()
            ],
          )));

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
