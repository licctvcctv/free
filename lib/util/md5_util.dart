
import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class MD5Util{

  MD5Util._internal();

  static final MD5Util _instance = MD5Util._internal();

  factory MD5Util(){
    return _instance;
  }

  Future<List<int>> getFileMd5BytesFromPath(String filePath) async{
    File file = File(filePath);
    var digest = await md5.bind(file.openRead()).first;
    return digest.bytes;
  }

  Future<List<int>> getFileMd5Bytes(File file) async{
    var digest = await md5.bind(file.openRead()).first;
    return digest.bytes;
  }

  Future<String> getFileMd5Base64FromPath(String filePath) async{
    var md5bytes = await getFileMd5BytesFromPath(filePath);
    return base64.encode(md5bytes);
  }

  Future<String> getFileMd5Base64(File file) async{
    var md5bytes = await getFileMd5Bytes(file);
    return base64.encode(md5bytes);
  }
}
