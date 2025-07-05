
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/circle_neo/create/circle_activity_http.dart';
import 'package:freego_flutter/components/trip/trip_common.dart';
import 'package:freego_flutter/components/trip/trip_create.dart';
import 'package:freego_flutter/components/trip/trip_http.dart';
import 'package:freego_flutter/components/trip/trip_show.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/common_locate.dart';
import 'package:freego_flutter/components/view/date_choose_view.dart';
import 'package:freego_flutter/components/view/image_input.dart';
import 'package:freego_flutter/components/view/notify_loading.dart';
import 'package:freego_flutter/model/map_poi.dart';
import 'package:freego_flutter/util/date_choose_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:intl/intl.dart';

class CircleActivityCreatePage extends StatelessWidget{
  const CircleActivityCreatePage({super.key});

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
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: const CircleActivityCreateWidget(),
      ),
    );
  }

}

class CircleActivityCreateWidget extends StatefulWidget{
  const CircleActivityCreateWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return CircleActivityCreateState();
  }

}

class CircleActivityCreateState extends State<CircleActivityCreateWidget>{

  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  Trip? trip;
  double? startLatitude;
  double? startLongitude;
  String? startAddress;

  DateTime? startTime;
  int? expectMin;
  int? expectMax;

  TextEditingController numberMinController = TextEditingController();
  TextEditingController numberMaxController = TextEditingController();

  List<String> picList = [];

  List<Trip> tripList = [];

  String? userCity;
  String? userAddress;
  double? userLatitude;
  double? userLongitude;

  final AMapFlutterLocation amapLocation = AMapFlutterLocation();

  @override
  void initState(){
    super.initState();
    startLocation();
  }

  void startLocation() async{
    amapLocation.onLocationChanged().listen((event) {
      if(event['city'] is String){
        userCity = event['city'].toString();
      }
      if(event['address'] is String){
        userAddress = event['address'].toString();
      }
      var latitude = event['latitude'];
      if(latitude is String){
        latitude = double.tryParse(latitude);
      }
      var longitude = event['longitude'];
      if(longitude is String){
        longitude = double.tryParse(longitude);
      }
      if(latitude is double && longitude is double){
        userLatitude = latitude;
        userLongitude = longitude;
      }
      if(userCity != null && userAddress != null && userLatitude != null && userLongitude != null){
        if(mounted && context.mounted){
          setState(() {
          });
        }
        amapLocation.stopLocation();
      }
    });
    amapLocation.startLocation();
  }

  @override
  void dispose(){
    titleController.dispose();
    contentController.dispose();
    numberMaxController.dispose();
    numberMinController.dispose();
    amapLocation.destroy();
    super.dispose();
  }

  Future submit() async{
    String title = titleController.text.trim();
    if(title.isEmpty){
      ToastUtil.warn('请输入标题');
      return;
    }
    String content = contentController.text.trim();
    if(content.isEmpty){
      ToastUtil.warn('请输入内容');
      return;
    }
    if(trip == null){
      ToastUtil.warn('请选择行程');
      return;
    }
    if(trip?.id == null){
      ToastUtil.warn('行程数据错误');
      return;
    }
    if(startLatitude == null || startLongitude == null || startAddress == null){
      ToastUtil.warn('请选择出发位置');
      return;
    }
    if(startTime == null){
      ToastUtil.warn('请选择出发时间');
      return;
    }
    if(expectMin == null || expectMax == null){
      ToastUtil.warn('请选择结伴人数');
      return;
    }
    if(userCity == null || userAddress == null || userLatitude == null || userLongitude == null){
      ToastUtil.warn('请选择我的位置');
      return;
    }
    bool result = await CircleActivityHttp().create(
      title: title, 
      content: content, 
      tripId: trip!.id!, 
      startLatitude: startLatitude!, 
      startLongitude: startLongitude!, 
      startAddress: startAddress!, 
      startTime: startTime!, 
      expectMin: expectMin!, 
      expectMax: expectMax!, 
      picList: picList,
      userCity: userCity,
      userAddress: userAddress,
      userLatitude: userLatitude,
      userLongitude: userLongitude);
    if(!result){
      ToastUtil.error('发布失败');
      return;
    }
    ToastUtil.hint('发布成功');
    Future.delayed(const Duration(seconds: 3), (){
      if(mounted && context.mounted){
        Navigator.of(context).pop(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeUtil.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonHeader(
            center: Text('寻找驴友', style: TextStyle(color: Colors.white, fontSize: 18),),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              physics: const ClampingScrollPhysics(),
              children: [
                const SizedBox(height: 10,),
                Container(
                  padding: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(0xfc, 0xfd, 0xfe, 1),
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      getTitleWidget(),
                      getContentWidget(),
                    ],
                  ),
                ),
                const SizedBox(height: 10,),
                SizedBox(
                  height: 240,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        child: getRouteWidget(),
                      ),
                      Positioned(
                        top: 60,
                        child: getStartWidget(),
                      ),
                      Positioned(
                        top: 120,
                        child: getTimeWidget(),
                      ),
                      Positioned(
                        top: 180,
                        child: getNumberWidget(),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 10,),
                ImageInputWidget(
                  onChange: (valList){
                    picList = valList;
                  },
                ),
                const SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: getUserLocationWidget(),
                    ),
                    const SizedBox(width: 15,),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap
                      ),
                      onPressed: submit,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: ThemeUtil.buttonColor,
                          borderRadius: BorderRadius.horizontal(left: Radius.circular(40))
                        ),
                        width: 104,
                        height: 56,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.post_add_outlined, color: Colors.white,),
                            Text('发 表', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),)
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 40,),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget getUserLocationWidget(){
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero
      ),
      onPressed: () async{
        dynamic result = await Navigator.of(context).push(MaterialPageRoute(builder: (context){
          return CommonLocatePage(initLat: userLatitude, initLng: userLongitude,);
        }));
        if(result is MapPoiModel){
          userLatitude = result.lat;
          userLongitude = result.lng;
          userCity = result.city;
          userAddress = result.name;
          if(mounted && context.mounted){
            setState(() {
            });
          }
        }
      },
      child: Container(
        height: 60,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(left: 24, right: 24),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0xee, 0xee, 0xee, 1),
              offset: Offset(0, -2),
              blurRadius: 2
            ),
            BoxShadow(
              color: Color.fromRGBO(0xee, 0xee, 0xee, 1),
              offset: Offset(0, 2),
              blurRadius: 2
            ),
          ]
        ),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            userAddress == null ?
            const Text('我的位置', style: TextStyle(color: Colors.grey, fontSize: 18),):
            Text('我在：$userCity $userAddress', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 18, fontWeight: FontWeight.bold),),
            if(userAddress == null)
            const Icon(Icons.play_arrow_rounded, color: Colors.grey, size: 32,)
          ],
        ),
      ),
    );
  }

  Widget getNumberWidget(){
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero
      ),
      onPressed: () async{
        dynamic result = await pickNumber();
        if(result is Map){
          dynamic numberMin = result['min'];
          dynamic numberMax = result['max'];
          if(numberMin is int){
            expectMin = numberMin;
          }
          if(numberMax is int){
            expectMax = numberMax;
          }
          if(expectMax is int && expectMax is int){
            if((expectMin as int) > (expectMax as int)){
              expectMax = expectMin;
            }
          }
          if(mounted && context.mounted){
            setState(() {
            });
          }
        }
      },
      child: Container(
        height: 60,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(left: 24, right: 24),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0xee, 0xee, 0xee, 1),
              offset: Offset(0, -2),
              blurRadius: 2
            ),
            BoxShadow(
              color: Color.fromRGBO(0xee, 0xee, 0xee, 1),
              offset: Offset(0, 2),
              blurRadius: 2
            ),
          ]
        ),
        child: Row(
          children: [
            expectMin == null || expectMax == null ?
            const Text('希望人数', style: TextStyle(color: Colors.grey, fontSize: 18),):
            expectMin == expectMax ?
            Text('人数：$expectMin 人'):
            Text('人数：$expectMin ~ $expectMax 人'),
            const Expanded(child: SizedBox()),
            const Icon(Icons.play_arrow_rounded, color: Colors.grey, size: 32,)
          ],
        ),
      ),
    );
  }

  Future<dynamic> pickNumber() async{
    numberMinController.text = expectMin?.toString() ?? '';
    numberMaxController.text = expectMax?.toString() ?? '';
    dynamic result = await showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder:(context, animation, secondaryAnimation) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: Colors.transparent,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(16))
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const SizedBox(
                          width: 80,
                          child: Text('人数', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
                        ),
                        const Expanded(child: SizedBox()),
                        Container(
                          width: 80,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4
                              )
                            ]
                          ),
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: '',
                              hintStyle: TextStyle(color: Colors.grey),
                              isDense: true,
                              contentPadding: EdgeInsets.fromLTRB(8, 10, 8, 10),
                              border: InputBorder.none,
                            ),
                            keyboardType: TextInputType.number,
                            controller: numberMinController,
                          ),
                        ),
                        const Text('  ~  ', style: TextStyle(color: ThemeUtil.foregroundColor),),
                        Container(
                          width: 80,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4
                              )
                            ]
                          ),
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: '',
                              hintStyle: TextStyle(color: Colors.grey),
                              isDense: true,
                              contentPadding: EdgeInsets.fromLTRB(8, 10, 8, 10),
                              border: InputBorder.none,
                            ),
                            keyboardType: TextInputType.number,
                            controller: numberMaxController,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: (){
                            int? numberMin = int.tryParse(numberMinController.text);
                            int? numberMax = int.tryParse(numberMaxController.text);
                            Map<String, int?> map = {};
                            map['min'] = numberMin;
                            map['max'] = numberMax;
                            Navigator.of(context).pop(map);
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                            decoration: const BoxDecoration(
                              color: ThemeUtil.buttonColor,
                              borderRadius: BorderRadius.all(Radius.circular(10))
                            ),
                            child: const Text('确 认', style: TextStyle(color: Colors.white),),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        );
      },
    );
    return result;
  }

  Widget getTimeWidget(){
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero
      ),
      onPressed: () async{
        DateTime firstDate = DateTime.now();
        firstDate = DateTime(firstDate.year, firstDate.month, firstDate.day + 1);
        DateChooseConfig config = DateChooseConfig(
          width: MediaQuery.of(context).size.width, 
          height: MediaQuery.of(context).size.width,
          chooseMode: DateChooseMode.single,
          firstDate: firstDate
        );
        List<DateTime>? result = await DateChooseUtil.chooseDate(context, config);
        if(result == null || result.isEmpty){
          return;
        }
        startTime = result.first;
        if(mounted && context.mounted){
          setState(() {
          });
        }
      },
      child: Container(
        height: 60,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(left: 24, right: 24),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0xee, 0xee, 0xee, 1),
              offset: Offset(0, -2),
              blurRadius: 2
            ),
            BoxShadow(
              color: Color.fromRGBO(0xee, 0xee, 0xee, 1),
              offset: Offset(0, 2),
              blurRadius: 2
            ),
          ]
        ),
        child: Row(
          children: [
            startTime == null ?
            const Text('结伴时间', style: TextStyle(color: Colors.grey, fontSize: 18),):
            Text('时间：${DateFormat('yyyy年MM月dd日').format(startTime!)}', style: const TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold),),
            const Expanded(child: SizedBox()),
            const Icon(Icons.play_arrow_rounded, color: Colors.grey, size: 32,)
          ],
        ),
      ),
    );
  }

  Widget getStartWidget(){
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero
      ),
      onPressed: () async{
        dynamic result = await Navigator.of(context).push(MaterialPageRoute(builder: (context){
          return CommonLocatePage(initLat: startLatitude, initLng: startLongitude,);
        }));
        if(result is MapPoiModel){
          startLatitude = result.lat;
          startLongitude = result.lng;
          startAddress = result.name;
          if(mounted && context.mounted){
            setState(() {
            });
          }
        }
      },
      child: Container(
        height: 60,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(left: 24, right: 24),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0xee, 0xee, 0xee, 1),
              offset: Offset(0, -2),
              blurRadius: 2
            ),
            BoxShadow(
              color: Color.fromRGBO(0xee, 0xee, 0xee, 1),
              offset: Offset(0, 2),
              blurRadius: 2
            ),
          ]
        ),
        child: Row(
          children: [
            startAddress == null ?
            const Text('出发位置', style: TextStyle(color: Colors.grey, fontSize: 18),):
            Text('起点：$startAddress', style: const TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold),),
            const Expanded(child: SizedBox()),
            const Icon(Icons.play_arrow_rounded, color: Colors.grey, size: 32,)
          ],
        ),
      ),
    );
  }

  Widget getRouteWidget(){
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero
      ),
      onPressed: () async{
        dynamic result = await pickTrip();
        if(result is Trip){
          trip = result;
          if(mounted && context.mounted){
            setState(() {
            });
          }
        }
      },
      child: Container(
        height: 60,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(left: 24, right: 24),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0xee, 0xee, 0xee, 1),
              offset: Offset(0, -2),
              blurRadius: 2
            ),
            BoxShadow(
              color: Color.fromRGBO(0xee, 0xee, 0xee, 1),
              offset: Offset(0, 2),
              blurRadius: 2
            ),
          ]
        ),
        child: Row(
          children: [
            trip == null? 
            const Text('选择路线', style: TextStyle(color: Colors.grey, fontSize: 18),):
            const Text('已选择', style: TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis,),
            const Expanded(child: SizedBox()),
            const Icon(Icons.play_arrow_rounded, color: Colors.grey, size: 32,)
          ],
        ),
      ),
    );
  }

  Future<dynamic> pickTrip() async{
    return await showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder:(context, animation, secondaryAnimation) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: Colors.transparent,
              child: TripChooseWidget(tripList),
            )
          ],
        );
      },
    );
  }

  Widget getContentWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 60,
          padding: const EdgeInsets.only(left: 40),
          alignment: Alignment.centerLeft,
          child: const Text('描述', style: TextStyle(color: Color.fromRGBO(0xc5, 0xc5, 0xc5, 1), fontSize: 18),),
        ),
        Container(
          height: 180,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(0xf3, 0xf3, 0xf3, 1),
            borderRadius: BorderRadius.circular(12)
          ),
          child: TextField(
            controller: contentController,
            decoration: const InputDecoration(
              hintText: '        你想怎么做？',
              hintStyle: TextStyle(color: Color.fromRGBO(0xc5, 0xc5, 0xc6, 1)),
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
            ),
            minLines: 1,
            maxLines: 9999,
          ),
        ),
      ],
    );
  }

  Widget getTitleWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 60,
          padding: const EdgeInsets.only(left: 40),
          alignment: Alignment.centerLeft,
          child: const Text('标题', style: TextStyle(color: Color.fromRGBO(0xc5, 0xc5, 0xc6, 1), fontSize: 18),),
        ),
        Container(
          height: 60,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(0xf3, 0xf3, 0xf3, 1),
            borderRadius: BorderRadius.circular(12)
          ),
          alignment: Alignment.centerLeft,
          child: TextField(
            controller: titleController,
            decoration: const InputDecoration(
              hintText: '        你想约人做什么？',
              hintStyle: TextStyle(color: Color.fromRGBO(0xc5, 0xc5, 0xc6, 1)),
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none
            ),
          ),
        ),
      ],
    );
  }
}

class TripChooseWidget extends StatefulWidget{
  final List<Trip>? initList;
  const TripChooseWidget(this.initList, {super.key});

  @override
  State<StatefulWidget> createState() {
    return TripChooseState();
  }

}

class TripChooseState extends State<TripChooseWidget>{

  bool inited = false;
  late List<Trip> tripList;

  ScrollController scrollController = ScrollController();
  bool onOperation = false;

  @override
  void dispose(){
    scrollController.dispose();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    tripList = widget.initList ?? [];
    if(tripList.isEmpty){
      Future.delayed(Duration.zero, () async{
        onOperation = true;
        List<Trip>? tmpList = await TripHttp.listByUser(timeStart: DateTime.now());
        if(tmpList != null){
          tripList = tmpList;
          if(mounted && context.mounted){
            setState(() {
            });
          }
        }
        inited = true;
        onOperation = false;
      });
    }
    else{
      inited = true;
    }
    scrollController.addListener(() async{ 
      if(onOperation){
        return;
      }
      onOperation = true;
      int? maxId;
      if(tripList.isNotEmpty){
        maxId = tripList.last.id;
      }
      List<Trip>? tmpList = await TripHttp.listByUser(maxId: maxId);
      if(tmpList != null){
        tripList.addAll(tmpList);
        if(mounted && context.mounted){
          setState(() {
          });
        }
      }
      onOperation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        !inited ?
        const NotifyLoadingWidget() :
        Container(
          width: size.width,
          height: size.width,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(16))
          ),
          padding: const EdgeInsets.all(16),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 10),
            children: getTripWidgets(),
          )
        ),
      ],
    );
  }

  List<Widget> getTripWidgets(){
    List<Widget> widgets = [];
    for(Trip trip in tripList){
      widgets.add(
        TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap
          ),
          onPressed: (){
            Navigator.of(context).pop(trip);
          },
          child: Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: ThemeUtil.foregroundColor))
            ),
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 9,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            Text(trip.startAddress ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor),),
                            const Text('  -  ', style: TextStyle(color: ThemeUtil.foregroundColor),),
                            Text(trip.endAddress ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor),)
                          ],
                        ),
                        const SizedBox(height: 10,),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            trip.startDate != null ?
                            Text(DateFormat('yyyy年MM月dd日').format(trip.startDate!), style: const TextStyle(color: Colors.grey)) :
                            const SizedBox(),
                            const Text('  -  ', style: TextStyle(color: ThemeUtil.foregroundColor),),
                            trip.endDate != null ?
                            Text(DateFormat('yyyy年MM月dd日').format(trip.endDate!), style: const TextStyle(color: Colors.grey)) :
                            const SizedBox(),
                          ],
                        )
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap
                        ),
                        onPressed: () async{
                          if(trip.id == null){
                            return;
                          }
                          TripVo? vo = await TripHttp.getTripById(id: trip.id!);
                          if(vo == null){
                            return;
                          }
                          if(mounted && context.mounted){
                            Navigator.of(context).push(MaterialPageRoute(builder: (context){
                              return TripShowPage(vo);
                            }));
                          }
                        },
                        child: const Center(
                          child: Icon(Icons.arrow_forward_ios_rounded, size: 32, color: ThemeUtil.foregroundColor,),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        )
      );
    }
    if(widgets.isEmpty){
      widgets.add(
        const Padding(
          padding: EdgeInsets.fromLTRB(0, 20, 12, 12),
          child: Text('您还没有行程~'),
        )
      );
    }
    widgets.add(
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 12, 0),
        child: InkWell(
          onTap: ()async {
            bool? result = await Navigator.of(context).push(MaterialPageRoute(builder: (context){
              return const TripCreatePage();
            }));
            if(result == true){
              onOperation = true;
              List<Trip>? tmpList = await TripHttp.listByUser(timeStart: DateTime.now());
              if(tmpList != null){
                tripList = tmpList;
                if(mounted && context.mounted){
                  setState(() {
                  });
                }
              }
              onOperation = false;
            }
          },
          child: Row(
            children: const [
              Text('去创建行程', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ThemeUtil.buttonColor),),
              Icon(Icons.arrow_forward, color: ThemeUtil.buttonColor)
            ],
          )
        ),
      )
    );
    return widgets;
  }
}
