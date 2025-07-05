
import 'dart:io';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:freego_flutter/local_storage/model/local_friend.dart';
import 'package:freego_flutter/local_storage/util/local_friend_util.dart';
import 'package:freego_flutter/util/chinese_util.dart';
import 'package:freego_flutter/util/dictionary_util.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';

class FriendNaviController extends ChangeNotifier{
  int? idx;
  void jumpTo(int idx){
    this.idx = idx;
    notifyListeners();
  }
}

class FriendSearchController extends ChangeNotifier{
  String? keyword;
  void search(String keyword){
    this.keyword = keyword;
    notifyListeners();
  }
}

class FriendListWidget extends StatefulWidget{

  final bool Function(LocalFriendVo)? isSelected;
  final Function(LocalFriendVo)? onClick;
  final FriendNaviController? naviController;
  final FriendSearchController? searchController;

  const FriendListWidget({this.isSelected, this.onClick, this.naviController, this.searchController, super.key});

  @override
  State<StatefulWidget> createState() {
    return FriendListState();
  }
  
}

class FriendListState extends State<FriendListWidget>{

  static const double TITLE_HEIGHT = 40;
  static const double FRIEND_ITEM_HEIGHT = 48;

  List<LocalFriendVo> showedFriendList = [];
  List<LocalFriendVo> friendList = [];
  bool friendInited = false;

  GlobalKey parentKey = GlobalKey();
  Map<int, GlobalKey?> letterKeyMap = {};
  ScrollController scrollController = ScrollController();

  @override
  void dispose(){
    scrollController.dispose();
    widget.naviController?.removeListener(naviHandler);
    widget.searchController?.removeListener(searchHandler);
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    Future.delayed(Duration.zero, () async{
      List<LocalFriendVo> tmpList = await LocalFriendUitl().listIfEmpty(
        onFriendHeadDownload: (friend, count, total) async{
          if(count >= total){
            if(friend.userId == null){
              return;
            }
            LocalFriendVo? vo = await LocalFriendUitl().getVo(friend.userId!);
            if(vo == null){
              return;
            }
            for(LocalFriendVo friendVo in friendList){
              if(friendVo.id == vo.id){
                friendVo.friendHeadLocal = vo.friendHeadLocal;
                resetState();
                break;
              }
            }
          }
        },
      );
      friendList = tmpList;
      showedFriendList = friendList;
      friendInited = true;
      resetState();
    });
    if(widget.naviController != null){
      widget.naviController!.addListener(naviHandler);
    }
    if(widget.searchController != null){
      widget.searchController!.addListener(searchHandler);
    }
  }

  void searchHandler(){
    String? keyword = widget.searchController?.keyword;
    if(keyword == null){
      return;
    }
    showedFriendList = friendList.where((element){
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
    showedFriendList.sort((a, b){
      String aName = a.getShowName();
      String bName = b.getShowName();
      return aName.compareTo(bName);
    });
    List<List<LocalFriendVo>> classifiedLists = getAlphabeticList();
    List<Widget> widgets = [];
    bool firstNotEmpty = true;
    for(int i = 0; i < classifiedLists.length; ++i){
      List<LocalFriendVo> friendList = classifiedLists[i];
      if(friendList.isEmpty){
        continue;
      }
      if(firstNotEmpty){
        firstNotEmpty = false;
      }
      String title = i < 26 ? String.fromCharCode(i + 'A'.codeUnitAt(0)) : '#';
      List<Widget> friendWidgets = [];
      for(int j = 0; j < friendList.length; ++j){
        LocalFriendVo friend = friendList[j];
        friendWidgets.add(
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(10, 0, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: (){
                    widget.onClick?.call(friend);
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                    child: Row(
                      children: [
                        if(widget.isSelected != null)
                        Radio<LocalFriendVo>(
                          value: friend,
                          groupValue: widget.isSelected?.call(friend) == true ? friend : null,
                          toggleable: true,
                          onChanged: (val){
                            widget.onClick?.call(friend);
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
                        friend.friendHeadLocal != null ?
                        ClipOval(
                          child: SizedBox(
                            width: FRIEND_ITEM_HEIGHT,
                            height: FRIEND_ITEM_HEIGHT,
                            child: Image.file(
                              File(friend.friendHeadLocal!),
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
                          child: Text(StringUtil.getLimitedText(friend.getShowName(), DictionaryUtil.USERNAME_MAX_LENGTH), textAlign: TextAlign.right, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 18),),
                        )
                      ],
                    ),
                  ),
                ),
                if(friend != friendList.last)
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
                children: friendWidgets,
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

  List<List<LocalFriendVo>> getAlphabeticList(){
    List<List<LocalFriendVo>> lists = [];
    for(int i = 0; i <= 26; ++i){
      lists.add([]);
    }
    for(LocalFriendVo friend in showedFriendList){
      String showName = friend.getShowName();
      int idx = ChineseUtil().getCodeForChinese(showName);
      lists[idx].add(friend);
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

extension LocalFriendVoExt on LocalFriendVo{

  String getShowName(){
    if(friendRemark != null && friendRemark != ''){
      return friendRemark!;
    }
    if(friendName != null){
      return friendName!;
    }
    return '';
  }
}
