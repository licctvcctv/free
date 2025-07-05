
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/circle_neo/circle_common.dart';
import 'package:freego_flutter/components/circle_neo/circle_http.dart';
import 'package:freego_flutter/components/circle_neo/view/circle_activity.dart';
import 'package:freego_flutter/components/circle_neo/view/circle_article.dart';
import 'package:freego_flutter/components/circle_neo/view/circle_question.dart';
import 'package:freego_flutter/components/circle_neo/view/circle_shop.dart';
import 'package:freego_flutter/components/view/city_picker.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/custom_indicator.dart';
import 'package:freego_flutter/components/view/notify_empty.dart';
import 'package:freego_flutter/components/view/notify_loading.dart';
import 'package:freego_flutter/util/permission_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:permission_handler/permission_handler.dart';

class CircleHomePage extends StatefulWidget{
  const CircleHomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return CircleHomePageState();
  }

}

class CircleHomePageState extends State<CircleHomePage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 10,
        backgroundColor: ThemeUtil.backgroundColor,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: const CircleHomeWidget(),
      ),
    );
  }

}

class CircleHomeWidget extends StatefulWidget{
  const CircleHomeWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return CircleHomeState();
  }

}

class CircleHomeState extends State<CircleHomeWidget> with TickerProviderStateMixin{

  String city = '杭州市';
  final AMapFlutterLocation amapLocation = AMapFlutterLocation();

  List<Circle> circleList = [];

  List<Widget> contents = [];
  List<Widget> topBuffer = [];
  List<Widget> bottomBuffer = [];

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

  bool inited = false;

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
    Future.delayed(Duration.zero, () async{
      List<Circle>? tmpList = await CircleHttp().getHistoryCircle(city: city);
      if(tmpList == null){
        return;
      }
      circleList = tmpList;
      topBuffer = getCircleWidgets(circleList);
      inited = true;
      setState(() {
      });
    });
    startLocation();
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

  Future chooseCity(String? cityName) async{
    if(cityName != null && cityName != city){
      city = cityName;
      List<Circle>? tmpList = await CircleHttp().getHistoryCircle(city: city, maxId: null, keyword: textController.text);
      if(tmpList == null){
        return;
      }
      circleList = tmpList;
      topBuffer = getCircleWidgets(circleList);
      contents = [];
      if(mounted && context.mounted){
        setState(() {
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeUtil.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonHeader(
            center: Text('圈子', style: TextStyle(color: Colors.white, fontSize: 16),),
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
                  chooseCity(cityName);
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
          inited ?
          circleList.isEmpty ?
          const NotifyEmptyWidget() :
          Expanded(
            child: AnimatedCustomIndicatorWidget(
              contents: contents,
              topBuffer: topBuffer,
              bottomBuffer: bottomBuffer,
              touchTop: () async{
                int? minId;
                if(circleList.isNotEmpty){
                  minId = circleList.first.id;
                }
                List<Circle>? tmpList = await CircleHttp().getNewCircle(city: city, minId: minId, keyword: textController.text.trim());
                ToastUtil.hint('已更新到最新');
                if(tmpList == null || tmpList.isEmpty){
                  return;
                }
                circleList.insertAll(0, tmpList);
                topBuffer = getCircleWidgets(tmpList);
                if(mounted && context.mounted){
                  setState(() {
                  });
                }
              },
              touchBottom: () async{
                int? maxId;
                if(circleList.isNotEmpty){
                  maxId = circleList.last.id;
                }
                List<Circle>? tmpList = await CircleHttp().getHistoryCircle(city: city, maxId: maxId, keyword: textController.text.trim());
                if(tmpList == null || tmpList.isEmpty){
                  ToastUtil.hint('已无更多内容');
                  return;
                }
                circleList.addAll(tmpList);
                bottomBuffer = getCircleWidgets(tmpList);
                if(mounted && context.mounted){
                  setState(() {
                  });
                }
              },
            ), 
          ) :
          const Expanded(
            child: Center(
              child: NotifyLoadingWidget(),
            ),
          )
        ],
      ),
    );
  }

  Future search(String val) async{
    List<Circle>? tmpList = await CircleHttp().getHistoryCircle(city: city, keyword: val);
    if(tmpList == null){
      ToastUtil.error('查询失败');
      return;
    }
    circleList = tmpList;
    contents = getCircleWidgets(circleList);
    setState(() {
    });
  }

  List<Widget> getCircleWidgets(List<Circle> list){
    List<Widget> widgets = [];
    for(Circle circle in list){
      if(circle is CircleActivity){
        circle.trip?.points?.sort((a, b){
          if(a.tripDay == null || b.tripDay == null){
            return 0;
          }
          if(a.tripDay! < b.tripDay!){
            return -1;
          }
          else if(a.tripDay! > b.tripDay!){
            return 1; 
          }
          else{
            if(a.orderNum == null || b.orderNum == null){
              return 0;
            }
            if(a.orderNum! <= b.orderNum!){
              return -1;
            }
            else {
              return 1;
            }
          }
        });
        widgets.add(
          CircleActivityWidget(circle, key: ValueKey(circle.id),)
        );
      }
      else if(circle is CircleArticle){
        widgets.add(
          CircleArticleWidget(circle, key: ValueKey(circle.id),)
        );
      }
      else if(circle is CircleQuestion){
        widgets.add(
          CircleQuestionWidget(circle, key: ValueKey(circle.id),)
        );
      }
      else if(circle is CircleShop){
        widgets.add(
          CircleShopWidget(circle, key: ValueKey(circle.id),)
        );
      }
    }
    return widgets;
  }

  Future startLocation() async{
    bool isGranted = await PermissionUtil().requestPermission(context: context, permission: Permission.location, info: '希望获取位置权限用于获取您所在位置');
    if(!isGranted){
      return;
    }
    amapLocation.onLocationChanged().listen((event) {
      if(event['city'] is String){
        city = event['city'].toString();
        chooseCity(city);
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
