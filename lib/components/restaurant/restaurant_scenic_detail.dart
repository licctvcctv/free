import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/restaurant/restaurant_common.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/util/theme_util.dart';

class RestaurantScenicDetailPage extends StatelessWidget {
  final Restaurant restaurant;
  final List<RestaurantDish>? dishes;
  final double totalPrice;
  final int orderNum;
  final DateTime? tourDate;
  final String contactDinnerTime;
  final String contactName;
  final String contactPhone;
  final String contactAsk;
  final List<RestaurantDish>? selectedDishes;
  final Map<int, int> dishQuantities;

  const RestaurantScenicDetailPage({
    required this.restaurant,
    this.dishes,
    required this.totalPrice,
    required this.orderNum,
    this.tourDate,
    required this.contactDinnerTime,
    required this.contactName,
    required this.contactPhone,
    required this.contactAsk,
    required this.selectedDishes,
    required this.dishQuantities,
    super.key,
  });

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
      body: RestaurantScenicDetailWidget(
        restaurant: restaurant,
        dishes: dishes,
        totalPrice: totalPrice,
        orderNum: orderNum,
        tourDate: tourDate,
        contactDinnerTime: contactDinnerTime,
        contactName: contactName,
        contactPhone: contactPhone,
        contactAsk: contactAsk,
        selectedDishes: selectedDishes,
        dishQuantities: dishQuantities,
      ),
    );
  }
}

class RestaurantScenicDetailWidget extends StatefulWidget {
  final Restaurant restaurant;
  final List<RestaurantDish>? dishes;
  final double totalPrice;
  final int orderNum;
  final DateTime? tourDate;
  final String contactDinnerTime;
  final String contactName;
  final String contactPhone;
  final String contactAsk;
  final List<RestaurantDish>? selectedDishes;
  final Map<int, int> dishQuantities;

  const RestaurantScenicDetailWidget({
    required this.restaurant,
    this.dishes,
    required this.totalPrice,
    required this.orderNum,
    this.tourDate,
    required this.contactDinnerTime,
    required this.contactName,
    required this.contactPhone,
    required this.contactAsk,
    required this.selectedDishes,
    required this.dishQuantities,
    Key? key,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return RestaurantScenicDetailState();
  }
}

class RestaurantScenicDetailState extends State<RestaurantScenicDetailWidget> {
  Widget svgScenic = SvgPicture.asset(
    'svg/icon_restaurant.svg',
    color: ThemeUtil.foregroundColor,
  );
  bool showTimeLimit = false;
  Timer? payLimitTimer;
  int payLimitSeconds = 0;

  static const double FIELD_NAME_WIDTH = 100;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Restaurant restaurant = widget.restaurant;
    String contactName = widget.contactName; 
    String contactPhone = widget.contactPhone; 
    String contactAsk = widget.contactAsk; 
    return Container(
      color: ThemeUtil.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonHeader(
            center: Text(
              '订单详情',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(16,16,16,0),
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(16))),
                  clipBehavior: Clip.hardEdge,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                            child: Column(children: [
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: svgScenic,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          InkWell(
                            onTap: () async {},
                            child: Text(
                              restaurant.name ?? '',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: ThemeUtil.foregroundColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                          ),
                        ]))
                      ]),
                      const SizedBox(height: 10,),
                      const Text(
                        '已选菜品：',
                        style: TextStyle(
                          color: ThemeUtil.foregroundColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10,),
                      getmenuWidget(),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.fromLTRB(16,0,16,16),
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(16))),
                    clipBehavior: Clip.hardEdge,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                      const SizedBox(height: 5,),
                      const Divider(),
                      const SizedBox(height: 5,),
                      getBookNumWidet(),
                      const SizedBox(height: 10,),
                      getBookTimeWidget(),
                      Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Wrap(
                        children: [
                          const SizedBox(
                            width: FIELD_NAME_WIDTH,
                            child: Text('联系姓名：'),
                          ),
                          Text(contactName), // 显示联系姓名
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Wrap(
                        children: [
                          const SizedBox(
                            width: FIELD_NAME_WIDTH,
                            child: Text('联系电话：'),
                          ),
                          Text(contactPhone), // 显示联系电话
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Wrap(
                        children: [
                          const SizedBox(
                            width: FIELD_NAME_WIDTH,
                            child: Text('备注：'),
                          ),
                          Text(contactAsk), // 显示备注
                        ],
                      ),
                    ),
                      const Divider(),
                    ],
                  ),
                )
              ],
            ),
          ),
          getActionWidget()
        ],
      ),
    );
  }

  Widget getBookNumWidet() {
    int orderNum = widget.orderNum;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Wrap(
        children: [
          const SizedBox(
            width: FIELD_NAME_WIDTH,
            child: Text('用餐人数：'),
          ),
          Text('$orderNum'), // 显示联系电话
        ],
      ),
    );
  }

  Widget getBookTimeWidget() {
    DateTime? tourDate = widget.tourDate;
    String contactDinnerTime = widget.contactDinnerTime;

    if (tourDate != null) {
      String formattedDate = '${tourDate.year}年${tourDate.month}月${tourDate.day}日';
      String formattedTime = contactDinnerTime.substring(0, 5); // Extracting hours and minutes

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              width: FIELD_NAME_WIDTH,
              child: Text ('用餐时间：',),
            ),
            Text('$formattedDate $formattedTime'), // 显示联系电话
          ],
        ),
      );
    } else {
      return const SizedBox(); // 如果tourDate为null，则返回一个空的部件
    }
  }

  Widget getmenuWidget() {
    List<RestaurantDish>? selectedDishes = widget.selectedDishes;
    Map<int, int> dishQuantities = widget.dishQuantities;

    if (selectedDishes != null && selectedDishes.isNotEmpty) {
      int totalQuantity = 0;
      double totalPrice = 0;

      // 计算总价和总件数
      selectedDishes.forEach((dish) {
        int quantity = dishQuantities[dish.id] ?? 0;
        totalQuantity += quantity;
        if (dish.price != null) {
          totalPrice += dish.price! * quantity / 100;
        }
      });

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 显示所选菜品
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: selectedDishes.map((dish) {
              int quantity = dishQuantities[dish.id] ?? 0;
              double? itemTotalPrice = dish.price != null ? dish.price! * quantity / 100 : null;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${dish.name} x $quantity',
                        style: const TextStyle(
                          color: ThemeUtil.foregroundColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      itemTotalPrice != null
                          ? '￥${itemTotalPrice.toStringAsFixed(2)}'
                          : '￥0.00',
                      style: const TextStyle(
                        color: ThemeUtil.foregroundColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '共：$totalQuantity 件',
                    style: const TextStyle(
                      color: ThemeUtil.foregroundColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '合计：￥${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: ThemeUtil.foregroundColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return const SizedBox(); // 如果没有选定的菜品，则返回一个空的部件
    }
  }

  Widget getActionWidget() {
    Restaurant restaurant = widget.restaurant;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            decoration: const BoxDecoration(
                color: Colors.white,
                border: Border.fromBorderSide(
                    BorderSide(color: ThemeUtil.foregroundColor)),
                borderRadius: BorderRadius.all(Radius.circular(8))),
            child: TextButton(
              style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              onPressed: () {},
              child: const Text(
                '取消',
                style: TextStyle(
                    color: ThemeUtil.foregroundColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            decoration: const BoxDecoration(
              color: ThemeUtil.buttonColor,
              borderRadius: BorderRadius.all(Radius.circular(8))),
              child: TextButton(
              style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              onPressed: () {},
              child: const Text(
                '支 付',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ),
          )
        ],
      ),
    );
  }
}
