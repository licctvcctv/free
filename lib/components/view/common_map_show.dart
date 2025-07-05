
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/util/context_util.dart';
import 'package:freego_flutter/util/gaode_util.dart';
import 'package:freego_flutter/util/permission_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../config/const_config.dart';

class CommonMapShowPage extends StatelessWidget{
  final String address;
  final double latitude;
  final double longitude;
  const CommonMapShowPage({required this.address, required this.latitude, required this.longitude, super.key});

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
      body: CommonMapShowWidget(address: address, latitude: latitude, longitude: longitude,),
    );
  }
  
}

class CommonMapShowWidget extends StatefulWidget{
  final String address;
  final double latitude;
  final double longitude;
  const CommonMapShowWidget({required this.address, required this.latitude, required this.longitude, super.key});

  @override
  State<StatefulWidget> createState() {
    return CommonMapShowState();
  }

}

class CommonMapShowState extends State<CommonMapShowWidget>{
  static const double DEFAULT_ZOOM = 12;

  LatLng? userPos;
  Widget svgLocation = SvgPicture.asset('svg/map/location.svg');

  Set<Marker> markers = {};
  AMapFlutterLocation locationUtil = AMapFlutterLocation();

  @override
  void initState(){
    super.initState();
    requestPermission();
  }

  @override
  void dispose(){
    locationUtil.destroy();
    super.dispose();
  }

  void onMapCreate(AMapController amapController) {
    startLocation();
    Future.delayed(const Duration(seconds: 1), (){
      drawMarker();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stack(
            children: [
              Stack(
                children: [
                  Transform.scale(
                    scale: 1.1,
                    alignment: Alignment.topCenter,
                    child: AMapWidget(
                      apiKey: const AMapApiKey(androidKey: ConstConfig.amapApiKeyOfAndroid, iosKey: ConstConfig.amapApiKeyOfIOS),
                      privacyStatement: const AMapPrivacyStatement(hasContains: true, hasShow: true, hasAgree: true),
                      onMapCreated: onMapCreate,
                      initialCameraPosition: CameraPosition(target: LatLng(widget.latitude, widget.longitude), zoom: DEFAULT_ZOOM),
                      tiltGesturesEnabled: false,
                      rotateGesturesEnabled: false,
                      buildingsEnabled: false,
                      mapType: MapType.navi,
                      markers: markers,
                    ),
                  ),
                  const Positioned(
                    left: 0,
                    bottom: 0,
                    child: Text('高德地图', style: TextStyle(color: Color.fromRGBO(78, 89, 105, 0.6))),
                  )
                ],
              ),
              Positioned(
                top: ThemeUtil.getStatusBarHeight(ContextUtil.getContext()!) + 10,
                left: 0,
                child: InkWell(
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
              )
            ],
          ),
        ),
        Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
          alignment: Alignment.center,
          child: Text(widget.address, style: const TextStyle(fontWeight: FontWeight.bold, color: ThemeUtil.foregroundColor),),
        )
      ],
    );
  }

  Future drawMarker() async{
    Set<Marker> buffer = {};
    Marker targetMarker = await getTargetMarker();
    buffer.add(targetMarker);
    Marker? userMarker = await getUserMarker();
    if(userMarker != null){
      buffer.add(userMarker);
    }
    markers = buffer;
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }

  Future<Marker> getTargetMarker() async{
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
      position: LatLng(widget.latitude, widget.longitude),
      icon: icon,
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
        userPos = LatLng(latitude, longitude);
        drawMarker();
      }
    });
    locationUtil.startLocation();
  }
}
