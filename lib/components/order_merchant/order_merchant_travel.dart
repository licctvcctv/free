import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/chat_notification/chat_notification_storage.dart';
import 'package:freego_flutter/components/hotel_neo/hotel_common.dart';
import 'package:freego_flutter/components/order_merchant/order_merchant_api.dart';
import 'package:freego_flutter/components/order_merchant/order_status_util.dart';
import 'package:freego_flutter/components/order_neo/order_common.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:intl/intl.dart';

class OrderMerchantTravelPage extends StatelessWidget {
  final int? nid;
  final OrderTravel order;
  const OrderMerchantTravelPage({this.nid, required this.order, super.key});

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
      body: OrderMerchantTravelWidget(nid: nid, order: order,),
    );
  }
}

class OrderMerchantTravelWidget extends StatefulWidget {
  final int? nid;
  final OrderTravel order;
  const OrderMerchantTravelWidget({this.nid, required this.order, super.key});

  @override
  State<StatefulWidget> createState() {
    return OrderMerchantTravelState();
  }
}

class OrderMerchantTravelState extends State<OrderMerchantTravelWidget> {
  static const double FIELD_NAME_WIDTH = 100;

  Widget svgTravel = SvgPicture.asset(
    'svg/icon_travel.svg',
    color: ThemeUtil.foregroundColor,
  );

  @override
  Widget build(BuildContext context) {
    OrderTravel? order = widget.order;
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
                                  child: svgTravel,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                InkWell(
                                  onTap: () async {
                                    int? travelId = order.travelId;
                                    if (travelId == null) {
                                      return;
                                    }
                                    DateTime startDate = DateTime.now();
                                    startDate = DateTime(startDate.year, startDate.month, startDate.day);
                                    DateTime endDate = startDate.add(const Duration(days: 1));
                                  },
                                  child: Text(
                                    '${order.travelName}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: ThemeUtil.foregroundColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18
                                    ),
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
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  '￥${StringUtil.getPriceStr(order.amount)}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: ThemeUtil.foregroundColor,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
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
                                style: TextStyle(color: ThemeUtil.foregroundColor),
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
                                style: TextStyle(color: ThemeUtil.foregroundColor),
                              ),
                            ),
                            order.createTime != null ? 
                            Text(
                              DateFormat('yyyy-MM-dd HH:mm:ss').format(order.createTime!),
                              style: const TextStyle(
                                color: ThemeUtil.foregroundColor
                              ),
                            ): const SizedBox()
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
                                style: TextStyle(color: ThemeUtil.foregroundColor),
                              ),
                            ),
                            order.dayNum != null ? 
                            Text(
                              '共${order.dayNum}天',
                              style: const TextStyle(
                                color: ThemeUtil.foregroundColor
                              ),
                            ) : const SizedBox(),
                            order.nightNum != null ? 
                            Text(
                              '${order.nightNum!}晚',
                              style: const TextStyle(
                                color: ThemeUtil.foregroundColor
                              ),
                            ): const SizedBox()
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
                                style: TextStyle(color: ThemeUtil.foregroundColor),
                              ),
                            ),
                            Text(
                              '${order.destProvince ?? ''}${order.destCity ?? ''}${order.rendezvousLocation ?? ''}',
                              style: const TextStyle(
                                color: ThemeUtil.foregroundColor
                              ),
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
                                style: TextStyle(color: ThemeUtil.foregroundColor),
                              ),
                            ),
                            Text(
                              order.rendezvousTime ?? '',
                              style: const TextStyle(color: ThemeUtil.foregroundColor),
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
                                style: TextStyle(color: ThemeUtil.foregroundColor),
                              ),
                            ),
                            Text(
                              order.contactName ?? '',
                              style: const TextStyle(color: ThemeUtil.foregroundColor),
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
                                style: TextStyle(color: ThemeUtil.foregroundColor),
                              ),
                            ),
                            Text(
                              order.contactPhone ?? '',
                              style: const TextStyle(color: ThemeUtil.foregroundColor),
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
                                style: TextStyle(color: ThemeUtil.foregroundColor),
                              ),
                            ),
                            Text(
                              order.emergencyName ?? '',
                              style: const TextStyle(color: ThemeUtil.foregroundColor),
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
                                style: TextStyle(color: ThemeUtil.foregroundColor),
                              ),
                            ),
                            Text(
                              order.emergencyPhone ?? '',
                              style: const TextStyle(color: ThemeUtil.foregroundColor),
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
                                '备注',
                                style: TextStyle(color: ThemeUtil.foregroundColor),
                              ),
                            ),
                            Text(
                              order.remark ?? '',
                              style: const TextStyle(color: ThemeUtil.foregroundColor),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      getPayStatusWidget(),
                      const Divider(),
                      getGuestListWidget(),
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

  Widget getBookNumWidet() {
    int orderNum = (widget.order.number ?? 0) +
        (widget.order.childNumber ?? 0) +
        (widget.order.oldNumber ?? 0);
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
    OrderTravel travel = widget.order;
    List<Widget> dateWidgets = [];
    // 出发日期
    if (travel.startDate != null) {
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
                DateFormat('yyyy年MM月dd日').format(travel.startDate!),
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
    if (travel.endDate != null) {
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
                DateFormat('yyyy年MM月dd日').format(travel.endDate!),
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

  Widget getActionWidget() {
    //return const SizedBox();
    OrderTravel order = widget.order;
    OrderTravelStatus? status;
    if(order.orderStatus != null){
      status = OrderTravelStatusExt.getStatus(order.orderStatus!);
    }
    bool showConfirm = false;
    bool showReject = false;
    if(status == OrderTravelStatus.unconfirmed){
      showConfirm = true;
      showReject = true;
    }
    if (showConfirm || showReject) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if(showReject)
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
                    order.orderStatus = OrderTravelStatus.confirmFail.getNum();
                    if(mounted && context.mounted){
                      setState(() {
                      });
                    }
                    if(widget.nid != null){
                      ChatNotificationStorage.updateOrderTravelStatus(widget.nid!, OrderTravelStatus.confirmFail);
                      OrderStatusUtil().setOrderTravelStatus(widget.nid!, OrderTravelStatus.confirmFail.getNum());
                    }
                  }
                },
                child: const Text(
                  '拒 绝',
                  style: TextStyle(
                    color: ThemeUtil.foregroundColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                  ),
                ),
              ),
            ),
            if(showConfirm)
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
                onPressed: () async {
                  if(order.orderSerial == null){
                    ToastUtil.error('订单出错');
                    return;
                  }
                  bool result = await OrderMerchantHttp().confirmOrder(orderSerial: order.orderSerial!, fail: (response){
                    ToastUtil.error(response.data['message']);
                  });
                  if(result){
                    order.orderStatus = OrderTravelStatus.confirmed.getNum();
                    if(mounted && context.mounted){
                      setState(() {
                      });
                    }
                    if(widget.nid != null){
                      ChatNotificationStorage.updateOrderTravelStatus(widget.nid!, OrderTravelStatus.confirmed);
                      OrderStatusUtil().setOrderTravelStatus(widget.nid!, OrderTravelStatus.confirmed.getNum());
                    }
                  }
                },
                child: const Text(
                  '确 认',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                  ),
                ),
              ),
            )
          ],
        ),
      );
    }
    return const SizedBox();
  }

  Widget getCancelRuleTypeText() {
    OrderTravel order = widget.order;
    if (order.cancelRuleType == null) {
      return const SizedBox();
    }

    OrderTravelCancelRuleType? status = OrderTravelCancelRuleTypeExt.getStatus(order.cancelRuleType!);
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
    OrderTravel order = widget.order;
    OrderTravelStatus? status;
    if(order.orderStatus != null){
      status = OrderTravelStatusExt.getStatus(order.orderStatus!);
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
                  '订单状态',
                  style: TextStyle(color: ThemeUtil.foregroundColor),
                ),
              ),
              Text(
                MyOrderTravelStatusExt(status)?.getText() ?? '',
                style: TextStyle(color: status?.getColor()),
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
        ): const SizedBox()
      ],
    );
  }

  Widget getGuestListWidget(){
    OrderTravel order = widget.order;
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
            guest.name != null ?
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
            ) : const SizedBox(),
            guest.phone != null ?
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
            ) : const SizedBox(),
            cardType != null ?
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
            ) : const SizedBox(),
            guest.cardNo != null ?
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
            ) : const SizedBox(),
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

  Widget getContactWidget() {
    OrderTravel order = widget.order;
    if (order.contactPhone == null &&
        order.contactName == null &&
        order.contactEmail == null) {
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
                child: Text(
                  '联系姓名',
                  style: TextStyle(color: ThemeUtil.foregroundColor),
                ),
              ),
              Text(
                order.contactName!,
                style: const TextStyle(color: ThemeUtil.foregroundColor),
              )
            ]
          ),
        ): const SizedBox(),
        order.contactPhone != null ? 
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            children: [
              const SizedBox(
                width: FIELD_NAME_WIDTH,
                child: Text(
                  '联系手机',
                  style: TextStyle(color: ThemeUtil.foregroundColor),
                ),
              ),
              Text(
                order.contactPhone!,
                style: const TextStyle(color: ThemeUtil.foregroundColor),
              )
            ],
          ),
        ): const SizedBox(),
        order.contactEmail != null ? 
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            children: [
              const SizedBox(
                width: FIELD_NAME_WIDTH,
                child: Text(
                  '联系邮箱',
                  style: TextStyle(color: ThemeUtil.foregroundColor),
                ),
              ),
              Text(
                order.contactEmail!,
                style: const TextStyle(color: ThemeUtil.foregroundColor),
              )
            ],
          ),
        ): const SizedBox(),
        const Divider()
      ],
    );
  }

  Widget getCancelRuleWidget() {
    OrderTravel order = widget.order;
    if (order.cancelRuleType == null) {
      return const SizedBox();
    }
    CancelRuleType? cancelRuleType =
        CancelRuleTypeExt.getType(order.cancelRuleType!);
    if (cancelRuleType == null) {
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
                child: Text(
                  '取消政策',
                  style: TextStyle(color: ThemeUtil.foregroundColor),
                ),
              ),
              cancelRuleType == CancelRuleType.unable ? 
              const Text(
                '无法取消',
                style: TextStyle(color: ThemeUtil.foregroundColor),
              ) : 
              cancelRuleType == CancelRuleType.inTime ? 
              const Text(
                '限时免费取消',
                style: TextStyle(color: ThemeUtil.foregroundColor),
              ) : 
              cancelRuleType == CancelRuleType.charged ? 
              const Text(
                '收费取消',
                style: TextStyle(color: ThemeUtil.foregroundColor),
              ) : const SizedBox()
            ],
          ),
          order.cancelRuleDesc != null ? 
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              order.cancelRuleDesc!,
              style: const TextStyle(color: ThemeUtil.foregroundColor),
            ),
          ): const SizedBox(),
          order.cancelLatestTime != null ? 
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                const Text(
                  '免费取消时间',
                  style: TextStyle(color: ThemeUtil.foregroundColor),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  DateFormat('yyyy-MM-dd HH:mm').format(order.cancelLatestTime!),
                  style: const TextStyle(color: ThemeUtil.foregroundColor),
                ),
              ],
            )
          ): const SizedBox(),
          const Divider()
        ],
      ),
    );
  }
}

extension MyOrderTravelStatusExt on OrderTravelStatus{

  String getText(){
    switch(this){
      case OrderTravelStatus.unpaid:
        return '未支付';
      case OrderTravelStatus.unconfirmed:
        return '新的订单';
      case OrderTravelStatus.confirmFail:
        return '确认失败';
      case OrderTravelStatus.confirmed:
        return '已确认';
      case OrderTravelStatus.servicing:
        return '服务中';
      case OrderTravelStatus.completed:
        return '已完成';
      case OrderTravelStatus.canceling:
        return '取消中';
      case OrderTravelStatus.cancelFail:
        return '取消失败';
      case OrderTravelStatus.canceled:
        return '已取消';
      case OrderTravelStatus.refunding:
        return '退款中';
      case OrderTravelStatus.refundFail:
        return '退款失败';
      case OrderTravelStatus.refunded:
        return '已退款';
      case OrderTravelStatus.error:
        return '订单出错';
    }
  }

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