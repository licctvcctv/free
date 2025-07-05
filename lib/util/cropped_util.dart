
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:image_cropper/image_cropper.dart';

class CroppedUtil{

  CroppedUtil._internal();
  static final CroppedUtil _instance = CroppedUtil._internal();
  factory CroppedUtil(){
    return _instance;
  }

  Future<String?> getCroppedFile(File file) async{
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
      ],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: '头像',
          toolbarColor: ThemeUtil.buttonColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: true
        ),
        IOSUiSettings(
          title: '头像',
          aspectRatioLockEnabled: true,
          aspectRatioPickerButtonHidden: true,
          resetButtonHidden: true,
          cancelButtonTitle: '取消',
          doneButtonTitle: '确定'
        ),
      ],
    );
    if(croppedFile == null){
      return null;
    }
    return croppedFile.path;
  }
}
