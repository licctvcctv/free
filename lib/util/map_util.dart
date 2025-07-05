
import 'dart:ui' as ui;
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class MapUtil{

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

  static Future<ByteData?> widgetToByteData(Widget widget,{
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
