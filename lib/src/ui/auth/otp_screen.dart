import 'dart:async';

import 'package:craft_dynamic/craft_dynamic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:tsedeybnk/src/ui/other/app_loader.dart';

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
      body: SafeArea(
          child: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Enter OTP\nsent via email or sms",
                  style: TextStyle(color: Colors.white, fontSize: 28),
                )),
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Pinput(
                  length: 6,
                  controller: _otpController,
                  autofocus: true,
                  obscureText: true,
                  defaultPinTheme: PinTheme(
                      height: 44,
                      width: 44,
                      textStyle: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.white),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(4)))),
                  forceErrorState: true,
                  pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                  onCompleted: (pin) {
                    _verifyOTP(pin);
                  },
                ),
                const SizedBox(
                  height: 44,
                ),
                if (_isLoading) AppLoader(),
                const SizedBox(
                  height: 12,
                ),
                Center(
                    child: InkWell(
                        onTap: _isLoading || _timerCount != 0
                            ? null
                            : () {
                                _resendOtp();
                              },
                        child: Text(
                          "Resend OTP",
                          style: TextStyle(color: Colors.grey[200]),
                        ))),
                const SizedBox(
                  height: 24,
                ),
                Text(_stopwatchText)
              ],
            ))
          ],
        ),
      )),
      backgroundColor: Theme.of(context).primaryColor,
    );
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
