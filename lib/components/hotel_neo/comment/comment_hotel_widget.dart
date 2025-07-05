
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/comment/comment_http.dart';
import 'package:freego_flutter/components/comment/comment_model.dart';
import 'package:freego_flutter/components/comment/comment_tag_http.dart';
import 'package:freego_flutter/components/comment/comment_widget.dart';
import 'package:freego_flutter/components/hotel_neo/comment/comment_hotel_create.dart';
import 'package:freego_flutter/components/hotel_neo/comment/comment_hotel_page.dart';
import 'package:freego_flutter/components/hotel_neo/comment/comment_hotel_util.dart';
import 'package:freego_flutter/components/hotel_neo/hotel_home_freego.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/components/view/menu_action.dart';
import 'package:freego_flutter/components/view/notify_empty.dart';
import 'package:freego_flutter/components/view/notify_loading.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/util/dialog_util.dart';
import 'package:freego_flutter/util/theme_util.dart';

class CommentHotelShowWidget extends StatefulWidget{
  final int hotelId;
  final int? ownnerId;
  final String? hotelName;
  final Function(CommonMenuController)? onMenuShow;
  final Function(Comment)? onTipoffComment;
  final Function(CommentSub)? onTipoffCommentSub;

  const CommentHotelShowWidget({required this.hotelId, this.ownnerId, this.hotelName, this.onMenuShow, this.onTipoffComment, this.onTipoffCommentSub, super.key});
  
  @override
  State<StatefulWidget> createState() {
    return CommentHotelShowState();
  }
}

class _MyAfterPostCommentHotelHandler implements AfterPostCommentHotelHandler{

  final CommentHotelShowState state;
  _MyAfterPostCommentHotelHandler(this.state);

  @override
  void handle(Comment comment) {
    if(comment.productId == state.widget.hotelId && comment.typeId == ProductType.hotel.getNum()){
      List<Comment> commentList = state.commentList;
      commentList.insert(0, comment);
      state.resetState();
    }
  }

}

class CommentHotelShowState extends State<CommentHotelShowWidget> with AutomaticKeepAliveClientMixin{

  static const int DEFAULT_INIT_COUNT = 4;
  static const double AVATAR_SIZE = 56;
  static const double AVATAR_SUB_SIZE = 36;
  static const double SCORE_STAR_SIZE = 20;

  List<Comment> commentList = [];
  List<CommentTag> tagList = [];
  bool inited = false;

  late _MyAfterPostCommentHotelHandler _afterPostCommentHotelHandler;

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
      List<Comment>? tmpList = await CommentHttp().listHistoryComment(productId: widget.hotelId, type: ProductType.hotel, limit: DEFAULT_INIT_COUNT);
      if(tmpList == null){
        return;
      }
      commentList = tmpList;
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
    super.build(context);
    if(!inited){
      return const NotifyLoadingWidget();
    }
    else if(commentList.isEmpty){
      return InkWell(
        onTap: (){
          DialogUtil.loginRedirectConfirm(context, callback: (isLogined){
            if(isLogined){
              if(mounted && context.mounted){
                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                  return CommentHotelCreatePage(hotelId: widget.hotelId);
                }));
              }
            }
          });
        },
        child: const NotifyEmptyWidget(info: '我要第一个评论'),
      );
    }
    return InkWell(
      onTap: (){
        HotelHomePageState? parentState = context.findAncestorStateOfType();
        Navigator.of(context).push(MaterialPageRoute(builder: (context){
          return CommentHotelPage(widget.hotelId, creatorId: widget.ownnerId, hotelName: parentState?.widget.hotel.name,);
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
    for(Comment comment in commentList){
      List<String> picList = [];
      if(comment.pics != null && comment.pics!.isNotEmpty){
        picList = comment.pics!.split(',');
        for(int i = 0; i < picList.length; ++i){
          String pic = picList[i];
          picList[i] = getFullUrl(pic);
        }
      }
      widgets.add(
        CommentBlockWidget(comment: comment, type: ProductType.hotel, ownnerId: widget.ownnerId, onShowMenu: widget.onMenuShow, onTipoffComment: widget.onTipoffComment, onTipoffCommentSub: widget.onTipoffCommentSub,)
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
