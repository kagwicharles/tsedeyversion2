import 'package:craft_dynamic/craft_dynamic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:tsedeybnk/src/ui/auth/activation_screen.dart';
import 'package:tsedeybnk/src/ui/auth/login_screen.dart';

class SplashScreen extends StatelessWidget {
  bool isLoadingScreen;

  SplashScreen({this.isLoadingScreen = false, super.key});

  final _sharedPref = CommonSharedPref();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Theme.of(context).primaryColor.withOpacity(.1),
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  isLoadingScreen
                      ? Image.asset("assets/img/tsedey_logo2.png")
                          .animate(
                              delay: 1000
                                  .ms, // this delay only happens once at the very start
                              onPlay: (controller) => controller.repeat())
                          .shimmer(duration: 1000.ms)
                      : Image.asset("assets/img/tsedey_logo2.png"),
                  const Column(
                    children: [
                      Text(
                        "Welcome",
                        style: TextStyle(
                            fontSize: 34, fontWeight: FontWeight.bold),
                      ),
                      Text("to Tsedey Bank S/C"),
                    ],
                  ),
                  isLoadingScreen
                      ? const SizedBox()
                      : SizedBox(
                          width: 200,
                          child: ElevatedButton(
                            onPressed: () {
                              _moveNext(context);
                            },
                            child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Continue"),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Icon(Icons.forward)
                                ]),
                          ))
                ])),
      ),
    );
  }

  _moveNext(context) async {
    bool isActivated = await _sharedPref.getAppActivationStatus();
    if (isActivated) {
      CommonUtils.navigateToRoute(
          context: context, widget: const LoginScreen());
    } else {
      CommonUtils.navigateToRoute(
          context: context, widget: const ActivationScreen());
    }
  }
}
