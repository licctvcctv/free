
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:freego_flutter/components/chat_group/helper/group_room_helper.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/local_storage/model/local_group.dart';
import 'package:freego_flutter/local_storage/model/local_group_room.dart';
import 'package:freego_flutter/util/dictionary_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';

class GroupMetaGroupRemarkPage extends StatelessWidget{
  final LocalGroup group;
  final LocalGroupRoomVo room;
  const GroupMetaGroupRemarkPage({required this.group, required this.room, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 10,
        backgroundColor: ThemeUtil.backgroundColor,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      body: GroupMetaGroupRemarkWidget(group: group, room: room),
    );
  }
  
}

class GroupMetaGroupRemarkWidget extends StatefulWidget{
  final LocalGroup group;
  final LocalGroupRoomVo room;
  const GroupMetaGroupRemarkWidget({required this.group, required this.room, super.key});

  @override
  State<StatefulWidget> createState() {
    return GroupMetaGroupRemarkState();
  }
  
}

class GroupMetaGroupRemarkState extends State<GroupMetaGroupRemarkWidget>{

  TextEditingController remarkController = TextEditingController();

  @override
  void initState(){
    super.initState();
    remarkController.text = widget.room.getShowName();
  }

  @override
  void dispose(){
    remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Container(
        color: ThemeUtil.backgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonHeader(
              center: Text(widget.room.getShowName(), style: const TextStyle(color: Colors.white, fontSize: 18),),
            ),
            const SizedBox(height: 20,),
            getAvatarWidget(),
            const SizedBox(height: 20,),
            getInputWidget(),
            const Expanded(
              child: SizedBox(height: 20,),
            ),
            getSubmitWidget(),
            const SizedBox(height: 20,),
          ],
        ),
      ),
    );
  }

  Widget getSubmitWidget(){
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: InkWell(
        onTap: (){
          int? id = widget.room.id;
          if(id == null){
            return;
          }
          GroupRoomHelper().update(id: id, groupRemark: remarkController.text.trim(), fail: (response){
            String message = response.data['message'] ?? '操作失败';
            ToastUtil.error(message);
          }, success: (response){
            ToastUtil.hint('修改成功');
            Timer.periodic(const Duration(seconds: 3), (timer) { 
              timer.cancel();
              if(mounted && context.mounted){
                Navigator.of(context).pop();
              }
            });
          });
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          decoration: const BoxDecoration(
            color: ThemeUtil.buttonColor,
            borderRadius: BorderRadius.all(Radius.circular(4))
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: const Text('修改', style: TextStyle(color: Colors.white, fontSize: 18),),
        ),
      ),
    );
  }

  Widget getInputWidget(){
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('*修改群备注名', style: TextStyle(color: Colors.grey, fontSize: 16),),
          const SizedBox(height: 20,),
          Container(
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4
                )
              ]
            ),
            alignment: Alignment.center,
            child: TextField(
              controller: remarkController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.fromLTRB(10, 4, 8, 4),
                counterText: '',
                hintText: '群备注名',
                hintStyle: TextStyle(color: Colors.grey)
              ),
              maxLength: DictionaryUtil.GROUP_NAME_MAX_LENGTH,
              style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 18),
            )
          )
        ],
      ),
    );
  }
  
  Widget getAvatarWidget(){
    const double size = 100;
    return Container(
      alignment: Alignment.center,
      child: widget.group.avatarLocalPath != null ?
      ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          child: Image.file(
            File(widget.group.avatarLocalPath!),
            fit: BoxFit.cover,
            errorBuilder:(context, error, stackTrace) {
              return const ColoredBox(color: Colors.grey);
            },
          ),
        ),
      ) :
      const CircleAvatar(
        radius: size / 2,
        backgroundImage: ThemeUtil.defaultGroupAvatarProvider,
      )
    );
  }
}

extension _LocalGroupVoExt on LocalGroupRoomVo{

  String getShowName(){
    if(groupRemark != null && groupRemark!.isNotEmpty){
      return groupRemark!;
    }
    return groupName ?? '';
  }
}
