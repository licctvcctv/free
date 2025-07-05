
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/comment/comment_create.dart';
import 'package:freego_flutter/components/comment/comment_http.dart';
import 'package:freego_flutter/components/comment/comment_model.dart';
import 'package:freego_flutter/components/comment/comment_sub_util.dart';
import 'package:freego_flutter/components/comment/comment_sub_widget.dart';
import 'package:freego_flutter/components/comment/comment_tag_http.dart';
import 'package:freego_flutter/components/comment/comment_util.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/custom_indicator.dart';
import 'package:freego_flutter/components/view/image_display.dart';
import 'package:freego_flutter/components/view/menu_action.dart';
import 'package:freego_flutter/components/view/notify_empty.dart';
import 'package:freego_flutter/components/view/notify_loading.dart';
import 'package:freego_flutter/components/view/stars_display.dart';
import 'package:freego_flutter/components/view/tipoff.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/util/date_time_util.dart';
import 'package:freego_flutter/util/dialog_util.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:freego_flutter/util/user_home_director.dart';
import 'package:freego_flutter/util/user_like_util.dart';

class CommentPage extends StatelessWidget{
  final int productId;
  final ProductType type;
  final int? creatorId;
  final String? productName;
  const CommentPage({required this.productId, required this.type, this.creatorId, this.productName, super.key});
  
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
        child: CommentWrapper(
          productId: productId,
          type: type,
          creatorId: creatorId,
          productName: productName,
        ),
      ),
    );
  }

}

class CommentWrapper extends StatefulWidget{
  final int productId;
  final ProductType type;
  final int? creatorId;
  final String? productName;
  const CommentWrapper({required this.productId, required this.type, this.creatorId, this.productName, super.key});
  
  @override
  State<StatefulWidget> createState() {
    return CommentWrapperState();
  }
  
}

class CommentWrapperState extends State<CommentWrapper>{

  CommonMenuControllerWrapper controllerWrapper = CommonMenuControllerWrapper();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        controllerWrapper.controller?.hideMenu();
        controllerWrapper.controller = null;
      },
      child: Container(
        color: ThemeUtil.backgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonHeader(
              center: Text(widget.productName ?? '全部评论', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),),
            ),
            Expanded(
              child: Stack(
                children: [
                  CommentWidget(productId: widget.productId, type: widget.type, creatorId: widget.creatorId, productName: widget.productName, controllerWrapper: controllerWrapper,),
                  Positioned(
                    bottom: 40,
                    left: 0,
                    child: InkWell(
                      onTap: (){
                        DialogUtil.loginRedirectConfirm(context, callback: (isLogined){
                          if(isLogined){
                            Navigator.of(context).push(MaterialPageRoute(builder: (context){
                              return CommentCreatePage(widget.productId, widget.type, productName: widget.productName,);
                            }));
                          }
                        });
                      },
                      child: Opacity(
                        opacity: 0.6,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(4, 182, 221, 1),
                            borderRadius: BorderRadius.horizontal(right: Radius.circular(40))
                          ),
                          width: 104,
                          height: 56,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.edit, color: Colors.white,),
                              Text('写评论', style: TextStyle(color: Colors.white, fontSize: 16),),
                            ],
                          )
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  
}

class CommonMenuControllerWrapper{
  CommonMenuController? controller;
}

class CommentWidget extends StatefulWidget{
  final int productId;
  final ProductType type;
  final int? creatorId;
  final String? productName;
  final CommonMenuControllerWrapper? controllerWrapper;
  const CommentWidget({required this.productId, required this.type, this.creatorId, this.productName, this.controllerWrapper, super.key});

  @override
  State<StatefulWidget> createState() {
    return CommentState();
  }

}

class _MyAfterPostCommentHandler implements AfterPostCommentHandler{

  final CommentState state;
  _MyAfterPostCommentHandler(this.state);

  @override
  void handle(Comment comment) {
    if(comment.productId == state.widget.productId && comment.typeId == state.widget.type.getNum()){
      List<Comment> commentList = state.commentList;
      commentList.insert(0, comment);
      List<Widget> buffer = state.getCommentWidgets([comment]);
      state.topBuffer = buffer;
      state.resetState();
    }
  }
  
}

class CommentState extends State<CommentWidget>{

  List<Comment> commentList = [];
  List<CommentTag> tagList = [];

  List<Widget> contents = [];
  List<Widget> topBuffer = [];
  List<Widget> bottomBuffer = [];

  bool isInited = false;

  late _MyAfterPostCommentHandler _afterPostCommentHandler;
  String? selectedTag;
  
  @override
  void dispose(){
    CommentUtil().removeHandler(_afterPostCommentHandler);
    super.dispose();
  }

  @override
  void initState(){
    super.initState();

    _afterPostCommentHandler = _MyAfterPostCommentHandler(this);
    CommentUtil().addHandler(_afterPostCommentHandler);

    Future.delayed(Duration.zero, () async{
      List<Comment>? tmpList = await CommentHttp().listHistoryComment(productId: widget.productId, type: widget.type);
      if(tmpList == null){
        ToastUtil.error('获取评论失败');
        return;
      }
      commentList = tmpList;
      isInited = true;
      topBuffer = getCommentWidgets(commentList);
      if(mounted && context.mounted){
        setState(() {
        });
      }
    });
    Future.delayed(Duration.zero, () async{
      List<CommentTag>? tmpList = await CommentTagHttp().listTag(productId: widget.productId, type: widget.type);
      if(tmpList == null){
        return;
      }
      tagList = tmpList;
      if(mounted && context.mounted){
        setState(() {
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget inner = !isInited ?
    const NotifyLoadingWidget() :
    commentList.isEmpty ?
    const NotifyEmptyWidget() :
    AnimatedCustomIndicatorWidget(
      header: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Wrap(
          direction: Axis.horizontal,
          spacing: 10,
          runSpacing: 10,
          children: getTagWidgets(),
        ),
      ),
      contents: contents,
      topBuffer: topBuffer,
      bottomBuffer: bottomBuffer,
      touchTop: loadNew,
      touchBottom: loadHistory
    );
    return inner;
  }

  List<Widget> getTagWidgets(){
    List<Widget> widgets = [];
    for(CommentTag tag in tagList){
      widgets.add(
        InkWell(
          onTap: (){
            if(selectedTag == tag.tagName){
              selectedTag = null;
            }
            else{
              selectedTag = tag.tagName;
            }
            setState(() {
            });
            Future.delayed(Duration.zero, () async{
              List<Comment>? tmpList = await CommentHttp().listHistoryComment(productId: widget.productId, type: widget.type, tagName: selectedTag);
              tmpList ??= [];
              commentList = tmpList;
              topBuffer = bottomBuffer = [];
              contents = getCommentWidgets(commentList);
              if(mounted && context.mounted){
                setState(() {
                });
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: tag.tagName != selectedTag ? Colors.white : Colors.blue,
              borderRadius: const BorderRadius.all(Radius.circular(4))
            ),
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: Text('${tag.tagName}（${tag.count}）', style: TextStyle(color: tag.tagName != selectedTag ? ThemeUtil.foregroundColor : Colors.white),),
          ),
        )
      );
    }
    return widgets;
  }

  List<Widget> getCommentWidgets(List<Comment> commentList){
    List<Widget> widgets = [];
    for(Comment comment in commentList){
      Widget inner = CommentBlockWidget(
        comment: comment, 
        type: widget.type, 
        creatorId: widget.creatorId,
        onMenuShow: (controller){
          widget.controllerWrapper?.controller?.hideMenu();
          widget.controllerWrapper?.controller = controller;
        },
        onTipoffComment: (comment){
          if(comment.id == null){
            ToastUtil.error('数据错误');
            return;
          }
          DialogUtil.loginRedirectConfirm(context, callback: (isLogined){
            if(isLogined){
              if(mounted && context.mounted){
                showModalBottomSheet(
                  isDismissible: true,
                  isScrollControlled: true,
                  context: context,
                  builder: (context){
                    return TipOffWidget(targetId: comment.id!, productType: ProductType.productComment,);
                  }
                );
              }
            }
          },);
        },
        onTipoffCommentSub: (commentSub){
          if(commentSub.id == null){
            ToastUtil.error('数据错误');
            return;
          }
          DialogUtil.loginRedirectConfirm(context, callback: (isLogined){
            if(isLogined){
              if(mounted && context.mounted){
                showModalBottomSheet(
                  isDismissible: true,
                  isScrollControlled: true,
                  context: context,
                  builder: (context){
                    return TipOffWidget(targetId: commentSub.id!, productType: ProductType.productCommentSub,);
                  }
                );
              }
            }
          });
        },
      );
      widgets.add(
        Container(
          key: UniqueKey(),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(4))
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width
          ),
          margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          padding: const EdgeInsets.all(16),
          child: inner,
        )
      );
    }
    return widgets;
  }

  Future loadNew() async{
    int? minId;
    if(commentList.isNotEmpty){
      minId = commentList.first.id;
    }
    List<Comment>? tmpList = await CommentHttp().listNewComment(productId: widget.productId, type: widget.type, minId: minId, tagName: selectedTag);
    if(tmpList == null){
      ToastUtil.error('好像出了点小问题');
      return;
    }
    if(tmpList.isEmpty){
      ToastUtil.hint('已更新到最新评论');
      return;
    }
    List<Widget> widgets = getCommentWidgets(tmpList);
    topBuffer = widgets;
    commentList.insertAll(0, tmpList);
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }

  Future loadHistory() async{
    int? maxId;
    if(commentList.isNotEmpty){
      maxId = commentList.last.id;
    }
    List<Comment>? tmpList = await CommentHttp().listHistoryComment(productId: widget.productId, type: widget.type, maxId: maxId, tagName: selectedTag);
    if(tmpList == null){
      ToastUtil.error('好像出了点小问题');
      return;
    }
    if(tmpList.isEmpty){
      ToastUtil.hint('已经没有了呢');
      return;
    }
    List<Widget> widgets = getCommentWidgets(tmpList);
    bottomBuffer = widgets;
    commentList.addAll(tmpList);
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }

  void resetState(){
    if(mounted && context.mounted){
      setState(() {
      });
    }
  } 
}

class CommentBlockWidget extends StatefulWidget{
  final Comment comment;
  final ProductType type;
  final int? creatorId;
  final CommonMenuController? controller;
  final Function(CommonMenuController)? onMenuShow;
  final Function(Comment)? onTipoffComment;
  final Function(CommentSub)? onTipoffCommentSub;
  const CommentBlockWidget({required this.comment, required this.type, this.creatorId, this.controller, this.onMenuShow, this.onTipoffComment, this.onTipoffCommentSub, super.key});

  @override
  State<StatefulWidget> createState() {
    return CommentBlockState();
  }

}

class _MyAfterPostCommentSubHandler implements AfterPostCommentSubHandler{

  final CommentBlockState state;
  _MyAfterPostCommentSubHandler(this.state);

  @override
  void handler(CommentSub commentSub) {
    Comment comment = state.widget.comment;
    if(comment.id == commentSub.commentId){
      if(comment.lastSubId != commentSub.id){
        comment.subNum = (comment.subNum ?? 0) + 1;
        comment.replys ??= [];
        comment.replys!.insert(0, commentSub);
        comment.lastSubId = commentSub.id;
      }
      state.resetState();
    }
  }

}

class _MyAfterUserLikeHandler implements AfterUserLikeHandler{
  final CommentBlockState state;
  _MyAfterUserLikeHandler(this.state);

  @override
  void handle(int id, ProductType type) {
    Comment comment = state.widget.comment;
    if(comment.id == id && type == ProductType.productComment){
      if(comment.isLiked != true){
        comment.isLiked = true;
        comment.likeNum = (comment.likeNum ?? 0) + 1;
      }
      state.resetState();
    }
  }
  
}

class _MyAfterUserUnLikeHandler implements AfterUserUnlikeHandler{
  final CommentBlockState state;
  _MyAfterUserUnLikeHandler(this.state);

  @override
  void handle(int id, ProductType type) {
    Comment comment = state.widget.comment;
    if(comment.id == id && type == ProductType.productComment){
      if(comment.isLiked == true){
        comment.isLiked = false;
        comment.likeNum = (comment.likeNum ?? 1) - 1;
      }
      state.resetState();
    }
  }

}

class CommentBlockState extends State<CommentBlockWidget> with SingleTickerProviderStateMixin{

  static const int DEFAULT_INIT_COUNT = 4;
  static const double AVATAR_SIZE = 56;
  static const double AVATAR_SUB_SIZE = 36;

  static const double OPERATION_ICON_SIZE = 28;
  Widget svgCommentWidget = SvgPicture.asset('svg/comment/comment.svg');

  late _MyAfterPostCommentSubHandler _afterPostCommentSubHandler;
  late _MyAfterUserLikeHandler _afterUserLikeHandler;
  late _MyAfterUserUnLikeHandler _afterUserUnlikeHandler;

  late AnimationController rightMenuAnim;
  bool rightMenuShow = false;
  static const int RIGHT_MENU_ANIM_MILLI_SECONDS = 150;
  static const double RIGHT_MENU_WIDTH = 100;
  static const double RIGHT_MENU_ITEM_HEIGHT = 40;

  late CommonMenuController controller;

  @override
  void dispose(){
    CommentSubUtil().removeHandler(_afterPostCommentSubHandler);
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
    _afterPostCommentSubHandler = _MyAfterPostCommentSubHandler(this);
    CommentSubUtil().addHandler(_afterPostCommentSubHandler);
    _afterUserLikeHandler = _MyAfterUserLikeHandler(this);
    UserLikeUtil.addAfterUserLikeHandler(_afterUserLikeHandler);
    _afterUserUnlikeHandler = _MyAfterUserUnLikeHandler(this);
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
    Comment comment = widget.comment;
    List<String> picList = [];
    if(comment.pics != null && comment.pics!.isNotEmpty){
      picList = comment.pics!.split(',');
      for(int i = 0; i < picList.length; ++i){
        String pic = picList[i];
        if(!pic.startsWith('http')){
          picList[i] = getFullUrl(pic);
        }
      }
    }
    Widget inner = Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: (){
                    if(comment.userId != null){
                      UserHomeDirector().goUserHome(context: context, userId: comment.userId!);
                    }
                  },
                  child: ClipOval(
                    child: SizedBox(
                      width: AVATAR_SIZE,
                      height: AVATAR_SIZE,
                      child: comment.authorHead == null ?
                      ThemeUtil.defaultUserHead :
                      Image.network(getFullUrl(comment.authorHead!), fit: BoxFit.cover,),
                    ),
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
                            if(comment.userId != null){
                              UserHomeDirector().goUserHome(context: context, userId: comment.userId!);
                            }
                          },
                          child: Text(comment.authorName ?? '',  style: const TextStyle(color: ThemeUtil.foregroundColor,),),
                        ),
                        if(comment.userId == widget.creatorId)
                        Container(
                          padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                          decoration: const BoxDecoration(
                            color: Colors.lightBlueAccent,
                            borderRadius: BorderRadius.all(Radius.circular(4))
                          ),
                          child: Text(StringUtil.getAuthorTag(widget.type), style: const TextStyle(color: ThemeUtil.foregroundColor),),
                        )
                      ],
                    ),
                    if(comment.createTime != null)
                    Text(DateTimeUtil.shortTime(comment.createTime!), style: const TextStyle(color: Colors.grey),),
                    if(comment.stars != null)
                    StarsRowWidget(rank: comment.stars! ~/ 10, size: 22,)
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
            picList.isEmpty ?
            const SizedBox() :
            Padding(
              padding: const EdgeInsets.only(left: AVATAR_SIZE + 8, top: 10),
              child: ImageDisplayWidget(
                picList
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: AVATAR_SIZE + 8, top: 10),
              child: Text(comment.content ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor),),
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
                        onTap: (){
                          showGeneralDialog(
                            barrierDismissible: true,
                            barrierLabel: '',
                            context: context, 
                            transitionBuilder: (context, animation, secondaryAnimation, child) {
                              return SlideTransition(
                                position: animation.drive(Tween(begin: const Offset(0, 1), end: Offset.zero)),
                                child: child,
                              );
                            },
                            pageBuilder:(context, animation, secondaryAnimation) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Material(
                                    color: Colors.transparent,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxHeight: MediaQuery.of(context).size.height * 0.6,
                                        maxWidth: MediaQuery.of(context).size.width
                                      ),
                                      child: CommentSubWidget(comment, creatorId: widget.creatorId,),
                                    ),
                                  )
                                ],
                              );
                            },
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          width: OPERATION_ICON_SIZE,
                          height: OPERATION_ICON_SIZE,
                          child: svgCommentWidget,
                        ),
                      ),
                      Text('${comment.subNum ?? 0}', style: const TextStyle(color: Colors.grey),),
                      const SizedBox(width: 10,),
                      InkWell(
                        onTap: (){
                          if(comment.id == null){
                            return;
                          }
                          DialogUtil.loginRedirectConfirm(context, callback: (isLogined){
                            if(isLogined){
                              if(comment.isLiked == true){
                                UserLikeUtil.unlike(comment.id!, ProductType.productComment);
                              }
                              else{
                                UserLikeUtil.like(comment.id!, ProductType.productComment);
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
                          child: comment.isLiked == true ?
                          Image.asset('assets/comment/icon_comment_like_on.png') :
                          Image.asset('assets/comment/icon_comment_like.png')
                        ),
                      ),
                      Text('${comment.likeNum ?? 0}', style: const TextStyle(color: Colors.grey),)
                    ],
                  ),
                ],
              ),
            ),
            comment.replys == null || comment.replys!.isEmpty ?
            const SizedBox():
            Padding(
              padding: const EdgeInsets.only(left: AVATAR_SIZE + 8,),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: getCommentSubWidgets(comment.replys!),
                ),
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
                        widget.onTipoffComment?.call(comment);
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
    return inner;
  }

  List<Widget> getCommentSubWidgets(List<CommentSub> commentSubList){
    List<Widget> widgets = [];
    for(int i = 0; i < commentSubList.length; ++i){
      CommentSub sub = commentSubList[i];
      widgets.add(
        const Divider()
      );
      widgets.add(
        CommentSubBlockWidget(commentSub: sub, type: widget.type, creatorId: widget.creatorId, onMenuShow: widget.onMenuShow, onTipoffCommentSub: widget.onTipoffCommentSub,)
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

class CommentSubBlockWidget extends StatefulWidget{
  final CommentSub commentSub;
  final ProductType type;
  final int? creatorId;
  final CommonMenuController? controller;
  final Function(CommonMenuController)? onMenuShow;
  final Function(CommentSub)? onTipoffCommentSub;
  const CommentSubBlockWidget({required this.commentSub, required this.type, this.creatorId, this.controller, this.onMenuShow, this.onTipoffCommentSub, super.key});

  @override
  State<StatefulWidget> createState() {
    return CommentSubBlockState();
  }
  
}

class CommentSubBlockState extends State<CommentSubBlockWidget> with SingleTickerProviderStateMixin{

  static const double AVATAR_SIZE = 56;
  static const double AVATAR_SUB_SIZE = 36;

  late AnimationController rightMenuAnim;
  bool rightMenuShow = false;
  static const int RIGHT_MENU_ANIM_MILLI_SECONDS = 150;
  static const double RIGHT_MENU_WIDTH = 100;
  static const double RIGHT_MENU_ITEM_HEIGHT = 40;

  late CommonMenuController controller;

  @override
  void initState(){
    super.initState();
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

  @override
  void dispose(){
    rightMenuAnim.dispose();
    if(widget.controller == null){
      controller.dispose();
    }
    super.dispose();
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
    CommentSub sub = widget.commentSub;
    return Stack(
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
                      width: AVATAR_SUB_SIZE,
                      height: AVATAR_SUB_SIZE,
                      child: sub.authorHead == null ?
                      ThemeUtil.defaultUserHead :
                      Image.network(getFullUrl(sub.authorHead!))
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Column(
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
                            child: Text(sub.authorName ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: ThemeUtil.foregroundColor),),
                          ),
                          sub.userId == widget.creatorId ?
                          Container(
                            padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                            decoration: const BoxDecoration(
                              color: Colors.lightBlueAccent,
                              borderRadius: BorderRadius.all(Radius.circular(4))
                            ),
                            child: Text(StringUtil.getAuthorTag(widget.type), style: const TextStyle(color: ThemeUtil.foregroundColor),),
                          ) : const SizedBox(),
                        ],
                      ),
                      sub.createTime == null ?
                      const SizedBox() :
                      Text(DateTimeUtil.shortTime(sub.createTime!), style: const TextStyle(color: Colors.grey),)
                    ],
                  ),
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
              padding: const EdgeInsets.only(left: AVATAR_SUB_SIZE + 8, top: 6),
              child: Text(sub.content ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor),),
            )
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
  }
  
}
