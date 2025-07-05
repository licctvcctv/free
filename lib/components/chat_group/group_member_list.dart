
import 'dart:io';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/chat_group/pojo/group_member_role.dart';
import 'package:freego_flutter/local_storage/model/local_group.dart';
import 'package:freego_flutter/local_storage/model/local_group_member.dart';
import 'package:freego_flutter/local_storage/util/local_group_member_util.dart';
import 'package:freego_flutter/util/chinese_util.dart';
import 'package:freego_flutter/util/dictionary_util.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';

class GroupMemberNaviController extends ChangeNotifier{
  int? idx;
  void jumpTo(int idx){
    this.idx = idx;
    notifyListeners();
  }
}

class GroupMemberSearchController extends ChangeNotifier{
  String? keyword;
  void search(String keyword){
    this.keyword = keyword;
    notifyListeners();
  }
}

class GroupMemberListWidget extends StatefulWidget{
  final LocalGroup group;

  final bool Function(LocalGroupMemberVo)? isSelected;
  final Function(LocalGroupMemberVo)? onClick;
  final GroupMemberNaviController? naviController;
  final GroupMemberSearchController? searchController;

  const GroupMemberListWidget({required this.group, this.isSelected, this.onClick, this.naviController, this.searchController, super.key});

  @override
  State<StatefulWidget> createState() {
    return GroupMemberListState();
  }
  
}

class GroupMemberListState extends State<GroupMemberListWidget>{

  static const double TITLE_HEIGHT = 40;
  static const double FRIEND_ITEM_HEIGHT = 48;

  List<LocalGroupMemberVo> members = [];

  List<LocalGroupMemberVo> showMonitors = [];
  List<LocalGroupMemberVo> showNoMonitors = [];

  GlobalKey parentKey = GlobalKey();
  Map<int, GlobalKey?> letterKeyMap = {};
  ScrollController scrollController = ScrollController();

  @override
  void initState(){
    super.initState();
    Future.delayed(Duration.zero, () async{
      int? groupId = widget.group.id;
      if(groupId == null){
        return;
      }
      List<LocalGroupMemberVo> list = await LocalGroupMemberUtil().listIfEmpty(groupId, onMemberHeadDownload: (member, count, total) async{
        if(count >= total){
          for(LocalGroupMemberVo localMember in members){
            if(localMember.memberId == member.memberId){
              int? memberId = localMember.memberId;
              if(memberId != null){
                LocalGroupMemberVo? vo = await LocalGroupMemberUtil().getVo(groupId, memberId);
                if(vo != null){
                  localMember.memberHeadLocalPath = vo.memberHeadLocalPath;
                  resetState();
                }
              }
              break;
            }
          }
        }
      });
      members = list;
      resetState();
      handleSearch();
    });
    if(widget.naviController != null){
      widget.naviController!.addListener(naviHandler);
    }
    if(widget.searchController != null){
      widget.searchController!.addListener(handleSearch);
    }
  }

  void naviHandler(){
    int? idx = widget.naviController?.idx;
    if(idx == null){
      return;
    }
    GlobalKey? childKey = letterKeyMap[idx];
    if(childKey == null){
      return;
    }
    RenderBox? parentBox = parentKey.currentContext?.findRenderObject() as RenderBox?;
    if(parentBox == null){
      return;
    }
    RenderBox? childBox = childKey.currentContext?.findRenderObject() as RenderBox?;
    if(childBox == null){
      return;
    }
    double parentY = parentBox.localToGlobal(Offset.zero).dy;
    double childY = childBox.localToGlobal(Offset.zero).dy;
    double targetPos = childY - parentY + scrollController.offset;
    if(targetPos > scrollController.position.maxScrollExtent){
      targetPos = scrollController.position.maxScrollExtent;
    }
    scrollController.jumpTo(targetPos);
  }

  void handleSearch(){
    String keyword = widget.searchController?.keyword ?? '';
    showMonitors = [];
    showNoMonitors = [];
    for(LocalGroupMemberVo member in members){
      if(!member.getShowName().contains(keyword)){
        continue;
      }
      MemberRole? role = MemberRoleExt.getRole(member.memberRole ?? '');
      if(role == MemberRole.ownner || role == MemberRole.monitor){
        showMonitors.add(member);
      }
      else{
        showNoMonitors.add(member);
      }
    }
    showMonitors.sort((a, b){
      MemberRole? roleA = MemberRoleExt.getRole(a.memberRole ?? '');
      if(roleA == MemberRole.ownner){
        return - 1;
      }
      String nameA = a.getShowName();
      String nameB = b.getShowName();
      return nameA.compareTo(nameB);
    });
    showNoMonitors.sort((a, b){
      String nameA = a.getShowName();
      String nameB = b.getShowName();
      return nameA.compareTo(nameB);
    });
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    List<List<LocalGroupMemberVo>> classifiedLists = getAlphabeticList();
    List<Widget> widgets = [];
    if(showMonitors.isNotEmpty){
      const String title = '管理员';
      List<Widget> memberWidgets = [];
      for(int i = 0; i < showMonitors.length; ++i){
        LocalGroupMemberVo member = showMonitors[i];
        memberWidgets.add(
          getMemberWiget(member, member != showMonitors.last)
        );
      }
      widgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: TITLE_HEIGHT,
              margin: const EdgeInsets.only(left: TITLE_HEIGHT * 0.2),
              alignment: Alignment.centerLeft,
              child: const Text(title, style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 18),),
            ),
            Container(
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(TITLE_HEIGHT * 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4
                  )
                ]
              ),
              child: Column(
                children: memberWidgets,
              ),
            )
          ],
        )
      );
    }
    bool firstNotEmpty = true;
    for(int i = 0; i < classifiedLists.length; ++i){
      List<LocalGroupMemberVo> memberList = classifiedLists[i];
      if(memberList.isEmpty){
        continue;
      }
      if(firstNotEmpty){
        firstNotEmpty = false;
      }
      String title = i < 26 ? String.fromCharCode(i + 'A'.codeUnitAt(0)) : '#';
      List<Widget> memberWidgets = [];
      for(int j = 0; j < memberList.length; ++j){
        LocalGroupMemberVo member = memberList[j];
        memberWidgets.add(
          getMemberWiget(member, member != memberList.last)
        );
      }
      GlobalKey key = GlobalKey();
      letterKeyMap[i] = key;
      widgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: TITLE_HEIGHT,
              margin: const EdgeInsets.only(left: TITLE_HEIGHT * 0.2),
              alignment: Alignment.centerLeft,
              child: Text(title, style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 18),),
            ),
            Container(
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(TITLE_HEIGHT * 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4
                  )
                ]
              ),
              child: Column(
                children: memberWidgets,
              ),
            )
          ],
        )
      );
    }
    return SingleChildScrollView(
      key: parentKey,
      controller: scrollController,
      padding: EdgeInsets.zero,
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
    );
  }

  Widget getMemberWiget(LocalGroupMemberVo member, [bool withDottedLine = false]){
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(10, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: (){
              widget.onClick?.call(member);
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
              child: Row(
                children: [
                  if(widget.isSelected != null)
                  Radio<LocalGroupMemberVo>(
                    value: member,
                    groupValue: widget.isSelected?.call(member) == true ? member : null,
                    toggleable: true,
                    onChanged: (val){
                      widget.onClick?.call(member);
                    },
                    fillColor: MaterialStateProperty.resolveWith((states){
                      if(states.contains(MaterialState.selected)){
                        return Colors.black;
                      }
                      else{
                        return const Color.fromRGBO(0, 0, 0, 0.6);
                      }
                    })
                  ),
                  member.memberHeadLocalPath != null ?
                  ClipOval(
                    child: SizedBox(
                      width: FRIEND_ITEM_HEIGHT,
                      height: FRIEND_ITEM_HEIGHT,
                      child: Image.file(
                        File(member.memberHeadLocalPath!),
                        fit: BoxFit.cover,
                        errorBuilder:(context, error, stackTrace) {
                          return const ColoredBox(color: Colors.grey);
                        },
                      ),
                    ),
                  ) :
                  const CircleAvatar(
                    radius: FRIEND_ITEM_HEIGHT / 2,
                    backgroundImage: ThemeUtil.defaultUserHeadProvider
                  ),
                  Expanded(
                    child: Text(StringUtil.getLimitedText(member.getShowName(), DictionaryUtil.USERNAME_MAX_LENGTH), textAlign: TextAlign.right, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 18),),
                  )
                ],
              ),
            ),
          ),
          if(withDottedLine)
          const DottedLine(
            dashColor: ThemeUtil.dividerColor,
          ),
        ],
      ),
    );
  }

  List<List<LocalGroupMemberVo>> getAlphabeticList(){
    List<List<LocalGroupMemberVo>> lists = [];
    for(int i = 0; i <= 26; ++i){
      lists.add([]);
    }
    for(LocalGroupMemberVo member in showNoMonitors){
      String showName = member.getShowName();
      int idx = ChineseUtil().getCodeForChinese(showName);
      lists[idx].add(member);
    }
    return lists;
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
    if(memberRemark != null && memberRemark!.isNotEmpty){
      return memberRemark!;
    }
    return memberName ?? '';
  }
}
