
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:freego_flutter/components/travel/travel_common.dart';
import 'package:freego_flutter/components/view/common_header.dart';
//import 'package:freego_flutter/model/travel.dart';
import 'package:freego_flutter/util/theme_util.dart';

class TravelNoticePage extends StatelessWidget{
  final Travel travel;
  const TravelNoticePage(this.travel, {super.key});

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
      body: TravelNoticeWidget(travel),
    );
  }

}

class TravelNoticeWidget extends StatefulWidget{
  final Travel travel;
  const TravelNoticeWidget(this.travel, {super.key});

  @override
  State<StatefulWidget> createState() {
    return TravelNoticeState();
  }

}

class TravelNoticeState extends State<TravelNoticeWidget>{
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
                getBookNoticeWidget()
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget getBookNoticeWidget(){
    Travel travel = widget.travel;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(16))
            ),
            clipBehavior: Clip.hardEdge,
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 7),
                  child: Text('预订须知', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
                ),
                Html(
                  data: '<html>${travel.bookNotice}</html>',
                  style: {
                    'html': Style(
                      fontSize: FontSize(15),
                      lineHeight: LineHeight.number(1.5)
                    )
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
    /*return Container(
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
            child: Text('预订须知', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
          ),
          Html(
            data: '${travel.bookNotice}',
            shrinkWrap: true,
            style: {
              'html': Style(
                fontSize: FontSize(14),
                lineHeight: LineHeight.number(1.5)
              ),
            },
          )
        ],
      ),
    );*/
  }
}