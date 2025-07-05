
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/circle_neo/create/circle_shop_http.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/common_locate.dart';
import 'package:freego_flutter/components/view/image_input.dart';
import 'package:freego_flutter/model/map_poi.dart';
import 'package:freego_flutter/util/regular_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';

class CircleShopCreatePage extends StatelessWidget{
  const CircleShopCreatePage({super.key});

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
        child: const CircleShopCreateWidget(),
      ),
    );
  }

}

class CircleShopCreateWidget extends StatefulWidget{
  const CircleShopCreateWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return CircleShopCreateState();
  }

}

class CircleShopCreateState extends State<CircleShopCreateWidget>{

  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  TimeOfDay? openTime;
  TimeOfDay? closeTime;
  String? phone;
  TextEditingController phoneController = TextEditingController();

  List<int> openWeekDays = [];

  List<String> picList = [];

  String? userCity;
  String? userAddress;
  double? userLatitude;
  double? userLongitude;

  final AMapFlutterLocation amapLocation = AMapFlutterLocation();

  @override
  void dispose(){
    titleController.dispose();
    contentController.dispose();
    phoneController.dispose();
    amapLocation.destroy();
    super.dispose();
  }

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
    if(userCity == null || userAddress == null || userLatitude == null || userLongitude == null){
      ToastUtil.warn('请选择我的位置');
      return;
    }
    bool result = await CircleShopHttp().create(
      title: title, 
      content: content, 
      picList: picList,
      openTime: openTime?.format(context),
      closeTime: closeTime?.format(context),
      openDays: openWeekDays.isEmpty ? null : getWeekDaysStr(openWeekDays),
      phone: phone,
      userCity: userCity,
      userAddress: userAddress,
      userLatitude: userLatitude,
      userLongitude: userLongitude
    );
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
            center: Text('发现店家', style: TextStyle(color: Colors.white, fontSize: 18),),
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
                        child: getOpenTimeWidget(),
                      ),
                      Positioned(
                        top: 60,
                        child: getCloseTimeWidget(),
                      ),
                      Positioned(
                        top: 120,
                        child: getWeekDayWidget(),
                      ),
                      Positioned(
                        top: 180,
                        child: getPhoneWidget(),
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

  Widget getPhoneWidget(){
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero
      ),
      onPressed: () async{
        phoneController.text = phone ?? '';
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
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(16))
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('联系电话', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
                        const SizedBox(height: 20,),
                        Container(
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
                            controller: phoneController,
                          ),
                        ),
                        const SizedBox(height: 20,),
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
                                String phone = phoneController.text.trim();
                                if(phone.isEmpty){
                                  Navigator.of(context).pop();
                                  return;
                                }
                                if(!RegularUtil.checkPhone(phone) && !RegularUtil.checkFixedPhone(phone)){
                                  ToastUtil.warn('请输入正确的电话号码');
                                  return;
                                }
                                Navigator.of(context).pop(phone);
                              },
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                                decoration: const BoxDecoration(
                                  color: ThemeUtil.buttonColor,
                                  borderRadius: BorderRadius.all(Radius.circular(12))
                                ),
                                alignment: Alignment.center,
                                child: const Text('O K', style: TextStyle(color: Colors.white),),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  )
                )
              ],
            );
          },
        );
        if(result is String){
          if(result.isNotEmpty){
            phone = result;
            if(mounted && context.mounted){
              setState(() {
              });
            }
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
            phone == null ?
            const Text('联系电话', style: TextStyle(color: Colors.grey, fontSize: 18),) :
            Text(phone!, style: const TextStyle(color: ThemeUtil.foregroundColor),),
            const Expanded(child: SizedBox()),
            const Icon(Icons.play_arrow_rounded, color: Colors.grey, size: 32,)
          ],
        ),
      ),
    );
  }

  Widget getWeekDayWidget(){
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero
      ),
      onPressed: () async{
        dynamic result = await pickWeekDay();
        if(result is List<int>){
          openWeekDays = result;
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
            openWeekDays.isEmpty?
            const Text('营业日期', style: TextStyle(color: Colors.grey, fontSize: 18),) :
            Text(getWeekDaysStr(openWeekDays), style: const TextStyle(color: ThemeUtil.foregroundColor),),
            const Expanded(child: SizedBox()),
            const Icon(Icons.play_arrow_rounded, color: Colors.grey, size: 32,)
          ],
        ),
      ),
    );
  }

  String getWeekDaysStr(List<int> weekDays){
    weekDays.sort();
    String result = '周';
    if(weekDays.isNotEmpty){
      result += (WeekDayPickState.texts[weekDays.first]);
    }
    for(int i = 1; i < weekDays.length; ++i){
      result += ',';
      result += (WeekDayPickState.texts[weekDays[i]]);
    }
    return result;
  }

  Future<dynamic> pickWeekDay() async{
    return await showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: Colors.transparent,
              child: WeekDayPickWidget(initWeekDays: openWeekDays,),
            )
          ],
        );
      },
    );
  }

  Widget getCloseTimeWidget(){
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero
      ),
      onPressed: () async{
        TimeOfDay? time = await showTimePicker(
          context: context, 
          initialTime: closeTime ?? const TimeOfDay(hour: 20, minute: 0),
          initialEntryMode: TimePickerEntryMode.inputOnly,
          helpText: '',
          hourLabelText: '',
          minuteLabelText: ''
        );
        if(time != null){
          closeTime = time;
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
            closeTime == null ?
            const Text('结束营业时间', style: TextStyle(color: Colors.grey, fontSize: 18),) :
            Text(closeTime!.format(context), style: const TextStyle(color: ThemeUtil.foregroundColor),),
            const Expanded(child: SizedBox()),
            const Icon(Icons.play_arrow_rounded, color: Colors.grey, size: 32,)
          ],
        ),
      ),
    );
  }

  Widget getOpenTimeWidget(){
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero
      ),
      onPressed: () async{
        TimeOfDay? time = await showTimePicker(
          context: context, 
          initialTime: openTime ?? const TimeOfDay(hour: 8, minute: 0),
          initialEntryMode: TimePickerEntryMode.inputOnly,
          helpText: '',
          hourLabelText: '',
          minuteLabelText: ''
        );
        if(time != null){
          openTime = time;
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
            openTime == null ?
            const Text('开始营业时间', style: TextStyle(color: Colors.grey, fontSize: 18),) :
            Text(openTime!.format(context), style: const TextStyle(color: ThemeUtil.foregroundColor),),
            const Expanded(child: SizedBox()),
            const Icon(Icons.play_arrow_rounded, color: Colors.grey, size: 32,)
          ],
        ),
      ),
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
              hintText: '        能具体描述一下吗？',
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
              hintText: '        你发现了什么？',
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

class WeekDayPickWidget extends StatefulWidget{
  final List<int>? initWeekDays;
  const WeekDayPickWidget({this.initWeekDays, super.key});

  @override
  State<StatefulWidget> createState() {
    return WeekDayPickState();
  }

}

class WeekDayPickState extends State<WeekDayPickWidget>{

  static const List<String> texts = ['日', '一', '二', '三', '四', '五', '六'];

  late List<int> result;

  @override
  void initState(){
    super.initState();
    result = widget.initWeekDays ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16))
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('选择营业日', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
          const SizedBox(height: 20,),
          getWeekDayWidget(),
          const SizedBox(height: 20,),
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
                  Navigator.of(context).pop(result);
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  decoration: const BoxDecoration(
                    color: ThemeUtil.buttonColor,
                    borderRadius: BorderRadius.all(Radius.circular(12))
                  ),
                  alignment: Alignment.center,
                  child: const Text('O K', style: TextStyle(color: Colors.white),),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget getWeekDayWidget(){
    double width = MediaQuery.of(context).size.width;
    double cellWidth = (width - 32) / 7;
    List<Widget> widgets = [];
    for(int i = 0; i < 7; ++i){
      widgets.add(
        TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap
          ),
          onPressed: (){
            if(result.contains(i)){
              result.remove(i);
            }
            else{
              result.add(i);
            }
            setState(() {
            });
          },
          child: Container(
            width: cellWidth,
            height: cellWidth,
            alignment: Alignment.center,
            color: result.contains(i) ? ThemeUtil.buttonColor : ThemeUtil.backgroundColor,
            child: Text(texts[i], style: const TextStyle(color: ThemeUtil.foregroundColor),),
          ),
        )
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: widgets,
    );
  }
}
