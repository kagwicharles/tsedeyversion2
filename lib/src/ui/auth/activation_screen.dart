import 'package:craft_dynamic/craft_dynamic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import 'otp_screen.dart';

class ActivationScreen extends StatefulWidget {
  const ActivationScreen({super.key});

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authRepo = AuthRepository();

  String completeNumber = "";
  bool _isLoading = false;
  bool _passwordVisible = true;

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        body: Container(
          height: double.infinity,
          width: double.infinity,
          color: const Color(0xff105D38),
          child: Column(
            children: [
              Expanded(
                  flex: 4,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Center(
                        child: Image.asset("assets/img/tsedey_logo.png"),
                      ))),
              Expanded(
                  flex: 6,
                  child: Card(
                      margin: EdgeInsets.zero,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(40))),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Enter Activation Details",
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Text("to receive your activation key"),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  const Text(
                                    "Phone Number",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 16),
                                  ),
                                  IntlPhoneField(
                                    showDropdownIcon: false,
                                    controller: _phoneController,
                                    disableLengthCheck: true,
                                    decoration: InputDecoration(
                                      suffixIcon: IconButton(
                                          onPressed: () {
                                            _phoneController.clear();
                                          },
                                          icon: const Icon(Icons.clear)),
                                      hintText: 'Enter Mobile Number',
                                      border: const OutlineInputBorder(
                                          borderSide: BorderSide(),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(12))),
                                    ),
                                    initialCountryCode: 'ET',
                                    onChanged: (phone) {
                                      completeNumber =
                                          phone.completeNumber.formatPhone();
                                      // _countryCode = phone.countryCode;
                                    },
                                    validator: (value) {
                                      var phone = value?.number ?? "";

                                      if (phone.length != 9) {
                                        return "Invalid mobile";
                                      } else if (phone == "") {
                                        return "Enter your mobile";
                                      }
                                    },
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  const Text(
                                    "Enter PIN",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 16),
                                  ),
                                  WidgetFactory.buildTextField(
                                      context,
                                      TextFormFieldProperties(
                                          isEnabled: true,
                                          isObscured: _passwordVisible,
                                          controller: _pinController,
                                          inputDecoration: InputDecoration(
                                              hintText: "Enter pin",
                                              suffixIcon: IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _passwordVisible =
                                                          !_passwordVisible;
                                                    });
                                                  },
                                                  icon: Icon(
                                                    _passwordVisible
                                                        ? Icons.visibility
                                                        : Icons.visibility_off,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ))),
                                          textInputType: TextInputType.text),
                                      (pin) {
                                    if (pin != null) {
                                      if (pin.length < 4) {
                                        return "Invalid pin";
                                      }
                                    } else {
                                      return "Invalid pin";
                                    }
                                  }),
                                  const SizedBox(
                                    height: 44,
                                  ),
                                  _isLoading
                                      ? LoadUtil(
                                          colors: [
                                            APIService.appPrimaryColor,
                                            APIService.appSecondaryColor
                                          ],
                                        )
                                      : SizedBox(
                                          child: WidgetFactory.buildButton(
                                              context, () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            _activate();
                                          }
                                        }, "Activate"))
                                ],
                              ),
                            )),
                      ))),
            ],
          ),
        ),
      ));

  _activate() {
    setState(() {
      _isLoading = true;
    });
    _authRepo
        .activate(mobileNumber: completeNumber, pin: _pinController.text)
        .then((value) {
      setState(() {
        _isLoading = false;
      });
      if (value.status == StatusCode.success.statusCode) {
        CommonUtils.navigateToRoute(
            context: context,
            widget: OTPScreen(
              mobileNumber: completeNumber,
              pin: _pinController.text,
            ));
      } else {
        CommonUtils.showToast(
            value.message ?? "Unable to activate at the moment");
      }
    });
  }
}
