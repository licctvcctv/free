import 'dart:math';

import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/hotel_neo/api/hotel_api.dart';
import 'package:freego_flutter/components/hotel_neo/api/local_hotel_api.dart';
import 'package:freego_flutter/components/hotel_neo/api/panhe_hotel_api.dart';
import 'package:freego_flutter/components/hotel_neo/hotel_common.dart';
import 'package:freego_flutter/components/hotel_neo/hotel_home_freego.dart';
import 'package:freego_flutter/components/restaurant/restaurant_common.dart';
import 'package:freego_flutter/components/restaurant/restaurant_home.dart';
import 'package:freego_flutter/components/restaurant/restaurant_api.dart';
import 'package:freego_flutter/components/scenic/api/local_scenic_api.dart';
import 'package:freego_flutter/components/scenic/api/panhe_scenic_api.dart';
import 'package:freego_flutter/components/scenic/api/scenic_api.dart';
import 'package:freego_flutter/components/scenic/scenic_common.dart';
import 'package:freego_flutter/components/scenic/scenic_home_freego.dart';
import 'package:freego_flutter/components/travel/travel_common.dart';
import 'package:freego_flutter/components/travel/travel_detail.dart';
import 'package:freego_flutter/components/travel/travel_api.dart';
import 'package:freego_flutter/components/view/city_picker.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/custom_indicator.dart';
import 'package:freego_flutter/components/view/item_box_wrap.dart';
import 'package:freego_flutter/components/view/keep_alive_wrapper.dart';
import 'package:freego_flutter/components/view/notify_empty.dart';
import 'package:freego_flutter/components/view/notify_loading.dart';
import 'package:freego_flutter/components/view/titled_swiper.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/http/http_restaurant.dart';
import 'package:freego_flutter/util/permission_util.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:permission_handler/permission_handler.dart';

class ProductHomePage extends StatefulWidget{
  const ProductHomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return ProductHomePageState();
  }

}

class ProductHomePageState extends State<ProductHomePage>{
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
      body: GestureDetector(
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: const ProductHomeWidget(),
      ),
    );
  }

}

class ProductHomeWidget extends StatefulWidget{
  const ProductHomeWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return ProductHomeState();
  }

}

class ProductHomeState extends State<ProductHomeWidget> with TickerProviderStateMixin{

  String city = '杭州市';
  final AMapFlutterLocation amapLocation = AMapFlutterLocation();

  static const double SEARCH_ICON_SIZE = 36;
  static const int SEARCH_BAR_ANIM_MILLI_SECONDS = 200;
  static const double SEARCH_BAR_SUBMIT_WIDTH_FACTOR = 0.22;

  late AnimationController searchAnim;
  late AnimationController searchOpacityAnim;
  Widget svgSearch = SvgPicture.asset('svg/chat/chat_search.svg');
  Widget svgSearchSubmit = SvgPicture.asset('svg/chat/chat_search_submit.svg');
  bool isShowSearchNavi = true;
  TextEditingController textController = TextEditingController();
  FocusNode textFocus = FocusNode();

  static const List<String> texts = ['酒店', '景点', '美食', '旅游'];
  static const HOTEL_INDEX = 0;
  static const SCENIC_INDEX = 1;
  static const RESTAURANT_INDEX = 2;
  static const TRAVEL_INDEX = 3;

  TitledSwiperController swiperController = TitledSwiperController();
  
  int index = HOTEL_INDEX;
  Widget? hotelWidget;
  Widget? scenicWidget;
  Widget? restaurantWidget;
  Widget? travelWidget;

  @override
  void dispose(){
    amapLocation.destroy();
    searchAnim.dispose();
    searchOpacityAnim.dispose();
    textController.dispose();
    textFocus.removeListener(onTextFocus);
    textFocus.dispose();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    searchAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: SEARCH_BAR_ANIM_MILLI_SECONDS));
    searchOpacityAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: SEARCH_BAR_ANIM_MILLI_SECONDS));
    textFocus.addListener(onTextFocus);
    startLocation();
    search(textController.text);
    swiperController.onChange = (index){
      this.index = index;
      switch(index){
        case HOTEL_INDEX:
          if(hotelWidget == null){
            hotelWidget = getHotelWidget();
            setState(() {
            });
          }
          break;
        case SCENIC_INDEX:
          if(scenicWidget == null){
            scenicWidget = getScenicWidget();
            setState(() {
            });
          }
          break;
        case RESTAURANT_INDEX:
          if(restaurantWidget == null){
            restaurantWidget = getRestaurantWidget();
            setState(() {
            });
          }
          break;
        case TRAVEL_INDEX:
          if(travelWidget == null){
            travelWidget = getTravelWidget();
            setState(() {
            });
          }
          break;
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeUtil.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonHeader(
            center: Text('服务', style: TextStyle(color: Colors.white, fontSize: 18),),
          ),
          const SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap
                ),
                onPressed: () async{
                  String? cityName = await Navigator.of(context).push(MaterialPageRoute(builder: (context){
                    return const CityPickerPage();
                  }));
                  if(cityName != null && cityName != city){
                    city = cityName;
                    //city = city.substring(0, city.length - 1);
                    if(mounted && context.mounted){
                      setState(() {
                      });
                    }
                    hotelWidget = scenicWidget = restaurantWidget = travelWidget = null;
                    search(textController.text);
                  }
                },
                child: Container(
                  height: 40,
                  decoration: const BoxDecoration(
                    color: ThemeUtil.dividerColor,
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(10))
                  ),
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                  alignment: Alignment.center,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: city, style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
                        const TextSpan(text: '>', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
                      ]
                    ),
                  )
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: isShowSearchNavi ?
                  InkWell(
                    onTap: (){
                      isShowSearchNavi = false;
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) { 
                        FocusScope.of(context).requestFocus(textFocus);
                      });
                      searchAnim.forward();
                      searchOpacityAnim.forward();
                      setState(() {
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: SizedBox(
                        width: SEARCH_ICON_SIZE,
                        height: SEARCH_ICON_SIZE,
                        child: svgSearch,
                      ),
                    ),
                  ) :
                  AnimatedBuilder(
                    animation: searchAnim, 
                    builder:(context, child) {
                      return FadeTransition(
                        opacity: searchOpacityAnim,
                        child: FractionallySizedBox(
                          alignment: Alignment.centerRight,
                          widthFactor: searchAnim.value,
                          child: Container(
                            margin: const EdgeInsets.only(left: 10),
                            height: 40,
                            width: double.infinity,
                            child: Wrap(
                              children: [
                                FractionallySizedBox(
                                  widthFactor: 0.99 - SEARCH_BAR_SUBMIT_WIDTH_FACTOR,
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minWidth: SEARCH_ICON_SIZE
                                    ),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.horizontal(left: Radius.circular(9999))
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                    child: TextField(
                                      keyboardType: TextInputType.multiline,
                                      textInputAction: TextInputAction.search,
                                      decoration: const InputDecoration(
                                        hintText: '    搜 索',
                                        hintStyle: TextStyle(color: Colors.grey,),
                                        isDense: true,
                                        contentPadding: EdgeInsets.fromLTRB(8, 10, 8, 10),
                                        border: InputBorder.none,
                                      ),
                                      style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),
                                      controller: textController,
                                      focusNode: textFocus,
                                      onSubmitted: search,
                                    ),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: SEARCH_BAR_SUBMIT_WIDTH_FACTOR,
                                  child: InkWell(
                                    onTap: (){
                                      search(textController.text);
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.horizontal(right: Radius.circular(9999)),
                                        color: ThemeUtil.dividerColor
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      width: SEARCH_ICON_SIZE,
                                      height: 40,
                                      child: SizedBox(
                                        width: SEARCH_ICON_SIZE * 0.7,
                                        height: SEARCH_ICON_SIZE * 0.7,
                                        child: svgSearchSubmit,
                                      )
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                ),
              )
            ],
          ),
          const SizedBox(height: 10,),
          Expanded(
            child: TitledSwiper(
              controller: swiperController,
              pages: getPages(),
              titles: getTitles(),
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
    widgets.add(hotelWidget ?? const SizedBox());
    widgets.add(scenicWidget ?? const SizedBox());
    widgets.add(restaurantWidget ?? const SizedBox());
    widgets.add(travelWidget ?? const SizedBox());
    return widgets;
  }

  Widget getHotelWidget(){
    return HotelWidget(city: city, keyword: textController.text.trim(), key: UniqueKey(),);
  }

  Widget getRestaurantWidget(){
    return RestaurantWidget(city: city, keyword: textController.text.trim(), key: UniqueKey(),);
  }

  Widget getScenicWidget(){
    return ScenicWidget(city: city, keyword: textController.text.trim(), key: UniqueKey(),);
  }

  Widget getTravelWidget(){
    return TravelWidget(city: city, keyword: textController.text.trim(), key: UniqueKey(),);
  }

  void search(String val){
    switch(index){
      case HOTEL_INDEX:
        hotelWidget = getHotelWidget();
        scenicWidget = restaurantWidget = travelWidget = null;
        setState(() {
        });
        break;
      case SCENIC_INDEX:
        scenicWidget = getScenicWidget();
        hotelWidget = restaurantWidget = travelWidget = null;
        setState(() {
        });
        break;
      case RESTAURANT_INDEX:
        restaurantWidget = getRestaurantWidget();
        hotelWidget = scenicWidget = travelWidget = null;
        setState(() {
        });
        break;
      case TRAVEL_INDEX:
        travelWidget = getTravelWidget();
        hotelWidget = scenicWidget = restaurantWidget = null;
        setState(() {
        });
        break;
      default:
    }
  }

  void onTextFocus(){
    if(!textFocus.hasFocus){
      if(textController.text.trim().isEmpty){
        textController.text = '';
        searchAnim.reverse().then((value){
          isShowSearchNavi = true;
          if(mounted && context.mounted){
            setState(() {
            });
          }
        });
        searchOpacityAnim.reverse();
      }
    }
  }

  Future startLocation() async{
    bool isGranted = await PermissionUtil().requestPermission(context: context, permission: Permission.location, info: '希望获取当前位置用于获取您所在城市');
    if(!isGranted){
      return;
    }
    amapLocation.onLocationChanged().listen((event) {
      if(event['city'] is String){
        city = event['city'].toString();
        if(mounted && context.mounted){
          setState(() {
          });
        }
        amapLocation.stopLocation();
      }
    });
    amapLocation.startLocation();
  }
  
}

class HotelWidget extends StatefulWidget{

  final String city;
  final String keyword;

  const HotelWidget({required this.city, this.keyword = '', super.key});

  @override
  State<StatefulWidget> createState() {
    return HotelState();
  }
  
}

class HotelState extends State<HotelWidget>{

  static const int pageSize = 20;

  List<Hotel>? hotelList;
  int hotelPage = 0;
  bool localData = true;

  List<Widget> topBuffer = [];
  List<Widget> contentWidgets = [];
  List<Widget> bottomBuffer = [];

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      appendHotel();
    },);
  }

  @override
  Widget build(BuildContext context) {
    if(hotelList == null){
      return const NotifyLoadingWidget();
    }
    if(hotelList!.isEmpty){
      return const NotifyEmptyWidget();
    }
    return KeepAliveWrapperWidget(
            content: Column(
        children: [
        // 添加获取20条数据的按钮
          /*ElevatedButton(
            onPressed: fetchAndPrintHotelDetails,
            child: const Text('获取20条酒店数据并打印'),
          ),*/
          Expanded(

      child: AnimatedCustomIndicatorWidget(
        topBuffer: topBuffer,
        contents: contentWidgets,
        bottomBuffer: bottomBuffer,
        touchBottom: appendHotel,
            ),
          ),
        ],
      ),
    );
  }
  Future<void> fetchAndPrintHotelDetails() async {
  try {
    // 显示页码输入弹窗
    final selectedPage = await showDialog<int>(
      context: context,
      builder: (context) {
        final textController = TextEditingController();
        return AlertDialog(
          title: const Text('输入页码'),
          content: TextField(
            controller: textController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              //hintText: '请输入页码(1-10)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (textController.text.isEmpty) {
                  Navigator.pop(context);
                  return;
                }
                final page = int.tryParse(textController.text) ?? 1;
                Navigator.pop(context, page);
              },
              child: const Text('确定'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
          ],
        );
      },
    );

    if (selectedPage == null) return; // 用户取消了输入

    //ToastUtil.loading('正在获取酒店详细信息...');

    // 1. 获取指定页码的酒店基本信息
    const int pageSize = 1;
    
    List<Hotel>? hotels = await PanheHotelApi().search(
      city: widget.city, 
      keyword: widget.keyword, 
      pageNum: selectedPage, 
      pageSize: pageSize
    );

    if (hotels == null || hotels.isEmpty) {
      //ToastUtil.dismiss();
      ToastUtil.error('获取数据失败或该页无数据');
      return;
    }

    // 2. 对每条酒店获取详细信息（添加4~7秒随机间隔）
    DateTime currentDate = DateTime.now();
    DateTime checkInDate = DateTime(currentDate.year, currentDate.month, currentDate.day);
    DateTime checkOutDate = checkInDate.add(const Duration(days: 1));
    
    for (var hotel in hotels) {
      try {
        // 生成4~7秒的随机间隔
        final randomDelay = Duration(seconds: 4 + Random().nextInt(4)); // 4~7秒
        //debugPrint('等待 ${randomDelay.inSeconds} 秒后获取下一条...');
        await Future.delayed(randomDelay); // 等待随机时间
        
        Hotel? detail = await HotelApi().detail(
          id: hotel.id,
          outerId: hotel.outerId,
          source: hotel.source,
          startDate: checkInDate,
          endDate: checkOutDate
        );
        if (detail != null) {
          // 3. 获取酒店房间信息
          try {
            // 生成4~7秒的随机间隔
            final randomDelay = Duration(seconds: 4 + Random().nextInt(4));
            await Future.delayed(randomDelay);
            
            List<HotelChamber>? chambers = await PanheHotelApi().chamber(
              outerId: hotel.outerId!,
              startDate: checkInDate,
              endDate: checkOutDate
            );
            
            if (chambers != null && chambers.isNotEmpty) {
              debugPrint('获取到 ${hotel.name} 的 ${chambers.length} 个房间信息');
              // 这里可以对获取到的房间信息进行处理
              // 例如：存储到本地、显示在UI上等
            } else {
              debugPrint('${hotel.name} 没有可用房间信息');
            }
          } catch (e) {
            debugPrint('获取 ${hotel.name} 的房间信息异常: $e');
          }
        }
        } catch (e) {
        debugPrint('获取酒店详情异常: ${hotel.name} - $e');
      }
    }
    
    //ToastUtil.dismiss();
    //ToastUtil.success('酒店详细信息获取完成');
  } catch (e) {
    //ToastUtil.dismiss();
    ToastUtil.error('获取数据失败: ${e.toString()}');
  }
}

  void goHotelPage(Hotel hotel){
    if(hotel.id == null && hotel.outerId == null){
      ToastUtil.error('参数错误');
      return;
    }
    Future.delayed(Duration.zero, () async{
      DateTime startDate = DateTime.now();
      startDate = DateTime(startDate.year, startDate.month, startDate.day);
      DateTime endDate = startDate.add(const Duration(days: 1));
      Hotel? vo = await HotelApi().detail(id: hotel.id, outerId: hotel.outerId, source: hotel.source, startDate: startDate, endDate: endDate);
      if(vo == null){
        ToastUtil.error('目标不存在');
        return;
      }
      if(mounted && context.mounted){
        Navigator.of(context).push(MaterialPageRoute(builder: (context){
          return HotelHomePage(vo, startDate: startDate, endDate: endDate,);
        }));
      }
    });
  }

  List<Widget> getHotelWidgets(List<Hotel> list){
    List<Widget> widgets = [];
    double width = (MediaQuery.of(context).size.width - 30) / 2;
    for(int i = 0; i < list.length / 2; ++i){
      Hotel hotel1 = list[2 * i];
      Hotel? hotel2;
      if(2 * i + 1 < list.length){
        hotel2 = list[2 * i + 1];
      }
      widgets.add(
        const SizedBox(height: 10,)
      );
      widgets.add(
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width
          ),
          child: Row(
            children: [
              const SizedBox(width: 10,),
              Flexible(
                flex: 1,
                child: AspectRatio(
                  aspectRatio:  1 / 1.4,
                  child: getItemBox(
                    width: width,
                    height: width * 1.4,
                    cover: hotel1.cover != null ? getFullUrl(hotel1.cover!) : null,
                    score: hotel1.score,
                    price: hotel1.price,
                    name: hotel1.name,
                    onClick: (){
                      goHotelPage(hotel1);
                    }
                  )
                ),
              ),
              const SizedBox(width: 10,),
              Flexible(
                flex: 1,
                child: AspectRatio(
                  aspectRatio: 1 / 1.4,
                  child: 
                  hotel2 == null ?
                  const SizedBox() :
                  AspectRatio(
                    aspectRatio: 1 / 1.4,
                    child: getItemBox(
                      width: width,
                      height: width * 1.4,
                      cover: hotel2.cover != null ? getFullUrl(hotel2.cover!) : null,
                      score: hotel2.score,
                      price: hotel2.price,
                      name: hotel2.name,
                      onClick: (){
                        goHotelPage(hotel2!);
                      }
                    ),
                  )
                ),
              ),
              const SizedBox(width: 10,)
            ],
          ),
        )
      );
    }
    return widgets;
  }

  Future appendHotel() async{
    if(hotelPage > 10){
      return;
    }
    List<Hotel>? tmpList;
    if(localData){
      tmpList = await LocalHotelApi().search(keyword: widget.keyword, city: widget.city, pageNum: hotelPage + 1, pageSize: pageSize);
      if(tmpList != null && tmpList.length < pageSize){
        localData = false;
        hotelPage = 0;
      }
    }
    if(!localData){
      List<Hotel>? panheList = await PanheHotelApi().search(city: widget.city, keyword: widget.keyword, pageNum: hotelPage + 1, pageSize: pageSize,);
      if(panheList != null){
        tmpList ??= [];
        tmpList.addAll(panheList);
      }
    }
    if(tmpList == null){
      ToastUtil.error('好像出了点小问题');
      return;
    }
    hotelList ??= [];
    if(mounted && context.mounted){
      setState(() {
      });
    }
    if(tmpList.isEmpty){
      if(hotelPage > 0){
        ToastUtil.hint('已经没有了呢~');
      }
      return;
    }
    List<Widget> widgets = getHotelWidgets(tmpList);
    bottomBuffer.addAll(widgets);
    ++hotelPage;
    for(Hotel hotel in tmpList){
      bool theSame = false;
      for(Hotel localHotel in hotelList!){
        if(hotel.likeTheSame(localHotel)){
          theSame = true;
          break;
        }
      }
      if(!theSame){
        hotelList!.add(hotel);
      }
    }
  }
  
}

class ScenicWidget extends StatefulWidget{
  final String city;
  final String keyword;
  const ScenicWidget({required this.city, this.keyword = '', super.key});

  @override
  State<StatefulWidget> createState() {
    return ScenicState();
  }
  
}

class ScenicState extends State<ScenicWidget>{

  static const int pageSize = 20;

  List<Scenic>? scenicList;
  int scenicPage = 0;
  bool localData = true;

  List<Widget> topBuffer = [];
  List<Widget> contentWidgets = [];
  List<Widget> bottomBuffer = [];

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      appendScenic();
    },);
  }

  @override
  Widget build(BuildContext context) {
    if(scenicList == null){
      return const NotifyLoadingWidget();
    }
    if(scenicList!.isEmpty){
      return const NotifyEmptyWidget();
    }
    return KeepAliveWrapperWidget(
      content: AnimatedCustomIndicatorWidget(
        topBuffer: topBuffer,
        contents: contentWidgets,
        bottomBuffer: bottomBuffer,
        touchBottom: appendScenic,
      ),
    );
  }

  Future goScenicPage(Scenic scenic) async{
    if(scenic.id == null && (scenic.outerId == null || scenic.source == null)){
      ToastUtil.error('参数错误');
      return;
    }
    Future.delayed(Duration.zero, () async{
      Scenic? result = await ScenicApi().detail(id: scenic.id, outerId: scenic.outerId, source: scenic.source);
      if(result == null){
        ToastUtil.error('目标不存在');
        return;
      }
      if(mounted && context.mounted){
        Navigator.of(context).push(MaterialPageRoute(builder: (context){
          return ScenicHomePage(result);
        }));
      }
    });
  }

  List<Widget> getScenicWidgets(List<Scenic> list){
    List<Widget> widgets = [];
    double width = (MediaQuery.of(context).size.width - 30) / 2;
    for(int i = 0; i < list.length / 2; ++i){
      Scenic scenic1 = list[2 * i];
      Scenic? scenic2;
      if(2 * i + 1 < list.length){
        scenic2 = list[2 * i + 1];
      }
      widgets.add(
        const SizedBox(height: 10,)
      );
      widgets.add(
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width
          ),
          child: Row(
            children: [
              const SizedBox(width: 10,),
              Flexible(
                flex: 1,
                child: AspectRatio(
                  aspectRatio:  1 / 1.4,
                  child: getItemBox(
                    width: width,
                    height: width * 1.4,
                    cover: scenic1.cover != null ? getFullUrl(scenic1.cover!) : null,
                    score: scenic1.score,
                    price: scenic1.price,
                    name: scenic1.name,
                    onClick: (){
                      goScenicPage(scenic1);
                    }
                  )
                ),
              ),
              const SizedBox(width: 10,),
              Flexible(
                flex: 1,
                child: AspectRatio(
                  aspectRatio: 1 / 1.4,
                  child: 
                  scenic2 == null ?
                  const SizedBox() :
                  AspectRatio(
                    aspectRatio: 1 / 1.4,
                    child: getItemBox(
                      width: width,
                      height: width * 1.4,
                      cover: scenic2.cover != null ? getFullUrl(scenic2.cover!) : null,
                      score: scenic2.score,
                      price: scenic2.price,
                      name: scenic2.name,
                      onClick: (){
                        goScenicPage(scenic2!);
                      }
                    ),
                  )
                ),
              ),
              const SizedBox(width: 10,)
            ],
          ),
        )
      );
    }
    return widgets;
  }
  
  Future appendScenic() async{
    if(scenicPage > 10){
      return;
    }
    List<Scenic>? tmpList;
    if(localData){
      tmpList = await LocalScenicApi().search(city: widget.city, keyword: widget.keyword, pageNum: scenicPage + 1, pageSize: pageSize);
      if(tmpList != null && tmpList.length < pageSize){
        localData = false;
        scenicPage = 0;
      }
    }
    if(!localData){
      List<Scenic>? panheList = await PanheScenicApi().search(keyword: widget.keyword, city: widget.city, pageNum: scenicPage + 1, pageSize: pageSize);
      if(panheList != null){
        tmpList ??= [];
        tmpList.addAll(panheList);
      }
    }
    if(tmpList == null){
      ToastUtil.error('好像出了点小问题');
      return;
    }
    scenicList ??= [];
    if(mounted && context.mounted){
      setState(() {
      });
    }
    if(tmpList.isEmpty){
      if(scenicPage > 0){
        ToastUtil.hint('已经没有了呢~');
      }
      return;
    }
    List<Widget> widgets = getScenicWidgets(tmpList);
    bottomBuffer.addAll(widgets);
    ++scenicPage;
    for(Scenic scenic in tmpList){
      bool theSame = false;
      for(Scenic savedScenic in scenicList!){
        if(scenic.likeTheSame(savedScenic)){
          theSame = true;
          break;
        }
      }
      if(!theSame){
        scenicList!.add(scenic);
      }
    }
  }
}

class RestaurantWidget extends StatefulWidget{
  final String city;
  final String keyword;
  const RestaurantWidget({required this.city, this.keyword = '', super.key});

  @override
  State<StatefulWidget> createState() {
    return RestaurantState();
  }
  
}

class RestaurantState extends State<RestaurantWidget>{

  List<Restaurant>? restaurantList;
  int restaurantPage = 0;

  @override
  void initState(){
    super.initState();
    appendRestaurant();
  }

  @override
  Widget build(BuildContext context) {
    if(restaurantList == null){
      return const NotifyLoadingWidget();
    }
    if(restaurantList!.isEmpty){
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
              Restaurant restaurant = restaurantList![index];
              String? pic = restaurant.cover;
                if (pic != null && pic != '') {
                pic = getFullUrl(pic);
              }
              int? price;
              if (restaurant.averagePrice != null) {
                price = restaurant.averagePrice!;
              }
              return getItemBox(
                width: width, 
                height: height,
                cover: pic,
                score: restaurant.score,
                price: price,
                name: restaurant.name,
                onClick: () async{
                  if(restaurant.id == null){
                    ToastUtil.error('参数错误');
                    return;
                  }
                  Restaurant? target = await HttpRestaurant.getById(restaurant.id!);
                  if (target == null){
                    ToastUtil.error('目标不存在');
                      return;
                    }
                  if (mounted && context.mounted) {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                      return RestaurantHomePage(target);
                    }));
                  }
                }
              );
            },
            count: restaurantList!.length,
            childWidth: width,
            childHeight: height,
            column: 2,
          ),
        ),
        touchBottom: appendRestaurant
      ),
    );
  }
  
  Future appendRestaurant() async{
    List<Restaurant>? tmpList = await RestaurantApi().search(city: widget.city, keyword: widget.keyword, pageNum: restaurantPage + 1);
    if(tmpList == null){
      ToastUtil.error('好像出了点小问题');
      return;
    }
    restaurantList ??= [];
    if(mounted && context.mounted){
      setState(() {
      });
    }
    if(tmpList.isEmpty){
      if(restaurantPage > 0){
        ToastUtil.hint('已经没有了呢~');
      }
      return;
    }
    ++restaurantPage;
    restaurantList!.addAll(tmpList);
  }
}

class TravelWidget extends StatefulWidget{
  final String city;
  final String keyword;
  const TravelWidget({required this.city, this.keyword = '', super.key});

  @override
  State<StatefulWidget> createState() {
    return TravelState();
  }
  
}

class TravelState extends State<TravelWidget>{

  List<Travel>? travelList;
  int travelPage = 0;

  @override
  void initState(){
    super.initState();
    appendTravel();
  }

  @override
  Widget build(BuildContext context) {
    if(travelList == null){
      return const NotifyLoadingWidget();
    }
    if(travelList!.isEmpty){
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
              Travel travel = travelList![index];
              String? pic = travel.pics?.split(',')[0];
              if (pic != null && pic != '') {
                pic = getFullUrl(pic);
              }
              int? price;
              if (travel.minPrice != null) {
                price = travel.minPrice;
              }
              return getItemBox(
                width: width, 
                height: height,
                cover: pic,
                score: travel.score,
                price: price,
                name: travel.name,
                onClick: () async{
                  if(travel.id == null){
                    ToastUtil.error('参数错误');
                    return;
                  }
                  Future.delayed(Duration.zero, () async {
                    Travel? result = await TravelApi().getById(travelId: travel.id!);
                    if (result == null) {
                      ToastUtil.error('目标不存在');
                      return;
                    }
                    if (mounted && context.mounted) {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return TravelDetailPage(result);
                      }));
                    }
                  });
                },
              );
            },
            count: travelList!.length,
            childWidth: width,
            childHeight: height,
            column: 2,
          ),
        ),
        touchBottom: appendTravel,
      ),
    );
  }

  Future appendTravel() async{
    List<Travel>? tmpList = await TravelApi().search(city: widget.city, keyword: widget.keyword, pageNum: travelPage + 1);
    if(tmpList == null){
      ToastUtil.error('好像出了点小问题');
      return;
    }
    travelList ??= [];
    if(mounted && context.mounted) {
      setState(() {
      });
    }
    if(tmpList.isEmpty){
      if(travelPage > 0){
        ToastUtil.hint('已经没有了呢~');
      }
      return;
    }
    ++travelPage;
    travelList!.addAll(tmpList);
  }
  
}

ItemBox getItemBox({required double width, required double height, String? cover, double? score, int? price, String? name, Function()? onClick}){
  return ItemBox(
    width: width, 
    height: height, 
    onClick: onClick,
    cover: cover == null || cover == ''? 
    Image.asset('images/bg.png', fit: BoxFit.cover, width: double.infinity, height: double.infinity,) :
    Image.network(
      cover, fit: BoxFit.cover, width: double.infinity, height: double.infinity,
      errorBuilder:(context, error, stackTrace) {
        return Container(
          color: ThemeUtil.backgroundColor,
          alignment: Alignment.center,
          child: const Icon(Icons.error_outline, color: ThemeUtil.foregroundColor,),
        );
      },
    ),
    top: Container(
      width: width,
      alignment: Alignment.topRight,
      child: Column(
        children: [
          if(score != null)
          Container(
            width: 70,
            margin: const EdgeInsets.only(top: 5),
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            alignment: Alignment.topCenter,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(0, 0, 0, 0.3),
              borderRadius: BorderRadius.all(Radius.circular(6))
            ),
            child: Text('${(score/10).toStringAsFixed(1)}分', style: const TextStyle(color: Color.fromRGBO(255, 201, 12, 1), fontSize: 14),)
          ),
          if(price != null && price > 0)
          Container(
            width: 70,
            margin: const EdgeInsets.only(top: 5),
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            alignment: Alignment.topCenter,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(0, 0, 0, 0.3),
              borderRadius: BorderRadius.all(Radius.circular(6))
            ),
            child: Text('￥${StringUtil.getPriceStr(price)}', style: const TextStyle(color: Colors.blueAccent,fontWeight: FontWeight.bold, fontSize: 14),),
          )
        ],
      ),
    ),
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
