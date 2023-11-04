import 'package:cached_network_image/cached_network_image.dart';
import 'package:craft_dynamic/craft_dynamic.dart';
import 'package:flutter/material.dart';

import '../auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _moduleRepo = ModuleRepository();
  String title = "Settings";

  @override
  initState() {
    super.initState();
    getSettingsModule();
  }

  getSettingsModules() =>
      _moduleRepo.getModulesById(ParentModule.MYACCOUNTS.name);

  getSettingsModule() async {
    var module = await _moduleRepo.getModuleById(ParentModule.MYACCOUNTS.name);
    setState(() {
      title = module?.moduleName ?? "Settings";
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 44,
                ),
                const Text(
                  "Options",
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(
                  height: 15,
                ),
                FutureBuilder<List<ModuleItem>?>(
                    future: getSettingsModules(),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<ModuleItem>?> snapshot) {
                      Widget child = LoadUtil();
                      var modules = snapshot.data ?? [];

                      if (modules.isNotEmpty) {
                        child = ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: modules.length,
                          itemBuilder: (BuildContext context, index) => InkWell(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8)),
                            onTap: () {
                              ModuleUtil.onItemClick(modules[index], context);
                            },
                            child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1,
                                        color: Theme.of(context).primaryColor),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8))),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        modules[index].moduleName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      CachedNetworkImage(
                                          height: 34,
                                          width: 34,
                                          imageUrl:
                                              modules[index].moduleUrl ?? ""),
                                    ])),
                          ),
                          separatorBuilder: (context, index) => const SizedBox(
                            height: 15,
                          ),
                        );
                      }
                      return child;
                    }),
                const SizedBox(
                  height: 15,
                ),
                InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: logout,
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 1,
                                color: Theme.of(context).primaryColor),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8))),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Logout",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Image.asset(
                                "assets/img/logout.png",
                                height: 34,
                                width: 34,
                              )
                            ]))),
                const SizedBox(
                  height: 54,
                ),
              ],
            )),
      );

  logout() {
    return AlertUtil.showAlertDialog(context, "Do you want to Logout",
                isConfirm: true,
                title: "Logout",
                confirmButtonText: "Logout",
                cancelButtonText: "Cancel")
            .then((value) {
          if (value) {
            context.navigateAndPopAll(const LoginScreen());
          }
        }) ??
        false;
  }
}
