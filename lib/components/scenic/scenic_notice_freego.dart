
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:freego_flutter/components/scenic/scenic_common.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/util/theme_util.dart';

class ScenicNoticePage extends StatelessWidget{
  final Scenic scenic;
  const ScenicNoticePage(this.scenic, {super.key});

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
      body: ScenicNoticeWidget(scenic),
    );
  }

}

class ScenicNoticeWidget extends StatefulWidget{
  final Scenic scenic;
  const ScenicNoticeWidget(this.scenic, {super.key});

  @override
  State<StatefulWidget> createState() {
    return ScenicNoticeState();
  }

}

class ScenicNoticeState extends State<ScenicNoticeWidget>{
  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeUtil.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonHeader(
            center: Text(widget.scenic.name ?? '', style: const TextStyle(color: Colors.white, fontSize: 18),),
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
    Scenic scenic = widget.scenic;
    if(scenic.bookNotice == null){
      return const SizedBox();
    }
    dynamic noticeMap = json.decoder.convert(scenic.bookNotice!);
    List<Widget> widgets = [];
    for(dynamic item in noticeMap){
      widgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item['name']),
            const SizedBox(height: 8,),
            Html(
              data: item['value'],
            )
          ],
        )
      );
      widgets.add(const SizedBox(height: 8,));
    }
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
            child: Text('预订须知', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
          ),
          const SizedBox(height: 10,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widgets,
          )
        ],
      ),
    );
  }
}