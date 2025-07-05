import 'dart:async';
import 'dart:ui';

import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freego_flutter/data/city.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:permission_handler/permission_handler.dart';


class CityPage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent
    ));
    return Scaffold(
        extendBodyBehindAppBar: true,
        body: CityWidget()
    );
  }
}

class CityWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {

    // TODO: implement createState
    return CityState();
  }
}
class CityState extends ConsumerState{

  String? keyword;

  String? locationCity;

  Map<String,GlobalKey> widgetKes = {};
  GlobalKey scrollViewKey= new GlobalKey();
  ScrollController scrollController = new ScrollController();

  Map<String,List<String>> citySet={};
  onScreenTap()
  {
    //nameFocusNode.unfocus();
    //identityFocusNode.unfocus();
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }


  @override
  Widget build(BuildContext context) {

    var statusHeight = MediaQuery.of(context).viewPadding.top;

    return GestureDetector(

      child:Container(

        decoration: BoxDecoration(color: Color.fromRGBO(242,245,250,1)),
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(0),
        child:Stack(
        children: [
            Column(
               children: [
                 SizedBox(height: statusHeight+10,),
                 Container(
                   height: 50,
                   padding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                   decoration: BoxDecoration(
                       color: Color.fromRGBO(203,211,220,1)
                   ),
                   child: Row(
                     children:
                     [
                       IconButton(onPressed: (){
                         Navigator.pop(context);
                       }, icon: Icon(Icons.arrow_back_ios_new,color: Colors.white,)),
                       SizedBox(width: 10,),
                       Expanded(child:
                       Container(
                           decoration: BoxDecoration(
                               color: Color.fromRGBO(238, 240, 242, 1),
                               borderRadius: BorderRadius.all(Radius.circular(16))

                           ),
                           child:Row(
                             mainAxisAlignment: MainAxisAlignment.start,
                             children: [
                               Expanded(child: TextField(
                                 onSubmitted:(value){
                                    keyword = value;
                                    searchCity();
                                 },
                                 onChanged: (value){
                                    keyword = value;
                                 },
                                 decoration: InputDecoration(
                                   isDense:true,
                                   hintText: '请输入城市名或拼音',
                                   contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                   border: OutlineInputBorder(
                                       borderRadius: BorderRadius.circular(15),
                                       borderSide: BorderSide.none),
                                 ),
                                )
                               ),
                               GestureDetector(
                                 onTap: (){
                                    searchCity();
                                 },
                                 child:Container(
                                   height: double.infinity,
                                   decoration: BoxDecoration(
                                       borderRadius: BorderRadius.horizontal(left: Radius.zero,right: Radius.circular(16)),
                                       color: Colors.white
                                   ),
                                //   padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                                   width: 40,
                                   child:Icon(Icons.search,color: Colors.grey,)
                                )
                               )
                             ],)


                       )
                       ),
                       SizedBox(width: 10,),
                     ],

                   ),

                 ),
                 SizedBox(height: 10,),
                 Container(
                   padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                   width: double.infinity,
                   child: Text('当前位置'),
                 ),
                 SizedBox(height: 10,),
                 Container(
                    width: double.infinity,
                   padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    alignment: Alignment.centerLeft,
                    child:OutlinedButton(onPressed: (){
                            if(locationCity!=null)
                              {
                                 chooseCity(locationCity!);
                              }
                         },
                        child: locationCity!=null?Text(locationCity!):SizedBox(child:CircularProgressIndicator(),width: 20,height: 20,)
                    ),
                 ),

                 SizedBox(height: 10,),
                 Container(
                   padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                   width: double.infinity,
                   child: Text('推荐城市'),
                 ),
                 Wrap(
                   children: getRecomendCityViews((MediaQuery.of(context).size.width-20)/4),

                 ),
                 Expanded(
                  flex:1,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child:
                    Stack(

                      children: [
                          SingleChildScrollView(
                             key: scrollViewKey,
                             controller: scrollController,
                             child:Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: getAllCityViews(),
                            )
                         ),

                        Positioned(
                            right: 10,
                            top:40,
                            bottom: 10,
                            child: getAlphabetsViews()
                        )


                      ],

                    )
                  )

                  )

               ],
            )

            ,

        ]
        )
      )

      //color: Color.fromRGBO(242,245,250,1),
    );
  }


  @override
  void initState() {
    searchCity();
    locate();
  }
  locate() async
  {

    if (await Permission.location.request().isGranted) {
       ToastUtil.hint("已获取定位权限");
  // Either the permission was already granted before or the user just granted it.
    }
    else
    {
        return;
    }

    final AMapFlutterLocation amapLocation = AMapFlutterLocation();
    amapLocation.onLocationChanged().listen((Map<String, Object> result) {
      print("定位成功");
      locationCity = result['city'].toString();
      setState(() {

      });
      ///result即为定位结果
      amapLocation.stopLocation();
    });
    amapLocation.startLocation();
  }
  getAlphabetsViews()
  {

    List<String> keys = citySet.keys.toList();
    keys.sort((a,b)=>a.compareTo(b));

    var listViews =<Widget>[];

    return Container(
        height: double.infinity,
        width: 20,
        alignment: Alignment.center,
        child: ListView.builder(itemBuilder: (context,index){
          if(index>=keys.length)
            {
              return null;
            }
          return GestureDetector(
              onTap: (){
                alphabetChoose(keys[index]);
              },
              child:Container(
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
                child:Text(keys[index])
         ));
      },scrollDirection: Axis.vertical)
    );
    /*
    for(var i = 0;i < keys.length;i++)
    {
        listViews.add(Text(keys[i]));
    }

    return Container(
        child:Column(
          children: listViews,
        )
    );*/
  }

  List<String> getRecommendCities()
  {
     return ['北京','上海','成都','深圳','广州','杭州','西安','昆明'];
  }

  getRecomendCityViews(double width)
  {

    var views = <Widget>[];

    var cityList = getRecommendCities();

    for(var i =0; i<cityList.length;i++)
      {
         var name = cityList[i];
         views.add(
             Container(
               width: (MediaQuery.of(context).size.width-20)/4,
               child: GestureDetector(
                   onTap: (){
                       chooseCity(name);
                   },
                   child:Container(
                     alignment: Alignment.center,
                     width: double.infinity,
                     decoration: BoxDecoration(
                       color: Colors.white,
                       borderRadius: BorderRadius.circular(4)
                     ),
                     padding: EdgeInsets.fromLTRB(0,5,0,5),
                     child: Text(name),
               )),
               padding: EdgeInsets.fromLTRB(10,6,6,10),
               alignment: Alignment.center,
             )
         );
      }
    return views;
  }
  chooseCity(String name)
  {
      Navigator.pop(context,name);
  }

  alphabetChoose(String alp)
  {
    // print(88888);
      var renderBox = widgetKes[alp]!.currentContext?.findRenderObject() as RenderBox;
      final Offset offset = renderBox.localToGlobal(Offset.zero);

      var scrollBox =  scrollViewKey.currentContext?.findRenderObject() as RenderBox;
      final Offset scrollOffset = scrollBox.localToGlobal(Offset.zero);

      var childY = offset.dy;
      var parentY = scrollOffset.dy;

      scrollController.jumpTo(childY-parentY+scrollController.offset);

  }

  searchCity()
  {
    citySet = City.getAlphabetWithCities(keyword);
    setState(() {

    });
  }


  getAllCityViews()
  {
    var viewList = <Widget>[];

    List<String> keys = citySet.keys.toList();
    keys.sort((a,b)=>a.compareTo(b));
    for(var i =0;i<keys.length;i++)
    {

        widgetKes[keys[i]] = GlobalKey();
        var container = Container(
            width: double.infinity,
            alignment: Alignment.centerLeft,
            child:Column(
                children: [
                   Container(
                     key: widgetKes[keys[i]],
                     padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                     child: Text(keys[i]),
                     width: double.infinity,
                   ),
                   Container(
                     width: double.infinity,
                     color: Colors.white,
                     padding:EdgeInsets.fromLTRB(10, 0, 10, 0),

                     child: Container(
                          width: double.infinity,
                          color: Colors.grey.withOpacity(0.1),
                          child:Column(
                          children: getCityViews(citySet[keys[i]!]!,
                        )
                       )
                     ),
                   )
                ],
            )
        );
        viewList.add(container);
    }
    return viewList;
  }
  getCityViews(List<String> cityList)
  {
    var views = <Widget>[];

    for(var i =0; i<cityList.length;i++)
    {
      var name = cityList[i];

      views.add(
           Container(
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                      color: Colors.white,
                  ),
                  padding: EdgeInsets.fromLTRB(0,8,0,8),
                  child: GestureDetector(
                    onTap: (){
                       chooseCity(name);
                    },
                    child: Container(
                      padding: EdgeInsets.fromLTRB(0, 6,100, 6),
                      child:Text(name)
                   )
                  )
                 ,
                )
      );
      if(i!=cityList.length-1)
        {
           views.add(SizedBox(height: 1,));
        }
    }
    return views;
  }
}
