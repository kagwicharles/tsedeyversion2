import 'package:craft_dynamic/craft_dynamic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tsedeybnk/src/appstate/app_state.dart';
import 'package:tsedeybnk/src/ui/auth/activation_screen.dart';
import 'package:tsedeybnk/src/ui/auth/login_screen.dart';

import 'src/theme/app_theme.dart';

final profileRepo = ProfileRepository();
final _pref = CommonSharedPref();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light));

  // TODO Comment this line
  // await _pref.addActivationData("251905557471", "1648094426");

  bool activationStatus = await profileRepo.checkAppActivationStatus();

  runApp(ChangeNotifierProvider(
      create: (context) => AppState(),
      child: DynamicCraftWrapper(
        dashboard: activationStatus
            ? const LoginScreen(
                isLoadingScreen: false,
              )
            : const ActivationScreen(),
        appLoadingScreen: const LoginScreen(
          isLoadingScreen: true,
        ),
        appTimeoutScreen: const LoginScreen(),
        appInactivityScreen: const LoginScreen(),
        appTheme: AppTheme().appTheme,
        useExternalBankID: true,
        showAccountBalanceInDropdowns: true,
      )));
}
