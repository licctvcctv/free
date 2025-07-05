
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/chat_notification/chat_notification_storage.dart';
import 'package:freego_flutter/components/order_merchant/order_merchant_api.dart';
import 'package:freego_flutter/components/order_merchant/order_status_util.dart';
import 'package:freego_flutter/components/order_neo/order_common.dart';
import 'package:freego_flutter/components/scenic/scenic_common.dart';
import 'package:freego_flutter/components/scenic/scenic_home_freego.dart';
import 'package:freego_flutter/components/scenic/api/local_scenic_api.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:intl/intl.dart';

class OrderMerchantScenicPage extends StatelessWidget{
  final int? nid;
  final OrderScenic order;
  const OrderMerchantScenicPage({this.nid, required this.order, super.key});

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
      body: OrderMerchantScenicWidget(nid: nid, order: order,),
    );
  }

}

class OrderMerchantScenicWidget extends StatefulWidget{
  final int? nid;
  final OrderScenic order;
  const OrderMerchantScenicWidget({this.nid, required this.order, super.key});

  @override
  State<StatefulWidget> createState() {
    return OrderMerchantScenicState();
  }

}

class OrderMerchantScenicState extends State<OrderMerchantScenicWidget>{

  Widget svgScenic = SvgPicture.asset('svg/icon_scenic.svg', color: ThemeUtil.foregroundColor,);
  static const double FIELD_NAME_WIDTH = 100;

  @override
  Widget build(BuildContext context) {
    OrderScenic order = widget.order;
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
                  margin: const EdgeInsets.all(16),
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
                                  child: svgScenic,
                                ),
                                const SizedBox(width: 10,),
                                InkWell(
                                  onTap: () async{
                                    if(order.scenicId == null){
                                      return;
                                    }
                                    Scenic? scenic = await LocalScenicApi().detail(order.scenicId!);
                                    if(scenic == null){
                                      return;
                                    }
                                    if(mounted && context.mounted){
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                        return ScenicHomePage(scenic);
                                      }));
                                    }
                                  },
                                  child: Text(order.scenicName ?? '', textAlign: TextAlign.center, style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
                                ),
                                const SizedBox(height: 10,),
                                Text(order.ticketName ?? '', textAlign: TextAlign.center, style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold),),
                                const SizedBox(height: 10,),
                                Text('￥${StringUtil.getPriceStr(order.amount)}', textAlign: TextAlign.center, style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold),),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 10,),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Wrap(
                          children: [
                            const SizedBox(
                              width: FIELD_NAME_WIDTH,
                              child: Text('订单号', style: TextStyle(color: ThemeUtil.foregroundColor),),
                            ),
                            Text(order.orderSerial ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor),)
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Wrap(
                          children: [
                            const SizedBox(
                              width: FIELD_NAME_WIDTH,
                              child: Text('下单时间', style: TextStyle(color: ThemeUtil.foregroundColor),),
                            ), 
                            order.createTime != null ?
                            Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(order.createTime!), style: const TextStyle(color: ThemeUtil.foregroundColor),):
                            const SizedBox()
                          ],
                        ),
                      ),
                      if(order.orderStatus == OrderScenicStatus.drawing.getNum() && order.confirmLimitTime != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Wrap(
                          children: [
                            const SizedBox(
                              width: FIELD_NAME_WIDTH,
                              child: Text('最晚确认时间', style: TextStyle(color: ThemeUtil.foregroundColor),),
                            ),
                            Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(order.confirmLimitTime!), style: const TextStyle(color: ThemeUtil.foregroundColor),)
                          ],
                        ),
                      ),
                      if(order.travelDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Wrap(
                          children: [
                            const SizedBox(
                              width: FIELD_NAME_WIDTH,
                              child: Text('游玩日期'),
                            ),
                            Text(DateFormat('yyyy-MM-dd').format(order.travelDate!), style: const TextStyle(color: ThemeUtil.foregroundColor),)
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Wrap(
                          children: [
                            const SizedBox(
                              width: FIELD_NAME_WIDTH,
                              child: Text('购买数量'),
                            ),
                            Text('${order.quantity}张', style: const TextStyle(color: ThemeUtil.foregroundColor),)
                          ],
                        ),
                      ),
                      if(order.drawAddress != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Wrap(
                          children: [
                            const SizedBox(
                              width: FIELD_NAME_WIDTH,
                              child: Text('取票地址'),
                            ),
                            Text(order.drawAddress ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor),)
                          ],
                        ),
                      ),
                      const Divider(),
                      getContactWidget(),
                      getPayStatusWidget(),
                      const Divider(),
                      getGuestListWidget(),
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

  Widget getActionWidget(){
    OrderScenic order = widget.order;
    OrderScenicStatus? status;
    if(order.orderStatus != null){
      status = OrderScenicStatusExt.getStatus(order.orderStatus!);
    }
    if(status == null){
      return const SizedBox();
    }
    if(status == OrderScenicStatus.drawing){
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
                    order.orderStatus = OrderScenicStatus.drawFail.getNum();
                    if(mounted && context.mounted){
                      setState(() {
                      });
                    }
                    if(widget.nid != null){
                      ChatNotificationStorage.updateOrderScenicStatus(widget.nid!, OrderScenicStatus.drawFail);
                      OrderStatusUtil().setOrderScenicStatus(widget.nid!, OrderScenicStatus.drawFail.getNum());
                    }
                  }
                },
                child: const Text('拒 绝', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
              ),
            ),
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
                    order.orderStatus = OrderScenicStatus.drawn.getNum();
                    if(mounted && context.mounted){
                      setState(() {
                      });
                    }
                    if(widget.nid != null){
                      ChatNotificationStorage.updateOrderScenicStatus(widget.nid!, OrderScenicStatus.drawn);
                      OrderStatusUtil().setOrderScenicStatus(widget.nid!, OrderScenicStatus.drawn.getNum());
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

  Widget getGuestListWidget(){
    OrderScenic order = widget.order;
    List<OrderGuest>? guestList = order.guestList;
    if(guestList == null || guestList.isEmpty){
      return const SizedBox();
    }
    List<Widget> widgets = [];
    for(OrderGuest guest in guestList){
      CardType? cardType;
      if(guest.cardType != null){
        cardType = CardTypeExt.getType(guest.cardType!);
      }
      widgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(guest.name != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  const SizedBox(
                    width: FIELD_NAME_WIDTH,
                    child: Text('游客姓名', style: TextStyle(color: ThemeUtil.foregroundColor),),
                  ),
                  Text(guest.name ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor),)
                ],
              ),
            ),
            if(guest.phone != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  const SizedBox(
                    width: FIELD_NAME_WIDTH,
                    child: Text('游客手机', style: TextStyle(color: ThemeUtil.foregroundColor),),
                  ),
                  Text(guest.phone ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor),)
                ],
              ),
            ),
            if(cardType != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  const SizedBox(
                    width: FIELD_NAME_WIDTH,
                    child: Text('证件类型', style: TextStyle(color: ThemeUtil.foregroundColor),),
                  ),
                  Text(cardType.getName(), style: const TextStyle(color: ThemeUtil.foregroundColor),)
                ],
              ),
            ),
            if(guest.cardNo != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  const SizedBox(
                    width: FIELD_NAME_WIDTH,
                    child: Text('证件号', style: TextStyle(color: ThemeUtil.foregroundColor),),
                  ),
                  Text(guest.cardNo ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor),)
                ],
              ),
            ),
            const Divider()
          ],
        )
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget getPayStatusWidget(){
    OrderScenic order = widget.order;
    if(order.orderStatus == null){
      return const SizedBox();
    }
    OrderScenicStatus? status = OrderScenicStatusExt.getStatus(order.orderStatus!);
    if(status == null){
      return const SizedBox();
    }
    String? statusText;
    Color? statusColor;
    switch(status){
      case OrderScenicStatus.unpaid:
        statusText = '未支付';
        statusColor = Colors.lightGreen;
        break;
      case OrderScenicStatus.drawing:
        statusText = '出票中';
        statusColor = Colors.lightBlue;
        break;
      case OrderScenicStatus.drawn:
        statusText = '已出票';
        statusColor = Colors.lightBlue;
        break;
      case OrderScenicStatus.drawFail:
        statusText = '出票失败';
        statusColor = Colors.redAccent;
        break;
      case OrderScenicStatus.unsubscribing:
        statusText = '退订中';
        statusColor = Colors.grey;
        break;
      case OrderScenicStatus.unsubscribeFail:
        statusText = '退订失败';
        statusColor = Colors.redAccent;
        break;
      case OrderScenicStatus.unsubscribed:
        statusText = '已退订';
        statusColor = Colors.grey;
        break;
      case OrderScenicStatus.canceled:
        statusText = '已取消';
        statusColor = Colors.grey;
        break;
      default:
    }
    if(statusText == null){
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
                child: Text('订单状态', style: TextStyle(color: ThemeUtil.foregroundColor),),
              ),
              Text(statusText, style: TextStyle(color: statusColor),)
            ],
          ),
        ),
        order.unfinishedReason != null ?
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Wrap(
            children: [
              const SizedBox(
                width: FIELD_NAME_WIDTH,
                child: Text('失败原因', style: TextStyle(color: ThemeUtil.foregroundColor),),
              ),
              Text(order.unfinishedReason!, style: const TextStyle(color: ThemeUtil.foregroundColor),)
            ],
          ),
        ) : const SizedBox()
      ],
    );
  }

  Widget getContactWidget(){
    OrderScenic order = widget.order;
    if(order.contactName == null && order.contactPhone == null && order.contactCardType == null && order.contactCardNo == null){
      return const SizedBox();
    }
    CardType? cardType;
    if(order.contactCardType != null){
      cardType = CardTypeExt.getType(order.contactCardType!);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if(order.contactName != null)
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Wrap(
            children: [
              const SizedBox(
                width: FIELD_NAME_WIDTH,
                child: Text('联系姓名', style: TextStyle(color: ThemeUtil.foregroundColor),),
              ),
              Text(order.contactName ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor),)
            ],
          ),
        ),
        if(order.contactPhone != null)
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Wrap(
            children: [
              const SizedBox(
                width: FIELD_NAME_WIDTH,
                child: Text('联系电话', style: TextStyle(color: ThemeUtil.foregroundColor),),
              ),
              Text(order.contactPhone ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor),)
            ],
          ),
        ),
        if(cardType != null && cardType != CardType.none)
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Wrap(
            children: [
              const SizedBox(
                width: FIELD_NAME_WIDTH,
                child: Text('证件类型', style: TextStyle(color: ThemeUtil.foregroundColor),),
              ),
              Text(cardType.getName(), style: const TextStyle(color: ThemeUtil.foregroundColor),)
            ],
          ),
        ),
        if(order.contactCardNo != null)
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Wrap(
            children: [
              const SizedBox(
                width: FIELD_NAME_WIDTH,
                child: Text('证件号', style: TextStyle(color: ThemeUtil.foregroundColor),),
              ),
              Text(order.contactCardNo ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor),)
            ],
          ),
        ),
        const Divider()
      ]
    );
  }
}

extension MyOrderScenicStatusExt on OrderScenicStatus{

  String getText(){
    switch(this){
      case OrderScenicStatus.unpaid:
        return '订单未支付';
      case OrderScenicStatus.drawing:
        return '新的订单';
      case OrderScenicStatus.drawn:
        return '已出票';
      case OrderScenicStatus.drawFail:
        return '出票失败';
      case OrderScenicStatus.unsubscribing:
        return '退订中';
      case OrderScenicStatus.unsubscribed:
        return '已退订';
      case OrderScenicStatus.unsubscribeFail:
        return '退订失败';
      case OrderScenicStatus.canceled:
        return '已取消';
    }
  }

  Color getColor(){
    switch(this){
      case OrderScenicStatus.unpaid:
        return Colors.lightGreen;
      case OrderScenicStatus.drawing:
        return Colors.lightBlue;
      case OrderScenicStatus.drawn:
        return const Color.fromRGBO(249, 168, 37, 1);
      case OrderScenicStatus.drawFail:
        return Colors.redAccent;
      case OrderScenicStatus.unsubscribing:
      case OrderScenicStatus.unsubscribeFail:
      case OrderScenicStatus.unsubscribed:
      case OrderScenicStatus.canceled:
        return Colors.grey;
    }
  }
}