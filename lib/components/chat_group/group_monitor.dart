
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/local_storage/model/local_group.dart';
import 'package:freego_flutter/local_storage/model/local_group_room.dart';
import 'package:freego_flutter/util/theme_util.dart';

class GroupMonitorPage extends StatelessWidget{
  final LocalGroup group;
  final LocalGroupRoomVo room;
  const GroupMonitorPage({required this.group, required this.room, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 10,
        backgroundColor: ThemeUtil.backgroundColor,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      body: GroupMonitorWidget(group: group, room: room),
    );
  }
  
}

class GroupMonitorWidget extends StatefulWidget{
  final LocalGroup group;
  final LocalGroupRoomVo room;
  const GroupMonitorWidget({required this.group, required this.room, super.key});

  @override
  State<StatefulWidget> createState() {
    return GroupMonitorState();
  }
  
}

class GroupMonitorState extends State<GroupMonitorWidget>{
  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeUtil.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonHeader(
            center: Text(widget.room.getShowName(), style: const TextStyle(color: Colors.white, fontSize: 18),),
          ),

        ],
      ),
    );
  }
  
}

extension _LocalGroupRoomVoExt on LocalGroupRoomVo{
  String getShowName(){
    if(groupRemark != null && groupRemark != ''){
      return groupRemark!;
    }
    if(groupName != null){
      return groupName!;
    }
    return '';
  }
}