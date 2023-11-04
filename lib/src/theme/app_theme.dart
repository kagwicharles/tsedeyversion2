import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const pageTransitionsTheme = PageTransitionsTheme(
  builders: <TargetPlatform, PageTransitionsBuilder>{
    TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
  },
);

class AppTheme {
  static var primaryColor = const Color(0xff17C37B);
  static var secondaryAccent = const Color(0xffF6D703);

  ThemeData appTheme = ThemeData(
    primaryColor: primaryColor,
    useMaterial3: true,
    pageTransitionsTheme: pageTransitionsTheme,
    // Add this line
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryAccent,
      surfaceTint: Colors.white,
      surface: Colors.white,
      onError: Colors.red,
    ),
    fontFamily: "NunitoSans",
    appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            statusBarBrightness:
                Brightness.light // this makes the status bar transparent
            ),
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white)),
    textTheme: const TextTheme(
      labelSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
            elevation: MaterialStateProperty.all(0.0),
            backgroundColor: MaterialStateProperty.all(primaryColor),
            foregroundColor: MaterialStateProperty.all(Colors.white),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0))),
            minimumSize: MaterialStateProperty.all(const Size.fromHeight(54)))),
    inputDecorationTheme: InputDecorationTheme(
      errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(255, 217, 217, 217)),
          borderRadius: BorderRadius.all(Radius.circular(12.0))),
      focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(255, 217, 217, 217)),
          borderRadius: BorderRadius.all(Radius.circular(12.0))),
      enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(255, 217, 217, 217)),
          borderRadius: BorderRadius.all(Radius.circular(12.0))),
      border: const OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(255, 217, 217, 217)),
          borderRadius: BorderRadius.all(Radius.circular(12.0))),
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
      labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      hintStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      filled: true,
      fillColor: Colors.grey[50],
    ),
    dropdownMenuTheme: const DropdownMenuThemeData(
        textStyle: TextStyle(fontStyle: FontStyle.normal)),
    outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
            elevation: MaterialStateProperty.all(0.0),
            side: MaterialStateProperty.all(
                const BorderSide(color: Colors.white)),
            minimumSize: MaterialStateProperty.all(const Size.fromHeight(62)))),
    tabBarTheme: const TabBarTheme(
        unselectedLabelColor: Colors.white,
        labelColor: Colors.white,
        indicator: UnderlineTabIndicator(
            borderSide: BorderSide(
              width: 4.0,
              color: Colors.white,
            ),
            insets: EdgeInsets.symmetric(horizontal: 2.0, vertical: 0.0))),
    chipTheme: const ChipThemeData(
        showCheckmark: false,
        checkmarkColor: Colors.white,
        iconTheme: IconThemeData(size: 0),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16)),
    scaffoldBackgroundColor: Colors.white,
  );
}
