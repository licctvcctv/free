
import 'package:freego_flutter/local_storage/api/local_guide_api.dart';
import 'package:freego_flutter/local_storage/local_storage_guide.dart';
import 'package:freego_flutter/local_storage/model/local_guide.dart';

class LocalGuideUtil{

  static const Duration duration = Duration(days: 1);

  LocalGuideUtil._internal();
  static final LocalGuideUtil _instance = LocalGuideUtil._internal();
  factory LocalGuideUtil(){
    return _instance;
  }

  Future<LocalGuide?> get(int id) async{
    LocalGuide? localGuide = await LocalStorageGuide().get(id);
    bool reget = false;
    if(localGuide == null){
      reget = true;
    }
    else{
      DateTime? lastUpdateTime = localGuide.lastUpdateTime;
      if(lastUpdateTime == null){
        reget = true;
      }
      else{
        DateTime now = DateTime.now();
        if(now.subtract(duration).isAfter(lastUpdateTime)){
          reget = true;
        }
      }
    }
    if(reget){
      localGuide = await LocalGuideApi().getSimple(id: id);
      if(localGuide != null){
        await LocalStorageGuide().save(localGuide);
      }
    }
    return localGuide;
  }

}
