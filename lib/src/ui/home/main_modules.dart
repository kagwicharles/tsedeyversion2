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
                  const Text(
                    "My services",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  GridView.builder(
                      shrinkWrap: true,
                      itemCount: mainmodules.length,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              childAspectRatio: 1.7,
                              crossAxisCount: 2,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 2),
                      itemBuilder: (BuildContext context, index) {
                        var module = mainmodules[index];
                        var image = mainmodules[index].moduleUrl;
                        var title = mainmodules[index].moduleName;

                        return Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            child: InkWell(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(8)),
                                onTap: () {
                                  ModuleUtil.onItemClick(
                                      mainmodules[index], context);
                                },
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: image ?? "",
                                      placeholder: (context, url) =>
                                          SpinKitPulse(
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return DecoratedBox(
                                            decoration: BoxDecoration(
                                              color: index.isEven
                                                  ? APIService.appPrimaryColor
                                                  : APIService
                                                      .appSecondaryColor,
                                            ),
                                          );
                                        },
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                      height:
                                          module.menuProperties?.iconSize ?? 40,
                                      width:
                                          module.menuProperties?.iconSize ?? 40,
                                    ),
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    Flexible(
                                        child: Text(
                                      title,
                                      textAlign: TextAlign.center,
                                    ))
                                  ],
                                )));
                      })
                ],
              ))));
}
