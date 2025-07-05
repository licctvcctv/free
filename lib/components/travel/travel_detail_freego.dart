import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/order_neo/order_common.dart'
    as order_common;
import 'package:freego_flutter/components/order_neo/order_common.dart';
import 'package:freego_flutter/components/travel/travel_api.dart';
import 'package:freego_flutter/components/travel/travel_common.dart';
import 'package:freego_flutter/model/user.dart';
import 'package:freego_flutter/util/date_time_util.dart';
import 'package:freego_flutter/util/local_user.dart';
import 'package:freego_flutter/util/native_calendar_util.dart';
import 'package:freego_flutter/util/order_pay_util.dart';
import 'package:freego_flutter/util/regular_util.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:intl/intl.dart';

import '../merchent/merchant_api.dart';
import '../product_neo/product_source.dart';

class TravelDetailGoPage extends StatefulWidget {
  final Travel travel;
  final DateTime startDate;
  final DateTime endDate;
  final TravelSuit selectedSuit;
  final TravelSuitPrice? travelSuitPrice;

  const TravelDetailGoPage({
    required this.travel,
    required this.startDate,
    required this.endDate,
    required this.selectedSuit,
    required this.travelSuitPrice,
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return TravelDetailGoPageState();
  }
}

class TravelDetailGoPageState extends State<TravelDetailGoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 10,
        elevation: 0,
        backgroundColor: ThemeUtil.backgroundColor,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: TravelDetailGoWidget(
          travel: widget.travel,
          //travelSuitList: widget.travelSuitList,
          startDate: widget.startDate,
          endDate: widget.endDate,
          selectedSuit: widget.selectedSuit,
          travelSuitPriceModel: widget.travelSuitPrice,
        ), // 传递相应的 TravelModel
      ),
    );
  }
}

class TravelDetailGoWidget extends StatefulWidget {
  final Travel travel;
  final DateTime startDate;
  final DateTime endDate;
  final TravelSuit selectedSuit;
  final TravelSuitPrice? travelSuitPriceModel;

  const TravelDetailGoWidget(
      {required this.travel,
      required this.startDate,
      required this.endDate,
      required this.selectedSuit,
      required this.travelSuitPriceModel,
      super.key});

  @override
  State<StatefulWidget> createState() {
    return TravelDetailGoState();
  }
}

class TravelDetailGoState extends State<TravelDetailGoWidget> {
  int selectedValue = 0;
  int numberOfAdults = 1;
  int numberOfChildren = 0;
  int numberOfOld = 0;

  TextEditingController numController = TextEditingController();
  TextEditingController childController = TextEditingController();
  TextEditingController oldController = TextEditingController();

  FocusNode numFocus = FocusNode();
  FocusNode childFocus = FocusNode();
  FocusNode oldFocus = FocusNode();

  TextEditingController contactNameController = TextEditingController();
  TextEditingController contactPhoneController = TextEditingController();
  TextEditingController contactCardNoController = TextEditingController();
  TextEditingController contactRemarkController = TextEditingController();
  TextEditingController passengerNameController = TextEditingController();
  TextEditingController passengerPhoneController = TextEditingController();

  List<CardType> supportCardList = [];

  order_common.PayType? payType;

  late TravelSuit selectedSuit;

  //TouristInfoType? touristInfoType;
  List<OrderGuest> guestList = [];

  TextEditingController guestNameController = TextEditingController();
  TextEditingController guestPhoneController = TextEditingController();
  TextEditingController guestCardNoController = TextEditingController();
  TextEditingController contactEmailController = TextEditingController();

  late DateTime firstDate;
  late DateTime lastDate;

  int orderNum = 1;

  ContactInfoType? contactInfoType;

  TouristInfoType? touristInfoType;

  CardType? contactCardType;
  List<Map<String, dynamic>> savedGuestInfoList = [];

  List<PayType> payTypes = [PayType.wechat, PayType.alipay];

  @override
  void initState() {
    super.initState();

    TravelSuit selectedSuit = widget.selectedSuit;
    int personNum = selectedSuit.personNum ?? 1;

    numController.text = (numberOfAdults * personNum).toString();
    childController.text = (numberOfChildren * personNum).toString();
    oldController.text = (numberOfOld * personNum).toString();

    UserModel? user = LocalUser.getUser();
    if (user != null) {
      contactNameController.text = user.name ?? '';
      contactPhoneController.text = user.phone ?? '';
    }
    touristInfoType = TouristInfoTypeExt.getType(4);
    if (selectedSuit.supportCardTypes != null) {
      List<String> supportCardTypeStringList =
          selectedSuit.supportCardTypes!.split(',');
      for (String val in supportCardTypeStringList) {
        int? num = int.tryParse(val);
        if (num != null) {
          CardType? cardType = CardTypeExt.getType(num);
          if (cardType != null) {
            supportCardList.add(cardType);
          }
        }
      }
    }

    numFocus.addListener(() {
      if (!numFocus.hasFocus) {
        String val = numController.text;
        val = val.replaceAll(RegExp(r'[^0-9]'), '');
        val = val.replaceAll(RegExp(r'^0*'), '');
        numberOfAdults = int.tryParse(val) ?? 1;
        numController.text = numberOfAdults.toString();
        setState(() {});
      }
    });
    childFocus.addListener(() {
      if (!childFocus.hasFocus) {
        String val = childController.text;
        val = val.replaceAll(RegExp(r'[^0-9]'), '');
        val = val.replaceAll(RegExp(r'^0*'), '');
        numberOfChildren = int.tryParse(val) ?? 0;
        childController.text = numberOfChildren.toString();
        setState(() {});
      }
    });
    oldFocus.addListener(() {
      if (!oldFocus.hasFocus) {
        String val = oldController.text;
        val = val.replaceAll(RegExp(r'[^0-9]'), '');
        val = val.replaceAll(RegExp(r'^0*'), '');
        numberOfOld = int.tryParse(val) ?? 0;
        oldController.text = numberOfOld.toString();
        setState(() {});
      }
    });
    ProductSource? source =
        ProductSourceExt.getSource(widget.travel.source ?? '');
    if (source == ProductSource.local) {
      Future.delayed(Duration.zero, () async {
        payTypes = await MerchantApi()
                .listPayTypes(merchantId: widget.travel.userId ?? 0) ??
            [];
      });
    }
  }

  @override
  void dispose() {
    numController.dispose();
    childController.dispose();
    oldController.dispose();

    numFocus.dispose();
    childFocus.dispose();
    oldFocus.dispose();

    contactNameController.dispose();
    contactPhoneController.dispose();
    contactCardNoController.dispose();
    contactRemarkController.dispose();
    passengerNameController.dispose();
    passengerPhoneController.dispose();

    guestNameController.dispose();
    guestPhoneController.dispose();
    guestCardNoController.dispose();
    contactEmailController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Travel travel = widget.travel;
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
                        '${travel.name}',
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
                    getInfoAndSuitViews(),
                    getDateWidget(),
                    getTravelNumberWidget(),
                    getGuestInfoWidget(),
                    getContactWidget(),
                    getemergencyWidget(),
                    getRemarkWidget(),
                    getPayTypeChooseWidget(),
                  ],
                ),
              ),
              getPriceWidget()
            ],
          ),
        ],
      ),
    );
  }

  Widget getInfoAndSuitViews() {
    int? idToShow = widget.travel.id; // 获取 travelModel 的 ID
    int selectedValue = 1;
    Travel travel = widget.travel;
    TravelSuit selectedSuit = widget.selectedSuit;
    TravelSuitPrice? travelSuitPriceModel = widget.travelSuitPriceModel;
    return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(16))),
        child: Container(
          decoration: const BoxDecoration(
              color: ThemeUtil.backgroundColor,
              borderRadius: BorderRadius.all(Radius.circular(4))),
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selectedSuit.name!,
                style: const TextStyle(
                    color: ThemeUtil.foregroundColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                selectedSuit.description!,
                style: TextStyle(color: Colors.black.withOpacity(0.5)),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                travel.orderBeforeDays != 0
                    ? "提前${travel.orderBeforeDays}天预定"
                    : "当天可预定",
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    travelSuitPriceModel == null
                        ? '无价格'
                        : '￥${StringUtil.getPriceStr(travelSuitPriceModel.price)}起',
                    style: const TextStyle(
                        color: Colors.blueAccent, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  Widget getDateWidget() {
    int dayNum = widget.travel.dayNum ?? 0;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              '旅游日期',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('yyyy-MM-dd').format(widget.startDate),
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                ),
              ),
              Text(
                DateTimeUtil.getWeekDayCn(widget.startDate),
                style: const TextStyle(color: Colors.grey),
              ),
              const Text(
                ' 至 ',
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                DateFormat('yyyy-MM-dd').format(widget.endDate),
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                ),
              ),
              Text(
                DateTimeUtil.getWeekDayCn(widget.endDate),
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget getTravelNumberWidget() {
    TravelSuitPrice? travelSuitPriceModel = widget.travelSuitPriceModel;
    if (travelSuitPriceModel == null) {
      return const SizedBox();
    }
    int adultPrice = widget.travel.minPrice ?? 0;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              '出行人数',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    '成人：',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    travelSuitPriceModel.price != null
                        ? '￥${(numberOfAdults * travelSuitPriceModel.price!) / 100}'
                        : '电询',
                    style: TextStyle(
                      color: travelSuitPriceModel.price != null
                          ? Colors.blue
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      if (numberOfAdults <= 1) {
                        return;
                      }
                      --numberOfAdults;
                      int personNum = widget.selectedSuit.personNum ?? 1;
                      numController.text =
                          (numberOfAdults * personNum).toString();
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
                          color: numberOfAdults > 1
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
                      focusNode: numFocus,
                      onTapOutside: (event) {
                        numFocus.unfocus();
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
                      ++numberOfAdults;
                      int personNum = widget.selectedSuit.personNum ?? 1;
                      numController.text =
                          (numberOfAdults * personNum).toString();
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
                        child: const Icon(Icons.add_rounded,
                            color: ThemeUtil.foregroundColor)),
                  ),
                ],
              ),
            ],
          ),
          travelSuitPriceModel.childPrice != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                      Row(
                        children: const [
                          Text(
                            '（身高 > 120cm）',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ])
              : const SizedBox(),
          const SizedBox(height: 10),
          travelSuitPriceModel.childPrice != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '儿童：',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        numberOfChildren == 0
                            ? const Text(
                                '￥--',
                                style: TextStyle(
                                  color: ThemeUtil.foregroundColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              )
                            : Text(
                                '￥${numberOfChildren * travelSuitPriceModel.childPrice! / 100}',
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ],
                    ),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            if (numberOfChildren <= 0) {
                              return;
                            }
                            --numberOfChildren;
                            int personNum = widget.selectedSuit.personNum ?? 1;
                            childController.text =
                                (numberOfChildren * personNum).toString();
                            setState(() {});
                          },
                          child: Container(
                              height: 27,
                              width: 27,
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  border: Border.fromBorderSide(
                                      BorderSide(color: Colors.grey)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4))),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.remove_rounded,
                                color: numberOfChildren > 1
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4))),
                          padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
                          clipBehavior: Clip.hardEdge,
                          child: TextField(
                            controller: childController,
                            focusNode: childFocus,
                            onTapOutside: (event) {
                              childFocus.unfocus();
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
                            ++numberOfChildren;
                            int personNum = widget.selectedSuit.personNum ?? 1;
                            childController.text =
                                (numberOfChildren * personNum).toString();
                            setState(() {});
                          },
                          child: Container(
                              height: 27,
                              width: 27,
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  border: Border.fromBorderSide(
                                      BorderSide(color: Colors.grey)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4))),
                              alignment: Alignment.center,
                              child: const Icon(Icons.add_rounded,
                                  color: ThemeUtil.foregroundColor)),
                        ),
                      ],
                    ),
                  ],
                )
              : const SizedBox(),
          travelSuitPriceModel.childPrice != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                      Row(
                        children: const [
                          Text(
                            '（身高 > 120cm）',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ])
              : const SizedBox(),
          const SizedBox(height: 10),
          travelSuitPriceModel.oldPrice != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '老人：',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        numberOfOld == 0
                            ? const Text(
                                '￥--',
                                style: TextStyle(
                                  color: ThemeUtil.foregroundColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              )
                            : Text(
                                '￥${numberOfOld * travelSuitPriceModel.oldPrice! / 100}',
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ],
                    ),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            if (numberOfOld <= 0) {
                              return;
                            }
                            --numberOfOld;
                            int personNum = widget.selectedSuit.personNum ?? 1;
                            oldController.text =
                                (numberOfOld * personNum).toString();
                            setState(() {});
                          },
                          child: Container(
                              height: 27,
                              width: 27,
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  border: Border.fromBorderSide(
                                      BorderSide(color: Colors.grey)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4))),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.remove_rounded,
                                color: numberOfOld > 1
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4))),
                          padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
                          clipBehavior: Clip.hardEdge,
                          child: TextField(
                            controller: oldController,
                            focusNode: oldFocus,
                            onTapOutside: (event) {
                              oldFocus.unfocus();
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
                            ++numberOfOld;
                            int personNum = widget.selectedSuit.personNum ?? 1;
                            oldController.text =
                                (numberOfOld * personNum).toString();
                            setState(() {});
                          },
                          child: Container(
                              height: 27,
                              width: 27,
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  border: Border.fromBorderSide(
                                      BorderSide(color: Colors.grey)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4))),
                              alignment: Alignment.center,
                              child: const Icon(Icons.add_rounded,
                                  color: ThemeUtil.foregroundColor)),
                        ),
                      ],
                    ),
                  ],
                )
              : const SizedBox(),
          travelSuitPriceModel.oldPrice != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                      Row(
                        children: const [
                          Text(
                            '（年满65周岁）',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ])
              : const SizedBox(),
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
                fontSize: 18),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black12))),
            child: TextField(
              keyboardType: TextInputType.name,
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
          const SizedBox(
            height: 8,
          ),
          Container(
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black12))),
            child: TextField(
              keyboardType: TextInputType.emailAddress,
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

  Widget getGuestInfoWidget() {
    int guestNum = 1;
    if (touristInfoType == TouristInfoType.everyNamePhoneCard ||
        touristInfoType == TouristInfoType.everyNamePhoneCard) {
      int personNum = widget.selectedSuit.personNum ?? 1;
      guestNum = (numberOfAdults + numberOfChildren + numberOfOld) * personNum;
    }
    List<Widget> widgets = [];
    for (int i = 0; i < guestList.length; ++i) {
      OrderGuest guest = guestList[i];
      widgets.add(GestureDetector(
        onTap: () async {
          Object? result = showOrderGuest(guest);
          if (result is OrderGuest) {
            guestList[i] = result;
          }
        },
        onLongPressStart: (evt) {
          double dx = evt.globalPosition.dx;
          double dy = evt.globalPosition.dy;
          const double width = 60;
          const double height = 36;
          if (width + dx > MediaQuery.of(context).size.width) {
            dx = dx - width;
          }
          showGeneralDialog(
            barrierColor: Colors.transparent,
            barrierDismissible: true,
            barrierLabel: '',
            context: context,
            pageBuilder: (context, animation, secondaryAnimation) {
              return Stack(
                children: [
                  Positioned(
                    left: dx,
                    top: dy,
                    child: Material(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      child: InkWell(
                        onTap: () {
                          guestList.removeAt(i);
                          Navigator.of(context).pop();
                          if (mounted && context.mounted) {
                            setState(() {});
                          }
                        },
                        child: Container(
                          width: width,
                          height: height,
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              boxShadow: [
                                BoxShadow(color: Colors.black26, blurRadius: 4)
                              ]),
                          alignment: Alignment.center,
                          child: const Text(
                            '删除',
                            style: TextStyle(color: ThemeUtil.foregroundColor),
                          ),
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
          constraints: const BoxConstraints(maxWidth: 100),
          decoration: const BoxDecoration(
              border: Border.fromBorderSide(
                  BorderSide(color: ThemeUtil.foregroundColor))),
          padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                guest.name!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: ThemeUtil.foregroundColor),
              )
            ],
          ),
        ),
      ));
    }
    if (guestList.length < guestNum) {
      widgets.add(InkWell(
        onTap: () async {
          Object? result = await showOrderGuest(null);
          if (result is OrderGuest) {
            guestList.add(result);
            if (mounted && context.mounted) {
              setState(() {});
            }
          }
        },
        child: Container(
          height: 32,
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            border: Border.fromBorderSide(
                BorderSide(color: ThemeUtil.foregroundColor)),
            color: ThemeUtil.buttonColor,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.add_circle_outline_rounded,
                color: ThemeUtil.foregroundColor,
              ),
              Text(
                '添加',
                style: TextStyle(color: ThemeUtil.foregroundColor),
              )
            ],
          ),
        ),
      ));
    }
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
            '登记信息',
            style: TextStyle(
                color: ThemeUtil.foregroundColor,
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
          guestList.length < guestNum
              ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    '还需填写${guestNum - guestList.length}位游客信息',
                    style: const TextStyle(color: Colors.grey),
                  ),
                )
              : const SizedBox(),
          const SizedBox(
            height: 10,
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: widgets,
          )
        ],
      ),
    );
  }

  Future<Object?> showOrderGuest(OrderGuest? guest) {
    if (guest != null) {
      guestNameController.text = guest.name ?? '';
      guestCardNoController.text = guest.cardNo ?? '';
    } else {
      guestNameController.text = '';
      guestCardNoController.text = '';
    }
    guest ??= OrderGuest();
    CardType? cardType;
    if (guest.cardType != null) {
      cardType = CardTypeExt.getType(guest.cardType!);
    }
    bool setAsContact = guestList.isEmpty;
    return showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                          BoxShadow(color: Colors.black12, blurRadius: 4)
                        ]),
                    clipBehavior: Clip.hardEdge,
                    child: Column(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: Colors.black12))),
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
                        touristInfoType == TouristInfoType.everyNamePhoneCard ||
                                touristInfoType ==
                                    TouristInfoType.singleNamePhoneCard
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(left: 7),
                                    height: 44,
                                    decoration: const BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.black12))),
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '证件类型',
                                          style: TextStyle(
                                              color: cardType == null ||
                                                      cardType == CardType.none
                                                  ? Colors.grey
                                                  : ThemeUtil.foregroundColor,
                                              fontSize: 16),
                                        ),
                                        InkWell(
                                            onTap: () async {
                                              Object? result =
                                                  await showCardType();
                                              if (result is CardType) {
                                                cardType = result;
                                                if (context.mounted) {
                                                  setState(() {});
                                                }
                                              }
                                            },
                                            child: cardType == null ||
                                                    cardType == CardType.none
                                                ? const Text(
                                                    '请选择',
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 16),
                                                  )
                                                : Text(
                                                    cardType!.getName(),
                                                    style: const TextStyle(
                                                        color: ThemeUtil
                                                            .foregroundColor,
                                                        fontSize: 16),
                                                  ))
                                      ],
                                    ),
                                  ),
                                  Container(
                                    decoration: const BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.black12))),
                                    child: TextField(
                                      keyboardType: TextInputType.text,
                                      textInputAction: TextInputAction.done,
                                      decoration: const InputDecoration(
                                        hintText: '证件号',
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                        isDense: true,
                                        contentPadding:
                                            EdgeInsets.fromLTRB(8, 10, 8, 10),
                                        border: InputBorder.none,
                                      ),
                                      controller: guestCardNoController,
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox(),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  '设为联系人',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 16),
                                ),
                                InkWell(
                                    onTap: () {
                                      setAsContact = !setAsContact;
                                      setState(() {});
                                    },
                                    child: setAsContact
                                        ? const Icon(
                                            Icons.radio_button_checked,
                                            color: Colors.lightGreen,
                                          )
                                        : const Icon(
                                            Icons.radio_button_unchecked,
                                            color: Colors.grey,
                                          ))
                              ],
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: ThemeUtil.foregroundColor),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('取消')),
                            const SizedBox(
                              width: 20,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                String name = guestNameController.text.trim();
                                if (name.isEmpty) {
                                  ToastUtil.warn('名字不能为空');
                                  return;
                                }
                                if (cardType == null ||
                                    cardType == CardType.none) {
                                  ToastUtil.warn('请选择证件类型');
                                  return;
                                }
                                String? cardNo;
                                cardNo = guestCardNoController.text.trim();
                                if (cardNo.isEmpty) {
                                  ToastUtil.warn('证件号不能为空');
                                  return;
                                }
                                if (cardType == CardType.idCard &&
                                    !RegularUtil.checkIdCard(cardNo)) {
                                  ToastUtil.warn('请输入正确的身份证号');
                                  return;
                                }
                                guest!.name = name;
                                guest.cardNo = cardNo;
                                guest.cardType = cardType?.getNum();
                                Map<String, dynamic> guestInfo = {
                                  'name': name,
                                  'cardNo': cardNo,
                                  'cardType': cardType?.getNum(),
                                };
                                savedGuestInfoList.add(guestInfo);
                                Navigator.of(context).pop(guest);
                                if (setAsContact) {
                                  contactNameController.text = name;
                                  contactCardNoController.text = cardNo;
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
                              supportCardList.length,
                              (index) {
                                final isSelected =
                                    cardType == supportCardList[index];
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

  Widget getemergencyWidget() {
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
            '紧急联系人',
            style: TextStyle(
                color: ThemeUtil.foregroundColor,
                fontWeight: FontWeight.bold,
                fontSize: 18),
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
              controller: passengerNameController,
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
              controller: passengerPhoneController,
            ),
          ),
        ],
      ),
    );
  }

  Widget getRemarkWidget() {
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
                fontSize: 18),
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
              controller: contactRemarkController,
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

  Future buy() async {
    int guestNum = 1;
    if (touristInfoType == TouristInfoType.everyNamePhoneCard ||
        touristInfoType == TouristInfoType.singleNamePhoneCard) {
      int personNum = widget.selectedSuit.personNum ?? 1;
      guestNum = (numberOfAdults + numberOfChildren + numberOfOld) * personNum;
    }
    if (guestNum != guestList.length) {
      ToastUtil.warn('登记人数不足');
      return;
    }
    for (OrderGuest guest in guestList) {
      if (guest.name == null || guest.name!.isEmpty) {
        ToastUtil.warn('请登记正确的姓名');
        return;
      }
      if (touristInfoType == TouristInfoType.singleNamePhoneCard ||
          touristInfoType == TouristInfoType.everyNamePhoneCard) {
        if (guest.cardNo == null || guest.cardNo!.isEmpty) {
          ToastUtil.warn('请登记正确的证件号');
          return;
        }
      }
    }
    String contactName = contactNameController.text.trim();
    if (contactName.isEmpty) {
      ToastUtil.warn('清填写联系人姓名');
      return;
    }
    String contactPhone = contactPhoneController.text.trim();
    if (contactPhone.isEmpty) {
      ToastUtil.warn('请填写联系人电话');
      return;
    }
    if (!RegularUtil.checkPhone(contactPhone)) {
      ToastUtil.warn('联系人电话格式错误');
      return;
    }
    String contactEmail = contactEmailController.text.trim();
    if (contactEmail.isNotEmpty) {
      if (!RegularUtil.checkEmail(contactEmail)) {
        ToastUtil.warn('邮箱格式错误');
        return;
      }
    }
    String passengerName = passengerNameController.text.trim();
    if (passengerName.isEmpty) {
      ToastUtil.warn('请填写紧急联系人姓名');
      return;
    }
    String passengerPhone = passengerPhoneController.text.trim();
    if (passengerPhone.isEmpty) {
      ToastUtil.warn('请填写紧急联系人电话');
      return;
    }
    if (!RegularUtil.checkPhone(passengerPhone)) {
      ToastUtil.warn('紧急联系人电话格式错误');
      return;
    }
    if (payType == null) {
      ToastUtil.warn('请选择支付方式');
      return;
    }
    if (payType == PayType.alipay) {
      print('PayType: ${payType}');
      //if(!payTypes.contains(PayType.alipay)){
      //  ToastUtil.warn('商家未开通支付宝');
      //  return;
      //}
    } else if (payType == PayType.wechat) {
      //if(!payTypes.contains(PayType.wechat)){
      //  ToastUtil.warn('商家未开通微信支付');
      //  return;
      //}
    }
    String? orderSerial = await TravelApi().order(
        travelId: widget.travel.id!,
        travelSuitId: widget.selectedSuit.id!,
        number: numberOfAdults,
        oldNumber: numberOfOld,
        childNumber: numberOfChildren,
        startDate: widget.startDate,
        contactName: contactName,
        contactPhone: contactPhone,
        emergencyName: passengerName,
        emergencyPhone: passengerPhone,
        remark: contactRemarkController.text.trim(),
        guestList: guestList,
        fail: (response) {
          ToastUtil.error(response.data['message'] ?? '下单失败');
        });
    if (orderSerial == null) {
      return;
    }
    if (payType == order_common.PayType.alipay) {
      print('本地酒店支付2');
      if (widget.travel.source == 'local') {
        String? payInfo = await TravelApi()
            .pay(orderSerial: orderSerial, payType: PayType.zftalipay);
        if (payInfo == null) {
          ToastUtil.error('支付宝直付通预下单失败');
          return;
        }
        bool result = await OrderPayUtil().alipay(payInfo);
        if (result) {
          ToastUtil.hint('支付成功');
          //await createTravelEvent();
          Future.delayed(const Duration(seconds: 3), () async {
            if (mounted && context.mounted) {
              Navigator.of(context).pop();
            }
          });
        }
      } else {
        print('本地酒店支付2');
        if (widget.travel.source == 'local') {
          String? payInfo = await TravelApi()
              .pay(orderSerial: orderSerial, payType: PayType.alipay);
          if (payInfo == null) {
            ToastUtil.error('支付宝预下单失败');
            return;
          }
          bool result = await OrderPayUtil().alipay(payInfo);
          if (result) {
            ToastUtil.hint('支付成功');
            //await createTravelEvent();
            Future.delayed(const Duration(seconds: 3), () async {
              if (mounted && context.mounted) {
                Navigator.of(context).pop();
              }
            });
          }
        }
      }
    } else if (payType == order_common.PayType.wechat) {
      if (widget.travel.source == 'local') {
        String? payInfo = await TravelApi()
            .pay(orderSerial: orderSerial, payType: PayType.sftwechat);
        if (payInfo == null) {
          ToastUtil.error('微信收付通预下单失败');
          return;
        }
        OrderPayUtil().wechatPay(payInfo, onSuccess: () async {
          ToastUtil.hint('支付成功');
          //await createTravelEvent();
          Future.delayed(const Duration(seconds: 3), () async {
            if (mounted && context.mounted) {
              Navigator.of(context).pop();
            }
          });
        });
      } else {
        String? payInfo = await TravelApi()
            .pay(orderSerial: orderSerial, payType: PayType.wechat);
        if (payInfo == null) {
          ToastUtil.error('微信预下单失败');
          return;
        }
        OrderPayUtil().wechatPay(payInfo, onSuccess: () async {
          ToastUtil.hint('支付成功');
          //await createTravelEvent();
          Future.delayed(const Duration(seconds: 3), () async {
            if (mounted && context.mounted) {
              Navigator.of(context).pop();
            }
          });
        });
      }
    }
  }

  Widget getPriceWidget() {
    TravelSuit selectedSuit = widget.selectedSuit;
    TravelSuitPrice? travelSuitPriceModel = widget.travelSuitPriceModel;
    if (travelSuitPriceModel == null) {
      return const SizedBox();
    }
    int totalAdultPrice = numberOfAdults * travelSuitPriceModel.price!;
    int totalPrice = totalAdultPrice;
    orderNum = numberOfAdults;
    if (travelSuitPriceModel.childPrice != null) {
      int totalChildPrice = numberOfChildren * travelSuitPriceModel.childPrice!;
      totalPrice = totalPrice + totalChildPrice;
      orderNum = orderNum + numberOfChildren;
    }
    if (travelSuitPriceModel.oldPrice != null) {
      int totalOld = numberOfOld * travelSuitPriceModel.oldPrice!;
      totalPrice = totalPrice + totalOld;
      orderNum = orderNum + numberOfOld;
    }

    int? idToShow = widget.travel.id;

    List<Widget> widgets = [];
    widgets.add(const Divider());
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ), // 总价
            ],
          ),
          ElevatedButton(
              onPressed: () {
                if (idToShow == null) {
                  ToastUtil.error('数据错误');
                  return;
                }
                buy();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
                minimumSize: const Size(120, 50),
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

  Future createTravelEvent() async {
    Event event = NativeCalendarUtil().makeEvent(
        title: 'Freego-快速旅行',
        startTime: widget.startDate,
        endTime: widget.endDate,
        allDay: true,
        location: widget.travel.name);
    return NativeCalendarUtil().showEventOption(
        context: context, eventList: [event], title: 'Freego-快速旅行');
  }

  /*Future getSuits() async {
    int id = widget.travelId;
    return HttpTravel.suits(id, (isSuccess, data, msg, code) {
      if (isSuccess) {
        var list = data as List<dynamic>;
        for (var i = 0; i < list.length; i++) {
          var suit = TravelSuitModel.fromJson(list[i]);
          travelSuitList.add(suit);
          getSuitPrices(suit.id);
        }
        setState(() {});
      }
    });
  }

  getSuitPrices(int suitId) {
    List<TravelSuitPriceModel> priceList = [];
    Map<String, TravelSuitPriceModel> priceDayMap = {};
    HttpTravel.getSuitPrices(suitId, (isSuccess, data, msg, code) {
      var list = data as List<dynamic>;
      for (var i = 0; i < list.length; i++) {
        var mo = TravelSuitPriceModel.fromJson(list[i]);
        priceList.add(mo);
        priceDayMap[mo.day!] = mo;
      }
      priceMap[suitId] = priceList;
      priceDeepMap[suitId] = priceDayMap;

      if (priceList.isNotEmpty) {
        setState(() {
          priceAdults = priceList[0].price ?? 0;
          priceChildren = priceList[0].childPrice ?? 0;
        });
      }
      print('travelId: ${widget.travelId}');
      print('suitId: ${suitId}');
    });
  }*/
}
