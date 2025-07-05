
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/hotel_neo/api/hotel_api.dart';
import 'package:freego_flutter/components/hotel_neo/hotel_common.dart';
import 'package:freego_flutter/components/hotel_neo/hotel_home_freego.dart';
import 'package:freego_flutter/components/order_neo/api/order_neo_api.dart';
import 'package:freego_flutter/components/order_neo/order_common.dart';
import 'package:freego_flutter/components/order_neo/order_hotel_detail.dart';
import 'package:freego_flutter/components/order_neo/order_restaurant_detail.dart';
import 'package:freego_flutter/components/order_neo/order_scenic_detail.dart';
import 'package:freego_flutter/components/order_neo/order_travel_detail.dart';
import 'package:freego_flutter/components/restaurant/restaurant_common.dart';
import 'package:freego_flutter/components/restaurant/restaurant_home.dart';
import 'package:freego_flutter/components/restaurant/restaurant_api.dart';
import 'package:freego_flutter/components/scenic/api/scenic_api.dart';
import 'package:freego_flutter/components/scenic/scenic_common.dart';
import 'package:freego_flutter/components/scenic/scenic_home_freego.dart';
import 'package:freego_flutter/components/travel/travel_common.dart';
import 'package:freego_flutter/components/travel/travel_detail.dart';
import 'package:freego_flutter/components/travel/travel_api.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/custom_indicator.dart';
import 'package:freego_flutter/components/view/date_choose_view.dart';
import 'package:freego_flutter/components/view/notify_empty.dart';
import 'package:freego_flutter/components/view/notify_loading.dart';
import 'package:freego_flutter/util/date_choose_util.dart';
import 'package:freego_flutter/util/date_time_util.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:intl/intl.dart';

class OrderHomePage extends StatelessWidget{
  const OrderHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeUtil.backgroundColor,
        elevation: 0,
        toolbarHeight: 10,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      resizeToAvoidBottomInset: false,
      body: const OrderHomeWidget(),
    );
  }
  
}

class OrderHomeWidget extends StatefulWidget{
  const OrderHomeWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return OrderHomeState();
  }

}

class OrderHomeState extends State<OrderHomeWidget> with SingleTickerProviderStateMixin{

  static const int DATE_ANIM_MILLI_SECONDS = 350;

  late DateTime startDate;
  late DateTime endDate;
  DateTime today = DateTime.now();
  late AnimationController dateChooseAnim;
  bool showDateChooseWill = false;
  bool showDateChoose = false;
  GlobalKey dateChooseKey = GlobalKey();
  double dateChooseWidth = double.infinity;
  bool dateChooseOffstate = true;

  List<OrderNeo> orderList = [];
  List<Widget> contetns = [];
  List<Widget> topBuffers = [];
  List<Widget> bottomBuffers = [];

  bool inited = false;

  @override
  void initState(){
    super.initState();
    today = DateTime(today.year, today.month, today.day, 23, 59, 59, 999, 999);
    endDate = today.copyWith();
    startDate = endDate.subtract(const Duration(days: 7));
    startDate = DateTime(startDate.year, startDate.month, startDate.day);

    dateChooseAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: DATE_ANIM_MILLI_SECONDS));
    dateChooseAnim.value = 1;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) { 
      RenderBox? box = dateChooseKey.currentContext?.findAncestorRenderObjectOfType() as RenderBox?;
      if(box != null){
        dateChooseWidth = box.size.width;
      }
      dateChooseOffstate = false;
      dateChooseAnim.value = 0;
    });

    Future.delayed(Duration.zero, () async{
      await search();
      inited = true;
      if(mounted && context.mounted){
        setState(() {
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeUtil.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonHeader(
            center: Text('订单', style: TextStyle(color: Colors.white, fontSize: 18),),
          ),
          getDateChooseWidget(),
          !inited ?
          const Expanded(
            child: NotifyLoadingWidget(),
          ):
          orderList.isEmpty ?
          const NotifyEmptyWidget() :
          Expanded(
            child: AnimatedCustomIndicatorWidget(
              contents: contetns,
              topBuffer: topBuffers,
              bottomBuffer: bottomBuffers,
              touchTop: search,
              touchBottom: getHistory,
            ),
          )
        ],
      ),
    );
  }

  Widget getDateChooseWidget(){
    return Offstage(
      offstage: dateChooseOffstate,
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Row(
          children: [
            InkWell(
              onTap: (){
                if(!showDateChooseWill){
                  showDateChooseWill = true;
                  dateChooseAnim.forward().then((value){
                    showDateChoose = true;
                    if(mounted && context.mounted){
                      setState(() {
                      });
                    }
                  });
                }
                else{
                  showDateChooseWill = false;
                  dateChooseAnim.reverse().then((value){
                    showDateChoose = false;
                    if(mounted && context.mounted){
                      setState(() {
                      });
                    }
                  });
                }
              },
              child: showDateChoose ?
              const Icon(Icons.calendar_month_rounded, color: ThemeUtil.foregroundColor, size: 32,) :
              const Icon(Icons.calendar_month_outlined, color: ThemeUtil.foregroundColor, size: 32,)
            ),
            const SizedBox(width: 8,),
            AnimatedBuilder(
              animation: dateChooseAnim, 
              builder:(context, child) {
                Widget content = Row(
                  key: dateChooseKey,
                  children: [
                    InkWell(
                      onTap: () async{
                        final config = DateChooseConfig(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.width,
                          lastDate: today,
                          initDateList: [startDate, endDate],
                          chooseMode: DateChooseMode.range
                        );
                        List<DateTime>? results = await DateChooseUtil.chooseDate(context, config);
                        if(results != null && results.length > 1){
                          startDate = results.first;
                          endDate = results[1];
                          endDate = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999, 999);
                          if(mounted && context.mounted){
                            setState(() {
                            });
                            search();
                          }
                        }
                      },
                      child: Text(DateFormat('yyyy-MM-dd').format(startDate), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.underline),),
                    ),
                    const SizedBox(width: 4,),
                    Text(DateTimeUtil.getWeekDayCn(startDate), style: const TextStyle(color: Colors.grey),),
                    const Text(' 至 ', style: TextStyle(color: Colors.grey),),
                    InkWell(
                      onTap: () async{
                        final config = DateChooseConfig(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.width,
                          lastDate: today,
                          initDateList: [startDate, endDate],
                          chooseMode: DateChooseMode.range
                        );
                        List<DateTime>? results = await DateChooseUtil.chooseDate(context, config);
                        if(results != null && results.length > 1){
                          startDate = results.first;
                          endDate = results[1];
                          endDate = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999, 999);
                          if(mounted && context.mounted){
                            setState(() {
                            });
                            search();
                          }
                        }
                      },
                      child: Text(DateFormat('yyyy-MM-dd').format(endDate), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.underline),),
                    ),
                    const SizedBox(width: 4,),
                    Text(DateTimeUtil.getWeekDayCn(endDate), style: const TextStyle(color: Colors.grey),), 
                    const SizedBox(width: 4,)
                  ],
                );
                return Stack(
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: dateChooseAnim.value * dateChooseWidth
                      ),
                      child: Wrap(
                        direction: Axis.vertical,
                        clipBehavior: Clip.hardEdge,
                        children: [
                          content
                        ],
                      ),
                    )
                  ],
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Future search() async{
    List<OrderNeo>? list = await OrderNeoApi().listHistoryOrder(startTime: startDate, endTime: endDate);
    if(list != null){
      orderList = list;
      contetns = [];
      bottomBuffers = [];
      topBuffers = getOrderNeoWidgets(orderList);
      if(mounted && context.mounted){
        setState(() {
        });
      }
    }
    else{
      ToastUtil.error('好像出了点小问题');
    }
  }

  Future getHistory() async{
    int? maxId;
    if(orderList.isNotEmpty){
      maxId = orderList.last.id;
    }
    List<OrderNeo>? list = await OrderNeoApi().listHistoryOrder(startTime: startDate, endTime: endDate, maxId: maxId);
    if(list != null){
      if(list.isEmpty){
        if(inited){
          ToastUtil.hint('已经没有了呢');
        }
        return;
      }
      bottomBuffers = getOrderNeoWidgets(list);
      orderList.addAll(list);
      if(mounted && context.mounted){
        setState(() {
        });
      }
    }
  }

  List<Widget> getOrderNeoWidgets(List<OrderNeo> orderList){
    List<Widget> widgets = [];
    for(OrderNeo order in orderList){
      if(order is OrderHotel){
        widgets.add(
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: OrderHotelBlock(order),
          )
        );
      }
      else if(order is OrderScenic){
        widgets.add(
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: OrderScenicBlock(order),
          )
        );
      }
      else if(order is OrderRestaurant){
        widgets.add(
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: OrderRestaurantBlock(order),
          )
        );
      }
      else if(order is OrderTravel){
        widgets.add(
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: OrderTravelBlock(order),
          )
        );
      }


    }
    return widgets;
  }
}

class OrderHotelBlock extends StatefulWidget{
  final OrderHotel order;
  const OrderHotelBlock(this.order, {super.key});

  @override
  State<StatefulWidget> createState() {
    return OrderHotelState();
  }

}

class OrderHotelState extends State<OrderHotelBlock>{
  @override
  Widget build(BuildContext context) {
    OrderHotel order = widget.order;
    OrderHotelStatus? status;
    if(order.orderStatus != null){
      status = OrderHotelStatusExt.getStatus(order.orderStatus!);
    }
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16))
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Transform.translate(
              offset: const Offset(100, 0),
              child: Transform.rotate(
                angle: math.pi / 5,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(128, 8, 100, 8),
                  decoration: BoxDecoration(
                    color: status?.getColor() ?? Colors.redAccent,
                    borderRadius: const BorderRadius.all(Radius.circular(10))
                  ),
                  alignment: Alignment.topCenter,
                  child: Text(status?.getText() ?? '订单出错', style: const TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () async{
                    int? hotelId = order.hotelId;
                    if(hotelId == null){
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
                  child: Text(order.hotelName ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
                ),
                const SizedBox(height: 10,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: (MediaQuery.of(context).size.width - 64) * 0.6,
                      ),
                      child: Text(order.planName ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor),),
                    ),
                    const SizedBox(width: 10,),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: (MediaQuery.of(context).size.width - 64) * 0.4 - 10,
                      ),
                      child: Text('${order.numberOfRooms}间', style: const TextStyle(color: ThemeUtil.foregroundColor),),
                    )
                  ],
                ),
                const SizedBox(height: 10,),
                Row(
                  children: [
                    order.checkInDate != null ?
                    Text(DateFormat('yyyy-MM-dd').format(order.checkInDate!), style: const TextStyle(color: ThemeUtil.foregroundColor, decoration: TextDecoration.underline),) :
                    const SizedBox(),
                    const Text(' - ', style: TextStyle(color: ThemeUtil.foregroundColor),),
                    order.checkOutDate != null ?
                    Text(DateFormat('yyyy-MM-dd').format(order.checkOutDate!), style: const TextStyle(color: ThemeUtil.foregroundColor, decoration: TextDecoration.underline),) :
                    const SizedBox(),
                    const SizedBox(width: 10,),
                    Text('共${order.numberOfNights}晚', style: const TextStyle(color: ThemeUtil.foregroundColor),)
                  ],
                ),
                const SizedBox(height: 10,),
                Text('详细地址：${order.hotelAddress}', style: const TextStyle(color: Colors.grey),),
                order.cancelLatestTime != null ?
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text('在${DateFormat('yyyy-MM-dd HH:mm').format(order.cancelLatestTime!)}前可免费取消', style: const TextStyle(color: Colors.grey),)
                ) : const SizedBox(),
                const SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('￥${StringUtil.getPriceStr(order.amount)}', style: const TextStyle(color: Colors.redAccent),),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap
                      ),
                      onPressed: () async{
                        if(order.id == null){
                          return;
                        }
                        OrderHotel? orderHotel = await OrderNeoApi().getOrderHotel(id: order.id!);
                        if(orderHotel == null){
                          return;
                        }
                        if(mounted && context.mounted){
                          dynamic result = await Navigator.of(context).push(MaterialPageRoute(builder: (context){
                            return OrderHotelDetailPage(orderHotel);
                          }));
                          if(result is OrderHotel){
                            order.payStatus = result.payStatus;
                            order.orderStatus = result.orderStatus;
                            resetState();
                          }
                        }
                      }, 
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          border: Border.fromBorderSide(BorderSide(color: Colors.grey))
                        ),
                        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                        child: const Text('详情>>'),
                      )
                    )
                  ],
                )
              ],
            ),
          )
        ],
      )
    );
  }

  void resetState(){
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }

}

class OrderScenicBlock extends StatefulWidget{
  final OrderScenic order;
  const OrderScenicBlock(this.order, {super.key});

  @override
  State<StatefulWidget> createState() {
    return OrderScenicState();
  }

}

class OrderScenicState extends State<OrderScenicBlock>{
  @override
  Widget build(BuildContext context) {
    OrderScenic order = widget.order;
    OrderScenicStatus? status;
    if(order.orderStatus != null){
      status = OrderScenicStatusExt.getStatus(order.orderStatus!);
    }
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Transform.translate(
              offset: const Offset(100, 0),
              child: Transform.rotate(
                angle: math.pi / 5,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(128, 8, 100, 8),
                  decoration: BoxDecoration(
                    color: status?.getColor() ?? Colors.redAccent,
                    borderRadius: const BorderRadius.all(Radius.circular(10))
                  ),
                  alignment: Alignment.topCenter,
                  child: Text(status?.getText() ?? '订单出错', style: const TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () async{
                    OrderScenic order = widget.order;
                    if(order.scenicId == null){
                      return;
                    }
                    Scenic? scenic = await ScenicApi().detail(id: order.scenicId, outerId: order.outerScenicId, source: order.source);
                    if(scenic != null){
                      if(mounted && context.mounted){
                        Navigator.of(context).push(MaterialPageRoute(builder: (context){
                          return ScenicHomePage(scenic);
                        }));
                      }
                    }
                  },
                  child: Text(order.scenicName ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
                ),
                const SizedBox(height: 10,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: (MediaQuery.of(context).size.width - 64) * 0.6,
                      ),
                      child: Text(order.ticketName ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor),),
                    ),
                    const SizedBox(width: 10,),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: (MediaQuery.of(context).size.width - 64) * 0.4 - 10,
                      ),
                      child: Text('${order.quantity}张', style: const TextStyle(color: ThemeUtil.foregroundColor),),
                    ),
                  ],
                ),
                order.drawAddress != null ?
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text('取票地址：${order.drawAddress!}', style: const TextStyle(color: Colors.grey),),
                ) : const SizedBox(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('￥${StringUtil.getPriceStr(order.amount)}', style: const TextStyle(color: Colors.redAccent),),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap
                      ),
                      onPressed: () async{
                        if(order.id == null){
                          return;
                        }
                        OrderScenic? orderScenic = await OrderNeoApi().getOrderScenic(id: order.id!);
                        if(orderScenic == null){
                          return;
                        }
                        if(mounted && context.mounted){
                          dynamic result = await Navigator.of(context).push(MaterialPageRoute(builder: (context){
                            return OrderScenicDetailPage(orderScenic);
                          }));
                          if(result is OrderScenic){
                            order.payStatus = result.payStatus;
                            order.orderStatus = result.orderStatus;
                          }
                          resetState();
                        }
                      }, 
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          border: Border.fromBorderSide(BorderSide(color: Colors.grey))
                        ),
                        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                        child: const Text('详情>>'),
                      )
                    )
                  ],
                )
              ],
            ),
          )
        ],
      )
    );
  }

  void resetState(){
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }
}

class OrderRestaurantBlock extends StatefulWidget{
  final OrderRestaurant order;
  const OrderRestaurantBlock(this.order, {super.key});

  @override
  State<StatefulWidget> createState() {
    return OrderRestaurantState();
  }
}

class OrderRestaurantState extends State<OrderRestaurantBlock> {
  @override
  Widget build(BuildContext context) {
    OrderRestaurant order = widget.order;
    OrderRestaurantStatus? orderStatus;
    if(order.orderStatus != null){
      orderStatus = OrderRestaurantStatusExt.getStatus(order.orderStatus!);
    }
    return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: Transform.translate(
                offset: const Offset(100, 0),
                child: Transform.rotate(
                  angle: math.pi / 5,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(128, 8, 100, 8),
                    decoration: BoxDecoration(
                      color: orderStatus?.getColor(),
                      borderRadius: const BorderRadius.all(Radius.circular(10))
                    ),
                    alignment: Alignment.topCenter,
                    child: Text(
                      orderStatus?.getText() ?? '',
                      style:const TextStyle(color: Colors.white, fontSize: 18)
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () async {
                      OrderRestaurant order = widget.order;
                      if (order.restaurantId == null) {
                        return;
                      }
                      Restaurant? restaurant = await RestaurantApi().getById(order.restaurantId!);
                      if (restaurant != null) {
                        if (mounted && context.mounted) {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                            return RestaurantHomePage(restaurant);
                          }));
                        }
                      }
                    },
                    child: Text(
                      order.restaurantName ?? '',
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: (MediaQuery.of(context).size.width - 64) * 0.6,
                        ),
                        child: Text(
                          getDiningMethodsText(),
                          style: const TextStyle(color: ThemeUtil.foregroundColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(children: [
                    order.arrivalDate != null
                      ? Column(
                        children: [
                          Text(
                            order.diningMethods == DiningType.inStore.getNum() ? 
                            '预订用餐时间：${DateFormat('yyyy-MM-dd HH:mm').format(order.arrivalDate!)}' : 
                            (order.diningMethods == DiningType.packed.getNum() ? 
                            '预订取餐时间：${DateFormat('yyyy-MM-dd HH:mm').format(order.arrivalDate!)}' : 
                            ''), // 如果值不是1或2，显示空字符串
                            style: const TextStyle(color: ThemeUtil.foregroundColor),
                          ),
                        ],
                      )
                      : const SizedBox(),
                    ]
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    '详细地址：${order.restaurantAddress}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '￥${StringUtil.getPriceStr(order.amount)}',
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap
                        ),
                        onPressed: () async {
                          if(order.id == null){
                            return;
                          }
                          OrderRestaurant? orderRestaurant = await OrderNeoApi().getOrderRestaurant(id: order.id!);
                          if(orderRestaurant == null){
                            return;
                          }
                          if(mounted && context.mounted){
                            dynamic result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                              return OrderRestaurantDetailPage(orderRestaurant);
                            }));
                            if(result is OrderRestaurant){
                              order.payStatus = result.payStatus;
                              order.orderStatus = result.orderStatus;
                            }
                          }
                          if(mounted && context.mounted){
                            setState(() {
                            });
                          }
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            border: Border.fromBorderSide(BorderSide(color: Colors.grey))
                          ),
                          padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                          child: const Text('详情>>'),
                        )
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ));
  }

  String getDiningMethodsText() {
    OrderRestaurant order = widget.order;
    if (order.diningMethods == null) {
      return '订单出错';
    }
    OrderRestaurantDining? status =
        OrderRestaurantDiningExt.getStatus(order.diningMethods!);
    if (status == null) {
      return '订单出错';
    }
    switch (status) {
      case OrderRestaurantDining.dineIn:
        return '在店用餐';
      case OrderRestaurantDining.takeOut:
        return '打包带走';
      case OrderRestaurantDining.unconfirmed:
        return '未确认';
      default:
        return '订单出错';
    }
  }

}

class OrderTravelBlock extends StatefulWidget{
  final OrderTravel order;
  const OrderTravelBlock(this.order, {super.key});

  @override
  State<StatefulWidget> createState() {
    return OrderTravelState();
  }
}

class OrderTravelState extends State<OrderTravelBlock> {
  @override
  Widget build(BuildContext context) {
    OrderTravel order = widget.order;
    OrderTravelStatus? orderStatus;
    if(order.orderStatus != null){
      orderStatus = OrderTravelStatusExt.getStatus(order.orderStatus!);
    }
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Transform.translate(
              offset: const Offset(100, 0),
              child: Transform.rotate(
                angle: math.pi / 5,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(128, 8, 100, 8),
                  decoration: BoxDecoration(
                    color: orderStatus?.getColor() ?? Colors.redAccent,
                    borderRadius: const BorderRadius.all(Radius.circular(10))
                  ),
                  alignment: Alignment.topCenter,
                  child: Text(
                    orderStatus?.getText() ?? '订单出错',
                    style: const TextStyle(color: Colors.white, fontSize: 18)
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () async {
                    OrderTravel order = widget.order;
                    if (order.travelId == null) {
                      return;
                    }
                    Travel? travel = await TravelApi().getById(travelId: order.travelId!);
                    if (travel != null) {
                      if (mounted && context.mounted) {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                          return TravelDetailPage(travel);
                        }));
                      }
                    }
                  },
                  child: Text(
                    order.travelName ?? '',
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: (MediaQuery.of(context).size.width - 64) * 0.6,
                      ),
                      child: Text(
                        order.travelSuitName!,
                        style: const TextStyle(color: ThemeUtil.foregroundColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    order.startDate != null ?
                    Text(DateFormat('yyyy-MM-dd').format(order.startDate!), style: const TextStyle(color: ThemeUtil.foregroundColor, decoration: TextDecoration.underline),) :
                    const SizedBox(),
                    const Text(' - ', style: TextStyle(color: ThemeUtil.foregroundColor),),
                    order.endDate != null ?
                    Text(DateFormat('yyyy-MM-dd').format(order.endDate!), style: const TextStyle(color: ThemeUtil.foregroundColor, decoration: TextDecoration.underline),) :
                    const SizedBox(),
                    const SizedBox(width: 10,),
                    Text('共${order.dayNum}天${order.nightNum!}晚', style: const TextStyle(color: ThemeUtil.foregroundColor),)
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  '集合地：${order.destProvince??''}${order.destCity??''}${order.rendezvousLocation??''}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(
                  height: 10,
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '￥${StringUtil.getPriceStr(order.amount)}',
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap
                      ),
                      onPressed: () async {
                        if(order.id == null){
                          return;
                        }
                        OrderTravel? orderTravel = await OrderNeoApi().getOrderTravel(id: order.id!);
                        if(orderTravel == null){
                          return;
                        }
                        if(mounted && context.mounted){
                          dynamic result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                            return OrderTravelDetailPage(order);
                          }));
                          if(result is OrderTravel){
                            order.payStatus = result.payStatus;
                            order.orderStatus = result.orderStatus;
                          }
                        }
                        if(mounted && context.mounted){
                          setState(() {
                          });
                        }
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          border: Border.fromBorderSide(BorderSide(color: Colors.grey))
                        ),
                        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                        child: const Text('详情>>'),
                      )
                    )
                  ],
                )
              ],
            ),
          )
        ],
      )
    );
  }

  String getCancelRuleTypeText() {
    OrderTravel order = widget.order;
    int? cancelRuleType = order.cancelRuleType;

    if (cancelRuleType == null) {
      return '订单出错';
    }

    OrderTravelCancelRuleType? status =
      OrderTravelCancelRuleTypeExt.getStatus(cancelRuleType);

    if (status == null) {
      return '订单出错';
    }

    switch (status) {
      case OrderTravelCancelRuleType.cancelledNot:
        return '不可取消';
      case OrderTravelCancelRuleType.cancelled:
        return '可取消';
      case OrderTravelCancelRuleType.error:
        return '订单出错';
      default:
        return '订单出错';
    }
  }

}
