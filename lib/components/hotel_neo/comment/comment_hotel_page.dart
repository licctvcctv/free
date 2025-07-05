
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/comment/comment_http.dart';
import 'package:freego_flutter/components/comment/comment_model.dart';
import 'package:freego_flutter/components/comment/comment_page.dart';
import 'package:freego_flutter/components/comment/comment_tag_http.dart';
import 'package:freego_flutter/components/hotel_neo/comment/comment_hotel_create.dart';
import 'package:freego_flutter/components/hotel_neo/comment/comment_hotel_util.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/custom_indicator.dart';
import 'package:freego_flutter/components/view/menu_action.dart';
import 'package:freego_flutter/components/view/notify_empty.dart';
import 'package:freego_flutter/components/view/notify_loading.dart';
import 'package:freego_flutter/components/view/tipoff.dart';
import 'package:freego_flutter/util/dialog_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';

class CommentHotelPage extends StatelessWidget{
  final int hotelId;
  final String? hotelName;
  final int? creatorId;
  const CommentHotelPage(this.hotelId, {this.hotelName, this.creatorId, super.key});

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
      body: CommentHotelWidget(hotelId, hotelName: hotelName, creatorId: creatorId,),
    );
  }
  
}

class CommentHotelWidget extends StatefulWidget{
  final int hotelId;
  final String? hotelName;
  final int? creatorId;
  const CommentHotelWidget(this.hotelId, {this.hotelName, this.creatorId, super.key});

  @override
  State<StatefulWidget> createState() {
    return CommentHotelState();
  }

}

class _MyAfterPostCommentHotelHandler implements AfterPostCommentHotelHandler{

  final CommentHotelState state;
  _MyAfterPostCommentHotelHandler(this.state);

  @override
  void handle(Comment comment) {
    if(comment.productId == state.widget.hotelId && comment.typeId == ProductType.hotel.getNum()){
      List<Comment> commentList = state.commentList;
      commentList.insert(0, comment);
      List<Widget> buffer = state.getCommentWidgets([comment]);
      state.topBuffer = buffer;
      state.resetState();
    }
  }

}

class CommentHotelState extends State<CommentHotelWidget>{

  List<Comment> commentList = [];
  List<CommentTag> tagList = [];
  bool inited = false;

  List<Widget> contents = [];
  List<Widget> topBuffer = [];
  List<Widget> bottomBuffer = [];

  late _MyAfterPostCommentHotelHandler _afterPostCommentHotelHandler;
  String? selectedTag;

  CommonMenuController? menuController;

  @override
  void dispose(){
    CommentHotelUtil().removeHandler(_afterPostCommentHotelHandler);
    super.dispose();
  }

  @override
  void initState(){
    super.initState();

    _afterPostCommentHotelHandler = _MyAfterPostCommentHotelHandler(this);
    CommentHotelUtil().addHandler(_afterPostCommentHotelHandler);

    Future.delayed(Duration.zero, () async{
      List<Comment>? tmpList = await CommentHttp().listHistoryComment(productId: widget.hotelId, type: ProductType.hotel);
      if(tmpList == null){
        ToastUtil.error('好像出了点小问题');
        return;
      }
      commentList = tmpList;
      topBuffer = getCommentWidgets(commentList);
      inited = true;
      if(mounted && context.mounted){
        setState(() {
        });
      }
    });
    Future.delayed(Duration.zero, () async{
      List<CommentTag>? tmpList = await CommentTagHttp().listTag(productId: widget.hotelId, type: ProductType.hotel);
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
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        menuController?.hideMenu();
        menuController = null;
      },
      child: Container(
        color: ThemeUtil.backgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonHeader(
              center: Text(widget.hotelName ?? '全部评论', style: const TextStyle(color: Colors.white, fontSize: 18),),
            ),
            Expanded(
              child: Stack(
                children: [
                  !inited ?
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
                    touchBottom: loadMore,
                  ),
                  Positioned(
                    bottom: 40,
                    left: 0,
                    child: InkWell(
                      onTap: (){
                        DialogUtil.loginRedirectConfirm(context, callback: (isLogined){
                          if(isLogined){
                            Navigator.of(context).push(MaterialPageRoute(builder: (context){
                              return CommentHotelCreatePage(hotelId: widget.hotelId, title: widget.hotelName,);
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
              List<Comment>? tmpList = await CommentHttp().listHistoryComment(productId: widget.hotelId, type: ProductType.hotel, tagName: selectedTag);
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
              color: selectedTag == tag.tagName ? Colors.blue : Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(4))
            ),
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: Text('${tag.tagName}（${tag.count}）', style: TextStyle(color: selectedTag == tag.tagName ? Colors.white : ThemeUtil.foregroundColor),),
          ),
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
    List<Comment>? tmpList = await CommentHttp().listNewComment(productId: widget.hotelId, type: ProductType.hotel, minId: minId, tagName: selectedTag);
    if(tmpList == null){
      ToastUtil.error('好像出了点小问题');
      return;
    }
    if(tmpList.isEmpty){
      ToastUtil.hint('已更新到最新');
    }
    List<Widget> widgets = getCommentWidgets(tmpList);
    commentList.insertAll(0, tmpList);
    topBuffer = widgets;
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }

  Future loadMore() async{
    int? maxId;
    if(commentList.isNotEmpty){
      maxId = commentList.last.id;
    }
    List<Comment>? tmpList = await CommentHttp().listHistoryComment(productId: widget.hotelId, type: ProductType.hotel, maxId: maxId, tagName: selectedTag);
    if(tmpList == null){
      ToastUtil.error('好像出了点小问题');
      return;
    }
    if(tmpList.isEmpty){
      ToastUtil.hint('已经没有了呢');
      return;
    }
    List<Widget> widgets = getCommentWidgets(tmpList);
    commentList.addAll(tmpList);
    bottomBuffer = widgets;
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }

  List<Widget> getCommentWidgets(List<Comment> commentList){
    List<Widget> widgets = [];
    for(Comment comment in commentList){
      Widget inner = CommentBlockWidget(
        comment: comment, 
        type: ProductType.hotel,
        creatorId: widget.creatorId,
        onMenuShow: (controller){
          menuController?.hideMenu();
          menuController = controller;
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
          });
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
          key: ValueKey(comment.id),
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

  void resetState(){
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }
}
