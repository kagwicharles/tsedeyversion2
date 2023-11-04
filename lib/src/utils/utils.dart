import 'dart:convert';
import 'package:craft_dynamic/craft_dynamic.dart';

final _sharedPref = CommonSharedPref();

class Util {
  static String getGreeting() {
    final currentTime = DateTime.now();
    final currentHour = currentTime.hour;

    if (currentHour < 12) {
      return "Good morning";
    } else if (currentHour < 18) {
      return "Good afternoon";
    } else {
      return "Good evening";
    }
  }
}

extension LocalPref on CommonSharedPref {
  updateUserProfileImage(String imagepath) async {
    await storage.write(key: "userprofileimage", value: imagepath);
  }

  retrieveUserProfileImage() async =>
      await storage.read(key: "userprofileimage");
}

extension APICall on APIService {
  Future<DynamicResponse?> requestFullStatement(
      String account, String startDate, String endDate, String pin) async {
    String? res;
    DynamicResponse dynamicResponse =
        DynamicResponse(status: StatusCode.unknown.name);
    Map<String, dynamic> requestObj = {};
    Map<String, dynamic> innerMap = {};
    innerMap["INFOFIELD1"] = startDate;
    innerMap["INFOFIELD3"] = endDate;
    innerMap["BANKACCOUNTID"] = account;
    innerMap["MerchantID"] = "FULLSTATEMENT";

    requestObj[RequestParam.PayBill.name] = innerMap;
    requestObj[RequestParam.EncryptedFields.name] = {
      "PIN": CryptLib.encryptField(pin)
    };

    final route =
        await _sharedPref.getRoute(RouteUrl.account.name.toLowerCase());
    try {
      res = await performDioRequest(
          await dioRequestBodySetUp("PAYBILL",
              objectMap: requestObj, isAuthenticate: false),
          route: route);
      dynamicResponse = DynamicResponse.fromJson(jsonDecode(res ?? "{}") ?? {});
      logger.d("full statement request : $res");
    } catch (e) {
      AppLogger.appLogE(tag: runtimeType.toString(), message: e.toString());
      return dynamicResponse;
    }

    return dynamicResponse;
  }
}
