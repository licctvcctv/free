
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/chat_neo/chat_common.dart';
import 'package:freego_flutter/components/chat_neo/chat_room.dart';
import 'package:freego_flutter/components/chat_neo/chat_util.dart';
import 'package:freego_flutter/components/hotel_neo/api/hotel_api.dart';
import 'package:freego_flutter/components/hotel_neo/hotel_common.dart' hide HotelPayType;
import 'package:freego_flutter/components/hotel_neo/hotel_home_freego.dart';
import 'package:freego_flutter/components/order_neo/order_common.dart';
import 'package:freego_flutter/components/order_neo/api/order_neo_api.dart';
import 'package:freego_flutter/components/order_neo/api/order_pay_api.dart';
import 'package:freego_flutter/components/order_neo/order_home.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/components/product_neo/product_source.dart';
import 'package:freego_flutter/components/scenic/api/panhe_scenic_api.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/util/pay_util_neo.dart';
import 'package:freego_flutter/util/paytype_choose_util.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderHotelDetailPage extends StatelessWidget{
  final OrderHotel order;
  const OrderHotelDetailPage(this.order, {super.key});

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
      body: OrderHotelDetailWidget(order),
    );
  }
  
}

class OrderHotelDetailWidget extends StatefulWidget{
  final OrderHotel order;
  const OrderHotelDetailWidget(this.order, {super.key});

  @override
  State<StatefulWidget> createState() {
    return OrderHotelDetailState();
  }

}

class OrderHotelDetailState extends State<OrderHotelDetailWidget>{

  static const double FIELD_NAME_WIDTH = 100;

  Widget svgHotel = SvgPicture.asset('svg/icon_hotel.svg', color: ThemeUtil.foregroundColor,);
  bool showTimeLimit = false;
  Timer? payLimitTimer;
  int payLimitSeconds = 0;

  Widget svgQuestion = SvgPicture.asset('svg/question.svg', color: Colors.lightBlue,);

  late OrderHotel order;

  @override
  void dispose(){
    payLimitTimer?.cancel();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    order = widget.order;

    if(order.orderStatus != null){
      OrderHotelStatus? status = OrderHotelStatusExt.getStatus(order.orderStatus!);
      if(status == OrderHotelStatus.unpaid){
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
            center: const Text('订单详情', style: TextStyle(color: Colors.white, fontSize: 18),),
          ),
          Expanded(
            child: ListView(
              physics: const ClampingScrollPhysics(),
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
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
                                  child: svgHotel,
                                ),
                                const SizedBox(height: 10,),
                                InkWell(
                                  onTap: () async{
                                    int? hotelId = order.hotelId;
                                    if(hotelId == null && (order.outerHotelId == null || order.source == null)){
                                      return;
                                    }
                                    DateTime startDate = DateTime.now();
                                    startDate = DateTime(startDate.year, startDate.month, startDate.day);
                                    DateTime endDate = startDate.add(const Duration(days: 1));
                                    Hotel? hotel = await HotelApi().detail(id: hotelId, outerId: order.outerHotelId, source: order.source, startDate: startDate, endDate: endDate);
                                    if(hotel != null){
                                      if(mounted && context.mounted){
                                        Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                          return HotelHomePage(hotel, startDate: startDate, endDate: endDate,);
                                        }));
                                      }
                                    }
                                  },
                                  child: Text('${order.hotelName}', textAlign: TextAlign.center, style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
                                ),
                                const SizedBox(height: 10,),
                                Text(order.chamberName ?? '', textAlign: TextAlign.center, style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold),),
                                const SizedBox(height: 10,),
                                Text(order.planName ?? '', textAlign: TextAlign.center, style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold),),
                                const SizedBox(height: 10,),
                                Text('￥${StringUtil.getPriceStr(order.amount)}', textAlign: TextAlign.center, style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold),),
                                payLimitSeconds > 0 && payLimitTimer != null ?
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
                      order.checkInDate != null ?
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Wrap(
                          children: [
                            const SizedBox(
                              width: FIELD_NAME_WIDTH,
                              child: Text('入住日期', style: TextStyle(color: ThemeUtil.foregroundColor),),
                            ),
                            Text(DateFormat('yyyy年MM月dd日').format(order.checkInDate!), style: const TextStyle(color: ThemeUtil.foregroundColor),)
                          ],
                        ),
                      ) : const SizedBox(),
                      order.checkOutDate != null ?
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Wrap(
                          children: [
                            const SizedBox(
                              width: FIELD_NAME_WIDTH,
                              child: Text('离店日期', style: TextStyle(color: ThemeUtil.foregroundColor),),
                            ),
                            Text(DateFormat('yyyy年MM月dd日').format(order.checkOutDate!), style: const TextStyle(color: ThemeUtil.foregroundColor),)
                          ],
                        ),
                      ) : const SizedBox(),
                      order.numberOfNights != null ?
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Wrap(
                          children: [
                            const SizedBox(
                              width: FIELD_NAME_WIDTH,
                              child: Text('入住晚数', style: TextStyle(color: ThemeUtil.foregroundColor),),
                            ),
                            Text('${order.numberOfNights}晚', style: const TextStyle(color: ThemeUtil.foregroundColor),)
                          ],
                        ),
                      ) : const SizedBox(),
                      order.numberOfRooms != null ?
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Wrap(
                          children: [
                            const SizedBox(
                              width: FIELD_NAME_WIDTH,
                              child: Text('预订数量', style: TextStyle(color: ThemeUtil.foregroundColor),),
                            ),
                            Text('${order.numberOfRooms}间', style: const TextStyle(color: ThemeUtil.foregroundColor),)
                          ],
                        ),
                      ) : const SizedBox(),
                      getDayPriceWidget(),
                      getCancelRuleWidget(),
                      getContactWidget(),
                      getGuestWidget(),
                      getPayStatusWidget(),
                      getMerchantContactWidget(),
                    ],
                  ),
                ),
              ]
            )
          ),
          getActionWidget()
        ],
      ),
    );
  }

  Widget getGuestWidget(){
    List<OrderGuest>? guestList = order.guestList;
    if(guestList == null || guestList.isEmpty){
      return const SizedBox();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8,),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: FIELD_NAME_WIDTH,
              child: Text('入住人', style: TextStyle(color: ThemeUtil.foregroundColor),),
            ),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for(OrderGuest guest in guestList)
                Text(guest.name ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor),)
              ],
            )
          ],
        ),
        const Divider(),
      ],
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

  Future onPaySuccess() async{
    ToastUtil.hint('支付成功');
    if(order.id != null){
      OrderHotel? updatedOrder = await OrderNeoApi().getOrderHotel(id: order.id!);
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

  Future payLocal() async{
    if(order.orderSerial == null){
      ToastUtil.error('数据错误');
      return;
    }
    PayType? payType = await PayTypeChooseUtil().choose(context);
    if(payType == null){
      return;
    }
    if(payType == PayType.wechat){
      String? payInfo = await OrderPayApi().payByWechat(orderSerial: order.orderSerial!);
      if(payInfo == null){
        ToastUtil.error('微信预下单失败');
        return;
      }
      PayUtilNeo().wechatPay(
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
      bool result = await PayUtilNeo().alipay(payInfo);
      if(result){
        ToastUtil.hint('支付成功');
        onPaySuccess();
      }
      else{
        ToastUtil.error('支付失败');
      }
    }
  }

  Future payPanhe() async{
    if(order.orderSerial == null){
      ToastUtil.error('数据错误');
      return;
    }
    PayType? payType = await PayTypeChooseUtil().choose(context);
    if(payType == null){
      return;
    }
    if(payType == PayType.alipay){
      String? payInfo = await PanheScenicApi().pay(orderSerial: order.orderSerial!, payType: payType.getName());
      if(payInfo == null){
        ToastUtil.error('支付宝预下单失败');
        return;
      }
      bool result = await PayUtilNeo().alipay(payInfo);
      if(result){
        onPaySuccess();
      }
      else{
        ToastUtil.error('支付失败');
      }
    }
    else if(payType == PayType.wechat){
      String? payInfo = await PanheScenicApi().pay(orderSerial: order.orderSerial!, payType: payType.getName());
      if(payInfo == null){
        ToastUtil.error('微信预下单失败');
        return;
      }
      PayUtilNeo().wechatPay(
        payInfo, 
        onSuccess: onPaySuccess,
      );
    }
  }

  Widget getActionWidget(){
    PayStatus? payStatus;

    if(order.payStatus != null){
      payStatus = PayStatusExt.getStatus(order.payStatus!);
    }
    OrderHotelStatus? status;
    if(order.orderStatus != null){
      status = OrderHotelStatusExt.getStatus(order.orderStatus!);
    }
    bool showActionCancel = false;
    bool showActionPay = false;
    bool showActionRefund = false;

    if(payStatus == PayStatus.unpaid && status == OrderHotelStatus.unpaid){
      showActionPay = true;
      showActionCancel = true;
    }
    if(payStatus == PayStatus.paid && status != null && status.canCancel() && order.cancelRuleType != null){
      CancelRuleType? cancelRuleType = CancelRuleTypeExt.getType(order.cancelRuleType!);
      if(cancelRuleType == CancelRuleType.inTime){
        if(order.cancelLatestTime != null && DateTime.now().isBefore(order.cancelLatestTime!)){
          showActionRefund = true;
        }
      }
      else if(cancelRuleType == CancelRuleType.charged){
        showActionRefund = true;
      }
    }
    if(showActionCancel || showActionRefund || showActionPay){
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
            if(showActionRefund)
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
                  bool result;
                  if(order.source == "local") {
                    // 调用新的退款接口
                    result = await OrderNeoApi().refundOrder(
                      orderNo: order.orderSerial!,
                      fail: (response) {
                        String message = response.data['message'] ?? '退订失败';
                        ToastUtil.warn(message);
                      },
                      success: (response) {
                        if (mounted) {
                          _showRefundSuccessDialog();
                        }
                      }
                    );
                  } else {
                  // 原有退款逻辑
                    result = await OrderNeoApi().refund(
                      orderSerial: order.orderSerial!, 
                      orderType: ProductType.hotel, 
                      source: order.source, 
                      fail: (response){
                        String message = response.data['message'] ?? '退订失败';
                        ToastUtil.warn(message);
                      }
                    );
                  }
                  if(result){
                    //ToastUtil.hint('退订成功');
                    order.orderStatus = OrderHotelStatus.canceling.getNum();
                    if(mounted && context.mounted){
                      setState(() {
                      });
                    }
                  }
                },
                child: const Text('退 订', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
              ),
            ),
            if(showActionCancel)
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
                  bool result = await HotelApi().cancel(order: order, fail: (response){
                    dynamic message = response.data['message'];
                    ToastUtil.warn(message?.toString() ?? '取消失败');
                  });
                  if(result){
                    ToastUtil.hint('取消中');
                    payLimitTimer?.cancel();
                    payLimitTimer = null;
                    order.orderStatus = OrderHotelStatus.canceled.getNum();
                    order.payStatus = PayStatus.canceled.getNum();
                    if(mounted && context.mounted){
                      setState(() {
                      });
                    }
                  }
                },
                child: const Text('取 消', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
              ),
            ),
            if(showActionPay)
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
                  ProductSource? source;
                  if(order.source != null){
                    source = ProductSourceExt.getSource(order.source!);
                  }
                  if(source == ProductSource.panhe){
                    payPanhe();
                  }
                  if(source == null){
                    payLocal();
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

  void _showRefundSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 用户必须点击按钮才能关闭
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('退订成功', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('您的订单已成功退订'),
          actions: [
            TextButton(
              child: Text('确定', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.of(context).pop(); // 关闭弹窗
                // 返回订单列表并刷新
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => OrderHomePage()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }
  
  Widget getPayStatusWidget(){
    if(order.orderStatus == null){
      return const SizedBox();
    }
    OrderHotelStatus? status = OrderHotelStatusExt.getStatus(order.orderStatus!);
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
              Text(status?.getText() ?? '订单出错', style: TextStyle(color: status?.getColor() ?? Colors.redAccent),)
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
                child: Text('说明', style: TextStyle(color: ThemeUtil.foregroundColor),),
              ),
              Text(order.unfinishedReason!, style: const TextStyle(color: ThemeUtil.foregroundColor),)
            ],
          ),
        ) : const SizedBox()
      ],
    );
  }
  Widget getContactWidget(){
    if(order.contactPhone == null && order.contactName == null && order.contactEmail == null){
      return const SizedBox();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        order.contactName != null ?
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            children: [
              const SizedBox(
                width: FIELD_NAME_WIDTH,
                child: Text('联系姓名', style: TextStyle(color: ThemeUtil.foregroundColor),),
              ),
              Text(order.contactName!, style: const TextStyle(color: ThemeUtil.foregroundColor),)
            ]
          ),
        ) : const SizedBox(),
        order.contactPhone != null ?
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            children: [
              const SizedBox(
                width: FIELD_NAME_WIDTH,
                child: Text('联系手机', style: TextStyle(color: ThemeUtil.foregroundColor),),
              ),
              Text(order.contactPhone!, style: const TextStyle(color: ThemeUtil.foregroundColor),)
            ],
          ),
        ) : const SizedBox(),
        order.contactEmail != null ?
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            children: [
              const SizedBox(
                width: FIELD_NAME_WIDTH,
                child: Text('联系邮箱', style: TextStyle(color: ThemeUtil.foregroundColor),),
              ),
              Text(order.contactEmail!, style: const TextStyle(color: ThemeUtil.foregroundColor),)
            ],
          ),
        ): const SizedBox(),
        const Divider()
      ],
    );
  }

  Widget getCancelRuleWidget(){
    if(order.cancelRuleType == null){
      return const SizedBox();
    }
    CancelRuleType? cancelRuleType = CancelRuleTypeExt.getType(order.cancelRuleType!);
    if(cancelRuleType == null){
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: FIELD_NAME_WIDTH,
                child: Text('取消政策', style: TextStyle(color: ThemeUtil.foregroundColor),),
              ), 
              cancelRuleType == CancelRuleType.unable ?
              const Text('无法取消', style: TextStyle(color: ThemeUtil.foregroundColor),) :
              cancelRuleType == CancelRuleType.inTime ?
              const Text('限时免费取消', style: TextStyle(color: ThemeUtil.foregroundColor),) :
              cancelRuleType == CancelRuleType.charged ?
              const Text('收费取消', style: TextStyle(color: ThemeUtil.foregroundColor),) :
              const SizedBox()
            ],
          ),
          order.cancelRuleDesc != null ?
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(order.cancelRuleDesc!, style: const TextStyle(color: ThemeUtil.foregroundColor),),
          ) : const SizedBox(),
          order.cancelLatestTime != null ?
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                const Text('免费取消时间', style: TextStyle(color: ThemeUtil.foregroundColor),),
                const SizedBox(width: 10,),
                Text(DateFormat('yyyy-MM-dd HH:mm').format(order.cancelLatestTime!), style: const TextStyle(color: ThemeUtil.foregroundColor),),
              ],
            )
          ) : const SizedBox(),
          const Divider()
        ],
      ),
    );
  }

  Widget getDayPriceWidget(){
    DateTime? checkInDate = order.checkInDate;
    if(checkInDate == null){
      return const SizedBox();
    }
    if(order.priceArr == null || order.priceArr!.isEmpty){
      return const SizedBox();
    }
    List<String> priceList = order.priceArr!.split(',');
    if(priceList.length != order.numberOfNights){
      return const SizedBox();
    }
    List<Widget> widgets = [];
    for(int i = 0; i < order.numberOfNights!; ++i){
      DateTime date = checkInDate.add(Duration(days: i));
      int? priceVal = int.tryParse(priceList[i]);
      if(priceVal == null){
        continue;
      }
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            children: [
              SizedBox(
                width: FIELD_NAME_WIDTH,
                child: Text(DateFormat('yyyy-MM-dd').format(date), style: const TextStyle(color: ThemeUtil.foregroundColor),),
              ),
              Text('￥${StringUtil.getPriceStr(priceVal)}', style: const TextStyle(color: ThemeUtil.foregroundColor),)
            ],
          ),
        )
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: FIELD_NAME_WIDTH,
            child: Text('每日价格', style: TextStyle(color: ThemeUtil.foregroundColor),),
          ), 
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widgets,
          ),
          const Divider()
        ],
      ),
    );
  }
}

extension MyOrderHotelStatusExt on OrderHotelStatus{
  Color getColor(){
    switch(this){
      case OrderHotelStatus.unpaid:
        return Colors.lightGreen;
      case OrderHotelStatus.unconfirmed:
      case OrderHotelStatus.confirmed:
      case OrderHotelStatus.servicing:
        return Colors.lightBlue;
      case OrderHotelStatus.completed:
        return const Color.fromRGBO(249, 168, 37, 1);
      case OrderHotelStatus.canceling:
      case OrderHotelStatus.canceled:
        return Colors.grey;
      default:
        return Colors.redAccent;
    }
  }
}