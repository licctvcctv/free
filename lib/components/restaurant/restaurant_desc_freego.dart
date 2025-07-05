
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:freego_flutter/components/restaurant/restaurant_common.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/util/theme_util.dart';

class RestaurantDescPage extends StatelessWidget{
  final Restaurant restaurant;
  const RestaurantDescPage(this.restaurant, {super.key});
  
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
      body: RestaurantDescWidget(restaurant),
    );
  }
}

class RestaurantDescWidget extends StatefulWidget{
  final Restaurant restaurant;
  const RestaurantDescWidget(this.restaurant, {super.key});

  @override
  State<StatefulWidget> createState() {
    return RestaurantDescState();
  }

}

class RestaurantDescState extends State<RestaurantDescWidget>{
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeUtil.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonHeader(
            center: Text(widget.restaurant.name ?? '', style: const TextStyle(color: Colors.white, fontSize: 18),),
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
    Restaurant restaurant = widget.restaurant;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius:  BorderRadius.all(Radius.circular(16))
            ),
            clipBehavior: Clip.hardEdge,
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 7),
                  child: Text('餐厅介绍', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
                ),
                Html(
                  data: '<html>${restaurant.description}</html>',
                  style: {
                    'html': Style(
                      fontSize: FontSize(15),
                      lineHeight: LineHeight.number(1.5)
                    )
                  },
                )
              ],
            ),
          ),
          const SizedBox(height: 10,),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(16))
            ),
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('餐厅信息', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
                const SizedBox(height: 15,),
                Text(
                  '营业时间：${restaurant.openCloseTimes ?? "暂无"}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  '推荐菜品：${restaurant.recommendFood ?? "暂无推荐"}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  '人均消费：¥${restaurant.averagePrice != null ? (restaurant.averagePrice! / 100) : "暂无"}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  '联系电话：${restaurant.phone ?? "暂无电话"}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  restaurant.hasWifi != null ? '提供预定服务' : '暂无预定服务',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  restaurant.hasWifi == true ? '提供Wi-Fi服务' : '暂无Wi-Fi服务',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}