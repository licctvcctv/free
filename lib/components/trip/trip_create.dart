
import 'dart:io';

import 'package:amap_flutter_base/amap_flutter_base.dart' as amap_flutter_base;
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/facade/near_http.dart';
import 'package:freego_flutter/components/hotel_neo/api/local_hotel_api.dart';
import 'package:freego_flutter/components/hotel_neo/api/panhe_hotel_api.dart';
import 'package:freego_flutter/components/hotel_neo/hotel_common.dart';
import 'package:freego_flutter/components/restaurant/restaurant_common.dart';
import 'package:freego_flutter/components/scenic/api/local_scenic_api.dart';
import 'package:freego_flutter/components/scenic/api/scenic_api.dart';
import 'package:freego_flutter/components/scenic/scenic_common.dart';
import 'package:freego_flutter/components/trip/trip_common.dart';
import 'package:freego_flutter/components/trip/trip_http.dart';
import 'package:freego_flutter/components/trip/trip_show.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/common_locate.dart';
import 'package:freego_flutter/components/view/date_choose_view.dart';
import 'package:freego_flutter/components/view/image_viewer.dart';
import 'package:freego_flutter/components/view/radio_group.dart';
import 'package:freego_flutter/components/view/search_bar.dart';
import 'package:freego_flutter/config/const_config.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/http/http_gaode.dart';
import 'package:freego_flutter/model/map_poi.dart';
import 'package:freego_flutter/util/date_choose_util.dart';
import 'package:freego_flutter/util/date_time_util.dart';
import 'package:freego_flutter/util/file_upload_util.dart';
import 'package:freego_flutter/util/gaode_util.dart';
import 'package:freego_flutter/util/image_util.dart';
import 'package:freego_flutter/util/local_service_util.dart';
import 'package:freego_flutter/util/native_calendar_util.dart';
import 'package:freego_flutter/util/permission_util.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class TripCreatePage extends StatefulWidget{
  const TripCreatePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return TripCreatePageState();
  }

}

class TripCreatePageState extends State<TripCreatePage>{
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
        behavior: HitTestBehavior.translucent,
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: const TripCreateWidget(),
      ),
    );
  }

}

class TripCreateWidget extends StatefulWidget{
  const TripCreateWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return TripCreateState();
  }

}

class TripCreateState extends State<TripCreateWidget> with TickerProviderStateMixin{

  static const amap_flutter_base.LatLng DEFAULT_POS = amap_flutter_base.LatLng(39.909187, 116.397451);
  static const double DEFAULT_ZOOM = 12;

  AMapController? mapController;
  AMapFlutterLocation locationUtil = AMapFlutterLocation();
  amap_flutter_base.LatLng? userPos;
  Set<Marker> markers = {};

  RadioGroupController radioGroupController = RadioGroupController();

  bool showSearchResult = false;
  bool showSearchMarker = false;
  List<MapPoiModel> searchResult = [];
  String keyword = '';
  ScrollController scrollController = ScrollController();

  MapPoiModel? centerPoi;
  MapPoiModel? showPoi;

  Widget tripPointCenterSvg = SvgPicture.asset('svg/trip/trip_point_center.svg');
  Widget tripPointAroundSvg = SvgPicture.asset('svg/trip/trip_point_around.svg');
  List<Hotel> hotelList = [];
  List<Scenic> scenicList = [];
  List<Restaurant> restaurantList = [];
  Object? selectedAroundPoint;
  double zoom = DEFAULT_ZOOM;
  amap_flutter_base.LatLng? selectedPosition;
  String? targetCity;
  double searchRadius = 50 * 1000;
  NearType? nearType;

  int currentDay = 1;
  Trip trip = Trip();
  List<TripPoint>? points;
  TripPoint? showPoint;
  Set<Polyline> polylines = {};

  bool isNearMenuDisplayed = false;
  static const int NEAR_SLIDE_MILLI_SECONDS = 300;
  static const int NEAR_SLIDE_GAP_MILLI_SECONDS = 50;
  late AnimationController nearHotelSlideAnim;
  late AnimationController nearScenicSlideAnim;
  late AnimationController nearRestaurantSlideAnim;

  @override
  void initState(){
    super.initState();
    trip.totalNum = 1;
    nearHotelSlideAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: NEAR_SLIDE_MILLI_SECONDS));
    nearScenicSlideAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: NEAR_SLIDE_MILLI_SECONDS));
    nearRestaurantSlideAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: NEAR_SLIDE_MILLI_SECONDS));
  }

  @override
  void dispose(){
    scrollController.dispose();
    mapController?.disponse();
    locationUtil.destroy();
    nearHotelSlideAnim.dispose();
    nearScenicSlideAnim.dispose();
    nearRestaurantSlideAnim.dispose();
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
            hotelList.insert(0, selected);
          }
          drawMarker();
        }
      }
      else if(nearType == NearType.scenic){
        menuChooseScenic();
        if(nearType == NearType.scenic){
          if(selectedAroundPoint is Scenic){
            scenicList.insert(0, selectedAroundPoint as Scenic);
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
        startLocation();
      },
      onTap: (latlng){
        FocusScope.of(context).unfocus();
        hotelList = [];
        scenicList = [];
        restaurantList = [];
        radioGroupController.setValue(null);
        if(showSearchResult){
          showSearchResult = false;
          setState(() {
          });
        }
        else{
          Future.delayed(Duration.zero, () async{
            List<MapPoiModel>? poiList = await HttpGaode.getNearAddress(latlng.latitude, latlng.longitude, type: PoiType.all.getNum(), radius: 1000);
            if(poiList != null){
              showSearchMarker = true;
              searchResult = poiList;
              drawMarker();
            }
          });
        }
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

    return Container(
      color: ThemeUtil.backgroundColor,
      child: Column(
        children: [
          CommonHeader(
            center: SimpleSearchBar(
              hasButton: false,
              hintText: '请输入地点',
              onSumbit: (val) async{
                val = val.trim();
                if(val.isEmpty){
                  return;
                }
                keyword = val;
                List<MapPoiModel>? list = await HttpGaode.searchByKeyword(val, type: PoiType.all.getNum());
                if(list != null){
                  searchResult = list;
                  showSearchResult = true;
                  scrollController.jumpTo(0);
                  if(mounted && context.mounted){
                    setState(() {
                    });
                  }
                }
              },
            ),
          ),
          Expanded(
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
                  ]
                ),
                Positioned(
                  right: 0,
                  top: 40,
                  child: getNearMenuWidget(),
                ),
                Positioned(
                  left: 0,
                  top: 60,
                  child: Container(
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
                    ),
                  )
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      getBottomWidget(),
                      InkWell(
                        onTap: (){
                          showModalBottomSheet(
                            context: context,
                            barrierColor: Colors.transparent,
                            isDismissible: true,
                            isScrollControlled: true,
                            builder: (context) {
                              return RoutePlanWidget(trip: trip, points: points,);
                            },
                          );
                        },
                        child: Container(
                          width: 300,
                          height: 44,
                          margin: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: ThemeUtil.buttonColor,
                            borderRadius: BorderRadius.all(Radius.circular(8))
                          ),
                          alignment: Alignment.center,
                          child: const Text('行程定制', style: TextStyle(color: Colors.white,),),
                        ),
                      ),
                    ],
                  )
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Offstage(
                    offstage: !showSearchResult,
                    child: getSearchResultWidget(),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget getBottomWidget(){
    if(selectedAroundPoint != null){
      return AroundPointWidget(
        aroundPoint: selectedAroundPoint!, 
        onTapAdd: (obj){
          String? name;
          String? address;
          String? photoUrl;
          double? latitude;
          double? longitude;
          int? type;
          String? outerId;
          String? source;
          if(obj is Hotel){
            name = obj.name;
            address = obj.address;
            photoUrl = obj.cover;
            latitude = obj.latitude;
            longitude = obj.longitude;
            type = PoiType.hotel.getNum();
            outerId = obj.outerId;
            source = obj.source;
          }
          else if(obj is Scenic){
            name = obj.name;
            address = obj.address;
            photoUrl = obj.cover;
            latitude = obj.latitude;
            longitude = obj.longitude;
            type = PoiType.scenic.getNum();
            outerId = obj.outerId;
            source = obj.source;
          }
          else if(obj is Restaurant){
            name = obj.name;
            address = obj.address;
            photoUrl = obj.cover;
            latitude = obj.lat;
            longitude = obj.lng;
            type = PoiType.restaurant.getNum();
            outerId = null;
            source = null;
          }
          else{
            return;
          }
          int order = 1;
          for(TripPoint point in points ?? []){
            if(point.tripDay == currentDay && point.orderNum != null && point.orderNum! >= order){
              order = point.orderNum! + 1;
            }
          }
          points ??= [];
          TripPoint point = TripPoint();

          point.orderNum = order;
          point.name = name;
          point.address = address;
          point.image = photoUrl;
          point.latitude = latitude;
          point.longitude = longitude;
          point.type = type;
          point.tripDay = currentDay;
          point.outerId = outerId;
          point.source = source;
          points?.add(point);
          ToastUtil.hint('添加成功');

          showPoint = point;
          setState(() {
          });
          drawMarker();
        }
      );
    }
    else if(showPoi != null){
      return MapPoiWidget(
        showPoi!,
        onTapAdd: (poi){
          int order = 1;
          for(TripPoint point in points ?? []){
            if(point.tripDay == currentDay && point.orderNum != null && point.orderNum! >= order){
              order = point.orderNum! + 1;
            }
          }
          points ??= [];
          TripPoint point = TripPoint();
          point.mapPoi = poi;

          point.orderNum = order;
          point.name = poi.name;
          point.address = poi.address;
          point.image = poi.photoList == null || poi.photoList!.isEmpty ? null : poi.photoList!.first;
          point.latitude = poi.lat;
          point.longitude = poi.lng;
          point.type = poi.poiType?.getNum();
          point.tripDay = currentDay;
          points?.add(point);
          ToastUtil.hint('添加成功');

          showPoint = point;
          setState(() {
          });
          drawMarker();
        },
      );
    }
    else if(showPoint != null){
      return TripPointWidget(
        showPoint!,
        onTapDelete: (point){
          points?.remove(point);
          for(TripPoint other in points ?? []){
            if(other.tripDay == currentDay && other.orderNum != null && point.orderNum != null){
              if(other.orderNum! > point.orderNum!){
                other.orderNum = other.orderNum! - 1;
              }
            }
          }
          showPoint = null;
          ToastUtil.hint('移除成功');
          setState(() {
          });
          drawMarker();
        }
      );
    }
    return const SizedBox();
  }

  List<Widget> getDayWidgets(){
    List<Widget> widgets = [];
    for(int i = 1; i <= (trip.totalNum ?? 0); ++i){
      widgets.add(
        GestureDetector(
          onTap: (){
            currentDay = i;
            showPoint = null;
            setState(() {
            });
            drawMarker();
            drawLine();
          },
          onLongPress: (){
            if(i == 1 && trip.totalNum == 1){
              return;
            }
            showDialog(
              context: context, 
              builder: (context){
                return AlertDialog(
                  title: Text('确定删除第$i天？'),
                  actions: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeUtil.buttonColor
                      ),
                      onPressed: (){
                        Navigator.of(context).pop();
                      }, 
                      child: const Text('取消')
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeUtil.buttonColor
                      ),
                      onPressed: (){
                        for(TripPoint point in points ?? []){
                          if(point.tripDay == i){
                            points?.remove(point);
                          }
                        }
                        for(TripPoint point in points ?? []){
                          if(point.tripDay != null){
                            if(point.tripDay! > i){
                              point.tripDay = point.tripDay! - 1;
                            }
                          }
                        }
                        if(trip.totalNum != null){
                          trip.totalNum = trip.totalNum! - 1;
                        }
                        setState(() {
                        });
                        Navigator.of(context).pop();
                      }, 
                      child: const Text('确定')
                    )
                  ],
                );
              }
            );
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
    widgets.add(
      InkWell(
        onTap: (){
          trip.totalNum = (trip.totalNum ?? 0) + 1;
          setState(() {
          });
        },
        child: Container(
          width: 80,
          height: 36,
          color: const Color.fromRGBO(255, 255, 255, 0.8),
          alignment: Alignment.center,
          child: const Text('+', style: TextStyle(color: ThemeUtil.buttonColor, fontSize: 32, fontWeight: FontWeight.bold),),
        ),
      )
    );
    return widgets;
  }

  Widget getSearchResultWidget(){
    Map<String, HighlightedWord> map = {};
    if(keyword.isNotEmpty){
      map = {
        keyword: HighlightedWord(
          textStyle: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          )
        ),
      };
    }
    List<Widget> widgets = [];
    for(MapPoiModel poi in searchResult){
      widgets.add(
        TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap
          ),
          onPressed: (){
            showPoint = null;
            showPoi = centerPoi = poi;
            showSearchResult = false;
            if(context.mounted){
              setState(() {
              });
              drawMarker();
            }
            if(poi.lat != null && poi.lng != null){
              mapController?.moveCamera(CameraUpdate.newLatLng(amap_flutter_base.LatLng(poi.lat!, poi.lng!)));
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black12))
            ),
            child: Row(
              children: [
                Image.asset('assets/trip/trip_location.png', fit: BoxFit.cover, width: 32, height: 32,),
                const SizedBox(width: 10,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TextHighlight(text: poi.name ?? '', words: map, textStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
                          ),
                          poi.score == null ?
                          const SizedBox():
                          Container(
                            decoration: const BoxDecoration(
                              color: Color.fromRGBO(255, 82, 82, 1),
                              borderRadius: BorderRadius.all(Radius.circular(2))
                            ),
                            padding: const EdgeInsets.all(2),
                            child: Text(poi.score ?? '', style: const TextStyle(color: Colors.white),),
                          )
                        ],
                      ),
                      const SizedBox(height: 8,),
                      Text(poi.address ?? '', style: const TextStyle(color: Colors.grey),)
                    ],
                  ),
                )
              ],
            ),
          )
        )
      );
    }
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.fromLTRB(CommonHeader.PADDING_LEFT + CommonHeader.DEFAULT_LEFT_WIDTH, 0, CommonHeader.PADDING_RIGHT + CommonHeader.DEFAULT_RIGHT_WIDTH, 0),
      child: SingleChildScrollView(
        controller: scrollController,
        physics: const ClampingScrollPhysics(),
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
              )
            ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widgets,
          ),
        ),
      )
    );
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
        for(Hotel localHotel in hotelList){
          if(hotel.likeTheSame(localHotel)){
            theSame = true;
            break;
          }
        }
        if(!theSame){
          hotelList.add(hotel);
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
        for(Scenic localScenic in scenicList){
          if(scenic.likeTheSame(localScenic)){
            theSame = true;
            break;
          }
        }
        if(!theSame){
          scenicList.add(scenic);
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
                  padding: radioGroupController.value == 0 ? const EdgeInsets.fromLTRB(18, 10, 18, 10) : const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: radioGroupController.value == 0 ? const Color.fromRGBO(0xaa, 0xe1, 0xea, 1) : Colors.white,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                  ),
                  child: Text('周边酒店', style: TextStyle(color: radioGroupController.value == 0 ? Colors.white : ThemeUtil.foregroundColor),),
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
                  padding: radioGroupController.value == 2 ? const EdgeInsets.fromLTRB(18, 10, 18, 10) : const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: radioGroupController.value == 2 ? const Color.fromRGBO(0xaa, 0xe1, 0xea, 1) : Colors.white,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                  ),
                  child: Text('周边景点', style: TextStyle(color: radioGroupController.value == 2 ? Colors.white : ThemeUtil.foregroundColor),),
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
                  padding: radioGroupController.value == 1 ? const EdgeInsets.fromLTRB(18, 10, 18, 10) : const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: radioGroupController.value == 1 ? const Color.fromRGBO(0xaa, 0xe1, 0xea, 1) : Colors.white,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                  ),
                  child: Text('周边美食', style: TextStyle(color: radioGroupController.value == 1 ? Colors.white : ThemeUtil.foregroundColor),)
                ),
              ),
            ),
            onChoose: menuChooseRestaurant,
          ),
        ],
      )
    );
  }

  void drawLine(){
    polylines = {};
    List<TripPoint> points = [];
    for(TripPoint point in this.points ?? []){
      if(point.tripDay == currentDay && point.orderNum != null && point.latitude != null && point.longitude != null){
        points.add(point);
      }
    }
    points.sort((a, b){
      return (a.orderNum ?? 0) - (b.orderNum ?? 0);
    });
    List<amap_flutter_base.LatLng> posList = [];
    for(TripPoint point in points){
      posList.add(amap_flutter_base.LatLng(point.latitude!, point.longitude!));
    }
    if(posList.isNotEmpty){
      Polyline polyline = Polyline(
        width: 20,
        customTexture: BitmapDescriptor.fromIconPath('assets/texture_green.png'),
        joinType: JoinType.round,
        points: posList
      );
      polylines.add(polyline);
    }
    if(context.mounted){
      setState(() {
      });
    }
  }

  Future drawMarker() async{
    drawLine();
    List<Marker> buffer = [];
    List<amap_flutter_base.LatLngBounds> filledBounds = [];
    MarkerWrapper? userMarker = await getUserMarker();
    if(userMarker != null){
      buffer.add(userMarker.marker);
    }
    List<MarkerWrapper> tripMarkers = await getTripPointMarkers();
    for(MarkerWrapper markerWrapper in tripMarkers){
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
    MarkerWrapper? centerMarker = await getCenterMarker();
    if(centerMarker != null){
      bool drawable = true;
      if(centerMarker.size != null){
        amap_flutter_base.LatLngBounds bounds = GaodeUtil.getBoundsBySize(centerMarker.marker.position, centerMarker.size!, zoom);
        if(filledBounds.checkContact(bounds)){
          drawable = false;
        }
        else{
          filledBounds.add(bounds);
        }
      }
      if(drawable){
        buffer.add(centerMarker.marker);
      }
    }
    if(showSearchMarker){
      List<MarkerWrapper> resultMarkers = await getResultMarkers();
      for(MarkerWrapper markerWrapper in resultMarkers){
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
    List<MarkerWrapper> aroundMarkers = await getAroundMarkers();
    for(MarkerWrapper markerWrapper in aroundMarkers){
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
    markers = {};
    for(Marker marker in buffer.reversed){
      markers.add(marker);
    }
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }

  Future<List<MarkerWrapper>> getTripPointMarkers() async{
    List<MarkerWrapper> list = [];
    List<TripPoint> points = [];
    for(TripPoint point in this.points ?? []){
      if(point.tripDay == currentDay && point.orderNum != null){
        points.add(point);
      }
    }
    points.sort((a, b){
      if(a.orderNum! <= b.orderNum!){
        return -1;
      }
      return 1;
    });
    for(TripPoint point in points){
      if(point.latitude == null || point.longitude == null || point.orderNum == null){
        continue;
      }
      ByteData? byteData = await GaodeUtil.widgetToByteData(
        SizedBox(
          width: 100,
          height: 100,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: 
                  selectedAroundPoint == null ?
                  tripPointCenterSvg :
                  tripPointAroundSvg
                ),
                Positioned(
                  top: 20,
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(30))
                    ),
                    child: Text('${point.orderNum}', style: const TextStyle(color: ThemeUtil.buttonColor, fontSize: 32),)
                  ),
                ),
              ],
            )
          ),
        )
      );
      BitmapDescriptor icon = BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
      Marker marker = Marker(
        position: amap_flutter_base.LatLng(point.latitude!, point.longitude!),
        icon: icon,
        infoWindowEnable: false,
        onTap: (id){
          showPoint = point;
          showPoi = null;
          selectedAroundPoint = null;
          selectedPosition = amap_flutter_base.LatLng(point.latitude!, point.longitude!);
          setState(() {
          });
        }
      );
      list.add(MarkerWrapper(marker, size: const Size(100, 100)));
    }
    return list;
  }

  Future<List<MarkerWrapper>> getResultMarkers() async{
    List<MarkerWrapper> list = [];
    for(MapPoiModel poi in searchResult){
      if(poi.lat == null || poi.lng == null){
        continue;
      }
      ByteData? byteData = await GaodeUtil.widgetToByteData(
        SizedBox(
          width: 80,
          height: 80,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: tripPointAroundSvg,
          ),
        )
      );
      BitmapDescriptor icon = BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
      Marker marker = Marker(
        position: amap_flutter_base.LatLng(poi.lat!, poi.lng!),
        icon: icon,
        infoWindowEnable: false,
        onTap: (id){
          showPoint = null;
          centerPoi = showPoi = poi;
          selectedAroundPoint = null;
          selectedPosition = amap_flutter_base.LatLng(poi.lat!, poi.lng!);
          showNearMenu();
          setState((){
          });
          drawMarker();
        }
      );
      list.add(MarkerWrapper(marker, size: const Size(80, 80)));
    }
    return list;
  }

  Future<List<MarkerWrapper>> getAroundMarkers() async{
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
                    tripPointCenterSvg :
                    tripPointAroundSvg,
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
          position: amap_flutter_base.LatLng(hotel.latitude!, hotel.longitude!),
          icon: icon,
          anchor: const Offset(0.2, 1),
          infoWindowEnable: false,
          onTap: (id){
            selectedAroundPoint = hotel;
            selectedPosition = amap_flutter_base.LatLng(hotel.latitude!, hotel.longitude!);
            showNearMenu();
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
                    tripPointCenterSvg :
                    tripPointAroundSvg,
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
          position: amap_flutter_base.LatLng(scenic.latitude!, scenic.longitude!),
          icon: icon,
          anchor: const Offset(0.2, 1),
          infoWindowEnable: false,
          onTap: (id){
            selectedAroundPoint = scenic;
            selectedPosition = amap_flutter_base.LatLng(scenic.latitude!, scenic.longitude!);
            showNearMenu();
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
                    tripPointCenterSvg :
                    tripPointAroundSvg,
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
          position: amap_flutter_base.LatLng(restaurant.lat!, restaurant.lng!),
          icon: icon,
          anchor: const Offset(0.2, 1),
          infoWindowEnable: false,
          onTap: (id){
            selectedAroundPoint = restaurant;
            selectedPosition = amap_flutter_base.LatLng(restaurant.lat!, restaurant.lng!);
            showNearMenu();
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
    if(centerPoi == null){
      return null;
    }
    if(centerPoi!.lat == null || centerPoi!.lng == null){
      return null;
    }
    ByteData? byteData = await GaodeUtil.widgetToByteData(
      SizedBox(
        width: 100,
        height: 100,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: tripPointCenterSvg,
        ),
      )
    );
    BitmapDescriptor icon = BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
    Marker marker = Marker(
      position: amap_flutter_base.LatLng(centerPoi!.lat!, centerPoi!.lng!),
      icon: icon,
      infoWindowEnable: false,
      onTap: (id){
        showPoint = null;
        showPoi = centerPoi;
        selectedAroundPoint = null;
        selectedPosition = amap_flutter_base.LatLng(centerPoi!.lat!, centerPoi!.lng!);
        setState(() {
        });
      }
    );
    return MarkerWrapper(marker, size: const Size(100, 100));
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
        bool moveCamera = mapController != null && userPos == null;
        userPos = amap_flutter_base.LatLng(latitude, longitude);
        if(moveCamera){
          mapController!.moveCamera(CameraUpdate.newLatLng(userPos!));
        }
        drawMarker();
      } 
    });
    locationUtil.startLocation();
  }
}

class RoutePlanWidget extends StatefulWidget{
  final Trip trip;
  final List<TripPoint>? points;
  const RoutePlanWidget({required this.trip, this.points, super.key});

  @override
  State<StatefulWidget> createState() {
    return RoutePlanState();
  }

}

class RoutePlanState extends State<RoutePlanWidget>{

  static const double CHOOSED_ITEM_WIDTH = 64;
  static const double CHOOSED_ITEM_HEIGHT = 28;

  static const double COVER_HEIGHT = 200;

  static const double POI_HEIGHT = 80;
  static const double POI_WIDTH = 100;

  TextEditingController startTextController = TextEditingController();
  FocusNode startFocus = FocusNode();
  String startKeyword = '';
  bool showStartSearchResult = false;
  bool startPoiChecked = false;
  List<MapPoiModel> startSearchResult = [];
  ScrollController startScrollController = ScrollController();
  TextEditingController endTextController = TextEditingController();
  FocusNode endFocus = FocusNode();
  String endKeyword = '';
  bool showEndSearchResult = false;
  bool endPoiChecked = false;
  List<MapPoiModel> endSearchResult = [];
  ScrollController endScrollController = ScrollController();

  Widget svgTripPointDelete = SvgPicture.asset('svg/trip/trip_point_delete.svg');

  @override
  void initState(){
    super.initState();
    Trip trip = widget.trip;
    startTextController.text = trip.startAddress ?? '';
    endTextController.text = trip.endAddress ?? '';
    checkStartPoi();
    checkEndPoi();
  }

  @override
  void dispose(){
    startFocus.dispose();
    endFocus.dispose();
    startTextController.dispose();
    endTextController.dispose();
    startScrollController.dispose();
    endScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Trip trip = widget.trip;
    List<TripPoint>? points = widget.points;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Material(
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
            height: MediaQuery.of(context).size.height * 0.7,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Stack(
                children: [
                  Listener(
                    behavior: HitTestBehavior.translucent,
                    onPointerDown: (e){
                      FocusScope.of(context).unfocus();
                      showEndSearchResult = showStartSearchResult = false;
                      setState(() {
                      });
                      checkStartPoi();
                      checkEndPoi();
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('封面', style: TextStyle(color: Colors.grey),),
                        const SizedBox(height: 10,),
                        trip.cover == null ?
                        InkWell(
                          onTap: () async{
                            bool isGranted = await PermissionUtil().requestPermission(context: context, permission: Permission.storage, info: '希望获取存储权限用于从相册中选择图片');
                            if(!isGranted){
                              ToastUtil.error('获取存储权限失败');
                              return;
                            }
                            if(mounted && context.mounted){

                              AssetPickerConfig config = ImageUtil.buildDefaultImagePickerConfig();
                              final List<AssetEntity>? results = await AssetPicker.pickAssets(
                                context,
                                pickerConfig: config,
                              );
                              if(results == null || results.isEmpty){
                                return;
                              }
                              AssetEntity entity = results[0];
                              File? file = await entity.file;
                              if(file == null){
                                ToastUtil.error('获取路径失败');
                                return;
                              }
                              CroppedFile? croppedFile = await ImageCropper().cropImage(
                                sourcePath: file.path,
                                aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
                                aspectRatioPresets: [
                                  CropAspectRatioPreset.ratio16x9,
                                ],
                                uiSettings: [
                                  AndroidUiSettings(
                                    toolbarTitle: '行程封面',
                                    toolbarColor: ThemeUtil.buttonColor,
                                    toolbarWidgetColor: Colors.white,
                                    initAspectRatio: CropAspectRatioPreset.original,
                                    lockAspectRatio: true
                                  ),
                                  IOSUiSettings(
                                    title: '行程封面',
                                    aspectRatioLockEnabled: true,
                                    aspectRatioPickerButtonHidden: true,
                                    resetButtonHidden: true,
                                    cancelButtonTitle: '取消',
                                    doneButtonTitle: '确定'
                                  ),
                                ],
                              );
                              if(croppedFile == null){
                                return;
                              }
                              String path = croppedFile.path;
                              //String name = path.substring(path.lastIndexOf('/') + 1, path.length);
                              String? url = await FileUploadUtil().upload(path: path);
                              if(url == null){
                                ToastUtil.error('文件上传失败');
                                return;
                              }
                              trip.cover = url;
                              if(context.mounted){
                                setState(() {
                                });
                              }
                            }
                          },
                          child: Container(
                            height: COVER_HEIGHT,
                            decoration: const BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.all(Radius.circular(10))
                            ),
                            alignment: Alignment.center,
                            child: const Text('+', style: TextStyle(fontSize: 52, color: Colors.white),),
                          ),
                        ) :
                        Container(
                          height: COVER_HEIGHT,
                          clipBehavior: Clip.hardEdge,
                          decoration: const BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.all(Radius.circular(10))
                          ),
                          alignment: Alignment.center,
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: SizedBox(
                                  height: COVER_HEIGHT,
                                  child: Image.network(
                                    getFullUrl(trip.cover!), 
                                    fit: BoxFit.contain,
                                    errorBuilder:(context, error, stackTrace) {
                                      return Container(
                                        color: ThemeUtil.backgroundColor,
                                        alignment: Alignment.center,
                                        child: const Icon(Icons.error_outline, color: ThemeUtil.foregroundColor)
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: ClipOval(
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    color: const Color.fromRGBO(255, 255, 255, 0.6),
                                    alignment: Alignment.center,
                                    child: InkWell(
                                      onTap: (){
                                        trip.cover = null;
                                        setState(() {
                                        });
                                      },
                                      child: const Text('X', style: TextStyle(fontSize: 20, color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold),),
                                    ),
                                  ),
                                )
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10,),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: (){
                            FocusScope.of(context).requestFocus(startFocus);
                            checkEndPoi();
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                            height: 60,
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('起点', style: TextStyle(color: Colors.grey),),
                                const SizedBox(width: 8,),
                                Expanded(
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '',
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero
                                    ),
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: startPoiChecked ? ThemeUtil.foregroundColor : Colors.redAccent),
                                    textAlign: TextAlign.end,
                                    textInputAction: TextInputAction.search,
                                    focusNode: startFocus,
                                    controller: startTextController,
                                    onChanged: (val){
                                      checkStartPoi();
                                    },
                                    onSubmitted: (val) async{
                                      val = val.trim();
                                      if(val.isEmpty){
                                        return;
                                      }
                                      startKeyword = val;
                                      List<MapPoiModel>? list = await HttpGaode.searchByKeyword(val, type: PoiType.all.getNum());
                                      if(list != null){
                                        startSearchResult = list;
                                        showStartSearchResult = true;
                                        setState(() {
                                        });
                                        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                                          startScrollController.jumpTo(0);
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            )
                          ),
                        ),
                        const SizedBox(height: 10,),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: (){
                            FocusScope.of(context).requestFocus(endFocus);
                            checkStartPoi();
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                            height: 60,
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('终点', style: TextStyle(color: Colors.grey),),
                                const SizedBox(width: 8,),
                                Expanded(
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '',
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero
                                    ),
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: endPoiChecked ? ThemeUtil.foregroundColor : Colors.redAccent),
                                    textAlign: TextAlign.end,
                                    textInputAction: TextInputAction.search,
                                    focusNode: endFocus,
                                    controller: endTextController,
                                    onChanged: (val){
                                      checkEndPoi();
                                    },
                                    onSubmitted: (val) async{
                                      val = val.trim();
                                      if(val.isEmpty){
                                        return;
                                      }
                                      endKeyword = val;
                                      List<MapPoiModel>? list = await HttpGaode.searchByKeyword(val, type: PoiType.all.getNum());
                                      if(list != null){
                                        endSearchResult = list;
                                        showEndSearchResult = true;
                                        setState(() {
                                        });
                                        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                                          endScrollController.jumpTo(0);
                                        });
                                      }
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10,),
                        const Text('已添加途径点', style: TextStyle(color: Colors.grey),),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: getPoiWidgets(),
                        ),
                        const SizedBox(height: 16,),
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('出发时间', style: TextStyle(color: Colors.grey),),
                              Expanded(
                                child: InkWell(
                                  onTap: () async{
                                    DateTime today = DateTime.now();
                                    today = DateTime(today.year, today.month, today.day);
                                    DateChooseConfig config = DateChooseConfig(
                                      chooseMode: DateChooseMode.single,
                                      width: MediaQuery.of(context).size.width,
                                      height: MediaQuery.of(context).size.width,
                                      firstDate: today,
                                      lastDate: trip.endDate,
                                    );
                                    List<DateTime>? result = await DateChooseUtil.chooseDate(context, config);
                                    if(result != null && result.isNotEmpty){
                                      trip.startDate = result.first;
                                      if(mounted && context.mounted){
                                        setState(() {
                                        });
                                      }
                                    }
                                  },
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: trip.startDate == null ?
                                    const Text('请选择', style: TextStyle(color: Colors.grey),) :
                                    Text(DateTimeUtil.toYMD(trip.startDate!), style: const TextStyle(color: Colors.black, decoration: TextDecoration.underline),),
                                  )
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 10,),
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('结束时间', style: TextStyle(color: Colors.grey),),
                              Expanded(
                                child: InkWell(
                                  onTap: () async{
                                    DateTime today = DateTime.now();
                                    today = DateTime(today.year, today.month, today.day);
                                    DateChooseConfig config = DateChooseConfig(
                                      chooseMode: DateChooseMode.single,
                                      width: MediaQuery.of(context).size.width,
                                      height: MediaQuery.of(context).size.width,
                                      firstDate: trip.startDate ?? today,
                                    );
                                    List<DateTime>? result = await DateChooseUtil.chooseDate(context, config);
                                    if(result != null && result.isNotEmpty){
                                      trip.endDate = result.first;
                                      if(mounted && context.mounted){
                                        setState(() {
                                        });
                                      }
                                    }
                                  },
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: trip.endDate == null ?
                                    const Text('请选择', style: TextStyle(color: Colors.grey),) :
                                    Text(DateTimeUtil.toYMD(trip.endDate!), style: const TextStyle(color: Colors.black, decoration: TextDecoration.underline),),
                                  )
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 10,),
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('出行方式', style: TextStyle(color: Colors.grey),),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: (){
                                      trip.travelMode = TravelMode.selfDrive.getNum();
                                      setState(() {
                                      });
                                    },
                                    child: Container(
                                      width: CHOOSED_ITEM_WIDTH,
                                      height: CHOOSED_ITEM_HEIGHT,
                                      decoration: BoxDecoration(
                                        color: trip.travelMode == TravelMode.selfDrive.getNum() ? ThemeUtil.buttonColor : Colors.black12,
                                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text('自驾', style: TextStyle(color: trip.travelMode == TravelMode.selfDrive.getNum() ? Colors.white : ThemeUtil.foregroundColor),),
                                    ),
                                  ),
                                  const SizedBox(width: 12,),
                                  InkWell(
                                    onTap: (){
                                      trip.travelMode = TravelMode.nonSelfDrive.getNum();
                                      setState(() {
                                      });
                                    },
                                    child: Container(
                                      width: CHOOSED_ITEM_WIDTH,
                                      height: CHOOSED_ITEM_HEIGHT,
                                      decoration: BoxDecoration(
                                        color: trip.travelMode == TravelMode.nonSelfDrive.getNum() ? ThemeUtil.buttonColor : Colors.black12,
                                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text('非自驾', style: TextStyle(color: trip.travelMode == TravelMode.nonSelfDrive.getNum() ? Colors.white : ThemeUtil.foregroundColor),),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 10,),
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('住宿标准', style: TextStyle(color: Colors.grey),),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: (){
                                          trip.accommodateType = AccommodateType.economic.getNum();
                                          setState(() {
                                          });
                                        },
                                        child: Container(
                                          width: CHOOSED_ITEM_WIDTH,
                                          height: CHOOSED_ITEM_HEIGHT,
                                          decoration: BoxDecoration(
                                            color: trip.accommodateType == AccommodateType.economic.getNum() ? ThemeUtil.buttonColor : Colors.black12,
                                            borderRadius: const BorderRadius.all(Radius.circular(4)),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text('经济', style: TextStyle(color: trip.accommodateType == AccommodateType.economic.getNum() ? Colors.white : ThemeUtil.foregroundColor),),
                                        ),
                                      ),
                                      const SizedBox(width: 12,),
                                      InkWell(
                                        onTap: (){
                                          trip.accommodateType = AccommodateType.confortable.getNum();
                                          setState(() {
                                          });
                                        },
                                        child: Container(
                                          width: CHOOSED_ITEM_WIDTH,
                                          height: CHOOSED_ITEM_HEIGHT,
                                          decoration: BoxDecoration(
                                            color: trip.accommodateType == AccommodateType.confortable.getNum() ? ThemeUtil.buttonColor : Colors.black12,
                                            borderRadius: const BorderRadius.all(Radius.circular(4)),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text('舒适', style: TextStyle(color: trip.accommodateType == AccommodateType.confortable.getNum() ? Colors.white : ThemeUtil.foregroundColor),),
                                        ),
                                      ),
                                      const SizedBox(width: 12,),
                                      InkWell(
                                        onTap: (){
                                          trip.accommodateType = AccommodateType.luxury.getNum();
                                          setState(() {
                                          });
                                        },
                                        child: Container(
                                          width: CHOOSED_ITEM_WIDTH,
                                          height: CHOOSED_ITEM_HEIGHT,
                                          decoration: BoxDecoration(
                                            color: trip.accommodateType == AccommodateType.luxury.getNum() ? ThemeUtil.buttonColor : Colors.black12,
                                            borderRadius: const BorderRadius.all(Radius.circular(4)),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text('豪华', style: TextStyle(color: trip.accommodateType == AccommodateType.luxury.getNum() ? Colors.white : ThemeUtil.foregroundColor),),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('旅行强度', style: TextStyle(color: Colors.grey),),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: (){
                                          trip.intensityType = IntensityType.tight.getNum();
                                          setState(() {
                                          });
                                        },
                                        child: Container(
                                          width: CHOOSED_ITEM_WIDTH,
                                          height: CHOOSED_ITEM_HEIGHT,
                                          decoration: BoxDecoration(
                                            color: trip.intensityType == IntensityType.tight.getNum() ? ThemeUtil.buttonColor : Colors.black12,
                                            borderRadius: const BorderRadius.all(Radius.circular(4)),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text('紧凑', style: TextStyle(color: trip.intensityType == IntensityType.tight.getNum() ? Colors.white : ThemeUtil.foregroundColor),),
                                        ),
                                      ),
                                      const SizedBox(width: 12,),
                                      InkWell(
                                        onTap: (){
                                          trip.intensityType = IntensityType.normal.getNum();
                                          setState(() {
                                          });
                                        },
                                        child: Container(
                                          width: CHOOSED_ITEM_WIDTH,
                                          height: CHOOSED_ITEM_HEIGHT,
                                          decoration: BoxDecoration(
                                            color: trip.intensityType == IntensityType.normal.getNum() ? ThemeUtil.buttonColor : Colors.black12,
                                            borderRadius: const BorderRadius.all(Radius.circular(4)),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text('标准', style: TextStyle(color: trip.intensityType == IntensityType.normal.getNum() ? Colors.white : ThemeUtil.foregroundColor),),
                                        ),
                                      ),
                                      const SizedBox(width: 12,),
                                      InkWell(
                                        onTap: (){
                                          trip.intensityType = IntensityType.casual.getNum();
                                          setState(() {
                                          });
                                        },
                                        child: Container(
                                          width: CHOOSED_ITEM_WIDTH,
                                          height: CHOOSED_ITEM_HEIGHT,
                                          decoration: BoxDecoration(
                                            color: trip.intensityType == IntensityType.casual.getNum() ? ThemeUtil.buttonColor : Colors.black12,
                                            borderRadius: const BorderRadius.all(Radius.circular(4)),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text('休闲', style: TextStyle(color: trip.intensityType == IntensityType.casual.getNum() ? Colors.white : ThemeUtil.foregroundColor),),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              )
                            ],
                          )
                        ),
                        const SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () async{
                                if(!startPoiChecked){
                                  ToastUtil.error('请填写出发地点');
                                  return;
                                }
                                if(!endPoiChecked){
                                  ToastUtil.error('请填写结束地点');
                                  return;
                                }
                                if(trip.startDate == null){
                                  ToastUtil.error('请填写出发日期');
                                  return;
                                }
                                if(trip.endDate == null){
                                  ToastUtil.error('请填写结束日期');
                                  return;
                                }
                                if(trip.travelMode == null){
                                  ToastUtil.error('请填写出行方式');
                                  return;
                                }
                                if(trip.accommodateType == null){
                                  ToastUtil.error('请填写住宿类型');
                                  return;
                                }
                                if(trip.intensityType == null){
                                  ToastUtil.error('请填写旅行强度');
                                  return;
                                }
                                if(points == null || points.isEmpty){
                                  ToastUtil.error('请填写途径点');
                                  return;
                                }
                                bool result = await TripHttp.createTrip(trip: trip, points: points, fail: (response){
                                  String? message = response.data['message'];
                                  ToastUtil.error(message ?? '创建失败');
                                });
                                if(result){
                                  ToastUtil.hint('创建成功');
                                  if(mounted && context.mounted){
                                    await showGeneralDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      barrierLabel: '',
                                      barrierColor: Colors.transparent,
                                      pageBuilder: (context, animation, secondaryAnimation){
                                        return Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Material(
                                              color: Colors.transparent,
                                              child: CalendarInsertWidget(trip: trip, pointList: points,),
                                            )
                                          ],
                                        );
                                      }
                                    );
                                  }
                                  Future.delayed(const Duration(seconds: 3), (){
                                    if(context.mounted){
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop(true);
                                    }
                                  });
                                }
                                else{
                                  ToastUtil.error('保存失败');
                                }
                              },
                              child: Container(
                                width: 300,
                                height: 44,
                                margin: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: ThemeUtil.buttonColor,
                                  borderRadius: BorderRadius.all(Radius.circular(8))
                                ),
                                alignment: Alignment.center,
                                child: const Text('保存', style: TextStyle(color: Colors.white,),),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  Offstage(
                    offstage: !showStartSearchResult,
                    child: Container(
                      margin: const EdgeInsets.only(top: COVER_HEIGHT + 100),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(2)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black38,
                              blurRadius: 4,
                            )
                          ]
                        ),
                        constraints: const BoxConstraints(
                          maxHeight: 160
                        ),
                        child: SingleChildScrollView(
                          controller: startScrollController,
                          physics: const ClampingScrollPhysics(),
                          child: Column(
                            children: getStartMapPoiOptions(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Offstage(
                    offstage: !showEndSearchResult,
                    child: Container(
                      margin: const EdgeInsets.only(top: COVER_HEIGHT + 170),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(2)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black38,
                              blurRadius: 4
                            )
                          ]
                        ),
                        constraints: const BoxConstraints(
                          maxHeight: 160
                        ),
                        child: SingleChildScrollView(
                          controller: endScrollController,
                          physics: const ClampingScrollPhysics(),
                          child: Column(
                            children: getEndMapPoiOptions(),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  List<Widget> getEndMapPoiOptions(){
    Map<String, HighlightedWord> map = {
      endKeyword: HighlightedWord(
        textStyle: const TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        )
      ),
    };
    List<Widget> widgets = [];
    if(endSearchResult.isEmpty){
      widgets.add(
        InkWell(
          onTap: () async{
            Object? result = await Navigator.of(context).push(MaterialPageRoute(builder: (context){
              return const CommonLocatePage();
            }));
            if(result is MapPoiModel){
              Trip trip = widget.trip;
              trip.endAddress = result.name;
              trip.endLatitude = result.lat;
              trip.endLongitude = result.lng;
              endTextController.text = result.name ?? '';
              showEndSearchResult = false;
              endPoiChecked = true;
              if(mounted && context.mounted){
                setState(() {
                });
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Row(
              children: const [
                SizedBox(width: 12),
                Icon(Icons.search, color: Colors.lightBlue,),
                SizedBox(width: 12),
                Text('手动搜索', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold))
              ],
            ),
          ),
        )
      );
    }
    for(MapPoiModel poi in endSearchResult){
      widgets.add(
        InkWell(
          onTap: (){
            Trip trip = widget.trip;
            trip.endAddress = poi.name;
            trip.endLatitude = poi.lat;
            trip.endLongitude = poi.lng;
            endTextController.text = poi.name ?? '';
            showEndSearchResult = false;
            endPoiChecked = true;
            setState(() {
            });
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.black12))
            ),
            child: Row(
              children: [
                Image.asset('assets/trip/trip_location.png', fit: BoxFit.cover, width: 32, height: 32,),
                const SizedBox(width: 10,),
                Expanded(
                  child: TextHighlight(text: poi.name ?? '', words: map, textStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
                )
              ],
            ),
          ),
        )
      );
    }
    return widgets;
  }

  List<Widget> getStartMapPoiOptions(){
    Map<String, HighlightedWord> map = {
      startKeyword: HighlightedWord(
        textStyle: const TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        )
      ),
    };
    List<Widget> widgets = [];
    if(startSearchResult.isEmpty){
      widgets.add(
        InkWell(
          onTap: () async{
            Object? result = await Navigator.of(context).push(MaterialPageRoute(builder: (context){
              return const CommonLocatePage();
            }));
            if(result is MapPoiModel){
              Trip trip = widget.trip;
              trip.startAddress = result.name;
              trip.startLatitude = result.lat;
              trip.startLongitude = result.lng;
              startTextController.text = result.name ?? '';
              showStartSearchResult = false;
              startPoiChecked = true;
              if(mounted && context.mounted){
                setState(() {
                });
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Row(
              children: const [
                SizedBox(width: 12),
                Icon(Icons.search, color: Colors.lightBlue,),
                SizedBox(width: 12),
                Text('手动搜索', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold))
              ],
            ),
          ),
        )
      );
    }
    for(MapPoiModel poi in startSearchResult){
      widgets.add(
        InkWell(
          onTap: (){
            Trip trip = widget.trip;
            trip.startAddress = poi.name;
            trip.startLatitude = poi.lat;
            trip.startLongitude = poi.lng;
            startTextController.text = poi.name ?? '';
            showStartSearchResult = false;
            startPoiChecked = true;
            setState(() {
            });
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.black12))
            ),
            child: Row(
              children: [
                Image.asset('assets/trip/trip_location.png', fit: BoxFit.cover, width: 32, height: 32,),
                const SizedBox(width: 10,),
                Expanded(
                  child: TextHighlight(text: poi.name ?? '', words: map, textStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
                )
              ],
            ),
          ),
        )
      );
    }
    return widgets;
  }

  List<Widget> getPoiWidgets(){
    List<Widget> widgets = [];
    for(int i = 1; i <= (widget.trip.totalNum ?? 0); ++i){
      widgets.add(
        Container(
          height: 36,
          alignment: Alignment.centerLeft,
          child: Text('第 $i 天', style: const TextStyle(color: Colors.grey),),
        )
      );
      List<Widget> poiWidgets = [];
      List<TripPoint>? list = widget.points?.where((element){
        return element.tripDay == i;
      }).toList();
      if(list == null || list.isEmpty){
        widgets.add(
          const Text('自由活动', style: TextStyle(color: Colors.grey),)
        );
      }
      for(int j = 0; j < (list?.length ?? 0); ++j){
        TripPoint point = list![j];
        poiWidgets.add(
          Container(
            height: POI_HEIGHT,
            width: POI_WIDTH,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(6)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4
                )
              ]
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: point.image == null ?
                      Image.asset('images/bg.png', fit: BoxFit.cover, width: double.infinity, height: double.infinity,) :
                      Image.network(
                        point.image!, 
                        fit: BoxFit.cover,
                        width: double.infinity, 
                        height: double.infinity,
                        errorBuilder:(context, error, stackTrace) {
                          return Container(
                            color: ThemeUtil.backgroundColor,
                            alignment: Alignment.center,
                            child: const Icon(Icons.error_outline, color: ThemeUtil.foregroundColor)
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2),
                      child: Text(point.name ?? '', overflow: TextOverflow.ellipsis, style: const TextStyle(color: ThemeUtil.foregroundColor),),
                    )
                  ],
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                    onTap: (){
                      widget.points?.removeAt(j);
                      for(TripPoint other in widget.points ?? []){
                        if(other.tripDay == point.tripDay){
                          if(other.orderNum != null && point.orderNum != null && other.orderNum! > point.orderNum!){
                            other.orderNum = other.orderNum! - 1;
                          }
                        }
                      }
                      setState(() {
                      });
                      TripCreateState? state = context.findAncestorStateOfType();
                      state?.drawMarker();
                    },
                    child: ClipOval(
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Color.fromRGBO(255, 255, 255, 0.8),
                        ),
                        child: svgTripPointDelete,
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        );
      }
      widgets.add(
        Wrap(
          runSpacing: 10,
          spacing: 10,
          children: poiWidgets,
        )
      );
    }
    return widgets;
  }

  void checkStartPoi(){
    String? address = widget.trip.startAddress?.trim();
    startPoiChecked = address == startTextController.text;
    resetState();
  }

  void checkEndPoi(){
    String? address = widget.trip.endAddress?.trim();
    endPoiChecked = address == endTextController.text;
    resetState();
  }

  void resetState(){
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }
}

class AroundPointWidget extends StatefulWidget{
  final Object aroundPoint;
  final Function(Object)? onTapAdd;
  const AroundPointWidget({required this.aroundPoint, this.onTapAdd, super.key});

  @override
  State<StatefulWidget> createState() {
    return AroundPointState();
  }
  
}

class AroundPointState extends State<AroundPointWidget>{

  static const double ADD_BUTTON_SIZE = 28;

  @override
  Widget build(BuildContext context) {
    Hotel? hotel;
    Restaurant? restaurant;
    Scenic? scenic;
    if(widget.aroundPoint is Hotel){
      hotel = widget.aroundPoint as Hotel;
    }
    if(widget.aroundPoint is Restaurant){
      restaurant = widget.aroundPoint as Restaurant;
    }
    if(widget.aroundPoint is Scenic){
      scenic = widget.aroundPoint as Scenic;
    }
    if(hotel == null && restaurant == null && scenic == null){
      return const SizedBox();
    }
    Size size = MediaQuery.of(context).size;
    String? photoUrl;
    double? score;
    int? price;
    String? name;
    String? address;
    if(hotel != null){
      photoUrl = hotel.cover;
      score = hotel.score;
      price = hotel.price;
      name = hotel.name;
      address = hotel.address;
    }
    else if(scenic != null){
      photoUrl = scenic.cover;
      score = scenic.score;
      price = scenic.price;
      name = scenic.name;
      address = scenic.address;
    }
    else if(restaurant != null){
      photoUrl = restaurant.cover;
      score = restaurant.score;
      price = restaurant.averagePrice;
      name = restaurant.name;
      address = restaurant.address;
    }
    if(photoUrl != null){
      photoUrl = getFullUrl(photoUrl);
    }
    return Container(
      width: size.width - 32,
      height: 124,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0xee, 0xee, 0xee, 1),
            offset: Offset(0, 2),
            blurRadius: 2
          )
        ]
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 108,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8))
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: photoUrl == null ?
                        Image.asset('images/bg.png', fit: BoxFit.cover, width: double.infinity, height: double.infinity,) :
                        InkWell(
                          onTap: (){
                            Navigator.of(context).push(MaterialPageRoute(builder: (context){
                              return ImageViewer(photoUrl!);
                            }));
                          },
                          child: Image.network(
                            photoUrl, 
                            fit: BoxFit.cover, 
                            width: double.infinity, 
                            height: double.infinity,
                            errorBuilder:(context, error, stackTrace) {
                              return Container(
                                color: ThemeUtil.backgroundColor,
                                alignment: Alignment.center,
                                child: const Icon(Icons.error_outline, color: ThemeUtil.foregroundColor),
                              );
                            },
                          )
                        )
                      ),
                      if(score != null)
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(2, 4, 2, 4),
                          decoration: const BoxDecoration(
                            color: ThemeUtil.buttonColor,
                            borderRadius: BorderRadius.horizontal(right: Radius.circular(4)),
                          ),
                          child: Text('${StringUtil.getScoreString(score / 10)}"', style: const TextStyle(color: Colors.white),),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 8,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                          ),
                          const SizedBox(width: 10,),
                          if(score != null && score > 0)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(StringUtil.getScoreString(score!), style: const TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold, fontSize: 17),),
                              const Text('分 ', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
                            ],
                          ),
                        ],
                      ),
                      Text(name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),),
                      const SizedBox(height: 4),
                      Text(address ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey),),
                      const Expanded(child: SizedBox()),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if(price != null && price > 0)
                          RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: '￥',
                                  style: TextStyle(color: Colors.red, fontSize: 16)
                                ),
                                TextSpan(
                                  text: StringUtil.getPriceStr(price),
                                  style: const TextStyle(color: Colors.red, fontSize: 16)
                                ),
                                const TextSpan(
                                  text: '起',
                                  style: TextStyle(color: Colors.grey)
                                )
                              ]
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: (){
                widget.onTapAdd?.call(widget.aroundPoint);
              },
              child: Container(
                width: ADD_BUTTON_SIZE,
                height: ADD_BUTTON_SIZE,
                decoration: BoxDecoration(
                  color: ThemeUtil.backgroundColor,
                  borderRadius: const BorderRadius.all(Radius.circular(ADD_BUTTON_SIZE / 2)),
                  border: Border.all(color: ThemeUtil.dividerColor)
                ),
                alignment: Alignment.center,
                child: const Text('+', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: ThemeUtil.foregroundColor),),
              ),
            ),
          )
        ],
      ),
    );
  }
  
}

class TripPointWidget extends StatefulWidget{
  final TripPoint point;
  final Function(TripPoint)? onTapDelete;

  const TripPointWidget(this.point, {this.onTapDelete, super.key});
  
  @override
  State<StatefulWidget> createState() {
    return TripPointState();
  }

}

class TripPointState extends State<TripPointWidget>{

  static const double DELETE_BUTTON_SIZE = 28;

  @override
  Widget build(BuildContext context) {
    if(widget.point.mapPoi == null){
      return const SizedBox();
    }
    MapPoiModel poi = widget.point.mapPoi!;
    Size size = MediaQuery.of(context).size;
    String? photoUrl;
    if(poi.photoList != null && poi.photoList!.isNotEmpty){
      photoUrl = poi.photoList![0];
    }
    return Container(
      width: size.width - 32,
      height: 124,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0xee, 0xee, 0xee, 1),
            offset: Offset(0, 2),
            blurRadius: 2
          )
        ]
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 108,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8))
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: photoUrl == null ?
                        Image.asset('images/bg.png', fit: BoxFit.cover, width: double.infinity, height: double.infinity,) :
                        InkWell(
                          onTap: (){
                            Navigator.of(context).push(MaterialPageRoute(builder: (context){
                              return ImageViewer(photoUrl!);
                            }));
                          },
                          child: Image.network(
                            photoUrl, 
                            fit: BoxFit.cover, 
                            width: double.infinity, 
                            height: double.infinity,
                            errorBuilder:(context, error, stackTrace) {
                              return Container(
                                color: ThemeUtil.backgroundColor,
                                alignment: Alignment.center,
                                child: const Icon(Icons.error_outline, color: ThemeUtil.foregroundColor)
                              );
                            },
                          )
                        )
                      ),
                      poi.score == null ?
                      const SizedBox() :
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(2, 4, 2, 4),
                          decoration: const BoxDecoration(
                            color: ThemeUtil.buttonColor,
                            borderRadius: BorderRadius.horizontal(right: Radius.circular(4)),
                          ),
                          child: Text(poi.score ?? '', style: const TextStyle(color: Colors.white),),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 8,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(poi.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),),
                      const SizedBox(height: 4),
                      Text(poi.address ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey),),
                      const Expanded(child: SizedBox()),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          poi.cost == null ?
                          const SizedBox() :
                          RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: '￥',
                                  style: TextStyle(color: Colors.red, fontSize: 16)
                                ),
                                TextSpan(
                                  text: poi.cost ?? '',
                                  style: const TextStyle(color: Colors.red, fontSize: 16)
                                ),
                                const TextSpan(
                                  text: '起',
                                  style: TextStyle(color: Colors.grey)
                                )
                              ]
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: (){
                widget.onTapDelete?.call(widget.point);
              },
              child: Container(
                width: DELETE_BUTTON_SIZE,
                height: DELETE_BUTTON_SIZE,
                decoration: BoxDecoration(
                  color: ThemeUtil.backgroundColor,
                  borderRadius: const BorderRadius.all(Radius.circular(DELETE_BUTTON_SIZE / 2)),
                  border: Border.all(color: ThemeUtil.dividerColor)
                ),
                alignment: Alignment.center,
                child: const Text('X', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: ThemeUtil.foregroundColor),),
              ),
            ),
          )
        ],
      ),
    );
  }

}

class MapPoiWidget extends StatefulWidget{
  final MapPoiModel poi;
  final Function(MapPoiModel)? onTapAdd;
  const MapPoiWidget(this.poi, {this.onTapAdd, super.key});

  @override
  State<StatefulWidget> createState() {
    return MapPoiState();
  }

}

class MapPoiState extends State<MapPoiWidget>{

  static const double ADD_BUTTON_SIZE = 28;

  @override
  Widget build(BuildContext context) {
    MapPoiModel poi = widget.poi;
    Size size = MediaQuery.of(context).size;
    String? photoUrl;
    if(poi.photoList != null && poi.photoList!.isNotEmpty){
      photoUrl = poi.photoList![0];
    }
    return Container(
      width: size.width - 32,
      height: 124,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0xee, 0xee, 0xee, 1),
            offset: Offset(0, 2),
            blurRadius: 2
          )
        ]
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 108,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8))
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: photoUrl == null ?
                        Image.asset('images/bg.png', fit: BoxFit.cover, width: double.infinity, height: double.infinity,) :
                        InkWell(
                          onTap: (){
                            Navigator.of(context).push(MaterialPageRoute(builder: (context){
                              return ImageViewer(photoUrl!);
                            }));
                          },
                          child: Image.network(
                            photoUrl, 
                            fit: BoxFit.cover, 
                            width: double.infinity, 
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: ThemeUtil.backgroundColor,
                                alignment: Alignment.center,
                                child: const Icon(Icons.error_outline, color: ThemeUtil.foregroundColor)
                              );
                            },
                          )
                        )
                      ),
                      poi.score == null ?
                      const SizedBox() :
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(2, 4, 2, 4),
                          decoration: const BoxDecoration(
                            color: ThemeUtil.buttonColor,
                            borderRadius: BorderRadius.horizontal(right: Radius.circular(4)),
                          ),
                          child: Text(poi.score ?? '', style: const TextStyle(color: Colors.white),),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 8,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(poi.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),),
                      const SizedBox(height: 4),
                      Text(poi.address ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey),),
                      const Expanded(child: SizedBox()),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          poi.cost == null ?
                          const SizedBox() :
                          RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: '￥',
                                  style: TextStyle(color: Colors.red, fontSize: 16)
                                ),
                                TextSpan(
                                  text: poi.cost ?? '',
                                  style: const TextStyle(color: Colors.red, fontSize: 16)
                                ),
                                const TextSpan(
                                  text: '起',
                                  style: TextStyle(color: Colors.grey)
                                )
                              ]
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: (){
                widget.onTapAdd?.call(poi);
              },
              child: Container(
                width: ADD_BUTTON_SIZE,
                height: ADD_BUTTON_SIZE,
                decoration: BoxDecoration(
                  color: ThemeUtil.backgroundColor,
                  borderRadius: const BorderRadius.all(Radius.circular(ADD_BUTTON_SIZE / 2)),
                  border: Border.all(color: ThemeUtil.dividerColor)
                ),
                alignment: Alignment.center,
                child: const Text('+', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: ThemeUtil.foregroundColor),),
              ),
            ),
          )
        ],
      ),
    );
  }

}

class CalendarInsertWidget extends StatefulWidget{

  final Trip trip;
  final List<TripPoint> pointList;
  const CalendarInsertWidget({required this.trip, required this.pointList, super.key});

  @override
  State<StatefulWidget> createState() {
    return CalendarInsertState();
  }
  
}

class CalendarInsertState extends State<CalendarInsertWidget>{

  static const double FIELD_WIDTH = 80;
  bool showDetail = false;

  TextEditingController titleController = TextEditingController();
  TextEditingController hoursController = TextEditingController();

  @override
  void initState(){
    super.initState();
    titleController.text = 'Freego行程';
    hoursController.text = '4';
  }

  @override
  void dispose(){
    titleController.dispose();
    hoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Container(
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
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('是否加入本地日历？', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 20, fontWeight: FontWeight.bold),),
            const SizedBox(height: 32),
            showDetail ?
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: FIELD_WIDTH,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('标', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16, fontWeight: FontWeight.bold),),
                          Text('题', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16, fontWeight: FontWeight.bold),)
                        ],
                      )
                    ),
                    const Text(' ： ', style: TextStyle(color: ThemeUtil.foregroundColor)),
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          border: Border.fromBorderSide(BorderSide(color: Colors.grey)),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: TextField(
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '',
                            isDense: true,
                            contentPadding: EdgeInsets.zero
                          ),
                          textAlign: TextAlign.end,
                          controller: titleController,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    SizedBox(
                      width: FIELD_WIDTH,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('提', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16, fontWeight: FontWeight.bold),),
                          Text('前', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16, fontWeight: FontWeight.bold),),
                          Text('提', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16, fontWeight: FontWeight.bold),),
                          Text('醒', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16, fontWeight: FontWeight.bold),),
                        ],
                      )
                    ),
                    const Text(' ： ', style: TextStyle(color: ThemeUtil.foregroundColor)),
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          border: Border.fromBorderSide(BorderSide(color: Colors.grey)),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: TextField(
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '',
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            suffixText: '小时'
                          ),
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.end,
                          controller: hoursController,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ) :
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: (){
                    showDetail = true;
                    setState(() {
                    });
                  },
                  child: const Text('显示选项', style: TextStyle(color: ThemeUtil.buttonColor, fontWeight: FontWeight.bold),),
                )
              ],
            ),
            const SizedBox(height: 16,),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap
                  ),
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      border: Border.fromBorderSide(BorderSide(color: ThemeUtil.buttonColor))
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(8),
                    child: const Text(' 否 ', style: TextStyle(color: ThemeUtil.buttonColor, fontWeight: FontWeight.bold, fontSize: 18),)
                  ),
                ),
                const SizedBox(width: 16,),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap
                  ),
                  onPressed: (){
                    if(!checkInput()){
                      return;
                    }
                    createCalendarEvent();
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: ThemeUtil.buttonColor,
                      borderRadius: BorderRadius.all(Radius.circular(8))
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(8),
                    child: const Text(' 是 ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))
                  ),
                )
              ],
            )
          ],
        )
      ),
    );
  }
  
  bool checkInput(){
    String title = titleController.text.trim();
    if(title.isEmpty){
      ToastUtil.warn('请输入标题');
      return false;
    }
    String hoursText = hoursController.text.trim();
    if(hoursText.isEmpty){
      ToastUtil.warn('请输入提醒时间');
      return false;
    }
    int? hours = int.tryParse(hoursController.text);
    if(hours == null){
      ToastUtil.warn('请输入正确的提醒时间');
      return false;
    }
    return true;
  }

  Future createCalendarEvent() async{
    int? dayNum = widget.trip.totalNum;
    if(dayNum == null){
      return;
    }
    DateTime? date = widget.trip.startDate;
    if(date == null){
      return;
    }
    String title = titleController.text.trim();
    int? hours = int.tryParse(hoursController.text);
    if(hours == null){
      return;
    }
    for(int i = 1; i <= dayNum; ++i){
      List<TripPoint> points = widget.pointList.where((element) => element.tripDay == i).toList();
      if(points.isEmpty){
        try{
          NativeCalendarUtil().createEventForDay(title: title, setDate: date!, location: '自由活动', reminderMinutes: hours * 60);
        }
        on UnAuthedException catch(e){
          ToastUtil.error(e.message);
        }
      }
      else{
        points.sort((a, b){
          return (a.orderNum ?? 0) - (b.orderNum ?? 0);
        });
        for(TripPoint point in points){
          if(point.name == null){
            continue;
          }
          try{
            await NativeCalendarUtil().createEventForDay(title: title, setDate: date!, location: point.name!, reminderMinutes: hours * 60);
          }
          on UnAuthedException catch (e){
            ToastUtil.error(e.message);
          }
        }
      }
      date = date!.add(const Duration(days: 1));
    }
  }
}
