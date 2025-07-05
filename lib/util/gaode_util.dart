
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class GaodeUtil{

  static double devicePixelRatio = 1;

  static LatLng? latLngFromText(String text){
    if(text.endsWith(';')){
      text = text.substring(0, text.length - 1);
    }
    List<String> vals = text.split(',');
    if(vals.length == 2){
      double? lng = double.tryParse(vals[0]);
      double? lat = double.tryParse(vals[1]);
      if(lng != null && lat != null){
        return LatLng(lat, lng);
      }
    }
    return null;
  }

  static String latLngToText(LatLng latLng){
    return '${latLng.longitude},${latLng.latitude}';
  }

  static Future<Marker> getCustomMarker(LatLng position, Widget content, {Function(String)? onClick}) async{
    ByteData? byteData = await GaodeUtil.widgetToByteData(
      content
    );
    BitmapDescriptor icon = BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
    Marker marker = Marker(
      position: position,
      icon: icon,
      onTap: onClick
    );
    return marker;
  }

  static LatLngBounds getBoundsBySize(LatLng position, Size size, double zoom){
    double scale = zoomToScale(zoom.floor()) * (zoom.floor() + 1 - zoom) + zoomToScale(zoom.floor() + 1) * (zoom - zoom.floor());
    double radio = scale / (1000 / AMapUtil.devicePixelRatio); // 单位像素距离，单位为米
    double upperLat = (radio * 1.5 * size.height) / (EARTHRADIUS * math.pi * 2) * 360 + position.latitude; 
    double circleRadius = math.cos(position.latitude * DEG_TO_RAD) * EARTHRADIUS;
    double deltaLng = (radio * size.width) / (circleRadius * math.pi * 2) * 360;
    double leftLng = position.longitude - deltaLng;
    double rightLng = position.longitude + deltaLng;
    LatLngBounds bounds = LatLngBounds(southwest: LatLng(position.latitude, leftLng), northeast: LatLng(upperLat, rightLng));
    return bounds;
  }

  static double zoomToScale(int zoom){
    if(zoom > 20){
      return 0;
    }
    switch(zoom){
      case 20:
        return 5;
      case 19:
        return 10;
      case 18:
        return 25;
      case 17:
        return 50;
      case 16:
        return 100;
      case 15:
        return 200;
      case 14:
        return 500;
      case 13:
        return 1000;
      case 12:
        return 2000;
      case 11:
        return 5000;
      case 10:
        return 10000;
      case 9:
        return 20000;
      case 8:
        return 30000;
      case 7:
        return 50000;
      case 6:
        return 100000;
      case 5:
        return 200000;
      case 4:
        return 500000;
      case 3:
        return 1000000;
      default: 
        return double.infinity;
    }
  }

  static Future<ByteData?> widgetToByteData(Widget widget, {
    Alignment alignment = Alignment.center,
    Size size = const Size(double.maxFinite, double.maxFinite),
    double devicePixelRatio = 1.0,
    double pixelRatio = 1.0}) async {
      RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();
      RenderView renderView = RenderView(
        child: RenderPositionedBox(alignment: alignment, child: repaintBoundary),
        configuration: ViewConfiguration(
          size: size,
          devicePixelRatio: devicePixelRatio,
      ),
      window: ui.window,
    );

    PipelineOwner pipelineOwner = PipelineOwner();
    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());
    RenderObjectToWidgetElement rootElement = RenderObjectToWidgetAdapter(
      container: repaintBoundary,
      child: widget,
    ).attachToRenderTree(buildOwner);
    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();

    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    ui.Image image = await repaintBoundary.toImage(pixelRatio: pixelRatio);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData;
  }
}

class MarkerWrapper{
  Marker marker;
  Size? size;
  MarkerWrapper(this.marker, {this.size});
}

extension LatLngBoundsExt on LatLngBounds{

  bool checkContact(LatLngBounds other){
    if(contains(other.northeast)){
      return true;
    }
    if(contains(other.southwest)){
      return true;
    }
    LatLng northWest = LatLng(other.northeast.latitude, other.southwest.longitude);
    if(contains(northWest)){
      return true;
    }
    LatLng southEast = LatLng(other.southwest.latitude, other.northeast.longitude);
    if(contains(southEast)){
      return true;
    }
    return false;
  }
}

extension LatLngBoundsListExt on List<LatLngBounds>{

  bool checkContact(LatLngBounds other){
    for(LatLngBounds bounds in this){
      if(bounds.checkContact(other) || other.checkContact(bounds)){
        return true;
      }
    }
    return false;
  }
}
