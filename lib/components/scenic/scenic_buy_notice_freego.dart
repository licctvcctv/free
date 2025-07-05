
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:freego_flutter/components/scenic/scenic_common.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/util/theme_util.dart';

class ScenicBuyNoticePage extends StatelessWidget{
  
  final String? scenicName;
  final String? bookNotice;
  final String? refundChangeRule;
  final String? costDescription;
  final String? useDescription;
  final String? otherDescription;

  const ScenicBuyNoticePage({this.scenicName, this.bookNotice, this.refundChangeRule, this.costDescription, this.useDescription, this.otherDescription, super.key});
  
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
      body: ScenicBuyNoticeWidget(bookNotice: bookNotice, refundChangeRule: refundChangeRule, costDescription: costDescription, useDescription: useDescription, otherDescription: otherDescription,),
    );
  }

}

class ScenicBuyNoticeWidget extends StatefulWidget{
  final String? scenicName;
  final String? bookNotice;
  final String? refundChangeRule;
  final String? costDescription;
  final String? useDescription;
  final String? otherDescription;
  const ScenicBuyNoticeWidget({this.scenicName, this.bookNotice, this.refundChangeRule, this.costDescription, this.useDescription, this.otherDescription, super.key});

  @override
  State<StatefulWidget> createState() {
    return ScenicBuyNoticeState();
  }

}

class ScenicBuyNoticeState extends State<ScenicBuyNoticeWidget>{
  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeUtil.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonHeader(
            center: Text(widget.scenicName ?? '', style: const TextStyle(color: Colors.white, fontSize: 18),),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              physics: const ClampingScrollPhysics(),
              children: [
                getBookNotickWidget(),
                getRefundChangeRuleWidget(),
                getCostDescriptionWidget(),
                getUseDescriptionWidget(),
                getOtherDescriptionWidget(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget getOtherDescriptionWidget(){
    String? otherDescription = widget.otherDescription;
    if(otherDescription == null || otherDescription.isEmpty){
      return const SizedBox();
    }
    dynamic noticeMap = [];
    try{
      noticeMap = json.decoder.convert(otherDescription);
    }
    catch(e){
      return const SizedBox();
    }
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
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('其他说明', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
          const SizedBox(height: 10,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widgets,
          )
        ],
      ),
    );
  }

  Widget getUseDescriptionWidget(){
    String? useDescription = widget.useDescription;
    if(useDescription == null || useDescription.isEmpty){
      return const SizedBox();
    }
    dynamic noticeMap = [];
    try{
      noticeMap = json.decoder.convert(useDescription);
    }
    catch(e){
      return const SizedBox();
    }
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
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('使用说明', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
          const SizedBox(height: 10,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widgets,
          )
        ],
      ),
    );
  }

  Widget getCostDescriptionWidget(){
    String? costDescription = widget.costDescription;
    if(costDescription == null || costDescription.isEmpty){
      return const SizedBox();
    }
    dynamic noticeMap = [];
    try{
      noticeMap = json.decoder.convert(costDescription);
    }
    catch(e){
      return const SizedBox();
    }
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
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('费用说明', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
          const SizedBox(height: 10,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widgets,
          )
        ],
      ),
    );
  }

  Widget getRefundChangeRuleWidget(){
    String? refundChangeRule = widget.refundChangeRule;
    if(refundChangeRule == null || refundChangeRule.isEmpty){
      return const SizedBox();
    }
    dynamic noticeMap = [];
    try{
      noticeMap = json.decoder.convert(refundChangeRule);
    }
    catch(e){
      return const SizedBox();
    }
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
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('退改说明', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
          const SizedBox(height: 10,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widgets,
          )
        ],
      ),
    );
  }

  Widget getBookNotickWidget(){
    String? bookNotice = widget.bookNotice;
    if(bookNotice == null || bookNotice.isEmpty){
      return const SizedBox();
    }
    dynamic noticeMap = [];
    try{
      noticeMap = json.decoder.convert(bookNotice);
    }
    catch(e){
      return const SizedBox();
    }
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
          const Text('预订说明', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
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