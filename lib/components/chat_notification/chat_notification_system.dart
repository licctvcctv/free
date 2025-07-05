
import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/chat_neo/chat_socket.dart';
import 'package:freego_flutter/components/chat_notification/chat_notification_common.dart';
import 'package:freego_flutter/components/chat_notification/chat_notification_storage.dart';
import 'package:freego_flutter/components/chat_notification/chat_notification_util.dart';
import 'package:freego_flutter/components/chat_notification/chat_notification_visitor.dart';
import 'package:freego_flutter/components/chat_notification_neo/model/im_notification_order_hotel_state.dart';
import 'package:freego_flutter/components/chat_notification_neo/model/im_notification_order_restaurant_state.dart';
import 'package:freego_flutter/components/chat_notification_neo/model/im_notification_order_scenic_state.dart';
import 'package:freego_flutter/components/chat_notification_neo/model/im_notification_order_travel_state.dart';
import 'package:freego_flutter/components/chat_notification_neo/parser/im_notification_parser.dart';
import 'package:freego_flutter/components/hotel_neo/api/hotel_api.dart';
import 'package:freego_flutter/components/hotel_neo/hotel_common.dart';
import 'package:freego_flutter/components/hotel_neo/hotel_home_freego.dart';
import 'package:freego_flutter/components/merchent/merchant_api.dart';
import 'package:freego_flutter/components/merchent/merchant_model.dart';
import 'package:freego_flutter/components/merchent/merchant_show.dart';
import 'package:freego_flutter/components/order_neo/api/order_neo_api.dart';
import 'package:freego_flutter/components/order_neo/order_common.dart';
import 'package:freego_flutter/components/order_neo/order_hotel_detail.dart';
import 'package:freego_flutter/components/order_neo/order_restaurant_detail.dart';
import 'package:freego_flutter/components/order_neo/order_scenic_detail.dart';
import 'package:freego_flutter/components/order_neo/order_travel_detail.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/components/restaurant/restaurant_api.dart';
import 'package:freego_flutter/components/restaurant/restaurant_common.dart';
import 'package:freego_flutter/components/restaurant/restaurant_home.dart';
import 'package:freego_flutter/components/scenic/api/scenic_api.dart';
import 'package:freego_flutter/components/scenic/scenic_common.dart';
import 'package:freego_flutter/components/scenic/scenic_home_freego.dart';
import 'package:freego_flutter/components/travel/travel_api.dart';
import 'package:freego_flutter/components/travel/travel_common.dart';
import 'package:freego_flutter/components/travel/travel_detail.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/custom_indicator.dart';
import 'package:freego_flutter/model/cash.dart';
import 'package:freego_flutter/util/order_redirector.dart';
import 'package:freego_flutter/util/product_redirector.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:freego_flutter/util/user_home_director.dart';
import 'package:intl/intl.dart';

class ChatNotificationSystemPage extends StatelessWidget{

  final ImNotificationRoom room;
  const ChatNotificationSystemPage({required this.room, super.key});

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
      body: ChatNotificationSystemWidget(room: room),
    );
  }
  
}

class ChatNotificationSystemWidget extends StatefulWidget{
  final ImNotificationRoom room;
  const ChatNotificationSystemWidget({required this.room, super.key});

  @override
  State<StatefulWidget> createState() {
    return ChatNotificationSystemState();
  }
  
}

class _MyMessageHandler extends ChatMessageHandler{
  
  final ChatNotificationSystemState state;
  _MyMessageHandler(this.state) :super(priority: 10);
  
  @override
  Future handle(MessageObject rawObj) async{
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

  final ChatNotificationSystemState _state;
  _MyReconnectHandler(this._state) :super(priority: 99);
  
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

class ChatNotificationSystemState extends State<ChatNotificationSystemWidget>{

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
            center: Text('系统消息', style: TextStyle(color: Colors.white, fontSize: 18),),
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
    List<ImNotification> list = await ChatNotificationUtil().getHistory(roomId: roomId, maxId: maxId);
    if(list.isEmpty){
      ToastUtil.hint('已经没有了呢');
      return;
    }
    List<ImNotification> newList = [];
    for(ImNotification notification in list){
      ImNotification? tmp = ImNotificationParser().parse(notification);
      if(tmp == null){
        newList.add(notification);
      }
      else{
        newList.add(tmp);
      }
    }
    notificationList.addAll(newList);
    bottomBuffer = getNotificationWidgets(newList);
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
    if(notification is ImNotificationSystemOrderStateChange){
      return NotificationWrapper(
        NotificationSystemOrderStateChangeWidget(notification: notification,),
        key: ValueKey(notification.id),
      );
    }
    else if(notification is ImNotificationSystemTipoffConfirmed){
      return NotificationWrapper(
        NotificationSystemTipoffConfirmedWidget(notification: notification,),
        key: ValueKey(notification.id),
      );
    }
    else if(notification is ImNotificationSystemProductWarned){
      return NotificationWrapper(
        NotificationSystemProductWarnedWidget(notification: notification,),
        key: ValueKey(notification.id),
      );
    }
    else if(notification is ImNotificationSystemGetReward){
      return NotificationWrapper(
        NotificationSystemGetRewardWidget(notification: notification,),
        key: ValueKey(notification.id),
      );
    }
    else if(notification is ImNotificationSystemCashWithdrawResult){
      return NotificationWrapper(
        NotificationSystemCashWithdrawResultWidget(notification: notification,),
        key: ValueKey(notification.id),
      );
    }
    else if(notification is ImNotificationSystemMerchantApplyResult){
      return NotificationWrapper(
        NotificationSystemMerchantApplyResultWidget(notification: notification,),
        key: ValueKey(notification.id),
      );
    }
    return null;
  }

  @override
  Widget? visitScenicOrderState(ImNotificationOrderScenicState notification) {
    return NotificationWrapper(
      NotificationSystemScenicOrderState(notification: notification),
      key: ValueKey(notification.id),
    );
  }

  @override
  Widget? visitHotelOrderState(ImNotificationOrderHotelState notification) {
    return NotificationWrapper(
      NotificationSystemHotelOrderState(notification: notification),
      key: ValueKey(notification.id)
    );
  }

  @override
  Widget? visitRestaurantOrderState(ImNotificationOrderRestaurantState notification){
    return NotificationWrapper(
      NotificationSystemRestaurantOrderState(notification: notification,),
      key: ValueKey(notification.id),
    );
  }

  @override
  Widget? visitTravelOrderState(ImNotificationOrderTravelState notification){
    return NotificationWrapper(
      NotificationSystemTravelOrderState(notification: notification),
      key: ValueKey(notification.id),
    );
  }
}

class NotificationSystemProductWarnedWidget extends StatelessWidget{
  
  final ImNotificationSystemProductWarned notification;
  const NotificationSystemProductWarnedWidget({required this.notification, super.key});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('收到警告', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
        if(notification.createTime != null)
        Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(notification.createTime!), style: const TextStyle(color: ThemeUtil.foregroundColor),),
        const Divider(),
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(text: '您发布的', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
              TextSpan(
                text: notification.productName,
                style: const TextStyle(color: Colors.lightBlue, fontSize: 16),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async{
                    if(notification.productType == null || notification.productId == null){
                      return;
                    }
                    ProductType? type = ProductTypeExt.getType(notification.productType!);
                    if(type == null){
                      return;
                    }
                    ProductRedirector().redirect(productId: notification.productId!, type: type, context: context);
                  }
              ),
              const TextSpan(text: '中存在违规内容', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
            ]
          ),
        ),
        const SizedBox(height: 12,),
        const Text('请自觉遵守社区规范，共同维护Freego的氛围', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),)
      ],
    );
  }

}

class NotificationSystemTravelOrderState extends StatelessWidget{

  final ImNotificationOrderTravelState notification;

  const NotificationSystemTravelOrderState({required this.notification, super.key});

  @override
  Widget build(BuildContext context) {
    Widget? timeWidget = getTimeWidget();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getTitle(),
        if(timeWidget != null)
        timeWidget,
        const Divider(),
        getContent(context),
        const Divider(),
        getDetail(context)
      ],
    );
  }
  
  Future toDetail(BuildContext context) async{
    if(notification.orderId == null){
      return;
    }
    OrderTravel? order = await OrderNeoApi().getOrderTravel(id: notification.orderId!);
    if(order != null){
      if(context.mounted){
        Navigator.of(context).push(MaterialPageRoute(builder: (context){
          return OrderTravelDetailPage(order);
        }));
      }
    }
  }

  Widget getDetail(BuildContext context){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap
          ),
          onPressed: () async{
            toDetail(context);
          },
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
          onPressed: (){
            toDetail(context);
          },
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(Icons.arrow_forward_ios_rounded, color: ThemeUtil.foregroundColor,),
          ),
        )
      ],
    );
  }

  Widget getContent(BuildContext context){
    OrderScenicStatus? orderStatus;
    if(notification.orderStatus != null){
      orderStatus = OrderScenicStatusExt.getStatus(notification.orderStatus!);
    }
    return RichText(
      text: TextSpan(
        children: [
          const TextSpan(text: '您预订的', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
          TextSpan(
            text: notification.travelName,
            style: const TextStyle(color: Colors.lightBlue, fontSize: 16),
            recognizer: TapGestureRecognizer()
              ..onTap = () async{
                if(notification.travelId == null){
                  return;
                }
                Travel? travel = await TravelApi().getById(travelId: notification.travelId!);
                if(travel != null){
                  if(context.mounted){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context){
                      return TravelDetailPage(travel);
                    }));
                  }
                }
              }
          ),
          TextSpan(
            text: '(${notification.travelSuitName})',
            style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)
          ),
          TextSpan(
            text: orderStatus?.getText() ?? '异常', 
            style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),
          )
        ],
      ),
    );
  }

  Widget getTitle(){
    OrderTravelStatus? orderStatus;
    if(notification.orderStatus != null){
      orderStatus = OrderTravelStatusExt.getStatus(notification.orderStatus!);
    }
    return Text('订单${orderStatus?.getText() ?? ''}', style: TextStyle(color: orderStatus?.getColor() ?? Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 18),);
  }

  Widget? getTimeWidget(){
    if(notification.createTime != null){
      return Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(notification.createTime!,), style: const TextStyle(color: ThemeUtil.foregroundColor),);
    }
    return null;
  }
}

class NotificationSystemRestaurantOrderState extends StatelessWidget{

  final ImNotificationOrderRestaurantState notification;

  const NotificationSystemRestaurantOrderState({required this.notification, super.key});
  
  @override
  Widget build(BuildContext context) {
    Widget? timeWidget = getTimeWidget();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getTitle(),
        if(timeWidget != null)
        timeWidget,
        const Divider(),
        getContent(context),
        const Divider(),
        getDetail(context)
      ],
    );
  }

  Future toDetail(BuildContext context) async{
    if(notification.orderId == null){
      return;
    }
    OrderRestaurant? order = await OrderNeoApi().getOrderRestaurant(id: notification.orderId!);
    if(order != null){
      if(context.mounted){
        Navigator.of(context).push(MaterialPageRoute(builder: (context){
          return OrderRestaurantDetailPage(order);
        }));
      }
    }
  }

  Widget getDetail(BuildContext context){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap
          ),
          onPressed: () async{
            toDetail(context);
          },
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
          onPressed: (){
            toDetail(context);
          },
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(Icons.arrow_forward_ios_rounded, color: ThemeUtil.foregroundColor,),
          ),
        )
      ],
    );
  }

  Widget getContent(BuildContext context){
    OrderScenicStatus? orderStatus;
    if(notification.orderStatus != null){
      orderStatus = OrderScenicStatusExt.getStatus(notification.orderStatus!);
    }
    return RichText(
      text: TextSpan(
        children: [
          const TextSpan(text: '您在', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
          TextSpan(
            text: notification.restaurantName,
            style: const TextStyle(color: Colors.lightBlue, fontSize: 16),
            recognizer: TapGestureRecognizer()
              ..onTap = () async{
                if(notification.restaurantId == null){
                  return;
                }
                Restaurant? restaurant = await RestaurantApi().getById(notification.restaurantId!);
                if(restaurant != null){
                  if(context.mounted){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context){
                      return RestaurantHomePage(restaurant);
                    }));
                  }
                }
              }
          ),
          if(notification.diningTime != null)
          TextSpan(
            text: '(${DateFormat('yyyy年MM月dd日 HH时mm分').format(notification.diningTime!)})',
            style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)
          ),
          TextSpan(
            text: orderStatus?.getText() ?? '异常', 
            style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),
          )
        ],
      ),
    );
  }

  Widget getTitle(){
    OrderScenicStatus? orderStatus;
    if(notification.orderStatus != null){
      orderStatus = OrderScenicStatusExt.getStatus(notification.orderStatus!);
    }
    return Text('订单${orderStatus?.getText() ?? ''}', style: TextStyle(color: orderStatus?.getColor() ?? Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 18),);
  }

  Widget? getTimeWidget(){
    if(notification.createTime != null){
      return Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(notification.createTime!,), style: const TextStyle(color: ThemeUtil.foregroundColor),);
    }
    return null;
  }
}

class NotificationSystemScenicOrderState extends StatelessWidget{

  final ImNotificationOrderScenicState notification;
  const NotificationSystemScenicOrderState({required this.notification, super.key});

  @override
  Widget build(BuildContext context) {
    Widget? timeWidget = getTimeWidget();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getTitle(),
        if(timeWidget != null)
        timeWidget,
        const Divider(),
        getContent(context),
        const Divider(),
        getDetail(context)
      ],
    );
  } 

  Future toDetail(BuildContext context) async{
    if(notification.orderId == null){
      return;
    }
    OrderScenic? order = await OrderNeoApi().getOrderScenic(id: notification.orderId!);
    if(order != null){
      if(context.mounted){
        Navigator.of(context).push(MaterialPageRoute(builder: (context){
          return OrderScenicDetailPage(order);
        }));
      }
    }
  }

  Widget getDetail(BuildContext context){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap
          ),
          onPressed: () async{
            toDetail(context);
          },
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
          onPressed: (){
            toDetail(context);
          },
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(Icons.arrow_forward_ios_rounded, color: ThemeUtil.foregroundColor,),
          ),
        )
      ],
    );
  }

  Widget getContent(BuildContext context){
    OrderScenicStatus? orderStatus;
    if(notification.orderStatus != null){
      orderStatus = OrderScenicStatusExt.getStatus(notification.orderStatus!);
    }
    return RichText(
      text: TextSpan(
        children: [
          const TextSpan(text: '您在', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
          TextSpan(
            text: notification.scenicName,
            style: const TextStyle(color: Colors.lightBlue, fontSize: 16),
            recognizer: TapGestureRecognizer()
              ..onTap = () async{
                Scenic? scenic = await ScenicApi().detail(id: notification.scenicId, outerId: notification.outerScenicId, source: notification.outerTicketId);
                if(scenic != null){
                  if(context.mounted){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context){
                      return ScenicHomePage(scenic);
                    }));
                  }
                }
              }
          ),
          const TextSpan(text: '中购买的门票', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
          TextSpan(
            text: notification.ticketName,
            style: const TextStyle(color: Colors.lightBlue, fontSize: 16),
          ),
          if(notification.travelDate != null)
          TextSpan(
            text: '(${DateFormat('yyyy年MM月dd日').format(notification.travelDate!)})',
            style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)
          ),
          TextSpan(
            text: orderStatus?.getText() ?? '异常', 
            style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),
          )
        ],
      ),
    );
  }

  Widget getTitle(){
    OrderScenicStatus? orderStatus;
    if(notification.orderStatus != null){
      orderStatus = OrderScenicStatusExt.getStatus(notification.orderStatus!);
    }
    return Text('订单${orderStatus?.getText() ?? ''}', style: TextStyle(color: orderStatus?.getColor() ?? Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 18),);
  }

  Widget? getTimeWidget(){
    if(notification.createTime != null){
      return Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(notification.createTime!,), style: const TextStyle(color: ThemeUtil.foregroundColor),);
    }
    return null;
  }
}

class NotificationSystemHotelOrderState extends StatelessWidget{

  final ImNotificationOrderHotelState notification;
  const NotificationSystemHotelOrderState({required this.notification, super.key});
  
  @override
  Widget build(BuildContext context) {
    Widget? timeWidget = getTimeWidget();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getTitle(),
        if(timeWidget != null)
        timeWidget,
        const Divider(),
        getContent(context),
        const Divider(),
        getDetail(context)
      ],
    );
  } 

  Future toDetail(BuildContext context) async{
    if(notification.orderId == null){
      return;
    }
    OrderHotel? order = await OrderNeoApi().getOrderHotel(id: notification.orderId!);
    if(order != null){
      if(context.mounted){
        Navigator.of(context).push(MaterialPageRoute(builder: (context){
          return OrderHotelDetailPage(order);
        }));
      }
    }
  }

  Widget getDetail(BuildContext context){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap
          ),
          onPressed: () async{
            toDetail(context);
          },
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
          onPressed: (){
            toDetail(context);
          },
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(Icons.arrow_forward_ios_rounded, color: ThemeUtil.foregroundColor,),
          ),
        )
      ],
    );
  }

  Widget getContent(BuildContext context){
    OrderHotelStatus? orderStatus;
    if(notification.orderStatus != null){
      orderStatus = OrderHotelStatusExt.getStatus(notification.orderStatus!);
    }
    return RichText(
      text: TextSpan(
        children: [
          const TextSpan(text: '您在', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
          TextSpan(
            text: notification.hotelName,
            style: const TextStyle(color: Colors.lightBlue, fontSize: 16),
            recognizer: TapGestureRecognizer()
              ..onTap = () async{
                Hotel? hotel = await HotelApi().detail(id: notification.hotelId, outerId: notification.outerHotelId, source: notification.source);
                if(hotel != null){
                  if(context.mounted){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context){
                      return HotelHomePage(hotel);
                    }));
                  }
                }
              }
          ),
          const TextSpan(text: '中预订的房间', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
          TextSpan(
            text: notification.ratePlanName,
            style: const TextStyle(color: Colors.lightBlue, fontSize: 16),
          ),
          if(notification.checkInDate != null)
          TextSpan(
            children: [
              const TextSpan(text: '(', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
              TextSpan(
                text: DateFormat('yyyy年MM月dd日').format(notification.checkInDate!), 
                style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)
              ),
              if(notification.checkOutDate != null && notification.checkOutDate!.isAfter(notification.checkOutDate!))
              TextSpan(
                text: ' - ${DateFormat('yyyy年MM月dd日').format(notification.checkOutDate!)}',
                style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)
              ),
              const TextSpan(text: ')', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16))
            ]
          ),
          TextSpan(
            text: orderStatus?.getText() ?? '异常', 
            style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),
          )
        ],
      ),
    );
  }

  Widget getTitle(){
    OrderHotelStatus? orderStatus;
    if(notification.orderStatus != null){
      orderStatus = OrderHotelStatusExt.getStatus(notification.orderStatus!);
    }
    return Text('订单${orderStatus?.getText() ?? ''}', style: TextStyle(color: orderStatus?.getColor() ?? Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 18),);
  }

  Widget? getTimeWidget(){
    if(notification.createTime != null){
      return Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(notification.createTime!,), style: const TextStyle(color: ThemeUtil.foregroundColor),);
    }
    return null;
  }

}

class NotificationSystemOrderStateChangeWidget extends StatelessWidget{

  final ImNotificationSystemOrderStateChange notification;
  const NotificationSystemOrderStateChangeWidget({required this.notification, super.key});

  @override
  Widget build(BuildContext context) {
    NotificationType? type;
    if(notification.type != null){
      type = NotificationTypeExt.getType(notification.type!);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        type == NotificationType.systemOrderSuccess ?
        const Text('下单成功', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),) :
        type == NotificationType.systemOrderFail ?
        const Text('订单失败', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),) :
        type == NotificationType.systemOrderConfirmed ?
        const Text('订单已确认', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),) :
        type == NotificationType.systemOrderCompleted ?
        const Text('订单已完成', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),) :
        const SizedBox(),
        if(notification.createTime != null)
        Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(notification.createTime!,), style: const TextStyle(color: ThemeUtil.foregroundColor),),
        const Divider(),
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(text: '您在', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
              TextSpan(
                text: notification.productName,
                style: const TextStyle(color: Colors.lightBlue, fontSize: 16),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async{
                    if(notification.productType == null || notification.productId == null){
                      return;
                    }
                    ProductType? type = ProductTypeExt.getType(notification.productType!);
                    if(type == null){
                      return;
                    }
                    ProductRedirector().redirect(productId: notification.productId!, type: type, context: context);
                  }
              ),
              const TextSpan(text: '中预订的', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
              if (notification.productType != null && notification.productType == ProductType.restaurant.getNum())
                const TextSpan(
                  text: '用餐',
                  style: TextStyle(color: Colors.lightBlue, fontSize: 16),
                )
              else
                TextSpan(
                  text: notification.subName,
                  style: const TextStyle(color: Colors.lightBlue, fontSize: 16),
                ),
              /*TextSpan(
                text: notification.subName,
                style: const TextStyle(color: Colors.lightBlue, fontSize: 16)
              ),*/
              if(notification.startDate != null)
              TextSpan(
                children: [
                  const TextSpan(text: '(', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
                  TextSpan(
                    text: DateFormat('yyyy年MM月dd日').format(notification.startDate!), 
                    style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)
                  ),
                  if(notification.endDate != null && notification.endDate!.isAfter(notification.startDate!))
                  TextSpan(
                    text: ' - ${DateFormat('yyyy年MM月dd日').format(notification.endDate!)}',
                    style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)
                  ),
                  const TextSpan(text: ')', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16))
                ]
              ),
              type == NotificationType.systemOrderSuccess ?
              const TextSpan(text: '已下单成功', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)) :
              type == NotificationType.systemOrderFail ?
              const TextSpan(text: '下单失败', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)) :
              type == NotificationType.systemOrderConfirmed ?
              const TextSpan(text: '已被确认', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)) :
              type == NotificationType.systemOrderCompleted ?
              const TextSpan(text: '订单已完成，收入已转入个人账户', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)) :
              const TextSpan(text: '')
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
              onPressed: (){
                toDetail(context);
              },
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
              onPressed: (){
                toDetail(context);
              },
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
  
  Future toDetail(BuildContext context) async{
    if(notification.linkedId == null){
      return;
    }
    ProductType? type;
    if(notification.productType != null){
      type = ProductTypeExt.getType(notification.productType!);
    }
    if(type == null){
      return;
    }
    try{
      OrderRedirector().redirect(notification.linkedId!, type, context);
    }
    catch (e){
      if(e is OrderNotFoundException){
        ToastUtil.error('目标已失效');
      }
      else if(e is UnsupportedTypeException){
        ToastUtil.error('类型错误');
      }
    }
  }
}

class NotificationSystemGetRewardWidget extends StatelessWidget{

  final ImNotificationSystemGetReward notification;
  const NotificationSystemGetRewardWidget({required this.notification, super.key});
  
  @override
  Widget build(BuildContext context) {
    String? productTypeName = getProductTypeName();
    String? amountStr = StringUtil.getPriceStr(notification.amount);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('收到打赏', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
        if(notification.createTime != null)
        Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(notification.createTime!,), style: const TextStyle(color: ThemeUtil.foregroundColor),),
        const Divider(),
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(text: '您的', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
              if(productTypeName != null)
              TextSpan(text: productTypeName, style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
              TextSpan(
                text: notification.productName,
                style: const TextStyle(color: Colors.lightBlue, fontSize: 16),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async{
                    if(notification.productType == null || notification.productId == null){
                      return;
                    }
                    ProductType? type = ProductTypeExt.getType(notification.productType!);
                    if(type == null){
                      return;
                    }
                    ProductRedirector().redirect(productId: notification.productId!, type: type, context: context);
                  }
              ),
              const TextSpan(text: '收到了用户', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
              TextSpan(
                text: notification.userName,
                style: const TextStyle(color: Colors.lightBlue, fontSize: 16),
                recognizer: TapGestureRecognizer()
                  ..onTap = (){
                    if(notification.userId == null){
                      return;
                    }
                    UserHomeDirector().goUserHome(context: context, userId: notification.userId!);
                  }
              ),
              const TextSpan(text: '的打赏。', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
            ]
          ),
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('收入', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
            Text('${amountStr ?? ''}元', style: const TextStyle(color: Colors.lightBlue, fontSize: 16),)
          ],
        )
      ],
    );
  }
  
  String? getProductTypeName(){
    if(notification.productType == null){
      return null;
    }
    ProductType? type = ProductTypeExt.getType(notification.productType!);
    switch(type){
      case ProductType.guide:
        return '攻略';
      default:
    }
    return null;
  }
}

class NotificationSystemTipoffConfirmedWidget extends StatelessWidget{

  final ImNotificationSystemTipoffConfirmed notification;
  const NotificationSystemTipoffConfirmedWidget({required this.notification, super.key});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('举报成功', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
        if(notification.createTime != null)
        Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(notification.createTime!), style: const TextStyle(color: ThemeUtil.foregroundColor),),
        const Divider(),
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(text: '您举报的', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
              TextSpan(
                text: notification.productName,
                style: const TextStyle(color: Colors.lightBlue, fontSize: 16),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async{
                    if(notification.productType == null || notification.productId == null){
                      return;
                    }
                    ProductType? type = ProductTypeExt.getType(notification.productType!);
                    if(type == null){
                      return;
                    }
                    ProductRedirector().redirect(productId: notification.productId!, type: type, context: context);
                  }
              ),
              const TextSpan(text: '已被受理', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
            ]
          ),
        ),
        const SizedBox(height: 12,),
        const Text('感谢您维护了freego社区的氛围', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),)
      ],
    );
  }
  
}

class NotificationSystemCashWithdrawResultWidget extends StatelessWidget{

  static const double FIELD_NAME_WIDTH = 80;

  final ImNotificationSystemCashWithdrawResult notification;
  const NotificationSystemCashWithdrawResultWidget({required this.notification, super.key});
  
  @override
  Widget build(BuildContext context) {
    CashWithdrawStatus? status;
    if(notification.status != null){
      status = CashWithdrawStatusExt.getType(notification.status!);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        status == CashWithdrawStatus.success ?
        const Text('提现成功', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),) :
        const Text('提现失败', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
        if(notification.createTime != null)
        Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(notification.createTime!), style: const TextStyle(color: ThemeUtil.foregroundColor),),
        const Divider(),
        Row(
          children: [
            const SizedBox(
              width: FIELD_NAME_WIDTH,
              child: Text('提现金额', style: TextStyle(color: ThemeUtil.foregroundColor),),
            ),
            Expanded(
              child: Text(StringUtil.getPriceStr(notification.amount) ?? '', style: const TextStyle(color: Colors.lightBlue),),
            )
          ],
        ),
        const SizedBox(height: 8,),
        Row(
          children: [
            const SizedBox(
              width: FIELD_NAME_WIDTH,
              child: Text('目标银行', style: TextStyle(color: ThemeUtil.foregroundColor),),
            ),
            Expanded(
              child: Text(notification.bankName ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor),),
            )
          ],
        ),
        const SizedBox(height: 8,),
        Row(
          children: [
            const SizedBox(
              width: FIELD_NAME_WIDTH,
              child: Text('真实姓名', style: TextStyle(color: ThemeUtil.foregroundColor),),
            ),
            Expanded(
              child: Text(notification.realName ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor),),
            )
          ],
        ),
        const SizedBox(height: 8,),
        Row(
          children: [
            const SizedBox(
              width: FIELD_NAME_WIDTH,
              child: Text('银行卡号', style: TextStyle(color: ThemeUtil.foregroundColor),),
            ),
            Expanded(
              child: Text(notification.bankAccount ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor),),
            )
          ],
        ),
        const SizedBox(height: 8,),
        Row(
          children: [
            const SizedBox(
              width: FIELD_NAME_WIDTH,
              child: Text('处理结果', style: TextStyle(color: ThemeUtil.foregroundColor),),
            ),
            Expanded(
              child: status == CashWithdrawStatus.success ?
              const Text('成功', style: TextStyle(color: Colors.lightBlue),) :
              const Text('失败', style: TextStyle(color: Colors.grey),)
            )
          ],
        ),
        if(status == CashWithdrawStatus.rejected)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8,),
            Row(
              children: [
                const SizedBox(
                  width: FIELD_NAME_WIDTH,
                  child: Text('失败原因', style: TextStyle(color: ThemeUtil.foregroundColor),),
                ),
                Expanded(
                  child: Text(notification.refuseReason ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor),),
                )
              ],
            )
          ],
        )
      ],
    );
  }
}

class NotificationSystemMerchantApplyResultWidget extends StatelessWidget{

  static const double FIELD_NAME_WIDTH = 80;

  final ImNotificationSystemMerchantApplyResult notification;
  const NotificationSystemMerchantApplyResultWidget({required this.notification, super.key});

  @override
  Widget build(BuildContext context) {
    VerifyStatus? verifyStatus;
    BusinessType? businessType;
    if(notification.verifyStatus != null){
      verifyStatus = VerifyStatusExt.getStatus(notification.verifyStatus!);
    }
    if(notification.businessType != null){
      businessType = BusinessTypeExt.getType(notification.businessType!);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        verifyStatus == VerifyStatus.verified ?
        const Text('商家申请成功', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),) :
        const Text('商家申请失败', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
        if(notification.createTime != null)
        Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(notification.createTime!), style: const TextStyle(color: ThemeUtil.foregroundColor),),
        const Divider(),
        Row(
          children: [
            const SizedBox(
              width: FIELD_NAME_WIDTH,
              child: Text('店铺名称', style: TextStyle(color: ThemeUtil.foregroundColor),),
            ),
            Expanded(
              child: Text(notification.shopName ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor),),
            )
          ],
        ),
        const SizedBox(height: 8,),
        Row(
          children: [
            const SizedBox(
              width: FIELD_NAME_WIDTH,
              child: Text('店铺类型', style: TextStyle(color: ThemeUtil.foregroundColor),),
            ),
            Expanded(
              child: Text(getBusinessName(businessType) ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor),),
            )
          ],
        ),
        const SizedBox(height: 8,),
        Row(
          children: [
            const SizedBox(
              width: FIELD_NAME_WIDTH,
              child: Text('店铺地址', style: TextStyle(color: ThemeUtil.foregroundColor),),
            ),
            Expanded(
              child: Text(notification.address ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor),),
            )
          ],
        ),
        const SizedBox(height: 8,),
        Row(
          children: [
            const SizedBox(
              width: FIELD_NAME_WIDTH,
              child: Text('审核状态', style: TextStyle(color: ThemeUtil.foregroundColor),),
            ),
            Expanded(
              child: verifyStatus == VerifyStatus.verified ?
              const Text('审核成功', style: TextStyle(color: Colors.lightBlue),) :
              const Text('审核失败', style: TextStyle(color: Colors.grey),)
            )
          ],
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
              onPressed: (){
                toDetail(context);
              },
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
              onPressed: (){
                toDetail(context);
              },
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

  Future toDetail(BuildContext context) async{
    if(notification.linkedId != null){
      Merchant? merchant = await MerchantApi().getMerchant(id: notification.linkedId!);
      if(merchant == null){
        ToastUtil.error('目标不存在');
        return;
      }
      if(context.mounted){
        Navigator.of(context).push(MaterialPageRoute(builder: (context){
          return MerchantShowPage(merchant: merchant);
        }));
      }
    }
  }
  
  String? getBusinessName(BusinessType? type){
    if(type == null){
      return null;
    }
    switch(type){
      case BusinessType.hotel:
        return '酒店';
      case BusinessType.restaurant:
        return '美食';
      case BusinessType.scenic:
        return '景点';
      case BusinessType.travelAgency:
        return '旅行社';
      case BusinessType.other:
        return '其他';
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
