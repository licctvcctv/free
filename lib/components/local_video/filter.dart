
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:freego_flutter/util/local_file_util.dart';

class Filter{
  final String name;
  final String script;
  const Filter({required this.name, required this.script});
}

class FilterLib{

  static final FilterLib _instance = FilterLib._internal();
  FilterLib._internal();
  factory FilterLib(){
    return _instance;
  }

  final Filter noFilter = const Filter(name: '无', script: '');
  final Filter motionFlow = const Filter(name: '慢动作', script: '@dynamic motionflow 12 0');
  final Filter softlight = const Filter(name: '柔光', script: '@selfblend softlight 100');
  final Filter hardlight = const Filter(name: '强光', script: '@selfblend hardlight 100');
  final Filter vividlight = const Filter(name: '亮光', script: '@selfblend vividlight 100');
  final Filter linearlight = const Filter(name: '线性光', script: '@selfblend linearlight 100');
  final Filter pinlight = const Filter(name: '点光', script: '@selfblend pinlight 100');
  final Filter hardmix = const Filter(name: '实色混合', script: '@selfblend hardmix 10');
  final Filter colorburn = const Filter(name: '颜色加深', script: '@selfblend colorburn 100');
  final Filter colorodge = const Filter(name: '颜色减淡', script: '@selfblend colorodge 100');
  final Filter sharpen = const Filter(name: '锐化', script: '@adjust sharpen 2');
  final Filter saturation = const Filter(name: '饱和度', script: '@adjust saturation 2');

  final Filter edgyamber = const Filter(name: '琥珀', script: '@adjust lut edgy_amber.png');
  final Filter filmstock = const Filter(name: '胶片', script: '@adjust lut filmstock.png');
  final Filter foggynight = const Filter(name: '迷雾', script: '@adjust lut foggy_night.png');
  final Filter latesunset = const Filter(name: '晚霞', script: '@adjust lut late_sunset.png');
  final Filter softwarming = const Filter(name: '暖阳', script: '@adjust lut soft_warming.png');
  final Filter wildbird = const Filter(name: '自然', script: '@adjust lut wildbird.png');

  Future<String?> loadResources() async{
    const String assetDirPath = 'assets/camera/filter';
    Directory? filterResourceDir = await LocalFileUtil.getResourcePath();
    if(filterResourceDir == null){
      return null;
    }
    filterResourceDir = Directory('${filterResourceDir.path}/camera/filter');
    if(!filterResourceDir.existsSync()){
      filterResourceDir.createSync(recursive: true);
    }
    List<String> resourceList = [
      'edgy_amber.png',
      'filmstock.png',
      'foggy_night.png',
      'late_sunset.png',
      'soft_warming.png',
      'wildbird.png'
    ];
    for(String resource in resourceList){
      try{
        ByteData byteData = await rootBundle.load('$assetDirPath/$resource');
        File outputFile = File('${filterResourceDir.path}/$resource');
        await outputFile.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
      }
      catch(e){
        //
      }
    }
    return filterResourceDir.path;
  }
}
