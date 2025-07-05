
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/order_merchant/order_merchant_api.dart';
import 'package:freego_flutter/components/order_neo/order_common.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:intl/intl.dart';

class OrderMerchantRestaurantPage extends StatelessWidget{
  final int? nid;
  final OrderRestaurant order;
  const OrderMerchantRestaurantPage({required this.order, this.nid, super.key});

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
      body: OrderMerchantRestaurantWidget(nid: nid, order: order,),
    );
  }
  
}

class OrderMerchantRestaurantWidget extends StatefulWidget{
  final int? nid;
  final OrderRestaurant order;
  const OrderMerchantRestaurantWidget({required this.order, this.nid, super.key});

  @override
  State<StatefulWidget> createState() {
    return OrderMerchantRestaurantState();
  }

}

class OrderMerchantRestaurantState extends State<OrderMerchantRestaurantWidget>{

  static const double FIELD_NAME_WIDTH = 100;

  Widget svgRestaurant = SvgPicture.asset('svg/icon_restaurant.svg', color: ThemeUtil.foregroundColor,);
  late OrderRestaurant order;

  @override
  void initState(){
    super.initState();
    order = widget.order;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeUtil.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonHeader(
            center: Text('订单详情', style: TextStyle(color: Colors.white, fontSize: 18),),
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
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: svgRestaurant,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                InkWell(
                                  onTap: () async {},
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
                              ]
                            )
                          )
                        ]
                      ),
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
                    borderRadius: BorderRadius.all(Radius.circular(16))
                  ),
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
                                style: TextStyle(color: ThemeUtil.foregroundColor),
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
                              style: const TextStyle(
                                color: ThemeUtil.foregroundColor
                              ),
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
                                style: 
                                TextStyle(color: ThemeUtil.foregroundColor),
                              ),
                            ),
                            Text(
                              getDiningMethodsText(),
                              style: const TextStyle(
                                color: ThemeUtil.foregroundColor
                              ),
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
                                '联系姓名：',
                                style:
                                TextStyle(color: ThemeUtil.foregroundColor),
                              ),
                            ),
                            Text(
                              order.contactName ?? '',
                              style: const TextStyle(
                                color: ThemeUtil.foregroundColor
                              ),
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
                                '联系电话：',
                                style:
                                TextStyle(color: ThemeUtil.foregroundColor),
                              ),
                            ),
                            Text(
                              order.contactPhone ?? '',
                              style: const TextStyle(
                                color: ThemeUtil.foregroundColor
                              ),
                            ), // 显示联系电话
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
                                '备注：',
                                style: TextStyle(color: ThemeUtil.foregroundColor),
                              ),
                            ),
                            //const SizedBox(width: 10,),
                            Text(
                              order.remark ?? '',
                              style: const TextStyle(
                                color: ThemeUtil.foregroundColor
                              ),
                            ), // 显示备注
                          ],
                        ),
                      ),
                      const Divider(),
                      getPayStatusWidget()
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

  String getDiningMethodsText() {
    if (order.diningMethods == null) {
      return '订单出错';
    }
    OrderRestaurantDining? status =
        OrderRestaurantDiningExt.getStatus(order.diningMethods!);
    if (status == null) {
      return '订单出错';
    }
    switch (status) {
      case OrderRestaurantDining.dineIn:
        return '在店用餐';
      case OrderRestaurantDining.takeOut:
        return '打包带走';
      case OrderRestaurantDining.unconfirmed:
        return '未确认';
      default:
        return '订单出错';
    }
  }

  Widget getBookNumWidet() {
    int orderNum = widget.order.numberPeople ?? 0;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Wrap(
        children: [
          const SizedBox(
            width: FIELD_NAME_WIDTH,
            child: Text(
              '用餐人数：',
              style: TextStyle(color: ThemeUtil.foregroundColor),
            ),
          ),
          Text(
            '$orderNum',
            style: const TextStyle(color: ThemeUtil.foregroundColor),
          ),
          const Text(
            ' 位',
            style: TextStyle(color: ThemeUtil.foregroundColor),
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
                '用餐时间：',
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
    List<OrderRestaurantDish> dishList = order.dishList ?? [];
    if(dishList.isNotEmpty){
      // 计算总件数和总价
      int totalItems = 0;
      double totalPrice = 0.0;

      for (OrderRestaurantDish orderDish in dishList) {
        totalItems += orderDish.dishNumber ?? 0;
        totalPrice += (orderDish.price ?? 0) * (orderDish.dishNumber ?? 0) / 100.0;
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: getOrderNeoWidgets(dishList),
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

  List<Widget> getOrderNeoWidgets(
      List<OrderRestaurantDish>? orderRestaurantDish) {
    List<Widget> widgets = [];
    if (orderRestaurantDish != null) {
      for (OrderRestaurantDish orderDish in orderRestaurantDish) {
        widgets.add(
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
                '￥${StringUtil.getPriceStr(orderDish.price)}',
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
    OrderRestaurant restaurant = widget.order;
    if (restaurant.orderStatus == null) {
      return const SizedBox();
    }
    OrderRestaurantStatus? status =
        OrderRestaurantStatusExt.getStatus(restaurant.orderStatus!);
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
                MyOrderRestaurantStatusExt(status).getText(),
                style: TextStyle(color: status.getColor()),
              )
            ],
          ),
        ),
        restaurant.unfinishedReason != null
            ? Padding(
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
              )
            : const SizedBox()
      ],
    );
  }

  Widget getActionWidget() {
    bool showConfirm = false;
    bool showReject = false;

    if(order.orderStatus == null){
      return const SizedBox();
    }
    OrderRestaurantStatus? status = OrderRestaurantStatusExt.getStatus(order.orderStatus!);
    if(status == null){
      return const SizedBox();
    }
    if(status == OrderRestaurantStatus.unconfirmed){
      showConfirm = true;
      showReject = true;
    }
    if(showConfirm || showReject){
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
            if(showReject)
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
                  if(order.orderSerial == null){
                    ToastUtil.error('订单出错');
                    return;
                  }
                  bool result = await OrderMerchantHttp().rejectOrder(orderSerial: order.orderSerial!, fail: (response){
                    ToastUtil.error(response.data['message']);
                  });
                  if(result){
                    order.orderStatus = OrderRestaurantStatus.confirmFail.getNum();
                    if(mounted && context.mounted){
                      setState(() {
                      });
                    }
                  }
                },
                child: const Text('拒 绝', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
              ),
            ),
            if(showConfirm)
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
                  if(order.orderSerial == null){
                    ToastUtil.error('订单出错');
                    return;
                  }
                  bool result = await OrderMerchantHttp().confirmOrder(orderSerial: order.orderSerial!, fail: (response){
                    ToastUtil.error(response.data['message']);
                  });
                  if(result){
                    order.orderStatus = OrderRestaurantStatus.confirmed.getNum();
                    if(mounted && context.mounted){
                      setState(() {
                      });
                    }
                  }
                },
                child: const Text('确 认', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),),
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

  String getText(){
    switch(this){
      case OrderRestaurantStatus.unpaid:
        return '未支付';
      case OrderRestaurantStatus.unconfirmed:
        return '新的订单';
      case OrderRestaurantStatus.confirmFail:
        return '确认失败';
      case OrderRestaurantStatus.confirmed:
        return '已接单';
      case OrderRestaurantStatus.servicing:
        return '服务中';
      case OrderRestaurantStatus.completed:
        return '已完成';
      case OrderRestaurantStatus.canceling:
        return '取消中';
      case OrderRestaurantStatus.cancelFail:
        return '取消失败';
      case OrderRestaurantStatus.canceled:
        return '已取消';
      case OrderRestaurantStatus.refunding:
        return '退款中';
      case OrderRestaurantStatus.refundFail:
        return '退款失败';
      case OrderRestaurantStatus.refunded:
        return '已退款';
      case OrderRestaurantStatus.error:
        return '订单失败';
    }
  }

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
