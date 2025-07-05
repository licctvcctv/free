
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:freego_flutter/components/circle_neo/circle_common.dart';
import 'package:freego_flutter/components/circle_neo/detail/circle_article.dart';
import 'package:freego_flutter/components/circle_neo/view/circle_const.dart';
import 'package:freego_flutter/components/comment/comment_page.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/components/user_favorite/user_favorite_util.dart';
import 'package:freego_flutter/components/view/gardient_opacity.dart';
import 'package:freego_flutter/components/view/image_group_viewer.dart';
import 'package:freego_flutter/components/view/user_behavior.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/util/dialog_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/user_like_util.dart';
import 'package:intl/intl.dart';

class CircleArticleWidget extends StatefulWidget{
  final CircleArticle circle;
  const CircleArticleWidget(this.circle, {super.key});

  @override
  State<StatefulWidget> createState() {
    return CircleArticleState();
  }

}

class _MyAfterUserLikeHandler implements AfterUserLikeHandler{

  final CircleArticleState state;
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

  final CircleArticleState state;
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

  final CircleArticleState state;
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

  final CircleArticleState state;
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

class CircleArticleState extends State<CircleArticleWidget>{

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
    CircleArticle circle = widget.circle;
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
                  Text(circle.authorName ?? '', style: const TextStyle(fontSize: 18),),
                  circle.createTime == null ?
                  const SizedBox() :
                  Text(DateFormat('yyyy.MM.dd').format(circle.createTime!), style: const TextStyle(color: Colors.grey),)
                ],
              ),
              ],
            ),
            const Divider(),
            TextButton(
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 10),
                alignment: Alignment.centerLeft,
              ),
              onPressed: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                  return CircleArticlePage(circle);
                }));
              }, 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(circle.title ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 18, fontWeight: FontWeight.bold),),
                  getKeywordsWidget(),
                  getContentWidget(),
                  getImagesWidget(),
                ],
              )
            ),
            const Divider(),
            getFooterWidget()
          ],
        ),
      ),
    );
  }

Widget getFooterWidget() {
  CircleArticle circle = widget.circle;
  return SizedBox(
    height: 40,
    child: Row(
      children: [
        Expanded(
          child: Text(
            circle.location ?? '',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: ThemeUtil.foregroundColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // 将三个图标包裹在一个 Row 中并居中对齐
        Row(
          mainAxisAlignment: MainAxisAlignment.center, // 居中对齐
          children: [
            // 评论图标
            SizedBox(
              width: 40,
              child: IconButton(
                onPressed: () {
                  if (circle.id == null) return;
                  DialogUtil.loginRedirectConfirm(context, callback: (isLogined) {
                    if (isLogined && mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CommentPage(
                            productId: circle.id!,
                            type: ProductType.circle,
                            creatorId: circle.userId,
                          ),
                        ),
                      );
                    }
                  });
                },
                icon: const Icon(Icons.comment, size: 24, color: COLOR_INACTIVE),
              ),
            ),
            // 喜欢图标
            SizedBox(
              width: 40,
              child: IconButton(
                onPressed: () {
                  if (circle.id == null) return;
                  DialogUtil.loginRedirectConfirm(context, callback: (isLogined) {
                    if (isLogined && mounted) {
                      if (circle.isLiked == true) {
                        UserLikeUtil.unlike(circle.id!, ProductType.circle);
                      } else {
                        UserLikeUtil.like(circle.id!, ProductType.circle);
                      }
                    }
                  });
                },
                icon: circle.isLiked == true
                    ? const Icon(Icons.favorite_sharp, size: 24, color: COLOR_ACTIVE)
                    : const Icon(Icons.favorite_sharp, size: 24, color: COLOR_INACTIVE),
              ),
            ),
            // 收藏图标
            SizedBox(
              width: 40,
              child: IconButton(
                onPressed: () {
                  if (circle.id == null) return;
                  DialogUtil.loginRedirectConfirm(context, callback: (isLogined) {
                    if (isLogined && mounted) {
                      if (circle.isFavorited == true) {
                        UserFavoriteUtil().unFavorite(productId: circle.id!, type: ProductType.circle);
                      } else {
                        UserFavoriteUtil().favorite(productId: circle.id!, type: ProductType.circle);
                      }
                    }
                  });
                },
                icon: circle.isFavorited == true
                    ? const Icon(Icons.star_rate_rounded, size: 26, color: COLOR_ACTIVE)
                    : const Icon(Icons.star_rate_rounded, size: 26, color: COLOR_INACTIVE),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}


  Widget getContentWidget(){
    String? content = widget.circle.content;
    if(content == null){
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: GradientOpacityWidget(
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: CircleWidgetConsts.CONTENT_HEIGHT_MAX
          ),
          child: Wrap(
            clipBehavior: Clip.hardEdge,
            children: [
              HtmlWidget(content, textStyle: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),)
            ],
          )
        )
      ),
    );
  }

  Widget getKeywordsWidget(){
    String? keywords = widget.circle.keywords;
    if(keywords == null || keywords.trim().isEmpty){
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('关键词：', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
          Expanded(
            child: Text(keywords, style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
          )
        ],
      ),
    );
  }

Widget getImagesWidget() {
  if (widget.circle.pics == null) return const SizedBox();
  List<String> picList = widget.circle.pics!.split(',');
  if (picList.isEmpty) return const SizedBox();

  // 计算可用宽度（屏幕宽度的60%，两边各留20%空白）
  final screenWidth = MediaQuery.of(context).size.width;
  final availableWidth = screenWidth * 0.6;
  
  // 计算图片尺寸
  const spacing = 5.0;
  final itemSize = (availableWidth - 2 * spacing) / 3;

  return Center(
    child: SizedBox(
      width: availableWidth,
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
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
      ),
    ),
  );
}
  void resetState(){
    setState(() {
    });
  }
}
