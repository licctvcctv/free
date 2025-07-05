
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:freego_flutter/util/storage.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtil{

  static const String savedKey = "permission_denied";
  PermissionUtil._internal();
  static final PermissionUtil _instance = PermissionUtil._internal();
  factory PermissionUtil(){
    return _instance;
  }

  Future<bool> checkPermission(Permission permission) async{
    bool isGranted = await permission.status.isGranted;
    if(isGranted){
      await removeRejectedPermission(permission);
    }
    return isGranted;
  }

  Future<bool> requestPermission({required BuildContext context, required Permission permission, required String info}) async{
    if(Platform.isIOS){
      PermissionStatus status = await permission.request();
      if(status.isGranted){
        return true;
      }
      else{
        return false;
      }
    }
    PermissionStatus status = await permission.status;
    if(status.isGranted){
      await removeRejectedPermission(permission);
      return true;
    }
    List<Permission> rejectedList = await getRejecedPermissions();
    if(rejectedList.contains(permission)){
      return false;
    }
    if(context.mounted){
      dynamic result = await showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.transparent,
        barrierLabel: '',
        pageBuilder:(context, animation, secondaryAnimation) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: Colors.transparent,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 4
                      )
                    ]
                  ),
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(info, style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
                      const SizedBox(height: 18,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: (){
                              addRejectedPermission(permission);
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                border: Border.fromBorderSide(BorderSide(color: ThemeUtil.foregroundColor))
                              ),
                              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                              child: const Text('拒 绝', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
                            ),
                          ),
                          InkWell(
                            onTap: () async{
                              await permission.request();
                              PermissionStatus status = await permission.status;
                              if(status.isDenied){
                                addRejectedPermission(permission);
                                ToastUtil.error('获取权限失败');
                              }
                              if(context.mounted){
                                Navigator.of(context).pop(true);
                              }
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: ThemeUtil.buttonColor,
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                border: Border.fromBorderSide(BorderSide(color: ThemeUtil.buttonColor))
                              ),
                              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                              child: const Text('同 意', style: TextStyle(color: Colors.white, fontSize: 16),),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          );
        },
      );
      if(result == true){
        return result;
      }
    }
    return false;
  }

  Future<List<Permission>> getRejecedPermissions() async{
    Object? permissions = await Storage.readInfo<String>(savedKey);
    if(permissions is! String){
      return [];
    }
    List<String> permissionValList;
    permissionValList = (permissions).split(',');
    List<Permission> result = [];
    for(String str in permissionValList){
      int? permissionVal = int.tryParse(str);
      if(permissionVal == null){
        continue;
      }
      result.add(Permission.byValue(permissionVal));
    }
    return result;
  }

  Future addRejectedPermission(Permission permission) async{
    List<Permission> savedList = await getRejecedPermissions();
    if(!await permission.isDenied){
      // 解决OPPO权限错误问题
      return;
    }
    if(savedList.contains(permission)){
      return;
    }
    savedList.add(permission);
    List<int> vals = [];
    for(Permission permission in savedList){
      vals.add(permission.value);
    }
    String savedVal = vals.join(',');
    return Storage.saveInfo<String>(savedKey, savedVal);
  }

  Future removeRejectedPermission(Permission permission) async{
    List<Permission> savedList = await getRejecedPermissions();
    if(!savedList.remove(permission)){
      return;
    }
    List<int> vals = [];
    for(Permission permission in savedList){
      vals.add(permission.value);
    }
    String savedVal = vals.join(',');
    return Storage.saveInfo<String>(savedKey, savedVal);
  }

}
