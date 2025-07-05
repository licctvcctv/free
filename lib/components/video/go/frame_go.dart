
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/facade/near_http.dart';
import 'package:freego_flutter/components/hotel_neo/api/hotel_api.dart';
import 'package:freego_flutter/components/hotel_neo/api/local_hotel_api.dart';
import 'package:freego_flutter/components/hotel_neo/api/panhe_hotel_api.dart';
import 'package:freego_flutter/components/hotel_neo/hotel_common.dart';
import 'package:freego_flutter/components/hotel_neo/hotel_home_freego.dart';
import 'package:freego_flutter/components/restaurant/restaurant_common.dart';
import 'package:freego_flutter/components/restaurant/restaurant_home.dart';
import 'package:freego_flutter/components/restaurant/restaurant_api.dart';
import 'package:freego_flutter/components/scenic/api/local_scenic_api.dart';
import 'package:freego_flutter/components/scenic/api/scenic_api.dart';
import 'package:freego_flutter/components/scenic/scenic_common.dart';
import 'package:freego_flutter/components/scenic/scenic_home_freego.dart';
import 'package:freego_flutter/components/video/go/video_go.dart';
import 'package:freego_flutter/components/view/radio_group.dart';
import 'package:freego_flutter/config/const_config.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/http/http_gaode.dart';
import 'package:freego_flutter/model/map_poi.dart';
import 'package:freego_flutter/util/app_redirect.dart';
import 'package:freego_flutter/util/gaode_util.dart';
import 'package:freego_flutter/util/local_service_new_util.dart';
import 'package:freego_flutter/util/local_service_util.dart';
import 'package:freego_flutter/util/permission_util.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:freego_flutter/util/video_tool/video_tool_api.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';

class FrameGoPage extends StatelessWidget{
  final int videoId;
  final int millis;
  const FrameGoPage({required this.videoId, required this.millis, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
        backgroundColor: ThemeUtil.backgroundColor,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      resizeToAvoidBottomInset: false,
      body: FrameGoWidget(videoId: videoId, millis: millis),
    );
  }
  
}

class FrameGoWidget extends StatefulWidget{
  final int videoId;
  final int millis;
  const FrameGoWidget({required this.videoId, required this.millis, super.key});

  @override
  State<StatefulWidget> createState() {
    return FrameGoState();
  }
  
}

class FrameGoState extends State<FrameGoWidget>{

  static const LatLng DEFAULT_POS = LatLng(39.909187, 116.397451);
  static const double DEFAULT_ZOOM = 12;
  static const bool ENABLE_GAODE_NEARPOINT = true;

  double zoom = DEFAULT_ZOOM;
  AMapFlutterLocation locationUtil = AMapFlutterLocation();

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  LatLng? userPos;
  //late AMapController aMapController;
  AMapController? aMapController;

  String? keyword;
  List<MapPoiModel> list = [];
  MapPoiModel? targetPoi;
  bool showTargetPoi = false;
  String? targetCity;

  static const double CENTER_MARKER_SIZE = 140;
  static const double POI_AROUND_MARKER_SIZE = 100;
  Widget svgPointSelected = SvgPicture.asset('svg/trip/trip_point_center.svg');
  Widget svgPointAvailable = SvgPicture.asset('svg/trip/trip_point_around.svg');

  static const int NEAR_SLIDE_MILLI_SECONDS = 300;
  static const int NEAR_SLIDE_GAP_MILLI_SECONDS = 50;
  bool isNearMenuDisplayed = false;
  RadioGroupController radioGroupController = RadioGroupController();
  NearType? nearType;
  List<Hotel>? hotelList;
  List<Scenic>? scenicList;
  List<Restaurant>? restaurantList;
  Object? selectedAroundPoint;
  double searchRadius = 50 * 1000;

  List<SimpleHotel>? simpleHotelList;
  List<SimpleScenic>? simpleScenicList;
  List<SimpleRestaurant>? simpleRestaurantList;

  @override
  void initState(){
    super.initState();
    radioGroupController = RadioGroupController(value: 0); // 初始化时就设置默认值
    nearType = NearType.hotel; // 设置默认类型
    Future.delayed(Duration.zero, () async{
      String? info = await VideoToolApi().getFrameInfo(id: widget.videoId, millis: widget.millis);
      keyword = info;
      debugPrint('获取的关键词: $keyword');
      resetState();
      /*if(keyword == null || keyword!.isEmpty){
        debugPrint('关键词为空，无法搜索地点'); 
        return;
      }*/
      if(keyword == null || keyword!.isEmpty) {
  showTargetPoi = true;
  if(targetPoi?.lat != null && targetPoi?.lng != null) {
    aMapController?.moveCamera(CameraUpdate.newLatLng(
      LatLng(targetPoi!.lat!, targetPoi!.lng!)
    ));
  }
}
      ToastUtil.hint(keyword!);
      
      List<MapPoiModel>? tmp = await HttpGaode.searchByKeyword(keyword!);
      if(tmp != null){
        list = tmp;
        if(list.isNotEmpty){
          targetPoi = list.first;
          showTargetPoi = true;
          aMapController?.moveCamera(CameraUpdate.newLatLng(LatLng(targetPoi!.lat!, targetPoi!.lng!)));
        }
        resetState();
      }
      menuChooseHotel();
    });
    
    startLocation();
  }

  @override
  void dispose(){
    locationUtil.destroy();
    aMapController?.disponse();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeUtil.backgroundColor,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10,),
              Row(
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
                  Expanded(
                    child: getRouteWidget(),
                  )
                ],
              ),
              getNearMenuWidget(),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: getBottomBlock(),
          )
        ],
      ),
    );
  }

  Widget getBottomBlock(){
    if(showTargetPoi){
      if(targetPoi != null){
        double? score;
        int? price;
        if(targetPoi?.score != null){
          score = double.tryParse(targetPoi!.score!);
          if(score != null){
            score *= 10;
          }
        }
        if(targetPoi?.cost != null){
          double? db = double.tryParse(targetPoi!.cost!);
          if(db != null){
            price = (db * 100).toInt();
          }
        }
        String? url;
        if(targetPoi?.photoList != null && targetPoi!.photoList!.isNotEmpty){
          url = targetPoi?.photoList?.first;
        }
        return PointBlock(
          name: targetPoi!.name,
          address: targetPoi!.address,
          score: score,
          price: price,
          mainImage: url,
          onClick: null,
        );
      }
    }
    if(selectedAroundPoint != null){
      if(selectedAroundPoint is Hotel){
        Hotel hotel = selectedAroundPoint as Hotel;
        String? cover = hotel.cover;
        if(cover != null){
          cover = getFullUrl(cover);
        }
        return PointBlock(
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
            Hotel? target;
            target = await HotelApi().detail(id: hotel.id, outerId: hotel.outerId, source: hotel.source, startDate: startDate, endDate: endDate);
            if(target == null){
              ToastUtil.error('目标不存在');
              return;
            }
            if(mounted && context.mounted){
              Navigator.of(context).push(MaterialPageRoute(builder: (context){
                return HotelHomePage(target!);
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
        return PointBlock(
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
        return PointBlock(
          name: restaurant.name,
          address: restaurant.address,
          score: restaurant.score,
          price: restaurant.averagePrice,
          mainImage: cover,
          onClick: () async{
            if(restaurant.id == null){
              return;
            }
            Restaurant? target = await RestaurantApi().getById(restaurant.id!);
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
      else if(selectedAroundPoint is SimpleHotel){
        SimpleHotel hotel = selectedAroundPoint as SimpleHotel;
        return PointBlock(
          name: hotel.name,
          address: hotel.address,
          score: hotel.score,
          price: hotel.price,
          mainImage: hotel.cover,
        );
      }
    }
    return const SizedBox();
  }

  Widget getRouteWidget(){
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: const BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.5),
        borderRadius: BorderRadius.all(Radius.circular(8))
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          Container(
            margin: const EdgeInsets.all(8),
            child: TextButton(
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap
              ),
              onPressed: (){
                if(targetPoi?.lat == null || targetPoi?.lng == null){
                  return;
                }
                AppRedirect.gotoGaodeMap(targetPoi!.lat!, targetPoi!.lng!);
              },
              child: Row(
                children: const [
                  Icon(Icons.arrow_forward),
                  SizedBox(width: 8,),
                  Text('地图导航')
                ],
              ),
            )
          )
        ],
      ),
    );
  }

  Future menuChooseHotel() async{
    setState(() {
      nearType = NearType.hotel;
      radioGroupController.setValue(0); // 确保在setState内部更新值
    });
    nearType = NearType.hotel;
    radioGroupController.setValue(0);
    setState(() {
    });
    drawMarker();
    if(targetPoi?.lat == null || targetPoi?.lng == null){
      targetPoi ??= MapPoiModel(); // 初始化对象
      targetPoi!.lat = userPos?.latitude ?? DEFAULT_POS.latitude;
      targetPoi!.lng = userPos?.longitude ?? DEFAULT_POS.longitude;
       //debugPrint('目标点经纬度为空，退出 menuChooseHotel()');
       //return;
    }  
    if(hotelList == null){
      List<Hotel>? tmpList = await LocalHotelApi().near(latitude: targetPoi!.lat!, longitude: targetPoi!.lng!, radius: searchRadius, pageSize: 20);
      if(tmpList == null || tmpList.length < 20){
        if(targetCity == null){
          GeoAddress? geoAddress = await HttpGaode.regeo(targetPoi!.lat!, targetPoi!.lng!);
          if(geoAddress == null){
            return;
          }
          targetCity = geoAddress.city;
        }
        List<Hotel>? panheList = await PanheHotelApi().near(city: targetCity!, latitude: targetPoi!.lat!, longitude: targetPoi!.lng!, radius: searchRadius, pageSize: 20);
        if(panheList != null){
          tmpList ??= [];
          tmpList.addAll(panheList);
        }
      }
      if(tmpList == null){
        return;
      }
      if(tmpList.isEmpty){
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
        debugPrint('当前目标点: ${targetPoi?.lat},${targetPoi?.lng}'); // ✅ 检查目标点经纬度
    if(targetPoi?.lat == null || targetPoi?.lng == null){
      return;
    }
    if(scenicList == null){
      List<Scenic>? tmpList = await LocalScenicApi().near(latitude: targetPoi!.lat!, longitude: targetPoi!.lng!, radius: searchRadius, pageSize: 50);
      if(tmpList == null || tmpList.length < 50){
        List<Scenic>? panheList = await ScenicApi().near(latitude: targetPoi!.lat!, longitude: targetPoi!.lng!, radius: searchRadius, pageSize: 50);
        if(panheList != null){
          tmpList ??= [];
          tmpList.addAll(panheList);
        }
      }
      if(tmpList == null || tmpList.isEmpty){
        ToastUtil.hint('附近没有景点');
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
            content:  UnconstrainedBox(
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
            onChoose: menuChooseHotel,
          ),
          RadioItemWidget(
            value: 2,
            content: UnconstrainedBox(
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
            onChoose: menuChooseScenic,
          ),
          RadioItemWidget(
            value: 1,
            content: UnconstrainedBox(
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
            onChoose: () async{
              nearType = NearType.restaurnt;
              radioGroupController.setValue(1);
              setState(() {
              });
              drawMarker();
              if(targetPoi?.lat == null || targetPoi?.lng == null){
                return;
              }
              if(restaurantList == null){
                List<Restaurant>? tmpList = await NearHttp().nearRestaurant(latitude: targetPoi!.lat!, longitude: targetPoi!.lng!, radius: searchRadius);
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
            },
          ),
        ],
      )
    );
  }

  Future onCameraMove(CameraPosition cameraMove) async{
    zoom = cameraMove.zoom;
    double scale = GaodeUtil.zoomToScale(zoom.floor()) * (zoom.floor() + 1 - zoom) + GaodeUtil.zoomToScale(zoom.floor() + 1) * (zoom - zoom.floor());
    double radius = scale * MediaQuery.of(context).size.width / 50;
    if(radius < 2000){
      return;
    }
    double ratio = radius / searchRadius;
    if(ratio > 1.2 || ratio < 0.8){
      searchRadius = radius;
      if(nearType == NearType.hotel){
        await menuChooseHotel();
        if(nearType == NearType.hotel){
          if(selectedAroundPoint is Hotel){
            Hotel selected = selectedAroundPoint as Hotel;
            hotelList!.insert(0, selected);
          }
          drawMarker();
        }
      }
      else if(nearType == NearType.scenic){
        await menuChooseScenic();
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
  
  Widget getMapWidget(){
    LatLng? initPos = DEFAULT_POS;
    AMapWidget mapWidget = AMapWidget(
      apiKey: const AMapApiKey(androidKey: ConstConfig.amapApiKeyOfAndroid, iosKey: ConstConfig.amapApiKeyOfIOS),
      onMapCreated: (controller){
        aMapController = controller;
        drawMarker();
      },
      onCameraMove: onCameraMove,
      initialCameraPosition: CameraPosition(target: initPos, zoom: DEFAULT_ZOOM),
      privacyStatement: const AMapPrivacyStatement(hasContains: true, hasShow: true, hasAgree: true),
      mapType: MapType.navi,
      zoomGesturesEnabled: true,
      buildingsEnabled: false,
      labelsEnabled: true,
      tiltGesturesEnabled: false,
      rotateGesturesEnabled: false,
      markers: markers,
      polylines: polylines,
    );
    return mapWidget;
  }

  Future drawMarker() async{
    Set<Marker> buffer = {};
    MarkerWrapper? userMarker = await getUserMarker();
    if(userMarker != null){
      buffer.add(userMarker.marker);
    }

    List<LatLngBounds> filledBounds = [];
    MarkerWrapper? centerMarker = await getCenterMarker();
    if(centerMarker != null){
      buffer.add(centerMarker.marker);
      if(centerMarker.size != null){
        filledBounds.add(GaodeUtil.getBoundsBySize(centerMarker.marker.position, centerMarker.size!, zoom));
      }
    }

    if(nearType != null){
      List<MarkerWrapper> nearPointMarkers = await getAroundPointMarkers();
      for(MarkerWrapper markerWrapper in nearPointMarkers){
        bool drawable = true;
        if(markerWrapper.size != null){
          LatLngBounds bounds = GaodeUtil.getBoundsBySize(markerWrapper.marker.position, markerWrapper.size!, zoom);
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
                  if(hotel.price != null && hotel.price! > 0)
                  Container(
                    width: 120,
                    height: 80,
                    alignment: Alignment.centerLeft,
                    child: Text('￥${StringUtil.getPriceStr(hotel.price) ?? 0}', style: const TextStyle(color: ThemeUtil.buttonColor, fontWeight: FontWeight.bold, fontSize: 32),),
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
            showTargetPoi = false;
            selectedAroundPoint = hotel;
            setState(() {
            });
            drawMarker();
          }
        );
        list.add(MarkerWrapper(marker, size: const Size(200, 80)));
      }
      for(SimpleHotel hotel in simpleHotelList ?? []){
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
                    svgPointAvailable
                  ),
                  Container(
                    width: 120,
                    height: 80,
                    alignment: Alignment.centerLeft,
                    child: Text('￥${hotel.score ?? '5'}', style: const TextStyle(color: ThemeUtil.buttonColor, fontWeight: FontWeight.bold, fontSize: 32),) ,
                  )
                ],
              ),
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
            showTargetPoi = false;
            selectedAroundPoint = hotel;
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
                  if(scenic.score != null && scenic.score! > 0)
                  Container(
                    width: 120,
                    height: 80,
                    alignment: Alignment.centerLeft,
                    child: 
                    Text('${StringUtil.getScoreString(scenic.score!)}"', style: const TextStyle(color: ThemeUtil.buttonColor, fontWeight: FontWeight.bold, fontSize: 32),) 
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
            showTargetPoi = false;
            selectedAroundPoint = scenic;
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
                    child: Text('${((restaurant.score ?? 100) / 10).toStringAsFixed(1)}分',
                      style: const TextStyle(color: ThemeUtil.buttonColor, fontWeight: FontWeight.bold, fontSize: 32),
                    ),
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
            showTargetPoi = false;
            selectedAroundPoint = restaurant;
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

  Future<MarkerWrapper?> getCenterMarker() async{
    if(targetPoi == null){
      return null;
    }
    ByteData? byteData = await GaodeUtil.widgetToByteData(
      SizedBox(
        width: CENTER_MARKER_SIZE,
        height: CENTER_MARKER_SIZE,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: showTargetPoi ?
          svgPointSelected :
          svgPointAvailable
        ),
      )
    );
    BitmapDescriptor icon = BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
    Marker marker = Marker(
      position: LatLng(targetPoi!.lat!, targetPoi!.lng!),
      icon: icon,
      infoWindowEnable: false,
      onTap: (str){
        showTargetPoi = true;
        selectedAroundPoint = null;
        setState(() {
        });
        drawMarker();
      }
    );
    return MarkerWrapper(marker, size: const Size(120, 120));
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
      clickable: false
    );
    return MarkerWrapper(marker, size: const Size(60, 60));
  }

  Future startLocation() async{
    debugPrint('开始定位...');
    /*if(! await LocalServiceUtil.checkGpsEnabled()){
      debugPrint('定位开始2');
      return;
    }*/
    bool isGpsEnabled = await LocalServiceNewUtil().requestService(
      context: context,
      info: '需要开启定位服务以获取您的位置信息'
    );
    if (!isGpsEnabled) {
      return;
    }
    /*if(! await PermissionUtil().checkPermission(Permission.location)){
      debugPrint('定位开始3');
      return;
    }*/
    bool isGranted = await PermissionUtil().requestPermission(
      context: context, 
      permission: Permission.location, 
      info: '希望获取当前位置用于获取您所在位置'
    );
    if(!isGranted){
      return;
    }
    locationUtil.onLocationChanged().listen((event) async {
      var latitude = event['latitude'];
      if(latitude is String){
        latitude = double.tryParse(latitude);
      }
      var longitude = event['longitude'];
      if(longitude is String){
        longitude = double.tryParse(longitude);
      }
      debugPrint('收到定位数据: lat=$latitude, lng=$longitude');
      if(latitude is double && longitude is double){
        bool moveCamera = userPos == null;
        userPos = LatLng(latitude, longitude);
        debugPrint('定位成功: ${userPos?.latitude},${userPos?.longitude}');
        if(moveCamera){
          aMapController?.moveCamera(CameraUpdate.newLatLng(userPos!));
        }
        setState(() {
        });
        drawMarker();
      }
    });
    locationUtil.startLocation();
  }

  void resetState(){
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }

}
