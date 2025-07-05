import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/chat_neo/chat_common.dart';
import 'package:freego_flutter/components/chat_neo/chat_room.dart';
import 'package:freego_flutter/components/chat_neo/chat_util.dart';
import 'package:freego_flutter/components/order_neo/api/order_neo_api.dart';
import 'package:freego_flutter/components/order_neo/order_common.dart';
import 'package:freego_flutter/components/restaurant/restaurant_common.dart';
import 'package:freego_flutter/components/restaurant/restaurant_home.dart';
import 'package:freego_flutter/components/restaurant/restaurant_api.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/util/order_pay_util.dart';
import 'package:freego_flutter/util/paytype_choose_util.dart';
import 'package:freego_flutter/util/string_util.dart';

import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderRestaurantDetailPage extends StatelessWidget {
  final OrderRestaurant order;
  const OrderRestaurantDetailPage(this.order, {super.key});

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
      body: OrderRestaurantDetailWidget(order),
    );
  }
}

class OrderRestaurantDetailWidget extends StatefulWidget {
  final OrderRestaurant order;
  const OrderRestaurantDetailWidget(this.order, {super.key});

  //get restaurant => null;

  @override
  State<StatefulWidget> createState() {
    return OrderRestaurantDetailState();
  }
}

class OrderRestaurantDetailState extends State<OrderRestaurantDetailWidget> {

  static const double FIELD_NAME_WIDTH = 100;

  Widget svgRestaurant = SvgPicture.asset(
    'svg/icon_restaurant.svg',
    color: ThemeUtil.foregroundColor,
  );
  bool showTimeLimit = false;
  Timer? payLimitTimer;
  int payLimitSeconds = 0;
  Widget svgQuestion = SvgPicture.asset('svg/question.svg', color: Colors.lightBlue,);

  late OrderRestaurant order;

  @override
  void initState() {
    super.initState();
    order = widget.order;

    if(order.orderStatus != null){
      OrderRestaurantStatus? status = OrderRestaurantStatusExt.getStatus(order.orderStatus!);
      if(status == OrderRestaurantStatus.unpaid){
        if(order.payLimitTime != null){
          DateTime now = DateTime.now();
          payLimitSeconds = order.payLimitTime!.difference(now).inSeconds;
          if(now.isBefore(order.payLimitTime!)){
            showTimeLimit = true;
            payLimitTimer = Timer.periodic(const Duration(seconds: 1), (timer) { 
              --payLimitSeconds;
              if(payLimitSeconds <= 0){
                timer.cancel();
              }
              if(mounted && context.mounted){
                setState(() {
                });
              }
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              physics: const ClampingScrollPhysics(),
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(16))
                  ),
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
                            child: svgRestaurant,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          InkWell(
                            onTap: () async {
                              if (order.restaurantId == null) {
                                return;
                              }
                              Restaurant? restaurant = await RestaurantApi().getById(order.restaurantId!);
                              if (restaurant != null) {
                                if (mounted && context.mounted) {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                                    return RestaurantHomePage(restaurant);
                                  }));
                                }
                              }
                            },
                            child: Text(
                              order.restaurantName ?? '',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: ThemeUtil.foregroundColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18
                              ),
                            ),
                          ),
                        ]))
                      ]),
                      payLimitSeconds > 0 ?
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(StringUtil.getLimitedTimeFromSeconds(payLimitSeconds), textAlign: TextAlign.center, style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 26),)
                            ],
                          ),
                        ) : const SizedBox(),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        '已选菜品：',
                        style: TextStyle(
                          color: ThemeUtil.foregroundColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      getmenuWidget(),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(16))),
                  clipBehavior: Clip.hardEdge,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Wrap(
                          children: [
                            const SizedBox(
                              width: FIELD_NAME_WIDTH,
                              child: Text(
                                '订单号',
                                style:TextStyle(color: ThemeUtil.foregroundColor),
                              ),
                            ),
                            Text(
                              order.orderSerial ?? '',
                              style: const TextStyle(color: ThemeUtil.foregroundColor),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Wrap(
                          children: [
                            const SizedBox(
                              width: FIELD_NAME_WIDTH,
                              child: Text(
                                '下单时间',
                                style: TextStyle(color: ThemeUtil.foregroundColor),
                              ),
                            ),
                            if(order.createTime != null)
                            Text(
                              DateFormat('yyyy-MM-dd HH:mm:ss').format(order.createTime!),
                              style: const TextStyle(color: ThemeUtil.foregroundColor),
                            )
                          ],
                        ),
                      ),
                      getBookNumWidet(),
                      const SizedBox(
                        height: 10,
                      ),
                      getBookTimeWidget(),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Wrap(
                          children: [
                            const SizedBox(
                              width: FIELD_NAME_WIDTH,
                              child: Text(
                                '用餐方式',
                                style: TextStyle(color: ThemeUtil.foregroundColor),
                              ),
                            ),
                            Text(
                              getDiningMethodsText(),
                              style: const TextStyle(color: ThemeUtil.foregroundColor),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 10,),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Wrap(
                          children: [
                            const SizedBox(
                              width: FIELD_NAME_WIDTH,
                              child: Text(
                                '联系姓名',
                                style: TextStyle(color: ThemeUtil.foregroundColor),
                              ),
                            ),
                            Text(
                              order.contactName ?? '',
                              style: const TextStyle(color: ThemeUtil.foregroundColor),
                            ), // 显示联系姓名
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Wrap(
                          children: [
                            const SizedBox(
                              width: FIELD_NAME_WIDTH,
                              child: Text(
                                '联系电话',
                                style: TextStyle(color: ThemeUtil.foregroundColor),
                              ),
                            ),
                            Text(
                              order.contactPhone ?? '',
                              style: const TextStyle(color: ThemeUtil.foregroundColor),
                            ), // 显示联系电话
                          ],
                        ),
                      ),
                      if(order.remark != null && order.remark != '')
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Wrap(
                          children: [
                            const SizedBox(
                              width: FIELD_NAME_WIDTH,
                              child: Text(
                                '备注：',
                                style:TextStyle(color: ThemeUtil.foregroundColor),
                              ),
                            ),
                            Text(
                              order.remark ?? '',
                              style: const TextStyle(
                                  color: ThemeUtil.foregroundColor),
                            ), // 显示备注
                          ],
                        ),
                      ),
                      const Divider(),
                      getPayStatusWidget(),
                      getMerchantContactWidget(),
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

  Widget getMerchantContactWidget(){
    bool showChat = order.merchantId != null;
    bool showPhone = order.merchantPhone != null;
    if(!showChat && !showPhone){
      return const SizedBox();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 8),
        Row(
          children: [
            const SizedBox(
              width: FIELD_NAME_WIDTH,
              child: Text('联系商家', style: TextStyle(color: ThemeUtil.foregroundColor),),
            ),
            if(showPhone)
            InkWell(
              onTap:  () async{
                String url = 'tel:${order.merchantPhone}';
                Uri uri = Uri.parse(url);
                if (await canLaunchUrl(uri)){
                  launchUrl(uri);
                }
              }, 
              child: const Icon(Icons.phone_rounded, color: Colors.lightBlue, size: 40,)
            ),
            if(showChat)
            InkWell(
              onTap: () async{
                if(order.merchantId == null){
                  return;
                }
                ImSingleRoom? room = await ChatUtilSingle.enterRoom(order.merchantId!);
                if(room == null){
                  return;
                }
                if(mounted && context.mounted){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context){
                    return ChatRoomPage(room: room,);
                  }));
                }
              }, 
              child: SizedBox(
                width: 40,
                height: 40,
                child: svgQuestion,
              )
            )
          ],
        )
      ],
    );
  }

  String getDiningMethodsText() {
    if (order.diningMethods == null) {
      return '订单出错';
    }
    DiningType? type = DiningTypeExt.getType(order.diningMethods!);
    if (type == null) {
      return '订单出错';
    }
    switch (type) {
      case DiningType.inStore:
        return '在店用餐';
      case DiningType.packed:
        return '打包带走';
      default:
        return '订单出错';
    }
  }

  Widget getBookNumWidet() {
    int orderNum = order.numberPeople ?? 0;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Wrap(
        children: [
          const SizedBox(
            width: FIELD_NAME_WIDTH,
            child: Text(
              '用餐人数',
              style: TextStyle(color: ThemeUtil.foregroundColor),
            ),
          ),
          Text(
            '$orderNum位',
            style: const TextStyle(color: ThemeUtil.foregroundColor),
          ),
        ],
      ),
    );
  }

  Widget getBookTimeWidget() {
    DateTime? tourDate = order.arrivalDate;

    if (tourDate != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              width: FIELD_NAME_WIDTH,
              child: Text(
                '用餐时间',
                style: TextStyle(color: ThemeUtil.foregroundColor),
              ),
            ),
            Text(
              DateFormat('yyyy-MM-dd HH:mm').format(tourDate),
              style: const TextStyle(color: ThemeUtil.foregroundColor),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget getmenuWidget() {
    List<OrderRestaurantDish> restaurantDishList = order.dishList ?? [];
    if(restaurantDishList.isNotEmpty){
      // 计算总件数和总价
      int totalItems = 0;
      double totalPrice = 0.0;

      for (OrderRestaurantDish orderDish in restaurantDishList) {
        totalItems += orderDish.dishNumber ?? 0;
        totalPrice +=
            (orderDish.price ?? 0) * (orderDish.dishNumber ?? 0) / 100.0;
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: getOrderNeoWidgets(restaurantDishList),
          ),
          const Divider(), // 添加横线
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '共：$totalItems 件',
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
    } 
    else {
      return const Text('暂无数据'); // 处理没有数据的情况
    }
  }

  List<Widget> getOrderNeoWidgets(List<OrderRestaurantDish>? orderRestaurantDish) {
    List<Widget> widgets = [];
    if (orderRestaurantDish != null) {
      for (OrderRestaurantDish orderDish in orderRestaurantDish) {
        widgets.add(
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Text(
                    '${orderDish.dishName} x ${orderDish.dishNumber}',
                    style: const TextStyle(
                      color: ThemeUtil.foregroundColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Text(
                '￥${StringUtil.getPriceStr(orderDish.price ?? 0)}',
                style: const TextStyle(
                  color: ThemeUtil.foregroundColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      }
    }
    return widgets;
  }

  Widget getPayStatusWidget() {
    OrderRestaurant restaurant = order;
    if (restaurant.orderStatus == null) {
      return const SizedBox();
    }
    OrderRestaurantStatus? status = OrderRestaurantStatusExt.getStatus(restaurant.orderStatus!);
    if (status == null) {
      return const SizedBox();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            children: [
              const SizedBox(
                width: FIELD_NAME_WIDTH,
                child: Text(
                  '订单状态：',
                  style: TextStyle(color: ThemeUtil.foregroundColor),
                ),
              ),
              Text(
                status.getText(),
                style: TextStyle(color: status.getColor()),
              )
            ],
          ),
        ),
        restaurant.unfinishedReason != null ? 
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Wrap(
            children: [
              const SizedBox(
                width: FIELD_NAME_WIDTH,
                child: Text(
                  '失败原因',
                  style: TextStyle(color: ThemeUtil.foregroundColor),
                ),
              ),
              Text(
                restaurant.unfinishedReason!,
                style: const TextStyle(color: ThemeUtil.foregroundColor),
              )
            ],
          ),
        ): const SizedBox()
      ],
    );
  }

  Future onPaySuccess() async{
    ToastUtil.hint('支付成功');
    if(order.id == null){
      return;
    }
    OrderRestaurant? updatedOrder = await OrderNeoApi().getOrderRestaurant(id: order.id!);
    if(updatedOrder != null){
      order = updatedOrder;
    }
    if(mounted && context.mounted){
      Navigator.of(context).pop(order);
    }
  }

  Widget getActionWidget() {
    OrderRestaurant restaurant = order;
    bool showCancel = false;
    bool showPay = false;
    PayStatus? payStatus;
    if(order.payStatus != null){
      payStatus = PayStatusExt.getStatus(order.payStatus!);
    }
    OrderRestaurantStatus? orderStatus;
    if(order.orderStatus != null){
      orderStatus = OrderRestaurantStatusExt.getStatus(order.orderStatus!);
    }
    if(payStatus == PayStatus.unpaid){
      showCancel = true;
      showPay = true;
    }
    if(showCancel || showPay){
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4
            )
          ]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if(showCancel)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border.fromBorderSide(BorderSide(color: ThemeUtil.foregroundColor)),
                borderRadius: BorderRadius.all(Radius.circular(8))
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap
                ),
                onPressed: () async{
                  if(restaurant.orderSerial == null){
                    ToastUtil.error('数据错误');
                    return;
                  }
                  bool result = await RestaurantApi().cancel(orderSerial: restaurant.orderSerial!);
                  if(result){
                    ToastUtil.hint('取消中');
                    restaurant.payStatus = PayStatus.canceled.getNum();
                    restaurant.orderStatus = OrderRestaurantStatus.canceled.getNum();
                    if(mounted && context.mounted){
                      setState(() {
                      });
                    }
                  }
                  else{
                    ToastUtil.error('取消失败');
                  }
                },
                child: const Text('取 消', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
              ),
            ),
            if(showPay)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: const BoxDecoration(
                color: ThemeUtil.buttonColor,
                borderRadius: BorderRadius.all(Radius.circular(8))
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap
                ),
                onPressed: () async{
                  if(restaurant.orderSerial == null){
                    ToastUtil.error('数据错误');
                    return;
                  }
                  PayType? payType = await PayTypeChooseUtil().choose(context);
                  if(payType == null){
                    return;
                  }
                  if(payType == PayType.wechat){
                    String? payInfo = await RestaurantApi().pay(orderSerial: restaurant.orderSerial!, payType: PayType.wechat);
                    if(payInfo == null){
                      ToastUtil.error('微信预下单失败');
                      return;
                    }
                    OrderPayUtil().wechatPay(
                      payInfo, 
                      onSuccess: onPaySuccess,
                      onFail: (){
                        ToastUtil.error('支付失败');
                      }
                    );
                  }
                  else if(payType == PayType.alipay){
                    String? payInfo = await RestaurantApi().pay(orderSerial: restaurant.orderSerial!, payType: PayType.alipay);
                    if(payInfo == null){
                      ToastUtil.error('支付宝预下单失败');
                      return;
                    }
                    bool result = await OrderPayUtil().alipay(payInfo);
                    if(result){
                      ToastUtil.hint('支付成功');
                      onPaySuccess();
                    }
                    else{
                      ToastUtil.error('支付失败');
                    }
                  }
                },
                child: const Text('支 付', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),),
              ),
            )
          ],
        ),
      );
    }
    return const SizedBox();
  }
}

extension MyOrderRestaurantStatusExt on OrderRestaurantStatus{
  Color getColor(){
    switch(this){
      case OrderRestaurantStatus.unpaid:
        return Colors.lightGreen;
      case OrderRestaurantStatus.unconfirmed:
      case OrderRestaurantStatus.confirmed:
      case OrderRestaurantStatus.servicing:
        return Colors.lightBlue;
      case OrderRestaurantStatus.completed:
        return const Color.fromRGBO(249, 168, 37, 1);
      case OrderRestaurantStatus.canceling:
      case OrderRestaurantStatus.canceled:
        return Colors.grey;
      default:
        return Colors.redAccent;
    }
  }
}
