import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/order_neo/order_common.dart';
import 'package:freego_flutter/components/scenic/scenic_common.dart';
import 'package:freego_flutter/components/scenic/scenic_home_freego.dart';
import 'package:freego_flutter/components/scenic/api/local_scenic_api.dart';
import 'package:freego_flutter/components/travel/travel_common.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/model/travel.dart';
import 'package:freego_flutter/model/travel_suit.dart';
import 'package:freego_flutter/util/date_time_util.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:intl/intl.dart';

class TravelScenicDetailPage extends StatelessWidget {
  final TravelModel travelModel;
  final DateTime startDate;
  final DateTime endDate;
  final int totalPrice;
  final TravelSuitModel selectedSuit;
  final int numberOfAdults;
  final int numberOfChildren;
  final String contactName;
  final String contactPhone;
  final CardType? contactCardType;
  final String contactCardNo;
  final String contactEmail;
  final String contactRemark;

  const TravelScenicDetailPage({
    required this.travelModel,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.selectedSuit,
    required this.numberOfAdults,
    required this.numberOfChildren,
    required this.contactName,
    required this.contactPhone,
    required this.contactCardType,
    required this.contactCardNo,
    required this.contactEmail,
    required this.contactRemark,
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
      body: TravelScenicDetailWidget(
        travelModel: travelModel,
        startDate: startDate,
        endDate: endDate,
        totalPrice: totalPrice,
        selectedSuit: selectedSuit,
        numberOfAdults: numberOfAdults,
        numberOfChildren: numberOfChildren,
        contactName: contactName,
        contactPhone: contactPhone,
        contactCardType: contactCardType,
        contactCardNo: contactCardNo,
        contactEmail: contactEmail,
        contactRemark: contactRemark,
      ),
    );
  }
}

class TravelScenicDetailWidget extends StatefulWidget {
  final TravelModel travelModel;
  final DateTime startDate;
  final DateTime endDate;
  final int totalPrice;
  final TravelSuitModel selectedSuit;
  final int numberOfAdults;
  final int numberOfChildren;
  final String contactName;
  final String contactPhone;
  final CardType? contactCardType;
  final String contactCardNo;
  final String contactEmail;
  final String contactRemark;

  const TravelScenicDetailWidget({
    required this.travelModel,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.selectedSuit,
    required this.numberOfAdults,
    required this.numberOfChildren,
    required this.contactName,
    required this.contactPhone,
    required this.contactCardType,
    required this.contactCardNo,
    required this.contactEmail,
    required this.contactRemark,
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return TravelScenicDetailState();
  }
}

class TravelScenicDetailState extends State<TravelScenicDetailWidget> {
  Widget svgScenic = SvgPicture.asset(
    'svg/icon_scenic.svg',
    color: ThemeUtil.foregroundColor,
  );
  bool showTimeLimit = false;
  Timer? payLimitTimer;
  int payLimitSeconds = 0;

  static const double FIELD_NAME_WIDTH = 100;

  @override
  void dispose() {
    //payLimitTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    //OrderScenic order = widget.order;

    /*if(order.orderStatus != null){
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
    }*/
  }

  @override
  Widget build(BuildContext context) {
    //TravelScenic order = widget.order;
    TravelModel travelModel = widget.travelModel;
    return Container(
      color: ThemeUtil.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonHeader(
            center: Text(
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
                      Row(children: [
                        Expanded(
                            child: Column(children: [
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: svgScenic,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          InkWell(
                            onTap: () async {},
                            child: Text(
                              travelModel.name ?? '',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: ThemeUtil.foregroundColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                          ),
                          const SizedBox(
                            height : 10,
                          ),
                          Text(
                            '${widget.selectedSuit.name}',
                            style: const TextStyle(
                              color: ThemeUtil.foregroundColor,
                              fontWeight: FontWeight.bold,
                              //fontSize: 18
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            '${travelModel.dayNum!}天${travelModel.nightNum!}晚',
                            style: const TextStyle(
                              color: ThemeUtil.foregroundColor,
                              fontWeight: FontWeight.bold,
                              //fontSize: 18
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            '￥${widget.totalPrice}',
                            style: const TextStyle(
                              color: ThemeUtil.foregroundColor,
                              fontWeight: FontWeight.bold,
                              //fontSize: 18
                            ),
                          ),
                        ]))
                      ]),
                      const SizedBox(
                        height: 10,
                      ),
                      /*Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Wrap(
                          children: [
                            const SizedBox(
                              width: FIELD_NAME_WIDTH,
                              child: Text(
                                '订单号',
                              ),
                            ),
                            //Text('￥${widget.totalPrice}', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold),),
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
                              ),
                            ),
                            //Text('￥${widget.totalPrice}', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ),*/
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Wrap(
                          children: [
                            const SizedBox(
                              width: FIELD_NAME_WIDTH,
                              child: Text(
                                '开始日期',
                              ),
                            ),
                            Text(
                              DateFormat('yyyy-MM-dd').format(widget.startDate),
                              style: const TextStyle(
                                  color: ThemeUtil.foregroundColor),
                            ),
                            const Text(' (',
                              style: TextStyle(
                                  color: ThemeUtil.foregroundColor),
                            ),
                            Text(
                              DateTimeUtil.getWeekDayCn(widget.startDate),
                              style: const TextStyle(
                                  color: ThemeUtil.foregroundColor),
                            ),
                            const Text(')',
                              style: TextStyle(
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
                                '结束日期',
                              ),
                            ),
                            Text(
                              DateFormat('yyyy-MM-dd').format(widget.endDate),
                              style: const TextStyle(
                                  color: ThemeUtil.foregroundColor),
                            ),
                            const Text(' (',
                              style: TextStyle(
                                  color: ThemeUtil.foregroundColor),
                            ),
                            Text(
                              DateTimeUtil.getWeekDayCn(widget.endDate),
                              style: const TextStyle(
                                  color: ThemeUtil.foregroundColor),
                            ),
                            const Text(')',
                              style: TextStyle(
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
                                '出行人数',
                              ),
                            ),
                            Text(
                              '共${widget.numberOfAdults + widget.numberOfChildren}人',
                              style: const TextStyle(
                                  color: ThemeUtil.foregroundColor),
                            ),
                            const Text(
                              '(',
                              style:
                                  TextStyle(color: ThemeUtil.foregroundColor),
                            ),
                            Text(
                              '${widget.numberOfAdults != 0 ? '成人:${widget.numberOfAdults}' : ''}',
                              style: const TextStyle(
                                  color: ThemeUtil.foregroundColor),
                            ),
                            Text(
                              '${widget.numberOfChildren != 0 ? ' 儿童:${widget.numberOfChildren}' : ''}',
                              style: const TextStyle(
                                  color: ThemeUtil.foregroundColor),
                            ),
                            Text(
                              ')',
                              style: const TextStyle(
                                  color: ThemeUtil.foregroundColor),
                            ),
                            const Divider(),
                            getCancelRuleWidget(),
                            const Divider(),
                            getContactWidget(),
                            //getPayStatusWidget(),
                          ],
                        ),
                      ),
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

  Widget getCancelRuleWidget(){
    /*OrderHotel order = widget.order;
    if(order.cancelRuleType == null){
      return const SizedBox();
    }
    CancelRuleType? cancelRuleType = CancelRuleTypeExt.getType(order.cancelRuleType!);
    if(cancelRuleType == null){
      return const SizedBox();
    }*/
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
              /*cancelRuleType == CancelRuleType.unable ?
              const Text('无法取消', style: TextStyle(color: ThemeUtil.foregroundColor),) :
              cancelRuleType == CancelRuleType.inTime ?*/
              const Text('限时免费取消', style: TextStyle(color: ThemeUtil.foregroundColor),)// :
             // cancelRuleType == CancelRuleType.charged ?
             // const Text('收费取消', style: TextStyle(color: ThemeUtil.foregroundColor),) :
             // const SizedBox()
            ],
          ),
          /*order.cancelRuleDesc != null ?
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(order.cancelRuleDesc!, style: const TextStyle(color: ThemeUtil.foregroundColor),),
          ) : const SizedBox(),*/
          //order.cancelLatestTime != null ?
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                const SizedBox(
                  width: FIELD_NAME_WIDTH,
                  child: Text('取消时间', style: TextStyle(color: ThemeUtil.foregroundColor),),
                ), 
                //const SizedBox(width: 10,),
                Text(DateFormat('yyyy-MM-dd HH:mm').format(widget.startDate.subtract(const Duration(days: 2))), style: const TextStyle(color: ThemeUtil.foregroundColor),),
                const Text(' 前可取消', style: TextStyle(color: ThemeUtil.foregroundColor),),
              ],
            )
          ),// : const SizedBox(),
        ],
      ),
    );
  }

  Widget getContactWidget() {
    //OrderScenic order = widget.order;
    //if(order.contactName == null && order.contactPhone == null && order.contactCardType == null && order.contactCardNo == null){
    //  return const SizedBox();
    //}
    //CardType? cardType;
    //if(order.contactCardType != null){
    //  cardType = CardTypeExt.getType(order.contactCardType!);
    //}
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      //order.contactName != null ?
      Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Wrap(
          children: [
            const SizedBox(
              width: FIELD_NAME_WIDTH,
              child: Text(
                '联系姓名',
                style: TextStyle(color: ThemeUtil.foregroundColor),
              ),
            ),
            Text(
              widget.contactName,
              style: const TextStyle(color: ThemeUtil.foregroundColor),
            )
          ],
        ),
      ), // : const SizedBox(),
      //order.contactPhone != null ?
      Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Wrap(
          children: [
            const SizedBox(
              width: FIELD_NAME_WIDTH,
              child: Text(
                '联系电话',
                style: TextStyle(color: ThemeUtil.foregroundColor),
              ),
            ),
            Text(
              widget.contactPhone,
              style: const TextStyle(color: ThemeUtil.foregroundColor),
            )
          ],
        ),
      ), // : const SizedBox(),
      //cardType != null && cardType != CardType.none ?
      Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Wrap(
          children: [
            const SizedBox(
              width: FIELD_NAME_WIDTH,
              child: Text(
                '证件类型',
                style: TextStyle(color: ThemeUtil.foregroundColor),
              ),
            ),
            Text(
              widget.contactCardType!.getName(),
              style: const TextStyle(color: ThemeUtil.foregroundColor),
            )
          ],
        ),
      ), // : const SizedBox(),
      //order.contactCardNo != null ?
      Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Wrap(
          children: [
            const SizedBox(
              width: FIELD_NAME_WIDTH,
              child: Text(
                '证件号',
                style: TextStyle(color: ThemeUtil.foregroundColor),
              ),
            ),
            Text(
              widget.contactCardNo,
              style: const TextStyle(color: ThemeUtil.foregroundColor),
            )
          ],
        ),
      ), // : const SizedBox(),
      Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Wrap(
          children: [
            const SizedBox(
              width: FIELD_NAME_WIDTH,
              child: Text(
                '邮 箱',
                style: TextStyle(color: ThemeUtil.foregroundColor),
              ),
            ),
            Text(
              widget.contactEmail,
              style: const TextStyle(color: ThemeUtil.foregroundColor),
            )
          ],
        ),
      ),
      widget.contactRemark != null ?
      Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Wrap(
          children: [
            const SizedBox(
              width: FIELD_NAME_WIDTH,
              child: Text(
                '备 注',
                style: TextStyle(color: ThemeUtil.foregroundColor),
              ),
            ),
            Text(
              widget.contactRemark,
              style: const TextStyle(color: ThemeUtil.foregroundColor),
            )
          ],
        ),
      ) : const SizedBox(),
      const Divider()
    ]);
  }

  Widget getActionWidget(){
    /*OrderScenic order = widget.order;
    OrderScenicStatus? status;
    if(order.orderStatus != null){
      status = OrderScenicStatusExt.getStatus(order.orderStatus!);
    }
    if(status == null){
      return const SizedBox();
    }*/
    //if(status == OrderScenicStatus.unpaid){
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
                onPressed: (){

                },
                child: const Text('取消', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
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
                onPressed: (){

                },
                child: const Text('支 付', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),),
              ),
            )
          ],
        ),
      );
    }
    //return const SizedBox();
  //}
}
