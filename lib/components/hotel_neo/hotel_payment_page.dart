import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/hotel_neo/api/local_hotel_api.dart';
import 'package:freego_flutter/components/hotel_neo/api/panhe_hotel_api.dart';
import 'package:freego_flutter/components/hotel_neo/hotel_common.dart';
import 'package:freego_flutter/components/merchent/merchant_api.dart';
import 'package:freego_flutter/components/order_neo/order_common.dart'
    as order_common;
import 'package:freego_flutter/components/order_neo/order_common.dart';
import 'package:freego_flutter/components/product_neo/product_source.dart';
import 'package:freego_flutter/components/video/video_home.dart';
import 'package:freego_flutter/components/video/video_model.dart';
import 'package:freego_flutter/util/native_calendar_util.dart';
import 'package:freego_flutter/util/pay_util_neo.dart';
import 'package:freego_flutter/util/regular_util.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;

class HotelPaymentPage extends StatefulWidget {
  final Hotel hotel;
  final HotelChamber chamber;
  final HotelChamberPlan plan;
  final DateTime startDate;
  final DateTime endDate;
  final int orderNum;
  final int totalPrice;
  final String contactName;
  final String contactPhone;
  final String contactEmail;
  final List<OrderGuest> guestList;

  const HotelPaymentPage({
    required this.hotel,
    required this.chamber,
    required this.plan,
    required this.startDate,
    required this.endDate,
    required this.orderNum,
    required this.totalPrice,
    required this.contactName,
    required this.contactPhone,
    required this.contactEmail,
    required this.guestList,
    Key? key,
  }) : super(key: key);

  @override
  _HotelPaymentPageState createState() => _HotelPaymentPageState();
}

class _HotelPaymentPageState extends State<HotelPaymentPage> {
  PayType? selectedPayType;
  bool isPaying = false;
  List<PayType> availablePayTypes = [];

  VideoModel? video2;

  @override
  void initState() {
    super.initState();
    _initTimeZone();
    _loadPayTypes();
  }

  Future<void> _initTimeZone() async {
    try {
      tz.initializeTimeZones(); // 直接初始化
    } catch (e) {
      debugPrint('时区初始化失败: $e');
    }
  }

  Future<void> _loadPayTypes() async {
    if (widget.hotel.source == 'local') {
      availablePayTypes = await MerchantApi()
              .listPayTypes(merchantId: widget.hotel.userId ?? 0) ??
          [];
    } else {
      availablePayTypes = [PayType.wechat, PayType.alipay];
    }
    availablePayTypes = [
      PayType.wechat,
      PayType.alipay,
      //PayType.unionpay,
    ];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('支付订单'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                // 订单信息卡片
                _buildOrderInfoCard(),
                SizedBox(height: 16),
                // 支付方式选择
                _buildPaymentMethods(),
                SizedBox(height: 16),
                // 联系人信息
                _buildContactInfo(),
              ],
            ),
          ),
          // 底部支付栏
          _buildPaymentBar(),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.hotel.name}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '${widget.plan.name}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16),
                SizedBox(width: 8),
                Text(
                  '${DateFormat('MM月dd日').format(widget.startDate)} - ${DateFormat('MM月dd日').format(widget.endDate)}',
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.people, size: 16),
                SizedBox(width: 8),
                Text('${widget.orderNum}间'),
              ],
            ),
            Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('总价', style: TextStyle(fontSize: 16)),
                Text(
                  '¥${StringUtil.getPriceStr(widget.totalPrice)}',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.red,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '支付方式',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ...availablePayTypes
                .map((type) => _buildPaymentMethodItem(type))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodItem(PayType type) {
    bool isSelected = selectedPayType == type;
    debugPrint('支付方式: $type');
    final paymentMethods = {
      PayType.alipay: {'name': '支付宝支付', 'icon': 'images/pay_alipay.png'},
      PayType.wechat: {'name': '微信支付', 'icon': 'images/pay_weixin.png'},
      //PayType.unionpay: {'name': '银联支付', 'icon': 'images/pay_unionpay.png'},
    };

    final info = paymentMethods[type] ??
        {'name': type.toString(), 'icon': 'images/pay_default.png'};

    return InkWell(
      onTap: () => setState(() => selectedPayType = type),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
        child: Row(
          children: [
            Image.asset(
              info['icon']!,
              width: 24,
              height: 24,
            ),
            SizedBox(width: 12),
            Text(info['name']!),
            Spacer(),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '联系人信息',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('姓名: ${widget.contactName}'),
            SizedBox(height: 4),
            Text('电话: ${widget.contactPhone}'),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('应付金额'),
              Text(
                '¥${StringUtil.getPriceStr(widget.totalPrice)}',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.red,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Spacer(),
          /*ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              backgroundColor: selectedPayType != null ? Colors.blue : Colors.grey,
            ),
            onPressed: selectedPayType != null && !isPaying ? _handlePayment : null,
            child: isPaying 
                ? CircularProgressIndicator(color: Colors.white)
                : Text('立即支付', style: TextStyle(fontSize: 16)),
          )*/
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              onPressed: () async {
                String? source = widget.hotel.source;
                ProductSource? productSource;
                if (source != null) {
                  productSource = ProductSourceExt.getSource(source);
                }
                if (productSource == ProductSource.local) {
                  payLocal();
                } else if (productSource == ProductSource.panhe) {
                  payPanhe();
                }
              },
              child: const Text(
                '立即支付',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ))
        ],
      ),
    );
  }

  Future payPanhe() async {
    Hotel hotel = widget.hotel;
    HotelChamberPlan plan = widget.plan;
    if (selectedPayType == null) {
      ToastUtil.warn('请选择支付方式');
      return;
    }
    List<String> guestNames = [];
    for (OrderGuest guest in widget.guestList) {
      guestNames.add(guest.name ?? '');
    }
    String? contactEmail = widget.contactEmail;
    if (contactEmail.isEmpty) {
      contactEmail = null;
    }
    String? orderSerial = await PanheHotelApi().order(
        outerId: hotel.outerId!,
        ratePlanId: plan.ratePlanId!,
        roomNum: widget.orderNum,
        checkInDate: widget.startDate,
        checkOutDate: widget.endDate,
        guestNames: guestNames,
        contactName: widget.contactName,
        contactMobile: widget.contactPhone,
        contactEmail: widget.contactEmail,
        fail: (response) {
          String message = response.data['message'] ?? '下单失败';
          ToastUtil.error(message);
        });
    if (orderSerial == null) {
      return;
    }
    if (selectedPayType == order_common.PayType.alipay) {
      String? payInfo = await PanheHotelApi()
          .pay(orderSerial: orderSerial, payType: selectedPayType!.getName());
      if (payInfo == null) {
        ToastUtil.error('支付宝预下单失败');
        return;
      }
      bool result = await PayUtilNeo().alipay(payInfo);
      if (result) {
        ToastUtil.hint('支付成功');
        await createHotelEvent();
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && context.mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    } else if (selectedPayType == order_common.PayType.wechat) {
      String? payInfo = await PanheHotelApi()
          .pay(orderSerial: orderSerial, payType: selectedPayType!.getName());
      if (payInfo == null) {
        ToastUtil.error('微信预下单失败');
        return;
      }
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
    }
  }

  Future payLocal() async {
    Hotel hotel = widget.hotel;
    HotelChamber chamber = widget.chamber;
    HotelChamberPlan plan = widget.plan;

    if (selectedPayType == null) {
      ToastUtil.warn('请选择支付方式');
      return;
    }

    // 验证商家是否支持该支付方式
    if (!availablePayTypes.contains(selectedPayType)) {
      ToastUtil.warn('商家未开通该支付方式');
      return;
    }

    // 处理可选的联系人邮箱
    String? contactEmail = widget.contactEmail;
    if (contactEmail.isEmpty) {
      contactEmail = null;
    }

    // 下单
    /*String? orderSerial = await LocalHotelApi().order(
    chamberId: chamber.id!, 
    planId: plan.id!, 
    checkInDate: widget.startDate, 
    checkOutDate: widget.endDate, 
    quantity: widget.orderNum, 
    contactName: widget.contactName, 
    contactPhone: widget.contactPhone,
    contactEmail: contactEmail,
    remark: null,
    fail: (response) {
      ToastUtil.error(response.data['message'] ?? '下单失败');
    }
  );
  
  if (orderSerial == null) {
    return;
  }*/

    // 使用新的下单接口
    String? orderNo = await LocalHotelApi().createOrder(
        orderType: 2, // 酒店类型为2
        price: widget.totalPrice,
        chamberId: widget.chamber.id ?? 0,
        checkInDate: widget.startDate, 
        checkOutDate: widget.endDate, 
        contactEmail: widget.contactEmail,
        contactName: widget.contactName,
        contactPhone: widget.contactPhone, 
        planId: widget.plan.id!,
        quantity: widget.orderNum,
        remark: null,
        userId: widget.hotel.userId ?? 0, // 商户ID
        fail: (response) {
          ToastUtil.error(response.data['message'] ?? '下单失败');
        });

    if (orderNo == null) {
      return;
    }

    // 根据选择的支付类型处理支付
    if (selectedPayType == order_common.PayType.alipay) {
      // 调用新的预支付接口
      String? payInfo = await LocalHotelApi()
          .payNew(orderNo: orderNo, payType: 5002 // 5002表示支付宝
              );
      print('✅ 提取的 data 字段: $payInfo');
      if (payInfo == null) {
        ToastUtil.error('支付宝预下单失败');
        return;
      }

      bool result = await PayUtilNeo().alipay(payInfo);
      if (result) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => VideoHomePage(initVideo: video2)),
          );
        }
        final payStatus = await LocalHotelApi().checkPayStatus(orderNo: orderNo);
        if (payStatus != null && payStatus['code'] == 10200) {
          final tradeStateDesc = payStatus['data']['tradeStateDesc'];
          ToastUtil.hint(tradeStateDesc); // 直接使用接口返回的 tradeStateDesc
          final payStatussss = payStatus['data']['state'];
          // 如果支付成功，执行后续逻辑
          if (payStatussss == 1) {
            // 假设 1 表示支付成功
            await createHotelEvent();
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (context) => VideoHomePage(initVideo: video2)),
                );
              }
            });
          }
        } else {
          ToastUtil.error('获取支付状态失败');
        }
      }
    } else if (selectedPayType == order_common.PayType.wechat) {
      // 调用新的预支付接口
      String? payParams = await LocalHotelApi()
          .payNew(orderNo: orderNo, payType: 5001 // 5001表示微信
              );
      print('✅ 提取的 data 字段1: $payParams');

      if (payParams == null) {
        ToastUtil.error('微信预下单失败');
        return;
      }

      PayUtilNeo().wechatPay(
        payParams,
        onSuccess: () async {
          final payStatus = await LocalHotelApi().checkPayStatus(orderNo: orderNo);
        if (payStatus != null && payStatus['code'] == 10200) {
          final tradeStateDesc = payStatus['data']['tradeStateDesc'];
          ToastUtil.hint(tradeStateDesc); // 直接使用接口返回的 tradeStateDesc
          final payStatussss = payStatus['data']['state'];
          // 如果支付成功，执行后续逻辑
          if (payStatussss == 1) {
            // 假设 1 表示支付成功
            await createHotelEvent();
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (context) => VideoHomePage(initVideo: video2)),
                );
              }
            });
          }
        } else {
          ToastUtil.error('获取支付状态失败');
        }
        },
      );
    }
  }
  /*Future payLocal() async{
    HotelChamber chamber = widget.chamber;
    HotelChamberPlan plan = widget.plan;
    if(selectedPayType == null){
      ToastUtil.warn('请选择支付方式');
      return;
    }
    if(selectedPayType == PayType.alipay){
      if(!availablePayTypes.contains(PayType.alipay)){
        ToastUtil.warn('商家未开通支付宝');
        return;
      }
    }
    else if(selectedPayType == PayType.wechat){
      if(!availablePayTypes.contains(PayType.wechat)){
        ToastUtil.warn('商家未开通微信支付');
        return;
      }
    }
    String? contactEmail = widget.contactEmail;
            if(contactEmail.isEmpty){
              contactEmail = null;
            }
    String? orderSerial = await LocalHotelApi().order(
      chamberId: chamber.id!, 
      planId: plan.id!, 
      checkInDate: widget.startDate, 
      checkOutDate: widget.endDate, 
      quantity: widget.orderNum, 
      contactName: widget.contactName, 
      contactPhone: widget.contactPhone,
      contactEmail: contactEmail,
      remark: null,
      fail: (response){
        ToastUtil.error(response.data['message'] ?? '下单失败');
      }
    );
    if(orderSerial == null){
      return;
    }
    if(selectedPayType == order_common.PayType.alipay){
      if(widget.hotel.source == 'local'){
        // 使用支付宝直付通分账支付
        String? payInfo = await LocalHotelApi().pay(orderSerial: orderSerial, payType: PayType.zftalipay);
        if(payInfo == null){
          ToastUtil.error('支付宝直付通预下单失败');
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
      } else {
        String? payInfo = await LocalHotelApi().pay(orderSerial: orderSerial, payType: PayType.alipay);
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
    }  
    else if(selectedPayType == order_common.PayType.wechat){
      if (widget.hotel.source == 'local') {
        // 使用微信收付通支付
        String? payInfo = await LocalHotelApi().pay(orderSerial: orderSerial,payType: PayType.sftwechat);
        if (payInfo == null) {
          ToastUtil.error('微信收付通预下单失败');
          return;
        }
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

  Future<void> _handlePayment() async {
    setState(() {
      isPaying = true;
    });

    try {
      bool paymentSuccess = false;

      if (widget.hotel.source == 'local') {
        paymentSuccess = await _processLocalPayment();
      } else if (widget.hotel.source == 'panhe') {
        paymentSuccess = await _processPanhePayment();
      }

      if (paymentSuccess) {
        ToastUtil.hint('支付成功');
        await createHotelEvent();
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      ToastUtil.error('支付失败: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          isPaying = false;
        });
      }
    }
  }

  Future<bool> _processLocalPayment() async {
    debugPrint('本地酒店支付');
    // 实现本地酒店支付逻辑
    // 类似于原来的payLocal()方法
    return true;
  }

  Future<bool> _processPanhePayment() async {
    // 实现Panhe酒店支付逻辑
    // 类似于原来的payPanhe()方法
    return true;
  }

  Future createHotelEvent() async {
    Event event = NativeCalendarUtil().makeEvent(
        title: 'Freego-快速入住',
        startTime: widget.startDate,
        endTime: widget.endDate,
        allDay: true,
        location: widget.hotel.name);
    return NativeCalendarUtil().showEventOption(
        context: context, eventList: [event], title: 'Freego-快速入住');
  }
}
