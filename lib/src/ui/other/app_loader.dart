import 'package:craft_dynamic/craft_dynamic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AppLoader extends StatelessWidget {
  bool useWhite;
  AppLoader({super.key, this.useWhite = true});

  @override
  Widget build(BuildContext context) => SpinKitWave(
        itemBuilder: (BuildContext context, int index) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: index.isEven
                  ? useWhite
                      ? Colors.white
                      : APIService.appPrimaryColor
                  : APIService.appSecondaryColor,
            ),
          );
        },
      );
}
