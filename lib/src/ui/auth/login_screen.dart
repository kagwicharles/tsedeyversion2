import 'package:craft_dynamic/craft_dynamic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_launcher_icons/config/config.dart';
import 'package:get/get.dart';
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
                  Expanded(
                    flex: 5,
                    child: Container(color: Colors.transparent),
                  ),
                  Expanded(
                    flex: 4,
                    child: Card(
                        margin: EdgeInsets.zero,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(40),
                                topRight: Radius.circular(40))),
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            child: widget.isLoadingScreen
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                          "assets/img/login_eclipse.png",
                                          height: 150,
                                          width: 150,
                                          fit: BoxFit.contain),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                      CircularLoadUtil(
                                        colors: [
                                          AppTheme.primaryColor,
                                          AppTheme.secondaryAccent
                                        ],
                                      )
                                    ],
                                  )
                                : SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Image.asset(
                                            "assets/img/login_eclipse.png",
                                            height: 150,
                                            width: 150,
                                            fit: BoxFit.contain),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        const Text(
                                          "Enter your Login PIN",
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 18),
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
                                                  fontWeight: FontWeight.bold),
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: AppTheme
                                                          .primaryColor),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(
                                                              12)))),
                                          forceErrorState: true,
                                          pinputAutovalidateMode:
                                              PinputAutovalidateMode.onSubmit,
                                          onCompleted: (pin) {
                                            _login(pin);
                                          },
                                        ),
                                        const SizedBox(
                                          height: 24,
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                                child: ElevatedButton(
                                                    onPressed: () {},
                                                    child:
                                                        const Text("Login"))),
                                            const SizedBox(
                                              width: 16,
                                            ),
                                            InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                onTap: () {
                                                  _authRepo.biometricLogin(
                                                      _pinController,
                                                      isButtonAction: true);
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  12)),
                                                      border: Border.all(
                                                          color: APIService
                                                              .appPrimaryColor)),
                                                  child: const Icon(
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
                                    ),
                                  ))),
                  )
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
