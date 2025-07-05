
import 'package:amap_flutter_base/amap_flutter_base.dart' as amap_flutter_base;
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart' as flutter_html;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/comment/comment_page.dart';
import 'package:freego_flutter/components/comment/comment_widget.dart';
import 'package:freego_flutter/components/facade/near_http.dart';
import 'package:freego_flutter/components/guide_neo/guide_model.dart';
import 'package:freego_flutter/components/hotel_neo/api/hotel_api.dart';
import 'package:freego_flutter/components/hotel_neo/api/local_hotel_api.dart';
import 'package:freego_flutter/components/hotel_neo/api/panhe_hotel_api.dart';
import 'package:freego_flutter/components/order_neo/order_common.dart' as order_common;
import 'package:freego_flutter/components/hotel_neo/hotel_common.dart';
import 'package:freego_flutter/components/hotel_neo/hotel_home_freego.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/components/restaurant/restaurant_common.dart' as restaurant_model;
import 'package:freego_flutter/components/restaurant/restaurant_common.dart';
import 'package:freego_flutter/components/restaurant/restaurant_home.dart';
import 'package:freego_flutter/components/restaurant/restaurant_api.dart';
import 'package:freego_flutter/components/scenic/api/local_scenic_api.dart';
import 'package:freego_flutter/components/scenic/api/panhe_scenic_api.dart';
import 'package:freego_flutter/components/scenic/api/scenic_api.dart';
import 'package:freego_flutter/components/scenic/scenic_common.dart';
import 'package:freego_flutter/components/scenic/scenic_home_freego.dart';
import 'package:freego_flutter/components/user_favorite/user_favorite_util.dart';
import 'package:freego_flutter/components/user_reward/user_reward_http.dart';
import 'package:freego_flutter/components/view/menu_action.dart';
import 'package:freego_flutter/components/view/radio_group.dart';
import 'package:freego_flutter/components/view/tipoff.dart';
import 'package:freego_flutter/config/const_config.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/http/http_gaode.dart';
import 'package:freego_flutter/http/http_gaode_route.dart';
import 'package:freego_flutter/util/context_util.dart';
import 'package:freego_flutter/util/dialog_util.dart';
import 'package:freego_flutter/util/gaode_util.dart';
import 'package:freego_flutter/util/local_service_util.dart';
import 'package:freego_flutter/util/local_user.dart';
import 'package:freego_flutter/util/order_pay_util.dart';
import 'package:freego_flutter/util/permission_util.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:freego_flutter/util/user_gift/user_gift_util.dart';
import 'package:freego_flutter/util/user_home_director.dart';
import 'package:freego_flutter/util/user_like_util.dart';
import 'package:permission_handler/permission_handler.dart';

class GuideMapShowPage extends StatelessWidget{
  final Guide guide;
  const GuideMapShowPage(this.guide, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: GuideMapShowWidget(guide),
    );
  }
  
}

class GuideMapShowWidget extends StatefulWidget{
  final Guide guide;
  const GuideMapShowWidget(this.guide, {super.key});

  @override
  State<StatefulWidget> createState() {
    return GuideMapShowState();
  }

}

enum NearType{
  hotel,
  scenic,
  restaurnt
}

class _MyAfterUserLikeHandler implements AfterUserLikeHandler{

  final GuideMapShowState state;
  const _MyAfterUserLikeHandler(this.state);

  @override
  void handle(int id, ProductType type) {
    if(type != ProductType.guide){
      return;
    }
    Guide guide = state.widget.guide;
    if(guide.id != id){
      return;
    }
    if(guide.isLiked != true){
      guide.isLiked = true;
      guide.likeNum = (guide.likeNum ?? 0) + 1;
    }
    state.resetState();
  }

}

class _MyAfterUserUnlikeHandler implements AfterUserUnlikeHandler{

  final GuideMapShowState state;
  const _MyAfterUserUnlikeHandler(this.state);

  @override
  void handle(int id, ProductType type) {
    if(type != ProductType.guide){
      return;
    }
    Guide guide = state.widget.guide;
    if(guide.id != id){
      return;
    }
    if(guide.isLiked == true){
      guide.isLiked = false;
      guide.likeNum = (guide.likeNum ?? 1) - 1;
    }
    state.resetState();
  }

}

class _MyAfterUserFavoriteHandler implements AfterUserFavoriteHandler{

  final GuideMapShowState state;
  const _MyAfterUserFavoriteHandler(this.state);
  @override
  void handle(int productId, ProductType type) {
    if(type != ProductType.guide){
      return;
    }
    Guide guide = state.widget.guide;
    if(guide.id != productId){
      return;
    }
    if(guide.isFavorited != true){
      guide.isFavorited = true;
      guide.favoriteNum = (guide.favoriteNum ?? 0) + 1;
    }
    state.resetState();
  }
  
}

class _MyAfterUserUnFavoriteHandler implements AfterUserUnFavoriteHandler{

  final GuideMapShowState state;
  const _MyAfterUserUnFavoriteHandler(this.state);

  @override
  void handle(int productId, ProductType type) {
    if(type != ProductType.guide){
      return;
    }
    Guide guide = state.widget.guide;
    if(guide.id != productId){
      return;
    }
    if(guide.isFavorited == true){
      guide.isFavorited = false;
      guide.favoriteNum = (guide.favoriteNum ?? 1) - 1;
    }
    state.resetState();
  }

}

class GuideMapShowState extends State<GuideMapShowWidget> with TickerProviderStateMixin{

  static const amap_flutter_base.LatLng DEFAULT_POS = amap_flutter_base.LatLng(39.909187, 116.397451);
  static const double DEFAULT_ZOOM = 12;
  double zoom = DEFAULT_ZOOM;

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  late AMapController mapController;

  LatLng? userPos;
  AMapFlutterLocation locationUtil = AMapFlutterLocation();

  int currentDay = 1;
  List<GuidePoint> currentPointList = [];
  List<List<LatLng>> polylineList = [];

  static const double GUIDE_POINT_MARKER_SIZE = 140;
  static const double POI_AROUND_MARKER_SIZE = 100;
  Widget svgPointSelected = SvgPicture.asset('svg/trip/trip_point_center.svg');
  Widget svgPointAvailable = SvgPicture.asset('svg/trip/trip_point_around.svg');

  GuidePoint? selectedPoint;

  static const int NEAR_SLIDE_MILLI_SECONDS = 300;
  static const int NEAR_SLIDE_GAP_MILLI_SECONDS = 50;
  late AnimationController nearHotelSlideAnim;
  late AnimationController nearScenicSlideAnim;
  late AnimationController nearRestaurantSlideAnim;
  bool isNearMenuDisplayed = false;
  RadioGroupController radioGroupController = RadioGroupController();
  NearType? nearType;
  List<Hotel>? hotelList;
  List<Scenic>? scenicList;
  List<Restaurant>? restaurantList;
  GuidePoint? nearCenterPoint;
  Object? selectedAroundPoint;
  double searchRadius  = 50 * 1000;
  LatLng? selectedPosition;
  String? targetCity;

  static const double USER_BEHAVIOR_ICON_SIZE = 40;
  Widget svgLikeWidget = SvgPicture.asset('svg/like.svg', color: Colors.lightBlue,);
  Widget svgLikeOnWidget = SvgPicture.asset('svg/like_on.svg');
  Widget svgCommentWidget = SvgPicture.asset('svg/comment.svg', color: Colors.lightBlue);

  late _MyAfterUserLikeHandler _afterUserLikeHandler;
  late _MyAfterUserUnlikeHandler _afterUserUnlikeHandler;

  late _MyAfterUserFavoriteHandler _afterUserFavoriteHandler;
  late _MyAfterUserUnFavoriteHandler _afterUserUnFavoriteHandler;

  Widget svgDragUpFilled = SvgPicture.asset('svg/drag_up_filled.svg');
  static const double DRAG_UP_PANEL_SIZE = 50;
  DraggableScrollableController draggableController = DraggableScrollableController();

  late AnimationController rightMenuAnim;
  bool rightMenuShow = false;
  static const int RIGHT_MENU_ANIM_MILLI_SECONDS = 150;
  static const double RIGHT_MENU_WIDTH = 100;
  static const double RIGHT_MENU_ITEM_HEIGHT = 40;

  CommonMenuController? menuController;

  @override
  void dispose(){
    radioGroupController.dispose();
    nearHotelSlideAnim.dispose();
    nearScenicSlideAnim.dispose();
    nearRestaurantSlideAnim.dispose();
    locationUtil.destroy();
    mapController.disponse();

    UserLikeUtil.removeAfterUserLikeHandler(_afterUserLikeHandler);
    UserLikeUtil.removeAfterUserUnlikeHandler(_afterUserUnlikeHandler);
    UserFavoriteUtil().removeFavoriteHandler(_afterUserFavoriteHandler);
    UserFavoriteUtil().removeUnFavoriteHandler(_afterUserUnFavoriteHandler);

    draggableController.dispose();
    rightMenuAnim.dispose();

    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    startLocation();
    nearHotelSlideAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: NEAR_SLIDE_MILLI_SECONDS));
    nearScenicSlideAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: NEAR_SLIDE_MILLI_SECONDS));
    nearRestaurantSlideAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: NEAR_SLIDE_MILLI_SECONDS));

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

  void showMenu(){
    rightMenuAnim.forward();
    rightMenuShow = true;
  }

  void hideMenu(){
    rightMenuAnim.reverse();
    rightMenuShow = false;
  }

  Future onCameraMove(CameraPosition cameraMove) async{
    zoom = cameraMove.zoom;
    if(selectedPosition == null){
      return;
    }
    double scale = GaodeUtil.zoomToScale(zoom.floor()) * (zoom.floor() + 1 - zoom) + GaodeUtil.zoomToScale(zoom.floor() + 1) * (zoom - zoom.floor());
    double radius = scale * MediaQuery.of(context).size.width / 50;
    if(radius < 2000){
      return;
    }
    double ratio = radius / searchRadius;
    if(ratio > 1.2 || ratio < 0.8){
      searchRadius = radius;
      if(nearType == NearType.hotel){
        menuChooseHotel();
        if(nearType == NearType.hotel){
          if(selectedAroundPoint is Hotel){
            Hotel selected = selectedAroundPoint as Hotel;
            hotelList!.insert(0, selected);
          }
          drawMarker();
        }
      }
      else if(nearType == NearType.scenic){
        menuChooseScenic();
        if(nearType == NearType.scenic){
          if(selectedAroundPoint is Scenic){
            scenicList!.insert(0, selectedAroundPoint as Scenic);
          }
          drawMarker();
        }
      }
    }
    drawMarker();
  }

  @override
  Widget build(BuildContext context) {
    AMapWidget mapWidget = AMapWidget(
      apiKey: const amap_flutter_base.AMapApiKey(androidKey: ConstConfig.amapApiKeyOfAndroid, iosKey: ConstConfig.amapApiKeyOfIOS),
      onMapCreated: (controller){
        mapController = controller;
        chooseDay(currentDay);
        drawMarker();
      },
      onCameraMove: onCameraMove,
      onTap: (latlng){
        selectedPoint = null;
        selectedAroundPoint = null;
        radioGroupController.setValue(null);
        hideNearMenu();
        setState(() {
        });
        drawMarker();
      },
      initialCameraPosition: const CameraPosition(target: DEFAULT_POS, zoom: DEFAULT_ZOOM),
      privacyStatement: const amap_flutter_base.AMapPrivacyStatement(hasContains: true, hasShow: true, hasAgree: true),
      mapType: MapType.navi,
      zoomGesturesEnabled: true,
      buildingsEnabled: false,
      labelsEnabled: true,
      tiltGesturesEnabled: false,
      rotateGesturesEnabled: false,
      markers: markers,
      polylines: polylines,
    );

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        if(rightMenuShow){
          hideMenu();
          return;
        }
        menuController?.hideMenu();
        menuController = null;
      },
      child: Stack(
        children: [
          Stack(
            children: [
              Transform.scale(
                scale: 1.1,
                alignment: Alignment.topCenter,
                child: mapWidget,
              ),
              const Positioned(
                left: 0,
                bottom: 0,
                child: Text('高德地图', style: TextStyle(color: Color.fromRGBO(78, 89, 105, 0.6))),
              )
            ],
          ),
          Positioned(
            top: ThemeUtil.getStatusBarHeight(ContextUtil.getContext()!) + 60,
            left: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: (){
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(204, 204, 204, 0.5),
                      borderRadius: BorderRadius.horizontal(right: Radius.circular(20))
                    ),
                    alignment: Alignment.centerLeft,
                    child: const Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Icon(Icons.arrow_back_ios_new, color: ThemeUtil.foregroundColor,),
                    ),
                  ),
                ),
                getDayWidget(),
              ],
            ),
          ),
          Positioned(
            right: 0,
            top: 60 + ThemeUtil.getStatusBarHeight(ContextUtil.getContext()!),
            child: Offstage(
              offstage: !isNearMenuDisplayed,
              child: getNearMenuWidget(),
            ),
          ),
          getInfoWidget(),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: getBottomBlock()
          ),
        ],
      ),
    );
  }

  Widget getInfoWidget(){
    double screenHeight = MediaQuery.of(context).size.height;
    const double paddingVertical = 10;
    double minSizeRatio = (DRAG_UP_PANEL_SIZE + 2 * paddingVertical) / screenHeight;

    Guide guide = widget.guide;
    int commentNum = guide.commentNum ?? 0;
    int likeNum = guide.likeNum ?? 0;
    int favoriteNum = guide.favoriteNum ?? 0;
    return DraggableScrollableSheet(
      minChildSize: minSizeRatio,
      initialChildSize: minSizeRatio,
      maxChildSize: 1,
      controller: draggableController,
      builder: (context, scrollController) {
        return ListView(
          padding: EdgeInsets.zero,
          controller: scrollController,
          physics: const ClampingScrollPhysics(),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, paddingVertical, 0, paddingVertical),
                  child: InkWell(
                    onTap: (){
                      draggableController.animateTo(1, duration: const Duration(milliseconds: 350), curve: Curves.ease);
                    },
                    child: SizedBox(
                      width: DRAG_UP_PANEL_SIZE,
                      height: DRAG_UP_PANEL_SIZE,
                      child: svgDragUpFilled,
                    ),
                  ),
                )
              ],
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(16))
              ),
              constraints: BoxConstraints(
                minHeight: screenHeight - (DRAG_UP_PANEL_SIZE + 2 * paddingVertical)
              ),
              padding: const EdgeInsets.all(16),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Wrap(
                              spacing: 0,
                              children: [
                                Text(guide.title ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                if((guide.giftNum ?? 0) > 0)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('（', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Image.asset('images/present-box.png'),
                                    ),
                                    Text(' ${guide.giftNum}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ThemeUtil.buttonColor),),
                                    const Text('）', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),)
                                  ],
                                )
                              ],
                            )
                          ),
                          InkWell(
                            onTap: (){
                              menuController?.hideMenu();
                              menuController = null;
                              if(rightMenuShow){
                                hideMenu();
                              }
                              else{
                                showMenu();
                              }
                            },
                            child: const Icon(Icons.more_vert_rounded, color: ThemeUtil.foregroundColor,),
                          )
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () async{
                              bool isLogin = await DialogUtil.loginRedirectConfirm(context);
                              if(!isLogin){
                                return;
                              }
                              showRewardDialog();
                            },
                            child: Column(
                              children: const[
                                SizedBox(
                                  width: USER_BEHAVIOR_ICON_SIZE,
                                  height: USER_BEHAVIOR_ICON_SIZE,
                                  child: Icon(Icons.attach_money_rounded, color: Colors.lightBlue, size: USER_BEHAVIOR_ICON_SIZE,),
                                ),
                                SizedBox(height: 10,),
                                Text('打赏', style: TextStyle(color: ThemeUtil.foregroundColor),)
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: (){
                              if(guide.id == null){
                                return;
                              }
                              Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                return CommentPage(productId: guide.id!, type: ProductType.guide,);
                              }));
                            }, 
                            child: Column(
                              children: [
                                SizedBox(
                                  width: USER_BEHAVIOR_ICON_SIZE,
                                  height: USER_BEHAVIOR_ICON_SIZE,
                                  child: svgCommentWidget,
                                ),
                                const SizedBox(height: 10,),
                                Text('评论${commentNum <= 0 ? '' : '(${StringUtil.getCountStr(commentNum)})'}', style: const TextStyle(color: ThemeUtil.foregroundColor)),
                              ],
                            )
                          ),
                          TextButton(
                            onPressed: () async{
                              if(guide.id == null){
                                ToastUtil.error('数据错误');
                                return;
                              }
                              await DialogUtil.loginRedirectConfirm(context, hint: "需要登录后才能点赞，是否登录？");
                              if(!LocalUser.isLogined()){
                                return;
                              }
                              if(guide.isLiked == true){
                                await UserLikeUtil.unlike(guide.id!, ProductType.guide);
                              }
                              else{
                                await UserLikeUtil.like(guide.id!, ProductType.guide);
                              }
                            }, 
                            child: Column(
                              children: [
                                SizedBox(
                                  width: USER_BEHAVIOR_ICON_SIZE,
                                  height: USER_BEHAVIOR_ICON_SIZE,
                                  child: guide.isLiked == true ?
                                  svgLikeOnWidget :
                                  svgLikeWidget
                                ),
                                const SizedBox(height: 10,),
                                Text('点赞${likeNum <= 0 ? '' : '(${StringUtil.getCountStr(likeNum)})'}', style: const TextStyle(color: ThemeUtil.foregroundColor),)
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () async{
                              if(guide.id == null){
                                ToastUtil.error('数据错误');
                                return;
                              }
                              await DialogUtil.loginRedirectConfirm(context, hint: '需要登录后才能收藏，是否登录？');
                              if(!LocalUser.isLogined()){
                                return;
                              }
                              if(guide.isFavorited == true){
                                UserFavoriteUtil().unFavorite(productId: guide.id!, type: ProductType.guide);
                              }
                              else{
                                UserFavoriteUtil().favorite(productId: guide.id!, type: ProductType.guide);
                              }
                            },
                            child: Column(
                              children: [
                                SizedBox(
                                  width: USER_BEHAVIOR_ICON_SIZE,
                                  height: USER_BEHAVIOR_ICON_SIZE,
                                  child: guide.isFavorited == true ?
                                  const Icon(Icons.star_rounded, color: Colors.redAccent, size: USER_BEHAVIOR_ICON_SIZE,) :
                                  const Icon(Icons.star_rounded, color: Colors.lightBlue, size: USER_BEHAVIOR_ICON_SIZE,)
                                ),
                                const SizedBox(height: 10,),
                                Text('收藏${favoriteNum <= 0 ? '' : '(${StringUtil.getCountStr(favoriteNum)})'}', style: const TextStyle(color: ThemeUtil.foregroundColor)),
                              ]
                            ),
                          )
                        ],
                      ),
                      const Divider(),
                      CommentShowWidget(
                        productId: guide.id!,
                        type: ProductType.guide,
                        ownnerId: guide.userId,
                        productName: guide.title,
                        onMenuShow: (controller){
                          if(rightMenuShow){
                            hideMenu();
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
                                  if(guide.id == null){
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
                                            return TipOffWidget(targetId: guide.id!, productType: ProductType.guide,);
                                          }
                                        );
                                      }
                                    }
                                  });
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
              ),
            ),
          ],
        );
      },
    );
  }

  Widget getBottomBlock(){
    if(selectedAroundPoint != null){
      if(selectedAroundPoint is Hotel){
        Hotel hotel = selectedAroundPoint as Hotel;
        String? cover = hotel.cover;
        if(cover != null){
          cover = getFullUrl(cover);
        }
        return AroundPointBlock(
          name: hotel.name,
          address: hotel.address,
          score: hotel.score,
          price: hotel.price,
          mainImage: cover,
          onClick: () async{
            if(hotel.id == null && (hotel.outerId == null || hotel.source == null)){
              ToastUtil.error('数据错误');
              return;
            }
            DateTime startDate = DateTime.now();
            startDate = DateTime(startDate.year, startDate.month, startDate.day);
            DateTime endDate = startDate.add(const Duration(days: 1));
            Hotel? target = await HotelApi().detail(id: hotel.id, outerId: hotel.outerId, source: hotel.source);
            if(target == null){
              ToastUtil.error('目标不存在');
              return;
            }
            if(mounted && context.mounted){
              Navigator.of(context).push(MaterialPageRoute(builder: (context){
                return HotelHomePage(target);
              }));
            }
          },
        );
      }
      else if(selectedAroundPoint is Scenic){
        Scenic scenic = selectedAroundPoint as Scenic;
        String? cover = scenic.cover;
        if(cover != null){
          cover = getFullUrl(cover);
        }
        return AroundPointBlock(
          name: scenic.name,
          address: scenic.address,
          score: scenic.score,
          price: scenic.price,
          mainImage: cover,
          onClick: () async{
            if(scenic.id == null && (scenic.outerId == null || scenic.source == null)){
              ToastUtil.error('数据错误');
              return;
            }
            Scenic? target = await ScenicApi().detail(id: scenic.id, outerId: scenic.outerId, source: scenic.source);
            if(target == null){
              ToastUtil.error('目标不存在');
              return;
            }
            if(mounted && context.mounted){
              Navigator.of(context).push(MaterialPageRoute(builder: (context){
                return ScenicHomePage(target);
              }));
            }
          },
        );
      }
      else if(selectedAroundPoint is Restaurant){
        Restaurant restaurant = selectedAroundPoint as Restaurant;
        String? cover;
        if(restaurant.pics != null){
          List<String> picList = restaurant.pics!.split(',');
          if(picList.isNotEmpty){
            cover = picList.first;
          }
        }
        if(cover != null){
          cover = getFullUrl(cover);
        }
        return AroundPointBlock(
          name: restaurant.name,
          address: restaurant.address,
          score: restaurant.score,
          price: restaurant.averagePrice,
          mainImage: cover,
          onClick: () async{
            if(restaurant.id == null){
              return;
            }
            restaurant_model.Restaurant? target = await RestaurantApi().getById(restaurant.id!);
            if(target == null){
              ToastUtil.error('目标不存在');
              return;
            }
            if(mounted && context.mounted){
              Navigator.of(context).push(MaterialPageRoute(builder: (context){
                return RestaurantHomePage(target);
              }));
            }
          },
        );
      }
    }
    else if(selectedPoint != null){
      return GuidePointBlock(selectedPoint!);
    }
    return const SizedBox();
  }

  Future hideNearMenu() async{
    radioGroupController.setValue(null);
    nearRestaurantSlideAnim.reverse();
    await Future.delayed(const Duration(milliseconds: NEAR_SLIDE_GAP_MILLI_SECONDS));
    nearScenicSlideAnim.reverse();
    await Future.delayed(const Duration(milliseconds: NEAR_SLIDE_GAP_MILLI_SECONDS));
    nearHotelSlideAnim.reverse().then((value){
      isNearMenuDisplayed = false;
      if(mounted && context.mounted){
        setState(() {
        });
      }
    });
  }

  Future showNearMenu() async{
    isNearMenuDisplayed = true;
    nearHotelSlideAnim.forward();
    await Future.delayed(const Duration(milliseconds: NEAR_SLIDE_GAP_MILLI_SECONDS));
    nearScenicSlideAnim.forward();
    await Future.delayed(const Duration(milliseconds: NEAR_SLIDE_GAP_MILLI_SECONDS));
    nearRestaurantSlideAnim.forward();
  }

  Future menuChooseHotel() async{
    nearType = NearType.hotel;
    radioGroupController.setValue(0);
    setState(() {
    });
    drawMarker();
    if(selectedPosition == null){
      hotelList = [];
      return;
    }  
    else{
      List<Hotel>? tmpList = await LocalHotelApi().near(latitude: selectedPosition!.latitude, longitude: selectedPosition!.longitude, radius: searchRadius, pageSize: 50);
      if(tmpList == null || tmpList.length < 50){
        GeoAddress? geoAddress = await HttpGaode.regeo(selectedPosition!.latitude, selectedPosition!.longitude);
        if(geoAddress == null){
          hotelList = [];
          return;
        }
        targetCity = geoAddress.city;
        List<Hotel>? panheList = await PanheHotelApi().near(city: targetCity!, latitude: selectedPosition!.latitude, longitude: selectedPosition!.longitude, radius: searchRadius, pageSize: 50);
        if(panheList != null){
          tmpList ??= [];
          tmpList.addAll(panheList);
        }
      }
      if(tmpList == null){
        return;
      }
      if(tmpList.isEmpty){
        hotelList = [];
        ToastUtil.hint('附近没有酒店');
        return;
      }
      hotelList = [];
      for(Hotel hotel in tmpList){
        bool theSame = false;
        for(Hotel showHotel in hotelList!){
          if(hotel.likeTheSame(showHotel)){
            theSame = true;
            break;
          }
        }
        if(!theSame){
          hotelList!.add(hotel);
        }
      }
      if(mounted && context.mounted){
        setState(() {
        });
      }
      drawMarker();
    }
  }

  Future menuChooseScenic() async{
    nearType = NearType.scenic;
    radioGroupController.setValue(2);
    setState(() {
    });
    drawMarker();
    if(selectedPosition == null){
      scenicList = [];
      return;
    }
    else{
      List<Scenic>? tmpList = await LocalScenicApi().near(latitude: selectedPosition!.latitude, longitude: selectedPosition!.longitude, radius: searchRadius, pageSize: 50);
      if(tmpList == null || tmpList.length < 50){
        List<Scenic>? panheList = await PanheScenicApi().near(latitude: selectedPosition!.latitude, longitude: selectedPosition!.longitude, radius: searchRadius, pageSize: 50);
        if(panheList != null){
          tmpList ??= [];
          tmpList.addAll(panheList);
        }
      }
      if(tmpList == null || tmpList.isEmpty){
        ToastUtil.hint('附近没有景点');
        scenicList = [];
        return;
      }
      scenicList = [];
      for(Scenic scenic in tmpList){
        bool theSame = false;
        for(Scenic showScenic in scenicList!){
          if(scenic.likeTheSame(showScenic)){
            theSame = true;
            break;
          }
        }
        if(!theSame){
          scenicList!.add(scenic);
        }
      }
      if(mounted && context.mounted){
        setState(() {
        });
      }
      drawMarker();
    }
  }

  Future menuChooseRestaurant() async{
    nearType = NearType.restaurnt;
    radioGroupController.setValue(1);
    setState(() {
    });
    drawMarker();
    if(selectedPosition == null){
      restaurantList = [];
      return;
    }
    else{
      List<Restaurant>? tmpList = await NearHttp().nearRestaurant(latitude: selectedPosition!.latitude, longitude: selectedPosition!.longitude, radius: searchRadius);
      if(tmpList == null || tmpList.isEmpty){
        ToastUtil.hint('附近没有美食');
        return;
      }
      restaurantList = tmpList;
      if(mounted && context.mounted){
        setState(() {
        });
      }
      drawMarker();
    }
  }

  Widget getNearMenuWidget(){
    return Container(
      margin: const EdgeInsets.only(top: 16),
      alignment: Alignment.centerRight,
      child: RadioGroupWidget(
        controller: radioGroupController,
        crossAxisAlignment: CrossAxisAlignment.end,
        members: [
          RadioItemWidget(
            value: 0,
            content: SlideTransition(
              position: nearHotelSlideAnim.drive(Tween(begin: const Offset(1, 0), end: Offset.zero)),
              child: UnconstrainedBox(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: radioGroupController.value == 0 ? const EdgeInsets.fromLTRB(20, 12, 20, 12) : const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: radioGroupController.value == 0 ? const Color.fromRGBO(4, 182, 221, 0.8) : Colors.white,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                  ),
                  child: Text('周边酒店', style: TextStyle(color: radioGroupController.value == 0 ? Colors.white : ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
                )
              ),
            ),
            onChoose: menuChooseHotel,
          ),
          RadioItemWidget(
            value: 2,
            content: SlideTransition(
              position: nearRestaurantSlideAnim.drive(Tween(begin: const Offset(1, 0), end: Offset.zero)),
              child: UnconstrainedBox(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: radioGroupController.value == 2 ? const EdgeInsets.fromLTRB(20, 12, 20, 12) : const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: radioGroupController.value == 2 ? const Color.fromRGBO(4, 182, 221, 0.8) : Colors.white,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                  ),
                  child: Text('周边景点', style: TextStyle(color: radioGroupController.value == 2 ? Colors.white : ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
                ),
              ),
            ),
            onChoose: menuChooseScenic,
          ),
          RadioItemWidget(
            value: 1,
            content: SlideTransition(
              position: nearScenicSlideAnim.drive(Tween(begin: const Offset(1, 0), end: Offset.zero)),
              child: UnconstrainedBox(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: radioGroupController.value == 1 ? const EdgeInsets.fromLTRB(20, 12, 20, 12) : const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: radioGroupController.value == 1 ? const Color.fromRGBO(4, 182, 221, 0.8) : Colors.white,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                  ),
                  child: Text('周边美食', style: TextStyle(color: radioGroupController.value == 1 ? Colors.white : ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),)
                ),
              ),
            ),
            onChoose: menuChooseRestaurant,
          ),
        ],
      )
    );
  }

  void showRewardDialog(){
    Guide guide = widget.guide;
    if(guide.userId == null || guide.id == null){
      return;
    }
    UserGiftUtil().showGiftDialog(
      context: context, 
      authorId: guide.userId!,
      authorName: guide.authorName,
      authorHead: guide.authorHead, 
      productName: guide.title, 
      productId: guide.id!, 
      productType: ProductType.guide
    );
    /*
    showGeneralDialog(
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder:(context, animation, secondaryAnimation) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: Colors.transparent,
              child: UserRewardWidget(guide: widget.guide,),
            )
          ],
        );
      },
    );
    */
  }

  Widget getDayWidget(){
    Guide guide = widget.guide;
    if(guide.dayNum == null){
      return const SizedBox();
    }
    List<Widget> widgets = [];
    for(int i = 1; i <= guide.dayNum!; ++i){
      widgets.add(
        InkWell(
          onTap: (){
            chooseDay(i);
          },
          child: Container(
            width: 80,
            height: 36,
            color: currentDay == i ? const Color.fromRGBO(4, 182, 221, 0.8) : const Color.fromRGBO(255, 255, 255, 0.8),
            alignment: Alignment.center,
            child: Text('DAY $i', style: TextStyle(color: currentDay == i ? Colors.white : ThemeUtil.foregroundColor, fontWeight: FontWeight.bold),),
          ),
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4
          )
        ]
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: widgets,
      ),
    );
  }

  Future getRoute() async{
    polylineList = [];
    for(int i = 0; i < currentPointList.length - 1; ++i){
      GuidePoint from = currentPointList[i];
      GuidePoint to = currentPointList[i + 1];
      if(from.latitude == null || from.longitude == null || to.latitude == null || to.longitude == null){
        continue;
      }
      List<LatLng>? posList = await HttpGaodeRoute().getDrivingRoute(originLat: from.latitude!, originLng: from.longitude!, destLat: to.latitude!, destLng: to.longitude!);
      if(posList == null || posList.isEmpty){
        continue;
      }
      polylineList.add(posList);
    }
  }

  Future chooseDay(int num) async{
    Guide guide = widget.guide;
    if(num <= 0 || guide.dayNum != null && num > guide.dayNum!){
      return;
    }
    if(guide.pointList == null){
      return;
    }
    currentPointList = guide.pointList!.where((element) => element.day == num).toList();
    LatLngBounds? bounds = getBounds(currentPointList);
    if(bounds != null){
      mapController.moveCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    }
    currentDay = num;
    selectedAroundPoint = null;
    setState(() {
    });
    await getRoute();
    drawLine();
  }

  void choosePoint(GuidePoint point){
    if(point != nearCenterPoint){
      nearCenterPoint = point;
      hotelList = scenicList = restaurantList = null;
    }
    selectedPoint = point;
    selectedAroundPoint = null;
    radioGroupController.setValue(null);
    if(point.latitude != null && point.longitude != null){
      selectedPosition = LatLng(point.latitude!, point.longitude!);
    }
    setState(() {
    });
    drawMarker();
    showNearMenu();
  }

  void drawLine(){
    polylines = {};
    for(List<LatLng> posList in polylineList){
      if(posList.isNotEmpty){
        Polyline polyline = Polyline(
          width: 20,
          customTexture: BitmapDescriptor.fromIconPath('assets/texture_green.png'),
          joinType: JoinType.round,
          points: posList
        );
        polylines.add(polyline);
      }
    }
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }

  Future drawMarker() async{
    drawLine();
    Set<Marker> buffer = {};
    List<amap_flutter_base.LatLngBounds> filledBounds = [];
    MarkerWrapper? userMarker = await getUserMarker();
    if(userMarker != null){
      buffer.add(userMarker.marker);
    }

    List<MarkerWrapper> guidePointMarkers = await getGuidePointMarkers();
    for(MarkerWrapper markerWrapper in guidePointMarkers){
      bool drawable = true;
      if(markerWrapper.size != null){
        amap_flutter_base.LatLngBounds bounds = GaodeUtil.getBoundsBySize(markerWrapper.marker.position, markerWrapper.size!, zoom);
        if(filledBounds.checkContact(bounds)){
          drawable = false;
        }
        else{
          filledBounds.add(bounds);
        }
      }
      if(drawable){
        buffer.add(markerWrapper.marker);
      }
    }
    
    if(selectedPoint != null && nearType != null) {
      List<MarkerWrapper> nearPointMarkers = await getAroundPointMarkers();
      for(MarkerWrapper markerWrapper in nearPointMarkers){
        bool drawable = true;
        if(markerWrapper.size != null){
          amap_flutter_base.LatLngBounds bounds = GaodeUtil.getBoundsBySize(markerWrapper.marker.position, markerWrapper.size!, zoom);
          if(filledBounds.checkContact(bounds)){
            drawable = false;
          }
          else{
            filledBounds.add(bounds);
          }
        }
        if(drawable){
          buffer.add(markerWrapper.marker);
        }
      }
    }

    markers = buffer;
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }

  Future<List<MarkerWrapper>> getAroundPointMarkers() async{
    List<MarkerWrapper> list = [];
    if(nearType == NearType.hotel){
      for(Hotel hotel in hotelList ?? []){
        if(hotel.latitude == null || hotel.longitude == null){
          continue;
        }
        ByteData? byteData = await GaodeUtil.widgetToByteData(
          SizedBox(
            width: 200,
            height: 80,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: selectedAroundPoint == hotel ?
                    svgPointSelected :
                    svgPointAvailable,
                  ),
                  Container(
                    width: 120,
                    height: 80,
                    alignment: Alignment.centerLeft,
                    child: 
                    Text('￥${StringUtil.getPriceStr(hotel.price) ?? 0}', style: const TextStyle(color: ThemeUtil.buttonColor, fontWeight: FontWeight.bold, fontSize: 32),) 
                  ),
                ],
              )
            ),
          )
        );
        BitmapDescriptor icon = BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
        Marker marker = Marker(
          position: LatLng(hotel.latitude!, hotel.longitude!),
          icon: icon,
          anchor: const Offset(0.2, 1),
          infoWindowEnable: false,
          onTap: (id){
            selectedAroundPoint = hotel;
            if(hotel.latitude != null && hotel.longitude != null){
              selectedPosition = LatLng(hotel.latitude!, hotel.longitude!);
            }
            setState(() {
            });
            drawMarker();
          }
        );
        list.add(MarkerWrapper(marker, size: const Size(200, 80)));
      }
    }
    else if(nearType == NearType.scenic){
      for(Scenic scenic in scenicList ?? []){
        if(scenic.latitude == null || scenic.longitude == null){
          continue;
        }
        ByteData? byteData = await GaodeUtil.widgetToByteData(
          SizedBox(
            width: 200,
            height: 80,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: selectedAroundPoint == scenic ?
                    svgPointSelected :
                    svgPointAvailable,
                  ),
                  Container(
                    width: 120,
                    height: 80,
                    alignment: Alignment.centerLeft,
                    child: 
                    Text('${StringUtil.getScoreString(scenic.score ?? 100)}分', style: const TextStyle(color: ThemeUtil.buttonColor, fontWeight: FontWeight.bold, fontSize: 32),) 
                  ),
                ],
              )
            ),
          )
        );
        BitmapDescriptor icon = BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
        Marker marker = Marker(
          position: LatLng(scenic.latitude!, scenic.longitude!),
          icon: icon,
          anchor: const Offset(0.2, 1),
          infoWindowEnable: false,
          onTap: (id){
            selectedAroundPoint = scenic;
            if(scenic.latitude != null && scenic.longitude != null){
              selectedPosition = LatLng(scenic.latitude!, scenic.longitude!);
            }
            setState(() {
            });
            drawMarker();
          }
        );
        list.add(MarkerWrapper(marker, size: const Size(200, 80)));
      }
    }
    else if(nearType == NearType.restaurnt){
      for(Restaurant restaurant in restaurantList ?? []){
        if(restaurant.lat == null || restaurant.lng == null){
          continue;
        }
        ByteData? byteData = await GaodeUtil.widgetToByteData(
          SizedBox(
            width: 200,
            height: 80,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: selectedAroundPoint == restaurant ?
                    svgPointSelected :
                    svgPointAvailable,
                  ),
                  Container(
                    width: 120,
                    height: 80,
                    alignment: Alignment.centerLeft,
                    child: 
                    Text('${StringUtil.getScoreString(restaurant.score ?? 100)}分', style: const TextStyle(color: ThemeUtil.buttonColor, fontWeight: FontWeight.bold, fontSize: 32),) 
                  ),
                ],
              )
            ),
          )
        );
        BitmapDescriptor icon = BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
        Marker marker = Marker(
          position: LatLng(restaurant.lat!, restaurant.lng!),
          icon: icon,
          anchor: const Offset(0.2, 1),
          infoWindowEnable: false,
          onTap: (id){
            selectedAroundPoint = restaurant;
            if(restaurant.lat != null && restaurant.lng != null){
              selectedPosition = LatLng(restaurant.lat!, restaurant.lng!);
            }
            setState(() {
            });
            drawMarker();
          }
        );
        list.add(MarkerWrapper(marker, size: const Size(200, 80)));
      }
    }
    return list;
  }

  Future<List<MarkerWrapper>> getGuidePointMarkers() async{
    List<MarkerWrapper> list = [];
    for(GuidePoint point in currentPointList){
      if(point.latitude == null || point.longitude == null || point.orderNum == null){
        continue;
      }
      ByteData? byteData = await GaodeUtil.widgetToByteData(
        SizedBox(
          width: GUIDE_POINT_MARKER_SIZE,
          height: GUIDE_POINT_MARKER_SIZE,
          child: point == selectedPoint ?
          svgPointSelected :
          svgPointAvailable
        )
      );
      BitmapDescriptor icon = BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
      Marker marker = Marker(
        position: amap_flutter_base.LatLng(point.latitude!, point.longitude!),
        icon: icon,
        infoWindowEnable: false,
        onTap: (id){
          choosePoint(point);
        },
      );
      list.add(MarkerWrapper(marker, size: const Size(GUIDE_POINT_MARKER_SIZE, GUIDE_POINT_MARKER_SIZE)));
    }
    return list;
  }

  Future<MarkerWrapper?> getUserMarker() async{
    if(userPos == null){
      return null;
    }
    ByteData? byteData = await GaodeUtil.widgetToByteData(
      SizedBox(
        width: 60,
        height: 60,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: ClipOval(
            child: Container(
              color: Colors.white,
              alignment: Alignment.center,
              child: ClipOval(
                child: Container(
                  width: 36,
                  height: 36,
                  color: const Color.fromRGBO(4, 182, 221, 1),
                ),
              ),
            ),
          )
        ),
      )
    );
    BitmapDescriptor icon = BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
    Marker marker = Marker(
      position: userPos!,
      infoWindowEnable: false,
      icon: icon,
    );
    return MarkerWrapper(marker, size: const Size(60, 60));
  }

  Future startLocation() async{
    if(! await LocalServiceUtil.checkGpsEnabled()){
      return;
    }
    if(! await PermissionUtil().checkPermission(Permission.location)){
      return;
    }
    locationUtil.onLocationChanged().listen((event) async{ 
      var latitude = event['latitude'];
      if(latitude is String){
        latitude = double.tryParse(latitude);
      }
      var longitude = event['longitude'];
      if(longitude is String){
        longitude = double.tryParse(longitude);
      }
      if(latitude is double && longitude is double){
        userPos = amap_flutter_base.LatLng(latitude, longitude);
        drawMarker();
      } 
    });
    locationUtil.startLocation();
  }

  LatLngBounds? getBounds(List<GuidePoint> list){
    if(list.isEmpty){
      return null;
    }
    double minLat = double.infinity;
    double maxLat = double.negativeInfinity;
    double minLng = double.infinity;
    double maxLng = double.negativeInfinity;
    for(GuidePoint point in list){
      if(point.latitude != null){
        if(point.latitude! < minLat){
          minLat = point.latitude!;
        }
        if(point.latitude! > maxLat){
          maxLat = point.latitude!;
        }
      }
      if(point.longitude != null){
        if(point.longitude! < minLng){
          minLng = point.longitude!;
        }
        if(point.longitude! > maxLng){
          maxLng = point.longitude!;
        }
      }
    }
    return LatLngBounds(southwest: LatLng(minLat,minLng),northeast: LatLng(maxLat,maxLng));
  }

  void resetState(){
    setState(() {
    });
  }
}

class AroundPointBlock extends StatelessWidget{
  final String? name;
  final String? address;
  final double? score;
  final int? price;
  final String? mainImage;
  final Function()? onClick;
  const AroundPointBlock({this.name, this.address, this.score, this.price, this.mainImage, this.onClick, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4
          )
        ]
      ),
      child: InkWell(
        onTap: onClick,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.ltr,
            children: [
              Flexible(
                flex: 400,
                child: AspectRatio(
                  aspectRatio: 400 / 420,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    child: mainImage == null ?
                    ThemeUtil.defaultCover :
                    Image.network(mainImage!, fit: BoxFit.fitHeight),
                  ),
                ),
              ),
              Flexible(
                flex: 600,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: AspectRatio(
                    aspectRatio: 1 / 0.7,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(name ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold),),
                              ),
                              const SizedBox(width: 10,),
                              if(score != null && score! > 0)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(StringUtil.getScoreString(score!), style: const TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold, fontSize: 18),),
                                  const Text('分 ', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
                                ],
                              ),
                            ],
                          ),
                          Text(address ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey,),),
                          if(price != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('￥', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
                              Text(StringUtil.getPriceStr(price! > 0 ? price : null) ?? '免费', style: const TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold, fontSize: 18),)
                            ],
                          )
                        ],
                      )
                    ),
                  ),
                )
              )
            ],
          ),
        ),
      ),
    );
  }

}

class GuidePointBlock extends StatelessWidget{
  final GuidePoint point;
  const GuidePointBlock(this.point, {super.key});
  
  @override
  Widget build(BuildContext context) {
    List<String>? picList;
    String? cover;
    if(point.pics != null){
      picList = point.pics!.split(',');
      if(picList.isNotEmpty){
        cover = picList.first;
      }
      if(cover != null){
        cover = getFullUrl(cover);
      }
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4
          )
        ]
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: AspectRatio(
          aspectRatio: 1 / 0.382,
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 382,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                        child: cover == null ?
                        ThemeUtil.defaultCover :
                        Image.network(cover, fit: BoxFit.cover,),
                      )
                    ),
                  ),
                  Flexible(
                    flex: 618,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: AspectRatio(
                        aspectRatio: 1 / 0.618,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(point.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold),),
                            Text(point.address ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey,),),
                            flutter_html.Html(
                              shrinkWrap: true,
                              data: point.description ?? '',
                              style: {
                                'body': flutter_html.Style(
                                  padding: flutter_html.HtmlPaddings.zero,
                                  margin: flutter_html.Margins.zero,
                                  maxLines: 2,
                                  textOverflow: TextOverflow.ellipsis,
                                  color: ThemeUtil.foregroundColor
                                )
                              },
                            ),
                            const SizedBox()
                          ],
                        ),
                      ),
                    )
                  )
                ],
              ),
            ],
          )
        ),
      ),
    );
  }

}

class UserRewardWidget extends StatefulWidget{
  final Guide guide;
  const UserRewardWidget({required this.guide, super.key});

  @override
  State<StatefulWidget> createState() {
    return UserRewardState();
  }
  
}

class UserRewardState extends State<UserRewardWidget>{

  static const double AUTHOR_HEAD_SIZE = 48;
  static int AUTHOR_NAME_LENGTH_MAX = 14;
  static const double DOLLAR_SIZE = 48;

  TextEditingController rewardAmountController = TextEditingController(text: '10');
  order_common.PayType? payType;

  @override
  void dispose(){
    rewardAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4
                )
              ]
            ),
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10,),
                Row(
                  children: [
                    const Text('打赏给', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
                    const SizedBox(width: 10,),
                    InkWell(
                      onTap: (){
                        if(widget.guide.userId == null){
                          return;
                        }
                        UserHomeDirector().goUserHome(context: context, userId: widget.guide.userId!);
                      },
                      child: ClipOval(
                        child: SizedBox(
                          width: AUTHOR_HEAD_SIZE,
                          height: AUTHOR_HEAD_SIZE,
                          child: widget.guide.authorHead == null ?
                          ThemeUtil.defaultUserHead :
                          Image.network(getFullUrl(widget.guide.authorHead!), width: double.infinity, height: double.infinity, fit: BoxFit.cover,)
                        ),
                      ),
                    ),
                    const SizedBox(width: 10,),
                    InkWell(
                      onTap: (){
                        if(widget.guide.userId == null){
                          return;
                        }
                        UserHomeDirector().goUserHome(context: context, userId: widget.guide.userId!);
                      },
                      child: Text(widget.guide.authorName == null ? '' : StringUtil.getLimitedText(widget.guide.authorName!, AUTHOR_NAME_LENGTH_MAX), style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold),),
                    )
                  ],
                ),
                const SizedBox(height: 20,),
                Row(
                  children: [
                    Image.asset(
                      'images/dollar.png',
                      width: DOLLAR_SIZE,
                      height: DOLLAR_SIZE,
                      fit: BoxFit.fill,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4
                            )
                          ]
                        ),
                        padding: const EdgeInsets.all(12),
                        child: TextField(
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ThemeUtil.foregroundColor
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.end,
                          decoration: const InputDecoration(
                            hintText: '',
                            hintStyle: TextStyle(color: Color.fromRGBO(0xc5, 0xc5, 0xc6, 1)),
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                            suffixText: '元',
                          ),
                          controller: rewardAmountController,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20,),
                Row(
                  children: [
                    const Text('支付方式：', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
                    const Expanded(
                      child: SizedBox(),
                    ),
                    InkWell(
                      onTap: (){
                        payType = order_common.PayType.alipay;
                        setState(() {
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(12)),
                          color: payType == order_common.PayType.alipay ? Colors.black12 : Colors.white
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Image.asset(
                          'images/pay_alipay.png',
                          height: 40,
                          width: 40,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10,),
                    InkWell(
                      onTap: (){
                        payType = order_common.PayType.wechat;
                        setState(() {
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(12)),
                          color: payType == order_common.PayType.wechat ? Colors.black12 : Colors.white
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Image.asset(
                          'images/pay_weixin.png',
                          height: 40,
                          width: 40,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () async{
                        int? guideId = widget.guide.id;
                        if(guideId == null){
                          ToastUtil.error('数据错误');
                          return;
                        }
                        String val = rewardAmountController.text.trim();
                        if(val.isEmpty){
                          ToastUtil.warn('请填写打赏金额');
                          return;
                        }
                        double? amount = double.tryParse(val);
                        if(amount == null){
                          ToastUtil.warn('金额格式错误');
                          return;
                        }
                        int amountVal = (amount * 100).toInt();
                        if(amountVal <= 0){
                          ToastUtil.warn('金额错误');
                          return;
                        }
                        if(payType == null){
                          ToastUtil.warn('请选择支付方式');
                          return;
                        }
                        String? errMsg;
                        String? serial = await UserRewardHttp().postReward(productId: guideId, type: ProductType.guide, amount: amountVal, fail: (response){
                          errMsg = response.data['message'];
                        });
                        if(serial == null){
                          errMsg ??= '打赏失败';
                          ToastUtil.error(errMsg!);
                          return;
                        }
                        if(payType == order_common.PayType.wechat){
                          String? errMsg;
                          String? payInfo = await UserRewardHttp().payByWechat(serial: serial, fail: (response){
                            errMsg = response.data['message'];
                          });
                          if(payInfo == null){
                            errMsg ??= '微信预下单失败';
                            ToastUtil.error(errMsg!);
                            return;
                          }
                          OrderPayUtil().wechatPay(
                            payInfo,
                            onSuccess: (){
                              ToastUtil.hint('打赏成功，感谢您的支持');
                              Future.delayed(const Duration(seconds: 3), (){
                                if(mounted && context.mounted){
                                  Navigator.of(context).pop();
                                }
                              });
                            },
                            onFail: (){
                              ToastUtil.error('打赏失败');
                            }
                          );
                        }
                        else if(payType == order_common.PayType.alipay){
                          String? errMsg;
                          String? payInfo = await UserRewardHttp().payByAlipay(serial: serial, fail: (response){
                            errMsg = response.data['message'];
                          });
                          if(payInfo == null){
                            errMsg ??= '支付宝预下单失败';
                            ToastUtil.error(errMsg!);
                            return;
                          }
                          bool result = await OrderPayUtil().alipay(payInfo);
                          if(result){
                            ToastUtil.hint('打赏成功，感谢您的支持');
                            Future.delayed(const Duration(seconds: 3), (){
                              if(mounted && context.mounted){
                                Navigator.of(context).pop();
                              }
                            });
                          }
                          else{
                            ToastUtil.error('打赏失败');
                          }
                        }
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          color: ThemeUtil.buttonColor,
                          borderRadius: BorderRadius.all(Radius.circular(8))
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        child: const Text('打 赏', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        )
      ],
    );
  }
  
}
