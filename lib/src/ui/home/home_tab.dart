import 'package:craft_dynamic/craft_dynamic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../appstate/app_state.dart';
import 'accounts.dart';
import 'main_modules.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<BankAccount> accounts = [];
  List<ModuleItem> mainmodules = [];

  final _profileRepo = ProfileRepository();
  final _sessionManager = SessionRepository();
  final _homeRepo = HomeRepository();

  @override
  void initState() {
    super.initState();
    _sessionManager.startSession();
    getBankAccounts();
  }

  getBankAccounts() async {
    setHomeLoading(true);
    await _profileRepo.getUserBankAccounts().then((value) {
      accounts = value;
    });
    mainmodules = await _homeRepo.getMainModules();
    setHomeLoading(false);
  }

  void setHomeLoading(bool status) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppState>(context, listen: false).setIsLoadingHome(status);
    });
  }

  @override
  Widget build(BuildContext context) => Consumer<AppState>(
        builder: (context, state, child) => SingleChildScrollView(
            child: Column(
          children: [
            const SizedBox(
              height: 28,
            ),
            state.isLoadingHome || accounts.isEmpty
                ? SizedBox(
                    height: 188,
                    child: CircularLoadUtil(
                      colors: [
                        APIService.appPrimaryColor,
                        APIService.appSecondaryColor
                      ],
                    ))
                : AccountsWidget(
                    accounts: accounts,
                  ),
            const SizedBox(
              height: 4,
            ),
            !state.isLoadingHome && mainmodules.isNotEmpty
                ? MainModules(
                    mainmodules: mainmodules,
                  ).animate().moveY(duration: 700.ms, begin: 100, end: 0)
                : const SizedBox(),
          ],
        )),
      );
}
