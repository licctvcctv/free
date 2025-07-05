
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/chat_neo/chat_home.dart';
import 'package:freego_flutter/components/chat_neo/chat_socket.dart';
import 'package:freego_flutter/components/chat_neo/chat_util.dart';
import 'package:freego_flutter/components/chat_notification/chat_notification_util.dart';
import 'package:freego_flutter/components/circle_neo/circle_home.dart';
import 'package:freego_flutter/components/facade/near_http.dart';
import 'package:freego_flutter/components/guide_neo/guide_home.dart';
import 'package:freego_flutter/components/hotel_neo/api/hotel_api.dart';
import 'package:freego_flutter/components/hotel_neo/hotel_common.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/components/product_neo/product_home.dart';
import 'package:freego_flutter/components/restaurant/restaurant_common.dart';
import 'package:freego_flutter/components/restaurant/restaurant_api.dart';
import 'package:freego_flutter/components/scenic/api/scenic_api.dart';
import 'package:freego_flutter/components/scenic/scenic_common.dart';
import 'package:freego_flutter/components/trip/my_trip.dart';
import 'package:freego_flutter/components/user/user_center.dart';
import 'package:freego_flutter/components/view/city_picker.dart';
import 'package:freego_flutter/config/const_config.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/model/user.dart';
import 'package:freego_flutter/util/context_util.dart';
import 'package:freego_flutter/util/dialog_util.dart';
import 'package:freego_flutter/util/gaode_util.dart';
import 'package:freego_flutter/util/local_user.dart';
import 'package:freego_flutter/util/permission_util.dart';
import 'package:freego_flutter/util/product_redirector.dart';
import 'package:freego_flutter/util/route_observer.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeMapPage extends StatelessWidget{
  const HomeMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      body: const HomeMapWidget(),
    );
  }

}

class HomeMapWidget extends StatefulWidget{
  const HomeMapWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return HomeMapState();
  }
  
}

class _MyAfterLoginHandler implements AfterLoginHandler{
  HomeMapState state;
  _MyAfterLoginHandler(this.state);
  
  @override
  void handle(UserModel user) {
    state.setMessageHintCount();
  }
  
}

class _MyAfterLogoutHandler implements AfterLogoutHandler{
  HomeMapState state;
  _MyAfterLogoutHandler(this.state);
  
  @override
  void handle(UserModel user) {
    state.setMessageHintCount();
  }
  
}

class _MyMessageHandler extends ChatMessageHandler{
  HomeMapState state;
  _MyMessageHandler(this.state):super(priority: 99);
  
  @override
  Future handle(MessageObject rawObj) async{
    state.setMessageHintCount();
  }

}

class _MyReconnectHandler extends SocketReconnectHandler{
  HomeMapState state;
  _MyReconnectHandler(this.state):super(priority: 99);
  
  @override
  Future handle() async{
    state.setMessageHintCount();
  }
  
}

class HomeMapState extends State<HomeMapWidget> with SingleTickerProviderStateMixin, WidgetsBindingObserver, AutomaticKeepAliveClientMixin, RouteAware{

  static const double TOPPER_ICON_SIZE = 32;
  static const double MENU_ICON_SIZE = 20;
  static const LatLng DEFAULT_POS = LatLng(39.909187, 116.397451);
  static const double DEFAULT_ZOOM = 12;
  
  late AMapController mapController;
  double zoom = DEFAULT_ZOOM;

  bool isMenuShowInFact = false;
  bool isMenuShowInFuture = false;
  late AnimationController _menuAnimController;

  Widget svgUserWidget = SvgPicture.asset('svg/user.svg');
  Widget svgSearchWidget = SvgPicture.asset('svg/search.svg');

  int messageHintCount = 0;
  late _MyAfterLoginHandler _afterLoginHandler;
  late _MyAfterLogoutHandler _afterLogoutHandler;
  late _MyMessageHandler _chatMessageHandler;
  late _MyReconnectHandler _chatReconnectHandler;

  LatLng? userPos;
  AMapFlutterLocation locationUtil = AMapFlutterLocation();

  Set<Marker> markers = {};

  static const double SEARCH_TYPE_WIDTH = 60;
  ProductType searchType = ProductType.hotel;
  String searchTypeText = '酒店';
  bool showSearchHint = true;
  Widget svgSearch = SvgPicture.asset('svg/search.svg', color: ThemeUtil.foregroundColor,);
  FocusNode searchFocus = FocusNode();
  TextEditingController searchTextController = TextEditingController();

  LatLng? targetPos;
  bool isShowWaist = false;
  Widget svgLocation = SvgPicture.asset('svg/map/location.svg');
  List<Hotel> nearHotelList = [];
  List<Scenic> nearScenicList = [];
  List<Restaurant> nearRestaurantList = [];
  
  static const double WAIST_HEIGHT = 206;
  static const double WAIST_ITEM_WIDTH = 120;
  static const double NEAR_RADIUS = 5000;

  String city = '杭州市';

  Future setMessageHintCount({bool? reloadUnsent}) async{
    UserModel? user = LocalUser.getUser();
    if(user != null){
      if(reloadUnsent == true){
        await ChatUtilSingle.getAllUnsent();
        await ChatNotificationUtil.getAllUnsent();
      }
      int chatSingleCount = await ChatUtilSingle().getUnreadCount();
      int chatNotificationCount = await ChatNotificationUtil().getUnreadCount();
      messageHintCount = chatSingleCount + chatNotificationCount;
      if(mounted && context.mounted){
        setState(() {
        });
      }
    }
    else{
      messageHintCount = 0;
      setState(() {
      });
    }
  }

  @override
  void didPopNext(){
    setMessageHintCount();
  }

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    RouteObserverUtil().routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void initState(){
    super.initState();
    _menuAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    searchFocus.addListener(() {
      if(!searchFocus.hasFocus){
        if(searchTextController.text.trim().isEmpty){
          showSearchHint = true;
          resetState();
        }
      }
    });
    _afterLoginHandler = _MyAfterLoginHandler(this);
    _afterLogoutHandler = _MyAfterLogoutHandler(this);
    LocalUser.addAfterLoginHandler(_afterLoginHandler);
    LocalUser.addAfterLogoutHandler(_afterLogoutHandler);
    _chatMessageHandler = _MyMessageHandler(this);
    ChatSocket.addMessageHandler(_chatMessageHandler);
    _chatReconnectHandler = _MyReconnectHandler(this);
    ChatSocket.addReconnectHandler(_chatReconnectHandler);
    setMessageHintCount(reloadUnsent: true);
    ChatSocket.init();
    ChatUtilSingle();
    ChatNotificationUtil();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose(){
    _menuAnimController.dispose();
    searchTextController.dispose();
    searchFocus.dispose();
    LocalUser.removeAfterLoginHandler(_afterLoginHandler);
    LocalUser.removeAfterLogoutHandler(_afterLogoutHandler);
    ChatSocket.removeMessageHandler(_chatMessageHandler);
    ChatSocket.removeReconnectHandler(_chatReconnectHandler);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double systemHeaderHeight = ThemeUtil.getStatusBarHeight(ContextUtil.getContext()!);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Stack(
        children: [
          Stack(
            children: [
              Transform.scale(
                scale: 1.1,
                alignment: Alignment.topCenter,
                child: getMapWidget(),
              ),
              const Positioned(
                left: 0,
                bottom: 0,
                child: Text('高德地图', style: TextStyle(color: Color.fromRGBO(78, 89, 105, 0.6))),
              )
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 15 + systemHeaderHeight,
            child: Row(
              children: [
                Expanded(
                  child: getSearchBar(),
                ),
                InkWell(
                  onTap: shiftMenu,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(96, 96, 96, 0.3),
                      borderRadius: BorderRadius.horizontal(left: Radius.circular(8))
                    ),
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: const Icon(Icons.more_vert, color: Color.fromRGBO(255, 255, 255, 0.8), size: TOPPER_ICON_SIZE,),
                  ),
                )
              ],
            )
          ),
          Positioned(
            left: 4,
            top: 15 + systemHeaderHeight + TOPPER_ICON_SIZE + 20 + 4,
            child: getSearchTypeWidget(),
          ),
          Positioned(
            right: 0,
            top: 15 + systemHeaderHeight + TOPPER_ICON_SIZE + 20 + 10,
            child: getMenuWidget()
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: getWaistWidget(),
          )
        ],
      ),
    );
  }

  void chooseSearchType(ProductType type){
    if(type == searchType){
      return;
    }
    searchType = type;
    setState(() {
    });
    searchProductByText();
  }

  Widget getSearchTypeWidget(){
    return Wrap(
      spacing: 7,
      children: [
        InkWell(
          onTap: (){
           chooseSearchType(ProductType.hotel);
          },
          child: Container(
            decoration: BoxDecoration(
              color: searchType == ProductType.hotel ? const Color.fromRGBO(4, 182, 221, 0.7) : const Color.fromRGBO(255, 255, 255, 0.7),
              borderRadius: const BorderRadius.all(Radius.circular(8))
            ),
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Text('酒店', style: TextStyle(color: searchType == ProductType.hotel ? Colors.white : ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 14),),
          ),
        ),
        InkWell(
          onTap: (){
            chooseSearchType(ProductType.scenic);
          },
          child: Container(
            decoration: BoxDecoration(
              color: searchType == ProductType.scenic ? const Color.fromRGBO(4, 182, 221, 0.7) : const Color.fromRGBO(255, 255, 255, 0.7),
              borderRadius: const BorderRadius.all(Radius.circular(8))
            ),
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Text('景点', style: TextStyle(color: searchType == ProductType.scenic ? Colors.white : ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 14),),
          ),
        ),
        InkWell(
          onTap: (){
            chooseSearchType(ProductType.restaurant);
          },
          child: Container(
            decoration: BoxDecoration(
              color: searchType == ProductType.restaurant ? const Color.fromRGBO(4, 182, 221, 0.7) : const Color.fromRGBO(255, 255, 255, 0.7),
              borderRadius: const BorderRadius.all(Radius.circular(8))
            ),
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Text('美食', style: TextStyle(color: searchType == ProductType.restaurant ? Colors.white : ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 14),),
          ),
        )
      ],
    );
  }

  Widget getWaistWidget(){
    List<Widget> widgets = [];
    switch(searchType){
      case ProductType.hotel:
        for(Hotel hotel in nearHotelList){
          String? cover = hotel.cover;
          if(cover != null){
            cover = getFullUrl(cover);
          }
          widgets.add(
            InkWell(
              onTap: (){
                if(hotel.id == null){
                  ToastUtil.error('数据错误');
                  return;
                }
                ProductRedirector().redirect(productId: hotel.id!, type: ProductType.hotel, context: context);
              },
              child: Container(
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(8))
                ),
                height: WAIST_HEIGHT,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: WAIST_ITEM_WIDTH,
                      child: AspectRatio(
                        aspectRatio: 1.2,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(4)),
                          child: cover == null ?
                          ThemeUtil.defaultCover :
                          Image.network(cover, fit: BoxFit.cover,),
                        )
                      ),
                    ),
                    const SizedBox(height: 10,),
                    SizedBox(
                      height: 40,
                      width: WAIST_ITEM_WIDTH,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(hotel.name ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
                      ),
                    ),
                    const SizedBox(height: 10,),
                    SizedBox(
                      width: WAIST_ITEM_WIDTH,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if(hotel.score != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rate_rounded, size: 16, color: ThemeUtil.buttonColor,),
                              Text(StringUtil.getScoreString(hotel.score ?? 100), style: const TextStyle(color: ThemeUtil.buttonColor, fontWeight: FontWeight.bold, fontSize: 16),)
                            ],
                          ),
                          if(hotel.price != null)
                          Text('￥ ${StringUtil.getPriceStr(hotel.price)}', style: const TextStyle(color: ThemeUtil.buttonColor, fontWeight: FontWeight.bold, fontSize: 16),)
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          );
        }
        break;
      case ProductType.scenic:
        for(Scenic scenic in nearScenicList){
          String? cover = scenic.cover;
          if(cover != null){
            cover = getFullUrl(cover);
          }
          widgets.add(
            InkWell(
              onTap: (){
                if(scenic.id == null){
                  ToastUtil.error('数据错误');
                  return;
                }
                ProductRedirector().redirect(productId: scenic.id!, type: ProductType.scenic, context: context);
              },
              child: Container(
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(8))
                ),
                height: WAIST_HEIGHT,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: WAIST_ITEM_WIDTH,
                      child: AspectRatio(
                        aspectRatio: 1.2,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(4)),
                          child: cover == null ?
                          ThemeUtil.defaultCover :
                          Image.network(cover, fit: BoxFit.cover,),
                        )
                      ),
                    ),
                    const SizedBox(height: 10,),
                    SizedBox(
                      height: 40,
                      width: WAIST_ITEM_WIDTH,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(scenic.name ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
                      ),
                    ),
                    const SizedBox(height: 10,),
                    SizedBox(
                      width: WAIST_ITEM_WIDTH,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if(scenic.score != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rate_rounded, size: 16, color: ThemeUtil.buttonColor,),
                              Text(StringUtil.getScoreString(scenic.score ?? 100), style: const TextStyle(color: ThemeUtil.buttonColor, fontWeight: FontWeight.bold, fontSize: 16),)
                            ],
                          ),
                          if(scenic.price != null)
                          Text('￥ ${StringUtil.getPriceStr(scenic.price)}', style: const TextStyle(color: ThemeUtil.buttonColor, fontWeight: FontWeight.bold, fontSize: 16),)
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          );
        }
        break;
      case ProductType.restaurant:
        for(Restaurant restaurant in nearRestaurantList){
          String? cover = restaurant.cover;
          if(cover != null){
            cover = getFullUrl(cover);
          }
          widgets.add(
            InkWell(
              onTap: (){
                if(restaurant.id == null){
                  return;
                }
                ProductRedirector().redirect(productId: restaurant.id!, type: ProductType.restaurant, context: context);
              },
              child: Container(
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(8))
                ),
                height: WAIST_HEIGHT,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: WAIST_ITEM_WIDTH,
                      child: AspectRatio(
                        aspectRatio: 1.2,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(4)),
                          child: cover == null ?
                          ThemeUtil.defaultCover :
                          Image.network(cover, fit: BoxFit.cover,),
                        )
                      ),
                    ),
                    const SizedBox(height: 10,),
                    SizedBox(
                      height: 40,
                      width: WAIST_ITEM_WIDTH,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(restaurant.name ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
                      ),
                    ),
                    const SizedBox(height: 10,),
                    SizedBox(
                      width: WAIST_ITEM_WIDTH,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if(restaurant.score != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rate_rounded, size: 16, color: ThemeUtil.buttonColor,),
                              Text(StringUtil.getScoreString(restaurant.score ?? 100), style: const TextStyle(color: ThemeUtil.buttonColor, fontWeight: FontWeight.bold, fontSize: 16),)
                            ],
                          ),
                          if(restaurant.averagePrice != null)
                          Text('￥ ${StringUtil.getPriceStr(restaurant.averagePrice)}', style: const TextStyle(color: ThemeUtil.buttonColor, fontWeight: FontWeight.bold, fontSize: 16),)
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          );
        }
        break;
      default:
    }
    return Offstage(
      offstage: !isShowWaist,
      child: SizedBox(
        height: WAIST_HEIGHT,
        child: ListView(
          padding: EdgeInsets.zero,
          scrollDirection: Axis.horizontal,
          children: widgets,
        ),
      )
    );
  }

  Widget getSearchBar(){
    return SizedBox(
      height: TOPPER_ICON_SIZE + 20,
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color.fromRGBO(96, 96, 96, 0.3),
                borderRadius: BorderRadius.horizontal(right: Radius.circular(8))
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () async{
                      Object? name = await Navigator.of(context).push(MaterialPageRoute(builder: (context){
                        return const CityPickerPage(allowAllChoose: true, allChooseValue: '\\全国',);
                      }));
                      if(name == null){
                        return;
                      }
                      if(city == name){
                        return;
                      }
                      if(name == '\\全国'){
                        name = null;
                      }
                      if(name is String){
                        city = name;
                        setState(() {
                        });
                      }
                    },
                    child: Container(
                      width: SEARCH_TYPE_WIDTH,
                      height: TOPPER_ICON_SIZE + 20,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(4))
                      ),
                      margin: const EdgeInsets.all(4),
                      child: Text(city, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: (){

                      },
                      child: Listener(
                        behavior: HitTestBehavior.opaque,
                        onPointerDown: (e){
                          searchFocus.requestFocus();
                          showSearchHint = false;
                          setState(() {
                          });
                        },
                        child: Container(
                          height: TOPPER_ICON_SIZE + 20,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(4))
                          ),
                          margin: const EdgeInsets.fromLTRB(0, 4, 4, 4),
                          padding: const EdgeInsets.all(4),
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              SizedBox(
                                width: TOPPER_ICON_SIZE,
                                height: TOPPER_ICON_SIZE,
                                child: svgSearch,
                              ),
                              const SizedBox(width: 4,),
                              Expanded(
                                child: Stack(
                                  children: [
                                    TextField(
                                      focusNode: searchFocus,
                                      controller: searchTextController,
                                      onSubmitted: (val){

                                      },
                                      textInputAction: TextInputAction.search,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: '',
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),
                                    ),
                                    if(showSearchHint)
                                    const Text('酒店/景点等', overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 18),),
                                  ],
                                ),
                              )
                            ],
                          )
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(width: 10,)
        ],
      ),
    );
  }

  Widget getMenuWidget(){
    return Offstage(
      offstage: !isMenuShowInFact,
      child: FadeTransition(
        opacity: _menuAnimController,
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: Container(
            padding: const EdgeInsets.fromLTRB(15, 10, 0, 10),
            width: 125,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(96, 96, 96, 0.3),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context){
                      return const CircleHomePage();
                    }));
                  },
                  child: Row(
                    children: [
                      Image.asset('assets/icon_circle.png', width: MENU_ICON_SIZE, height: MENU_ICON_SIZE,),
                      const SizedBox(width: 10,),
                      const Text('圈子', style: TextStyle(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 18),)
                    ],
                  ),
                ),
                TextButton(
                  onPressed: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context){
                      return const GuideHomePage();
                    }));
                  }, 
                  child: Row(
                    children: [
                      Image.asset('assets/icon_guide.png', width: MENU_ICON_SIZE, height: MENU_ICON_SIZE,),
                      const SizedBox(width: 10,),
                      const Text('攻略', style: TextStyle(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 18),)
                    ],
                  ),
                ),
                TextButton(
                  onPressed: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context){
                      return const ProductHomePage();
                    }));
                  },
                  child: Row(
                    children: const [
                      Icon(Icons.shopping_cart, color: Colors.white, size: MENU_ICON_SIZE,),
                      SizedBox(width: 10,),
                      Text('服务', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),)
                    ],
                  ),
                ),
                TextButton(
                  onPressed: (){
                    DialogUtil.loginRedirectConfirm(context, callback: (isLogined){
                      if(isLogined){
                        Navigator.of(context).push(MaterialPageRoute(builder: (context){
                          return const MyTripPage();
                        }));
                      }
                    });
                  }, 
                  child: Row(
                    children: [
                      Image.asset('assets/icon_trip.png', width: MENU_ICON_SIZE, height: MENU_ICON_SIZE,),
                      const SizedBox(width: 10,),
                      const Text('行程', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),)
                    ],
                  )
                ),
                TextButton(
                  onPressed: () {
                    DialogUtil.loginRedirectConfirm(context, callback: (isLogined){
                      if(isLogined){
                        Navigator.of(context).push(MaterialPageRoute(builder: (context){
                          return const ChatHomePage();
                        }));
                      }
                    });
                  }, 
                  child: Row(
                    children: [
                      const Icon(Icons.chat, color: Colors.white, size: MENU_ICON_SIZE,),
                      const SizedBox(width: 10),
                      const Text('消息', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      if(messageHintCount > 0)
                      ClipOval(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                          ),
                          alignment: Alignment.center,
                          width: 20,
                          height: 20,
                          child: Text('${messageHintCount < 99 ? messageHintCount : '99'}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),),
                        ),
                      )
                    ],
                  )
                ),
                TextButton(
                  onPressed: () {
                    DialogUtil.loginRedirectConfirm(context, callback: (isLogined){
                      if(isLogined){
                        Navigator.of(context).push(MaterialPageRoute(builder: (context){
                          return const UserCenterPage();
                        }));
                      }
                    });
                  },
                  child: Row(
                    children: [
                      svgUserWidget,
                      const SizedBox(width: 10,),
                      const Text('我的', style: TextStyle(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 18),)
                    ],
                  ),
                )
              ]
            ),
          ),
        ),
      ),
    );
  }

  void shiftMenu(){
    if(isMenuShowInFuture){
      hideMenu();
    }
    else{
      showMenu();
    }
  }

  void showMenu(){
    isMenuShowInFuture = true;
    isMenuShowInFact = true;
    _menuAnimController.forward();
    setState(() {
    });
  }

  void hideMenu(){
    isMenuShowInFuture = false;
    _menuAnimController.reverse().then((value){
      isMenuShowInFact = false;
      if(mounted && context.mounted){
        setState(() {
        });
      }
    });
  }

  Future drawMarker() async{
    Set<Marker> buffer = {};
    List<LatLngBounds> filledBounds = [];
    MarkerWrapper? userMarker = await getUserMarker();
    if(userMarker != null){
      buffer.add(userMarker.marker);
      if(userMarker.size != null){
        filledBounds.add(GaodeUtil.getBoundsBySize(userMarker.marker.position, userMarker.size!, zoom));
      }
    }
    MarkerWrapper? targetMarker = await getTargetMarker();
    if(targetMarker != null){
      bool drawable = true;
      if(targetMarker.size != null){
        LatLngBounds bounds = GaodeUtil.getBoundsBySize(targetMarker.marker.position, targetMarker.size!, zoom);
        if(filledBounds.checkContact(bounds)){
          drawable = false;
        }
        else{
          filledBounds.add(bounds);
        }
      }
      if(drawable){
        buffer.add(targetMarker.marker);
      }
    }
    List<MarkerWrapper> nearMarkerList = await getNearProductMarkers();
    for(MarkerWrapper nearMarker in nearMarkerList){
      bool drawable = true;
      if(nearMarker.size != null){
        LatLngBounds bounds = GaodeUtil.getBoundsBySize(nearMarker.marker.position, nearMarker.size!, zoom);
        if(filledBounds.checkContact(bounds)){
          drawable = false;
        }
        else{
          filledBounds.add(bounds);
        }
      }
      if(drawable){
        buffer.add(nearMarker.marker);
      }
    }
    markers = buffer;
    resetState();
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

  Future<MarkerWrapper?> getTargetMarker() async{
    if(targetPos == null){
      return null;
    }
    ByteData? byteData = await GaodeUtil.widgetToByteData(
      SizedBox(
        width: 100,
        height: 100,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: svgLocation,
        ),
      )
    );
    BitmapDescriptor icon = BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
    Marker marker = Marker(
      position: targetPos!,
      icon: icon,
      infoWindowEnable: false,
      zIndex: 1
    );
    return MarkerWrapper(marker, size: const Size(100, 100));
  }

  Future<List<MarkerWrapper>> getNearProductMarkers() async{
    List<MarkerWrapper> list = [];
    switch(searchType){
      case ProductType.hotel:
        for(Hotel hotel in nearHotelList){
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
                      child: svgLocation
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
              if(hotel.id == null){
                ToastUtil.error('目标不存在');
                return;
              }
              ProductRedirector().redirect(productId: hotel.id!, type: ProductType.hotel, context: context);
            }
          );
          list.add(MarkerWrapper(marker, size: const Size(200, 80)));
        }
        break;
      case ProductType.scenic:
        for(Scenic scenic in nearScenicList){
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
                      child: svgLocation
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
              if(scenic.id == null){
                ToastUtil.error('目标不存在');
                return;
              }
              ProductRedirector().redirect(productId: scenic.id!, type: ProductType.scenic, context: context);
            }
          );
          list.add(MarkerWrapper(marker, size: const Size(200, 80)));
          }
        break;
      case ProductType.restaurant:
        for(Restaurant restaurant in nearRestaurantList){
          if(restaurant.lat == null || restaurant.lng == null || restaurant.id == null){
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
                      child: svgLocation,
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
              ProductRedirector().redirect(productId: restaurant.id!, type: ProductType.restaurant, context: context);
            }
          );
          list.add(MarkerWrapper(marker, size: const Size(200, 80)));
          }
        break;
      default:
    }
    return list;
  }

  Widget getMapWidget(){
    return AMapWidget(
      apiKey: const AMapApiKey(androidKey: ConstConfig.amapApiKeyOfAndroid, iosKey: ConstConfig.amapApiKeyOfIOS),
      onMapCreated: (controller){
        mapController = controller;
        startLocation();
      },
      onCameraMove: (cameraMove){
        zoom = cameraMove.zoom;
        drawMarker();
      },
      onTap: (latlng){
        FocusScope.of(context).unfocus();
        targetPos = latlng;
        drawMarker();
        searchNearProduct();
      },
      initialCameraPosition: const CameraPosition(target: DEFAULT_POS, zoom: DEFAULT_ZOOM),
      privacyStatement: const AMapPrivacyStatement(hasContains: true, hasShow: true, hasAgree: true),
      mapType: MapType.navi,
      zoomGesturesEnabled: true,
      buildingsEnabled: false,
      labelsEnabled: true,
      tiltGesturesEnabled: false,
      rotateGesturesEnabled: false,
      markers: markers
    );
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

  Future searchProductByText() async{
    String text = searchTextController.text.trim();
    switch(searchType){
      case ProductType.hotel:
        List<Hotel>? result = await HotelApi().search(city: city, keyword: text);
        result ??= [];
        List<Hotel> tmpList = [];
        for(Hotel hotel in result){
          tmpList.add(hotel);
        }
        nearHotelList = tmpList;
        break;
      case ProductType.scenic:
        List<Scenic>? result = await ScenicApi().search(city: city, keyword: text);
        result ??= [];
        List<Scenic> tmpList = [];
        for(Scenic scenic in result){
          tmpList.add(scenic);
        }
        nearScenicList = tmpList;
        break;
      case ProductType.restaurant:
        List<Restaurant>? result = await RestaurantApi().search(city: city, keyword: text);
        result ??= [];
        List<Restaurant> tmpList = [];
        for(Restaurant restaurant in result){
          tmpList.add(restaurant);
        }
        nearRestaurantList = tmpList;
        break;
      default:
    }
    resetState();
    drawMarker();
  }

  Future searchNearProduct() async{
    if(targetPos == null){
      return;
    }
    switch(searchType){
      case ProductType.hotel:
        List<Hotel>? result = await NearHttp().nearHotel(latitude: targetPos!.latitude, longitude: targetPos!.longitude, radius: NEAR_RADIUS);
        nearHotelList = result ?? [];
        isShowWaist = nearHotelList.isNotEmpty;
        break;  
      case ProductType.scenic:
        List<Scenic>? result = await NearHttp().nearScenic(latitude: targetPos!.latitude, longitude: targetPos!.longitude, radius: NEAR_RADIUS);
        nearScenicList = result ?? [];
        isShowWaist = nearScenicList.isNotEmpty;
        break;
      case ProductType.restaurant:
        List<Restaurant>? result = await NearHttp().nearRestaurant(latitude: targetPos!.latitude, longitude: targetPos!.longitude, radius: NEAR_RADIUS);
        nearRestaurantList = result ?? [];
        isShowWaist = nearRestaurantList.isNotEmpty;
        break;
      default:
    }
    resetState();
  }

  Future startLocation() async{
    bool granted = await PermissionUtil().requestPermission(context: context, permission: Permission.location, info: '希望获取您的当前位置用于推荐附近地点');
    if(granted){
      startAmapLocation();
    }
  }

  void startAmapLocation(){
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
        bool cameraMove = userPos == null;
        userPos = LatLng(latitude, longitude);
        if(targetPos == null){
          targetPos = userPos;
          searchNearProduct();
        }
        drawMarker();
        if(cameraMove){
          mapController.moveCamera(CameraUpdate.newLatLng(userPos!));
        }
      } 
    });
    locationUtil.startLocation();
  }
}
