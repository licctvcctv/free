
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/circle_neo/circle_common.dart';
import 'package:freego_flutter/components/circle_neo/circle_http.dart';
import 'package:freego_flutter/components/circle_neo/detail/circle_activity.dart';
import 'package:freego_flutter/components/circle_neo/detail/circle_article.dart';
import 'package:freego_flutter/components/circle_neo/detail/circle_question.dart';
import 'package:freego_flutter/components/circle_neo/detail/circle_shop.dart';
import 'package:freego_flutter/components/guide_neo/guide_http.dart';
import 'package:freego_flutter/components/guide_neo/guide_map_show.dart';
import 'package:freego_flutter/components/guide_neo/guide_model.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/components/user_favorite/user_favorite_http.dart';
import 'package:freego_flutter/components/user_favorite/user_favorite_model.dart';
import 'package:freego_flutter/components/user_favorite/user_favorite_util.dart';
import 'package:freego_flutter/components/video/video_home.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/custom_indicator.dart';
import 'package:freego_flutter/components/view/item_box_wrap.dart';
import 'package:freego_flutter/components/view/keep_alive_wrapper.dart';
import 'package:freego_flutter/components/view/notify_empty.dart';
import 'package:freego_flutter/components/view/notify_loading.dart';
import 'package:freego_flutter/components/view/titled_swiper.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/http/http_video.dart';
import 'package:freego_flutter/components/video/video_model.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';

class UserFavoriteHomePage extends StatelessWidget{
  const UserFavoriteHomePage({super.key});

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
      body: const UserFavoriteHomeWidget(),
    );
  }
  
}

class UserFavoriteHomeWidget extends StatefulWidget{
  const UserFavoriteHomeWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return UserFavoriteHomeState();
  }

}

class _MyAfterUnFavoriteHandler extends AfterUserUnFavoriteHandler{
  final UserFavoriteHomeState state;
  _MyAfterUnFavoriteHandler(this.state);
  
  @override
  void handle(int productId, ProductType productType) {
    switch(productType){
      case ProductType.video:
        state.videoList?.removeWhere((element) => element.productId == productId);
        state.resetState();
        break;
      case ProductType.guide:
        state.guideList?.removeWhere((element) => element.productId == productId);
        state.resetState();
        break;
      case ProductType.circle:
        state.circleList?.removeWhere((element) => element.productId == productId);
        state.resetState();
        break;
      default:
    }
  }

}

class UserFavoriteHomeState extends State<UserFavoriteHomeWidget>{

  static const List<String> texts = ['视频', '攻略', '圈子'];
  List<UserFavorite>? videoList;
  List<UserFavorite>? guideList;
  List<UserFavorite>? circleList;

  static const int VIDEO_INDEX = 0;
  static const int GUIDE_INDEX = 1;
  static const int CIRCLE_INDEX = 2;
  int currentIndex = 0;

  TitledSwiperController swiperController = TitledSwiperController();

  late _MyAfterUnFavoriteHandler _afterUnFavoriteHandler;

  @override
  void dispose(){
    UserFavoriteUtil().removeUnFavoriteHandler(_afterUnFavoriteHandler);
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    swiperController.onChange = (index) {
      currentIndex = index;
      switch(currentIndex){
        case VIDEO_INDEX:
          if(videoList == null){
            refreshVideo();
          }
          break;
        case GUIDE_INDEX:
          if(guideList == null){
            refreshGuide();
          }
          break;
        case CIRCLE_INDEX:
          if(circleList == null){
            refreshCircle();
          }
      }
    };
    refreshVideo();
    _afterUnFavoriteHandler = _MyAfterUnFavoriteHandler(this);
    UserFavoriteUtil().addUnFavoriteHandler(_afterUnFavoriteHandler);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeUtil.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonHeader(
            center: Text('我的收藏', style: TextStyle(color: Colors.white, fontSize: 18),),
          ),
          Expanded(
            child: TitledSwiper(
              titles: getTitles(),
              pages: getPages(),
              controller: swiperController,
              traceHistory: true,
            ),
          )
        ],
      ),
    );
  }

  List<Widget> getTitles(){
    List<Widget> widgets = [];
    for(String title in texts){
      widgets.add(
        Text(title, style: const TextStyle(color: Colors.black, fontSize: 16),)
      );
    }
    return widgets;
  }

  List<Widget> getPages(){
    List<Widget> widgets = [];
    widgets.add(getVideoPage());
    widgets.add(getGuidePage());
    widgets.add(getCirclePage());
    return widgets;
  }

  Future refreshCircle() async{
    List<UserFavorite>? tmpList = await UserFavoriteHttp().list(type: ProductType.circle);
    circleList ??= [];
    if(tmpList != null){
      circleList = tmpList;
      if(mounted && context.mounted){
        setState(() {
        });
      }
    }
  }

  Future searchCircle() async{
    int? maxId;
    if(circleList != null && circleList!.isNotEmpty){
      maxId = circleList!.last.id;
    }
    List<UserFavorite>? tmpList = await UserFavoriteHttp().list(type: ProductType.circle, maxId: maxId);
    if(tmpList == null){
      ToastUtil.error('好像出了点小问题');
      return;
    }
    if(tmpList.isEmpty){
      ToastUtil.hint('已经没有了呢');
      return;
    }
    circleList ??= [];
    circleList!.addAll(tmpList);
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }

  Widget getCirclePage(){
    if(circleList == null){
      return const NotifyLoadingWidget();
    }
    if(circleList!.isEmpty){
      return const NotifyEmptyWidget();
    }
    double width = (MediaQuery.of(context).size.width - 40) / 2;
    double height = width * 1.4;
    return KeepAliveWrapperWidget(
      content: CustomIndicatorWidget(
        content: Container(
          margin: const EdgeInsets.only(top: 10),
          alignment: Alignment.topCenter,
          child: ItemBoxWrap(
            builder: (index){
              UserFavorite circle = circleList![index];
              String? cover = circle.cover;
              if(cover != null){
                cover = getFullUrl(cover);
              }
              return getItemBox(
                width: width, 
                height: height, 
                cover: cover, 
                name: circle.name, 
                onClick: () async{
                  if(circle.productId == null){
                    ToastUtil.error('数据错误');
                    return;
                  }
                  Circle? result = await CircleHttp().getCircle(id: circle.productId!);
                  if(result == null){
                    ToastUtil.error('目标不存在');
                    return;
                  }
                  if(mounted && context.mounted){
                    if(result is CircleActivity){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context){
                        return CircleActivityPage(result);
                      }));
                    }
                    else if(result is CircleArticle){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context){
                        return CircleArticlePage(result);
                      }));
                    }
                    else if(result is CircleQuestion){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context){
                        return CircleQuestionPage(result);
                      }));
                    }
                    else if(result is CircleShop){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context){
                        return CircleShopPage(result);
                      }));
                    }
                  }
                },
                onLongPress: (){
                  if(circle.productId == null){
                    ToastUtil.error('数据错误');
                    return;
                  }
                  showMenu(circle.productId!, ProductType.circle);
                }
              );
            },
            count: circleList!.length,
            childWidth: width,
            childHeight: height,
            column: 2,
          ),
        ),
        touchTop: refreshCircle,
        touchBottom: searchCircle,
      ),
    );
  }

  void showMenu(int productId, ProductType type){
    showModalBottomSheet(
      isDismissible: true,
      isScrollControlled: true,
      context: context,
      builder: (context){
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
          child: TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap
            ),
            onPressed: (){
              Navigator.of(context).pop();
              UserFavoriteUtil().unFavorite(productId: productId, type: type);
            },
            child: Container(
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border.symmetric(horizontal: BorderSide(color: ThemeUtil.buttonColor))
              ),
              alignment: Alignment.center,
              child: const Text('取消收藏', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 18),),
            ),
          ),
        );
      }
    );
  }

  Future refreshGuide() async{
    List<UserFavorite>? tmpList = await UserFavoriteHttp().list(type: ProductType.guide);
    guideList ??= [];
    if(tmpList != null){
      guideList = tmpList;
      if(mounted && context.mounted){
        setState(() {
        });
      }
    }
  }

  Future searchGuide() async{
    int? maxId;
    if(guideList != null && guideList!.isNotEmpty){
      maxId = guideList!.last.id;
    }
    List<UserFavorite>? tmpList = await UserFavoriteHttp().list(type: ProductType.guide, maxId: maxId);
    if(tmpList == null){
      ToastUtil.error('好像出了点小问题');
      return;
    }
    if(tmpList.isEmpty){
      ToastUtil.hint('已经没有了呢');
      return;
    }
    guideList ??= [];
    guideList!.addAll(tmpList);
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }

  Widget getGuidePage(){
    if(guideList == null){
      return const NotifyLoadingWidget();
    }
    if(guideList!.isEmpty){
      return const NotifyEmptyWidget();
    }
    double width = (MediaQuery.of(context).size.width - 40) / 2;
    double height = width * 1.4;
    return KeepAliveWrapperWidget(
      content: CustomIndicatorWidget(
        content: Container(
          margin: const EdgeInsets.only(top: 10),
          alignment: Alignment.topCenter,
          child: ItemBoxWrap(
            builder: (index){
              UserFavorite guide = guideList![index];
              String? cover = guide.cover;
              if(cover != null){
                cover = getFullUrl(cover);
              }
              return getItemBox(
                width: width, 
                height: height, 
                cover: cover,
                name: guide.name, 
                onClick: () async{
                  if(guide.productId == null){
                    ToastUtil.error('数据错误');
                    return;
                  }
                  Guide? result = await GuideHttp().get(id: guide.productId!);
                  if(result == null){
                    ToastUtil.error('目标不存在');
                    return;
                  }
                  if(mounted && context.mounted){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context){
                      return GuideMapShowPage(result);
                    }));
                  }
                },
                onLongPress: (){
                  if(guide.productId == null){
                    ToastUtil.error('数据错误');
                    return;
                  }
                  showMenu(guide.productId!, ProductType.guide);
                }
              );
            },
            count: guideList!.length,
            childWidth: width,
            childHeight: height,
            column: 2,
          ),
        ),
        touchTop: refreshGuide,
        touchBottom: searchGuide,
      ),
    );
  }

  Future refreshVideo() async{
    List<UserFavorite>? tmpList = await UserFavoriteHttp().list(type: ProductType.video);
    videoList ??= [];
    if(tmpList != null){
      videoList = tmpList;
      if(mounted && context.mounted){
        setState(() {
        });
      }
    }
  }
  
  Future searchVideo() async{
    int? maxId;
    if(videoList != null && videoList!.isNotEmpty){
      maxId = videoList!.last.id;
    }
    List<UserFavorite>? tmpList = await UserFavoriteHttp().list(type: ProductType.video, maxId: maxId);
    if(tmpList == null){
      ToastUtil.error('好像出了点小问题');
      return;
    }
    if(tmpList.isEmpty){
      ToastUtil.hint('已经没有了呢');
      return;
    }
    videoList ??= [];
    videoList!.addAll(tmpList);
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }

  Widget getVideoPage(){
    if(videoList == null){
      return const NotifyLoadingWidget();
    }
    if(videoList!.isEmpty){
      return const NotifyEmptyWidget();
    }
    double width = (MediaQuery.of(context).size.width - 40) / 2;
    double height = width * 1.4;
    return KeepAliveWrapperWidget(
      content: CustomIndicatorWidget(
        content: Container(
          margin: const EdgeInsets.only(top: 10),
          alignment: Alignment.topCenter,
          child: ItemBoxWrap(
            builder: (index){
              UserFavorite video = videoList![index];
              String? cover = video.cover;
              if(cover != null){
                cover = getFullUrl(cover);
              }
              return getItemBox(
                width: width, 
                height: height, 
                cover: cover, 
                name: video.name, 
                onClick: () async{
                  if(video.productId == null){
                    ToastUtil.error('数据错误');
                    return;
                  }
                  VideoModel? result = await HttpVideo.getById(video.productId!);
                  if(result == null){
                    ToastUtil.error('目标不存在');
                    return;
                  }
                  if(mounted && context.mounted){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context){
                      return VideoHomePage(initVideo: result,);
                    }));
                  }
                },
                onLongPress: (){
                  if(video.productId == null){
                    ToastUtil.error('数据错误');
                    return;
                  }
                  showMenu(video.productId!, ProductType.video);
                }
              );
            },
            count: videoList!.length,
            childWidth: width,
            childHeight: height,
            column: 2,
          ),
        ),
        touchTop: refreshVideo,
        touchBottom: searchVideo,
      ),
    );
  }

  ItemBox getItemBox({required double width, required double height, String? cover, String? name, Function()? onClick, Function()? onLongPress}){
    return ItemBox(
      width: width, 
      height: height, 
      onClick: onClick,
      onLongPress: onLongPress,
      cover: cover == null ?
      Image.asset('images/bg.png', fit: BoxFit.cover, width: double.infinity, height: double.infinity,) :
      Image.network(cover, fit: BoxFit.cover, width: double.infinity, height: double.infinity,),
      bottom: Container(
        width: width,
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.3)),
          child: Container(
            padding: const EdgeInsets.all(10),
            alignment: Alignment.center,
            width: double.infinity,
            child: Text(
              name ?? '',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      )
    );
  }

  void resetState(){
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }
}
