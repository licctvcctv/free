
import 'package:freego_flutter/local_storage/model/local_group.dart';
import 'package:freego_flutter/mixin/listeners_mixin.dart';

class GroupHelper with ListenersMixin<GroupMetaChangeListener>{

  GroupHelper._internal();
  static final GroupHelper _instance = GroupHelper._internal();
  factory GroupHelper(){
    return _instance;
  }

}

abstract class GroupMetaChangeListener{

  void handle(LocalGroup group);
}
