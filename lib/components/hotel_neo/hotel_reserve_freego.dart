
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/hotel_neo/api/local_hotel_api.dart';
import 'package:freego_flutter/components/hotel_neo/api/panhe_hotel_api.dart';
import 'package:freego_flutter/components/hotel_neo/hotel_common.dart';
import 'package:freego_flutter/components/hotel_neo/hotel_payment_page.dart';
import 'package:freego_flutter/components/merchent/merchant_api.dart';
import 'package:freego_flutter/components/order_neo/order_common.dart' as order_common;
import 'package:freego_flutter/components/order_neo/order_common.dart';
import 'package:freego_flutter/components/product_neo/product_source.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/image_group_viewer.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/model/user.dart';
import 'package:freego_flutter/util/date_time_util.dart';
import 'package:freego_flutter/util/local_user.dart';
import 'package:freego_flutter/util/native_calendar_util.dart';
import 'package:freego_flutter/util/pay_util_neo.dart';
import 'package:freego_flutter/util/regular_util.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:intl/intl.dart';

class HotelReservePage extends StatefulWidget{
  final Hotel hotel;
  final HotelChamber chamber;
  final HotelChamberPlan plan;
  final DateTime startDate;
  final DateTime endDate;
  const HotelReservePage({required this.hotel, required this.chamber, required this.plan, required this.startDate, required this.endDate, super.key});

  @override
  State<StatefulWidget> createState() {
    return HotelReservePageState();
  }

}

class HotelReservePageState extends State<HotelReservePage>{
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
        child: HotelReserveWidget(hotel: widget.hotel, chamber: widget.chamber, plan: widget.plan, startDate: widget.startDate, endDate: widget.endDate,),
      ),
    );
  }

}

class HotelReserveWidget extends StatefulWidget{
  final Hotel hotel;
  final HotelChamber chamber;
  final HotelChamberPlan plan;
  final DateTime startDate;
  final DateTime endDate;
  const HotelReserveWidget({required this.hotel, required this.chamber, required this.plan, required this.startDate, required this.endDate, super.key});

  @override
  State<StatefulWidget> createState() {
    return HotelReserveState();
  }

}

class HotelReserveState extends State<HotelReserveWidget>{

  int orderNum = 1;
  TextEditingController numController = TextEditingController();
  FocusNode numFocus = FocusNode();

  TextEditingController contactNameController = TextEditingController();
  TextEditingController contactPhoneController = TextEditingController();
  TextEditingController contactEmailController = TextEditingController();

  order_common.PayType? payType;
  int maxNum = -1;

  List<OrderGuest> guestList = [];
  TextEditingController guestNameController = TextEditingController();

  List<PayType> payTypes = [PayType.wechat, PayType.alipay];

  @override
  void initState(){
    super.initState();
    numController.text = orderNum.toString();
    UserModel? user = LocalUser.getUser();
    if(user != null){
      contactPhoneController.text = user.phone ?? '';
    }
    for(HotelChamberPlanPrice priceObj in widget.plan.priceList!){
      int? stock = priceObj.stock;
      if(maxNum == -1 || stock != null && maxNum > stock){
        maxNum = stock!;
      }
    }
    numFocus.addListener(() {
      if(!numFocus.hasFocus){
        String val = numController.text;
        val = val.replaceAll(RegExp(r'[^0-9]'), '');
        val = val.replaceAll(RegExp(r'^0*'), '');
        orderNum = int.tryParse(val) ?? 1;
        if(orderNum > maxNum){
          orderNum = maxNum;
        }
        numController.text = orderNum.toString();
        resetState();
      }
    });
    ProductSource? source = ProductSourceExt.getSource(widget.hotel.source ?? '');
    print('打印产品来源: $source'); // 
    if(source == ProductSource.local){
      Future.delayed(Duration.zero, () async{
        payTypes = await MerchantApi().listPayTypes(merchantId: widget.hotel.userId ?? 0) ?? [];
        print('打印支付类型列表: $payTypes'); // 打印支付类型列表
      });
    }
  }

  @override
  void dispose(){
    numController.dispose();
    numFocus.dispose();
    contactNameController.dispose();
    contactPhoneController.dispose();
    contactEmailController.dispose();
    guestNameController.dispose();
    super.dispose();
  }

  void resetState(){
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    HotelChamberPlan plan = widget.plan;
    return Container(
      color: ThemeUtil.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonHeader(
            center: Text(plan.name ?? '', style: const TextStyle(color: Colors.white, fontSize: 18),),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              physics: const ClampingScrollPhysics(),
              children: [
                getInfoWidget(),
                getDateWidget(),
                getOrderNumWidget(),
                getDayPriceWidget(),
                getGuestInfoWidget(),
                getContactWidget(),
                getCancelRuleWidget(),
                getFacilityWidget(),
                //getPayTypeChooseWidget()
              ],
            ),
          ),
          getFooterWidget()
        ],
      ),
    );
  }

  Widget getGuestInfoWidget(){
    ProductSource? productSource;
    if(widget.hotel.source != null){
      productSource = ProductSourceExt.getSource(widget.hotel.source!);
    }
    if(productSource == ProductSource.local){
      return const SizedBox();
    }
    int guestNum = orderNum;
    List<Widget> widgets = [];
    if(guestList.length > orderNum){
      guestList = guestList.sublist(0, orderNum);
    }
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
    }
    else{
      guestNameController.text = '';
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
                                guest!.name = name;
                                guest.cardType = cardType?.getNum();
                                Navigator.of(context).pop(guest);
                                if(setAsContact){
                                  contactNameController.text = name;
                                }
                                resetState();
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

  Widget getFooterWidget(){
    int total = 0;
    HotelChamber chamber = widget.chamber;
    HotelChamberPlan plan = widget.plan;
    for(HotelChamberPlanPrice priceObj in plan.priceList ?? []){
      if(priceObj.price != null){
        total = total + priceObj.price!;
      }
    }
    total = total * orderNum;
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
              Text('￥${StringUtil.getPriceStr(total)}', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 18),),
            ],
          ),
          /*ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap
            ),
            onPressed: () async{
              String? source = widget.hotel.source;
              ProductSource? productSource;
              if(source != null){
                productSource = ProductSourceExt.getSource(source);
              }
              if(productSource == ProductSource.local){
                payLocal();
              }
              else if(productSource == ProductSource.panhe){
                payPanhe();
              }
            },
            child: const Text('支 付', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),)
          )*/
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap
          ),
          onPressed: () async {
            // 改为提交订单逻辑
            debugPrint('提交订单: $widget.hotel' );
            bool success = await submitOrder();
            if(success && mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HotelPaymentPage(
                    hotel: widget.hotel,
                    chamber: widget.chamber,
                    plan: widget.plan,
                    startDate: widget.startDate,
                    endDate: widget.endDate,
                    orderNum: orderNum,
                    totalPrice: total,
                    contactName: contactNameController.text.trim(),
                    contactPhone: contactPhoneController.text.trim(),
                    contactEmail: contactEmailController.text.trim(),
                    guestList: guestList,
                  ),
                ),
              );
            }
          },
          child: const Text('提交订单', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),)
        )
        ],
      ),
    );
  }

  // 提取提交订单逻辑
Future<bool> submitOrder() async {
  if(contactNameController.text.trim().isEmpty) {
    ToastUtil.warn('请填写联系人');
    return false;
  }
  
  if(contactPhoneController.text.trim().isEmpty || !RegularUtil.checkPhone(contactPhoneController.text.trim())) {
    ToastUtil.warn('请填写正确的联系电话');
    return false;
  }
  
  // 根据来源验证入住人信息
  if(widget.hotel.source != 'local' && guestList.length != orderNum) {
    ToastUtil.warn('请填写完整的入住人信息');
    return false;
  }
  
  return true;
}

  /*Future payPanhe() async{
    Hotel hotel = widget.hotel;
    HotelChamberPlan plan = widget.plan;
    if(hotel.outerId == null || plan.ratePlanId == null){
      ToastUtil.error('数据错误');
      return;
    }
    if(guestList.length != orderNum){
      ToastUtil.warn('请填写入住人信息');
      return;
    }
    String contactName = contactNameController.text.trim();
    if(contactName.isEmpty){
      ToastUtil.warn('清填写联系人');
      return;
    }
    String contactPhone = contactPhoneController.text.trim();
    if(contactPhone.isEmpty){
      ToastUtil.warn('请填写联系人电话');
      return;
    }
    if(!RegularUtil.checkPhone(contactPhone)){
      ToastUtil.warn('电话格式错误');
      return;
    }
    String? contactEmail = contactEmailController.text.trim();
    if(contactEmail.isEmpty){
      contactEmail = null;
    }
    if(contactEmail != null){
      if(!RegularUtil.checkEmail(contactEmail)){
        ToastUtil.warn('邮箱格式错误');
        return;
      }
    }
    if(payType == null){
      ToastUtil.warn('请选择支付方式');
      return;
    }
    List<String> guestNames = [];
    for(OrderGuest guest in guestList){
      guestNames.add(guest.name ?? '');
    }
    String? orderSerial = await PanheHotelApi().order(
      outerId: hotel.outerId!, ratePlanId: plan.ratePlanId!, roomNum: orderNum, checkInDate: widget.startDate, checkOutDate: widget.endDate, guestNames: guestNames, contactName: contactNameController.text.trim(), contactMobile: contactPhoneController.text.trim(), contactEmail: contactEmail,
      fail: (response){
        String message = response.data['message'] ?? '下单失败';
        ToastUtil.error(message);
      }
    );
    if(orderSerial == null){
      return;
    }
    if(payType == order_common.PayType.alipay){
      String? payInfo = await PanheHotelApi().pay(orderSerial: orderSerial, payType: payType!.getName());
      if(payInfo == null){
        ToastUtil.error('支付宝预下单失败');
        return;
      }
      bool result = await PayUtilNeo().alipay(payInfo);
      if(result){
        ToastUtil.hint('支付成功');
        await createHotelEvent();
        Future.delayed(const Duration(seconds: 3), () {
          if(mounted && context.mounted){
            Navigator.of(context).pop();
          }
        });
      }
    }
    else if(payType == order_common.PayType.wechat){
      String? payInfo = await PanheHotelApi().pay(orderSerial: orderSerial, payType: payType!.getName());
      if(payInfo == null){
        ToastUtil.error('微信预下单失败');
        return;
      }
      PayUtilNeo().wechatPay(
        payInfo, 
        onSuccess: () async{
          ToastUtil.hint('支付成功');
          await createHotelEvent();
          Future.delayed(const Duration(seconds: 3), () {
            if(mounted && context.mounted){
              Navigator.of(context).pop();
            }
          });
        },
      );
    }
  }

  Future payLocal() async{
    HotelChamber chamber = widget.chamber;
    HotelChamberPlan plan = widget.plan;
    if(chamber.id == null || plan.id == null){
      ToastUtil.error('数据错误');
      return;
    }
    String contactName = contactNameController.text.trim();
    if(contactName.isEmpty){
      ToastUtil.warn('请填写联系人');
      return;
    }
    String contactPhone = contactPhoneController.text.trim();
    if(contactPhone.isEmpty){
      ToastUtil.warn('请填写联系人电话');
      return;
    }
    if(!RegularUtil.checkPhone(contactPhone)){
      ToastUtil.warn('电话格式错误');
      return;
    }
    String? contactEmail = contactEmailController.text.trim();
    if(contactEmail.isEmpty){
      contactEmail = null;
    }
    if(contactEmail != null){
      if(!RegularUtil.checkEmail(contactEmail)){
        ToastUtil.warn('邮箱格式错误');
        return;
      }
    }
    if(payType == null){
      ToastUtil.warn('请选择支付方式');
      return;
    }
    if(payType == PayType.alipay){
      print('PayType: ${payType}');
      print('打印判断结果: ${payTypes.contains(PayType.alipay)}'); // 打印判断结果
      if(!payTypes.contains(PayType.alipay)){
        ToastUtil.warn('商家未开通支付宝');
        return;
      }
    }
    else if(payType == PayType.wechat){
      if(!payTypes.contains(PayType.wechat)){
        ToastUtil.warn('商家未开通微信支付');
        return;
      }
    }
    print('本地酒店支付');
    String? orderSerial = await LocalHotelApi().order(
      chamberId: chamber.id!, 
      planId: plan.id!, 
      checkInDate: widget.startDate, 
      checkOutDate: widget.endDate, 
      quantity: orderNum, 
      contactName: contactName, 
      contactPhone: contactPhone,
      contactEmail: contactEmail,
      remark: null,
      fail: (response){
        ToastUtil.error(response.data['message'] ?? '下单失败');
      }
    );
    if(orderSerial == null){
      print('本地酒店支付1');
      return;
    }
    if(payType == order_common.PayType.alipay){
      print('本地酒店支付2');
      if(widget.hotel.source == 'local'){
        // 使用支付宝直付通分账支付
        print('本地酒店支付3');
        String? payInfo = await LocalHotelApi().pay(orderSerial: orderSerial, payType: PayType.zftalipay);
        if(payInfo == null){
          ToastUtil.error('支付宝直付通预下单失败');
          return;
        }
        print('本地酒店支付4');
        bool result = await PayUtilNeo().alipay(payInfo);
        print('本地酒店支付5');
        print('Alipay result: $result');
        if(result){
          print('本地酒店支付6');
          ToastUtil.hint('支付成功');
          await createHotelEvent();
          Future.delayed(const Duration(seconds: 3), () {
            if(mounted && context.mounted){
              Navigator.of(context).pop();
            }
          });
        }
      } else {
                print('本地酒店支付7');

        String? payInfo = await LocalHotelApi().pay(orderSerial: orderSerial, payType: PayType.alipay);
        if(payInfo == null){
                  print('本地酒店支付8');

          ToastUtil.error('支付宝预下单失败');
          return;
        }
                print('本地酒店支付9');

        bool result = await PayUtilNeo().alipay(payInfo);
        if(result){
                  print('本地酒店支付10');

          ToastUtil.hint('支付成功');
          await createHotelEvent();
          Future.delayed(const Duration(seconds: 3), () {
            if(mounted && context.mounted){
              Navigator.of(context).pop();
            }
          });
        }
      }
    }  
    else if(payType == order_common.PayType.wechat){
      print('本地酒店支付4');
      if (widget.hotel.source == 'local') {
        // 使用微信收付通支付
        print('本地酒店支付5');
        String? payInfo = await LocalHotelApi().pay(orderSerial: orderSerial,payType: PayType.sftwechat);
        if (payInfo == null) {
          ToastUtil.error('微信收付通预下单失败');
          return;
        }
        print('本地酒店支付6');
        PayUtilNeo().wechatPay(
          payInfo, 
          onSuccess: () async {
            ToastUtil.hint('支付成功');
            await createHotelEvent();
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted && context.mounted) {
                Navigator.of(context).pop();
              }
            });
          },
        );
      }else{
        String? payInfo = await LocalHotelApi().pay(orderSerial: orderSerial, payType: PayType.wechat);
        if(payInfo == null){
          ToastUtil.error('微信预下单失败');
          return;
        }
        PayUtilNeo().wechatPay(
          payInfo, 
          onSuccess: () async{
            ToastUtil.hint('支付成功');
            await createHotelEvent();
            Future.delayed(const Duration(seconds: 3), () {
              if(mounted && context.mounted){
                Navigator.of(context).pop();
              }
            });
          },
        );
      }
    } 
  }*/

  Future createHotelEvent() async{
    Event event = NativeCalendarUtil().makeEvent(title: 'Freego-快速入住', startTime: widget.startDate, endTime: widget.endDate, allDay: true, location: widget.hotel.name);
    return NativeCalendarUtil().showEventOption(context: context, eventList: [event], title: 'Freego-快速入住');
  }

  /*Widget getPayTypeChooseWidget(){
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
              payType = order_common.PayType.alipay;
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
                payType == order_common.PayType.alipay ? 
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
              payType = order_common.PayType.wechat;
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
                payType == order_common.PayType.wechat ? 
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
  }*/

  Widget getContactWidget(){
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
          const Text('联系人', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
          const SizedBox(height: 10,),
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black12))
            ),
            child: TextField(
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.done,
              maxLines: 1,
              decoration: const InputDecoration(
                hintText: '姓 名',
                hintStyle: TextStyle(color: Colors.grey),
                isDense: true,
                contentPadding: EdgeInsets.fromLTRB(8, 10, 8, 10),
                border: InputBorder.none
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
          const SizedBox(height: 8,),
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black12))
            ),
            child: TextField(
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                hintText: '邮 箱',
                hintStyle: TextStyle(color: Colors.grey),
                isDense: true,
                contentPadding: EdgeInsets.fromLTRB(8, 10, 8, 10),
                border: InputBorder.none,
              ),
              controller: contactEmailController,
            ),
          ),
        ],
      ),
    );
  }

  Widget getFacilityWidget(){
    HotelChamber chamber = widget.chamber;
    if(chamber.facilityList == null || chamber.facilityList!.isEmpty){
      return const SizedBox();
    }
    List<Widget> widgets = [];
    for(HotelChamberFacility facility in chamber.facilityList ?? []){
      widgets.add(
        Text(facility.name!, style: const TextStyle(color: Colors.grey),)
      );
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16,16),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('房间设施', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
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

  Widget getCancelRuleWidget(){
    HotelChamberPlan plan = widget.plan;
    if(plan.cancelRuleType == null){
      return const SizedBox();
    }
    CancelRuleType? type = CancelRuleTypeExt.getType(plan.cancelRuleType!);
    if(type == null){
      return const SizedBox();
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('取消政策', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
          const SizedBox(height: 10,),
          type == CancelRuleType.unable ?
          const Text('无法取消', style: TextStyle(color: Colors.grey),) :
          type == CancelRuleType.inTime ?
          const Text('限时取消', style: TextStyle(color: Colors.grey),) :
          const Text('收费取消', style: TextStyle(color: Colors.grey),),
          const SizedBox(height: 10,),
          Text(plan.cancelRuleDesc ?? '', style: const TextStyle(color: Colors.grey),)
        ],
      ),
    );
  }

  Widget getDayPriceWidget(){
    HotelChamberPlan plan = widget.plan;
    List<Widget> widgets = [];
    for(HotelChamberPlanPrice priceObj in plan.priceList ?? []){
      if(priceObj.price == null || priceObj.date == null){
        continue;
      }
      widgets.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('MM月dd日').format(priceObj.date!), style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold),),
            Text('￥${StringUtil.getPriceStr(priceObj.price)}', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),)
          ],
        ),
      );
    }
    widgets.add(const Divider());
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('价格', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
          const SizedBox(height: 14,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widgets,
          )
        ]
      ),
    );
  }

  Widget getOrderNumWidget(){
    HotelChamberPlan plan = widget.plan;
    if(plan.priceList == null || plan.priceList!.isEmpty || maxNum < 0){
      return const SizedBox();
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('房间数：', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
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
                  if(orderNum >= maxNum){
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
                  child: Icon(Icons.add_rounded, color: orderNum < maxNum ? ThemeUtil.foregroundColor : Colors.grey,)
                ),
              ),
            ],
          )
        ]
      ),
    );
  }

  Widget getDateWidget(){
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(DateFormat('yyyy-MM-dd').format(widget.startDate), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.underline),),
          Text(DateTimeUtil.getWeekDayCn(widget.startDate), style: const TextStyle(color: Colors.grey),),
          const Text(' 至 ', style: TextStyle(color: Colors.grey),),
          Text(DateFormat('yyyy-MM-dd').format(widget.endDate), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.underline),),
          Text(DateTimeUtil.getWeekDayCn(widget.endDate), style: const TextStyle(color: Colors.grey),),    
        ],
      ),
    );
  }

  Widget getInfoWidget(){
    HotelChamber chamber = widget.chamber;
    HotelChamberPlan plan = widget.plan;
    if(chamber.pictureList == null || chamber.pictureList!.isEmpty){
      return const SizedBox();
    }
    chamber.pictureList = chamber.pictureList!.where((element){
      return element.path != null;
    }).toList();
    List<String> urlList = [];
    for(HotelChamberPicture picObj in chamber.pictureList!){
      String pic = picObj.path!;
      pic = getFullUrl(pic);
      urlList.add(pic);
    }
    int? price;
    if(plan.priceList != null && plan.priceList!.isNotEmpty){
      price = plan.priceList!.first.price;
    }
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16))
      ),
      clipBehavior: Clip.hardEdge,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SizedBox(
              height: 120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(plan.name ?? '', style: const TextStyle(fontSize: 16),),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      chamber.bedType != null ?
                      Text(chamber.bedType ?? '', style: const TextStyle(color: Colors.grey)) : const SizedBox(),
                      chamber.area != null ?
                      Text('${chamber.area}平米', style: const TextStyle(color: Colors.grey),) : const SizedBox(),
                      chamber.capacity != null ?
                      Text('可住${chamber.capacity}人',style: const TextStyle(color: Colors.grey),) : const SizedBox()
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      plan.breakfast != null ?
                      Text(plan.breakfast!, style: const TextStyle(color: Colors.grey),) : const SizedBox(),
                      plan.cancelRuleName != null ?
                      Text(plan.cancelRuleName!, style: const
                        TextStyle(color: Colors.grey),) : const SizedBox()
                    ],
                  ),
                  price == null ?
                  const SizedBox() :
                  Wrap(
                    children: [
                      Text('￥${price / 100} 起', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 18),)
                    ],
                  )
                ],
              ),
            )
          ),
          InkWell(
            onTap: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context){
                return ImageGroupViewer(urlList);
              }));
            },
            child: 
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              child: Stack(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: Image.network(urlList[0], fit: BoxFit.cover,),
                  ),
                  Container(
                    width: 120,
                    height: 120,
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 24,
                          padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(128, 128, 128, 0.5)
                          ),
                          alignment: Alignment.center,
                          child: const Text('图集', style: TextStyle(color: Colors.white),),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
