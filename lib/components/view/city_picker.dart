
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/view/alphabetic_navi.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/search_bar.dart';
import 'package:freego_flutter/data/city.dart';
import 'package:freego_flutter/util/permission_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:permission_handler/permission_handler.dart';

class CityPickerPage extends StatefulWidget{
  final bool allowAllChoose; //是否允许选择全国，默认为否
  final Object allChooseValue; //选择全国时的返回值，默认未字符串'\all'
  const CityPickerPage({super.key, this.allowAllChoose = false, this.allChooseValue = '\\all'});

  @override
  State<StatefulWidget> createState() {
    return CityPickerPageState();
  }
  
}

class CityPickerPageState extends State<CityPickerPage>{
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
        child: CityPickerWidget(allowAllChoose: widget.allowAllChoose, allChooseValue: widget.allChooseValue,),
      ),
    );
  }

}

class CityPickerWidget extends StatefulWidget{
  final bool allowAllChoose; //是否允许选择全国，默认为否
  final Object allChooseValue; //选择全国时的返回值，默认未字符串'\all'
  const CityPickerWidget({super.key, this.allowAllChoose = false, this.allChooseValue = '\\all'});

  @override
  State<StatefulWidget> createState() {
    return CityPickerState();
  }

}

class CityPickerState extends State<CityPickerWidget> with SingleTickerProviderStateMixin, WidgetsBindingObserver{

  String? currentCity;
  final AMapFlutterLocation amapLocation = AMapFlutterLocation();
  
  List<String> recommendedCities = ['北京', '上海', '广州', '深圳', '杭州', '成都', '西安', '武汉'];

  Map<String, List<String>> cityAlpMap = City.getAlphabetWithCities();
  Map<String, GlobalKey?> letterKeyMap = {};
  GlobalKey scrollKey = GlobalKey();
  ScrollController scrollController = ScrollController();
  AlphabeticNaviController naviController = AlphabeticNaviController();

  bool showSearchResult = false;
  List<String> searchResults = [];
  String keyword = '';

  late AnimationController _keyboardAnim;

  @override
  void initState(){
    super.initState();
    startLocation();
    _keyboardAnim = AnimationController(vsync: this, lowerBound: 0, upperBound: double.infinity);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose(){
    amapLocation.stopLocation();
    amapLocation.destroy();
    scrollController.dispose();
    naviController.dispose();
    _keyboardAnim.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: ThemeUtil.backgroundColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonHeader(
                center: SimpleSearchBar(
                  onSumbit: (val){
                    if(val.isEmpty){
                      return;
                    }
                    keyword = val;
                    searchResults = City.searchCities(keyword);
                    showSearchResult = true;
                    setState(() {
                    });
                  },
                  onFocus: (val){
                    showSearchResult = false;
                    setState(() {
                    });
                  },
                )
              ),
              Expanded(
                child: Stack(
                  children: [
                    ListView(
                      key: scrollKey,
                      padding: EdgeInsets.zero,
                      controller: scrollController,
                      physics: const ClampingScrollPhysics(),
                      children: [
                        getCurrentCityWidget(),
                        if(widget.allowAllChoose)
                          getAllCityWidget(),
                        getRecommendedCitiesWidget(),
                        getAlpListWidget(),
                      ],
                    ),
                    Offstage(
                      offstage: !showSearchResult,
                      child: Stack(
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: (){
                              showSearchResult = false;
                              setState(() {
                              });
                            },
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              getSearchResultWidget(),
                            ],
                          ),
                        ],
                      )
                    ),
                  ],
                )
              ),
              AnimatedBuilder(
                animation: _keyboardAnim,
                builder:(context, child) {
                  return Container(
                    height: _keyboardAnim.value,
                    color: ThemeUtil.backgroundColor,
                  );
                },
              )
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: AlphabeticNaviWidget(
            controller: naviController,
            onClickNavi: (idx){
              String letter = alphabets[idx];
              GlobalKey? childKey = letterKeyMap[letter];
              if(childKey == null){
                return;
              }
              RenderBox? parentBox = scrollKey.currentContext?.findRenderObject() as RenderBox?;
              if(parentBox == null){
                return;
              }
              RenderBox? childBox = childKey.currentContext?.findRenderObject() as RenderBox?;
              if(childBox == null){
                return;
              }
              double parentY = parentBox.localToGlobal(Offset.zero).dy;
              double childY = childBox.localToGlobal(Offset.zero).dy;
              scrollController.jumpTo(childY - parentY + scrollController.offset);
            },
          ),
        ),
      ],
    );
  }

  Widget getSearchResultWidget(){
    if(searchResults.isEmpty){
      return Container(
        width: double.infinity,
        alignment: Alignment.topCenter,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16))
          ),
          margin: const EdgeInsets.fromLTRB(60, 0, 60, 0),
          height: 180,
          width: double.infinity,
          alignment: Alignment.center,
          child: const Text('无搜索结果', style: TextStyle(color: Colors.black12, fontWeight: FontWeight.bold, fontSize: 16),),
        ),
      );
    }
    List<Widget> widgets = [];
    for(int i = 0; i < searchResults.length; ++i){
      widgets.add(
        InkWell(
          onTap: (){
            Navigator.of(context).pop(searchResults[i]);
          },
          child: Row(
            children: [
              const SizedBox(width: 16,),
              const Icon(Icons.location_on_rounded, color: ThemeUtil.foregroundColor,),
              const Expanded(
                child: SizedBox(),
              ),
              Container(
                height: 40,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Text(searchResults[i], style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
              )
            ],
          ),
        )
      );
      widgets.add(
        Container(
          height: 1,
          color: ThemeUtil.dividerColor,
        )
      );
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(60, 0, 60, 0),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4
          )
        ]
      ),
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const ClampingScrollPhysics(),
        children: widgets,
      ),
    );  
  }

  Widget getAlpListWidget(){
    List<Widget> widgets = [];
    for(MapEntry entry in cityAlpMap.entries){
      GlobalKey key = GlobalKey();
      letterKeyMap[entry.key] = key;
      widgets.add(
        Container(
          key: key,
          padding: const EdgeInsets.fromLTRB(12, 5, 12, 5),
          alignment: Alignment.centerLeft,
          child: Text(entry.key, style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
        )
      );
      List<Widget> subs = [];
      for(String cityName in entry.value){
        subs.add(
          InkWell(
            onTap: (){
              Navigator.of(context).pop(cityName);
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              alignment: Alignment.centerLeft,
              child: Text(cityName, style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
            ),
          )
        );
      }
      widgets.add(
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(12))
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: subs,
          ),
        )
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget getRecommendedCitiesWidget(){
    int cols = 4;
    List<Widget> widgets = [];
    widgets.add(
      const Text('常用', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),)
    );
    for(int i = 0; i < (recommendedCities.length + cols - 1) ~/ 4; ++i){
      List<Widget> subs = [];
      int low = i * cols;
      int high = i * cols + cols - 1;
      for(int j = low; j <= high; ++j){
        subs.add(
          InkWell(
            onTap: (){
              Navigator.of(context).pop('${recommendedCities[j]}市');
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(5))
              ),
              child: Text(recommendedCities[j], style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
            ),
          )
        );
      }
      widgets.add(
        const SizedBox(height: 10,)
      );
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: subs,
          ),
        )
      );
    }
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets
      ),
    );
  }

  Widget getAllCityWidget(){
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('全国', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
          const SizedBox(height: 10,),
          InkWell(
            onTap: (){
              Navigator.of(context).pop(widget.allChooseValue);
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 5, 12, 5),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(5))
              ),
              child: const Text('全国', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
            ),
          )
        ],
      ),
    );
  }

  Widget getCurrentCityWidget(){
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('当前', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
          const SizedBox(height: 10,),
          InkWell(
            onTap: (){
              if(currentCity != null){
                Navigator.of(context).pop(currentCity);
              }
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 5, 12, 5),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(5))
              ),
              child: Text(currentCity ?? '未知', style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
            ),
          )
        ],
      ),
    );
  }

  Future startLocation() async{
    bool isGranted = await PermissionUtil().requestPermission(context: context, permission: Permission.location, info: '希望获取当前位置用于获取您所在城市');
    if(isGranted){
      startAmapLocation();
    }
  }

  void startAmapLocation(){
    amapLocation.onLocationChanged().listen((event) {
      if(event['city'] is String){
        currentCity = event['city'].toString();
        if(mounted && context.mounted){
          setState(() {
          });
        }
      }
    });
    amapLocation.startLocation();
  }

  @override
  void didChangeMetrics(){
    super.didChangeMetrics();
    double keyboardHeight = EdgeInsets.fromWindowPadding(
      WidgetsBinding.instance.window.viewInsets, 
      WidgetsBinding.instance.window.devicePixelRatio).bottom;
    _keyboardAnim.value = keyboardHeight;
  }
}
