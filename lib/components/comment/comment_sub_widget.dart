
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/comment/comment_model.dart';
import 'package:freego_flutter/components/comment/comment_sub_http.dart';
import 'package:freego_flutter/components/comment/comment_sub_util.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/components/view/custom_indicator.dart';
import 'package:freego_flutter/components/view/menu_action.dart';
import 'package:freego_flutter/components/view/notify_empty.dart';
import 'package:freego_flutter/components/view/notify_loading.dart';
import 'package:freego_flutter/components/view/simple_input.dart';
import 'package:freego_flutter/components/view/tipoff.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/util/date_time_util.dart';
import 'package:freego_flutter/util/dialog_util.dart';
import 'package:freego_flutter/util/local_user.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:freego_flutter/util/user_home_director.dart';
import 'package:freego_flutter/util/user_like_util.dart';

class CommentSubWidget extends StatefulWidget{
  final Comment comment;
  final int? creatorId;
  const CommentSubWidget(this.comment, {this.creatorId, super.key});

  @override
  State<StatefulWidget> createState() {
    return CommentSubState();
  }
  
}

class _MyAfterPostCommentSubHandler implements AfterPostCommentSubHandler{

  final CommentSubState state;
  _MyAfterPostCommentSubHandler(this.state);

  @override
  void handler(CommentSub commentSub) {
    Comment comment = state.widget.comment;
    if(comment.id == commentSub.commentId && commentSub.commentId != null){
      List<CommentSub> subList = state.subList;
      subList.insert(0, commentSub);
      List<Widget> buffer = state.getCommentSubWidget([commentSub]);
      state.topBuffers = buffer;
      state.resetState();
    }
  }
  
}

class CommentSubState extends State<CommentSubWidget>{

  List<CommentSub> subList = [];
  bool inited = false;

  List<Widget> contents = [];
  List<Widget> topBuffers = [];
  List<Widget> bottomBuffers = [];

  late _MyAfterPostCommentSubHandler _afterPostCommentSubHandler;

  static const int USERNAME_MAX_LENGTH = 12;
  TextEditingController textController = TextEditingController();
  FocusNode textFocus = TextInputFocusNode();
  String prefix = '';
  int? replyId;

  CommonMenuController? menuController;

  @override
  void dispose(){
    CommentSubUtil().removeHandler(_afterPostCommentSubHandler);
    textController.dispose();
    textFocus.dispose();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();

    _afterPostCommentSubHandler = _MyAfterPostCommentSubHandler(this);
    CommentSubUtil().addHandler(_afterPostCommentSubHandler);

    Comment comment = widget.comment;
    Future.delayed(Duration.zero, () async{
      if(comment.id == null){
        ToastUtil.error('数据出错');
        return;
      }
      List<CommentSub>? tmpList = await CommentSubHttp().listHistory(commentId: comment.id!);
      if(tmpList == null){
        ToastUtil.error('获取评论失败');
        return;
      }
      topBuffers = getCommentSubWidget(tmpList);
      inited = true;
      subList = tmpList;
      if(mounted && context.mounted){
        setState(() {
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget inner = Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))
      ),
      height: double.infinity,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('全部子评论', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold),)
            ],
          ),
          const Divider(),
          Expanded(
            child: !inited ?
            const NotifyLoadingWidget() :
            subList.isEmpty ?
            const NotifyEmptyWidget() :
            AnimatedCustomIndicatorWidget(
              contents: contents,
              topBuffer: topBuffers,
              bottomBuffer: bottomBuffers,
              touchTop: loadNew,
              touchBottom: loadHistory,
            )
          ),
          if(LocalUser.isLogined())
          SimpleInputWidget(
            hintText: '友好地评论一下哟~',
            onSubmit: (val) async{
              Comment comment = widget.comment;
              CommentSub sub = CommentSub();
              sub.commentId = comment.id;
              sub.content = val;
              if(val.startsWith(prefix) && replyId != null){
                sub.replyId = replyId;
              }
              CommentSub? result = await CommentSubUtil().post(sub);
              return result != null;
            },
            textController: textController,
            focusNode: textFocus,
            backgroundColor: Colors.white,
          )
        ],
      ),
    );
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        FocusScope.of(context).unfocus();
        menuController?.hideMenu();
        menuController = null;
      },
      child: inner,
    );
  }

  Future loadNew() async{
    Comment comment = widget.comment;
    if(comment.id == null){
      ToastUtil.error('数据出错');
      return;
    }
    int? minId;
    if(subList.isNotEmpty){
      minId = subList.first.id;
    }
    List<CommentSub>? tmpList = await CommentSubHttp().listNew(commentId: comment.id!, minId: minId);
    if(tmpList == null){
      ToastUtil.error('好像出了点小问题');
      return;
    }
    if(tmpList.isEmpty){
      ToastUtil.hint('已更新到最新');
      return;
    }
    List<Widget> widgets = getCommentSubWidget(tmpList);
    topBuffers = widgets;
    subList.insertAll(0, tmpList);
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }

  Future loadHistory() async{
    Comment comment = widget.comment;
    if(comment.id == null){
      ToastUtil.error('数据出错');
      return;
    }
    int? maxId;
    if(subList.isNotEmpty){
      maxId = subList.last.id;
    }
    List<CommentSub>? tmpList = await CommentSubHttp().listHistory(commentId: comment.id!, maxId: maxId);
    if(tmpList == null){
      ToastUtil.error('好像出了点小问题');
      return;
    }
    if(tmpList.isEmpty){
      ToastUtil.hint('已经没有了呢');
      return;
    }
    List<Widget> widgets = getCommentSubWidget(tmpList);
    bottomBuffers = widgets;
    subList.addAll(tmpList);
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }

  List<Widget> getCommentSubWidget(List<CommentSub> subList){
    ProductType? type;
    Comment comment = widget.comment;
    if(comment.typeId != null){
      type = ProductTypeExt.getType(comment.typeId!);
    }
    List<Widget> widgets = [];
    for(CommentSub sub in subList){
      widgets.add(
        CommentSubBlock(
          sub,
          merchantId: widget.creatorId,
          merchantType: type,
          onReply: (){
            DialogUtil.loginRedirectConfirm(context, callback: (isLogined){
              if(isLogined){
                prefix = '回复 @${sub.authorName == null ? '' : StringUtil.getLimitedText(sub.authorName!, USERNAME_MAX_LENGTH)}：';
                replyId = sub.id;
                FocusScope.of(context).unfocus();
                FocusScope.of(context).requestFocus(textFocus);
                SystemChannels.textInput.invokeMethod('TextInput.show');
                textController.text = prefix;
                textController.selection = TextSelection(baseOffset: prefix.length, extentOffset: prefix.length);
                if(mounted && context.mounted){
                  setState(() {
                  });
                }
              }
            });
          },
          onMenuShow: (controller){
            menuController?.hideMenu();
            menuController = controller;
          },
          onTipoffCommentSub: (commentSub){
            if(commentSub.id == null){
              ToastUtil.error('数据错误');
              return;
            }
            showModalBottomSheet(
              isDismissible: true,
              isScrollControlled: true,
              context: context,
              builder: (context){
                return TipOffWidget(targetId: commentSub.id!, productType: ProductType.productCommentSub,);
              }
            );
          },
        )
      );
      widgets.add(
        const Divider()
      );
    }
    return widgets;
  }

  void resetState(){
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }
}

class CommentSubBlock extends StatefulWidget{

  final CommentSub sub;
  final int? merchantId;
  final ProductType? merchantType;
  final Function()? onReply;
  final CommonMenuController? controller;
  final Function(CommonMenuController)? onMenuShow;
  final Function(CommentSub)? onTipoffCommentSub;
  const CommentSubBlock(this.sub, {this.merchantId, this.merchantType, this.onReply, this.controller, this.onMenuShow, this.onTipoffCommentSub, super.key});

  @override
  State<StatefulWidget> createState() {
    return CommentSubBlockState();
  }
}

class _MyAfterUserLikeHandler implements AfterUserLikeHandler{

  final CommentSubBlockState state;
  _MyAfterUserLikeHandler(this.state);

  @override
  void handle(int id, ProductType type) {
    if(type != ProductType.productCommentSub){
      return;
    }
    CommentSub sub = state.widget.sub;
    if(sub.id == id){
      if(sub.isLiked != true){
        sub.isLiked = true;
        sub.likeNum = (sub.likeNum ?? 0) + 1;
      }
      state.resetState();
    }
  }

}

class _MyAfterUserUnlikeHandler implements AfterUserUnlikeHandler{

  final CommentSubBlockState state;
  _MyAfterUserUnlikeHandler(this.state);

  @override
  void handle(int id, ProductType type) {
    if(type != ProductType.productCommentSub){
      return;
    }
    CommentSub sub = state.widget.sub;
    if(sub.id == id){
      if(sub.isLiked == true){
        sub.isLiked = false;
        sub.likeNum = (sub.likeNum ?? 1) - 1; 
      }
      state.resetState();
    }
  }

}

class CommentSubBlockState extends State<CommentSubBlock> with SingleTickerProviderStateMixin{

  static const double AVATAR_SIZE = 56;
  static const double OPERATION_ICON_SIZE = 28;
  Widget svgCommentWidget = SvgPicture.asset('svg/comment/comment.svg');
  
  late _MyAfterUserLikeHandler _afterUserLikeHandler;
  late _MyAfterUserUnlikeHandler _afterUserUnlikeHandler;

  late AnimationController rightMenuAnim;
  bool rightMenuShow = false;
  static const int RIGHT_MENU_ANIM_MILLI_SECONDS = 150;
  static const double RIGHT_MENU_WIDTH = 100;
  static const double RIGHT_MENU_ITEM_HEIGHT = 40;

  late CommonMenuController controller;

  final Key key = UniqueKey();

  @override
  void dispose(){
    UserLikeUtil.removeAfterUserLikeHandler(_afterUserLikeHandler);
    UserLikeUtil.removeAfterUserUnlikeHandler(_afterUserUnlikeHandler);
    rightMenuAnim.dispose();
    if(widget.controller == null){
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    _afterUserLikeHandler = _MyAfterUserLikeHandler(this);
    UserLikeUtil.addAfterUserLikeHandler(_afterUserLikeHandler);
    _afterUserUnlikeHandler = _MyAfterUserUnlikeHandler(this);
    UserLikeUtil.addAfterUserUnlikeHandler(_afterUserUnlikeHandler);
    rightMenuAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: RIGHT_MENU_ANIM_MILLI_SECONDS));
    if(widget.controller == null){
      controller = CommonMenuController();
    }
    else{
      controller = widget.controller!;
    }
    controller.addListener(() { 
      if(mounted && context.mounted){
       switch(controller.action){
          case CommonMenuAction.showMenu:
            showMenu();
            break;
          case CommonMenuAction.hideMenu:
            hideMenu();
            break;
          default:
            break;
       }
      }
    });
  }

  void showMenu(){
    widget.onMenuShow?.call(controller);
    rightMenuAnim.forward();
    rightMenuShow = true;
    setState(() {
    });
  }

  void hideMenu(){
    rightMenuAnim.reverse();
    rightMenuShow = false;
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    CommentSub sub = widget.sub;
    Widget inner = Stack(
      key: key,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: (){
                    if(sub.userId != null){
                      UserHomeDirector().goUserHome(context: context, userId: sub.userId!);
                    }
                  },
                  child: ClipOval(
                    child: SizedBox(
                      width: AVATAR_SIZE,
                      height: AVATAR_SIZE,
                      child: sub.authorHead == null ?
                        ThemeUtil.defaultUserHead :
                        Image.network(getFullUrl(sub.authorHead!), fit: BoxFit.cover,),
                    )
                  ),
                ),
                const SizedBox(width: 8,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      children: [
                        InkWell(
                          onTap: (){
                            if(sub.userId != null){
                              UserHomeDirector().goUserHome(context: context, userId: sub.userId!);
                            }
                          },
                          child: Text(sub.authorName ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor),),
                        ),
                        sub.userId == widget.merchantId && widget.merchantType != null ?
                        Container(
                          padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                          decoration: const BoxDecoration(
                            color: Colors.lightBlueAccent,
                            borderRadius: BorderRadius.all(Radius.circular(4))
                          ),
                          child: Text(StringUtil.getAuthorTag(widget.merchantType!), style: const TextStyle(color: ThemeUtil.foregroundColor),),
                        ) : const SizedBox(),
                      ],
                    ),
                    sub.createTime == null ?
                    const SizedBox() :
                    Text(DateTimeUtil.shortTime(sub.createTime!), style: const TextStyle(color: Colors.grey),)
                  ],
                ),
                const Expanded(child: SizedBox()),
                InkWell(
                  onTap: (){
                    if(rightMenuShow){
                      hideMenu();
                    }
                    else{
                      showMenu();
                    }
                  },
                  child: const Icon(Icons.more_vert_rounded, color: ThemeUtil.foregroundColor, size: 24,),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: AVATAR_SIZE + 8, top: 10),
              child: Text(sub.content ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor),),
            ),
            Padding(
              padding: const EdgeInsets.only(left: AVATAR_SIZE + 8, top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: widget.onReply,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          width: OPERATION_ICON_SIZE,
                          height: OPERATION_ICON_SIZE,
                          child: svgCommentWidget,
                        ),
                      ),
                      const SizedBox(width: 10,),
                      InkWell(
                        onTap: (){
                          if(sub.id == null){
                            ToastUtil.error('数据出错');
                            return;
                          }
                          DialogUtil.loginRedirectConfirm(context, callback: (isLogined){
                            if(isLogined){
                              if(sub.isLiked == true){
                                UserLikeUtil.unlike(sub.id!, ProductType.productCommentSub);
                              }
                              else{
                                UserLikeUtil.like(sub.id!, ProductType.productCommentSub);
                              }
                              if(mounted && context.mounted){
                                setState(() {
                                });
                              }
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          width: OPERATION_ICON_SIZE,
                          height: OPERATION_ICON_SIZE,
                          child: sub.isLiked == true ?
                          Image.asset('assets/comment/icon_comment_like_on.png') :
                          Image.asset('assets/comment/icon_comment_like.png')
                        ),
                      ),
                      Text('${sub.likeNum ?? 0}', style: const TextStyle(color: Colors.grey),)
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          top: 0,
          right: 0,
          child: AnimatedBuilder(
            animation: rightMenuAnim,
            builder: (context, child) {
              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: rightMenuAnim.value * RIGHT_MENU_ITEM_HEIGHT
                ),
                child: Wrap(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap
                      ),
                      onPressed: (){
                        widget.onTipoffCommentSub?.call(sub);
                      },
                      child: Container(
                        width: RIGHT_MENU_WIDTH,
                        height: RIGHT_MENU_ITEM_HEIGHT,
                        decoration: const BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(12)
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 2
                            )
                          ]
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.info_outline_rounded, color: Colors.white,),
                            SizedBox(width: 8,),
                            Text('举报', style: TextStyle(color: Colors.white),),
                          ],
                        )
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width
      ),
      child: inner,
    );
  }

  void resetState(){
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }
}
