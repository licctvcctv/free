
import 'dart:io';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/chat_group/helper/group_helper.dart';
import 'package:freego_flutter/local_storage/model/local_group.dart';
import 'package:freego_flutter/local_storage/util/local_group_util.dart';
import 'package:freego_flutter/util/chinese_util.dart';
import 'package:freego_flutter/util/dictionary_util.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';

class GroupNaviController extends ChangeNotifier{
  int? idx;
  void jumpTo(int idx){
    this.idx = idx;
    notifyListeners();
  }
}

class GroupSearchController extends ChangeNotifier{
  String? keyword;
  void search(String keyword){
    this.keyword = keyword;
    notifyListeners();
  }
}

class GroupListWidget extends StatefulWidget{

  final bool Function(LocalGroup)? isSelected;
  final Function(LocalGroup)? onClick;
  final GroupNaviController? naviController;
  final GroupSearchController? searchController;

  const GroupListWidget({this.isSelected, this.onClick, this.naviController, this.searchController, super.key});

  @override
  State<StatefulWidget> createState() {
    return GroupListState();
  }
  
}

class _MyGroupMetaChangeListener extends GroupMetaChangeListener{

  final GroupListState _state;
  _MyGroupMetaChangeListener(this._state);

  @override
  void handle(LocalGroup group) async{
    if(group.id == null){
      return;
    }
    for(LocalGroup _group in _state.list){
      if(_group.id == group.id){
        LocalGroup? savedGroup = await LocalGroupUtil().get(group.id!);
        if(savedGroup != null){
          _group.clone(savedGroup);
          _state.resetState();
        }
        break;
      }
    }
  }
  
}

class GroupListState extends State<GroupListWidget>{

  static const double TITLE_HEIGHT = 40;
  static const double GROUP_ITEM_HEIGHT = 48;

  List<LocalGroup> list = [];
  List<LocalGroup> showList = [];
  bool groupInited = false;

  GlobalKey parentKey = GlobalKey();
  Map<int, GlobalKey?> letterKeyMap = {};
  ScrollController scrollController = ScrollController();

  late _MyGroupMetaChangeListener _myGroupMetaChangeHandler;

  @override
  void dispose(){
    widget.naviController?.removeListener(naviHandler);
    widget.searchController?.removeListener(searchHandler);
    scrollController.dispose();
    GroupHelper().removeListener(_myGroupMetaChangeHandler);
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    Future.delayed(Duration.zero, () async{
      list = await LocalGroupUtil().listIfEmpty(onGroupAvatarDownload: (group, count, total) async{
        if(count >= total){
          if(group.id == null){
            return;
          }
          LocalGroup? localGroup = await LocalGroupUtil().get(group.id!);
          if(localGroup == null){
            return;
          }
          for(LocalGroup group in list){
            if(group.id == localGroup.id){
              group.avatarLocalPath = localGroup.avatarLocalPath;
              resetState();
              break;
            }
          }
        }
      });
      showList = list;
      groupInited = true;
      resetState();
    });
    if(widget.naviController != null){
      widget.naviController!.addListener(naviHandler);
    }
    if(widget.searchController != null){
      widget.searchController!.addListener(searchHandler);
    }
    _myGroupMetaChangeHandler = _MyGroupMetaChangeListener(this);
    GroupHelper().addListener(_myGroupMetaChangeHandler);
  }

  void searchHandler(){
    String? keyword = widget.searchController?.keyword;
    if(keyword == null){
      return;
    }
    showList = list.where((element){
      return element.getShowName().contains(keyword);
    }).toList();
    resetState();
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

  @override
  Widget build(BuildContext context) {
    showList.sort((a, b){
      String aName = a.getShowName();
      String bName = b.getShowName();
      return aName.compareTo(bName);
    });
    List<List<LocalGroup>> classifiedLists = getAlphabeticList();
    List<Widget> widgets = [];
    bool firstNotEmpty = true;
    for(int i = 0; i < classifiedLists.length; ++i){
      List<LocalGroup> groupList = classifiedLists[i];
      if(groupList.isEmpty){
        continue;
      }
      if(firstNotEmpty){
        firstNotEmpty = false;
      }
      String title = i < 26 ? String.fromCharCode(i + 'A'.codeUnitAt(0)) : '#';
      List<Widget> groupWidgets = [];
      for(int j = 0; j < groupList.length; ++j){
        LocalGroup group = groupList[j];
        groupWidgets.add(
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(10, 0, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: (){
                    widget.onClick?.call(group);
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                    child: Row(
                      children: [
                        if(widget.isSelected != null)
                        Radio<LocalGroup>(
                          value: group,
                          groupValue: widget.isSelected?.call(group) == true ? group : null,
                          toggleable: true,
                          onChanged: (val){
                            widget.onClick?.call(group);
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
                        group.avatarLocalPath != null ?
                        ClipOval(
                          child: SizedBox(
                            width: GROUP_ITEM_HEIGHT,
                            height: GROUP_ITEM_HEIGHT,
                            child: Image.file(
                              File(group.avatarLocalPath!),
                              fit: BoxFit.cover,
                              errorBuilder:(context, error, stackTrace) {
                                return const ColoredBox(color: Colors.grey);
                              },
                            ),
                          ),
                        ) :
                        const CircleAvatar(
                          radius: GROUP_ITEM_HEIGHT / 2,
                          backgroundImage: ThemeUtil.defaultGroupAvatarProvider
                        ),
                        Expanded(
                          child: Text(StringUtil.getLimitedText(group.getShowName(), DictionaryUtil.GROUP_NAME_MAX_LENGTH), textAlign: TextAlign.right, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 18),),
                        )
                      ],
                    ),
                  ),
                ),
                if(group != groupList.last)
                const DottedLine(
                  dashColor: ThemeUtil.dividerColor,
                ),
              ],
            ),
          )
        );
      }
      GlobalKey key = GlobalKey();
      letterKeyMap[i] = key;
      widgets.add(
        Column(
          key: key,
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
                children: groupWidgets,
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

  List<List<LocalGroup>> getAlphabeticList(){
    List<List<LocalGroup>> lists = [];
    for(int i = 0; i <= 26; ++i){
      lists.add([]);
    }
    for(LocalGroup group in showList){
      String showName = group.getShowName();
      int idx = ChineseUtil().getCodeForChinese(showName);
      lists[idx].add(group);
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

extension LocalGroupVoExt on LocalGroup{
  String getShowName(){
    if(remark != null && remark != ''){
      return remark!;
    }
    if(name != null){
      return name!;
    }
    return '';
  }
}
