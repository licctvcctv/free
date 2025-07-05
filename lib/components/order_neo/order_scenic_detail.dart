
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/chat_neo/chat_common.dart';
import 'package:freego_flutter/components/chat_neo/chat_room.dart';
import 'package:freego_flutter/components/chat_neo/chat_util.dart';
import 'package:freego_flutter/components/order_neo/order_common.dart';
import 'package:freego_flutter/components/order_neo/api/order_neo_api.dart';
import 'package:freego_flutter/components/order_neo/api/order_pay_api.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/components/product_neo/product_source.dart';
import 'package:freego_flutter/components/scenic/api/panhe_scenic_api.dart';
import 'package:freego_flutter/components/scenic/api/scenic_api.dart';
import 'package:freego_flutter/components/scenic/scenic_buy_notice_freego.dart';
import 'package:freego_flutter/components/scenic/scenic_common.dart';
import 'package:freego_flutter/components/scenic/scenic_home_freego.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/util/pay_util_neo.dart';
import 'package:freego_flutter/util/paytype_choose_util.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:intl/intl.dart';

class OrderScenicDetailPage extends StatelessWidget{
  final OrderScenic order;
  const OrderScenicDetailPage(this.order, {super.key});

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
      body: OrderScenicDetailWidget(order),
    );
  }
  
}

class OrderScenicDetailWidget extends StatefulWidget{
  final OrderScenic order;
  const OrderScenicDetailWidget(this.order, {super.key});

  @override
  State<StatefulWidget> createState() {
    return OrderScenicDetailState();
  }
  
}

class OrderScenicDetailState extends State<OrderScenicDetailWidget> with SingleTickerProviderStateMixin{

  Widget svgScenic = SvgPicture.asset('svg/icon_scenic.svg', color: ThemeUtil.foregroundColor,);
  bool showTimeLimit = false;
  Timer? payLimitTimer;
  int payLimitSeconds = 0;

  static const double FIELD_NAME_WIDTH = 100;

  Widget svgQuestion = SvgPicture.asset('svg/question.svg', color: Colors.lightBlue,);

  late AnimationController rightMenuAnim;
  bool rightMenuShow = false;
  static const int RIGHT_MENU_ANIM_MILLI_SECONDS = 150;
  static const double RIGHT_MENU_WIDTH = 100;
  static const double RIGHT_MENU_ITEM_HEIGHT = 40;

  late OrderScenic order;

  @override
  void dispose(){
    payLimitTimer?.cancel();
    rightMenuAnim.dispose();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    order = widget.order;

    if(order.orderStatus != null){
      OrderScenicStatus? status = OrderScenicStatusExt.getStatus(order.orderStatus!);
      if(status == OrderScenicStatus.unpaid){
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

    rightMenuAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: RIGHT_MENU_ANIM_MILLI_SECONDS));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeUtil.backgroundColor,
      child: Stack(
        children: [
          Column(
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
                right: TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap
                  ),
                  onPressed: (){
                    if(!rightMenuShow){
                      rightMenuAnim.forward();
                    }
                    else{
                      rightMenuAnim.reverse();
                    }
                    rightMenuShow = !rightMenuShow;
                    setState(() {
                    });
                  },
                  child: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 32,),
                ),
              ),
              Expanded(
                child: ListView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.zero,
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
                                        if(order.scenicId == null && (order.outerScenicId == null || order.source == null)){
                                          return;
                                        }
                                        Scenic? scenic = await ScenicApi().detail(id: order.scenicId, outerId: order.outerScenicId, source: order.source);
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
                          order.travelDate != null ?
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
                          ) : const SizedBox(),
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
                          order.drawAddress != null && order.drawAddress!.isNotEmpty ?
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
                          ) : const SizedBox(),
                          const Divider(),
                          getContactWidget(),
                          getGuestWidget(),
                          getPayStatusWidget(),
                          getVoucherWidget(),
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
          rightMenuShow ?
          Positioned.fill(
            child: InkWell(
              onTap: (){
                rightMenuShow = false;
                rightMenuAnim.reverse();
                setState(() {
                });
              },
            ),
          ) : const SizedBox(),
          Positioned(
            top: CommonHeader.HEADER_HEIGHT,
            right: 0,
            child: AnimatedBuilder(
              animation: rightMenuAnim,
              builder: (context, child) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: rightMenuAnim.value * RIGHT_MENU_ITEM_HEIGHT
                  ),
                  child: Wrap(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap
                        ),
                        onPressed: (){
                          Navigator.of(context).push(MaterialPageRoute(builder: (context){
                            return ScenicBuyNoticePage(scenicName: order.scenicName, bookNotice: order.bookNotice, refundChangeRule: order.refundChangeRule, costDescription: order.costDescription, useDescription: order.useDescription, otherDescription: order.otherDescription,);
                          }));
                          rightMenuAnim.reverse();
                          rightMenuShow = false;
                          setState(() {
                          });
                        },
                        child: Container(
                          width: RIGHT_MENU_WIDTH,
                          height: RIGHT_MENU_ITEM_HEIGHT,
                          decoration: const BoxDecoration(
                            color: ThemeUtil.backgroundColor,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(12)
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 2
                              )
                            ]
                          ),
                          alignment: Alignment.center,
                          child: const Text('门票信息', style: TextStyle(color: ThemeUtil.foregroundColor),),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget getVoucherWidget(){
    OrderScenicStatus? orderStatus;
    PayStatus? payStatus;
    if(order.payStatus != null){
      payStatus = PayStatusExt.getStatus(order.payStatus!);
    }
    if(order.orderStatus != null){
      orderStatus = OrderScenicStatusExt.getStatus(order.orderStatus!);
    }
    if(payStatus != PayStatus.paid || orderStatus == OrderScenicStatus.unsubscribed){
      return const SizedBox();
    }
    
    String? voucherCode = order.voucherCode;
    String? voucherUrl = order.voucherUrl;
    String? providerNo = order.confirmOrderId;
    if(voucherCode == null && voucherUrl == null && providerNo == null){
      return const SizedBox();
    }
    if(voucherUrl != null){
      if(!voucherUrl.startsWith('http')){
        voucherUrl = getFullUrl(voucherUrl);
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        if(voucherCode != null) 
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: FIELD_NAME_WIDTH,
                child: Text('凭证码'),
              ),
              Expanded(
                child: Text(voucherCode, style: const TextStyle(color: ThemeUtil.foregroundColor),)
              )
            ],
          ),
        ),
        if(voucherUrl != null)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: FIELD_NAME_WIDTH,
                child: Text('二维码'),
              ),
              SizedBox(
                height: 120,
                width: 120,
                child: Image.network(
                  voucherUrl,
                  width: 120,
                  height: 120,
                  fit: BoxFit.fill,
                  errorBuilder:(context, error, stackTrace) {
                    return const Icon(Icons.error_outline, color: ThemeUtil.foregroundColor,);
                  },
                ),
              )
            ],
          ),
        ),
        if(providerNo != null) 
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: FIELD_NAME_WIDTH,
                child: Text('确认单号'),
              ),
              Expanded(
                child: Text(providerNo, style: const TextStyle(color: ThemeUtil.foregroundColor),)
              )
            ],
          ),
        ),
      ],
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
              child: Text('游客', style: TextStyle(color: ThemeUtil.foregroundColor),),
            ),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for(OrderGuest guest in guestList)
                Text('${guest.name}${guest.cardNo == null ? '' : '(${guest.cardNo})'}', style: const TextStyle(color: ThemeUtil.foregroundColor),)
              ],
            )
          ],
        ),
        const Divider(),
      ],
    );
  }

  Widget getMerchantContactWidget(){
    if(order.merchantId == null){
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
            if(order.merchantId != null)
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
            ),
          ],
        )
      ],
    );
  }

  Widget getActionWidget(){
    PayStatus? payStatus;
    OrderScenicStatus? status;
    if(order.payStatus != null){
      payStatus = PayStatusExt.getStatus(order.payStatus!);
    }
    if(order.orderStatus != null){
      status = OrderScenicStatusExt.getStatus(order.orderStatus!);
    }
    bool showActionCancel = false;
    bool showActionPay = false;
    bool showActionRefund = false;
    if(payStatus == PayStatus.unpaid && status == OrderScenicStatus.unpaid){
      showActionCancel = true;
      showActionPay = true;
    }
    if(payStatus == PayStatus.paid && status == OrderScenicStatus.drawn){
      showActionRefund = true;
    }
    if(showActionRefund || showActionCancel || showActionPay){
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
                  String? message;
                  bool result = await OrderNeoApi().refund(orderSerial: order.orderSerial!, orderType: ProductType.scenic, source: order.source, fail: (response){
                    message = response.data['message'] ?? '退订失败';
                  });
                  message ??= '退订失败';
                  if(result){
                    ToastUtil.hint('退订成功');
                    order.orderStatus = OrderScenicStatus.unsubscribing.getNum();
                    if(mounted && context.mounted){
                      setState(() {
                      });
                    }
                  }
                  else{
                    ToastUtil.warn(message!);
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
                  bool result = await ScenicApi().cancel(order: order, fail: (response){
                    Object? message = response.data['message'];
                    ToastUtil.warn(message?.toString() ?? '取消失败');
                  });
                  if(result){
                    ToastUtil.hint('取消中');
                    payLimitTimer?.cancel();
                    payLimitTimer = null;
                    order.orderStatus = OrderScenicStatus.canceled.getNum();
                    order.payStatus = OrderScenicStatus.canceled.getNum();
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

  Future onPaySuccess() async{
    ToastUtil.hint('支付成功');
    if(order.id != null){
      OrderScenic? updatedOrder = await OrderNeoApi().getOrderScenic(id: order.id!);
      if(updatedOrder != null){
        order = updatedOrder;
      }
    }
    Future.delayed(const Duration(seconds: 3), () {
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

  Widget getPayStatusWidget(){
    if(order.orderStatus == null){
      return const SizedBox();
    }
    OrderScenicStatus? status = OrderScenicStatusExt.getStatus(order.orderStatus!);
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
        ) : const SizedBox(),
      ],
    );
  }

  Widget getContactWidget(){
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
        order.contactName != null ?
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
        ) : const SizedBox(),
        order.contactPhone != null ?
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
        ) : const SizedBox(),
        cardType != null && cardType != CardType.none ?
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
        ) : const SizedBox(),
        order.contactCardNo != null ?
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
        ) : const SizedBox(),
        const Divider()
      ]
    );
  }
}

extension MyOrderScenicStatus on OrderScenicStatus{
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
