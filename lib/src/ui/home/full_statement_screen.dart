import 'package:craft_dynamic/craft_dynamic.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tsedeybnk/src/ui/home/full_statement_details.dart';
import 'package:tsedeybnk/src/utils/utils.dart';
import 'package:vibration/vibration.dart';

class FullStatementScreen extends StatefulWidget {
  const FullStatementScreen({super.key});

  @override
  State<FullStatementScreen> createState() => _FullStatementScreenState();
}

class _FullStatementScreenState extends State<FullStatementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bankAccountRepo = BankAccountRepository();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _pinController = TextEditingController();
  final _api = APIService();

  List<BankAccount> accounts = [];
  String? _currentAccount;
  bool isObscured = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    getAccounts();
  }

  getAccounts() async {
    var accounts = await _bankAccountRepo.getAllBankAccounts();
    setState(() {
      this.accounts = accounts ?? [];
      _currentAccount = accounts?[0].bankAccountId;
    });
  }

  List<DropdownMenuItem> parseDrodownItems() {
    List<DropdownMenuItem> items = [];
    if (accounts.isNotEmpty) {
      for (var item in accounts) {
        items.add(DropdownMenuItem(
            value: item.bankAccountId,
            child: Text(
                item.aliasName.isEmpty ? item.bankAccountId : item.aliasName)));
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Full Statement")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(children: [
          const SizedBox(
            height: 20,
          ),
          Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField(
                    value: _currentAccount,
                    decoration:
                        const InputDecoration(hintText: "Select Account"),
                    items: parseDrodownItems(),
                    onChanged: (value) {
                      _currentAccount = value;
                    },
                    validator: (value) {
                      if (value == null) {
                        return "Input required*";
                      }
                    },
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  TextFormField(
                    controller: _startDateController,
                    decoration: InputDecoration(
                        hintText: "Enter Start Date",
                        suffixIcon: IconButton(
                          onPressed: () {
                            selectDate(_startDateController);
                          },
                          icon: Icon(
                            Icons.calendar_month,
                            color: APIService.appPrimaryColor,
                          ),
                        )),
                    validator: inputValidator,
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  TextFormField(
                    controller: _endDateController,
                    decoration: InputDecoration(
                        hintText: "Enter End Date",
                        suffixIcon: IconButton(
                          onPressed: () {
                            selectDate(_endDateController);
                          },
                          icon: Icon(
                            Icons.calendar_month,
                            color: APIService.appPrimaryColor,
                          ),
                        )),
                    validator: inputValidator,
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  TextFormField(
                    controller: _pinController,
                    obscureText: isObscured,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        hintText: "Enter PIN",
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                isObscured = !isObscured;
                              });
                            },
                            icon: Icon(
                              isObscured
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: APIService.appPrimaryColor,
                            ))),
                    validator: inputValidator,
                  ),
                  const SizedBox(
                    height: 44,
                  ),
                  _isLoading
                      ? LoadUtil()
                      : ElevatedButton(
                          onPressed: requestFullStatement,
                          child: const Text("Submit"))
                ],
              ))
        ]),
      ),
    );
  }

  selectDate(TextEditingController controller) async {
    DateTime selectedDate = DateTime.now();

    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1900),
        lastDate: DateTime(2101));
    setState(() {
      controller.text = DateFormat('yyyy-MM-dd').format(picked ?? selectedDate);
    });
  }

  String? inputValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Input required*";
    }
    return null;
  }

  requestFullStatement() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      _api
          .requestFullStatement(
              _currentAccount ?? "",
              _startDateController.text,
              _endDateController.text,
              _pinController.text)
          .then((value) {
        setState(() {
          _isLoading = false;
        });
        if (value?.status == StatusCode.success.statusCode) {
          context.navigate(
              FullStatementDetails(transactions: value?.dynamicList ?? []));
          clearInput();
        } else {
          AlertUtil.showAlertDialog(
              context, value?.message ?? "Full Statement Retrieval Failed!",
              isInfoAlert: true);
        }
      });
    } else {
      Vibration.vibrate();
    }
  }

  clearInput() {
    _startDateController.clear();
    _endDateController.clear();
    _pinController.clear();
  }
}
