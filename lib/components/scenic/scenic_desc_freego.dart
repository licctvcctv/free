
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:freego_flutter/components/scenic/scenic_common.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/util/theme_util.dart';

class ScenicDescPage extends StatelessWidget{
  final Scenic scenic;
  const ScenicDescPage(this.scenic, {super.key});
  
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
      body: ScenicDescWidget(scenic),
    );
  }
}

class ScenicDescWidget extends StatefulWidget{
  final Scenic scenic;
  const ScenicDescWidget(this.scenic, {super.key});

  @override
  State<StatefulWidget> createState() {
    return ScenicDescState();
  }

}

class ScenicDescState extends State<ScenicDescWidget>{
  
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
                getDetailWidget()
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget getDetailWidget(){
    Scenic scenic = widget.scenic;
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
            child: Text('景点介绍', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
          ),
          Html(
            data: '${scenic.description}',
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
    );
  }
}