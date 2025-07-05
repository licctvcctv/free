
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/chat_neo/chat_common.dart';
import 'package:freego_flutter/components/chat_neo/chat_room.dart';
import 'package:freego_flutter/components/chat_neo/chat_util.dart';
import 'package:freego_flutter/components/friend_neo/friend_http.dart';
import 'package:freego_flutter/components/friend_neo/friend_storage.dart';
import 'package:freego_flutter/components/view/alphabetic_navi.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/notify_loading.dart';
import 'package:freego_flutter/components/view/search_bar.dart';
import 'package:freego_flutter/components/friend_neo/user_friend.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/util/dictionary_util.dart';
import 'package:freego_flutter/util/route_observer.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:lpinyin/lpinyin.dart';

class FriendHomePage extends StatefulWidget{
  const FriendHomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return FriendHomePageState();
  }
  
}

class FriendHomePageState extends State<FriendHomePage> with RouteAware{

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    RouteObserverUtil().routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose(){
    RouteObserverUtil().routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush(){
    ThemeUtil.setStatusBarDark();
  }

  @override
  void didPopNext(){
    ThemeUtil.setStatusBarDark();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 10,
        backgroundColor: ThemeUtil.backgroundColor,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: const FriendHomeWidget(),
      ),
    );
  }

}

class FriendHomeWidget extends StatefulWidget{
  const FriendHomeWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return FriendHomeState();
  }

}

class FriendHomeState extends State<FriendHomeWidget> with SingleTickerProviderStateMixin, WidgetsBindingObserver{

  List<UserFriend> friendList = [];
  bool inited = false;

  int? focused;
  List<UserFriend> showedFriendList = [];

  AlphabeticNaviController naviController = AlphabeticNaviController();
  FriendListController friendListController = FriendListController();

  late AnimationController _keyboardAnim;

  @override
  void dispose(){
    naviController.dispose();
    friendListController.dispose();
    _keyboardAnim.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    _keyboardAnim = AnimationController(vsync: this, lowerBound: 0, upperBound: double.infinity);
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(Duration.zero, () async{
      List<UserFriend> savedFriend = await FriendStorage.getFriends();
      friendList = savedFriend;
      showedFriendList = friendList;
      inited = true;
      if(context.mounted){
        setState(() {
        });
      }
      List<UserFriend>? tmpList = await FriendHttp.getFriends();
      if(tmpList != null){
        friendList = tmpList;
        FriendStorage.saveFriends(tmpList);
        showedFriendList = friendList;
        if(mounted && context.mounted){
          setState(() {
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: ThemeUtil.backgroundColor,
          child: Column(
            children: [
              const CommonHeader(
                center: Text('我的好友', style: TextStyle(color: Colors.white),),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: SearchBar(
                  onSubmit: (val){
                    showedFriendList = friendList.where((element){
                      if(element.name?.contains(val) == true){
                        return true;
                      }
                      if(element.friendRemark?.contains(val) == true){
                        return true;
                      }
                      return false;
                    }).toList();
                    setState(() {
                    });
                  }
                ),
              ),
              Expanded(
                child: inited ?
                getFriendWidget() :
                const NotifyLoadingWidget()
              ),
              AnimatedBuilder(
                animation: _keyboardAnim,
                builder:(context, child) {
                  return Container(
                    height: _keyboardAnim.value,
                    color: ThemeUtil.backgroundColor,
                  );
                },
              )
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: AlphabeticNaviWidget(
            controller: naviController,
            onClickNavi: (idx){
              friendListController.jumpTo(idx);
            },
          ),
        )
      ],
    );
  }

  Widget getFriendWidget(){
    if(friendList.isEmpty){
      return Container(
        alignment: Alignment.center,
        child: const Text('你还没有好友', style: TextStyle(color: Colors.grey),),
      );
    }
    return FriendListWidget(
      showedFriendList,
      controller: friendListController,
      onTapFriend: (friend) async{
        if(friend.friendId == null){
          ToastUtil.error('目标已失效');
          return;
        }
        ImSingleRoom? room = await ChatUtilSingle.enterRoom(friend.friendId!);
        if(room == null){
          ToastUtil.error('目标已失效');
          return;
        }
        if(mounted && context.mounted){
          Navigator.of(context).push(MaterialPageRoute(builder: (context){
            return ChatRoomPage(room: room,);
          }));
        }
      },
    );
  }

  @override
  void didChangeMetrics(){
    super.didChangeMetrics();
    double keyboardHeight = EdgeInsets.fromWindowPadding(
      WidgetsBinding.instance.window.viewInsets, 
      WidgetsBinding.instance.window.devicePixelRatio).bottom;
    _keyboardAnim.value = keyboardHeight;
  }

}

class FriendListController extends ChangeNotifier{
  int? idx;
  void jumpTo(int idx){
    this.idx = idx;
    notifyListeners();
  }
}

class FriendListWidget extends StatefulWidget{
  final FriendListController? controller;
  final void Function(UserFriend)? onTapFriend;
  final List<UserFriend> friendList;
  const FriendListWidget(this.friendList, {this.onTapFriend, this.controller, super.key});

  @override
  State<StatefulWidget> createState() {
    return FriendListState();
  }

}

class FriendListState extends State<FriendListWidget>{

  static const double TITLE_HEIGHT = 72;
  static const double FRIEND_ITEM_HEIGHT = 60;

  late List<UserFriend> friendList;

  FriendHomeState? parentState;
  GlobalKey parentKey = GlobalKey();
  Map<int, GlobalKey?> letterKeyMap = {};
  ScrollController scrollController = ScrollController();

  @override
  void dispose(){
    scrollController.dispose();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    parentState = context.findAncestorStateOfType();
    if(widget.controller != null){
      widget.controller!.addListener(() {
        int? idx = widget.controller?.idx;
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    friendList = widget.friendList;
    friendList.sort((a, b){
      String aName = a.getShowName();
      String bName = b.getShowName();
      return aName.compareTo(bName);
    });
    List<List<UserFriend>> classifiedLists = getAlphabeticList();
    List<Widget> widgets = [];
    bool firstNotEmpty = true;
    for(int i = 0; i < classifiedLists.length; ++i){
      List<UserFriend> friendList = classifiedLists[i];
      if(friendList.isEmpty){
        continue;
      }
      if(firstNotEmpty){
        firstNotEmpty = false;
        parentState?.naviController.focus(i);
      }
      String title = i < 26 ? String.fromCharCode(i + 'A'.codeUnitAt(0)) : '#';
      List<Widget> friendWidgets = [];
      for(int j = 0; j < friendList.length; ++j){
        UserFriend friend = friendList[j];
        friendWidgets.add(
          Container(
            height: FRIEND_ITEM_HEIGHT,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: InkWell(
              onTap: (){
                widget.onTapFriend?.call(friend);
              },
              child: Row(
                children: [
                  ClipOval(
                    child: SizedBox(
                      width: FRIEND_ITEM_HEIGHT * 0.8,
                      height: FRIEND_ITEM_HEIGHT * 0.8,
                      child: friend.head == null ? 
                      ThemeUtil.defaultUserHead :
                      Image.network(getFullUrl(friend.head!), width: double.infinity, height: double.infinity, fit: BoxFit.fill,)
                    ),
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  Text(StringUtil.getLimitedText(friend.getShowName(), DictionaryUtil.USERNAME_MAX_LENGTH), style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold),)
                ],
              ),
            ),
          )
        );
        if(j < friendList.length - 1){
          friendWidgets.add(
            const Divider(color: Colors.black12,)
          );
        }
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

  List<List<UserFriend>> getAlphabeticList(){
    List<List<UserFriend>> lists = [];
    for(int i = 0; i <= 26; ++i){
      lists.add([]);
    }
    for(UserFriend friend in friendList){
      String showName = friend.getShowName();
      int idx = getCodeForChinese(showName);
      lists[idx].add(friend);
    }
    return lists;
  }

  int getCodeForChinese(String str){
    int code = str.codeUnitAt(0);
    if(code >= 'a'.codeUnitAt(0) && code <= 'z'.codeUnitAt(0)){
      return code - 'a'.codeUnitAt(0);
    }
    if(code >= 'A'.codeUnitAt(0) && code <= 'Z'.codeUnitAt(0)){
      return code - 'A'.codeUnitAt(0);
    }
    String py = PinyinHelper.getFirstWordPinyin(str);
    code = py.codeUnitAt(0);
    int result = code - 'a'.codeUnitAt(0);
    if(result >= 0 && result < 26){
      return result;
    }
    return 26;
  }
}

extension UserFriendExt on UserFriend{

  String getShowName(){
    if(friendRemark != null && friendRemark != ''){
      return friendRemark!;
    }
    if(name != null){
      return name!;
    }
    return '';
  }
}
