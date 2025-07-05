import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/order_neo/order_common.dart'
    as order_common;
import 'package:freego_flutter/components/order_neo/order_common.dart';
import 'package:freego_flutter/components/restaurant/restaurant_api.dart';
import 'package:freego_flutter/components/restaurant/restaurant_common.dart';
import 'package:freego_flutter/components/view/date_choose_view.dart';
import 'package:freego_flutter/model/user.dart';
import 'package:freego_flutter/util/date_choose_util.dart';
import 'package:freego_flutter/util/local_user.dart';
import 'package:freego_flutter/util/native_calendar_util.dart';
import 'package:freego_flutter/util/order_pay_util.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:intl/intl.dart';

import '../merchent/merchant_api.dart';
import '../product_neo/product_source.dart';

class RestaurantBookGoPage extends StatelessWidget {
  final Restaurant restaurant;
  final List<RestaurantDish>? dishes;
  final int totalPrice;
  final List<RestaurantDish>? selectedDishes;
  final Map<int, int> dishQuantities;
  final DiningType diningMethods;

  const RestaurantBookGoPage({
    required this.restaurant,
    this.dishes,
    required this.totalPrice,
    required this.selectedDishes,
    required this.dishQuantities,
    required this.diningMethods,
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
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: RestaurantBookGoWidget(
          restaurant: restaurant,
          dishes: dishes,
          totalPrice: totalPrice,
          selectedDishes: selectedDishes,
          dishQuantities: dishQuantities,
          diningMethods: diningMethods,
        ),
      ),
    );
  }
}

class RestaurantBookGoWidget extends StatefulWidget {
  final Restaurant restaurant;
  final List<RestaurantDish>? dishes;
  final int totalPrice;
  final List<RestaurantDish>? selectedDishes;
  final Map<int, int> dishQuantities;
  final DiningType diningMethods;

  const RestaurantBookGoWidget({
    required this.restaurant,
    this.dishes,
    required this.totalPrice,
    required this.selectedDishes,
    required this.dishQuantities,
    required this.diningMethods,
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return RestaurantBookGoState();
  }
}

class RestaurantBookGoState extends State<RestaurantBookGoWidget> {
  late int orderNum;
  TextEditingController numController = TextEditingController();
  FocusNode numFocusNode = FocusNode();

  late DateTime firstDate;
  late DateTime lastDate;

  DateTime? tourDate;

  TextEditingController contactNameController = TextEditingController();
  TextEditingController contactPhoneController = TextEditingController();
  TextEditingController contactDinnerTimeController = TextEditingController();
  TextEditingController remarkController = TextEditingController();

  bool isSelectable = false;

  late double totalPrice;

  order_common.PayType? payType;

  List<PayType> payTypes = [PayType.wechat, PayType.alipay];

  TimeOfDay? selectedTime;
  @override
  void dispose() {
    numController.dispose();
    numFocusNode.dispose();
    contactNameController.dispose();
    contactPhoneController.dispose();
    contactDinnerTimeController.dispose();
    remarkController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    firstDate = DateTime.now();
    lastDate = DateTime.now().add(const Duration(days: 7));
    tourDate = DateTime.now();
    orderNum = 1;
    numController.text = '$orderNum';
    UserModel? user = LocalUser.getUser();
    if (user != null) {
      contactNameController.text = user.name ?? '';
      contactPhoneController.text = user.phone ?? '';
    }
    numFocusNode.addListener(() {
      if (!numFocusNode.hasFocus) {
        String val = numController.text;
        val = val.replaceAll(RegExp(r'[^0-9]'), '');
        val = val.replaceAll(RegExp(r'^0*'), '');
        orderNum = (double.tryParse(val) ?? 1).toInt();
        numController.text = orderNum.toString();
      }
    });
    ProductSource? source =
        ProductSourceExt.getSource(widget.restaurant.source ?? '');
    if (source == ProductSource.local) {
      Future.delayed(Duration.zero, () async {
        payTypes = await MerchantApi()
                .listPayTypes(merchantId: widget.restaurant.userId ?? 0) ??
            [];
      });
    }
  }

  void updateSelectedMealTime(String mealTime) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color.fromRGBO(242, 245, 250, 1)),
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: 50,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(203, 211, 220, 1),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.arrow_back_ios_new,
                                color: Colors.white),
                          ),
                        ],
                      ),
                      Text(
                        widget.restaurant.name ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  physics: const ClampingScrollPhysics(),
                  children: [
                    getBookNumWidet(),
                    getTargetDateget(),
                    getMealTimeget(),
                    getContactWidget(),
                    getNotesget(),
                    getPayTypeChooseWidget(),
                  ],
                ),
              ),
              getPriceWidget(widget.totalPrice, widget.selectedDishes,
                  widget.dishQuantities)
            ],
          ),
        ],
      ),
    );
  }

  Widget getBookNumWidet() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 30, 16, 16),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          widget.diningMethods == 1
              ? const Text(
                  '用餐人数',
                  style: TextStyle(
                      color: ThemeUtil.foregroundColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                )
              : const Text(
                  '餐具',
                  style: TextStyle(
                      color: ThemeUtil.foregroundColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
          Row(
            children: [
              InkWell(
                onTap: () {
                  if (orderNum <= 1) {
                    return;
                  }
                  --orderNum;
                  numController.text = orderNum.toString();
                  setState(() {});
                },
                child: Container(
                    height: 27,
                    width: 27,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border.fromBorderSide(
                            BorderSide(color: Colors.grey)),
                        borderRadius: BorderRadius.all(Radius.circular(4))),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.remove_rounded,
                      color: orderNum > 1
                          ? ThemeUtil.foregroundColor
                          : Colors.grey,
                    )),
              ),
              const SizedBox(
                width: 10,
              ),
              Container(
                height: 27,
                width: 70,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(4))),
                padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
                clipBehavior: Clip.hardEdge,
                child: TextField(
                  controller: numController,
                  focusNode: numFocusNode,
                  onTapOutside: (event) {
                    numFocusNode.unfocus();
                  },
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '',
                      isDense: true,
                      contentPadding: EdgeInsets.zero),
                  textAlign: TextAlign.end,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              InkWell(
                onTap: () {
                  ++orderNum;
                  numController.text = orderNum.toString();
                  setState(() {});
                },
                child: Container(
                    height: 27,
                    width: 27,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border.fromBorderSide(
                            BorderSide(color: Colors.grey)),
                        borderRadius: BorderRadius.all(Radius.circular(4))),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.add_rounded,
                      color: ThemeUtil.foregroundColor,
                    )),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget getTargetDateget() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(16))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '选择日期：',
                style: TextStyle(
                  color: ThemeUtil.foregroundColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              InkWell(
                  onTap: () async {
                    final config = DateChooseConfig(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width,
                        firstDate: DateTime.now().subtract(Duration(
                          hours: DateTime.now().hour,
                          minutes: DateTime.now().minute,
                          seconds: DateTime.now().second,
                          milliseconds: DateTime.now().millisecond,
                          microseconds: DateTime.now().microsecond,
                        )),
                        lastDate: firstDate.add(const Duration(days: 30)),
                        chooseMode: DateChooseMode.single);
                    List<DateTime>? results =
                        await DateChooseUtil.chooseDate(context, config);
                    if (results != null) {
                      tourDate = results.first;
                      if (mounted && context.mounted) {
                        setState(() {});
                      }
                    }
                  },
                  child: tourDate != null
                      ? Text(
                          DateFormat('yyyy年MM月dd日').format(tourDate!),
                          style: const TextStyle(
                              color: ThemeUtil.buttonColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              decoration: TextDecoration.underline),
                        )
                      : const Text(
                          '未开放',
                          style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 26),
                        )),
            ],
          ),
        ],
      ),
    );
  }

  Widget getMealTimeget() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.diningMethods == DiningType.inStore)
                const Text(
                  '用餐时间：',
                  style: TextStyle(
                    color: ThemeUtil.foregroundColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              if (widget.diningMethods == DiningType.packed)
                const Text(
                  '取餐时间：',
                  style: TextStyle(
                    color: ThemeUtil.foregroundColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              const SizedBox(width: 60),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.zero, minimumSize: Size.zero),
                      onPressed: () async {
                        TimeOfDay? time = await showTimePicker(
                            context: context,
                            initialTime: selectedTime ??
                                const TimeOfDay(hour: 8, minute: 0),
                            initialEntryMode: TimePickerEntryMode.inputOnly,
                            helpText: '',
                            hourLabelText: '',
                            minuteLabelText: '');
                        if (time != null) {
                          selectedTime = time;
                          if (mounted && context.mounted) {
                            setState(() {});
                          }
                        }
                      },
                      child: selectedTime != null
                          ? Text(
                              selectedTime!.format(context),
                              style: const TextStyle(
                                  color: ThemeUtil.buttonColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  decoration: TextDecoration.underline),
                            )
                          : const Text(
                              '请输入时间',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget getContactWidget() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(16))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '联系人',
            style: TextStyle(
                color: ThemeUtil.foregroundColor,
                fontWeight: FontWeight.bold,
                fontSize: 20),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black12))),
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
              controller: contactNameController,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Container(
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black12))),
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
        ],
      ),
    );
  }

  Widget getNotesget() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(16))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '备 注',
            style: TextStyle(
                color: ThemeUtil.foregroundColor,
                fontWeight: FontWeight.bold,
                fontSize: 20),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black12))),
            child: TextField(
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                hintText: '请输入您的要求',
                hintStyle: TextStyle(color: Colors.grey),
                isDense: true,
                contentPadding: EdgeInsets.fromLTRB(8, 10, 8, 10),
                border: InputBorder.none,
              ),
              controller: remarkController,
            ),
          )
        ],
      ),
    );
  }

  Widget getPayTypeChooseWidget() {
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
          const Text(
            '支付方式',
            style: TextStyle(
                color: ThemeUtil.foregroundColor,
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
          const SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () {
              payType = order_common.PayType.alipay;
              setState(() {});
            },
            child: Row(
              children: [
                Image.asset(
                  'images/pay_alipay.png',
                  height: 40,
                  width: 40,
                ),
                const SizedBox(
                  width: 10,
                ),
                const Text(
                  '支付宝支付',
                  style: TextStyle(color: ThemeUtil.foregroundColor),
                ),
                const Expanded(
                  child: SizedBox(),
                ),
                payType == order_common.PayType.alipay
                    ? const Icon(
                        Icons.radio_button_checked,
                        color: Colors.blue,
                      )
                    : const Icon(
                        Icons.radio_button_unchecked,
                        color: Colors.grey,
                      ),
              ],
            ),
          ),
          const Divider(),
          InkWell(
            onTap: () {
              payType = order_common.PayType.wechat;
              setState(() {});
            },
            child: Row(
              children: [
                Image.asset(
                  'images/pay_weixin.png',
                  height: 40,
                  width: 40,
                ),
                const SizedBox(
                  width: 10,
                ),
                const Text(
                  "微信支付",
                  style: TextStyle(color: ThemeUtil.foregroundColor),
                ),
                const Expanded(
                  child: SizedBox(),
                ),
                payType == order_common.PayType.wechat
                    ? const Icon(
                        Icons.radio_button_checked,
                        color: Colors.blue,
                      )
                    : const Icon(
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

  Future createRestaurantEvent() async {
    /*
    DateTime dinningDate = DateTime(tourDate!.year, tourDate!.month, tourDate!.day);
    Event event = NativeCalendarUtil().makeEvent(title: 'Freego-快速用餐', startTime: dinningDate, endTime: dinningDate, allDay: true, location: widget.restaurant.name);
    return NativeCalendarUtil().showEventOption(context: context, eventList: [event], title: 'Freego-快速用餐');
    */
  }

  Widget getPriceWidget(int totalPrice, List<RestaurantDish>? selectedDishes,
      Map<int, int> dishQuantities) {
    Restaurant restaurant = widget.restaurant;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text(
                '合计：',
                style: TextStyle(
                    color: ThemeUtil.foregroundColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              Text(
                '￥${StringUtil.getPriceStr(totalPrice)}',
                style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ],
          ),
          ElevatedButton(
              onPressed: () async {
                if (restaurant.id == null) {
                  ToastUtil.error('数据错误');
                  return;
                }
                if (selectedTime == null) {
                  if (widget.diningMethods == DiningType.inStore) {
                    ToastUtil.warn('请选择用餐时间');
                    return;
                  } else {
                    ToastUtil.warn('请选择取餐时间');
                    return;
                  }
                }
                DateTime selectedDateTime = DateTime(
                  tourDate!.year,
                  tourDate!.month,
                  tourDate!.day,
                  selectedTime!.hour,
                  selectedTime!.minute,
                );
                if (selectedDateTime.isBefore(DateTime.now())) {
                  ToastUtil.warn('用餐时间已过');
                  return;
                }
                String contactName = contactNameController.text.trim();
                if (contactName.isEmpty) {
                  ToastUtil.warn('请填写联系人姓名');
                  return;
                }
                String contactPhone = contactPhoneController.text.trim();
                if (contactPhone.isEmpty) {
                  ToastUtil.warn('请填写联系人电话');
                  return;
                }
                if (payType == null) {
                  ToastUtil.warn('请选择支付方式');
                  return;
                }
                if (payType == PayType.alipay) {
                  print('PayType: ${payType}');
                  //if(!payTypes.contains(PayType.alipay)){
                  // ToastUtil.warn('商家未开通支付宝');
                  // return;
                  //  }
                } else if (payType == PayType.wechat) {
                  // if(!payTypes.contains(PayType.wechat)){
                  //  ToastUtil.warn('商家未开通微信支付');
                  //  return;
                  //  }
                }
                if (selectedDishes == null || selectedDishes.isEmpty) {
                  ToastUtil.warn('菜品不能为空');
                  return;
                }
                List<OrderRestaurantDishParam> list = [];
                for (RestaurantDish dish in selectedDishes) {
                  OrderRestaurantDishParam param = OrderRestaurantDishParam();
                  param.dishId = dish.id;
                  param.quantity = dishQuantities[dish.id];
                  if (param.quantity == null || param.quantity! < 1) {
                    ToastUtil.warn('菜品数必须大于0');
                    return;
                  }
                  list.add(param);
                }
                String? orderSerial = await RestaurantApi().order(
                    restaurantId: restaurant.id!,
                    numberOfPeople: orderNum,
                    diningTime: selectedDateTime,
                    diningType: widget.diningMethods,
                    contactName: contactName,
                    contactPhone: contactPhone,
                    remark: remarkController.text.trim(),
                    dishList: list,
                    fail: (response) {
                      ToastUtil.error(response.data['message'] ?? '下单失败');
                    });
                if (orderSerial == null) {
                  return;
                }
                if (payType == PayType.alipay) {
                  if (restaurant.source == 'local') {
                    print('饭店支付确认1');
                    String? payInfo = await RestaurantApi().pay(
                        orderSerial: orderSerial, payType: PayType.zftalipay);
                    if (payInfo == null) {
                      ToastUtil.error('支付宝直付通预下单失败');
                      return;
                    }
                    bool result = await OrderPayUtil().alipay(payInfo);
                    if (result) {
                      ToastUtil.hint('支付成功');
                      await createRestaurantEvent();
                      Future.delayed(const Duration(seconds: 3), () async {
                        if (mounted && context.mounted) {
                          int count = 3;
                          Navigator.of(context)
                              .popUntil((route) => count-- <= 0);
                        }
                      });
                    }
                  } else {
                    print('饭店支付确认2');
                    String? payInfo = await RestaurantApi()
                        .pay(orderSerial: orderSerial, payType: PayType.alipay);
                    if (payInfo == null) {
                      ToastUtil.error('支付宝预下单失败');
                      return;
                    }
                    bool result = await OrderPayUtil().alipay(payInfo);
                    if (result) {
                      ToastUtil.hint('支付成功');
                      await createRestaurantEvent();
                      Future.delayed(const Duration(seconds: 3), () async {
                        if (mounted && context.mounted) {
                          int count = 3;
                          Navigator.of(context)
                              .popUntil((route) => count-- <= 0);
                        }
                      });
                    }
                  }
                } else if (payType == PayType.wechat) {
                  if (restaurant.source == 'local') {
                    String? payInfo = await RestaurantApi()
                        .pay(orderSerial: orderSerial, payType: PayType.sftwechat);
                    if (payInfo == null) {
                      ToastUtil.error('微信收付通预下单失败');
                      return;
                    }
                    OrderPayUtil().wechatPay(
                      payInfo,
                      onSuccess: () async {
                        ToastUtil.hint('支付成功');
                        await createRestaurantEvent();
                        Future.delayed(const Duration(seconds: 3), () async {
                          if (mounted && context.mounted) {
                            int count = 3;
                            Navigator.of(context)
                                .popUntil((route) => count-- <= 0);
                          }
                        });
                      },
                    );
                  } else {
                    String? payInfo = await RestaurantApi()
                        .pay(orderSerial: orderSerial, payType: PayType.wechat);
                    if (payInfo == null) {
                      ToastUtil.error('微信预下单失败');
                      return;
                    }
                    OrderPayUtil().wechatPay(
                      payInfo,
                      onSuccess: () async {
                        ToastUtil.hint('支付成功');
                        await createRestaurantEvent();
                        Future.delayed(const Duration(seconds: 3), () async {
                          if (mounted && context.mounted) {
                            int count = 3;
                            Navigator.of(context)
                                .popUntil((route) => count-- <= 0);
                          }
                        });
                      },
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
                minimumSize: const Size(120, 50), // 设置按钮的最小尺寸
              ),
              child: const Text(
                '支 付',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ))
        ],
      ),
    );
  }
}
