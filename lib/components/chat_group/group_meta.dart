
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:freego_flutter/components/chat_group/group_members.dart';
import 'package:freego_flutter/components/chat_group/group_meta_group_remark.dart';
import 'package:freego_flutter/components/chat_group/helper/group_helper.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/local_storage/model/local_group.dart';
import 'package:freego_flutter/local_storage/model/local_group_member.dart';
import 'package:freego_flutter/local_storage/model/local_group_room.dart';
import 'package:freego_flutter/local_storage/util/local_group_member_util.dart';
import 'package:freego_flutter/local_storage/util/local_group_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/user_home_director.dart';

class GroupMetaPage extends StatelessWidget{
  final LocalGroup group;
  final LocalGroupRoomVo room;
  const GroupMetaPage({required this.group, required this.room, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 10,
        backgroundColor: ThemeUtil.backgroundColor,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      body: GroupMetaWidget(group: group, room: room),
    );
  }
  
}

class GroupMetaWidget extends StatefulWidget{
  final LocalGroup group;
  final LocalGroupRoomVo room;
  const GroupMetaWidget({required this.group, required this.room, super.key});

  @override
  State<StatefulWidget> createState() {
    return GroupMetaState();
  }
  
}

class _MyGroupMetaChangeListener extends GroupMetaChangeListener{

  final GroupMetaState _state;
  _MyGroupMetaChangeListener(this._state);

  @override
  void handle(LocalGroup group) async{
    if(group.id == null){
      return;
    }
    if(group.id == _state.widget.group.id){
      LocalGroup? savedGroup = await LocalGroupUtil().get(group.id!);
      if(savedGroup == null){
        return;
      }
      _state.widget.group.clone(savedGroup);
      _state.resetState();
    }
  }
  
}

class GroupMetaState extends State<GroupMetaWidget>{

  List<LocalGroupMemberVo> members = [];

  late _MyGroupMetaChangeListener _myGroupMetaChangeListener;

  @override
  void dispose(){
    GroupHelper().removeListener(_myGroupMetaChangeListener);
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    Future.delayed(Duration.zero, () async{
      int? groupId = widget.room.groupId;
      if(groupId == null){
        return;
      }
      members = await LocalGroupMemberUtil().listIfEmpty(groupId, onMemberHeadDownload: ((member, count, total) async{
        if(count >= total){
          for(LocalGroupMemberVo localMember in members){
            if(localMember.id == member.id){
              if(member.memberId != null){
                LocalGroupMemberVo? vo = await LocalGroupMemberUtil().getVo(groupId, member.memberId!);
                if(vo != null){
                  localMember.memberHeadLocalPath = vo.memberHeadLocalPath;
                  resetState();
                }
              }
              break;
            }
          }
        }
      }));
      resetState();
    });
    _myGroupMetaChangeListener = _MyGroupMetaChangeListener(this);
    GroupHelper().addListener(_myGroupMetaChangeListener);
  }

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
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              physics: const ClampingScrollPhysics(),
              children: [
                const SizedBox(height: 20,),
                getAvatarWidget(),
                const SizedBox(height: 20,),
                getNameWidget(),
                const SizedBox(height: 10,),
                getRemarkWidget(),
                const SizedBox(height: 10,),
                getAnnounceWidget(),
                const SizedBox(height: 10,),
                getDescriptionWidget(),
                const SizedBox(height: 10,),
                getMembersWidget(),
                const SizedBox(height: 10,),
                getQuitWidget()
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget getQuitWidget(){
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        decoration: const BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.all(Radius.circular(4))
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: const Text('退出群聊', style: TextStyle(color: Colors.white, fontSize: 18),),
      ),
    );
  }

  void goMembers(){
    Navigator.of(context).push(MaterialPageRoute(builder: (context){
      return GroupMembersPage(group: widget.group,);
    }));
  }

  Widget getMembersWidget(){
    const double memberSize = 70;
    List<Widget> memberWidgets = [];
    if(members.isNotEmpty){
      for(int i = 0; i < 5; ++i){
        LocalGroupMemberVo member = members[i];
        memberWidgets.add(
          InkWell(
            onTap: (){
              if(member.memberId == null){
                return;
              }
              UserHomeDirector().goUserHome(context: context, userId: member.memberId!);
            },
            child: Column(
              children: [
                member.memberHeadLocalPath != null ?
                ClipOval(
                  child: SizedBox(
                    width: memberSize,
                    height: memberSize,
                    child: Image.file(
                      File(member.memberHeadLocalPath!),
                      fit: BoxFit.cover,
                      errorBuilder:(context, error, stackTrace) {
                        return const ColoredBox(color: Colors.grey);
                      },
                    ),
                  ),
                ) :
                CircleAvatar(
                  radius: memberSize / 2,
                  child: ThemeUtil.defaultUserHead,
                ),
                const SizedBox(height: 10,),
                SizedBox(
                  width: memberSize,
                  child: Text(
                    member.getShowName(),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              ],
            ),
          )
        ); 
        if(member == members.last){
          break;
        }
      }
      if(members.length > 5){
        memberWidgets.add(
          InkWell(
            onTap: goMembers,
            child: const SizedBox(
              width: memberSize,
              height: memberSize,
              child: Align(
                alignment: Alignment.center,
                child: Icon(Icons.more_horiz_outlined, size: 20,),
              ),
            ),
          )
        );
      }
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('群成员', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 18),),
              ),
              InkWell(
                onTap: goMembers,
                child: Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  child: const Icon(Icons.arrow_forward_ios, color: ThemeUtil.foregroundColor, size: 20,),
                ),
              )
            ],
          ),
          const SizedBox(height: 10,),
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: memberWidgets,
            ),
          )
        ],
      ),
    );
  }

  Widget getDescriptionWidget(){
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('群介绍', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 18),),
          const SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.all(10),
            child: widget.group.description == null || widget.group.description!.trim().isEmpty ?
            const Text('未设置', textAlign: TextAlign.end, style: TextStyle(color: Colors.grey, fontSize: 16),) :
            Text(widget.group.description!, style: const TextStyle(color: Colors.grey, fontSize: 16),)
          )
        ],
      ),
    );
  }

  Widget getAnnounceWidget(){
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('群公告', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 18),),
          const SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.all(10),
            child: widget.group.announce == null ?
            const Text('未设置', textAlign: TextAlign.end, style: TextStyle(color: Colors.grey, fontSize: 16),) :
            Text(widget.group.announce!, style: const TextStyle(color: Colors.grey, fontSize: 16),)
          )
        ],
      ),
    );
  }

  Widget getRemarkWidget(){
    return Container(
      height: 60,
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12))
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Text('群内昵称', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 18),),
          ),
          Expanded(
            child: Text(
              widget.room.memberRemark ?? '未设置',
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 18
              ),
            ),
          ),
          const SizedBox(width: 10,),
          InkWell(
            onTap: (){

            },
            child: const Icon(Icons.arrow_forward_ios, color: ThemeUtil.foregroundColor, size: 20,),
          )
        ]
      ),
    );
  }
  
  Widget getNameWidget(){
    return Container(
      height: 60,
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12))
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Text('名称', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 18),),
          ),
          Expanded(
            child: InkWell(
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                  return GroupMetaGroupRemarkPage(group: widget.group, room: widget.room,);
                }));
              },
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.room.getShowName(),
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 18
                      ),
                    ),
                  ),
                  const SizedBox(width: 10,),
                  const Icon(Icons.arrow_forward_ios, color: ThemeUtil.foregroundColor, size: 20),
                ],
              ),
            ),
          ),
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

  void resetState(){
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }
}

extension _LocalGroupMemberVoExt on LocalGroupMemberVo{
  String getShowName(){
    if(memberRemark != null && memberRemark != ''){
      return memberRemark!;
    }
    if(memberName != null){
      return memberName!;
    }
    return '';
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
