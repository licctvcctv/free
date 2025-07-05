

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';


import '../../model/travel.dart';


class TravelContentPage extends StatelessWidget{

  TravelModel travelModel;
  TravelContentPage(this.travelModel);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       // extendBodyBehindAppBar: true,
        body: TravelContentWidget(travelModel)

    );
  }
}

class TravelContentWidget extends ConsumerStatefulWidget {

  TravelModel travelModel;


  TravelContentWidget(this.travelModel);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    // TODO: implement createState
    return TravelContentState(travelModel);
  }
}
class TravelContentState extends ConsumerState{
  int menuIndex=0;

  TravelModel travelModel;

  TravelContentState(this.travelModel);


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var statusHeight = MediaQuery.of(context).viewPadding.top;
    return Container(
        
        decoration: BoxDecoration( color:Color.fromRGBO(242,245,250,1)),
        width: double.infinity,
        height: double.infinity,
        child:Stack(
          children: [
            Column(
              children: [
                SizedBox(height: statusHeight,),
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
                      Expanded(
                          child: Container(
                              width: double.infinity,
                              alignment: Alignment.center,
                              child: Text('介绍说明',style: TextStyle(color: Colors.white,fontSize:18),),
                           )
                      ),
                      SizedBox(width: 10,),
                      Container(child:Icon(Icons.more_horiz,color: Colors.white, size: 30,))
                    ],
                  ),
                ),
                Container(
                   
                   padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
                    child:Row(children: [
                      Expanded(
                        flex:1,
                        child:GestureDetector(
                          onTap: (){
                            // setStep(0);
                            setMenu(0);
                          },
                          child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.horizontal(left:Radius.circular(6)),
                                  color:menuIndex==0? Color.fromRGBO(4,182,221, 1): Colors.white
                              ),
                              padding: EdgeInsets.all(10),
                              child: Text('详细介绍',style: TextStyle( color:menuIndex==0?Colors.white: Colors.black),)
                          ),
                        )
                      ),
                      Expanded(
                        flex:1,
                        child: GestureDetector(
                          onTap: (){
                            // setStep(0);
                            setMenu(1);
                          },
                          child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.horizontal(right:Radius.circular(6)),
                                  color:menuIndex==1?Color.fromRGBO(4,182,221, 1): Colors.white
                              ),
                              padding: EdgeInsets.all(10),
                              child: Text('预订须知',style: TextStyle(  color:menuIndex==1?Colors.white: Colors.black,))
                          ),
                        )
                      )



                    ],)

                ),
                Expanded(
                    flex:1,
                    child: travelModel!=null?
                      IndexedStack(
                          index:menuIndex,
                          children: [
                             Container(
                               width: double.infinity,
                               color:Colors.white,
                               padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                               child:SingleChildScrollView(child:HtmlWidget(travelModel.description??'')),
                              // child: ,
                             ),
                             Container(
                               width: double.infinity,
                               height: double.infinity,
                               color:Colors.white,
                               padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                               child: HtmlWidget(travelModel.bookNotice??''),
                             )

                          ],

                      ):SizedBox()
                )
              ],
            ),

          ],
        )
    );
  }

  setMenu(int value)
  {
    menuIndex = value;
    setState(() {

    });
  }






  @override
  void initState() {
    // TODO: implement initState

  }





}
