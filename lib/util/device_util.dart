//
// import 'dart:io';
//
// import 'package:device_info_plus/device_info_plus.dart';
//
// class DeviceUtil {
//
//   DeviceUtil._internal();
//   static final DeviceUtil _instance = DeviceUtil._internal();
//   factory DeviceUtil(){
//     return _instance;
//   }
//
//   Future getDeviceInfo() async{
//     DeviceInfoPlugin plugin = DeviceInfoPlugin();
//     if(Platform.isAndroid){
//       AndroidDeviceInfo info = await plugin.androidInfo;
//     }
//     else if(Platform.isIOS){
//       IosDeviceInfo info = await plugin.iosInfo;
//     }
//   }
// }
