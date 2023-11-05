import 'package:craft_dynamic/craft_dynamic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:tsedeybnk/src/appstate/app_state.dart';
import 'package:tsedeybnk/src/ui/home/home_tab.dart';
import 'package:tsedeybnk/src/ui/home/my_bank_screen.dart';
import 'package:tsedeybnk/src/ui/home/profile_tab.dart';
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
      activeIcon: BarIcon(image: "activehome.png"),
      icon: BarIcon(image: "home.png"),
      label: 'Home',
    ),
    const BottomNavigationBarItem(
      activeIcon: BarIcon(image: "activemybank.png"),
      icon: BarIcon(image: "mybank.png"),
      label: 'My Bank',
    ),
    const BottomNavigationBarItem(
      activeIcon: BarIcon(image: "activesettings.png"),
      icon: BarIcon(image: "settings.png"),
      label: 'Settings',
    ),
  ];
  List<Widget> navWidgets = [
    const HomeTab(),
    const MyBankTab(),
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
    name = await _profileRepo.getUserInfo(UserAccountData.FirstName);
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
                backgroundColor: Colors.white,
                // selectedLabelStyle:
                //     const TextStyle(fontWeight: FontWeight.w600),
                unselectedItemColor: Colors.black,
                selectedItemColor: APIService.appPrimaryColor,
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

class BarIcon extends StatelessWidget {
  final String image;

  const BarIcon({super.key, required this.image});

  @override
  Widget build(BuildContext context) => Image.asset(
        "assets/img/$image",
        height: 28,
        width: 28,
        fit: BoxFit.contain,
      );
}

class Header extends StatelessWidget {
  final String firstName;
  bool isProfileSettings = false;

  Header({required this.firstName, this.isProfileSettings = false, super.key});

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          isProfileSettings
              ? const Text(
                  "Profile Settings",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello $firstName",
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      Util.getGreeting().toUpperCase(),
                      style: const TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
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
      ));
}
