
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/user_block/api/user_block_user_api.dart';
import 'package:freego_flutter/components/user_block/event/user_block_user_facade.dart';
import 'package:freego_flutter/components/user_block/model/user_block_user.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/custom_indicator.dart';
import 'package:freego_flutter/components/view/notify_empty.dart';
import 'package:freego_flutter/components/view/notify_loading.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:freego_flutter/util/user_home_director.dart';

class UserBlockUserHomePage extends StatelessWidget{
  const UserBlockUserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 10,
        backgroundColor: ThemeUtil.backgroundColor,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      body: const UserBlockUserHomeWidget(),
    );
  }
  
}

class UserBlockUserHomeWidget extends StatefulWidget{
  const UserBlockUserHomeWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return UserBlockUserHomeState();
  }
  
}

class UserBlockUserHomeState extends State<UserBlockUserHomeWidget>{

  final TextEditingController _textController = TextEditingController();

  final List<UserBlockUserExt> _blockedList = [];
  bool _inited = false;

  final List<Widget> _contentWidgets = [];
  final List<Widget> _bufferWidgets = [];

  UserBlockUserExt? choosedUser;

  @override
  void initState(){
    super.initState();
    appendList();
  }

  @override
  void dispose(){
    _textController.dispose();
    for(UserBlockUserExt item in _blockedList){
      item.controller?.dispose();
      item.controller = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        choosedUser?.controller?.unchoosed();
        choosedUser = null;
      },
      child: Container(
        color: ThemeUtil.backgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CommonHeader(
              center: Text('黑名单', style: TextStyle(color: Colors.white, fontSize: 18),),
            ),
            Expanded(
              child: 
              !_inited ?
              const NotifyLoadingWidget() :
              _blockedList.isEmpty ?
              const NotifyEmptyWidget() :
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                child: AnimatedCustomIndicatorWidget(
                  contents: _contentWidgets,
                  bottomBuffer: _bufferWidgets,
                  touchBottom: appendList,
                ),
              )
            ),
          ],
        ),
      ),
    );
  }
  
  Widget getWidget(UserBlockUserExt item){
    return UserBlockUserWidget(
      key: ValueKey('user_block_user_${item.id}'),
      item: item,
      afterChoosed: (item){
        choosedUser?.controller?.unchoosed();
        choosedUser = item;
      },
      afterRemoved: (item){
        if(_blockedList.remove(item)){
          item.controller?.dispose();
          ToastUtil.hint('取消黑名单成功');
          resetState();
        }
      }
    );
  }

  Future appendList() async{
    int? maxVal;
    if(_blockedList.isNotEmpty){
      maxVal = _blockedList.last.id;
    }
    List<UserBlockUser>? list = await UserBlockUserApi().range(keyword: _textController.text.trim(), maxVal: maxVal, isDesc: true);
    if(list != null){
      _inited = true;
      for(UserBlockUser user in list){
        UserBlockUserExt ext = UserBlockUserExt.fromSuper(user);
        ext.controller = UserBlockUserController();
        _blockedList.add(ext);
        _bufferWidgets.add(getWidget(ext));
      }
      resetState();
    }
  }

  void resetState(){
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }
}

enum UserBlockUserAction{
  removed,
  choosed,
  unchoosed
}

class UserBlockUserController extends ChangeNotifier{

  UserBlockUserAction? _action;
  Function({UserBlockUserExt item})? _afterAction;

  void removed({Function({UserBlockUserExt item})? afterRemoved}){
    _action = UserBlockUserAction.removed;
    _afterAction = afterRemoved;
    notifyListeners();
  }

  void unchoosed({Function({UserBlockUserExt item})? afterAction}){
    _action = UserBlockUserAction.unchoosed;
    _afterAction = afterAction;
    notifyListeners();
  }
}

class UserBlockUserWidget extends StatefulWidget{
  final UserBlockUserExt item;
  final Function(UserBlockUserExt)? afterChoosed;
  final Function(UserBlockUserExt)? afterRemoved;
  const UserBlockUserWidget({required this.item, this.afterChoosed, this.afterRemoved, super.key});

  @override
  State<StatefulWidget> createState() {
    return UserBlockUserState();
  }
  
}

class UserBlockUserState extends State<UserBlockUserWidget> with TickerProviderStateMixin {

  static const double AVATAR_SIZE = 50;
  static const double HEIGHT = 80;

  late UserBlockUserExt _item;

  late AnimationController _sizeAnimController;

  bool _onChooseMode = false;
  late AnimationController _optionAnimController;

  @override
  void initState(){
    super.initState();
    _item = widget.item;
    UserBlockUserController? controller = widget.item.controller;
    if(controller != null){
      controller.addListener(() {
        UserBlockUserAction? action = controller._action;
        switch(action){
          case UserBlockUserAction.removed:
            dealRemoved(controller._afterAction);
            break;
          case UserBlockUserAction.choosed:
            enterChooseMode();
            controller._afterAction?.call(item: _item);
            break;
          case UserBlockUserAction.unchoosed:
            controller._afterAction?.call(item: _item);
            leaveChooseMode();
            break;
          default:
        }
      });
    }
    _sizeAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350), value: 1);
    _optionAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: 175));
  }

  @override
  void dispose(){
    _sizeAnimController.dispose();
    _optionAnimController.dispose();
    super.dispose();
  }

  void dealRemoved(Function({UserBlockUserExt item})? then){
    _sizeAnimController.reverse().then((value){
      then?.call(item: widget.item,);
    });
  }

  void enterChooseMode(){
    _onChooseMode = true;
    _optionAnimController.forward();
    setState(() {
    });
  }

  void leaveChooseMode(){
    _optionAnimController.reverse().then((value){
      _onChooseMode = false;
      resetState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        if(_onChooseMode){
          _item.isChoosed = !_item.isChoosed;
          setState(() {
          });
          return;
        }
        else{
          if(_item.blockId == null){
            return;
          }
          UserHomeDirector().goUserHome(context: context, userId: _item.blockId!);
        }
      },
      onLongPress: _onChooseMode ? null : (){
        enterChooseMode();
        widget.afterChoosed?.call(_item);
      },
      child: AnimatedBuilder(
        animation: _sizeAnimController,
        builder: (context, child) {
          return Wrap(
            clipBehavior: Clip.hardEdge,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width,
                  maxHeight: HEIGHT * _sizeAnimController.value
                ),
                decoration: const BoxDecoration(
                ),
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                child: Container(
                  decoration: const BoxDecoration(),
                  margin: const EdgeInsets.only(top: 6, bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 2
                              )
                            ]
                          ),
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                          height: HEIGHT,
                          clipBehavior: Clip.hardEdge,
                          child: Row(
                            children: [
                              ClipOval(
                                child: SizedBox(
                                  width: AVATAR_SIZE,
                                  height: AVATAR_SIZE,
                                  child: _item.userHead == null ?
                                  ThemeUtil.defaultUserHead :
                                  Image.network(getFullUrl(_item.userHead!), fit: BoxFit.cover,)
                                ),
                              ),
                              const SizedBox(width: 10,),
                              Expanded(
                                child: Text(_item.username ?? '', overflow: TextOverflow.ellipsis, style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
                              ),
                              const SizedBox(width: 10,),
                              const Icon(Icons.arrow_forward_ios, color: ThemeUtil.foregroundColor,)
                            ],
                          )
                        ),
                      ),
                      if(_onChooseMode)
                      getOptionWidget()
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
  
  Future unblock() async{
    if(_item.blockId == null){
      return;
    }
    bool result = await UserBlockUserFacade().unblock(userId: _item.blockId!);
    if(result){
      await _sizeAnimController.reverse();
      widget.afterRemoved?.call(_item);
    }
  }

  Widget getOptionWidget(){
    const double WIDTH = 120;
    return AnimatedBuilder(
      animation: _optionAnimController,
      builder: (context, child) {
        return Wrap(
          clipBehavior: Clip.hardEdge,
          direction: Axis.vertical,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: WIDTH * _optionAnimController.value
              ),
              padding: const EdgeInsets.only(left: 10),
              decoration: const BoxDecoration(),
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                onTap: unblock,
                child: const Icon(Icons.cancel_outlined, color: ThemeUtil.buttonColor, size: 36,),
              ),
            )
          ],
        );
      },
    );
  }

  void resetState(){
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }
}

class UserBlockUserExt extends UserBlockUser{

  bool isChoosed = false;
  UserBlockUserController? controller;

  UserBlockUserExt.fromSuper(UserBlockUser item){
    id = item.id;
    userId = item.userId;
    blockId = item.blockId;
    username = item.username;
    userHead = item.userHead;
    createdTime = item.createdTime;
  }
}
