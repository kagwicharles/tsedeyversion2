import 'package:cached_network_image/cached_network_image.dart';
import 'package:craft_dynamic/craft_dynamic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:tsedeybnk/src/ui/home/full_statement_screen.dart';
import 'package:tsedeybnk/src/ui/home/map_screen.dart';

class MyBankTab extends StatefulWidget {
  const MyBankTab({super.key});

  @override
  State<MyBankTab> createState() => _MyBankScreenState();
}

class _MyBankScreenState extends State<MyBankTab> {
  List<ModuleItem> modules = [];
  final _moduleRepo = ModuleRepository();

  @override
  void initState() {
    super.initState();
    getMyBankModules();
  }

  getMyBankModules() async {
    var items = await _moduleRepo.getModulesById("MYBANK");
    AppLogger.appLogD(tag: "get my bank modules:", message: items);

    setState(() {
      modules = items ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(
            height: 16,
          ),
          Expanded(
            child: ListView.separated(
              itemCount: modules.length,
              itemBuilder: (context, index) {
                return ListItem(moduleItem: modules[index]);
              },
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(
                color: Colors.white,
                height: 4,
                thickness: 1,
              ),
            ).animate().moveY(duration: 700.ms, begin: 100, end: 0),
          )
        ]);
  }
}

class ListItem extends StatelessWidget {
  final ModuleItem moduleItem;
  const ListItem({super.key, required this.moduleItem});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          AppLogger.appLogD(
              tag: "list item on mybank", message: moduleItem.moduleId);
          if (checkIsStatic(context, moduleItem)) {
            return;
          }
          ModuleUtil.onItemClick(moduleItem, context);
        },
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: CachedNetworkImage(
                    height: 58,
                    width: 58,
                    fit: BoxFit.contain,
                    imageUrl: moduleItem.moduleUrl ?? "",
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) => SpinKitPulse(
                      itemBuilder: (BuildContext context, int index) {
                        return DecoratedBox(
                          decoration: BoxDecoration(
                            color: index.isEven
                                ? APIService.appPrimaryColor
                                : APIService.appSecondaryColor,
                          ),
                        );
                      },
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.error,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                Expanded(
                    flex: 8,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              moduleItem.moduleName,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            moduleItem.moduleDescription.toString().isEmpty ||
                                    moduleItem.moduleDescription == null
                                ? const SizedBox()
                                : Column(
                                    children: [
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        moduleItem.moduleDescription ?? "",
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    ],
                                  )
                          ],
                        ))),
                Expanded(
                    flex: 1,
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Theme.of(context).primaryColor,
                    ))
              ],
            )));
  }

  bool checkIsStatic(BuildContext context, ModuleItem moduleItem) {
    if (moduleItem.moduleId == "LOCATOR") {
      _showMyDialog(context);
      return true;
    }
    if (moduleItem.moduleId == "FULLSTATEMENT") {
      context.navigate(const FullStatementScreen());
      return true;
    }
    return false;
  }

  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding:
              const EdgeInsets.only(top: 2, bottom: 12, left: 12, right: 12),
          contentPadding:
              const EdgeInsets.only(top: 8, bottom: 2, left: 14, right: 14),
          actionsPadding:
              const EdgeInsets.symmetric(vertical: 4, horizontal: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          title: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Locators',
                  style: TextStyle(
                      color: APIService.appPrimaryColor, fontSize: 18),
                ),
                Icon(
                  Icons.map,
                  color: APIService.appSecondaryColor,
                )
              ],
            ),
            Divider(
              color: APIService.appPrimaryColor.withOpacity(.2),
            )
          ]),
          content: Row(
            children: [
              Expanded(
                  child: ElevatedButton(
                style: ButtonStyle(
                  minimumSize:
                      MaterialStateProperty.all(const Size.fromHeight(40)),
                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4))),
                ),
                child: const Text("ATMs"),
                onPressed: () {
                  context.navigate(MapView());
                },
              )),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                  child: ElevatedButton(
                style: ButtonStyle(
                    minimumSize:
                        MaterialStateProperty.all(const Size.fromHeight(40)),
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4))),
                    backgroundColor:
                        MaterialStatePropertyAll(APIService.appSecondaryColor)),
                child: const Text("Branches"),
                onPressed: () {
                  context.navigate(MapView(
                    isAtms: false,
                  ));
                },
              )),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
