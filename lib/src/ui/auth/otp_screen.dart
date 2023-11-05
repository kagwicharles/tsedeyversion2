import 'dart:async';

import 'package:craft_dynamic/craft_dynamic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:tsedeybnk/src/ui/other/app_loader.dart';

import 'package:vibration/vibration.dart';

import '../../theme/app_theme.dart';
import 'login_screen.dart';

class OTPScreen extends StatefulWidget {
  final String mobileNumber;
  final String pin;

  const OTPScreen({super.key, required this.mobileNumber, required this.pin});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final _otpController = TextEditingController();
  final _authRepo = AuthRepository();
  Stopwatch _stopwatch = Stopwatch();

  String _stopwatchText = '10:00'; // initial stopwatch text
  bool _isLoading = false;
  int _timerCount = 600; // initial timer count in seconds
  late Timer _timer; // tim

  @override
  initState() {
    super.initState();
    configureTimer();
  }

  configureTimer() {
    _stopwatch = Stopwatch()..start();
    _timerCount = 60;
    // start the timer
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      setState(() {
        _stopwatchText =
            _formatTime(60 * 1000 - _stopwatch.elapsedMilliseconds);
        _timerCount--;
        if (_timerCount == 0) {
          _stopwatchText = "00:00";
        }
      });
      // check if stopwatch has reached 0
      if (_stopwatch.elapsed.inSeconds >= 60) {
        _stopwatch.stop();
        _timer.cancel();
      }
    });
  }

  String _formatTime(int milliseconds) {
    int seconds = (milliseconds / 1000).floor();
    int minutes = seconds ~/ 60;
    seconds = seconds % 60;
    if (seconds < 0) {
      seconds += 60;
      minutes--;
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Theme.of(context).primaryColor,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
        body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarBrightness: Brightness.light,
                statusBarIconBrightness: Brightness.dark),
            child: Scaffold(
              body: SizedBox(
                  height: double.infinity,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Image.asset(
                        "assets/img/bank_bg.png",
                        height: MediaQuery.sizeOf(context).height,
                        width: MediaQuery.sizeOf(context).width,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            width: double.infinity,
                            height:
                                (MediaQuery.sizeOf(context).height / 2) + 88,
                            decoration: const BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                      "assets/img/login_bg.png",
                                    ),
                                    fit: BoxFit.cover)),
                            margin: EdgeInsets.zero,
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: SingleChildScrollView(
                                    child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    // Image.asset(
                                    //     "assets/img/login_eclipse.png",
                                    //     height: 150,
                                    //     width: 150,
                                    //     fit: BoxFit.contain),
                                    const SizedBox(
                                      height: 164,
                                    ),
                                    const Text(
                                      "Enter OTP sent to your mobile/sms to activate account",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 18),
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    Pinput(
                                      obscuringCharacter: "*",
                                      obscureText: true,
                                      length: 6,
                                      controller: _otpController,
                                      defaultPinTheme: PinTheme(
                                          height: 60,
                                          width: 60,
                                          textStyle: TextStyle(
                                              color: APIService.appPrimaryColor,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold),
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: AppTheme.primaryColor),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(12)))),
                                      forceErrorState: true,
                                      pinputAutovalidateMode:
                                          PinputAutovalidateMode.onSubmit,
                                      onCompleted: (pin) {
                                        // _login(pin);
                                      },
                                    ),
                                    const SizedBox(
                                      height: 44,
                                    ),
                                    _isLoading
                                        ? AppLoader(
                                            useWhite: false,
                                          )
                                        : ElevatedButton(
                                            onPressed: _isLoading
                                                ? null
                                                : () {
                                                    if (_otpController
                                                            .text.isEmpty ||
                                                        _otpController.length !=
                                                            6) {
                                                      CommonUtils.showToast(
                                                          "Incorrect OTP!");
                                                      Vibration.vibrate();
                                                      return;
                                                    }
                                                    _verifyOTP(
                                                        _otpController.text);
                                                  },
                                            child: const Text("Verify OTP"))
                                  ],
                                ))),
                          ))
                    ],
                  )),
              backgroundColor: Theme.of(context).primaryColor,
            )));
  }

  @override
  void dispose() {
    super.dispose();
    _stopwatch.stop();
  }

  _verifyOTP(String pin) {
    setState(() {
      _isLoading = true;
    });
    _authRepo
        .verifyOTP(mobileNumber: widget.mobileNumber, otp: pin)
        .then((value) {
      setState(() {
        _isLoading = false;
      });
      debugPrint("ACTIVATION RES STATUS: ${value.status}");
      if (value.status == StatusCode.success.statusCode) {
        CommonUtils.navigateToRouteAndPopAll(
            context: context, widget: const LoginScreen());
      } else {
        _otpController.clear();
        CommonUtils.showToast(value.message ?? "Unable to verify OTP");
      }
    });
  }

  _resendOtp() {
    setState(() {
      _isLoading = true;
    });
    _authRepo
        .activate(mobileNumber: widget.mobileNumber, pin: widget.pin)
        .then((value) {
      setState(() {
        _isLoading = false;
      });
      if (value.status == StatusCode.success.statusCode) {
        _otpController.clear();
        configureTimer();
      } else {
        CommonUtils.showToast(value.message);
      }
    });
  }
}
