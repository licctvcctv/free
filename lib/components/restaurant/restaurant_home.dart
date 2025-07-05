import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_swiper_plus/flutter_swiper_plus.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:freego_flutter/components/chat_neo/chat_common.dart';
import 'package:freego_flutter/components/chat_neo/chat_room.dart';
import 'package:freego_flutter/components/chat_neo/chat_util.dart';
import 'package:freego_flutter/components/comment/comment_page.dart';
import 'package:freego_flutter/components/comment/comment_widget.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/components/product_question/product_question_widget.dart';
import 'package:freego_flutter/components/restaurant/restaurant_common.dart';
import 'package:freego_flutter/components/restaurant/restaurant_desc_freego.dart';
import 'package:freego_flutter/components/restaurant/restaurant_order_freego.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/common_map_show.dart';
import 'package:freego_flutter/components/view/image_group_viewer.dart';
import 'package:freego_flutter/components/view/menu_action.dart';
import 'package:freego_flutter/components/view/navigated_view.dart';
import 'package:freego_flutter/components/view/pics_swiper.dart';
import 'package:freego_flutter/components/view/tipoff.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/util/dialog_util.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';

const double headerHeight = 50;

class RestaurantHomePage extends StatelessWidget {
  final Restaurant restaurant;
  const RestaurantHomePage(this.restaurant, {super.key});

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
      body: RestaurantDescWidget(restaurant),
    );
  }
}

class RestaurantDescWidget extends StatefulWidget {
  final Restaurant restaurant;
  const RestaurantDescWidget(this.restaurant, {super.key});

  @override
  State<StatefulWidget> createState() {
    return RestaurantDescState();
  }
}

class RestaurantDescState extends State<RestaurantDescWidget> with SingleTickerProviderStateMixin {

  late Restaurant restaurant;
  NavigatedController controller = NavigatedController();

  String? distance;
  AMapFlutterLocation location = AMapFlutterLocation();
  int commentNum = 0;

  late AnimationController rightMenuAnim;
  bool rightMenuShow = false;
  static const int RIGHT_MENU_ANIM_MILLI_SECONDS = 150;
  static const double RIGHT_MENU_WIDTH = 100;
  static const double RIGHT_MENU_ITEM_HEIGHT = 40;

  Widget svgQuestion = SvgPicture.asset('svg/question.svg', color: const Color.fromARGB(255, 255, 214, 79),);

  CommonMenuController? menuController;

  @override
  void dispose(){
    rightMenuAnim.dispose();
    location.destroy();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    restaurant = widget.restaurant;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getDistance();
    });
    rightMenuAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: RIGHT_MENU_ANIM_MILLI_SECONDS),
    );
  }

  void getDistance() async {
    Restaurant restaurant = widget.restaurant;
    if (restaurant.lat == null || restaurant.lng == null) {
      return;
    }
    LatLng resPos = LatLng(restaurant.lat!, restaurant.lng!);
    location.onLocationChanged().listen((result) {
      var latitude = result['latitude'];
      if(latitude is String){
        latitude = double.tryParse(latitude);
      }
      var longitude = result['longitude'];
      if(longitude is String){
        longitude = double.tryParse(longitude);
      }
      if (latitude is double && longitude is double) {
        LatLng position = LatLng(latitude, longitude);
        double dist = AMapTools.distanceBetween(position, resPos);
        String distanceText = StringUtil.getDistanceText(dist.toInt()); // 使用 getDistanceText 方法来获取距离文本信息
        if(mounted && context.mounted){
          setState(() {
            distance = distanceText; // 更新 distance 变量为文本格式的距离信息
          });
        }
        location.stopLocation();
      }
    });
    location.startLocation();
  }

  @override
  Widget build(BuildContext context) {
    Restaurant restaurant = widget.restaurant;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
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
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    physics: const ClampingScrollPhysics(),
                    children: [
                      getPicWidget(),
                      RestaurantTextWidget(restaurant),
                      getContackWidget(),
                      getReserveWidget(),
                      RestaurantDishWidget(restaurant),
                      getCommentWidget(),
                      getQuestionWidget(),
                      const SizedBox(
                        height: 48,
                      )
                    ],
                  ),
                ),
              ],
            ),
            rightMenuShow ?
              Positioned.fill(
                child: InkWell(
                  onTap: (){
                    rightMenuShow = false;
                    rightMenuAnim.reverse();
                    setState(() {
                    });
                  },
                ),
              ) : const SizedBox(),
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
                            Navigator.of(context).push(MaterialPageRoute(builder: (context){
                              return RestaurantDescPage(restaurant);
                            }));
                            rightMenuAnim.reverse();
                            rightMenuShow = false;
                            setState(() {
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
                            child: const Text('餐厅介绍', style: TextStyle(color: Colors.white),),
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

  Widget getPicWidget(){
    Restaurant restaurant = widget.restaurant;
    List<String> pics = (widget.restaurant.pics ?? '').split(',');
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12))
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          restaurant.pics == null || restaurant.pics!.isEmpty ?
          const SizedBox() :
          PicsSwiper(
            urlBuilder: (index) {
              return getFullUrl(pics[index]);
            },
            count: pics.length,
          ),
          Align(
            alignment: Alignment.topCenter,
            child: CommonHeader(
              left: Container(
                decoration: const BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.all(Radius.circular(4))
                ),
                width: 48,
                height: 48,
                alignment: Alignment.center,
                child: IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white,),
                ),
              ),
              right: TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap
                ),
                onPressed: (){
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
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.all(Radius.circular(4))
                  ),
                  width: 48,
                  height: 48,
                  child: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 32,),
                ),
              ),
              backgroundColor: Colors.transparent,
            ),
          )
        ],
      ),
    );
  }

  Widget getContackWidget() {
    String fullAddress = restaurant.province! +
      restaurant.city! +
      restaurant.district! +
      restaurant.address!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if(restaurant.lat == null || restaurant.lng == null){
                  return;
                }
                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                  return CommonMapShowPage(address: restaurant.address ?? '', latitude: restaurant.lat!, longitude: restaurant.lng!,);
                }));
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color.fromARGB(255, 255, 214, 79),
                      Color.fromARGB(255, 243, 232, 198)
                    ],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                padding: const EdgeInsets.fromLTRB(10, 14, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('位置：$fullAddress', style: const TextStyle(color: ThemeUtil.foregroundColor)),
                    const SizedBox(height: 10),
                    Text('距您：${distance ?? '未知'}', style: const TextStyle(color: ThemeUtil.foregroundColor)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const [
                        Icon(Icons.location_on_rounded, color: Color.fromARGB(255, 255, 196, 0), size: 26),
                        Text(
                          '地图/周边',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(255, 255, 196, 0)
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10,),
          InkWell(
            onTap: () async{
              if(restaurant.userId == null){
                return;
              }
              DialogUtil.loginRedirectConfirm(context, callback: (isLogined) async{
                if(isLogined){
                  ImSingleRoom? room = await ChatUtilSingle.enterRoom(restaurant.userId!);
                  if(room == null){
                    return;
                  }
                  if(mounted && context.mounted){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context){
                      return ChatRoomPage(room: room,);
                    }));
                  }
                }
              });
            }, 
            child: SizedBox(
              width: 40,
              height: 40,
              child: svgQuestion,
            )
          ),
        ],
      ),
    );
  }

  Widget getReserveWidget() {
    String? priceStr = StringUtil.getPriceStr(restaurant.averagePrice);
    List<String> priceParts = priceStr?.split('.') ?? [];
    return GestureDetector(
      onTap: () {
        DialogUtil.loginRedirectConfirm(context, callback: (isLogined){
          if(isLogined){
            if(mounted && context.mounted){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return RestaurantOrderGoPage(restaurant);
              }));
            }
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: ThemeUtil.backgroundColor,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Html(
                          data: restaurant.bookNotice ?? '',
                          style: {
                            "*": Style(
                              margin: Margins.zero,
                              padding: HtmlPaddings.zero,
                              color: Colors.grey,
                            ),
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(color: Colors.orangeAccent,fontWeight: FontWeight.bold,),
                                children: <TextSpan>[
                                  const TextSpan(text: '￥',style: TextStyle(fontSize: 20),),
                                  TextSpan(text: priceParts.isNotEmpty ? priceParts.first : '', style: const TextStyle(fontSize: 24),),
                                  if(priceParts.length > 1)
                                  TextSpan(text: '.${priceParts[1]} 起', style: const TextStyle(fontSize: 16),),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    decoration: const BoxDecoration(
                      color: ThemeUtil.buttonColor,
                      borderRadius: BorderRadius.all(Radius.circular(12))
                    ),
                    child: const Text('预 订', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),),
                  )
                ],
              )
            ),
          ],
        ),
      )
    );
  }

  Widget getQuestionWidget() {
    Restaurant restaurant = widget.restaurant;
    if (restaurant.id == null) {
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 0, 0, 8),
            child: Text(
              '问答',
              style: TextStyle(
                color: ThemeUtil.foregroundColor,
                fontWeight: FontWeight.bold,
                fontSize: 18
              ),
            ),
          ),
          ProductQuestionShowWidget(
            productId: restaurant.id!,
            productType: ProductType.restaurant,
            ownnerId: restaurant.userId,
            title: restaurant.name,
            onMenuShow: (controller){
              menuController?.hideMenu();
              menuController = controller;
            },
            onTipoffQuestion: (question){
              if(question.id == null){
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
                        return TipOffWidget(targetId: question.id!, productType: ProductType.productQuestion,);
                      }
                    );
                  }
                }
              });
            },
            onTipoffQuestionAnswer: (answer){
              if(answer.id == null){
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
                        return TipOffWidget(targetId: answer.id!, productType: ProductType.productQuestionAnswer,);
                      }
                    );
                  }
                }
              });
            },
          )
        ],
      ),
    );
  }

  Widget getCommentWidget() {
    Restaurant restaurant = widget.restaurant;
    if (restaurant.id == null) {
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 0, 0, 8),
            child: Text(
              '评论',
              style: TextStyle(
                color: ThemeUtil.foregroundColor,
                fontWeight: FontWeight.bold,
                fontSize: 18
              ),
            ),
          ),
          CommentShowWidget(
            productId: restaurant.id!,
            type: ProductType.restaurant,
            ownnerId: restaurant.userId,
            productName: restaurant.name,
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
          )
        ],
      ),
    );
  }
}

class RestaurantMediaWidget extends StatefulWidget {
  final Restaurant restaurant;
  const RestaurantMediaWidget(this.restaurant, {super.key});

  @override
  State<StatefulWidget> createState() {
    return RestaurantMediaState();
  }
}

class RestaurantMediaState extends State<RestaurantMediaWidget> {
  final SwiperController _swiperController = SwiperController();

  bool showDetails = false; // 添加状态以控制是否显示评分和人均消费内容
  double? scoreToShow;
  int? averagePriceToShow;

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> pics = (widget.restaurant.pics ?? '').split(',');
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          child: PicsSwiper(
            urlBuilder: (index) {
              return getFullUrl(pics[index]);
            },
            count: pics.length,
          ),
        ),
      ],
    );
  }

}

class RestaurantTextWidget extends StatefulWidget {
  final Restaurant restaurant;
  const RestaurantTextWidget(this.restaurant, {super.key});

  @override
  State<StatefulWidget> createState() {
    return RestaurantTextState();
  }
}

class RestaurantTextState extends State<RestaurantTextWidget> {
  String? distance;
  AMapFlutterLocation location = AMapFlutterLocation();

  int commentNum = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getDistance();
    });
  }

  void getDistance() async {
    Restaurant restaurant = widget.restaurant;
    if (restaurant.lat == null || restaurant.lng == null) {
      return;
    }
    LatLng resPos = LatLng(restaurant.lat!, restaurant.lng!);
    location.onLocationChanged().listen((result) {
      var latitude = result['latitude'];
      if(latitude is String){
        latitude = double.tryParse(latitude);
      }
      var longitude = result['longitude'];
      if(longitude is String){
        longitude = double.tryParse(longitude);
      }
      if (latitude is double && longitude is double) {
        LatLng position = LatLng(latitude, longitude);
        double dist = AMapTools.distanceBetween(position, resPos);
        String distanceText = StringUtil.getDistanceText(dist.toInt()); // 使用 getDistanceText 方法来获取距离文本信息
        if(mounted && context.mounted){
          setState(() {
            distance = distanceText; // 更新 distance 变量为文本格式的距离信息
          });
        }
        location.stopLocation();
      }
    });
    location.startLocation();
  }

  @override
  Widget build(BuildContext context) {
    Restaurant restaurant = widget.restaurant;
    String fullAddress = restaurant.province! +
      restaurant.city! +
      restaurant.district! +
      restaurant.address!;
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                restaurant.name ?? '',
                style: const TextStyle(
                  color: ThemeUtil.foregroundColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20
                ),
              ),
              const Expanded(child: SizedBox()),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context){
                    return RestaurantDescPage(restaurant);
                  }));
                },
                child: Row(
                  children: const [
                    Text(
                      '详情',
                      style: TextStyle(color: Color.fromARGB(255, 255, 196, 0)),
                    ),
                    Icon(
                      Icons.keyboard_arrow_right_rounded,
                      size: 30,
                      color: Color.fromARGB(255, 255, 196, 0),
                      weight: 1000,
                    )
                  ],
                ),
              ),
            ],
          ),
          const Divider(),
          Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                child: Container(
                  color: const Color.fromARGB(255, 255, 196, 0),
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                  child: Text(
                    '${((restaurant.score ?? 100) / 10).toStringAsFixed(1)}分',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const Expanded(
                child: SizedBox(),
              ),
              InkWell(
                onTap: () {
                  if(restaurant.id == null){
                    ToastUtil.error('数据错误');
                    return;
                  }
                  Navigator.of(context).push(MaterialPageRoute(builder: (context){
                    return CommentPage(productId: restaurant.id!, type: ProductType.restaurant);
                  }));
                },
                child: Row(
                  children: [
                    Text(
                      '${restaurant.commentNum}条评论',
                      style: const TextStyle(
                          color: Color.fromARGB(255, 255, 196, 0)),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_right_rounded,
                      size: 30,
                      color: Color.fromARGB(255, 255, 196, 0),
                      weight: 1000,
                    )
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

class RestaurantDishWidget extends StatelessWidget {
  final Restaurant restaurant;
  const RestaurantDishWidget(this.restaurant, {super.key});

  @override
  Widget build(BuildContext context) {
    List<RestaurantDish> dishList = restaurant.dishList!;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 0, 0, 8),
            child: Text(
              '菜品展示',
              style: TextStyle(
                  color: ThemeUtil.foregroundColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          ),
          Container(
            height: 140,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: getDishWidgets(context, dishList),
            ),
          )
        ],
      ),
    );
  }

  List<Widget> getDishWidgets(BuildContext context, List<RestaurantDish> dishList) {
    List<Widget> widgets = [];
    List<String> urlList = [];
    for (RestaurantDish dish in dishList) {
      urlList.add(dish.pic == null || dish.pic!.isEmpty
        ? 'images/share_weixin.png'
        : getFullUrl(dish.pic!));
    }
    for (int i = 0; i < dishList.length; ++i) {
      RestaurantDish dish = dishList[i];
      widgets.add(InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return ImageGroupViewer(
              urlList,
              initIndex: i,
              builder: (context, index) {
                RestaurantDish target = dishList[index];
                return Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(64, 64, 64, 0.5),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Text(
                        target.name ?? '',
                        style: const TextStyle(color: Colors.white),
                      ),
                      target.price == null ? 
                      const SizedBox() : 
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '现价：',
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            '${StringUtil.getPriceStr(target.price)}',
                            style: const TextStyle(color: Colors.red)
                          ),
                        ],
                      ),
                      target.priceOld == null ? 
                      const SizedBox() : 
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '原价：',
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            '${StringUtil.getPriceStr(target.priceOld)}',
                            style: const TextStyle(
                              color: Colors.red,
                              decoration: TextDecoration.lineThrough),
                          )
                        ],
                      ),
                      target.description == null ? 
                      const SizedBox() : 
                      HtmlWidget(
                        '${target.description}',
                        textStyle: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                );
              },
            );
          }));
        },
        child: Container(
          width: 185,
          height: 140,
          padding: const EdgeInsets.all(5),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(25)),
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              Image.network(
                getFullUrl(dish.pic!),
                fit: BoxFit.fill,
                width: double.infinity,
                height: double.infinity,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(64, 64, 64, 0.2),
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  child: Text(
                    dish.name!,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ));
    }
    return widgets;
  }

  List<Widget> getTags(String tags) {
    List<String> tagList = tags.split(',');
    List<Widget> list = [];
    for (String tag in tagList) {
      list.add(
        Container(
          margin: const EdgeInsets.only(right: 4),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.red, borderRadius: BorderRadius.circular(4)
          ),
          child: Text(
            tag,
            style: const TextStyle(color: Colors.white),
          ),
        )
      );
    }
    return list;
  }
}
