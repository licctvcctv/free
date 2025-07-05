
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/hotel_neo/hotel_common.dart';
import 'package:freego_flutter/components/hotel_neo/hotel_home_freego.dart';
import 'package:freego_flutter/components/hotel_neo/api/local_hotel_api.dart';
import 'package:freego_flutter/components/order_merchant/order_merchant_api.dart';
import 'package:freego_flutter/components/order_neo/order_common.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:intl/intl.dart';

class OrderMerchantHotelPage extends StatelessWidget{
  final int? nid;
  final OrderHotel order;
  const OrderMerchantHotelPage({this.nid, required this.order, super.key});

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
      body: OrderMerchantHotelWidget(nid: nid, order: order,),
    );
  }
  
}

class OrderMerchantHotelWidget extends StatefulWidget{
  final int? nid;
  final OrderHotel order;
  const OrderMerchantHotelWidget({this.nid, required this.order, super.key});

  @override
  State<StatefulWidget> createState() {
    return OrderMerchantHotelState();
  }

}

class OrderMerchantHotelState extends State<OrderMerchantHotelWidget>{

  static const double FIELD_NAME_WIDTH = 100;

  Widget svgHotel = SvgPicture.asset('svg/icon_hotel.svg', color: ThemeUtil.foregroundColor,);

  @override
  Widget build(BuildContext context) {
    OrderHotel? order = widget.order;
    return Container(
      color: ThemeUtil.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonHeader(
            center: Text('订单详情', style: TextStyle(color: Colors.white, fontSize: 18),),
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
                                  child: svgHotel,
                                ),
                                const SizedBox(height: 10,),
                                InkWell(
                                  onTap: () async{
                                    int? hotelId = order.hotelId;
                                    if(hotelId == null){
                                      return;
                                    }
                                    DateTime startDate = DateTime.now();
                                    startDate = DateTime(startDate.year, startDate.month, startDate.day);
                                    DateTime endDate = startDate.add(const Duration(days: 1));
                                    Hotel? hotel = await LocalHotelApi().detail(id: hotelId, startDate: startDate, endDate: endDate);
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
                                const SizedBox(height: 10,),
                                Text('￥${StringUtil.getPriceStr(order.amount)}', textAlign: TextAlign.center, style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold),),
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
                      if(order.orderStatus == OrderHotelStatus.unconfirmed.getNum() && order.confirmLimitTime != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Wrap(
                          children: [
                            const SizedBox(
                              width: FIELD_NAME_WIDTH,
                              child: Text('最晚确认时间', style: TextStyle(color: ThemeUtil.foregroundColor),),
                            ),
                            Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(order.confirmLimitTime!), style: const TextStyle(color: ThemeUtil.foregroundColor),)
                          ],
                        ),
                      ),
                      if(order.checkInDate != null)
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
                      ),
                      if(order.checkOutDate != null)
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
                      ),
                      if(order.numberOfNights != null)
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
                      ),
                      if(order.numberOfRooms != null)
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
                      ),
                      getDayPriceWidget(),
                      getCancelRuleWidget(),
                      getContactWidget(),
                      getPayStatusWidget(),
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

  Widget getActionWidget(){
    OrderHotel order = widget.order;
    if(order.orderStatus == null){
      return const SizedBox();
    }
    OrderHotelStatus? status = OrderHotelStatusExt.getStatus(order.orderStatus!);
    if(status == null){
      return const SizedBox();
    }
    if(status == OrderHotelStatus.unconfirmed){
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
            TextButton(
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
                  order.orderStatus = OrderHotelStatus.confirmFail.getNum();
                  if(mounted && context.mounted){
                    setState(() {
                    });
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border.fromBorderSide(BorderSide(color: ThemeUtil.foregroundColor)),
                  borderRadius: BorderRadius.all(Radius.circular(8))
                ),
                child: const Text('拒 绝', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
              ),
            ),
            TextButton(
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
                bool result = await OrderMerchantHttp().confirmOrder(orderSerial: order.orderSerial!, fail: (response){
                  ToastUtil.error(response.data['message']);
                });
                if(result){
                  order.orderStatus = OrderHotelStatus.confirmed.getNum();
                  if(mounted && context.mounted){
                    setState(() {
                    });
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                decoration: const BoxDecoration(
                  color: ThemeUtil.buttonColor,
                  borderRadius: BorderRadius.all(Radius.circular(8))
                ),
                child:  const Text('确 认', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),),
              ),
            )
          ],
        ),
      );
    }
    else if(status == OrderHotelStatus.confirmed){
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
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
                bool result = await OrderMerchantHttp().servicingOrder(orderSerail: order.orderSerial!);
                if(result){
                  order.orderStatus = OrderHotelStatus.servicing.getNum();
                  if(mounted && context.mounted){
                    setState(() {
                    });
                  }
                }
                else{
                  ToastUtil.error('开始服务失败');
                }
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                decoration: const BoxDecoration(
                  color: ThemeUtil.buttonColor,
                  borderRadius: BorderRadius.all(Radius.circular(8))
                ),
                child:  const Text('开始服务', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),),
              )
            )
          ],
        ),
      );
    }
    return const SizedBox();
  }

  Widget getPayStatusWidget(){
    OrderHotel order = widget.order;
    if(order.orderStatus == null){
      return const SizedBox();
    }
    OrderHotelStatus? status = OrderHotelStatusExt.getStatus(order.orderStatus!);
    if(status == null){
      return const SizedBox();
    }
    String? statusText;
    Color? statusColor;
    switch(status){
      case OrderHotelStatus.unpaid:
        statusText = '未支付';
        statusColor = Colors.lightGreen;
        break;
      case OrderHotelStatus.unconfirmed:
        statusText = '待确认';
        statusColor = Colors.lightBlue;
        break;
      case OrderHotelStatus.confirmed:
        statusText = '已确认';
        statusColor = Colors.lightBlue;
        break;
      case OrderHotelStatus.confirmFail:
        statusText = '确认失败';
        statusColor = Colors.redAccent;
        break;
      case OrderHotelStatus.servicing:
        statusText = '服务中';
        statusColor = Colors.lightBlue;
        break;
      case OrderHotelStatus.completed:
        statusText = '已完成';
        statusColor = const Color.fromRGBO(249, 168, 37, 1);
        break;
      case OrderHotelStatus.canceling:
        statusText = '取消中';
        statusColor = Colors.grey;
        break;
      case OrderHotelStatus.cancelFail:
        statusText = '取消失败';
        statusColor = Colors.grey;
        break;
      case OrderHotelStatus.canceled:
        statusText = '已取消';
        statusColor = Colors.grey;
        break;
      default:
    }
    if(statusText == null){
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
                child: Text('订单状态', style: TextStyle(color: ThemeUtil.foregroundColor),),
              ),
              Text(statusText, style: TextStyle(color: statusColor),)
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
                child: Text('失败原因', style: TextStyle(color: ThemeUtil.foregroundColor),),
              ),
              Text(order.unfinishedReason!, style: const TextStyle(color: ThemeUtil.foregroundColor),)
            ],
          ),
        ) : const SizedBox()
      ],
    );
  }

  Widget getContactWidget(){
    OrderHotel order = widget.order;
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
    OrderHotel order = widget.order;
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
    OrderHotel order = widget.order;
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
      int? price = int.tryParse(priceList[i]);
      if(price != null){
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                SizedBox(
                  width: FIELD_NAME_WIDTH,
                  child: Text(DateFormat('yyyy-MM-dd').format(date), style: const TextStyle(color: ThemeUtil.foregroundColor),),
                ),
                Text('￥${StringUtil.getPriceStr(price)} ', style: const TextStyle(color: ThemeUtil.foregroundColor),)
              ],
            ),
          )
        );
      }
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

  String getText(){
    switch(this){
      case OrderHotelStatus.unpaid:
        return '订单未支付';
      case OrderHotelStatus.unconfirmed:
        return '新的订单';
      case OrderHotelStatus.confirmed:
        return '确认成功';
      case OrderHotelStatus.confirmFail:
        return '确认失败';
      case OrderHotelStatus.completed:
        return '订单已完成';
      case OrderHotelStatus.canceling:
        return '订单取消中';
      case OrderHotelStatus.canceled:
        return '订单已取消';
      case OrderHotelStatus.cancelFail:
        return '订单取消失败';
      case OrderHotelStatus.servicing:
        return '服务中';
    }
  }

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