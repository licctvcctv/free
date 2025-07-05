
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/friend_neo/friend_home.dart';
import 'package:freego_flutter/components/friend_neo/friend_http.dart';
import 'package:freego_flutter/components/friend_neo/friend_storage.dart';
import 'package:freego_flutter/components/view/alphabetic_navi.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/notify_loading.dart';
import 'package:freego_flutter/components/view/search_bar.dart';
import 'package:freego_flutter/components/friend_neo/user_friend.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';

class FriendChoosePage extends StatelessWidget{
  const FriendChoosePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 10,
        backgroundColor: ThemeUtil.backgroundColor,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: const FriendChooseWidget(),
      ),
    );
  }
  
}

class FriendChooseWidget extends StatefulWidget{
  const FriendChooseWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return FriendChooseState();
  }
}

class FriendChooseState extends State<FriendChooseWidget>{

  List<UserFriend> friendList = [];
  bool inited = false;

  int? focused;
  List<UserFriend> showedFriendList = [];

  AlphabeticNaviController naviController = AlphabeticNaviController();
  FriendListController friendListController = FriendListController();

  @override
  void dispose(){
    naviController.dispose();
    friendListController.dispose();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
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
        if(context.mounted){
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
        Navigator.of(context).pop(friend);
      },
    );
  }
}
