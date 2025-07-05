
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:freego_flutter/components/travel/travel_common.dart';
import 'package:freego_flutter/components/view/common_header.dart';
//import 'package:freego_flutter/model/travel.dart';
import 'package:freego_flutter/util/theme_util.dart';

class TravelDescPage extends StatelessWidget{
  final Travel travel;
  const TravelDescPage(this.travel, {super.key});
  
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
      body: TravelDescWidget(travel),
    );
  }
}

class TravelDescWidget extends StatefulWidget{
  final Travel travel;
  const TravelDescWidget(this.travel, {super.key});

  @override
  State<StatefulWidget> createState() {
    return TravelDescState();
  }

}

class TravelDescState extends State<TravelDescWidget>{
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeUtil.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonHeader(
            center: Text(widget.travel.name ?? '', style: const TextStyle(color: Colors.white, fontSize: 18),),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              physics: const ClampingScrollPhysics(),
              children: [
                getDetailWidget()
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget getDetailWidget(){
    Travel travel = widget.travel;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 7),
            child: Text('行程介绍', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
          ),
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Column(
              children: [
                Container(
                  child: SingleChildScrollView(
                    child: HtmlWidget(travel.description ?? ''),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}