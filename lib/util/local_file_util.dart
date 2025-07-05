
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class LocalFileUtil{

  static String androidRoot = '/storage/emulated/0';
  static String androidRootCamera = '$androidRoot/DCIM/Camera';

  static Future<Directory?> getProejctPath() async{
    if(Platform.isAndroid){
      String projectPath = '$androidRoot/freego';
      return Directory(projectPath);
    }
    else if(Platform.isIOS){
      return await getApplicationDocumentsDirectory();
    }
    return null;
  }

  static Future<Directory?> getResourcePath() async{
    if(Platform.isAndroid){
      return await getExternalStorageDirectory();
    }
    else if(Platform.isIOS){
      return await getApplicationDocumentsDirectory();
    }
    return null;
  }

  static String getFileName(String path){
    int idx = path.lastIndexOf('/');
    if(idx >= 0){
      return path.substring(idx + 1);
    }
    return path;
  }
  static String getFileNameWithoutExtendsion(String path){
    int idx1 = path.lastIndexOf('/');
    int idx2 = path.lastIndexOf('.');
    if(idx1 >= 0){
      if(idx2 >= 0){
        return path.substring(idx1 + 1, idx2);
      }
      else{
        return path.substring(idx1 + 1);
      }
    }
    else{
      if(idx2 >= 0){
        return path.substring(0, idx2);
      }
      return path;
    }
  }
  static String getFileExtension(String path){
    int idx = path.lastIndexOf('.');
    if(idx >= 0){
      return path.substring(idx + 1);
    }
    return '';
  }
  static String getPathWithoutExtension(String path){
    int idx = path.lastIndexOf('.');
    if(idx >= 0){
      return path.substring(0, idx);
    }
    return path;
  }

  static String? getFileContentType(String path){
    String ext = getFileExtension(path);
    switch(ext){
      case "jpg":
      case "jpeg":
        return "image/jpeg";
      case "gif":
        return "image/gif";
      case "png":
        return "image/png";
      case "mp3":
        return "audio/mpeg";
      case "ogg":
        return "audio/ogg";
      case "m4a":
        return "audio/mp4";
      case "wav":
        return "audio/wav";
      case "mp4":
        return "video/mp4";
      default:
        return null;
    }
  }
}
