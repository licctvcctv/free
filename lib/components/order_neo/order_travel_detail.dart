import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/chat_neo/chat_common.dart';
import 'package:freego_flutter/components/chat_neo/chat_room.dart';
import 'package:freego_flutter/components/chat_neo/chat_util.dart';
import 'package:freego_flutter/components/order_neo/order_common.dart';
import 'package:freego_flutter/components/order_neo/api/order_neo_api.dart';
import 'package:freego_flutter/components/order_neo/api/order_pay_api.dart';
import 'package:freego_flutter/components/travel/travel_common.dart';
import 'package:freego_flutter/components/travel/travel_detail.dart';
import 'package:freego_flutter/components/travel/travel_api.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/util/order_pay_util.dart';
import 'package:freego_flutter/util/paytype_choose_util.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:intl/intl.dart';

class OrderTravelDetailPage extends StatelessWidget {
  final OrderTravel order;
  const OrderTravelDetailPage(this.order, {super.key});

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
      body: OrderTravelDetailWidget(order),
    );
  }
}

class OrderTravelDetailWidget extends StatefulWidget {
  final OrderTravel order;
  const OrderTravelDetailWidget(this.order, {super.key});

  get travel => null;

  @override
  State<StatefulWidget> createState() {
    return OrderTravelDetailState();
  }
}

class OrderTravelDetailState extends State<OrderTravelDetailWidget> {
  Widget svgTravel = SvgPicture.asset(
    'svg/icon_travel.svg',
    color: ThemeUtil.foregroundColor,
  );
  bool showTimeLimit = false;
  Timer? payLimitTimer;
  int payLimitSeconds = 0;

  static const double FIELD_NAME_WIDTH = 100;
  Widget svgQuestion = SvgPicture.asset(
    'svg/question.svg',
    color: Colors.lightBlue,
  );

  late OrderTravel order;

  @override
  void initState() {
    super.initState();
    order = widget.order;

    if(order.orderStatus != null){
      OrderTravelStatus? status = OrderTravelStatusExt.getStatus(order.orderStatus!);
      if(status == OrderTravelStatus.unpaid){
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
          CommonHeader(
            left: Container(
              width: 48,
              alignment: Alignment.center,
              child: IconButton(
                onPressed: (){
                  Navigator.of(context).pop(order);
                },
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white,),
              ),
            ),
            center: const Text(
              '订单详情',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(16))),
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
                                  child: svgTravel,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                InkWell(
                                  onTap: () async {
                                    if (order.travelId == null) {
                                      return;
                                    }
                                    Travel? travel = await TravelApi().getById(travelId: order.travelId!);
                                    if (travel != null) {
                                      if (mounted && context.mounted) {
                                        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                                          return TravelDetailPage(travel);
                                        }));
                                      }
                                    }
                                  },
                                  child: Text(
                                    order.travelName ?? '',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: ThemeUtil.foregroundColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  order.travelSuitName ?? '',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: ThemeUtil.foregroundColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  '￥${StringUtil.getPriceStr(order.amount)}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: ThemeUtil.foregroundColor,
                                      fontWeight: FontWeight.bold),
                                ),
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
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Wrap(
                          children: [
                            const SizedBox(
                              width: FIELD_NAME_WIDTH,
                              child: Text(
                                '订单号',
                                style:
                                    TextStyle(color: ThemeUtil.foregroundColor),
                              ),
                            ),
                            Text(
                              order.orderSerial ?? '',
                              style: const TextStyle(
                                  color: ThemeUtil.foregroundColor),
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
                                style:
                                    TextStyle(color: ThemeUtil.foregroundColor),
                              ),
                            ),
                            order.createTime != null
                                ? Text(
                                    DateFormat('yyyy-MM-dd HH:mm:ss')
                                        .format(order.createTime!),
                                    style: const TextStyle(
                                        color: ThemeUtil.foregroundColor),
                                  )
                                : const SizedBox()
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
                                '旅行时间',
                                style:
                                    TextStyle(color: ThemeUtil.foregroundColor),
                              ),
                            ),
                            order.dayNum != null
                                ? Text(
                                    '共${order.dayNum}天',
                                    style: const TextStyle(
                                        color: ThemeUtil.foregroundColor),
                                  )
                                : const SizedBox(),
                            order.nightNum != null
                                ? Text(
                                    '${order.nightNum!}晚',
                                    style: const TextStyle(
                                        color: ThemeUtil.foregroundColor),
                                  )
                                : const SizedBox()
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
                                '集合地点',
                                style:
                                    TextStyle(color: ThemeUtil.foregroundColor),
                              ),
                            ),
                            Text(
                              '${order.destProvince??''}${order.destCity??''}${order.rendezvousLocation??''}',
                              style: const TextStyle(
                                  color: ThemeUtil.foregroundColor),
                            ),
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
                                '集合时间',
                                style:
                                    TextStyle(color: ThemeUtil.foregroundColor),
                              ),
                            ),
                            Text(
                              order.rendezvousTime ?? '',
                              style: const TextStyle(
                                  color: ThemeUtil.foregroundColor),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      getCancelRuleTypeText(),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Wrap(
                          children: [
                            const SizedBox(
                              width: FIELD_NAME_WIDTH,
                              child: Text(
                                '联系姓名',
                                style:
                                    TextStyle(color: ThemeUtil.foregroundColor),
                              ),
                            ),
                            Text(
                              order.contactName ?? '',
                              style: const TextStyle(
                                  color: ThemeUtil.foregroundColor),
                            ),
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
                                style:
                                    TextStyle(color: ThemeUtil.foregroundColor),
                              ),
                            ),
                            Text(
                              order.contactPhone ?? '',
                              style: const TextStyle(
                                  color: ThemeUtil.foregroundColor),
                            ),
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
                                '紧急联系姓名',
                                style:
                                    TextStyle(color: ThemeUtil.foregroundColor),
                              ),
                            ),
                            Text(
                              order.emergencyName ?? '',
                              style: const TextStyle(
                                  color: ThemeUtil.foregroundColor),
                            ),
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
                                '紧急联系电话',
                                style:
                                    TextStyle(color: ThemeUtil.foregroundColor),
                              ),
                            ),
                            Text(
                              order.emergencyPhone ?? '',
                              style: const TextStyle(
                                  color: ThemeUtil.foregroundColor),
                            ),
                          ],
                        ),
                      ),
                      if(order.remark != null && order.remark!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Wrap(
                          children: [
                            const SizedBox(
                              width: FIELD_NAME_WIDTH,
                              child: Text(
                                '备注',
                                style:
                                    TextStyle(color: ThemeUtil.foregroundColor),
                              ),
                            ),
                            Text(
                              order.remark ?? '',
                              style: const TextStyle(
                                  color: ThemeUtil.foregroundColor),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      getPayStatusWidget(),
                      getMerchantContactWidget(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          getActionWidget()
        ],
      ),
    );
  }

  Widget getMerchantContactWidget(){
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
            ),
          ],
        )
      ],
    );
  }

  Widget getBookNumWidet() {
    int orderNum = (order.number ?? 0) +
        (order.childNumber ?? 0) +
        (order.oldNumber ?? 0);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Wrap(
        children: [
          const SizedBox(
            width: FIELD_NAME_WIDTH,
            child: Text(
              '旅行人数',
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
    List<Widget> dateWidgets = [];
    // 出发日期
    if (order.startDate != null) {
      dateWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                width: FIELD_NAME_WIDTH,
                child: Text(
                  '开始日期',
                  style: TextStyle(color: ThemeUtil.foregroundColor),
                ),
              ),
              Text(
                DateFormat('yyyy年MM月dd日').format(order.startDate!),
                style: const TextStyle(color: ThemeUtil.foregroundColor),
              ),
            ],
          ),
        ),
      );
    }
    dateWidgets.add(
      const SizedBox(height: 10),
    );
    if (order.endDate != null) {
      dateWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                width: FIELD_NAME_WIDTH,
                child: Text(
                  '结束日期',
                  style: TextStyle(color: ThemeUtil.foregroundColor),
                ),
              ),
              Text(
                DateFormat('yyyy年MM月dd日').format(order.endDate!),
                style: const TextStyle(color: ThemeUtil.foregroundColor),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: dateWidgets,
    );
  }

  Widget getCancelRuleTypeText() {
    if (order.cancelRuleType == null) {
      return const SizedBox();
    }
    OrderTravelCancelRuleType? status =
        OrderTravelCancelRuleTypeExt.getStatus(order.cancelRuleType!);
    if (status == null) {
      return const SizedBox();
    }
    String? statusText;
    switch (status) {
      case OrderTravelCancelRuleType.cancelledNot:
        statusText = '不可取消';
        break;
      case OrderTravelCancelRuleType.cancelled:
        statusText = '可取消';
        break;
      default:
    }
    if (statusText == null) {
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
                  '取消政策',
                  style: TextStyle(color: ThemeUtil.foregroundColor),
                ),
              ),
              Text(
                statusText,
                style: const TextStyle(color: ThemeUtil.foregroundColor),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget getPayStatusWidget() {
    if (order.orderStatus == null) {
      return const SizedBox();
    }
    OrderTravelStatus? status = OrderTravelStatusExt.getStatus(order.orderStatus!);
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
                status?.getText() ?? '订单出错',
                style: TextStyle(color: status?.getColor() ?? Colors.redAccent),
              )
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
                child: Text(
                  '失败原因',
                  style: TextStyle(color: ThemeUtil.foregroundColor),
                ),
              ),
              Text(
                order.unfinishedReason!,
                style: const TextStyle(color: ThemeUtil.foregroundColor),
              )
            ],
          ),
        ) : const SizedBox()
      ],
    );
  }

  Future onPaySuccess() async{
    ToastUtil.hint('支付成功');
    if(order.id != null){
      OrderTravel? updatedOrder = await OrderNeoApi().getOrderTravel(id: order.id!);
      if(updatedOrder != null){
        order = updatedOrder;
      }
    }
    Future.delayed(const Duration(seconds: 3), (){
      if(mounted && context.mounted){
        Navigator.of(context).pop(order);
      }
    });
  }

  Widget getActionWidget() {
    OrderTravelStatus? orderStatus;
    if(order.orderStatus != null){
      orderStatus = OrderTravelStatusExt.getStatus(order.orderStatus!);
    }
    PayStatus? payStatus;
    if(order.payStatus != null){
      payStatus = PayStatusExt.getStatus(order.payStatus!);
    }
    OrderTravelCancelRuleType? cancelRuleType;
    if(order.cancelRuleType != null){
      cancelRuleType = OrderTravelCancelRuleTypeExt.getStatus(order.cancelRuleType!);
    }
    bool showPay = false;
    bool showCancel = false;
    bool showRefund = false;
    if(payStatus == PayStatus.unpaid){
      showPay = true;
      showCancel = true;
    }
    if(cancelRuleType == OrderTravelCancelRuleType.cancelled && orderStatus?.canRefund() == true){
      if(order.cancelLatestTime == null || DateTime.now().isBefore(order.cancelLatestTime!)){
        showRefund = true;
      }
    }
    if(showPay || showCancel || showRefund){
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
                  if(order.orderSerial == null){
                    ToastUtil.error('数据错误');
                    return;
                  }
                  bool result = await TravelApi().cancel(orderSerial: order.orderSerial!);
                  if(result){
                    ToastUtil.hint('取消中');
                    order.orderStatus = OrderTravelStatus.canceling.getNum();
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
            const SizedBox(),
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
                  if(order.orderSerial == null){
                    ToastUtil.error('数据错误');
                    return;
                  }
                  PayType? payType = await PayTypeChooseUtil().choose(context);
                  if(payType == null){
                    return;
                  }
                  if(payType == PayType.wechat){
                    String? payInfo = await TravelApi().pay(orderSerial: order.orderSerial!, payType: PayType.wechat, fail: (response){
                      ToastUtil.error(response.data['message'] ?? '微信预下单失败');
                    });
                    if(payInfo == null){
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
                    String? payInfo = await OrderPayApi().payByAlipay(orderSerial: order.orderSerial!);
                    if(payInfo == null){
                      ToastUtil.error('支付宝预下单失败');
                      return;
                    }
                    bool result = await OrderPayUtil().alipay(payInfo);
                    if(result){
                      onPaySuccess();
                    }
                    else{
                      ToastUtil.error('支付失败');
                    }
                  }
                },
                child: const Text('支 付', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),),
              ),
            ),
            if(showRefund)
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
                    ToastUtil.error('数据错误');
                    return;
                  }
                  bool result = await TravelApi().refund(orderSerial: order.orderSerial!, fail: (response){
                    String message = response.data['message'] ?? '退订失败';
                    ToastUtil.warn(message);
                  });
                  if(result){
                    ToastUtil.hint('退订成功');
                    order.orderStatus = OrderTravelStatus.refunding.getNum();
                    if(mounted && context.mounted){
                      setState(() {
                      });
                    }
                  }
                },
                child: const Text('退 订', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox();
  }
}

extension MyOrderTravelStatusExt on OrderTravelStatus{

  Color getColor(){
    switch(this){
      case OrderTravelStatus.unpaid:
        return Colors.lightGreen;
      case OrderTravelStatus.unconfirmed:
      case OrderTravelStatus.confirmed:
      case OrderTravelStatus.servicing:
        return Colors.lightBlue;
      case OrderTravelStatus.completed:
        return const Color.fromRGBO(249, 168, 37, 1);
      case OrderTravelStatus.canceling:
      case OrderTravelStatus.canceled:
        return Colors.grey;
      default:
        return Colors.redAccent;
    }
  }
}