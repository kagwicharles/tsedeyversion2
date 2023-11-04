import 'package:craft_dynamic/craft_dynamic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_launcher_icons/config/config.dart';
import 'package:pinput/pinput.dart';
import 'package:tsedeybnk/src/theme/app_theme.dart';

import '../home/dashboard_screen.dart';
import '../other/app_loader.dart';

class LoginScreen extends StatefulWidget {
  final bool isLoadingScreen;

  const LoginScreen({super.key, this.isLoadingScreen = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _pinController = TextEditingController();
  final _authRepo = AuthRepository();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Theme.of(context).primaryColor,
      statusBarIconBrightness: Brightness.light,
    ));

    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.dark),
        child: Scaffold(
          body: Container(
              height: double.infinity,
              width: double.infinity,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(
                        "assets/img/bank_bg.png",
                      ),
                      fit: BoxFit.cover)),
              child: Column(
                children: [
                  const Expanded(flex: 5, child: SizedBox()),
                  Expanded(
                      flex: 5,
                      child: Stack(
                        children: [
                          Card(
                              margin: EdgeInsets.zero,
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(40),
                                      topRight: Radius.circular(40))),
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 20,
                                  ),
                                  child: widget.isLoadingScreen
                                      ? CircularLoadUtil(
                                          colors: [
                                            AppTheme.primaryColor,
                                            AppTheme.secondaryAccent
                                          ],
                                        )
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            const SizedBox(
                                              height: 12,
                                            ),
                                            const Text(
                                              "Enter your Login PIN",
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 18),
                                            ),
                                            const SizedBox(
                                              height: 12,
                                            ),
                                            Pinput(
                                              obscuringCharacter: "*",
                                              enabled: widget.isLoadingScreen
                                                  ? false
                                                  : true,
                                              length: 4,
                                              controller: _pinController,
                                              autofocus: widget.isLoadingScreen
                                                  ? false
                                                  : true,
                                              obscureText: true,
                                              defaultPinTheme: PinTheme(
                                                  height: 60,
                                                  width: 60,
                                                  textStyle: TextStyle(
                                                      color: APIService
                                                          .appPrimaryColor,
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  padding:
                                                      const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: AppTheme
                                                              .primaryColor),
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  12)))),
                                              forceErrorState: true,
                                              pinputAutovalidateMode:
                                                  PinputAutovalidateMode
                                                      .onSubmit,
                                              onCompleted: (pin) {
                                                _login(pin);
                                              },
                                            ),
                                            SizedBox(
                                              height: 24,
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                    child: ElevatedButton(
                                                        onPressed: () {},
                                                        child: const Text(
                                                            "Login"))),
                                                const SizedBox(
                                                  width: 16,
                                                ),
                                                InkWell(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    onTap: () {
                                                      _authRepo.biometricLogin(
                                                          _pinController,
                                                          isButtonAction: true);
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.all(12),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          12)),
                                                          border: Border.all(
                                                              color: APIService
                                                                  .appPrimaryColor)),
                                                      child: Icon(
                                                        Icons.fingerprint,
                                                        color: Colors.black,
                                                        size: 28,
                                                      ),
                                                    )),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 44,
                                            ),
                                            if (_isLoading)
                                              AppLoader(
                                                useWhite: false,
                                              ),
                                            const SizedBox(
                                              height: 12,
                                            )
                                          ],
                                        ))),
                          Positioned(
                              left: 0,
                              right: 0,
                              top: -300,
                              child:
                                  Image.asset("assets/img/login_eclipse.png")),
                        ],
                      ))
                ],
              )),
          backgroundColor: Theme.of(context).primaryColor,
        ));
  }

  _login(String pin) {
    setState(() {
      _isLoading = true;
    });
    _authRepo.login(pin).then((value) {
      setState(() {
        _isLoading = false;
      });
      if (value.status == StatusCode.success.statusCode) {
        _pinController.clear();
        CommonUtils.navigateToRoute(
            context: context, widget: const DashboardScreen());
      } else {
        _pinController.clear();
        CommonUtils.showToast(value.message ?? "Try Again Later!");
      }
    });
  }
}
