
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/comment/comment_create.dart';
import 'package:freego_flutter/components/comment/comment_http.dart';
import 'package:freego_flutter/components/comment/comment_model.dart';
import 'package:freego_flutter/components/comment/comment_page.dart';
import 'package:freego_flutter/components/comment/comment_sub_util.dart';
import 'package:freego_flutter/components/comment/comment_tag_http.dart';
import 'package:freego_flutter/components/comment/comment_util.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/components/view/image_display.dart';
import 'package:freego_flutter/components/view/menu_action.dart';
import 'package:freego_flutter/components/view/notify_empty.dart';
import 'package:freego_flutter/components/view/notify_loading.dart';
import 'package:freego_flutter/components/view/stars_display.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/util/date_time_util.dart';
import 'package:freego_flutter/util/dialog_util.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';

class CommentShowWidget extends StatefulWidget{
  final int productId;
  final ProductType type;
  final int? ownnerId;
  final String? productName;
  final Function(CommonMenuController)? onMenuShow;
  final Function(Comment)? onTipoffComment;
  final Function(CommentSub)? onTipoffCommentSub;
  const CommentShowWidget({required this.productId, required this.type, this.ownnerId, this.productName, this.onMenuShow, this.onTipoffComment, this.onTipoffCommentSub, super.key});

  @override
  State<StatefulWidget> createState() {
    return CommentShowState();
  }

}

class _MyAfterPostCommentHandler implements AfterPostCommentHandler{

  final CommentShowState state;
  _MyAfterPostCommentHandler(this.state);
  @override
  void handle(Comment comment) {
    if(comment.productId == state.widget.productId && comment.typeId == state.widget.type.getNum()){
      List<Comment>? commentList = state.commentList;
      if(commentList == null){
        commentList = [comment];
      }
      else{
        commentList.insert(0, comment);
      }
      state.resetState();
    }
  }

}

class CommentShowState extends State<CommentShowWidget> with AutomaticKeepAliveClientMixin{

  static const int DEFAULT_INIT_COUNT = 4;

  List<Comment>? commentList;
  List<CommentTag> tagList = [];
  late _MyAfterPostCommentHandler _afterPostCommentHandler;

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
      List<Comment>? tmpList = await CommentHttp().listHistoryComment(productId: widget.productId, type: widget.type, limit: DEFAULT_INIT_COUNT);
      if(tmpList == null){
        return;
      }
      commentList = tmpList;
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
    super.build(context);
    if(commentList == null){
      return const NotifyLoadingWidget();
    }
    if(commentList!.isEmpty){
      return InkWell(
        onTap: (){
          DialogUtil.loginRedirectConfirm(context, callback: (isLogined){
            if(isLogined){
              if(mounted && context.mounted){
                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                  return CommentCreatePage(widget.productId, widget.type);
                }));
              }
            }
          });
        },
        child: const NotifyEmptyWidget(info: '我要第一个评论',),
      );
    }
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(builder: (context){
          return CommentPage(productId: widget.productId, type: widget.type, creatorId: widget.ownnerId, productName: widget.productName,);
        }));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            direction: Axis.horizontal,
            spacing: 10,
            runSpacing: 10,
            children: getTagWidgets(),
          ),
          const SizedBox(height: 10,),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(12))
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: getCommentWidgets(),
            ),
          )
        ],
      ),
    );
  }

  List<Widget> getTagWidgets(){
    List<Widget> widgets = [];
    for(CommentTag tag in tagList){
      widgets.add(
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(4))
          ),
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
          child: Text('${tag.tagName}（${tag.count}）', style: const TextStyle(color: ThemeUtil.foregroundColor),),
        )
      );
    }
    return widgets;
  }

  List<Widget> getCommentWidgets(){
    List<Widget> widgets = [];
    for(Comment comment in commentList ?? []){
      widgets.add(
        CommentBlockWidget(comment: comment, type: widget.type, ownnerId: widget.ownnerId, onShowMenu: widget.onMenuShow, onTipoffComment: widget.onTipoffComment, onTipoffCommentSub: widget.onTipoffCommentSub,)
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
  
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class CommentBlockWidget extends StatefulWidget{
  final Comment comment;
  final int? ownnerId;
  final ProductType type;
  final CommonMenuController? controller;
  final Function(CommonMenuController)? onShowMenu;
  final Function(Comment)? onTipoffComment;
  final Function(CommentSub)? onTipoffCommentSub;
  const CommentBlockWidget({required this.comment, this.ownnerId, required this.type, this.controller, this.onShowMenu, this.onTipoffComment, this.onTipoffCommentSub, super.key});

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
        comment.replys ??= [];
        comment.replys!.insert(0, commentSub);
        comment.lastSubId = commentSub.id;
        state.resetState();
      }
    }
  }

}

class CommentBlockState extends State<CommentBlockWidget> with SingleTickerProviderStateMixin{

  static const double AVATAR_SIZE = 56;
  static const double AVATAR_SUB_SIZE = 36;

  final key = UniqueKey();

  late _MyAfterPostCommentSubHandler _afterPostCommentSubHandler;

  late AnimationController rightMenuAnim;
  bool rightMenuShow = false;
  static const int RIGHT_MENU_ANIM_MILLI_SECONDS = 150;
  static const double RIGHT_MENU_WIDTH = 100;
  static const double RIGHT_MENU_ITEM_HEIGHT = 40;

  late CommonMenuController controller;

  @override
  void initState(){
    super.initState();
    _afterPostCommentSubHandler = _MyAfterPostCommentSubHandler(this);
    CommentSubUtil().addHandler(_afterPostCommentSubHandler);
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
    CommentSubUtil().removeHandler(_afterPostCommentSubHandler);
    rightMenuAnim.dispose();
    if(widget.controller == null){
      controller.dispose();
    }
    super.dispose();
  }

  void showMenu(){
    widget.onShowMenu?.call(controller);
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
    return Stack(
      key: key,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: AVATAR_SIZE,
                    height: AVATAR_SIZE,
                    child: comment.authorHead == null ?
                    ThemeUtil.defaultUserHead :
                    Image.network(getFullUrl(comment.authorHead!), fit: BoxFit.cover,),
                  ),
                ),
                const SizedBox(width: 8,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      children: [
                        Text(comment.authorName ?? '',  style: const TextStyle(color: ThemeUtil.foregroundColor,),),
                        if(comment.userId == widget.ownnerId)
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
                    comment.createTime == null ?
                    const SizedBox() :
                    Text(DateTimeUtil.shortTime(comment.createTime!), style: const TextStyle(color: Colors.grey),),
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
            const Divider()
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
  }
  
  List<Widget> getCommentSubWidgets(List<CommentSub> commentSubList){
    List<Widget> widgets = [];
    for(int i = 0; i < commentSubList.length; ++i){
      CommentSub sub = commentSubList[i];
      widgets.add(
        const Divider()
      );
      widgets.add(
        CommentSubBlockWidget(commentSub: sub, type: widget.type, ownnerId: widget.ownnerId, onMenuShow: widget.onShowMenu, onTipoffCommentSub: widget.onTipoffCommentSub,)
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
  final int? ownnerId;
  final ProductType type;
  final CommonMenuController? controller;
  final Function(CommonMenuController)? onMenuShow;
  final Function(CommentSub)? onTipoffCommentSub;
  const CommentSubBlockWidget({required this.commentSub, this.ownnerId, required this.type, this.controller, this.onMenuShow, this.onTipoffCommentSub, super.key});

  @override
  State<StatefulWidget> createState() {
    return CommentSubBlockState();
  }
  
}

class CommentSubBlockState extends State<CommentSubBlockWidget> with SingleTickerProviderStateMixin{

  static const double AVATAR_SIZE = 56;
  static const double AVATAR_SUB_SIZE = 36;

  final Key key = UniqueKey();

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
      key: key,
      children: [
        Column(  
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: AVATAR_SUB_SIZE,
                    height: AVATAR_SUB_SIZE,
                    child: sub.authorHead == null ?
                    ThemeUtil.defaultUserHead :
                    Image.network(getFullUrl(sub.authorHead!))
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(sub.authorName ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: ThemeUtil.foregroundColor),),
                          sub.userId == widget.ownnerId ?
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
