
import 'dart:ui' as ui;
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/circle_neo/circle_common.dart';
import 'package:freego_flutter/components/comment/comment_page.dart';
import 'package:freego_flutter/components/comment/comment_widget.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/components/user_favorite/user_favorite_util.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/common_map_show.dart';
import 'package:freego_flutter/components/view/menu_action.dart';
import 'package:freego_flutter/components/view/pics_swiper.dart';
import 'package:freego_flutter/components/view/tipoff.dart';
import 'package:freego_flutter/components/view/user_behavior.dart';
import 'package:freego_flutter/config/const_config.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/util/context_util.dart';
import 'package:freego_flutter/util/dialog_util.dart';
import 'package:freego_flutter/util/dictionary_util.dart';
import 'package:freego_flutter/util/gaode_util.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:freego_flutter/util/user_home_director.dart';
import 'package:freego_flutter/util/user_like_util.dart';

class CircleShopPage extends StatelessWidget{
  final CircleShop circle;
  const CircleShopPage(this.circle, {super.key});

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
      body: CircleShopWidget(circle),
    );
  }

}

class CircleShopWidget extends StatefulWidget{
  final CircleShop circle;
  const CircleShopWidget(this.circle, {super.key});

  @override
  State<StatefulWidget> createState() {
    return CircleShopState();
  }

}

class _MyAfterUserLikeHandler implements AfterUserLikeHandler{

  final CircleShopState state;
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

  final CircleShopState state;
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

  final CircleShopState state;
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

  final CircleShopState state;
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

class CircleShopState extends State<CircleShopWidget> with SingleTickerProviderStateMixin{

  static const double AVATAR_SIZE = 68;
  static const double MAKE_FRIEND_SIZE = 28;
  static const double BEHAVIOR_ICON_SIZE = 32;

  Widget svgComment = SvgPicture.asset('svg/comment/comment.svg');

  late _MyAfterUserLikeHandler _afterUserLikeHandler;
  late _MyAfterUserUnlikeHandler _afterUserUnlikeHandler;

  late _MyAfterUserFavoriteHandler _afterUserFavoriteHandler;
  late _MyAfterUserUnFavoriteHandler _afterUserUnFavoriteHandler;

  late AnimationController rightMenuAnim;
  bool rightMenuShow = false;
  static const int RIGHT_MENU_ANIM_MILLI_SECONDS = 150;
  static const double RIGHT_MENU_WIDTH = 100;
  static const double RIGHT_MENU_ITEM_HEIGHT = 40;

  CommonMenuController? menuController;

  @override
  void dispose(){
    UserLikeUtil.removeAfterUserLikeHandler(_afterUserLikeHandler);
    UserLikeUtil.removeAfterUserUnlikeHandler(_afterUserUnlikeHandler);
    UserFavoriteUtil().removeFavoriteHandler(_afterUserFavoriteHandler);
    UserFavoriteUtil().removeUnFavoriteHandler(_afterUserUnFavoriteHandler);
    rightMenuAnim.dispose();
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

    rightMenuAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: RIGHT_MENU_ANIM_MILLI_SECONDS));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        if(rightMenuShow){
          rightMenuShow = false;
          rightMenuAnim.reverse();
          return;
        }
        menuController?.hideMenu();
        menuController = null;
      },
      child: Container(
        color: ThemeUtil.backgroundColor,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonHeader(
                  center: const Text('发现店家', style: TextStyle(color: Colors.white, fontSize: 18),),
                  right: InkWell(
                    onTap: (){
                      menuController?.hideMenu();
                      menuController = null;

                      if(!rightMenuShow){
                        rightMenuAnim.forward();
                      }
                      else{
                        rightMenuAnim.reverse();
                      }
                      rightMenuShow = !rightMenuShow;
                      setState(() {
                      });
                    },
                    child: const Icon(Icons.more_vert_rounded, color: Colors.white,),
                  ),
                ),
                Expanded(
                  child: ListView(
                    physics: const ClampingScrollPhysics(),
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height - ThemeUtil.getStatusBarHeight(ContextUtil.getContext() ?? context) - 50 - CommonHeader.HEADER_HEIGHT
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            getPicSwiperWidget(),
                            getAuthorInfoWidget(),
                            getContentWidget(),
                            getMapWidget(),
                            getCommentWidget(),
                          ],
                        ),
                      ),
                      getUserBehaviorWidget()
                    ],
                  ),
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
                          onPressed: showTipoffModal,
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
        ),
      ),
    );
  }

  void showTipoffModal(){
    Circle circle = widget.circle;
    if(circle.id == null){
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
              return TipOffWidget(targetId: circle.id!, productType: ProductType.circle,);
            }
          );
        }
      }
    });
  }

  Widget getUserBehaviorWidget(){
    CircleShop circle = widget.circle;
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
            onTap: (){
              if(circle.id == null){
                ToastUtil.error('链接不存在');
                return;
              }
              Navigator.of(context).push(MaterialPageRoute(builder: (context){
                return CommentPage(productId: circle.id!, type: ProductType.circle, creatorId: circle.userId,);
              }));
            },
            child: SizedBox(
              width: BEHAVIOR_ICON_SIZE,
              height: BEHAVIOR_ICON_SIZE,
              child: svgComment,
            ),
          ),
          InkWell(
            onTap: (){
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
            child: circle.isLiked == true? 
            const Icon(Icons.favorite_rounded, color: COLOR_ACTIVE, size: BEHAVIOR_ICON_SIZE,) :
            const Icon(Icons.favorite_rounded, color: COLOR_INACTIVE, size: BEHAVIOR_ICON_SIZE,)
          ),
          InkWell(
            onTap: (){
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
            child: circle.isFavorited == true ?
            const Icon(Icons.star_rounded, color: COLOR_ACTIVE, size: BEHAVIOR_ICON_SIZE,) :
            const Icon(Icons.star_rounded, color: COLOR_INACTIVE, size: BEHAVIOR_ICON_SIZE,)
          )
        ],
      ),
    );
  }

  Widget getCommentWidget(){
    CircleShop circle = widget.circle;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('互助讨论区', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 20),),
              const SizedBox(width: 4,),
              Text('（${circle.commentNum}条）', style: const TextStyle(color: Colors.grey, fontSize: 16),),
            ],
          ),
          const SizedBox(height: 10,),
          CommentShowWidget(
            productId: circle.id!,
            type: ProductType.circle,
            ownnerId: circle.userId,
            productName: circle.name,
            onMenuShow: (controller){
              if(rightMenuShow){
                rightMenuShow = false;
                rightMenuAnim.reverse();
              }
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
          ),
        ],
      ),
    );
  }

  Widget getMapWidget(){
    CircleShop circle = widget.circle;
    if(circle.lat == null || circle.lng == null){
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: InkWell(
          onTap: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context){
              return CommonMapShowPage(address: circle.address ?? '', latitude: circle.lat!, longitude: circle.lng!);
            }));
          },
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                child: CircleShopMapShow(latitude: circle.lat!, longitude: circle.lng!,),
              ),
              Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color.fromRGBO(255, 255, 255, 0), Color.fromRGBO(128, 128, 128, 0.8)]
                  )
                ),
                padding: const EdgeInsets.only(bottom: 10),
                alignment: Alignment.bottomCenter,
                child: circle.address != null ?
                Text('地址：${circle.address}', style: const TextStyle(color: Colors.white),) :
                const SizedBox()
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget getContentWidget(){
    CircleShop circle = widget.circle;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(circle.shopName ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
          circle.openTime != null && circle.closeTime != null ?
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text('营业时间： ${circle.openTime} - ${circle.closeTime}', style: const TextStyle(color: ThemeUtil.foregroundColor),),
          ) : const SizedBox(),
          circle.openDays != null ?
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text('营业日期：${circle.openDays}', style: const TextStyle(color: ThemeUtil.foregroundColor),),
          ) : const SizedBox(),
          const SizedBox(height: 10,),
          Text(circle.content ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor, height: 1.5),)
        ],
      ),
    );
  }

  Widget getAuthorInfoWidget(){
    CircleShop circle = widget.circle;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          InkWell(
            onTap: (){
              if(circle.userId != null){
                UserHomeDirector().goUserHome(context: context, userId: circle.userId!);
              }
            },
            child: ClipOval(
              child: SizedBox(
                width: AVATAR_SIZE,
                height: AVATAR_SIZE,
                child: circle.authorHead == null ?
                ThemeUtil.defaultUserHead :
                Image.network(getFullUrl(circle.authorHead!), fit: BoxFit.cover,),
              ),
            ),
          ),
          const SizedBox(width: 10,),
          InkWell(
            onTap: (){
              if(circle.userId != null){
                UserHomeDirector().goUserHome(context: context, userId: circle.userId!);
              }
            },
            child: Text(StringUtil.getLimitedText(circle.authorName ?? '', DictionaryUtil.USERNAME_MAX_LENGTH), style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
          ),
          const SizedBox(width: 10,),
        ],
      ),
    );
  }

  Widget getPicSwiperWidget(){
    CircleShop circle = widget.circle;
    if(circle.pics == null || circle.pics!.isEmpty){
      return const SizedBox();
    }
    List<String> picList = circle.pics!.split(',');
    for(int i = 0; i < picList.length; ++i){
      picList[i] = getFullUrl(picList[i]);
    }
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      clipBehavior: Clip.hardEdge,
      child: PicsSwiper(
        urlBuilder: (idx){
          return picList[idx];
        }, 
        count: picList.length
      ),
    );
  }

  void resetState(){
    if(mounted && context.mounted){
      setState((){
      });
    }
  }
}

class CircleShopMapShow extends StatefulWidget{
  final double latitude;
  final double longitude;
  const CircleShopMapShow({required this.latitude, required this.longitude, super.key});

  @override
  State<StatefulWidget> createState() {
    return CircleShopMapState();
  }

}

class CircleShopMapState extends State<CircleShopMapShow>{

  static const double DEFAULT_ZOOM = 14;
  Set<Marker> markers = {};
  Widget targetPos = SvgPicture.asset('svg/map/location_on.svg');

  @override
  void initState(){
    super.initState();
    Future.delayed(Duration.zero, () async{
      ByteData? byteData = await GaodeUtil.widgetToByteData(
        SizedBox(
          width: 100,
          height: 100,
          child: Directionality(
            textDirection: ui.TextDirection.ltr, 
            child: targetPos
          ),
        )
      );
      BitmapDescriptor icon = BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
      Marker marker = Marker(
        position: LatLng(widget.latitude, widget.longitude),
        icon: icon,
      );
      markers = {marker};
      if(mounted && context.mounted){
        setState(() {
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AMapWidget(
      apiKey: const AMapApiKey(androidKey: ConstConfig.amapApiKeyOfAndroid, iosKey: ConstConfig.amapApiKeyOfIOS),
      initialCameraPosition: CameraPosition(target: LatLng(widget.latitude, widget.longitude), zoom: DEFAULT_ZOOM),
      privacyStatement: const AMapPrivacyStatement(hasContains: true, hasShow: true, hasAgree: true),
      mapType: MapType.navi,
      zoomGesturesEnabled: false,
      buildingsEnabled: false,
      labelsEnabled: true,
      tiltGesturesEnabled: false,
      rotateGesturesEnabled: false,
      scaleEnabled: false,
      scrollGesturesEnabled: false,
      markers: markers,
    );
  }

}
