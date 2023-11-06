import 'package:cached_network_image/cached_network_image.dart';
import 'package:craft_dynamic/craft_dynamic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MainModules extends StatelessWidget {
  const MainModules({super.key, required this.mainmodules});

  final List<ModuleItem> mainmodules;

  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
          elevation: 0,
          color: Colors.transparent,
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GridView.builder(
                      shrinkWrap: true,
                      itemCount: mainmodules.length,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              childAspectRatio: 0.6,
                              crossAxisCount: 4,
                              mainAxisSpacing: 4,
                              crossAxisSpacing: 2),
                      itemBuilder: (BuildContext context, index) {
                        var module = mainmodules[index];
                        var image = mainmodules[index].moduleUrl;
                        var title = mainmodules[index].moduleName;

                        return InkWell(
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8)),
                            onTap: () {
                              ModuleUtil.onItemClick(
                                  mainmodules[index], context);
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ClipOval(
                                    child: Material(
                                        elevation: 8,
                                        child: CircleAvatar(
                                            radius: 40,
                                            backgroundColor: Colors.white,
                                            child: CachedNetworkImage(
                                              imageUrl: image ?? "",
                                              placeholder: (context, url) =>
                                                  SpinKitPulse(
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return DecoratedBox(
                                                    decoration: BoxDecoration(
                                                      color: index.isEven
                                                          ? APIService
                                                              .appPrimaryColor
                                                          : APIService
                                                              .appSecondaryColor,
                                                    ),
                                                  );
                                                },
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(Icons.error),
                                              height: module.menuProperties
                                                      ?.iconSize ??
                                                  40,
                                              width: module.menuProperties
                                                      ?.iconSize ??
                                                  40,
                                            )))),
                                const SizedBox(
                                  height: 24,
                                ),
                                Flexible(
                                    child: Text(
                                  title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 14),
                                ))
                              ],
                            ));
                      })
                ],
              ))));
}
