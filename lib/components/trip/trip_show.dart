
import 'package:amap_flutter_base/amap_flutter_base.dart' as amap_flutter_base;
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/facade/near_http.dart';
import 'package:freego_flutter/components/hotel_neo/api/hotel_api.dart';
import 'package:freego_flutter/components/hotel_neo/api/panhe_hotel_api.dart';
import 'package:freego_flutter/components/hotel_neo/hotel_common.dart';
import 'package:freego_flutter/components/hotel_neo/hotel_home_freego.dart';
import 'package:freego_flutter/components/hotel_neo/api/local_hotel_api.dart';
import 'package:freego_flutter/components/restaurant/restaurant_common.dart' as restaurant_model;
import 'package:freego_flutter/components/restaurant/restaurant_common.dart';
import 'package:freego_flutter/components/restaurant/restaurant_home.dart';
import 'package:freego_flutter/components/restaurant/restaurant_api.dart';
import 'package:freego_flutter/components/scenic/api/scenic_api.dart';
import 'package:freego_flutter/components/scenic/scenic_common.dart';
import 'package:freego_flutter/components/scenic/scenic_home_freego.dart';
import 'package:freego_flutter/components/scenic/api/local_scenic_api.dart';
import 'package:freego_flutter/components/trip/trip_common.dart';
import 'package:freego_flutter/components/view/radio_group.dart';
import 'package:freego_flutter/config/const_config.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/http/http_gaode.dart';
import 'package:freego_flutter/http/http_gaode_route.dart';
import 'package:freego_flutter/model/map_poi.dart';
import 'package:freego_flutter/util/context_util.dart';
import 'package:freego_flutter/util/gaode_util.dart';
import 'package:freego_flutter/util/local_service_util.dart';
import 'package:freego_flutter/util/permission_util.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:permission_handler/permission_handler.dart';

class TripShowPage extends StatefulWidget{
  final TripVo trip;
  const TripShowPage(this.trip, {super.key});

  @override
  State<StatefulWidget> createState() {
    return TripShowPageState();
  }
  
}

class TripShowPageState extends State<TripShowPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      resizeToAvoidBottomInset: false,
      body: TripShowWidget(widget.trip),
    );
  }

}

class TripShowWidget extends StatefulWidget{
  final TripVo trip;
  const TripShowWidget(this.trip, {super.key});

  @override
  State<StatefulWidget> createState() {
    return TripShowState();
  }
  
}

enum NearType{
  hotel,
  scenic,
  restaurnt
}

class TripShowState extends State<TripShowWidget> with TickerProviderStateMixin{

  static const amap_flutter_base.LatLng DEFAULT_POS = amap_flutter_base.LatLng(39.909187, 116.397451);
  static const double DEFAULT_ZOOM = 12;
  double zoom = DEFAULT_ZOOM;

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  AMapController? mapController;

  int currentDay = 1;
  List<TripPoint> points = [];
  List<List<LatLng>> polylineList = [];

  LatLng? userPos;
  AMapFlutterLocation locationUtil = AMapFlutterLocation();

  static const double TRIP_POINT_MARKER_SIZE = 140;
  static const double POI_AROUND_MARKER_SIZE = 100;
  Widget svgPointSelected = SvgPicture.asset('svg/trip/trip_point_center.svg');
  Widget svgPointAvailable = SvgPicture.asset('svg/trip/trip_point_around.svg');

  TripPoint? showPoint;

  static const int NEAR_SLIDE_MILLI_SECONDS = 300;
  static const int NEAR_SLIDE_GAP_MILLI_SECONDS = 50;
  late AnimationController nearHotelSlideAnim;
  late AnimationController nearScenicSlideAnim;
  late AnimationController nearRestaurantSlideAnim;
  TripPoint? nearCenterPoint;
  bool isNearMenuDisplayed = false;
  RadioGroupController radioGroupController = RadioGroupController();
  NearType? nearType;
  List<Hotel>? hotelList;
  List<Scenic>? scenicList;
  List<Restaurant>? restaurantList;
  Object? selectedAroundPoint;
  double searchRadius = 50 * 1000;
  String? targetCity;
  LatLng? selectedPosition;

  @override
  void initState(){
    super.initState();
    nearHotelSlideAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: NEAR_SLIDE_MILLI_SECONDS));
    nearScenicSlideAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: NEAR_SLIDE_MILLI_SECONDS));
    nearRestaurantSlideAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: NEAR_SLIDE_MILLI_SECONDS));
  }

  @override
  void dispose(){
    radioGroupController.dispose();
    nearHotelSlideAnim.dispose();
    nearScenicSlideAnim.dispose();
    nearRestaurantSlideAnim.dispose();
    locationUtil.destroy();
    mapController?.disponse();
    super.dispose();
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
        switchDay();
        startLocation();
      },
      onCameraMove: onCameraMove,
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

    return Stack(
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
              const SizedBox(height: 10,),
              Container(
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
                  children: getDayWidgets(),
                )
              )
            ],
          ),
        ),
        Positioned(
          right: 0,
          top: 60 + ThemeUtil.getStatusBarHeight(ContextUtil.getContext()!),
          child: getNearMenuWidget(),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: getBottomBlock()
        ),
      ],
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
            if(hotel.id == null){
              ToastUtil.error('数据错误');
              return;
            }
            DateTime startDate = DateTime.now();
            startDate = DateTime(startDate.year, startDate.month, startDate.day);
            DateTime endDate = startDate.add(const Duration(days: 1));
            Hotel? target = await LocalHotelApi().detail(id: hotel.id!, startDate: startDate, endDate: endDate);
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
            if(scenic.id == null){
              ToastUtil.error('数据错误');
              return;
            }
            Scenic? target = await LocalScenicApi().detail(scenic.id!);
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
    if(showPoint != null){
      return TripPointWidget(showPoint!);
    }
    return const SizedBox();
  }

  Future drawMarker() async{
    drawLine();
    List<Marker> buffer = [];
    List<amap_flutter_base.LatLngBounds> filledBounds = [];
    MarkerWrapper? userMarker = await getUserMarker();
    if(userMarker != null){
      buffer.add(userMarker.marker);
    }

    List<MarkerWrapper> tripPointMarkers = await getTripPointMarkers();
    for(MarkerWrapper markerWrapper in tripPointMarkers){
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

    if(showPoint != null && nearType != null) {
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

    markers = {};
    for(Marker marker in buffer.reversed){
      markers.add(marker);
    }
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }

  void drawLine() {
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
    if(context.mounted){
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
            selectedPosition = LatLng(hotel.latitude!, hotel.longitude!);
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
            selectedPosition = LatLng(scenic.latitude!, scenic.longitude!);
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
            selectedPosition = LatLng(restaurant.lat!, restaurant.lng!);
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

  Future<List<MarkerWrapper>> getTripPointMarkers() async{
    List<MarkerWrapper> list = [];
    for(TripPoint point in points){
      if(point.latitude == null || point.longitude == null || point.orderNum == null){
        continue;
      }
      ByteData? byteData = await GaodeUtil.widgetToByteData(
        SizedBox(
          width: TRIP_POINT_MARKER_SIZE,
          height: TRIP_POINT_MARKER_SIZE,
          child: point == showPoint ?
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
        }
      );
      list.add(MarkerWrapper(marker, size: const Size(TRIP_POINT_MARKER_SIZE, TRIP_POINT_MARKER_SIZE)));
    }
    return list;
  }

  void choosePoint(TripPoint point){
    selectedAroundPoint = null;
    if(point == showPoint){
      return;
    }
    if(point != nearCenterPoint){
      nearCenterPoint = point;
      hotelList = scenicList = restaurantList = null;
    }
    showPoint = point;
    nearType = null;
    radioGroupController.setValue(null);
    selectedPosition = LatLng(point.latitude!, point.longitude!);
    setState(() {
    });
    drawMarker();
    showNearMenu();
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
      icon: icon,
      infoWindowEnable: false
    );
    return MarkerWrapper(marker, size: const Size(60, 60));
  }

  Future startLocation() async{
    if(! await LocalServiceUtil.checkGpsEnabled()){
      ToastUtil.error('未开启定位服务');
      return;
    }
    if(! await PermissionUtil().checkPermission(Permission.location)){
      ToastUtil.error('未开启定位权限');
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
        await drawMarker();
      }
    });
    locationUtil.startLocation();
  }

  Future getRoute() async{
    polylineList = [];
    for(int i = 0; i < points.length - 1; ++i){
      TripPoint from = points[i];
      TripPoint to = points[i + 1];
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

  Future switchDay() async{
    radioGroupController.setValue(null);
    List<TripPoint>? list = widget.trip.points?.where((element) => element.orderNum != null && element.tripDay == currentDay).toList();
    if(list != null){
      list.sort((a, b){
        if(a.orderNum! <= b.orderNum!){
          return -1;
        }
        return 1;
      });
      points = list;
      LatLngBounds? bounds = getBounds(list);
      if(bounds != null){
        mapController?.moveCamera(CameraUpdate.newLatLngBounds(bounds, 50));
      }
      showPoint = null;
      drawMarker();
      await getRoute();
      drawLine();
    }
  }

  LatLngBounds? getBounds(List<TripPoint> list){
    if(list.isEmpty){
      return null;
    }
    double minLat = double.infinity;
    double maxLat = double.negativeInfinity;
    double minLng = double.infinity;
    double maxLng = double.negativeInfinity;
    for(TripPoint point in list){
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

  List<Widget> getDayWidgets(){
    Trip trip = widget.trip;
    List<Widget> widgets = [];
    for(int i = 1; i <= (trip.totalNum ?? 0); ++i){
      widgets.add(
        GestureDetector(
          onTap: (){
            currentDay = i;
            showPoint = null;
            switchDay();
          },
          child: Container(
            width: 80,
            height: 36,
            color: currentDay == i ? const Color.fromRGBO(4, 182, 221, 0.8) : const Color.fromRGBO(255, 255, 255, 0.8),
            alignment: Alignment.center,
            child: Text('第 $i 天', style: TextStyle(color: currentDay == i ? Colors.white : ThemeUtil.foregroundColor, fontWeight: FontWeight.bold),),
          ),
        )
      );
    }
    return widgets;
  }

  Future hideNearMenu() async{
    isNearMenuDisplayed = false;
    radioGroupController.setValue(null);
    nearRestaurantSlideAnim.reverse();
    await Future.delayed(const Duration(milliseconds: NEAR_SLIDE_GAP_MILLI_SECONDS));
    nearScenicSlideAnim.reverse();
    await Future.delayed(const Duration(milliseconds: NEAR_SLIDE_GAP_MILLI_SECONDS));
    nearHotelSlideAnim.reverse();
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
        List<Scenic>? panheList = await ScenicApi().near(latitude: selectedPosition!.latitude, longitude: selectedPosition!.longitude, radius: searchRadius, pageSize: 50);
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
        for(Scenic localScenic in scenicList!){
          if(scenic.likeTheSame(localScenic)){
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

}

class TripPointWidget extends StatefulWidget{
  final TripPoint point;

  const TripPointWidget(this.point, {super.key});
  
  @override
  State<StatefulWidget> createState() {
    return TripPointState();
  }

}

class TripPointState extends State<TripPointWidget>{

  @override
  Widget build(BuildContext context) {
    TripPoint point = widget.point;
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
        onTap: () async{
          PoiType? poiType;
          if(point.type != null){
            poiType = PoiTypeExt.getType(point.type!);
          }
          if(poiType == PoiType.hotel){
            Hotel? hotel = await HotelApi().detail(outerId: point.outerId, source: point.source);
            if(hotel != null){
              if(mounted && context.mounted){
                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                  return HotelHomePage(hotel);
                }));
              }
            }
          }
          if(poiType == PoiType.scenic){
            Scenic? scenic = await ScenicApi().detail(outerId: point.outerId, source: point.source);
            if(scenic != null){
              if(mounted && context.mounted){
                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                  return ScenicHomePage(scenic);
                }));
              }
            }
          }
        },
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
                          child: point.image == null ?
                          Image.asset('images/bg.png', fit: BoxFit.cover, width: double.infinity, height: double.infinity,) :
                          Image.network(point.image!, fit: BoxFit.cover, width: double.infinity, height: double.infinity,)
                        ),
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
                              Text(point.name ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold),),
                              Text(point.address ?? '', maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey,),),
                              const SizedBox()
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                )
              ],
            )
          ),
        ),
      ),
    );
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
