import 'package:craft_dynamic/craft_dynamic.dart';
import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
          body: SafeArea(
              child: Center(
        child: LoadUtil(),
      )));
}
