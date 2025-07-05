
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/trip/trip_common.dart';
import 'package:freego_flutter/components/trip/trip_create.dart';
import 'package:freego_flutter/components/trip/trip_http.dart';
import 'package:freego_flutter/components/trip/trip_show.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/custom_indicator.dart';
import 'package:freego_flutter/components/view/notify_empty.dart';
import 'package:freego_flutter/components/view/notify_loading.dart';
import 'package:freego_flutter/components/view/switcher.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/model/map_poi.dart';
import 'package:freego_flutter/util/date_time_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';

class MyTripPage extends StatefulWidget{
  const MyTripPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return MyTripPageState();
  }

}

class MyTripPageState extends State<MyTripPage>{
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
      body: const MyTripWidget(),
    );
  }

}

class MyTripWidget extends StatefulWidget{
  const MyTripWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return MyTripState();
  }

}

class MyTripState extends State<MyTripWidget>{

  Widget svgAdd = SvgPicture.asset('svg/trip/trip_add.svg');
  PageController pageController = PageController();

  TripOngoingController tripOngoingController = TripOngoingController();

  @override
  void initState(){
    super.initState();
  }

  @override
  void dispose(){
    pageController.dispose();
    tripOngoingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeUtil.backgroundColor,
      child: Column(
        children: [
          const CommonHeader(
            center: Text('我的行程', style: TextStyle(color: Colors.white),),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Switcher(
              leftText: '进行中',
              rightText: '已完成',
              onTapLeft: (){
                pageController.animateToPage(0, duration: const Duration(milliseconds: SwitcherState.ANIM_MILLISECONDS), curve: Curves.ease);
              },
              onTapRight: (){
                pageController.animateToPage(1, duration: const Duration(milliseconds: SwitcherState.ANIM_MILLISECONDS), curve: Curves.ease);
              },
            ),
          ),
          Expanded(
            child: PageView(
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                TripOngoingWidget(),
                TripDoneWidget()
              ],
            )
          ),
          InkWell(
            onTap: () async{
              dynamic result = await Navigator.of(context).push(MaterialPageRoute(builder: (context){
                return const TripCreatePage();
              }));
              if(result == true){
                tripOngoingController.refresh();
              }
            },
            child: Container(
              decoration: const BoxDecoration(
                color: ThemeUtil.buttonColor,
                borderRadius: BorderRadius.all(Radius.circular(12))
              ),
              clipBehavior: Clip.hardEdge,
              width: 200,
              height: 50,
              alignment: Alignment.center,
              child: svgAdd,
            ),
          ),
          const SizedBox(height: 10,)
        ],
      ),
    );
  }
}

enum TripOngoingAction{
  refresh
}

class TripOngoingController extends ChangeNotifier{
  TripOngoingAction? action;
  void refresh(){
    action = TripOngoingAction.refresh;
    notifyListeners();
  }
}

class TripOngoingWidget extends StatefulWidget{
  final TripOngoingController? controller;
  const TripOngoingWidget({this.controller, super.key});

  @override
  State<StatefulWidget> createState() {
    return TripOngoingState();
  }

}

class TripOngoingState extends State<TripOngoingWidget> with AutomaticKeepAliveClientMixin{

  List<TripVo> list = [];
  DateTime endDate = DateTime.now();
  bool inited = false;

  List<Widget> content = [];
  List<Widget> topBuffer = [];
  List<Widget> bottomBuffer = [];

  @override
  void initState(){
    super.initState();
    refresh();
    if(widget.controller != null){
      widget.controller!.addListener(() {
        TripOngoingAction? action = widget.controller!.action;
        switch(action){
          case TripOngoingAction.refresh:
            refresh();
            break;
          default:
        }
      });
    }
  }

  Future refresh() async{
    content = [];
    List<TripVo>? list = await TripHttp.getTrip(startDate: endDate);
    if(list != null){
      this.list = list;
      topBuffer = getTripWidgets(list);
    }
    inited = true;
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if(!inited){
      return const NotifyLoadingWidget();
    }
    if(list.isEmpty){
      return const NotifyEmptyWidget();
    }
    return AnimatedCustomIndicatorWidget(
      contents: content,
      topBuffer: topBuffer,
      bottomBuffer: bottomBuffer,
      touchTop: () async{
        List<TripVo>? list = await TripHttp.getTrip(startDate: endDate);
        if(list != null){
          this.list = list;
          content = [];
          topBuffer = getTripWidgets(list);
          if(mounted && context.mounted){
            setState(() {
            });
          }
          ToastUtil.hint('刷新成功');
        }
        else{
          ToastUtil.error('刷新失败');
        }
      },
      touchBottom: () async{
        List<TripVo>? list = await TripHttp.getTrip(startDate: endDate, offset: this.list.length);
        if(list != null && list.isNotEmpty){
          this.list.addAll(list);
          bottomBuffer = getTripWidgets(list);
          if(mounted && context.mounted){
            setState(() {
            });
          }
        }
        else{
          ToastUtil.hint('已经没有了呢');
        }
      },
    );
  }

  List<Widget> getTripWidgets(List<TripVo> list){
    List<Widget> widgets = [];
    for(TripVo vo in list){
      widgets.add(TripShowWidget(vo));
    }
    return widgets;
  }
  
  @override
  bool get wantKeepAlive => true;
}

class TripDoneWidget extends StatefulWidget{
  const TripDoneWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return TripDoneState();
  }

}

class TripDoneState extends State<TripDoneWidget> with AutomaticKeepAliveClientMixin{

  List<TripVo> list = [];
  DateTime endDate = DateTime.now();
  bool inited = false;

  List<Widget> content = [];
  List<Widget> topBuffer = [];
  List<Widget> bottomBuffer = [];

  @override
  void initState(){
    super.initState();
    Future.delayed(Duration.zero, () async{
      List<TripVo>? list = await TripHttp.getTrip(endDate: endDate);
      if(list != null){
        this.list = list;
        topBuffer = getTripWidgets(list);
      }
      inited = true;
      if(mounted && context.mounted){
        setState(() {
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if(!inited){
      return const NotifyLoadingWidget();
    }
    if(list.isEmpty){
      return const NotifyEmptyWidget();
    }
    return AnimatedCustomIndicatorWidget(
      contents: content,
      topBuffer: topBuffer,
      bottomBuffer: bottomBuffer,
      touchBottom: () async{
        List<TripVo>? list = await TripHttp.getTrip(endDate: endDate, offset: this.list.length);
        if(list != null && list.isNotEmpty){
          this.list.addAll(list);
          bottomBuffer = getTripWidgets(list);
          if(mounted && context.mounted){
            setState(() {
            });
          }
        }
        else{
          ToastUtil.hint('已经没有了呢');
        }
      },
    );
  }

  List<Widget> getTripWidgets(List<TripVo> list){
    List<Widget> widgets = [];
    for(TripVo vo in list){
      widgets.add(TripShowWidget(vo, completed: true,));
    }
    return widgets;
  }
  
  @override
  bool get wantKeepAlive => true;
}

class TripShowWidget extends StatefulWidget{
  final TripVo trip;
  final bool completed;
  const TripShowWidget(this.trip, {this.completed = false, super.key});

  @override
  State<StatefulWidget> createState() {
    return TripShowState();
  }

}

class TripShowState extends State<TripShowWidget>{

  static const double COVER_HEIGHT = 196;
  static const double COVER_WIDTH = 332;
  static const double CONTENT_HEIGTH = 260;

  static const double COMPLETED_SIZE = 160;

  Widget tripShowFrame = SvgPicture.asset('svg/trip/trip_show_frame.svg', fit: BoxFit.fill,);
  Widget tripIconHotel = SvgPicture.asset('svg/trip/trip_icon_hotel.svg', fit: BoxFit.fill,);
  Widget tripIconRestaurant = SvgPicture.asset('svg/trip/trip_icon_restaurant.svg', fit: BoxFit.fill,);
  Widget tripIconScenic = SvgPicture.asset('svg/trip/trip_icon_scenic.svg', fit: BoxFit.fill,);
  Widget tripIconDefault = SvgPicture.asset('svg/trip/trip_icon_default.svg', fit: BoxFit.fill,);

  int currentDay = 1;
  PageController controller = PageController();

  @override
  void dispose(){
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TripVo trip = widget.trip;
    return InkWell(
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(builder: (context){
          return TripShowPage(trip);
        }));
      }, 
      child: Container(
        margin: const EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            tripShowFrame,
            Container(
              margin: const EdgeInsets.fromLTRB(9, 0, 9, 0),
              child: Column(
                children: [
                  SizedBox(
                    height: COVER_HEIGHT,
                    width: COVER_WIDTH,
                    child: widget.trip.cover == null ?
                    Image.asset('assets/trip/trip_title.png', fit: BoxFit.cover,) :
                    Image.network(getFullUrl(widget.trip.cover!), fit: BoxFit.cover,),
                  ),
                  SizedBox(
                    width: COVER_WIDTH,
                    height: CONTENT_HEIGTH,
                    child: Stack(
                      children: [
                        widget.completed ?
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 32),
                            width: COMPLETED_SIZE,
                            child: Image.asset('assets/trip/completed.png', fit: BoxFit.fill,),
                          ),
                        ):
                        const SizedBox(),
                        Padding(
                          padding: const EdgeInsets.only(left: 14, right: 14),
                          child: PageView.builder(
                            physics: const ClampingScrollPhysics(),
                            controller: controller,
                            itemCount: trip.totalNum,
                            itemBuilder: (context, index){
                              return ListView(
                                padding: EdgeInsets.zero,
                                physics: const ClampingScrollPhysics(),
                                children: getDayWidgets(index + 1)
                              );
                            },
                            onPageChanged: (idx){
                              currentDay = idx + 1;
                              setState(() {
                              });
                            },
                          ),
                        ),
                        currentDay > 1 ?
                        Align(
                          alignment: Alignment.centerLeft,
                          child: InkWell(
                            onTap: (){
                              if(currentDay <= 1){
                                return;
                              }
                              currentDay = currentDay - 1;
                              controller.animateToPage(currentDay - 1, duration: const Duration(milliseconds: 350), curve: Curves.ease);
                              setState(() {
                              });
                            },
                            child: const Icon(Icons.arrow_circle_left, size: 28, color: Color.fromRGBO(204, 204, 204, 0.6),)
                          ),
                        ):
                        const SizedBox(),
                        trip.totalNum != null && currentDay < trip.totalNum! ?
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: (){
                              if(trip.totalNum == null || currentDay >= trip.totalNum!){
                                return;
                              }
                              currentDay = currentDay + 1;
                              controller.animateToPage(currentDay - 1, duration: const Duration(milliseconds: 350), curve: Curves.ease);
                              setState(() {
                              });
                            },
                            child: const Icon(Icons.arrow_circle_right, size: 28, color: Color.fromRGBO(204, 204, 204, 0.6),),
                          ),
                        ) :
                        const SizedBox(),
                      ]
                    )
                  ),
                  Container(
                    width: COVER_WIDTH,
                    height: 40,
                    alignment: Alignment.center,
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      children: [
                        Text(trip.startAddress ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor),),
                        const Text(' - ', style: TextStyle(color: ThemeUtil.foregroundColor),),
                        Text(trip.endAddress ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor),),
                      ]
                    ),
                  )
                ],
              )
            ),
          ],
        ),
      )
    );
  }

  List<Widget> getDayWidgets(int dayNum){
    List<Widget> widgets = [];
    DateTime? startDate = widget.trip.startDate;
    DateTime? date = startDate?.add(Duration(days: dayNum - 1));
    List<TripPoint> points = [];
    for(TripPoint vo in widget.trip.points ?? []){
      if(vo.tripDay == dayNum && vo.orderNum != null){
        points.add(vo);
      }
    }
    points.sort((a, b){
      if(a.orderNum! <= b.orderNum!){
        return -1;
      }
      return 1;
    });
    List<Widget> pois = [];
    for(int i = 0; i < points.length; ++i){
      TripPoint point = points[i];
      pois.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                point.type == PoiType.hotel.getNum() ?
                tripIconHotel :
                point.type == PoiType.restaurant.getNum() ?
                tripIconRestaurant :
                point.type == PoiType.scenic.getNum() ?
                tripIconScenic :
                tripIconDefault,
                i < points.length - 1 ?
                Container(
                  height: 20,
                  width: 4,
                  color: const Color.fromRGBO(0x04, 0xb6, 0xdd, 1),
                ) :
                const SizedBox()
              ],
            ),
            const SizedBox(width: 10,),
            Text(point.name ?? '', style: const TextStyle(color: Colors.grey),),
          ],
        )
      );
    }
    widgets.add(
      SizedBox(
        height: 260,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 210,
              width: COVER_WIDTH - 20,
              child: Column(
                children: [
                  Text('DAY $dayNum', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 4,),
                  date == null ?
                  const SizedBox() :
                  Text('(${DateTimeUtil.toFormat(date, 'yyyy.MM.dd')})',),
                  pois.isEmpty ?
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('自由活动', style: TextStyle(color: ThemeUtil.foregroundColor),)
                    ],
                  ):
                  Expanded(
                    child: ListView(
                      physics: const ClampingScrollPhysics(),
                      shrinkWrap: true,
                      children: pois,
                    ),
                  ),
                ]
              ),
            )
          ],
        ),
      )
    );
    return widgets;
  }
}
