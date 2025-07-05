
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/friend_neo/friend_http.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/http/http_tool.dart';
import 'package:freego_flutter/util/dictionary_util.dart';
import 'package:freego_flutter/util/local_user.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';

import 'friend_common.dart';

class FriendApplyPage extends StatefulWidget{
  final SimpleUser user;
  const FriendApplyPage(this.user, {super.key});

  @override
  State<StatefulWidget> createState() {
    return FriendApplyPageState();
  }
  
}

class FriendApplyPageState extends State<FriendApplyPage>{
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
        child: FriendApplyWidget(widget.user),
      ),
    );
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

  static const double PADDING_TOP = 80;
  static const double AVATAR_SIZE = 80;
  static const double BACKUP_PADDING_VERTICAL = 50;
  static const double BACKUP_HEIGHT = 50;
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
    return Container(
      height: double.infinity,
      color: ThemeUtil.backgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CommonHeader(
            center: Text('添加好友', style: TextStyle(color: Colors.white),),
          ),
          ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const ClampingScrollPhysics(),
            children: [
              Column(
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
                  Text(user.name ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor),)
                ],
              ),
              const SizedBox(height: 60,),
              Container(
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
                              ToastUtil.hint('您和对方已经是好友了');
                              break;
                            case ResultCode.RES_DOING:
                              ToastUtil.warn('您和对方的好友申请正在处理中');
                              break;
                            default:
                              String? message = response.data['message'];
                              message ??= '申请失败';
                              ToastUtil.error(message);
                              break;
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
          )
        ],
      ),
    );
  }

}
