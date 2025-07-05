
import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/chat_neo/chat_common.dart';
import 'package:freego_flutter/components/chat_neo/chat_room.dart';
import 'package:freego_flutter/components/chat_neo/chat_socket.dart';
import 'package:freego_flutter/components/chat_neo/chat_util.dart';
import 'package:freego_flutter/components/chat_notification/chat_notification_common.dart';
import 'package:freego_flutter/components/chat_notification/chat_notification_storage.dart';
import 'package:freego_flutter/components/chat_notification/chat_notification_util.dart';
import 'package:freego_flutter/components/chat_notification/chat_notification_visitor.dart';
import 'package:freego_flutter/components/chat_notification_neo/model/im_notification_order_hotel_state_for_merchant.dart';
import 'package:freego_flutter/components/chat_notification_neo/model/im_notification_order_restaurant_for_merchant.dart';
import 'package:freego_flutter/components/chat_notification_neo/model/im_notification_order_scenic_state_for_merchant.dart';
import 'package:freego_flutter/components/chat_notification_neo/model/im_notification_order_travel_state_for_merchant.dart';
import 'package:freego_flutter/components/chat_notification_neo/parser/im_notification_parser.dart';
import 'package:freego_flutter/components/hotel_neo/hotel_common.dart';
import 'package:freego_flutter/components/hotel_neo/hotel_home_freego.dart';
import 'package:freego_flutter/components/hotel_neo/api/local_hotel_api.dart';
import 'package:freego_flutter/components/order_merchant/order_merchant_hotel.dart';
import 'package:freego_flutter/components/order_merchant/order_merchant_api.dart';
import 'package:freego_flutter/components/order_merchant/order_merchant_restaurant.dart';
import 'package:freego_flutter/components/order_merchant/order_merchant_scenic.dart';
import 'package:freego_flutter/components/order_merchant/order_merchant_travel.dart';
import 'package:freego_flutter/components/order_merchant/order_status_util.dart';
import 'package:freego_flutter/components/order_neo/order_common.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/components/restaurant/restaurant_common.dart';
import 'package:freego_flutter/components/restaurant/restaurant_home.dart';
import 'package:freego_flutter/components/restaurant/restaurant_api.dart';
import 'package:freego_flutter/components/scenic/scenic_home_freego.dart';
import 'package:freego_flutter/components/scenic/api/local_scenic_api.dart';
import 'package:freego_flutter/components/travel/travel_common.dart';
import 'package:freego_flutter/components/travel/travel_detail.dart';
import 'package:freego_flutter/components/travel/travel_api.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/custom_indicator.dart';
import 'package:freego_flutter/http/http_tool.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:intl/intl.dart';

import '../scenic/scenic_common.dart';

class ChatNotificationOrderPage extends StatelessWidget{
  final ImNotificationRoom room;
  const ChatNotificationOrderPage(this.room, {super.key});

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
      body: ChatNotificationOrderWidget(room),
    );
  }

}

class ChatNotificationOrderWidget extends StatefulWidget{
  final ImNotificationRoom room;
  const ChatNotificationOrderWidget(this.room, {super.key});

  @override
  State<StatefulWidget> createState() {
    return ChatNotificationOrderState();
  }

}

class _MyMessageHandler extends ChatMessageHandler{

  final ChatNotificationOrderState state;
  _MyMessageHandler(this.state) :super(priority: 10);

  @override
  Future handle(MessageObject rawObj) async {
    if(rawObj.name != ChatSocket.MESSAGE_NOTIFICATION){
      return;
    }
    if(rawObj.body == null){
      return;
    }
    ImNotification? notification = ImNotificationConverter.fromJson(json.decoder.convert(rawObj.body!));
    if(notification == null){
      return;
    }
    if(notification.roomId != state.widget.room.id){
      return;
    }
    state.notificationList.insert(0, notification);
    state.topBuffer = state.getNotificationWidgets([notification]);
    state.resetState();
    ChatNotificationUtil().readAll(notification.roomId!);
  }
  
}

class _MyReconnectHandler extends SocketReconnectHandler{

  final ChatNotificationOrderState _state;
  _MyReconnectHandler(this._state):super(priority: 99);
  
  @override
  Future handle() async{
    int? minId;
    for(ImNotification notification in _state.notificationList){
      if(notification.id != null){
        minId = notification.id;
        break;
      }
    }
    List<ImNotification> tmpList = await ChatNotificationStorage.getNewNotificationByRoom(roomId: _state.widget.room.id!, minId: minId);
    _state.notificationList.insertAll(0, tmpList);
    _state.topBuffer = _state.getNotificationWidgets(tmpList);
    _state.resetState();
    ChatNotificationUtil().readAll(_state.widget.room.id!);
  }

}

class ChatNotificationOrderState extends State<ChatNotificationOrderWidget>{

  List<ImNotification> notificationList = [];

  List<Widget> contents = [];
  List<Widget> topBuffer = [];
  List<Widget> bottomBuffer = [];

  late _MyMessageHandler _messageHandler;
  late _MyReconnectHandler _myReconnectHandler;

  static final MyNotificationVisitor notificationVisitor = MyNotificationVisitor();

  @override
  void dispose(){
    ChatSocket.removeMessageHandler(_messageHandler);
    ChatSocket.removeReconnectHandler(_myReconnectHandler);
    super.dispose();
  }

  @override
  void initState(){
    super.initState();

    _messageHandler = _MyMessageHandler(this);
    ChatSocket.addMessageHandler(_messageHandler);
    _myReconnectHandler = _MyReconnectHandler(this);
    ChatSocket.addReconnectHandler(_myReconnectHandler);

    int? roomId = widget.room.id;
    if(roomId != null){
      Future.delayed(Duration.zero, () async{
        List<ImNotification> tmpList = await ChatNotificationUtil().getHistory(roomId: roomId);
        for(ImNotification notification in tmpList){
          ImNotification? tmp = ImNotificationParser().parse(notification);
          if(tmp == null){
            notificationList.add(notification);
          }
          else{
            notificationList.add(tmp);
          }
        }
        topBuffer = getNotificationWidgets(notificationList);
        if(mounted && context.mounted){
          setState(() {
          });
        }
      });
      ChatNotificationUtil().readAll(roomId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeUtil.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonHeader(
            center: Text('订单消息', style: TextStyle(color: Colors.white, fontSize: 18),),
          ),
          Expanded(
            child: AnimatedCustomIndicatorWidget(
              contents: contents,
              topBuffer: topBuffer,
              bottomBuffer: bottomBuffer,
              touchBottom: loadHistory,
            ),
          )
        ],
      ),
    );
  }

  Future loadHistory() async{
    int? roomId = widget.room.id;
    if(roomId == null){
      return;
    }
    int? maxId;
    if(notificationList.isNotEmpty){
      maxId = notificationList.last.id;
    }
    List<ImNotification> tmpList = await ChatNotificationUtil().getHistory(roomId: roomId, maxId: maxId);
    if(tmpList.isEmpty){
      ToastUtil.hint('已经没有了呢');
      return;
    }
    for(ImNotification notification in tmpList){
      ImNotification? tmp = ImNotificationParser().parse(notification);
      if(tmp == null){
        notificationList.add(notification);
      }
      else{
        notificationList.add(tmp);
      }
    }
    bottomBuffer = getNotificationWidgets(tmpList);
    if(mounted && context.mounted){
      setState(() {
      });
    } 
  }

  List<Widget> getNotificationWidgets(List<ImNotification> notificationList){
    List<Widget> widgets = [];
    for(ImNotification notification in notificationList){
      Widget? widget = notification.visitBy(notificationVisitor);
      if(widget != null){
        widgets.add(widget);
      }
    }
    return widgets;
  }

  void resetState(){
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }
}

class MyNotificationVisitor extends ChatNotificationVisitor<Widget>{

  @override
  Widget? visit(ImNotification notification){
    if(notification is ImNotificationOrderHotel){
      return NotificationWrapper(
        NotificationOrderHotelWidget(notification),
        key: ValueKey('notification_${notification.id}'),
      );
    }
    else if(notification is ImNotificationOrderScenic){
      return NotificationWrapper(
        NotificationOrderScenicWidget(notification),
        key: ValueKey('notification_${notification.id}'),
      );
    }
    else if(notification is ImNotificationOrderRestaurant){
      return NotificationWrapper(
        NotificationOrderRestaurantWidget(notification),
        key: ValueKey('notification_${notification.id}'),
      );
    }
    else if(notification is ImNotificationOrderTravel){
      return NotificationWrapper(
        NotificationOrderTravelWidget(notification),
        key: ValueKey('notification_${notification.id}'),
      );
    }
    return null;
  }

  @override
  Widget? visitScenicOrderStateForMerchant(ImNotificationOrderScenicStateForMerchant notification){
    return NotificationWrapper(
      NotificationOrderScenicStateForMerchantWidget(notification: notification,),
      key: ValueKey('notification_${notification.id}'),
    );
  }

  @override
  Widget? visitHotelOrderStateForMerchant(ImNotificationOrderHotelStateForMerchant notification){
    return NotificationWrapper(
      NotificationOrderHotelStateForMerchantWidget(notification: notification,),
      key: ValueKey('notification_${notification.id}'),
    );
  }

  @override
  Widget? visitRestaurantOrderStateForMerchant(ImNotificationOrderRestaurantStateForMerchant notification){
    return NotificationWrapper(
      NotificationOrderRestaurantStateForMerchantWidget(notification: notification,),
      key: ValueKey('notification_${notification.id}'),
    );
  }
}

class NotificationOrderScenicStateForMerchantWidget extends StatefulWidget{

  final ImNotificationOrderScenicStateForMerchant notification;
  const NotificationOrderScenicStateForMerchantWidget({required this.notification, super.key});

  @override
  State<StatefulWidget> createState() {
    return NotificationOrderScenicStateForMerchantState();
  }
  
}

class NotificationOrderScenicStateForMerchantState extends State<NotificationOrderScenicStateForMerchantWidget>{

  static const double FIELD_NAME_WIDTH = 80;

  late ImNotificationOrderScenicStateForMerchant notification;
  OrderScenicStatus? orderStatus;

  @override
  void initState(){
    super.initState();
    notification = widget.notification;
    if(notification.orderStatus != null){
      orderStatus = OrderScenicStatusExt.getStatus(notification.orderStatus!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(MyOrderScenicStatusExt(orderStatus)?.getText() ?? '', style: TextStyle(color: orderStatus?.getColor(), fontWeight: FontWeight.bold, fontSize: 18),),
            if(notification.checked != true)
            const Text('NEW', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),)
          ],
        ),
        if(notification.createTime != null)
        Text(notification.createTime!.toFormat('yyyy-MM-dd HH:mm:ss'), style: const TextStyle(color: ThemeUtil.foregroundColor),),
        const SizedBox(height: 8,),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: FIELD_NAME_WIDTH,
              child: Text('门票', style: TextStyle(color: ThemeUtil.foregroundColor),),
            ),
            Expanded(
              child: InkWell(
                onTap: () async{
                  if(notification.scenicId == null){
                    ToastUtil.error('数据错误');
                    return;
                  }
                  Scenic? scenic = await LocalScenicApi().detail(notification.scenicId!);
                  if(scenic == null){
                    ToastUtil.error('目标不存在');
                    return;
                  }
                  if(mounted && context.mounted){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context){
                      return ScenicHomePage(scenic);
                    }));
                  }
                },
                child: Text(notification.scenicName ?? '', style: const TextStyle(color: ThemeUtil.buttonColor),),
              )
            )
          ],
        ),
        const Divider(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: FIELD_NAME_WIDTH,
              child: Text('门票', style: TextStyle(color: ThemeUtil.foregroundColor),),
            ),
            Expanded(
              child: Text(notification.ticketName ?? '', style: const TextStyle(color: ThemeUtil.buttonColor),),
            )
          ],
        ),
        const SizedBox(height: 8,),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: FIELD_NAME_WIDTH,
              child: Text('购买数量', style: TextStyle(color: ThemeUtil.foregroundColor),),
            ),
            Expanded(
              child: Text('${notification.quantity}', style: const TextStyle(color: ThemeUtil.foregroundColor),),
            )
          ],
        ),
        if(notification.travelDate != null)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: FIELD_NAME_WIDTH,
                child: Text('游玩日期', style: TextStyle(color: ThemeUtil.foregroundColor),),
              ),
              Expanded(
                child: Text(DateFormat('yyyy年MM月dd日').format(notification.travelDate!), style: const TextStyle(color: ThemeUtil.foregroundColor),),
              )
            ],
          ),
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              style: TextButton.styleFrom( 
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap
              ),
              onPressed: toDetail,
              child: const Padding(
                padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
                child: Text('查看详情', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold),),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap
              ),
              onPressed: toDetail,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.arrow_forward_ios_rounded, color: ThemeUtil.foregroundColor,),
              ),
            )
          ]
        )
      ],
    );
  }

  Future toDetail() async{
    if(notification.orderId == null){
      return;
    }
    OrderScenic? order = await OrderMerchantHttp().getOrderScenic(orderId: notification.orderId!);
    if(order == null){
      ToastUtil.error('目标不存在');
      return;
    }
    if(context.mounted){
      Navigator.of(context).push(MaterialPageRoute(builder: (context){
        return OrderMerchantScenicPage(nid: notification.id, order: order,);
      }));
    }
    notification.checked = true;
    if(notification.id != null){
      ChatNotificationStorage.setChecked(notification.id!, true);
    }
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }
  
}

class NotificationOrderScenicWidget extends StatefulWidget{

  final ImNotificationOrderScenic notification;
  const NotificationOrderScenicWidget(this.notification, {super.key});

  @override
  State<StatefulWidget> createState() {
    return NotificationOrderScenicState();
  }
  
}

class _MyOrderScenicStatusListener implements OrderScenicStatusListener{

  NotificationOrderScenicState state;
  _MyOrderScenicStatusListener(this.state);

  @override
  void setOrderStatus(int nid, int status) {
    if(nid == state.widget.notification.id){
      state.widget.notification.orderStatus = status;
      state.resetState();
    }
  }
  
}

class NotificationOrderScenicState extends State<NotificationOrderScenicWidget>{

  static const double FIELD_NAME_WIDTH = 80;

  late _MyOrderScenicStatusListener _listener;

  @override
  void initState(){
    super.initState();
    _listener = _MyOrderScenicStatusListener(this);
    OrderStatusUtil().addScenicStatusListener(_listener);
  }

  @override
  void dispose(){
    OrderStatusUtil().removeScenicStatusListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ImNotificationOrderScenic notification = widget.notification;
    NotificationType? type;
    if(notification.type != null){
      type = NotificationTypeExt.getType(notification.type!);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            type == NotificationType.orderReceived ?
            const Text('新订单消息', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),) :
            const Text('订单取消', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
            notification.checked != true ?
            const Text('NEW', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),): 
            const SizedBox()
          ],
        ),
        notification.createTime != null ?
        Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(notification.createTime!,), style: const TextStyle(color: ThemeUtil.foregroundColor),) :
        const SizedBox(),
        const SizedBox(height: 8,),
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(text: '用户', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
              TextSpan(
                text: '${notification.customerName}',
                style: const TextStyle(color: Colors.lightBlue, fontSize: 16),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async{
                    if(notification.customerId == null){
                      return;
                    }
                    ImSingleRoom? room = await ChatUtilSingle.enterRoom(notification.customerId!);
                    if(room == null){
                      return;
                    }
                    if(mounted && context.mounted){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context){
                        return ChatRoomPage(room: room);
                      }));
                    }
                  }
              ),
              const TextSpan(text: '在', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
              TextSpan(
                text: '${notification.scenicName}',
                style: const TextStyle(color: Colors.lightBlue, fontSize: 16),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async{
                    if(notification.scenicId == null){
                      ToastUtil.error('数据错误');
                      return;
                    }
                    Scenic? scenic = await LocalScenicApi().detail(notification.scenicId!);
                    if(scenic == null){
                      ToastUtil.error('目标不存在');
                      return;
                    }
                    if(mounted && context.mounted){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context){
                        return ScenicHomePage(scenic);
                      }));
                    }
                  }
              ),
              const TextSpan(text: '中购买了门票', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
            ]
          ),
        ),
        const Divider(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: FIELD_NAME_WIDTH,
              child: Text('门票名', style: TextStyle(color: ThemeUtil.foregroundColor),),
            ),
            Expanded(
              child: Text(notification.ticketName ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor),),
            )
          ],
        ),
        const SizedBox(height: 8,),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: FIELD_NAME_WIDTH,
              child: Text('购买数量', style: TextStyle(color: ThemeUtil.foregroundColor),),
            ),
            Expanded(
              child: Text('${notification.quantity}', style: const TextStyle(color: ThemeUtil.foregroundColor),),
            )
          ],
        ),
        notification.visitDate != null ?
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: FIELD_NAME_WIDTH,
                child: Text('游玩日期', style: TextStyle(color: ThemeUtil.foregroundColor),),
              ),
              Expanded(
                child: Text(DateFormat('yyyy年MM月dd日').format(notification.visitDate!), style: const TextStyle(color: ThemeUtil.foregroundColor),),
              )
            ],
          ),
        ) : const SizedBox(),
        getPayStatusWidget(),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              style: TextButton.styleFrom( 
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap
              ),
              onPressed: toDetail,
              child: const Padding(
                padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
                child: Text('查看详情', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold),),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap
              ),
              onPressed: toDetail,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.arrow_forward_ios_rounded, color: ThemeUtil.foregroundColor,),
              ),
            )
          ],
        )
      ],
    );
  }

  Future toDetail() async{
    ImNotificationOrderScenic notification = widget.notification;
    if(notification.linkedId == null){
      ToastUtil.error('数据错误');
      return;
    }
    OrderScenic? order = await OrderMerchantHttp().getOrderScenic(orderId: notification.linkedId!);
    if(order == null){
      ToastUtil.error('目标不存在');
      return;
    }
    if(context.mounted){
      Navigator.of(context).push(MaterialPageRoute(builder: (context){
        return OrderMerchantScenicPage(nid: notification.id, order: order,);
      }));
    }
    notification.checked = true;
    if(notification.id != null){
      ChatNotificationStorage.updateOrderChecked(notification.id!, ProductType.scenic, 1);
    }
    setState(() {
    });
  }

  Widget getPayStatusWidget(){
    ImNotificationOrderScenic notification = widget.notification;
    if(notification.orderStatus == null){
      return const SizedBox();
    }
    OrderScenicStatus? status = OrderScenicStatusExt.getStatus(notification.orderStatus!);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          const SizedBox(
            width: FIELD_NAME_WIDTH,
            child: Text('订单状态', style: TextStyle(color: ThemeUtil.foregroundColor),),
          ),
          Text(MyOrderScenicStatusExt(status)?.getText() ?? '订单出错', style: TextStyle(color: status?.getColor() ?? Colors.redAccent),)
        ],
      ),
    );
  }

  void resetState(){
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }
}

class NotificationOrderHotelStateForMerchantWidget extends StatefulWidget{

  final ImNotificationOrderHotelStateForMerchant notification;

  const NotificationOrderHotelStateForMerchantWidget({required this.notification, super.key});

  @override
  State<StatefulWidget> createState() {
    return NotificationOrderHotelStateForMerchantState();
  }
  
}

class NotificationOrderHotelStateForMerchantState extends State<NotificationOrderHotelStateForMerchantWidget>{

  static const double FIELD_NAME_WIDTH = 80;

  late ImNotificationOrderHotelStateForMerchant notification;
  OrderHotelStatus? orderStatus;

  @override
  void initState(){
    super.initState();
    notification = widget.notification;
    if(notification.orderStatus != null){
      orderStatus = OrderHotelStatusExt.getStatus(notification.orderStatus!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(MyOrderHotelStatusExt(orderStatus)?.getText() ?? '', style: TextStyle(color: orderStatus?.getColor(), fontWeight: FontWeight.bold, fontSize: 18),),
            if(notification.checked != true)
            const Text('NEW', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),)
          ],
        ),
        if(notification.createTime != null)
        Text(notification.createTime!.toFormat('yyyy-MM-dd HH:mm:ss',), style: const TextStyle(color: ThemeUtil.foregroundColor),),
        const Divider(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: FIELD_NAME_WIDTH,
              child: Text('酒店', style: TextStyle(color: ThemeUtil.foregroundColor),),
            ),
            Expanded(
              child: InkWell(
                onTap: () async{
                  if(notification.hotelId == null){
                    ToastUtil.error('数据错误');
                    return;
                  }
                  DateTime startDate = DateTime.now();
                  startDate = DateTime(startDate.year, startDate.month, startDate.day);
                  DateTime endDate = startDate.add(const Duration(days: 1));
                  Hotel? hotel = await LocalHotelApi().detail(id: notification.hotelId!, startDate: startDate, endDate: endDate);
                  if(hotel == null){
                    ToastUtil.error('目标不存在');
                    return;
                  }
                  if(mounted && context.mounted){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context){
                      return HotelHomePage(hotel, startDate: startDate, endDate: endDate,);
                    }));
                  }
                },
                child: Text(notification.hotelName ?? '', style: const TextStyle(color: ThemeUtil.buttonColor),),
              ),
            )
          ],
        ),
        const Divider(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: FIELD_NAME_WIDTH,
              child: Text('房型', style: TextStyle(color: ThemeUtil.foregroundColor),),
            ),
            Expanded(
              child: Text(notification.chamberName ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor),),
            )
          ],
        ),
        const Divider(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: FIELD_NAME_WIDTH,
              child: Text('房间套餐', style: TextStyle(color: ThemeUtil.foregroundColor),),
            ),
            Expanded(
              child: Text(notification.ratePlanName ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor),),
            )
          ],
        ),
        const SizedBox(height: 8,),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: FIELD_NAME_WIDTH,
              child: Text('预订数量', style: TextStyle(color: ThemeUtil.foregroundColor),),
            ),
            Expanded(
              child: Text('${notification.numberOfRooms}', style: const TextStyle(color: ThemeUtil.foregroundColor),),
            )
          ],
        ),
        if(notification.checkInDate != null && notification.checkOutDate != null)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: FIELD_NAME_WIDTH,
                child: Text('入住时间', style: TextStyle(color: ThemeUtil.foregroundColor),),
              ),
              Expanded(
                child: Row(
                  children: [
                    Text(DateFormat('yyyy年MM月dd日').format(notification.checkInDate!), style: const TextStyle(color: ThemeUtil.foregroundColor),),
                    const Text(' - ', style: TextStyle(color: Colors.grey),),
                    Text(DateFormat('yyyy年MM月dd日').format(notification.checkOutDate!), style: const TextStyle(color: ThemeUtil.foregroundColor),)
                  ],
                ),
              )
            ],
          ),
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap
              ),
              onPressed: toDetail,
              child: const Padding(
                padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
                child: Text('查看详情', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold),),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap
              ),
              onPressed: toDetail,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.arrow_forward_ios_rounded, color: ThemeUtil.foregroundColor,),
              ),
            )
          ],
        )
      ],
    );
  }
  
  Future toDetail() async{
    if(notification.orderId == null){
      ToastUtil.error('数据错误');
      return;
    }
    OrderHotel? order = await OrderMerchantHttp().getOrderHotel(orderId: notification.orderId!);
    if(order == null){
      ToastUtil.error('目标不存在');
      return;
    }
    if(context.mounted){
      Navigator.of(context).push(MaterialPageRoute(builder: (context){
        return OrderMerchantHotelPage(nid: notification.id!, order: order,);
      }));
    }
    notification.checked = true;
    if(notification.id != null){
      ChatNotificationStorage.updateOrderChecked(notification.id!, ProductType.hotel, 1);
    }
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }
}

class NotificationOrderHotelWidget extends StatefulWidget{
  final ImNotificationOrderHotel notification;
  const NotificationOrderHotelWidget(this.notification, {super.key});

  @override
  State<StatefulWidget> createState() {
    return NotificationOrderHotelState();
  }

}

class _MyOrderHotelStatusListener implements OrderHotelStatusListener{

  final NotificationOrderHotelState state;
  _MyOrderHotelStatusListener(this.state);

  @override
  void setOrderStatus(int nid, int status) {
    if(nid == state.widget.notification.id){
      state.widget.notification.orderStatus = status;
      state.resetState();
    }
  }
  
}

class NotificationOrderHotelState extends State<NotificationOrderHotelWidget>{

  static const double FIELD_NAME_WIDTH = 80;
  late _MyOrderHotelStatusListener _listener;

  @override
  void initState(){
    super.initState();
    _listener = _MyOrderHotelStatusListener(this);
    OrderStatusUtil().addHotelStatusListener(_listener);
  }

  @override
  void dispose(){
    OrderStatusUtil().removeHotelStatusListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ImNotificationOrderHotel notification = widget.notification;
    NotificationType? type;
    if(notification.type != null){
      type = NotificationTypeExt.getType(notification.type!);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            type == NotificationType.orderReceived ?
            const Text('新订单消息', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),) :
            const Text('订单取消', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
            notification.checked != true ?
            const Text('NEW', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),): 
            const SizedBox()
          ],
        ),
        notification.createTime != null ?
        Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(notification.createTime!,), style: const TextStyle(color: ThemeUtil.foregroundColor),) :
        const SizedBox(),
        const Divider(),
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 16),
            children: [
              const TextSpan(text: '用户', style: TextStyle(color: ThemeUtil.foregroundColor)),
              TextSpan(
                text: notification.customerName,
                style: const TextStyle(color: Colors.lightBlue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async{
                    if(notification.customerId == null){
                      return;
                    }
                    ImSingleRoom? room = await ChatUtilSingle.enterRoom(notification.customerId!);
                    if(room == null){
                      return;
                    }
                    if(mounted && context.mounted){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context){
                        return ChatRoomPage(room: room);
                      }));
                    }
                  }
              ),
              const TextSpan(text: '在', style: TextStyle(color: ThemeUtil.foregroundColor)),
              TextSpan(
                text: notification.hotelName,
                style: const TextStyle(color: Colors.lightBlue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async{
                    if(notification.hotelId == null){
                      ToastUtil.error('数据错误');
                      return;
                    }
                    DateTime startDate = DateTime.now();
                    startDate = DateTime(startDate.year, startDate.month, startDate.day);
                    DateTime endDate = startDate.add(const Duration(days: 1));
                    Hotel? hotel = await LocalHotelApi().detail(id: notification.hotelId!, startDate: startDate, endDate: endDate);
                    if(hotel == null){
                      ToastUtil.error('目标不存在');
                      return;
                    }
                    if(mounted && context.mounted){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context){
                        return HotelHomePage(hotel, startDate: startDate, endDate: endDate,);
                      }));
                    }
                  }
              ),
              type == NotificationType.orderReceived ?
              const TextSpan(text: '中预订了房间', style: TextStyle(color: ThemeUtil.foregroundColor)) :
              const TextSpan(text: '取消了房间', style: TextStyle(color: ThemeUtil.foregroundColor))
            ]
          ),
        ),
        const Divider(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: FIELD_NAME_WIDTH,
              child: Text('房间套餐', style: TextStyle(color: ThemeUtil.foregroundColor),),
            ),
            Expanded(
              child: Text(notification.planName ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor),),
            )
          ],
        ),
        const SizedBox(height: 8,),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: FIELD_NAME_WIDTH,
              child: Text('预订数量', style: TextStyle(color: ThemeUtil.foregroundColor),),
            ),
            Expanded(
              child: Text('${notification.quantity}', style: const TextStyle(color: ThemeUtil.foregroundColor),),
            )
          ],
        ),
        notification.checkInDate != null && notification.checkOutDate != null ?
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: FIELD_NAME_WIDTH,
                child: Text('入住时间', style: TextStyle(color: ThemeUtil.foregroundColor),),
              ),
              Expanded(
                child: Row(
                  children: [
                    Text(DateFormat('yyyy年MM月dd日').format(notification.checkInDate!), style: const TextStyle(color: ThemeUtil.foregroundColor),),
                    const Text(' - ', style: TextStyle(color: Colors.grey),),
                    Text(DateFormat('yyyy年MM月dd日').format(notification.checkOutDate!), style: const TextStyle(color: ThemeUtil.foregroundColor),)
                  ],
                ),
              )
            ],
          ),
        ) : const SizedBox(),
        getPayStatusWidget(),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap
              ),
              onPressed: toDetail,
              child: const Padding(
                padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
                child: Text('查看详情', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold),),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap
              ),
              onPressed: toDetail,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.arrow_forward_ios_rounded, color: ThemeUtil.foregroundColor,),
              ),
            )
          ],
        )
      ],
    );
  }

  Future toDetail() async{
    ImNotificationOrderHotel notification = widget.notification;
    if(notification.linkedId == null || notification.id == null){
      ToastUtil.error('数据错误');
      return;
    }
    OrderHotel? order = await OrderMerchantHttp().getOrderHotel(orderId: notification.linkedId!);
    if(order == null){
      ToastUtil.error('目标不存在');
      return;
    }
    if(context.mounted){
      Navigator.of(context).push(MaterialPageRoute(builder: (context){
        return OrderMerchantHotelPage(nid: notification.id!, order: order,);
      }));
    }
    notification.checked = true;
    if(notification.id != null){
      ChatNotificationStorage.updateOrderChecked(notification.id!, ProductType.hotel, 1);
    }
    setState(() {
    });
  }

  Widget getPayStatusWidget(){
    ImNotificationOrderHotel notification = widget.notification;
    if(notification.orderStatus == null){
      return const SizedBox();
    }
    OrderHotelStatus? status = OrderHotelStatusExt.getStatus(notification.orderStatus!);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          const SizedBox(
            width: FIELD_NAME_WIDTH,
            child: Text('订单状态', style: TextStyle(color: ThemeUtil.foregroundColor),),
          ),
          Text(MyOrderHotelStatusExt(status)?.getText() ?? '订单出错', style: TextStyle(color: status?.getColor() ?? Colors.redAccent),)
        ],
      ),
    );
  }

  void resetState(){
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }
}

class NotificationWrapper extends StatelessWidget{

  static const double MARGIN_TOP = 4;
  static const double MARGIN_BOTTOM = MARGIN_TOP;
  static const double PADDING = 20;
  static const double BORDER_RADIUS = 10;

  final Widget content;
  const NotificationWrapper(this.content, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(   
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(BORDER_RADIUS)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4
          )
        ]
      ),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width
      ),
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.fromLTRB(0, MARGIN_TOP, 0, MARGIN_BOTTOM),
      padding: const EdgeInsets.all(PADDING),
      child: content,
    );
  }

}

class NotificationOrderRestaurantStateForMerchantWidget extends StatefulWidget{
  final ImNotificationOrderRestaurantStateForMerchant notification;
  const NotificationOrderRestaurantStateForMerchantWidget({required this.notification, super.key});

  @override
  State<StatefulWidget> createState() {
    return NotificationOrderRestaurantStateForMerchantState();
  }
  
}

class NotificationOrderRestaurantStateForMerchantState extends State<NotificationOrderRestaurantStateForMerchantWidget>{

  static const double FIELD_NAME_WIDTH = 80;

  late ImNotificationOrderRestaurantStateForMerchant notification;
  OrderRestaurantStatus? orderStatus;

  @override
  void initState(){
    super.initState();
    notification = widget.notification;
    if(notification.orderStatus != null){
      orderStatus = OrderRestaurantStatusExt.getStatus(notification.orderStatus!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(MyOrderRestaurantStatusExt(orderStatus)?.getText() ?? '', style: TextStyle(color: orderStatus?.getColor(), fontWeight: FontWeight.bold, fontSize: 18),),
            if(notification.checked != true)
            const Text('NEW', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),)
          ],
        ),
        if(notification.createTime != null)
        Text(notification.createTime!.toFormat('yyyy-MM-dd HH:mm:ss',), style: const TextStyle(color: ThemeUtil.foregroundColor),),
        const Divider(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: FIELD_NAME_WIDTH,
              child: Text('餐厅', style: TextStyle(color: ThemeUtil.foregroundColor),),
            ),
            Expanded(
              child: InkWell(
                onTap: () async{
                  if(notification.restaurantId == null){
                    ToastUtil.error('数据错误');
                    return;
                  }
                  DateTime startDate = DateTime.now();
                  startDate = DateTime(startDate.year, startDate.month, startDate.day);
                  DateTime endDate = startDate.add(const Duration(days: 1));
                  Hotel? hotel = await LocalHotelApi().detail(id: notification.restaurantId!, startDate: startDate, endDate: endDate);
                  if(hotel == null){
                    ToastUtil.error('目标不存在');
                    return;
                  }
                  if(mounted && context.mounted){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context){
                      return HotelHomePage(hotel, startDate: startDate, endDate: endDate,);
                    }));
                  }
                },
                child: Text(notification.restaurantName ?? '', style: const TextStyle(color: ThemeUtil.buttonColor),),
              ),
            )
          ],
        ),
        const SizedBox(height: 8,),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: FIELD_NAME_WIDTH,
              child: Text('用餐人数', style: TextStyle(color: ThemeUtil.foregroundColor),),
            ),
            Expanded(
              child: Text('${notification.numberOfPeople}', style: const TextStyle(color: ThemeUtil.foregroundColor),),
            )
          ],
        ),
        if(notification.diningTime != null)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: FIELD_NAME_WIDTH,
                child: Text('用餐时间', style: TextStyle(color: ThemeUtil.foregroundColor),),
              ),
              Expanded(
                child: Row(
                  children: [
                    Text(DateFormat('yyyy年MM月dd日').format(notification.diningTime!), style: const TextStyle(color: ThemeUtil.foregroundColor),),
                  ],
                ),
              )
            ],
          ),
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap
              ),
              onPressed: toDetail,
              child: const Padding(
                padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
                child: Text('查看详情', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold),),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap
              ),
              onPressed: toDetail,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.arrow_forward_ios_rounded, color: ThemeUtil.foregroundColor,),
              ),
            )
          ],
        )
      ],
    );
  }
  
  Future toDetail() async{
    if(notification.orderId == null){
      ToastUtil.error('数据错误');
      return;
    }
    OrderRestaurant? order = await OrderMerchantHttp().getOrderRestaurant(orderId: notification.orderId!);
    if(order == null){
      ToastUtil.error('目标不存在');
      return;
    }
    if(context.mounted){
      Navigator.of(context).push(MaterialPageRoute(builder: (context){
        return OrderMerchantRestaurantPage(nid: notification.id!, order: order,);
      }));
    }
    notification.checked = true;
    if(notification.id != null){
      ChatNotificationStorage.updateOrderChecked(notification.id!, ProductType.hotel, 1);
    }
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }
}

class NotificationOrderRestaurantWidget extends StatefulWidget{

  final ImNotificationOrderRestaurant notification;
  const NotificationOrderRestaurantWidget(this.notification, {super.key});

  @override
  State<StatefulWidget> createState() {
    return NotificationOrderRestaurantState();
  }
  
}

class _MyOrderRestaurantStatusListener implements OrderRestaurantStatusListener{

  final NotificationOrderRestaurantState state;
  _MyOrderRestaurantStatusListener(this.state);

  @override
  void setOrderStatus(int nid, int status) {
    if(state.widget.notification.id == nid){
      state.widget.notification.orderStatus = status;
      state.resetState();
    }
  }
  
}

class NotificationOrderRestaurantState extends State<NotificationOrderRestaurantWidget>{

  static const double FIELD_NAME_WIDTH = 80;

  late _MyOrderRestaurantStatusListener _listener;

  @override
  void initState(){
    super.initState();
    _listener = _MyOrderRestaurantStatusListener(this);
    OrderStatusUtil().addRestaurantStatusListener(_listener);
  }

  @override
  void dispose(){
    OrderStatusUtil().removeRestaurantStatusListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ImNotificationOrderRestaurant notification = widget.notification;
    NotificationType? type;
    if(notification.type != null){
      type = NotificationTypeExt.getType(notification.type!);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            type == NotificationType.orderReceived ?
            const Text('新订单消息', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),) :
            const Text('订单取消', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
            notification.checked != true ?
            const Text('NEW', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),): 
            const SizedBox()
          ],
        ),
        notification.createTime != null ?
        Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(notification.createTime!,), style: const TextStyle(color: ThemeUtil.foregroundColor),) :
        const SizedBox(),
        const SizedBox(height: 8,),
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(text: '用户', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
              TextSpan(
                text: '${notification.customerName}',
                style: const TextStyle(color: Colors.lightBlue, fontSize: 16),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async{
                    if(notification.customerId == null){
                      return;
                    }
                    ImSingleRoom? room = await ChatUtilSingle.enterRoom(notification.customerId!);
                    if(room == null){
                      return;
                    }
                    if(mounted && context.mounted){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context){
                        return ChatRoomPage(room: room);
                      }));
                    }
                  }
              ),
              const TextSpan(text: '在', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
              TextSpan(
                text: '${notification.restaurantName}',
                style: const TextStyle(color: Colors.lightBlue, fontSize: 16),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async{
                    if(notification.restaurantId == null){
                      ToastUtil.error('数据错误');
                      return;
                    }
                    Restaurant? restaurant = await RestaurantApi().getById(notification.restaurantId!);
                    if(restaurant == null){
                      ToastUtil.error('目标不存在');
                      return;
                    }
                    if(mounted && context.mounted){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context){
                        return RestaurantHomePage(restaurant);
                      }));
                    }
                  }
              ),
              type == NotificationType.orderReceived ?
              const TextSpan(text: '中预订了用餐', style: TextStyle(color: ThemeUtil.foregroundColor)) :
              const TextSpan(text: '取消了用餐', style: TextStyle(color: ThemeUtil.foregroundColor))
            ]
          ),
        ),
        const Divider(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: FIELD_NAME_WIDTH,
              child: Text('用餐方式', style: TextStyle(color: ThemeUtil.foregroundColor),),
            ),
            Expanded(
              child: Text(getDiningMethodsText(), style: const TextStyle(color: ThemeUtil.foregroundColor),),
            )
          ],
        ),
        const SizedBox(height: 8,),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: FIELD_NAME_WIDTH,
              child: Text('用餐人数', style: TextStyle(color: ThemeUtil.foregroundColor),),
            ),
            Expanded(
              child: Text('${notification.numberPeople}', style: const TextStyle(color: ThemeUtil.foregroundColor),),
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: FIELD_NAME_WIDTH,
                child: Text('预订时间', style: TextStyle(color: ThemeUtil.foregroundColor),),
              ),
              Expanded(
                child: Text(DateFormat('yyyy年MM月dd日 HH:mm').format(notification.arrivalDate!), style: const TextStyle(color: ThemeUtil.foregroundColor),),
              )
            ],
          ),
        ),
        getPayStatusWidget(),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              style: TextButton.styleFrom( 
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap
              ),
              onPressed: toDetail,
              child: const Padding(
                padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
                child: Text('查看详情', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold),),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap
              ),
              onPressed: toDetail,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.arrow_forward_ios_rounded, color: ThemeUtil.foregroundColor,),
              ),
            )
          ],
        )
      ],
    );
  }

  Future toDetail() async{
    ImNotificationOrderRestaurant notification = widget.notification;
    if(notification.linkedId == null){
      ToastUtil.error('数据错误');
      return;
    }
    OrderRestaurant? order = await OrderMerchantHttp().getOrderRestaurant(orderId: notification.linkedId!);
    if(order == null){
      ToastUtil.error('目标不存在');
      return;
    }
    if(context.mounted){
      Navigator.of(context).push(MaterialPageRoute(builder: (context){
        return OrderMerchantRestaurantPage(nid: notification.id, order: order,);
      }));
    }
    notification.checked = true;
    if(notification.id != null){
      ChatNotificationStorage.updateOrderChecked(notification.id!, ProductType.restaurant, 1);
    }
    setState(() {
    });
  }

  String getDiningMethodsText() {
    ImNotificationOrderRestaurant notification = widget.notification;
    if (notification.diningMethods == null) {
      return '订单出错';
    }
    OrderRestaurantDining? status =
        OrderRestaurantDiningExt.getStatus(notification.diningMethods!);
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

  Widget getPayStatusWidget(){
    ImNotificationOrderRestaurant notification = widget.notification;
    if(notification.orderStatus == null){
      return const SizedBox();
    }
    OrderRestaurantStatus? status = OrderRestaurantStatusExt.getStatus(notification.orderStatus!);
    if(status == null){
      return const SizedBox();
    }
    String? statusText;
    Color? statusColor;
    switch(status){
      case OrderRestaurantStatus.unpaid:
        statusText = '未支付';
        statusColor = Colors.lightGreen;
        break;
      case OrderRestaurantStatus.unconfirmed:
        statusText = '待确认';
        statusColor = Colors.lightBlue;
        break;
      case OrderRestaurantStatus.confirmed:
        statusText = '已确认';
        statusColor = Colors.lightBlue;
        break;
      case OrderRestaurantStatus.confirmFail:
        statusText = '确认失败';
        statusColor = Colors.redAccent;
        break;
      case OrderRestaurantStatus.completed:
        statusText = '已完成';
        statusColor = const Color.fromRGBO(249, 168, 37, 1);
        break;
      case OrderRestaurantStatus.canceling:
        statusText = '取消中';
        statusColor = Colors.grey;
        break;
      case OrderRestaurantStatus.cancelFail:
        statusText = '取消失败';
        statusColor = Colors.grey;
        break;
      case OrderRestaurantStatus.canceled:
        statusText = '已取消';
        statusColor = Colors.grey;
        break;
      default:
    }
    if(statusText == null){
      return const SizedBox();
    }
    return Padding(
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
    );
  }

  void resetState(){
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }
}

class NotificationOrderTravelStateForMerchantWidget extends StatefulWidget{

  final ImNotificationOrderTravelStateForMerchant notification;

  const NotificationOrderTravelStateForMerchantWidget({required this.notification, super.key});

  @override
  State<StatefulWidget> createState() {
    return NotificationOrderTravelStateForMerchantState();
  }
  
}

class NotificationOrderTravelStateForMerchantState extends State<NotificationOrderTravelStateForMerchantWidget>{

  static const double FIELD_NAME_WIDTH = 80;

  late ImNotificationOrderTravelStateForMerchant notification;
  OrderTravelStatus? orderStatus;

  @override
  void initState(){
    super.initState();
    notification = widget.notification;
    if(notification.orderStatus != null){
      orderStatus = OrderTravelStatusExt.getStatus(notification.orderStatus!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(MyOrderTravelStatusExt(orderStatus)?.getText() ?? '', style: TextStyle(color: orderStatus?.getColor(), fontWeight: FontWeight.bold, fontSize: 18),),
            if(notification.checked != true)
            const Text('NEW', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),)
          ],
        ),
        if(notification.createTime != null)
        Text(notification.createTime!.toFormat('yyyy-MM-dd HH:mm:ss',), style: const TextStyle(color: ThemeUtil.foregroundColor),),
        const Divider(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: FIELD_NAME_WIDTH,
              child: Text('旅行', style: TextStyle(color: ThemeUtil.foregroundColor),),
            ),
            Expanded(
              child: InkWell(
                onTap: () async{
                  if(notification.travelId == null){
                    ToastUtil.error('数据错误');
                    return;
                  }
                  Travel? travel = await TravelApi().getById(travelId: notification.travelId!);
                  if(travel == null){
                    ToastUtil.error('目标不存在');
                    return;
                  }
                  if(mounted && context.mounted){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context){
                      return TravelDetailPage(travel);
                    }));
                  }
                },
                child: Text(notification.travelName ?? '', style: const TextStyle(color: ThemeUtil.buttonColor),),
              ),
            )
          ],
        ),
        const Divider(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: FIELD_NAME_WIDTH,
              child: Text('套餐', style: TextStyle(color: ThemeUtil.foregroundColor),),
            ),
            Expanded(
              child: Text(notification.travelSuitName ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor),),
            )
          ],
        ),
        const SizedBox(height: 8,),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: FIELD_NAME_WIDTH,
              child: Text('成人', style: TextStyle(color: ThemeUtil.foregroundColor),),
            ),
            Expanded(
              child: Text('${notification.numberOfAdult}', style: const TextStyle(color: ThemeUtil.foregroundColor),),
            )
          ],
        ),
        if((notification.numberOfOld ?? 0) > 0)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: FIELD_NAME_WIDTH,
                child: Text('老人', style: TextStyle(color: ThemeUtil.foregroundColor),),
              ),
              Expanded(
                child: Text('${notification.numberOfOld}', style: const TextStyle(color: ThemeUtil.foregroundColor),),
              )
            ],
          ),
        ),
        if((notification.numberOfChild ?? 0) > 0)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: FIELD_NAME_WIDTH,
                child: Text('儿童', style: TextStyle(color: ThemeUtil.foregroundColor),),
              ),
              Expanded(
                child: Text('${notification.numberOfChild}', style: const TextStyle(color: ThemeUtil.foregroundColor),),
              )
            ],
          ),
        ),
        if(notification.startDate != null && notification.endDate != null)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: FIELD_NAME_WIDTH,
                child: Text('时间', style: TextStyle(color: ThemeUtil.foregroundColor),),
              ),
              Expanded(
                child: Row(
                  children: [
                    Text(DateFormat('yyyy年MM月dd日').format(notification.startDate!), style: const TextStyle(color: ThemeUtil.foregroundColor),),
                    const Text(' - ', style: TextStyle(color: Colors.grey),),
                    Text(DateFormat('yyyy年MM月dd日').format(notification.endDate!), style: const TextStyle(color: ThemeUtil.foregroundColor),)
                  ],
                ),
              )
            ],
          ),
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap
              ),
              onPressed: toDetail,
              child: const Padding(
                padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
                child: Text('查看详情', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold),),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap
              ),
              onPressed: toDetail,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.arrow_forward_ios_rounded, color: ThemeUtil.foregroundColor,),
              ),
            )
          ],
        )
      ],
    );
  }
  
  Future toDetail() async{
    if(notification.orderId == null){
      ToastUtil.error('数据错误');
      return;
    }
    OrderTravel? order = await OrderMerchantHttp().getOrderTravel(orderId: notification.orderId!);
    if(order == null){
      ToastUtil.error('目标不存在');
      return;
    }
    if(context.mounted){
      Navigator.of(context).push(MaterialPageRoute(builder: (context){
        return OrderMerchantTravelPage(nid: notification.id!, order: order,);
      }));
    }
    notification.checked = true;
    if(notification.id != null){
      ChatNotificationStorage.updateOrderChecked(notification.id!, ProductType.hotel, 1);
    }
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }
}

class NotificationOrderTravelWidget extends StatefulWidget{

  final ImNotificationOrderTravel notification;
  const NotificationOrderTravelWidget(this.notification, {super.key});

  @override
  State<StatefulWidget> createState() {
    return NotificationOrderTravelState();
  }
  
}

class _MyOrderTravelStatusListener implements OrderTravelStatusListener{

  NotificationOrderTravelState state;
  _MyOrderTravelStatusListener(this.state);

  @override
  void setOrderStatus(int nid, int status) {
    if(state.widget.notification.id == nid){
      state.widget.notification.orderStatus = status;
      state.resetState();
    }
  }
  
}

class NotificationOrderTravelState extends State<NotificationOrderTravelWidget>{

  static const double FIELD_NAME_WIDTH = 80;

  late _MyOrderTravelStatusListener _listener;

  @override
  void initState(){
    super.initState();
    _listener = _MyOrderTravelStatusListener(this);
    OrderStatusUtil().addTravelStatusListener(_listener);
  }

  @override
  void dispose(){
    OrderStatusUtil().removeTravelStatusListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ImNotificationOrderTravel notification = widget.notification;
    NotificationType? type;
    if(notification.type != null){
      type = NotificationTypeExt.getType(notification.type!);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            type == NotificationType.orderReceived ?
            const Text('新订单消息', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),) :
            const Text('订单取消', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
            notification.checked != true ?
            const Text('NEW', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),): 
            const SizedBox()
          ],
        ),
        if(notification.createTime != null)
        Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(notification.createTime!,), style: const TextStyle(color: ThemeUtil.foregroundColor),),
        const SizedBox(height: 8,),
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(text: '用户', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
              TextSpan(
                text: '${notification.customerName}',
                style: const TextStyle(color: Colors.lightBlue, fontSize: 16),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async{
                    if(notification.customerId == null){
                      return;
                    }
                    ImSingleRoom? room = await ChatUtilSingle.enterRoom(notification.customerId!);
                    if(room == null){
                      return;
                    }
                    if(mounted && context.mounted){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context){
                        return ChatRoomPage(room: room);
                      }));
                    }
                  }
              ),
              const TextSpan(text: '在', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
              TextSpan(
                text: '${notification.travelName}',
                style: const TextStyle(color: Colors.lightBlue, fontSize: 16),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async{
                    if(notification.travelId == null){
                      ToastUtil.error('数据错误');
                      return;
                    }
                    Travel? travel = await TravelApi().getById(travelId: notification.travelId!);
                    if(travel == null){
                      ToastUtil.error('目标不存在');
                      return;
                    }
                    if(mounted && context.mounted){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context){
                        return TravelDetailPage(travel);
                      }));
                    }
                  }
              ),
              type == NotificationType.orderReceived ?
              const TextSpan(text: '中预订了旅游项目', style: TextStyle(color: ThemeUtil.foregroundColor)) :
              const TextSpan(text: '取消了旅游项目', style: TextStyle(color: ThemeUtil.foregroundColor))

            ]
          ),
        ),
        const Divider(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: FIELD_NAME_WIDTH,
              child: Text('旅游套餐', style: TextStyle(color: ThemeUtil.foregroundColor),),
            ),
            Expanded(
              child: Text('${notification.travelSuitName}', style: const TextStyle(color: ThemeUtil.foregroundColor),),
            )
          ],
        ),
        const SizedBox(height: 8,),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: FIELD_NAME_WIDTH,
              child: Text('旅游人数', style: TextStyle(color: ThemeUtil.foregroundColor),),
            ),
            Expanded(
              child: Text('${(notification.number ?? 0) + (notification.oldNumber ?? 0) + (notification.childNumber ?? 0)} 人', style: const TextStyle(color: ThemeUtil.foregroundColor),),
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: FIELD_NAME_WIDTH,
                child: Text('旅游时间', style: TextStyle(color: ThemeUtil.foregroundColor),),
              ),
              Expanded(
                child: Row(
                  children: [
                    Text(DateFormat('yyyy年MM月dd日').format(notification.startDate!), style: const TextStyle(color: ThemeUtil.foregroundColor),),
                    const Text(' - ', style: TextStyle(color: Colors.grey),),
                    Text(DateFormat('yyyy年MM月dd日').format(notification.endDate!), style: const TextStyle(color: ThemeUtil.foregroundColor),)
                  ],
                ),
              )
            ],
          ),
        ),
        getPayStatusWidget(),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              style: TextButton.styleFrom( 
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap
              ),
              onPressed: toDetail,
              child: const Padding(
                padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
                child: Text('查看详情', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold),),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap
              ),
              onPressed: toDetail,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.arrow_forward_ios_rounded, color: ThemeUtil.foregroundColor,),
              ),
            )
          ],
        )
      ],
    );
  }

  Future toDetail() async{
    ImNotificationOrderTravel notification = widget.notification;
    if(notification.linkedId == null){
      ToastUtil.error('数据错误');
      return;
    }
    OrderTravel? order = await OrderMerchantHttp().getOrderTravel(orderId: notification.linkedId!);
    if(order == null){
      ToastUtil.error('目标不存在');
      return;
    }
    if(context.mounted){
      Navigator.of(context).push(MaterialPageRoute(builder: (context){
        return OrderMerchantTravelPage(nid: notification.id, order: order,);
      }));
    }
    notification.checked = true;
    if(notification.id != null){
      ChatNotificationStorage.updateOrderChecked(notification.id!, ProductType.travel, 1);
    }
    setState(() {
    });
  }

  Widget getPayStatusWidget(){
    ImNotificationOrderTravel notification = widget.notification;
    if(notification.orderStatus == null){
      return const SizedBox();
    }
    OrderTravelStatus? status = OrderTravelStatusExt.getStatus(notification.orderStatus!);
    if(status == null){
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          const SizedBox(
            width: FIELD_NAME_WIDTH,
            child: Text('订单状态', style: TextStyle(color: ThemeUtil.foregroundColor),),
          ),
          Text(MyOrderTravelStatusExt(status).getText(), style: TextStyle(color: MyOrderTravelStatusExt(status).getColor()),)
        ],
      ),
    );
  }

  void resetState(){
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }
}
