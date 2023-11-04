import 'package:craft_dynamic/craft_dynamic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:tsedeybnk/src/appstate/app_state.dart';
import 'package:tsedeybnk/src/ui/home/home_tab.dart';
import 'package:tsedeybnk/src/ui/home/my_bank_screen.dart';
import 'package:tsedeybnk/src/ui/home/profile_tab.dart';
import 'package:tsedeybnk/src/ui/home/recents_tab.dart';
import 'package:tsedeybnk/src/ui/home/settings_screen.dart';

import '../../utils/utils.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _profileRepo = ProfileRepository();
  final _sessionManager = SessionRepository();
  List<BankAccount> accounts = [];
  List<ModuleItem> mainmodules = [];
  List<BottomNavigationBarItem> navItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.account_balance),
      label: 'My Bank',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.receipt_long_sharp),
      label: 'Recent',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];
  List<Widget> navWidgets = [
    const HomeTab(),
    const MyBankTab(),
    RecentsTab(),
    const ProfileTab()
  ];

  String name = "Buddy";
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _sessionManager.startSession();
    getCustomerDetails();
  }

  getCustomerDetails() async {
    name = await _profileRepo.getUserInfo(UserAccountData.FirstName) +
        " " +
        await _profileRepo.getUserInfo(UserAccountData.LastName);
    setCustomerName(name);
  }

  void setCustomerName(String name) {
    Provider.of<AppState>(context, listen: false).setCustomerName(name);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.dark),
        child: WillPopScope(
            onWillPop: () async {
              return AlertUtil.showAlertDialog(
                          context, "Would you like to logout",
                          isConfirm: true,
                          title: "Logout",
                          cancelButtonText: "Cancel",
                          confirmButtonText: "Logout")
                      .then((value) {
                    if (value) {
                      Navigator.of(context).pop();
                    }
                  }) ??
                  false;
            },
            child: Scaffold(
              body: Consumer<AppState>(
                  builder: (context, state, child) => Container(
                        height: double.infinity,
                        color: Theme.of(context).primaryColor.withOpacity(.1),
                        child: SafeArea(
                            child: Column(
                          children: [
                            _selectedIndex == 3
                                ? const SizedBox()
                                : Header(
                                    firstName: name,
                                  ),
                            Expanded(
                                child: navWidgets[_selectedIndex]
                                    .animate(
                                        onPlay: (controller) =>
                                            controller.isAnimating)
                                    .moveY(duration: 800.ms, begin: 50, end: 0))
                          ],
                        )),
                      )),
              bottomNavigationBar: BottomNavigationBar(
                items: navItems,
                iconSize: 28,
                showUnselectedLabels: true,

                type: BottomNavigationBarType.fixed,
                selectedFontSize: 14,
                elevation: 0,
                backgroundColor: Theme.of(context).primaryColor,
                // selectedLabelStyle:
                //     const TextStyle(fontWeight: FontWeight.w600),
                unselectedItemColor: Colors.white,
                selectedItemColor: Colors.grey[600],
                currentIndex: _selectedIndex,
                onTap: _onNavItemSelect,
              ),
            )));
  }

  void _onNavItemSelect(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class Header extends StatelessWidget {
  final String firstName;
  bool isProfileSettings = false;

  Header({required this.firstName, this.isProfileSettings = false, super.key});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Image.asset(
            "assets/launcher.png",
            height: 64,
            width: 64,
          ),
          const SizedBox(
            width: 15,
          ),
          isProfileSettings
              ? const Text(
                  "Profile Settings",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Util.getGreeting(),
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          firstName,
                          style: const TextStyle(fontSize: 18),
                        ))
                  ],
                ),
          const Spacer(),
          IconButton(
              onPressed: () {
                context.navigate(const SettingsScreen());
              },
              icon: Icon(
                Icons.grid_view_rounded,
                size: 34,
                color: Theme.of(context).primaryColor,
              ))
        ],
      );
}
