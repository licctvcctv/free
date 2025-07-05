
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/circle_neo/circle_common.dart';
import 'package:freego_flutter/components/circle_neo/detail/circle_activity.dart';
import 'package:freego_flutter/components/circle_neo/view/circle_const.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/components/trip/trip_common.dart';
import 'package:freego_flutter/components/user_favorite/user_favorite_util.dart';
import 'package:freego_flutter/components/view/image_group_viewer.dart';
import 'package:freego_flutter/components/view/user_behavior.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/util/dialog_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/user_like_util.dart';
import 'package:intl/intl.dart';

class CircleActivityWidget extends StatefulWidget{

  final CircleActivity circle;
  const CircleActivityWidget(this.circle, {super.key});

  @override
  State<StatefulWidget> createState() {
    return CircleActivityState();
  }

}

class _MyAfterUserLikeHandler implements AfterUserLikeHandler{

  final CircleActivityState state;
  const _MyAfterUserLikeHandler(this.state);

  @override
  void handle(int id, ProductType type) {
    if(type != ProductType.circle){
      return;
    }
    Circle circle = state.widget.circle;
    if(circle.id != id){
      return;
    }
    if(circle.isLiked != true){
      circle.isLiked = true;
      circle.likeNum = (circle.likeNum ?? 0) + 1;
    }
    state.resetState();
  }

}

class _MyAfterUserUnlikeHandler implements AfterUserUnlikeHandler{

  final CircleActivityState state;
  const _MyAfterUserUnlikeHandler(this.state);

  @override
  void handle(int id, ProductType type) {
    if(type != ProductType.circle){
      return;
    }
    Circle circle = state.widget.circle;
    if(circle.id != id){
      return;
    }
    if(circle.isLiked == true){
      circle.isLiked = false;
      circle.likeNum = (circle.likeNum ?? 1) - 1;
    }
    state.resetState();
  }

}

class _MyAfterUserFavoriteHandler implements AfterUserFavoriteHandler{

  final CircleActivityState state;
  const _MyAfterUserFavoriteHandler(this.state);
  @override
  void handle(int productId, ProductType type) {
    if(type != ProductType.circle){
      return;
    }
    Circle circle = state.widget.circle;
    if(circle.id != productId){
      return;
    }
    if(circle.isFavorited != true){
      circle.isFavorited = true;
      circle.favoriteNum = (circle.favoriteNum ?? 0) + 1;
    }
    state.resetState();
  }
  
}

class _MyAfterUserUnFavoriteHandler implements AfterUserUnFavoriteHandler{

  final CircleActivityState state;
  const _MyAfterUserUnFavoriteHandler(this.state);

  @override
  void handle(int productId, ProductType type) {
    if(type != ProductType.circle){
      return;
    }
    Circle circle = state.widget.circle;
    if(circle.id != productId){
      return;
    }
    if(circle.isFavorited == true){
      circle.isFavorited = false;
      circle.favoriteNum = (circle.favoriteNum ?? 1) - 1;
    }
    state.resetState();
  }

}

class CircleActivityState extends State<CircleActivityWidget>{

  late _MyAfterUserLikeHandler _afterUserLikeHandler;
  late _MyAfterUserUnlikeHandler _afterUserUnlikeHandler;

  late _MyAfterUserFavoriteHandler _afterUserFavoriteHandler;
  late _MyAfterUserUnFavoriteHandler _afterUserUnFavoriteHandler;

  @override
  void dispose(){
    UserLikeUtil.removeAfterUserLikeHandler(_afterUserLikeHandler);
    UserLikeUtil.removeAfterUserUnlikeHandler(_afterUserUnlikeHandler);
    UserFavoriteUtil().removeFavoriteHandler(_afterUserFavoriteHandler);
    UserFavoriteUtil().removeUnFavoriteHandler(_afterUserUnFavoriteHandler);
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    _afterUserLikeHandler = _MyAfterUserLikeHandler(this);
    UserLikeUtil.addAfterUserLikeHandler(_afterUserLikeHandler);
    _afterUserUnlikeHandler = _MyAfterUserUnlikeHandler(this);
    UserLikeUtil.addAfterUserUnlikeHandler(_afterUserUnlikeHandler);

    _afterUserFavoriteHandler = _MyAfterUserFavoriteHandler(this);
    UserFavoriteUtil().addFavoriteHandler(_afterUserFavoriteHandler);
    _afterUserUnFavoriteHandler = _MyAfterUserUnFavoriteHandler(this);
    UserFavoriteUtil().addUnFavoriteHandler(_afterUserUnFavoriteHandler);
  }

  @override
  Widget build(BuildContext context) {
    CircleActivity circle = widget.circle;
    TripVo? trip = circle.trip;
    DateTime now = DateTime.now();
    int? status;
    if(trip != null){
      if(trip.startDate != null && trip.startDate!.isAfter(now)){
        status = 1;
      }
      else if(trip.startDate != null && trip.startDate!.isBefore(now) && trip.endDate != null && trip.endDate!.isAfter(now)){
        status = 2;
      }
      else if(trip.endDate != null && trip.endDate!.isBefore(now)){
        status = 3;
      }
    }
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width
      ),
      child: Container(
        margin: const EdgeInsets.all(CircleWidgetConsts.MARGIN),
        padding: const EdgeInsets.all(CircleWidgetConsts.PADDING),
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4
            )
          ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: CircleWidgetConsts.AVATAR_SIZE,
                    height: CircleWidgetConsts.AVATAR_SIZE,
                    child: circle.authorHead == null ?
                    ThemeUtil.defaultUserHead :
                    Image.network(getFullUrl(circle.authorHead!), fit: BoxFit.cover,),
                  ),
                ),
                const SizedBox(width: 10,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(circle.authorName ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
                    circle.createTime == null ?
                    const SizedBox() :
                    Text(DateFormat('yyyy.MM.dd').format(circle.createTime!), style: const TextStyle(color: Colors.grey),)
                  ],
                ),
                const Expanded(
                  child: SizedBox(),
                ),
                status == null ?
                const SizedBox() :
                status == 1 ?
                Container(
                  width: 80,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: const Text('招募中', style: TextStyle(color: Colors.blue, fontSize: 18),),
                ) :
                status == 2 ?
                Container(
                  width: 80,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: const Text('进行中', style: TextStyle(color: Colors.red, fontSize: 18),),
                ) :
                Container(
                  width: 80,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: ThemeUtil.foregroundColor),
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: const Text('已结束', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 18),),
                )
              ],
            ),
            const Divider(),
            TextButton(
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 10),
                alignment: Alignment.centerLeft
              ),
              onPressed: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                  return CircleActivityPage(circle);
                }));
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(circle.name ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ThemeUtil.foregroundColor)),
                  const SizedBox(height: 10,),
                  if(circle.startTime != null)
                  Row(
                    children: [
                      const Text('出发时间：', style: TextStyle(fontSize: 16, color: ThemeUtil.foregroundColor),),
                      Expanded(
                        child: Text(DateFormat('yyyy-MM-dd').format(circle.startTime!), style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
                      )
                    ],
                  ),
                  const SizedBox(height: 10,),
                  Row(
                    children: [
                      const Text('集合地点：', style: TextStyle(fontSize: 16, color: ThemeUtil.foregroundColor),),
                      Expanded(
                        child: Text(circle.assemblingSpot ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
                      )
                    ],
                  ),
                  getDayWidget(),
                  getPointWidget(),
                  getImagesWidget()
                ],
              ),
            ),
            const Divider(),
            getFooterWidget()
          ],
        ),
      ),
    );
  }

  Widget getFooterWidget(){
    CircleActivity circle = widget.circle;
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          Expanded(
            child: Text(circle.location ?? '', overflow: TextOverflow.ellipsis, style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16, fontWeight: FontWeight.bold),),
          ),
          SizedBox(
            width: 60,
            child: IconButton(
              onPressed: (){
                if(circle.id == null){
                  return;
                }
                DialogUtil.loginRedirectConfirm(context, callback: (isLogined){
                  if(isLogined){
                    if(mounted && context.mounted){
                      if(circle.isLiked == true){
                        UserLikeUtil.unlike(circle.id!, ProductType.circle);
                      }
                      else{
                        UserLikeUtil.like(circle.id!, ProductType.circle);
                      }
                    }
                  }
                });
              },
              icon: circle.isLiked == true ?
              const Icon(Icons.favorite_sharp, size: 28, color: COLOR_ACTIVE,) :
              const Icon(Icons.favorite_sharp, size: 28, color: COLOR_INACTIVE,)
            ),
          ),
          SizedBox(
            width: 60,
            child: IconButton(
              onPressed: (){
                if(circle.id == null){
                  return;
                }
                DialogUtil.loginRedirectConfirm(context, callback: (isLogined){
                  if(isLogined){
                    if(mounted && context.mounted){
                      if(circle.isFavorited == true){
                        UserFavoriteUtil().unFavorite(productId: circle.id!, type: ProductType.circle);
                      }
                      else{
                        UserFavoriteUtil().favorite(productId: circle.id!, type: ProductType.circle);
                      }
                    }
                  }
                });
              },
              icon: circle.isFavorited == true ?
              const Icon(Icons.star_rate_rounded, size: 28, color: COLOR_ACTIVE,) :
              const Icon(Icons.star_rate_rounded, size: 28, color: COLOR_INACTIVE,)
            ),
          )
        ],
      ),
    );
  }

Widget getImagesWidget() {
  if (widget.circle.pics == null) return const SizedBox();
  List<String> picList = widget.circle.pics!.split(',');
  if (picList.isEmpty) return const SizedBox();

  // 动态计算图片尺寸：3 列，考虑边距和间距
  final screenWidth = MediaQuery.of(context).size.width;
  const padding = 16.0;    // 与外部容器的 padding 一致
  const spacing = 10.0;    // 图片间距
  final itemSize = (screenWidth - 2 * padding - 2 * spacing) / 3;

  return GridView.count(
    shrinkWrap: true,          // 适应内容高度
    physics: const NeverScrollableScrollPhysics(), // 禁止滚动
    crossAxisCount: 3,         // 固定 3 列
    mainAxisSpacing: spacing,  // 行间距
    crossAxisSpacing: spacing, // 列间距
    children: picList.map((pic) => 
      InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => ImageGroupViewer(picList, initIndex: picList.indexOf(pic)),
        )),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            getFullUrl(pic),
            fit: BoxFit.cover,
            width: itemSize,
            height: itemSize,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
          ),
        ),
      ),
    ).toList(),
  );
}

  Widget getDayWidget(){
    TripVo? trip = widget.circle.trip;
    if(trip == null || trip.totalNum == null){
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          const Text('游玩天数：', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
          Expanded(
            child: Text('${trip.totalNum}天', style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
          )
        ],
      ),
    );
  }

  Widget getPointWidget(){
    TripVo? trip = widget.circle.trip;
    if(trip == null){
      return const SizedBox();
    }
    List<TripPoint>? points = trip.points;
    if(points == null || points.isEmpty){
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          const Text('游玩地点：', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
          Expanded(
            child: Text('${points.first.name}等', style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
          )
        ],
      ),
    );
  }

  void resetState(){
    setState(() {
    });
  }
}
