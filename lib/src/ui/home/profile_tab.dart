import 'dart:io';

import 'package:craft_dynamic/craft_dynamic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:tsedeybnk/src/ui/home/dashboard_screen.dart';
import 'package:tsedeybnk/src/utils/utils.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _profileRepo = ProfileRepository();
  final ImagePicker _picker = ImagePicker();
  final _sharedPref = CommonSharedPref();
  File? imagefile;
  String fullname = "";
  String phone = "";
  String email = "";
  String imageUrl = "";

  @override
  void initState() {
    super.initState();
    getCustomerImageUrl();
  }

  getCustomerImageUrl() async {
    var customerimage = await _sharedPref.retrieveUserProfileImage();
    setState(() {
      imagefile = File(customerimage ?? "");
    });
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 24,
                ),
                Row(children: [
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.navigate(const DashboardScreen());
                      },
                      icon: const Icon(Icons.arrow_back)),
                  const SizedBox(
                    width: 12,
                  ),
                  const Text(
                    "Profile Settings",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )
                ]),
                const SizedBox(
                  height: 24,
                ),
                Center(
                  child: imagefile?.path == null || imagefile?.path == ""
                      ? const CircleAvatar(
                          radius: 54,
                          child: Icon(
                            Icons.person,
                            size: 54,
                          ))
                      : CircleAvatar(
                          radius: 54, // Image radius
                          backgroundImage: FileImage(
                            File(imagefile?.path ?? ""),
                          ),
                          onBackgroundImageError: (exception, stackTrace) =>
                              const Icon(Icons.person),
                        ),
                ),
                const SizedBox(
                  height: 18,
                ),
                IntrinsicHeight(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        showBottomDialog();
                      },
                      child: const Text("Change Photo"),
                    ),
                  ],
                )),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Personal Details",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(
                          height: 14,
                        ),
                        Card(
                          elevation: 0,
                          child: Column(
                            children: [
                              CardInfo(
                                  title: "Full Name",
                                  value: Row(
                                    children: [
                                      LoadAccountDetail(
                                          datakey: UserAccountData.FirstName),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      LoadAccountDetail(
                                          datakey: UserAccountData.LastName)
                                    ],
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 34,
                        ),
                        const Text(
                          "Account Details",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(
                          height: 14,
                        ),
                        Card(
                          elevation: 0,
                          child: Column(
                            children: [
                              CardInfo(
                                  title: "Email",
                                  value: LoadAccountDetail(
                                    datakey: UserAccountData.EmailID,
                                  )),
                              const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 14),
                                  child: Divider(
                                    color: Colors.grey,
                                  )),
                              CardInfo(
                                  title: "Phone Number",
                                  value: LoadAccountDetail(
                                    datakey: UserAccountData.Phone,
                                  ))
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 14,
                        ),
                        Card(
                            child: FutureBuilder<List<BankAccount>>(
                                future: _profileRepo.getUserBankAccounts(),
                                builder: (context, snapshot) => snapshot.hasData
                                    ? ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          String alias =
                                              snapshot.data?[index].aliasName ??
                                                  "";

                                          return Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(alias.isEmpty
                                                      ? "Account"
                                                      : alias),
                                                  Text(
                                                    snapshot.data?[index]
                                                            .bankAccountId
                                                            .replaceRange(
                                                          4,
                                                          9,
                                                          "****",
                                                        ) ??
                                                        "",
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )
                                                ],
                                              ));
                                        },
                                        separatorBuilder: (context, index) =>
                                            const SizedBox(
                                              height: 8,
                                            ),
                                        itemCount: snapshot.data?.length ?? 0)
                                    : ThreeLoadUtil()))
                      ]),
                ).animate().moveY(duration: 700.ms, begin: 100, end: 0),
                const SizedBox(
                  height: 24,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Version",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    FutureBuilder<String>(
                        future: DeviceInfo.getAppVersion(),
                        builder: (BuildContext context,
                            AsyncSnapshot<String> snapshot) {
                          Widget child = const SizedBox();
                          if (snapshot.hasData) {
                            child = Align(
                                alignment: Alignment.center,
                                child: Column(
                                  children: [
                                    Text(
                                      snapshot.data ?? "",
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ));
                          }
                          return child;
                        }),
                  ],
                )
              ],
            ),
          )),
        ],
      );

  updateImage(ImageSource sourse) async {
    final directory = await getApplicationDocumentsDirectory();
    _picker.pickImage(source: sourse).then((image) async {
      if (image != null) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        var imagelocation = File(image.path);
        File copiedimage =
            await imagelocation.copy("${directory.path}/profile");

        _sharedPref.updateUserProfileImage(copiedimage.path);
        setState(() {
          imagefile = File(copiedimage.path);
        });
      }
    });
  }

  deleteImage() async {
    if (imagefile != null && imagefile?.path != "") {
      var result = await AlertUtil.showAlertDialog(
          context, "Do you want to remove profile image?",
          isConfirm: true,
          confirmButtonText: "Delete",
          cancelButtonText: "Cancel",
          title: "Delete");
      if (result) {
        _sharedPref.updateUserProfileImage("");
        setState(() {
          imagefile = File("");
        });
      }
    } else {
      CommonUtils.showToast("No profile pic has been set!");
    }
  }

  showBottomDialog() {
    return showModalBottomSheet<void>(
      showDragHandle: true,
      context: context,
      builder: (BuildContext context) {
        return FractionallySizedBox(
            heightFactor: 0.5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: SingleChildScrollView(
                  child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Profile Options",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.close))
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        _showMyDialog(context);
                      },
                      child: const Text("Change Picture")),
                  const SizedBox(
                    height: 12,
                  ),
                  OutlinedButton(
                      onPressed: () {
                        deleteImage();
                      },
                      child: const Text("Delete Picture"))
                ],
              )),
            ));
      },
    );
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
              const EdgeInsets.only(top: 8, bottom: 2, left: 24, right: 24),
          actionsPadding:
              const EdgeInsets.symmetric(vertical: 4, horizontal: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          title: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Choose',
                  style: TextStyle(
                      color: APIService.appPrimaryColor, fontSize: 18),
                ),
                Icon(
                  Icons.image,
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
                child: const Text("Gallery"),
                onPressed: () {
                  updateImage(ImageSource.gallery);
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
                child: const Text("Take Photo"),
                onPressed: () {
                  updateImage(ImageSource.camera);
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

// ignore: must_be_immutable
class LoadAccountDetail extends StatelessWidget {
  LoadAccountDetail({super.key, required this.datakey});

  UserAccountData datakey;
  final _profileRepo = ProfileRepository();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: _profileRepo.getUserInfo(datakey),
        builder: (context, snapshot) => snapshot.hasData
            ? Text(
                snapshot.data ?? "",
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            : const Center(child: SizedBox()));
  }
}

class CardInfo extends StatelessWidget {
  final String title;
  final Widget value;

  const CardInfo({super.key, required this.title, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(title), value],
      ));
}
