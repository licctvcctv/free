
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/friend_neo/friend_common.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/notify_empty.dart';
import 'package:freego_flutter/components/view/search_bar.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/http/http_tool.dart';
import 'package:freego_flutter/util/dictionary_util.dart';
import 'package:freego_flutter/util/local_user.dart';
import 'package:freego_flutter/util/regular_util.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';

import 'friend_http.dart';

class FriendAddPage extends StatefulWidget{
  const FriendAddPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return FriendAddPageState();
  }
  
}

class FriendAddPageState extends State<FriendAddPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 20,
        elevation: 0,
        backgroundColor: ThemeUtil.backgroundColor,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
        automaticallyImplyLeading: false,
      ),
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        //behavior: HitTestBehavior.translucent,
        behavior: HitTestBehavior.opaque,
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: const FriendAddWidget(),
      ),
    );
  }

}

class FriendAddWidget extends StatefulWidget{
  const FriendAddWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return FriendAddState();
  }

}

class FriendAddState extends State<FriendAddWidget>{

  static const double CONTENT_PADDINT_TOP = 20;
  static const double FRIEND_ITEM_HEIGHT = 60;
  bool searched = false;
  List<SimpleUser> userList = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      color: ThemeUtil.backgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonHeader(
            backgroundColor: ThemeUtil.backgroundColor,
            left: Container(
              width: 48,
              alignment: Alignment.center,
              child: IconButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_ios_new, color: ThemeUtil.foregroundColor,),
              ),
            ),
            center: SimpleSearchBar(
              hasButton: false,
              onSumbit: search,
              onBlur: search,
              backgroundColor: Colors.grey[200],
              hintText: '请输入手机号',
            ),
          ),
          const SizedBox(height: CONTENT_PADDINT_TOP,),
          userList.isEmpty && searched ?
          const NotifyEmptyWidget() :
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(FRIEND_ITEM_HEIGHT * 0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4
                )
              ]
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: getSearchResultWidgets(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> getSearchResultWidgets(){
    List<Widget> widgets = [];
    for(SimpleUser user in userList){
      widgets.add(
        Container(
          height: FRIEND_ITEM_HEIGHT,
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Row(
            children: [
              ClipOval(
                child: SizedBox(
                  width: FRIEND_ITEM_HEIGHT,
                  height: FRIEND_ITEM_HEIGHT,
                  child: user.head == null ?
                  ThemeUtil.defaultUserHead :
                  Image.network(getFullUrl(user.head!), width: double.infinity, height: double.infinity, fit: BoxFit.fill,)
                ),
              ),
              const SizedBox(
                width: 6,
              ),
              Text(StringUtil.getLimitedText(user.name ?? '', DictionaryUtil.USERNAME_MAX_LENGTH), style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold),),
              const Expanded(child: SizedBox()),
              TextButton(
                onPressed: (){
                  showGeneralDialog(
                    context: context, 
                    barrierColor: Colors.transparent,
                    barrierLabel: "",
                    barrierDismissible: true,
                    transitionDuration: const Duration(milliseconds: 350),
                    transitionBuilder: (context, animation, secondaryAnimation, child){
                      return Transform.scale(
                        scaleY: animation.value,
                        child: child,
                      );
                    },
                    pageBuilder: (context, anim, anim2){
                      return FriendApplyWidget(user);
                    }
                  );
                }, 
                child: const Text('添加')
              )
            ],
          ),
        )
      );
    }
    return widgets;
  }

  Future search(String keyword) async{
    if(!RegularUtil.checkPhone(keyword)){
      ToastUtil.error('手机号格式错误');
      return;
    }
    SimpleUser? user = await FriendHttp.searchUserByPhone(keyword);
    searched = true;
    if(user != null){
      userList = [user];
    }
    else{
      userList = [];
    }
    if(context.mounted){
      setState(() {
      });
    }
  }
}

class FriendApplyWidget extends StatefulWidget{
  final SimpleUser user;
  const FriendApplyWidget(this.user, {super.key});

  @override
  State<StatefulWidget> createState() {
    return FriendApplyState();
  }

}

class FriendApplyState extends State<FriendApplyWidget>{

  static const double PADDING_TOP = 50;
  static const double AVATAR_SIZE = 80;
  static const double BACKUP_HEIGHT = 50;
  static const double BACKUP_PADDING_VERTICAL = 50;
  static const double SUBMIT_HEIGHT = 50;
  static const double SUBMIT_WIDTH = 200;

  TextEditingController textController = TextEditingController();

  @override
  void initState(){
    super.initState();
    String? localUserName = LocalUser.getUser()?.name;
    if(localUserName != null){
      textController.text = '我是$localUserName';
    }
  }

  @override
  void dispose(){
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SimpleUser user = widget.user;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Material(
          child: Container(
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4
                )
              ]
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: Container(
                width: 400,
                height: 400,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: PADDING_TOP,),
                    ClipOval(
                      child: SizedBox(
                        width: AVATAR_SIZE,
                        height: AVATAR_SIZE,
                        child: user.head == null ?
                        ThemeUtil.defaultUserHead :
                        Image.network(getFullUrl(user.head!), width: double.infinity, height: double.infinity, fit: BoxFit.fill,)
                      ),
                    ),
                    const SizedBox(height: 10,),
                    Text(user.name ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16, decoration: TextDecoration.none),),
                    const SizedBox(height: 40,),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(BACKUP_PADDING_VERTICAL, 0, BACKUP_PADDING_VERTICAL, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('备注信息：', style: TextStyle(color: Colors.grey),),
                          const SizedBox(height: 10,),
                          Container(
                            height: BACKUP_HEIGHT,
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
                            child: TextField(
                              controller: textController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.all(4),
                                counterText: '',
                              ),
                              maxLength: DictionaryUtil.FRIEND_APPLY_BACKUP_MAX_LENGTH,
                              style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 15),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 40,),
                    Column(
                      children: [
                        SizedBox(
                          width: SUBMIT_WIDTH,
                          height: SUBMIT_HEIGHT,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              backgroundColor: Colors.lightBlue,
                            ),
                            onPressed: (){
                              if(user.id == null){
                                ToastUtil.error('目标错误');
                                return;
                              }
                              FriendHttp.friendApply(user.id!, textController.text, fail: (response){
                                int? code = response.data['code'];
                                switch(code){
                                  case ResultCode.RES_CREATED:
                                    ToastUtil.warn('您与对方已经是朋友');
                                    return;
                                  case ResultCode.RES_DOING:
                                    ToastUtil.warn('您的好友申请正在处理中');
                                    return;
                                  default:
                                    ToastUtil.error('好友申请失败');
                                    return;
                                }
                              }, success: (response){
                                ToastUtil.hint('申请成功');
                              });
                            }, 
                            child: const Text('发 送', style: TextStyle(color: Colors.white),),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

}
