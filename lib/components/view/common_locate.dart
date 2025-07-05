
import 'dart:typed_data';

import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/search_bar.dart';
import 'package:freego_flutter/config/const_config.dart';
import 'package:freego_flutter/http/http_gaode.dart';
import 'package:freego_flutter/model/map_poi.dart';
import 'package:freego_flutter/util/gaode_util.dart';
import 'package:freego_flutter/util/permission_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:permission_handler/permission_handler.dart';

class CommonLocatePage extends StatelessWidget{
  final double? initLat;
  final double? initLng;
  const CommonLocatePage({this.initLat, this.initLng, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 10,
        elevation: 0,
        backgroundColor: Colors.white,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: CommonLocateWidget(initLat, initLng),
      ),
    );
  }

}

class CommonLocateWidget extends StatefulWidget{
  final double? initLat;
  final double? initLng;
  const CommonLocateWidget(this.initLat, this.initLng, {super.key});

  @override
  State<StatefulWidget> createState() {
    return CommonLocateState();
  }

}

class CommonLocateState extends State<CommonLocateWidget>{

  static const double DEFAULT_ZOOM = 12;
  static const int SEARCH_PAGE_SIZE = 20;
  static const double SIMPLE_POI_HEIGHT = 80;

  LatLng targetPos = const LatLng(39.909187, 116.397451);
  AMapController? mapController;

  LatLng? userPos;
  AMapFlutterLocation locationUtil = AMapFlutterLocation();

  Set<Marker> markers = {};

  Widget svgLocation = SvgPicture.asset('svg/map/location.svg');

  List<MapPoiModel> poiList = [];
  String keywords = '';
  int poiPage = 1;
  bool poiEnd = false;

  @override
  void initState(){
    super.initState();
    if(widget.initLat != null && widget.initLng != null){
      targetPos = LatLng(widget.initLat!, widget.initLng!);
      drawMarker();
      searchPoi().then((value){
        if(mounted && context.mounted){
          setState(() {
          });
        }
      });
    }
    requestPermission();
  }

  @override
  void dispose(){
    mapController?.disponse();
    locationUtil.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CommonHeader(
          center: SimpleSearchBar(
            onSumbit: (val){
              keywords = val;
              resetPoiList();
              searchPoi().then((value){
                if(mounted && context.mounted){
                  setState(() {
                  });
                }
              });
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
                    child: AMapWidget(
                      apiKey: const AMapApiKey(androidKey:ConstConfig.amapApiKeyOfAndroid, iosKey: ConstConfig.amapApiKeyOfIOS),
                      privacyStatement: const AMapPrivacyStatement(hasContains: true, hasShow: true, hasAgree: true),
                      onMapCreated: (controller){
                        mapController = controller;
                        startLocation();
                      },
                      initialCameraPosition: CameraPosition(target: targetPos, zoom: DEFAULT_ZOOM),
                      tiltGesturesEnabled: false,
                      rotateGesturesEnabled: false,
                      buildingsEnabled: false,
                      mapType: MapType.navi,
                      markers: markers,
                      onTap: (pos){
                        targetPos = pos;
                        drawMarker();
                        resetPoiList();
                        searchPoi().then((value){
                          if(mounted && context.mounted){
                            setState(() {
                            });
                          }
                        });
                      },
                    ),
                  ),
                  const Positioned(
                    left: 0,
                    bottom: 0,
                    child: Text('高德地图', style: TextStyle(color: Color.fromRGBO(78, 89, 105, 0.6))),
                  )
                ],
              ),
            ],
          ),
        ),
        Container(
          height: (MediaQuery.of(context).size.height - ThemeUtil.getStatusBarHeight(context) - 10 - CommonHeader.HEADER_HEIGHT ) * 0.4,
          color: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: getPoiWidget(),
          ),
        )
      ],
    );
  }

  List<Widget> getPoiWidget(){
    List<Widget> widgets = [];
    for(MapPoiModel poi in poiList){
      if(poi.address == null || poi.address!.isEmpty || poi.lat == null || poi.lng == null){
        continue;
      }
      widgets.add(
        InkWell(
          onTap: (){
            Navigator.of(context).pop(poi);
          },
          child: SizedBox(
            height: SIMPLE_POI_HEIGHT,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Text(poi.name ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold),),
              ),
            ),
          )
        )
      );
    }
    return widgets;
  }

  void resetPoiList(){
    poiList.clear();
    poiPage = 1;
    poiEnd = false;
  }

  Future searchPoi() async{
    if(poiEnd){
      return;
    }
    List<MapPoiModel>? tmpList = await HttpGaode.getNearAddress(targetPos.latitude, targetPos.longitude, page: poiPage, pageSize: SEARCH_PAGE_SIZE, keywords: keywords);
    if(tmpList == null){
      return;
    }
    if(tmpList.length < SEARCH_PAGE_SIZE){
      poiEnd = true;
    }
    poiList.addAll(tmpList);
    ++poiPage;
  }

  Future drawMarker() async{
    Set<Marker> buffer = {};
    Marker? userMarker = await getUserMarker();
    if(userMarker != null){
      buffer.add(userMarker);
    }
    Marker? targetMarker = await getTargetMarker();
    if(targetMarker != null){
      buffer.add(targetMarker);
    }
    markers = buffer;
    setState(() {
    });
  }

  Future<Marker?> getTargetMarker() async{
    ByteData? byteData = await GaodeUtil.widgetToByteData(
      SizedBox(
        width: 80,
        height: 80,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: svgLocation,
        ),
      )
    );
    BitmapDescriptor icon = BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
    Marker marker = Marker(
      position: targetPos,
      icon: icon,
      infoWindowEnable: false,
      zIndex: 1
    );
    return marker;
  }

  Future<Marker?> getUserMarker() async{
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
      anchor: const Offset(0.5, 0.5),
      position: userPos!,
      icon: icon,
      infoWindowEnable: false,
      onTap: (val){
        targetPos = userPos!;
        drawMarker();
        resetPoiList();
        searchPoi().then((value){
          if(mounted && context.mounted){
            setState(() {
            });
          }
        });
      }
    );
    return marker;
  }

  Future requestPermission() async{
    bool isGranted = await PermissionUtil().requestPermission(context: context, permission: Permission.location, info: '希望获取位置权限用于标记您所在位置');
    if(!isGranted){
      ToastUtil.error('获取定位权限失败');
    }
  }

  Future startLocation() async{
    locationUtil.onLocationChanged().listen((event) {
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
        userPos = LatLng(latitude, longitude);
        if(moveCamera){
          mapController!.moveCamera(CameraUpdate.newLatLng(userPos!));
          targetPos = userPos!;
          resetPoiList();
          searchPoi().then((value){
            if(mounted && context.mounted){
              setState(() {
              });
            }
          });
        }
        drawMarker();
      }
    });
    locationUtil.startLocation();
  }
}
