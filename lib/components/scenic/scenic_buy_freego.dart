
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/merchent/merchant_api.dart';
import 'package:freego_flutter/components/order_neo/order_common.dart';
import 'package:freego_flutter/components/product_neo/product_source.dart';
import 'package:freego_flutter/components/scenic/api/panhe_scenic_api.dart';
import 'package:freego_flutter/components/scenic/scenic_buy_notice_freego.dart';
import 'package:freego_flutter/components/scenic/scenic_common.dart';
import 'package:freego_flutter/components/scenic/api/local_scenic_api.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/date_choose_view.dart';
import 'package:freego_flutter/model/user.dart';
import 'package:freego_flutter/util/comming_soon.dart';
import 'package:freego_flutter/util/date_choose_util.dart';
import 'package:freego_flutter/util/local_user.dart';
import 'package:freego_flutter/util/native_calendar_util.dart';
import 'package:freego_flutter/util/pay_util_neo.dart';
import 'package:freego_flutter/util/regular_util.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:intl/intl.dart';

class ScenicBuyPage extends StatelessWidget{

  final Scenic scenic;
  final ScenicTicket ticket;
  const ScenicBuyPage({required this.scenic, required this.ticket, super.key});
  
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
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: ScenicBuyWidget(scenic: scenic, ticket: ticket,),
      ),
    );
  }

}

class ScenicBuyWidget extends StatefulWidget{
  final Scenic scenic;
  final ScenicTicket ticket;
  const ScenicBuyWidget({required this.scenic, required this.ticket, super.key});

  @override
  State<StatefulWidget> createState() {
    return ScenicBuyState();
  }

}

class ScenicBuyState extends State<ScenicBuyWidget> with SingleTickerProviderStateMixin{

  late DateTime firstDate;
  late DateTime lastDate;
  DateTime? tourDate;

  List<ScenicTicketPrice> priceList = [];

  late int orderNum;
  TextEditingController numController = TextEditingController();
  FocusNode numFocus = FocusNode();

  TouristInfoType? touristInfoType;
  List<CardType> supportCardList = [];
  List<OrderGuest> guestList = [];

  TextEditingController guestNameController = TextEditingController();
  TextEditingController guestPhoneController = TextEditingController();
  TextEditingController guestCardNoController = TextEditingController();

  ScrollController scrollController = ScrollController();
  PayType? payType;

  ContactInfoType? contactInfoType;
  TextEditingController contactNameController = TextEditingController();
  TextEditingController contactPhoneController = TextEditingController();
  TextEditingController contactCardNoController = TextEditingController();
  CardType? contactCardType;

  late AnimationController rightMenuAnim;
  bool rightMenuShow = false;
  static const int RIGHT_MENU_ANIM_MILLI_SECONDS = 150;
  static const double RIGHT_MENU_WIDTH = 100;
  static const double RIGHT_MENU_ITEM_HEIGHT = 40;

  List<PayType> payTypes = [PayType.wechat, PayType.alipay];

  @override
  void dispose(){
    numController.dispose();
    numFocus.dispose();
    guestNameController.dispose();
    guestPhoneController.dispose();
    guestCardNoController.dispose();
    scrollController.dispose();
    contactNameController.dispose();
    contactPhoneController.dispose();
    contactCardNoController.dispose();
    rightMenuAnim.dispose();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    numFocus.addListener(() {
      if(!numFocus.hasFocus){
        String val = numController.text;
        val = val.replaceAll(RegExp(r'[^0-9]'), '');
        val = val.replaceAll(RegExp(r'^0*'), '');
        orderNum = int.tryParse(val) ?? 1;
        if(widget.ticket.minBuyCount != null && orderNum < widget.ticket.minBuyCount!){
          orderNum = widget.ticket.minBuyCount!;
        }
        if(widget.ticket.maxBuyCount != null && orderNum > widget.ticket.maxBuyCount!){
          orderNum = widget.ticket.maxBuyCount!;
        }
        numController.text = '$orderNum';
        resetState();
      }
    });
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    firstDate = today.copyWith();
    ScenicTicket ticket = widget.ticket;
    if(ticket.advanceTime != null){
      DateTime? result = DateTime.tryParse(DateFormat('yyyy-MM-dd ').format(firstDate) + ticket.advanceTime!);
      if(result != null){
        if(now.isAfter(result)){
          firstDate = firstDate.add(const Duration(days: 1));
        }
      }
    }
    if(ticket.advanceDay != null && ticket.advanceDay! > 0){
      firstDate = firstDate.add(Duration(days: ticket.advanceDay!));
    }
    lastDate = firstDate.subtract(const Duration(days: 1));
    Future.delayed(Duration.zero, () async{
      if(ticket.priceCalendar != null){
        priceList = ticket.priceCalendar!;
      }
      else if(ticket.id != null){
        List<ScenicTicketPrice>? tmpList = await LocalScenicApi().getPriceList(ticketId: ticket.id!, startDate: firstDate, endDate: firstDate.add(const Duration(days: 30)));
        if(tmpList != null){
          priceList = tmpList;
        }
      }
      if(priceList.isNotEmpty){
        if(priceList.last.date != null){
          lastDate = priceList.last.date!;
        }
        if(priceList.first.date != null){
          firstDate = priceList.first.date!;
        }
        tourDate = firstDate.copyWith();
      }
      else{
        tourDate = null;
      }
      if(mounted && context.mounted){
        setState(() {
        });
      }
    });

    orderNum = 1;
    if(ticket.minBuyCount != null){
      orderNum = ticket.minBuyCount!;
    }
    numController.text = '$orderNum';

    if(ticket.touristInfoType != null){
      touristInfoType = TouristInfoTypeExt.getType(ticket.touristInfoType!);
    }
    
    if(ticket.supportCardTypes != null){
      List<String> supportCardTypeStringList = ticket.supportCardTypes!.split(',');
      for(String val in supportCardTypeStringList){
        int? num = int.tryParse(val);
        if(num != null){
          CardType? cardType = CardTypeExt.getType(num);
          if(cardType != null){
            supportCardList.add(cardType);
          }
        }
      }
    }

    if(ticket.contactInfoType != null){
      contactInfoType = ContactInfoTypeExt.getType(ticket.contactInfoType!);
    }

    rightMenuAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: RIGHT_MENU_ANIM_MILLI_SECONDS));

    UserModel? user = LocalUser.getUser();
    if(user != null){
      contactNameController.text = user.name ?? '';
      contactPhoneController.text = user.phone ?? '';
    }

    ProductSource? source = ProductSourceExt.getSource(widget.scenic.source ?? '');
    if(source == ProductSource.local){
      Future.delayed(Duration.zero, () async{
        payTypes = await MerchantApi().listPayTypes(merchantId: widget.scenic.userId ?? 0) ?? [];
      });
    }
  }

  void resetState(){
    if(mounted && context.mounted){
      setState((){});
    }
  }

  @override
  Widget build(BuildContext context) {
    Scenic scenic = widget.scenic;
    ScenicTicket ticket = widget.ticket;
    return Container(
      color: ThemeUtil.backgroundColor,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonHeader(
                center: Text(scenic.name ?? '', style: const TextStyle(color: Colors.white, fontSize: 18),),
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
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  physics: const ClampingScrollPhysics(),
                  children: [
                    getInfoWidget(),
                    getDateChooseWidget(),
                    getBookNumWidet(),
                    getGuestInfoWidget(),
                    getContactInfoWidget(),
                    getPayTypeChooseWidget(),
                  ],
                ),
              ),
              getFooterWidget(),
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
                            return ScenicBuyNoticePage(scenicName: scenic.name, bookNotice: ticket.bookNotice, refundChangeRule: ticket.refundChangeRule, costDescription: ticket.costDescription, useDescription: ticket.useDescription, otherDescription: ticket.otherDescription,);
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

  Future buyLocal() async{
    ScenicTicket ticket = widget.ticket;
    String contactName = contactNameController.text.trim();
    String contactPhone = contactPhoneController.text.trim();
    String contactCardNo = contactCardNoController.text.trim();

    String? orderSerial = await LocalScenicApi().order(
      ticketId: ticket.id!, 
      travelDate: tourDate!, 
      quantity: orderNum, 
      guestList: guestList,
      contactName: contactName,
      contactPhone: contactPhone,
      contactCardType: contactCardType?.getNum(),
      contactCardNo: contactCardNo.isEmpty ? null : contactCardNo
    );
    if(orderSerial == null){
      ToastUtil.error('预下单失败');
      return;
    }
    if(payType == PayType.alipay){
      if(!payTypes.contains(PayType.alipay)){
        ToastUtil.warn('商家未开通支付宝');
        return;
      }
      String? payInfo = await LocalScenicApi().pay(orderSerial: orderSerial, payType: PayType.alipay);
      if(payInfo == null){
        ToastUtil.error('支付宝预下单失败');
        return;
      }
      bool result = await PayUtilNeo().alipay(payInfo);
      if(result){
        ToastUtil.hint('支付成功');
        await createScenicEvent();
        Future.delayed(const Duration(seconds: 3), () async{
          if(mounted && context.mounted){
            Navigator.of(context).pop();
          }
        });
      }
    }
    else if(payType == PayType.wechat){
      if(!payTypes.contains(PayType.wechat)){
        ToastUtil.warn('商家未开通微信支付');
        return;
      }
      String? payInfo = await LocalScenicApi().pay(orderSerial: orderSerial, payType: PayType.wechat, fail: (response){
        String? message = response.data['message'];
        ToastUtil.error(message ?? '微信预下单失败');
      });
      if(payInfo == null){
        return;
      }
      PayUtilNeo().wechatPay(
        payInfo, 
        onSuccess: () async{
          ToastUtil.hint('支付成功');
          await createScenicEvent();
          Future.delayed(const Duration(seconds: 3), () async{
            if(mounted && context.mounted){
              Navigator.of(context).pop();
            }
          });
        },
      );
    }
  }

  Future buyPanhe() async{
    Scenic scenic = widget.scenic;
    ScenicTicket ticket = widget.ticket;

    String contactName = contactNameController.text.trim();
    String contactPhone = contactPhoneController.text.trim();
    String contactCardNo = contactCardNoController.text.trim();

    String? orderSerial = await PanheScenicApi().order(
      scenicId: scenic.outerId!, 
      ticketId: ticket.outerId!, 
      quantity: orderNum, 
      travelDate: tourDate!, 
      contactName: contactName, 
      contactPhone: contactPhone,
      contactCardType: contactCardType?.getNum(),
      contactCardNo: contactCardNo,
      orderGuest: guestList,
      fail: (response){
        String? msg = response.data['message'];
        ToastUtil.error(msg ?? '预下单失败');
      }
    );
    if(orderSerial == null){
      return;
    }
    if(payType == PayType.alipay){
      String? payInfo = await PanheScenicApi().pay(orderSerial: orderSerial, payType: payType!.getName());
      if(payInfo == null){
        ToastUtil.error('支付宝预下单失败');
        return;
      }
      bool result = await PayUtilNeo().alipay(payInfo);
      if(result){
        ToastUtil.hint('支付成功');
        await createScenicEvent();
        Future.delayed(const Duration(seconds: 3), () async{
          if(mounted && context.mounted){
            Navigator.of(context).pop();
          }
        });
      }
    }
    else if(payType == PayType.wechat){
      String? payInfo = await PanheScenicApi().pay(orderSerial: orderSerial, payType: payType!.getName());
      if(payInfo == null){
        ToastUtil.error('微信预下单失败');
        return;
      }
      PayUtilNeo().wechatPay(
        payInfo, 
        onSuccess: () async{
          ToastUtil.hint('支付成功');
          await createScenicEvent();
          Future.delayed(const Duration(seconds: 3), () async{
            if(mounted && context.mounted){
              Navigator.of(context).pop();
            }
          });
        },
      );
    }
  }

  Widget getFooterWidget(){
    int? total;
    if(tourDate != null){
      for(ScenicTicketPrice item in priceList){
        if(item.date != null && item.date!.compareTo(tourDate!) == 0){
          total = item.settlePrice;
          break;
        }
      }
    }
    if(total != null){
      total = total * orderNum;
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4
          )
        ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text('合计：', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
              total == null ?
              const Text('请选择游玩日期', style: TextStyle(color: Colors.grey),) :
              Text('￥${StringUtil.getPriceStr(total)}', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 18),),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap
            ),
            onPressed: () async{
              Scenic scenic = widget.scenic;
              ScenicTicket ticket = widget.ticket;
              ProductSource? source;
              if(scenic.source != null){
                source = ProductSourceExt.getSource(scenic.source!);
              }
              
              if(tourDate == null){
                ToastUtil.warn('请选择游玩日期');
                return;
              }
              int guestNum = 0;
              if(touristInfoType == TouristInfoType.singleNamePhone || touristInfoType == TouristInfoType.singleNamePhoneCard){
                guestNum = 1;
              }
              if(touristInfoType == TouristInfoType.everyNamePhone || touristInfoType == TouristInfoType.everyNamePhoneCard){
                guestNum = orderNum * (ticket.unitQuantity ?? 1);
              }
              if(guestNum != guestList.length){
                ToastUtil.warn('登记人数不足');
                return;
              }
              for(OrderGuest guest in guestList){
                if(guest.name == null || guest.name!.isEmpty){
                  ToastUtil.warn('请登记正确的姓名');
                  return;
                }
                if(guest.phone == null || guest.phone!.isEmpty || !RegularUtil.checkPhone(guest.phone!)){
                  ToastUtil.warn('请登记正确的手机号');
                  return;
                }
                if(touristInfoType == TouristInfoType.singleNamePhoneCard || touristInfoType == TouristInfoType.everyNamePhoneCard){
                  if(guest.cardNo == null || guest.cardNo!.isEmpty){
                    ToastUtil.warn('请登记正确的证件号');
                    return;
                  }
                }
              }
              String contactName = contactNameController.text.trim();
              String contactPhone = contactPhoneController.text.trim();
              String contactCardNo = contactCardNoController.text.trim();
              if(contactInfoType == ContactInfoType.namePhone || contactInfoType == ContactInfoType.namePhonwCard){
                if(contactName.isEmpty){
                  ToastUtil.warn('请填写取票人姓名');
                  return;
                }
                if(contactPhone.isEmpty){
                  ToastUtil.warn('请填写取票人手机号');
                  return;
                }
                if(contactInfoType == ContactInfoType.namePhonwCard){
                  if(contactCardType == null || contactCardType == CardType.none){
                    ToastUtil.warn('请填写取票人证件类型');
                    return;
                  }
                  if(contactCardNo.isEmpty){
                    ToastUtil.warn('请填写取票人证件号');
                    return;
                  }
                }
              }
              if(payType == null){
                ToastUtil.warn('请选择支付方式');
                return;
              }

              if(source == ProductSource.panhe){
                buyPanhe();
                return;
              }
              if(source == ProductSource.local){
                buyLocal();
              }
            },
            child: const Text('支 付', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),),
          )
        ],
      ),
    );
  }

  Future createScenicEvent() async{
    return;
    Event event = NativeCalendarUtil().makeEvent(title: 'Freego-快速游览', startTime: tourDate!, endTime: tourDate!, allDay: true, location: widget.scenic.name);
    return NativeCalendarUtil().showEventOption(context: context, eventList: [event], title: 'Freego-快速游览');
  }

  Widget getPayTypeChooseWidget(){
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('支付方式', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
          const SizedBox(height: 10,),
          InkWell(
            onTap: (){
              payType = PayType.alipay;
              setState((){});
            },
            child: Row(
              children: [
                Image.asset(
                  'images/pay_alipay.png',
                  height: 40,
                  width: 40,
                ),
                const SizedBox(width: 10,),
                const Text('支付宝支付', style: TextStyle(color: ThemeUtil.foregroundColor),),
                const Expanded(
                  child: SizedBox(),
                ),
                payType == PayType.alipay ? 
                const Icon(
                  Icons.radio_button_checked,
                  color: Colors.blue,
                ): 
                const Icon(
                  Icons.radio_button_unchecked,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          const Divider(),
          InkWell(
            onTap: (){
              payType = PayType.wechat;
              setState((){});
            },
            child: Row(
              children: [
                Image.asset(
                  'images/pay_weixin.png',
                  height: 40,
                  width: 40,
                ),
                const SizedBox(width: 10,),
                const Text("微信支付", style: TextStyle(color: ThemeUtil.foregroundColor),),
                const Expanded(
                  child: SizedBox(),
                ),
                payType == PayType.wechat ? 
                const Icon(
                  Icons.radio_button_checked,
                  color: Colors.blue,
                ): 
                const Icon(
                  Icons.radio_button_unchecked,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getContactInfoWidget(){
    if(contactInfoType == null || contactInfoType == ContactInfoType.none){
      return const SizedBox();
    }
    if(contactInfoType == ContactInfoType.namePhone || contactInfoType == ContactInfoType.namePhonwCard){
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
            const Text('取票联系人', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black12))
              ),
              child: TextField(
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  hintText: '姓 名',
                  hintStyle: TextStyle(color: Colors.grey),
                  isDense: true,
                  contentPadding: EdgeInsets.fromLTRB(8, 10, 8, 10),
                  border: InputBorder.none,
                ),
                controller: contactNameController,
              ),
            ),
            const SizedBox(height: 8,),
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black12))
              ),
              child: TextField(
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  hintText: '电 话',
                  hintStyle: TextStyle(color: Colors.grey),
                  isDense: true,
                  contentPadding: EdgeInsets.fromLTRB(8, 10, 8, 10),
                  border: InputBorder.none,
                ),
                controller: contactPhoneController,
              ),
            ),
            contactInfoType == ContactInfoType.namePhonwCard ? 
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8,),
                Container(
                  padding: const EdgeInsets.only(left: 7),
                  height: 44,
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.black12))
                  ),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('证件类型', style: TextStyle(color: contactCardType == null || contactCardType == CardType.none ? Colors.grey : ThemeUtil.foregroundColor, fontSize: 16),),
                      InkWell(
                        onTap: () async{
                          Object? result = await showCardType();
                          if(result is CardType){
                            contactCardType = result;
                            if(context.mounted){
                              setState((){});
                            }
                          }
                        },
                        child: 
                        contactCardType == null || contactCardType == CardType.none ?
                        const Text('请选择', style: TextStyle(color: Colors.grey, fontSize: 16),) :
                        Text(contactCardType!.getName(), style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),)
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 8,),
                Container(
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.black12))
                  ),
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      hintText: '证件号',
                      hintStyle: TextStyle(color: Colors.grey),
                      isDense: true,
                      contentPadding: EdgeInsets.fromLTRB(8, 10, 8, 10),
                      border: InputBorder.none,
                    ),
                    controller: contactCardNoController,
                  ),
                ),
              ],
            ) : const SizedBox()
          ],
        ),
      );
    }
    return const SizedBox();
  }

  Widget getGuestInfoWidget(){
    if(touristInfoType == TouristInfoType.none){
      return const SizedBox();
    }
    int guestNum = 1;
    if(touristInfoType == TouristInfoType.everyNamePhone || touristInfoType == TouristInfoType.everyNamePhoneCard){
      guestNum = orderNum;
    }
    List<Widget> widgets = [];
    for(int i = 0; i < guestList.length; ++i){
      OrderGuest guest = guestList[i];
      widgets.add(
        GestureDetector(
          onTap: () async{
            Object? result = showOrderGuest(guest);
            if(result is OrderGuest){
              guestList[i] = result;
            }
          },
          onLongPressStart: (evt){
            double dx = evt.globalPosition.dx;
            double dy = evt.globalPosition.dy;
            const double width = 60;
            const double height = 36;
            if(width + dx > MediaQuery.of(context).size.width){
              dx = dx - width;
            }
            showGeneralDialog(
              barrierColor: Colors.transparent,
              barrierDismissible: true,
              barrierLabel: '',
              context: context, 
              pageBuilder:(context, animation, secondaryAnimation) {
                return Stack(
                  children: [
                    Positioned(
                      left: dx,
                      top: dy,
                      child: Material(
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                        child: InkWell(
                          onTap: (){
                            guestList.removeAt(i);
                            Navigator.of(context).pop();
                            if(mounted && context.mounted){
                              setState(() {
                              });
                            }
                          },
                          child: Container(
                            width: width,
                            height: height,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4
                                )
                              ]
                            ),
                            alignment: Alignment.center,
                            child: const Text('删除', style: TextStyle(color: ThemeUtil.foregroundColor),),
                          ),
                        ),
                      ),
                    )
                  ],
                );
              },
            ); 
          },
          child: Container(
            height: 32,
            constraints: const BoxConstraints(
              maxWidth: 100
            ),
            decoration: const BoxDecoration(
              border: Border.fromBorderSide(BorderSide(color: ThemeUtil.foregroundColor))
            ),
            padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(guest.name!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: ThemeUtil.foregroundColor),)
              ],
            ),
          ),
        )
      );
    }
    if(guestList.length < guestNum){
      widgets.add(
        InkWell(
          onTap: () async{
            Object? result = await showOrderGuest(null);
            if(result is OrderGuest){
              guestList.add(result);
              if(mounted && context.mounted){
                setState(() {
                });
              }
            }
          },
          child: Container(
            height: 32,
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              border: Border.fromBorderSide(BorderSide(color: ThemeUtil.foregroundColor)),
              color: ThemeUtil.buttonColor,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.add_circle_outline_rounded, color: ThemeUtil.foregroundColor,),
                Text('添加', style: TextStyle(color: ThemeUtil.foregroundColor),)
              ],
            ),
          ),
        )
      );
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
          const Text('登记信息', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
          guestList.length < guestNum ?
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text('还需填写${guestNum - guestList.length}位游客信息', style: const TextStyle(color: Colors.grey),),
          ) : const SizedBox(),
          const SizedBox(height: 10,),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: widgets,
          )
        ],
      ),
    );
  }

  Future<Object?> showOrderGuest(OrderGuest? guest){
    if(guest != null){
      guestNameController.text = guest.name ?? '';
      guestPhoneController.text = guest.phone ?? '';
      guestCardNoController.text = guest.cardNo ?? '';
    }
    else{
      guestNameController.text = '';
      guestPhoneController.text = '';
      guestCardNoController.text = '';
    }
    guest ??= OrderGuest();
    CardType? cardType;
    if(guest.cardType != null){
      cardType = CardTypeExt.getType(guest.cardType!);
    }
    bool setAsContact = guestList.isEmpty;
    return showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return StatefulBuilder(
          builder:(context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Material(
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.95,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4
                        )
                      ]
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Column(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.black12))
                          ),
                          child: TextField(
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.done,
                            decoration: const InputDecoration(
                              hintText: '姓 名',
                              hintStyle: TextStyle(color: Colors.grey),
                              isDense: true,
                              contentPadding: EdgeInsets.fromLTRB(8, 10, 8, 10),
                              border: InputBorder.none,
                            ),
                            controller: guestNameController,
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.black12))
                          ),
                          child: TextField(
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            decoration: const InputDecoration(
                              hintText: '手 机',
                              hintStyle: TextStyle(color: Colors.grey),
                              isDense: true,
                              contentPadding: EdgeInsets.fromLTRB(8, 10, 8, 10),
                              border: InputBorder.none,
                            ),
                            controller: guestPhoneController,
                          ),
                        ),
                        touristInfoType == TouristInfoType.everyNamePhoneCard || touristInfoType == TouristInfoType.singleNamePhoneCard ?
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(left: 7),
                              height: 44,
                              decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(color: Colors.black12))
                              ),
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('证件类型', style: TextStyle(color: cardType == null || cardType == CardType.none ? Colors.grey : ThemeUtil.foregroundColor, fontSize: 16),),
                                  InkWell(
                                    onTap: () async{
                                      Object? result = await showCardType();
                                      if(result is CardType){
                                        cardType = result;
                                        if(context.mounted){
                                          setState((){});
                                        }
                                      }
                                    },
                                    child: 
                                    cardType == null || cardType == CardType.none ?
                                    const Text('请选择', style: TextStyle(color: Colors.grey, fontSize: 16),) :
                                    Text(cardType!.getName(), style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),)
                                  )
                                ],
                              ),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(color: Colors.black12))
                              ),
                              child: TextField(
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.done,
                                decoration: const InputDecoration(
                                  hintText: '证件号',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  isDense: true,
                                  contentPadding: EdgeInsets.fromLTRB(8, 10, 8, 10),
                                  border: InputBorder.none,
                                ),
                                controller: guestCardNoController,
                              ),
                            ),
                            
                          ],
                        ) : const SizedBox(),
                        const SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                const Text('设为联系人', style: TextStyle(color: Colors.grey, fontSize: 16),),
                                InkWell(
                                  onTap: (){
                                    setAsContact = !setAsContact;
                                    setState((){});
                                  },
                                  child: setAsContact ?
                                  const Icon(Icons.radio_button_checked, color: Colors.lightGreen,) :
                                  const Icon(Icons.radio_button_unchecked, color: Colors.grey,)
                                )
                              ],
                            ),
                            const SizedBox(width: 20,),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: ThemeUtil.foregroundColor
                              ),
                              onPressed: (){
                                Navigator.of(context).pop();
                              }, 
                              child: const Text('取消')
                            ),
                            const SizedBox(width: 20,),
                            ElevatedButton(
                              onPressed: (){
                                String name = guestNameController.text.trim();
                                if(name.isEmpty){
                                  ToastUtil.warn('名字不能为空');
                                  return;
                                }
                                String phone = guestPhoneController.text.trim();
                                if(phone.isEmpty){
                                  ToastUtil.warn('手机号不能为空');
                                  return;
                                }
                                if(!RegularUtil.checkPhone(phone)){
                                  ToastUtil.warn('手机号格式不正确');
                                  return;
                                }
                                String? cardNo;
                                if(touristInfoType == TouristInfoType.everyNamePhoneCard || touristInfoType == TouristInfoType.singleNamePhoneCard){
                                  if(cardType == null || cardType == CardType.none){
                                    ToastUtil.warn('请选择证件类型');
                                    return;
                                  }
                                  cardNo = guestCardNoController.text.trim();
                                  if(cardNo.isEmpty){
                                    ToastUtil.warn('证件号不能为空');
                                    return;
                                  }
                                  if(cardType == CardType.idCard && !RegularUtil.checkIdCard(cardNo)){
                                    ToastUtil.warn('身份证号格式不正确');
                                    return;
                                  }
                                }
                                guest!.name = name;
                                guest.phone = phone;
                                guest.cardNo = cardNo;
                                guest.cardType = cardType?.getNum();
                                Navigator.of(context).pop(guest);
                                if(setAsContact){
                                  contactNameController.text = name;
                                  contactPhoneController.text = phone;
                                  contactCardNoController.text = cardNo ?? '';
                                  contactCardType = cardType;
                                }
                              },
                              child: const Text('确认'),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }
  
  Future<CardType?> showCardType() async {
    CardType cardType = CardType.idCard;
    CardType? selectedCardType = await showModalBottomSheet<CardType>(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: 240,
              color: Colors.transparent,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              '取消',
                              style: TextStyle(
                                color: ThemeUtil.buttonColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pop(cardType);
                            },
                            child: const Text(
                              '确认',
                              style: TextStyle(
                                color: ThemeUtil.buttonColor,
                                fontSize: 16,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 180,
                      child: Stack(
                        children: [
                          ListWheelScrollView(
                            diameterRatio: 1.5,
                            itemExtent: 40,
                            onSelectedItemChanged: (index) {
                              setState(() {
                                cardType = supportCardList[index];
                              });
                            },
                            physics: const FixedExtentScrollPhysics(),
                            children: List.generate(
                              supportCardList.length,(index) {
                                final isSelected = cardType == supportCardList[index];
                                return Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    supportCardList[index].getName(),
                                    style: const TextStyle(
                                      color: ThemeUtil.foregroundColor,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            top: 68,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 1,
                              color: Colors.grey[300],
                            ),
                          ),
                          Positioned(
                            bottom: 68,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 1,
                              color: Colors.grey[300],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    return selectedCardType;
  }
  /*Future<Object?> showCardType() {
    CardType cardType = CardType.idCard;
    return showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return Transform.translate(
          offset: Offset(0, (1 - animation.value) * 240),
          child: child,
        );
      },
      pageBuilder:(context, animation, secondaryAnimation) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Material(
              child: Container(
                height: 240,
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: (){
                              Navigator.of(context).pop();
                            },
                            child: const Text('取消', style: TextStyle(color: ThemeUtil.buttonColor, fontSize: 16),),
                          ),
                          InkWell(
                            onTap: (){
                              Navigator.of(context).pop(cardType);
                            },
                            child: const Text('确认', style: TextStyle(color: ThemeUtil.buttonColor, fontSize: 16),),
                          )
                        ]
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: ThemeUtil.backgroundColor,
                        ),
                        alignment: Alignment.center,
                        child: SizedBox(
                          height: 60,
                          child: PageView.builder(
                            scrollDirection: Axis.vertical,
                            onPageChanged: (idx){
                              cardType = supportCardList[idx];
                            },
                            itemBuilder: (context, index){
                              CardType cardType = supportCardList[index];
                              return Container(
                                height: 48,
                                alignment: Alignment.center,
                                color: Colors.white,
                                child: Text(cardType.getName(), style: const TextStyle(color: ThemeUtil.foregroundColor),),
                              );
                            },
                            itemCount: supportCardList.length,
                          )
                        )
                      ) ,
                    )
                  ],
                ),
              ),
            )
          ],
        );
      },
      
    );
  }*/

  Widget getBookNumWidet(){
    ScenicTicket ticket = widget.ticket;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('购买数', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
          Row(
            children: [
              InkWell(
                onTap: (){
                  if(orderNum <= 1){
                    return;
                  }
                  --orderNum;
                  numController.text = orderNum.toString();
                  setState(() {
                  });
                },
                child: Container(
                  height: 27,
                  width: 27,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border.fromBorderSide(BorderSide(color: Colors.grey)),
                    borderRadius: BorderRadius.all(Radius.circular(4))
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.remove_rounded, color: orderNum > 1 ? ThemeUtil.foregroundColor : Colors.grey,)
                ),
              ),
              const SizedBox(width: 10,),
              Container(
                height: 27,
                width: 70,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(4))
                ),
                padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
                clipBehavior: Clip.hardEdge,
                child: TextField(
                  controller: numController,
                  focusNode: numFocus,
                  onTapOutside: (event){
                    numFocus.unfocus();
                  },
                  onEditingComplete: (){
                    String val = numController.text;
                    val = val.replaceAll(RegExp(r'[^0-9]'), '');
                    val = val.replaceAll(RegExp(r'^0*'), '');
                    numController.text = val;
                    orderNum = int.parse(val);
                  },
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '',
                    isDense: true,
                    contentPadding: EdgeInsets.zero
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
              const SizedBox(width: 10,),
              InkWell(
                onTap: (){
                  if(ticket.maxBuyCount != null && orderNum >= ticket.maxBuyCount!){
                    return;
                  }
                  ++orderNum;
                  numController.text = orderNum.toString();
                  setState(() {
                  });
                },
                child: Container(
                  height: 27,
                  width: 27,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border.fromBorderSide(BorderSide(color: Colors.grey)),
                    borderRadius: BorderRadius.all(Radius.circular(4))
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.add_rounded, color: ticket.maxBuyCount != null && orderNum < ticket.maxBuyCount! ? ThemeUtil.foregroundColor : Colors.grey,)
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget getDateChooseWidget(){
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('游玩日期', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
          InkWell(
            onTap: () async{
              final config = DateChooseConfig(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width,
                firstDate: firstDate,
                lastDate: lastDate,
                chooseMode: DateChooseMode.single,
                choosable: (date) => priceList.any((element) => DateUtils.isSameDay(date, element.date))
              );
              List<DateTime>? results = await DateChooseUtil.chooseDate(context, config);
              if(results != null && results.isNotEmpty){
                tourDate = results.first;
                if(mounted && context.mounted){
                  setState(() {
                  });
                }
              }
            },
            child:
            tourDate != null ? 
            Text(
              DateFormat('yyyy年MM月dd日').format(tourDate!), 
              style: const TextStyle(color: ThemeUtil.buttonColor, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.underline), 
            ) :
            const Text('未开放', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16),)
          )
        ],
      ),
    );
  }

  Widget getInfoWidget(){
    ScenicTicket ticket = widget.ticket;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16))
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: ThemeUtil.backgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(4))
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ticket.name ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
            const SizedBox(height: 10,),
            ticket.advanceDay == null || ticket.advanceDay! <= 0 ?
            const Text('可立即预订', style: TextStyle(color: Colors.grey),) :
            ticket.advanceTime == null ?
            Text('需提前${ticket.advanceDay}天预订', style: const TextStyle(color: Colors.grey),) :
            Text('需提前${ticket.advanceDay}天在${ticket.advanceTime}前预订', style: const TextStyle(color: Colors.grey),),
            ticket.minBuyCount != null && ticket.minBuyCount! > 1 ?
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text('${ticket.minBuyCount}张起订', style: const TextStyle(color: Colors.grey),),
            ) : const SizedBox(),
            ticket.maxBuyCount != null ?
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text('每次限购${ticket.maxBuyCount}张', style: const TextStyle(color: Colors.grey),),
            ) : const SizedBox(),
            const SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                  Text('￥${StringUtil.getPriceStr(ticket.settlePrice)}起', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),),
              ],
            )
          ],
        ),
      )
    );
  }
}
