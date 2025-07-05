
import 'package:freego_flutter/components/chat_notification/chat_notification_storage.dart';
import 'package:freego_flutter/components/chat_notification/chat_notification_visitor.dart';

class ImNotification{
  int? id;
  int? roomId;
  int? type;
  int? subType;
  int? linkedId;
  String? innerContent;
  DateTime? createTime;

  bool? checked;
  ImNotification();
  void clone(ImNotification origin){
    id = origin.id;
    roomId = origin.roomId;
    type = origin.type;
    subType = origin.subType;
    linkedId = origin.linkedId;
    innerContent = origin.innerContent;
    createTime = origin.createTime;
    checked = origin.checked;
  }
  ImNotification.fromJson(dynamic json){
    id = json['id'];
    roomId = json['roomId'];
    type = json['type'];
    subType = json['subType'];
    linkedId = json['linkedId'];
    innerContent = json['innerContent'];
    if(json['createTime'] is String){
      createTime = DateTime.tryParse(json['createTime']);
    }
    checked = json['checked'];
  }
  Map<String, Object?> toSqlMap(){
    Map<String, Object?> map = {};
    map['id'] = id;
    map['room_id'] = roomId;
    map['type'] = type;
    map['sub_type'] = subType;
    map['linked_id'] = linkedId;
    map['inner_content'] = innerContent;
    map['create_time'] = createTime?.millisecondsSinceEpoch;
    map['checked'] = checked == true ? 1 : 0;
    return map;
  }
  ImNotification.fromSqlMap(dynamic map){
    id = map['id'];
    roomId = map['room_id'];
    type = map['type'];
    subType = map['sub_type'];
    linkedId = map['linked_id'];
    innerContent = map['inner_content'];
    if(map['create_time'] is int){
      createTime = DateTime.fromMillisecondsSinceEpoch(map['create_time']);
    }
    checked = map['checked'] == 1;
  }

  ImNotificationAdapter? getAdapter(){
    return ImNotificationAdapter.instance;
  }

  T? visitBy<T>(ChatNotificationVisitor<T> visitor){
    return visitor.visit(this);
  }

}

class ImNotificationRoom{
  int? id;
  int? ownnerId;
  int? type;
  int? lastMessageId;
  DateTime? lastMessageTime;
  int? lastSendId;
  int? unreadNum;
  DateTime? createTime;
  ImNotificationRoom.fromJson(dynamic json){
    id = json['id'];
    ownnerId = json['ownnerId'];
    type = json['type'];
    lastMessageId = json['lastMessageId'];
    if(json['lastMessageTime'] is String){
      lastMessageTime = DateTime.tryParse(json['lastMessageTime']);
    }
    lastSendId = json['lastSendId'];
    unreadNum = json['unreadNum'];
    if(json['createTime'] != null){
      createTime = DateTime.tryParse(json['createTime']);
    }
  }
  ImNotificationRoom.fromSqlMap(dynamic map){
    id = map['id'];
    ownnerId = map['ownner_id'];
    type = map['type'];
    lastMessageId = map['last_message_id'];
    if(map['last_message_time'] is int){
      lastMessageTime = DateTime.fromMillisecondsSinceEpoch(map['last_message_time']);
    }
    lastSendId = map['last_send_id'];
    unreadNum = map['unread_num'];
    if(map['create_time'] is int){
      createTime = DateTime.fromMillisecondsSinceEpoch(map['create_time']);
    }
  }
  Map<String, Object?> toSqlMap(){
    Map<String, Object?> map = {};
    map['id'] = id;
    map['ownner_id'] = ownnerId;
    map['type'] = type;
    map['last_message_id'] = lastMessageId;
    map['last_message_time'] = lastMessageTime?.millisecondsSinceEpoch;
    map['last_send_id'] = lastSendId;
    map['unread_num'] = unreadNum;
    map['create_time'] = createTime?.millisecondsSinceEpoch;
    return map;
  }
}

enum NotificationRoomType{
  interact,
  order,
  system
}

extension NotificationRoomTypeExt on NotificationRoomType{
  int getNum(){
    switch(this){
      case NotificationRoomType.interact:
        return 1;
      case NotificationRoomType.order:
        return 2;
      case NotificationRoomType.system:
        return 3;
    }
  }
  static NotificationRoomType? getType(int num){
    for(NotificationRoomType type in NotificationRoomType.values){
      if(type.getNum() == num){
        return type;
      }
    }
    return null;
  }
}

enum NotificationType{
  interactFriendApply,
  interactProductLiked,
  interactProductLikedMonument,
  interactProductCommented,
  interactCommentCommented,
  interactCommentSubCommented,
  interactCommentLiked,
  interactCommentSubLiked,
  interactGroupInvited,
  interactCircleActivityApplied,
  orderReceived,
  orderRetracted,
  systemOrderSuccess,
  systemOrderFail,
  systemOrderConfirmed,
  systemOrderCompleted,
  systemGetReward,
  systemTipoffConfirmed,
  systemTipoffWarned,
  systemCashwithdrawResult,
  systemMerchantApplyResult
}

extension NotificationTypeExt on NotificationType{
  int getNum(){
    switch(this){
      case NotificationType.interactFriendApply:
        return 1;
      case NotificationType.interactProductLiked:
        return 2;
      case NotificationType.interactProductLikedMonument:
        return 3;
      case NotificationType.interactProductCommented:
        return 4;
      case NotificationType.interactCommentCommented:
        return 5;
      case NotificationType.interactCommentSubCommented:
        return 6;
      case NotificationType.interactCommentLiked:
        return 7;
      case NotificationType.interactCommentSubLiked:
        return 8;
      case NotificationType.interactGroupInvited:
        return 21;
      case NotificationType.interactCircleActivityApplied:
        return 41;
      case NotificationType.orderReceived:
        return 101;
      case NotificationType.orderRetracted:
        return 102;
      case NotificationType.systemOrderSuccess:
        return 201;
      case NotificationType.systemOrderFail:
        return 202;
      case NotificationType.systemOrderConfirmed:
        return 203;
      case NotificationType.systemOrderCompleted:
        return 204;
      case NotificationType.systemGetReward:
        return 211;
      case NotificationType.systemTipoffConfirmed:
        return 221;
      case NotificationType.systemTipoffWarned:
        return 222;
      case NotificationType.systemCashwithdrawResult:
        return 301;
      case NotificationType.systemMerchantApplyResult:
        return 401;
    }
  }

  String getName(){
    switch(this){
      case NotificationType.interactFriendApply:
        return '新的朋友';
      case NotificationType.interactProductLiked:
      case NotificationType.interactCommentLiked:
      case NotificationType.interactCommentSubLiked:
        return '新的点赞';
      case NotificationType.interactProductCommented:
        return '新的评论';
      case NotificationType.interactProductLikedMonument:
        return '里程碑达成';
      case NotificationType.interactCommentCommented:
      case NotificationType.interactCommentSubCommented:
        return '新的回复';
      case NotificationType.interactCircleActivityApplied:
        return '组队申请';
      case NotificationType.interactGroupInvited:
        return '加群邀请';
      
      case NotificationType.orderReceived:
        return '新的订单';
      case NotificationType.orderRetracted:
        return '用户取消订单';

      case NotificationType.systemOrderSuccess:
        return '下单成功';
      case NotificationType.systemOrderFail:
        return '订单失败';
      case NotificationType.systemOrderConfirmed:
        return '订单已确认';
      case NotificationType.systemOrderCompleted:
        return '订单已完成';
      case NotificationType.systemGetReward:
        return '获得打赏';
      case NotificationType.systemTipoffConfirmed:
        return '举报成功';
      case NotificationType.systemTipoffWarned:
        return '收到警告';
      case NotificationType.systemCashwithdrawResult:
        return '提现通知';
      case NotificationType.systemMerchantApplyResult:
        return '商家审核结果';
    }
  }

  static NotificationType? getType(int num){
    for(NotificationType type in NotificationType.values){
      if(type.getNum() == num){
        return type;
      }
    }
    return null;
  }
}

class SimpleUser{
  int? id;
  String? name;
  String? head;

  SimpleUser();
  SimpleUser.fromJson(dynamic json){
    id = json['id'];
    name = json['name'];
    head = json['head'];
  }
  Map<String, Object?> toSqlMap(){
    Map<String, Object?> map = {};
    map['user_id'] = id;
    map['name'] = name;
    map['head'] = head;
    return map;
  }
  SimpleUser.fromSqlMap(dynamic map){
    id = map['user_id'];
    name = map['name'];
    head = map['head'];
  }
}

class ImNotificationSystemMerchantApplyResult extends ImNotification{
  int? verifyStatus;
  String? shopName;
  int? businessType;
  String? address;
  
  ImNotificationSystemMerchantApplyResult.fromJson(dynamic json) : super.fromJson(json){
    verifyStatus = json['verifyStatus'];
    shopName = json['shopName'];
    businessType = json['businessType'];
    address = json['address'];
  }
  ImNotificationSystemMerchantApplyResult.fromSqlMap(dynamic map) : super.fromSqlMap(map){
    verifyStatus = map['verify_status'];
    shopName = map['shop_name'];
    businessType = map['business_type'];
    address = map['address'];
  }
  Map<String, Object?> toExtraSqlMap(){
    Map<String, Object?> map = {};
    map['nid'] = id;
    map['verify_status'] = verifyStatus;
    map['shop_name'] = shopName;
    map['business_type'] = businessType;
    map['address'] = address;
    return map;
  }

  @override
  ImNotificationAdapter? getAdapter(){
    return ImNotificationSystemMerchantApplyResultAdapter();
  }
}

class ImNotificationSystemCashWithdrawResult extends ImNotification{
  int? amount;
  int? status;
  String? bankAccount;
  String? bankName;
  String? realName;
  String? refuseReason;
  
  ImNotificationSystemCashWithdrawResult.fromJson(dynamic json) : super.fromJson(json){
    amount = json['amount'];
    status = json['status'];
    bankAccount = json['bankAccount'];
    bankName = json['bankName'];
    realName = json['realName'];
    refuseReason = json['refuseReason'];
  }
  ImNotificationSystemCashWithdrawResult.fromSqlMap(dynamic map) : super.fromSqlMap(map){
    amount = map['amount'];
    status = map['status'];
    bankAccount = map['bank_account'];
    bankName = map['bank_name'];
    realName = map['real_name'];
    refuseReason = map['refuse_reason'];
  }
  Map<String, Object?> toExtraSqlMap(){
    Map<String, Object?> map = {};
    map['nid'] = id;
    map['amount'] = amount;
    map['status'] = status;
    map['bank_account'] = bankAccount;
    map['bank_name'] = bankName;
    map['real_name'] = realName;
    map['refuse_reason'] = refuseReason;
    return map;
  }

  @override
  ImNotificationAdapter? getAdapter(){
    return ImNotificationSystemCashWithdrawResultAdapter();
  }
}

class ImNotificationSystemTipoffConfirmed extends ImNotification{
  int? productId;
  int? productType;
  String? productName;
  
  ImNotificationSystemTipoffConfirmed.fromJson(dynamic json) : super.fromJson(json){
    productId = json['productId'];
    productType = json['productType'];
    productName = json['productName'];
  }
  ImNotificationSystemTipoffConfirmed.fromSqlMap(dynamic map) : super.fromSqlMap(map){
    productId = map['product_id'];
    productType = map['product_type'];
    productName = map['product_name'];
  }
  Map<String, Object?> toExtraSqlMap(){
    Map<String, Object?> map = {};
    map['nid'] = id;
    map['product_id'] = productId;
    map['product_type'] = productType;
    map['product_name'] = productName;
    return map;
  }

  @override
  ImNotificationAdapter? getAdapter(){
    return ImNotificationSystemTipoffConfirmedAdapter();
  }
}

class ImNotificationSystemGetReward extends ImNotification{

  int? productId;
  int? productType;
  String? productName;
  int? amount;
  int? userId;
  String? userHead;
  String? userName;
  DateTime? payDate;

  ImNotificationSystemGetReward.fromJson(dynamic json) : super.fromJson(json){
    productId = json['productId'];
    productType = json['productType'];
    productName = json['productName'];
    amount = json['amount'];
    userId = json['userId'];
    userHead = json['userHead'];
    userName = json['userName'];
    if(json['payDate'] is String){
      payDate = DateTime.tryParse(json['payDate']);
    }
  }
  ImNotificationSystemGetReward.fromSqlMap(dynamic map) : super.fromSqlMap(map){
    productId = map['product_id'];
    productType = map['product_type'];
    productName = map['product_name'];
    amount = map['amount'];
    userId = map['user_id'];
    userHead = map['user_head'];
    userName = map['user_name'];
    if(map['pay_date'] is int){
      payDate = DateTime.fromMillisecondsSinceEpoch(map['pay_date']);
    }
  }
  Map<String, Object?> toExtraSqlMap(){
    Map<String, Object?> map = {};
    map['nid'] = id;
    map['product_id'] = productId;
    map['product_type'] = productType;
    map['product_name'] = productName;
    map['amount'] = amount;
    map['user_id'] = userId;
    map['user_head'] = userHead;
    map['user_name'] = userName;
    map['pay_date'] = payDate?.millisecondsSinceEpoch;
    return map;
  }

  @override
  ImNotificationAdapter? getAdapter(){
    return ImNotificationSystemGetRewardAdapter();
  }
}

class ImNotificationSystemProductWarned extends ImNotification{

  int? productId;
  int? productType;
  String? productName;
  
  ImNotificationSystemProductWarned.fromJson(dynamic json) : super.fromJson(json){
    productId = json['productId'];
    productType = json['productType'];
    productName = json['productName'];
  }
  ImNotificationSystemProductWarned.fromSqlMap(dynamic map) : super.fromSqlMap(map){
    productId = map['product_id'];
    productType = map['product_type'];
    productName = map['product_name'];
  }
  Map<String, Object?> toExtraSqlMap(){
    Map<String, Object?> map = {};
    map['nid'] = id;
    map['product_id'] = productId;
    map['product_type'] = productType;
    map['product_name'] = productName;
    return map;
  }

  @override
  ImNotificationAdapter? getAdapter(){
    return ImNotificationSystemProductWarnedAdapter();
  }
}

class ImNotificationSystemOrderStateChange extends ImNotification{

  String? productName;
  String? subName;
  int? productId;
  int? productType;
  int? quantity;
  DateTime? startDate;
  DateTime? endDate;

  ImNotificationSystemOrderStateChange.fromJson(dynamic json) : super.fromJson(json){
    productName = json['productName'];
    subName = json['subName'];
    productId = json['productId'];
    productType = json['productType'];
    quantity = json['quantity'];
    if(json['startDate'] is String){
      startDate = DateTime.tryParse(json['startDate']);
    }
    if(json['endDate'] is String){
      endDate = DateTime.tryParse(json['endDate']);
    }
  }
  ImNotificationSystemOrderStateChange.fromSqlMap(dynamic map) : super.fromSqlMap(map){
    productName = map['product_name'];
    subName = map['sub_name'];
    productId = map['product_id'];
    productType = map['product_type'];
    quantity = map['quantity'];
    if(map['start_date'] is int){
      startDate = DateTime.fromMillisecondsSinceEpoch(map['start_date']);
    }
    if(map['end_date'] is int){
      endDate = DateTime.fromMillisecondsSinceEpoch(map['end_date']);
    }
  }
  Map<String, Object?> toExtraSqlMap(){
    Map<String, Object?> map = {};
    map['nid'] = id;
    map['product_name'] = productName;
    map['sub_name'] = subName;
    map['product_id'] = productId;
    map['product_type'] = productType;
    map['quantity'] = quantity;
    map['start_date'] = startDate?.millisecondsSinceEpoch;
    map['end_date'] = endDate?.millisecondsSinceEpoch;
    return map;
  }

  @override
  ImNotificationAdapter? getAdapter(){
    return ImNotificationSystemOrderStateChangeAdapter();
  }
}

class ImNotificationOrderScenic extends ImNotification{

  int? customerId;
  String? customerName;
  String? customerHead;
  int? scenicId;
  String? scenicName;
  String? ticketName;
  int? quantity;
  DateTime? visitDate;
  int? orderStatus;
  String? contactName;
  String? contactPhone;
  String? contactCardNo;
  int? contactCardType;
  bool? checked;

  ImNotificationOrderScenic.fromJson(dynamic json) : super.fromJson(json){
    customerId = json['customerId'];
    customerName = json['customerName'];
    customerHead = json['customerHead'];
    scenicId = json['scenicId'];
    scenicName = json['scenicName'];
    ticketName = json['ticketName'];
    quantity = json['quantity'];
    if(json['visitDate'] is String){
      visitDate = DateTime.tryParse(json['visitDate']);
    }
    orderStatus = json['orderStatus'];
    contactName = json['contactName'];
    contactPhone = json['contactPhone'];
    contactCardNo = json['contactCardNo'];
    contactCardType = json['contactCardType'];
  }
  ImNotificationOrderScenic.fromSqlMap(dynamic map) : super.fromSqlMap(map){
    customerId = map['customer_id'];
    customerName = map['customer_name'];
    customerHead = map['customer_head'];
    scenicId = map['scenic_id'];
    scenicName = map['scenic_name'];
    ticketName = map['ticket_name'];
    quantity = map['quantity'];
    if(map['visit_date'] is int){
      visitDate = DateTime.fromMillisecondsSinceEpoch(map['visit_date']);
    }
    orderStatus = map['order_status'];
    contactName = map['contact_name'];
    contactPhone = map['contact_phone'];
    contactCardNo = map['contact_card_no'];
    contactCardType = map['contact_card_type'];
    checked = (map['checked'] != null && map['checked'] > 0);
  }
  Map<String, Object?> toExtraSqlMap(){
    Map<String, Object?> map = {};
    map['nid'] = id;
    map['customer_id'] = customerId;
    map['customer_name'] = customerName;
    map['customer_head'] = customerHead;
    map['scenic_id'] = scenicId;
    map['scenic_name'] = scenicName;
    map['ticket_name'] = ticketName;
    map['quantity'] = quantity;
    map['visit_date'] = visitDate?.millisecondsSinceEpoch;
    map['order_status'] = orderStatus;
    map['contact_name'] = contactName;
    map['contact_phone'] = contactPhone;
    map['contact_card_no'] = contactCardNo;
    map['contact_card_type'] = contactCardType;
    map['checked'] = checked == true ? 1 : 0;
    return map;
  }

  @override
  ImNotificationAdapter? getAdapter(){
    return ImNotificationOrderScenicAdapter();
  }
}

class ImNotificationOrderHotel extends ImNotification{

  int? customerId;
  String? customerName;
  String? customerHead;
  int? hotelId;
  String? hotelName;
  String? planName;
  int? quantity;
  DateTime? checkInDate;
  DateTime? checkOutDate;
  int? orderStatus;
  String? contactName;
  String? contactPhone;
  String? contactEmail;
  String? remark;
  bool? checked;

  ImNotificationOrderHotel.fromJson(dynamic json) : super.fromJson(json){
    customerId = json['customerId'];
    customerName = json['customerName'];
    customerHead = json['customerHead'];
    hotelId = json['hotelId'];
    hotelName = json['hotelName'];
    planName = json['planName'];
    quantity = json['quantity'];
    if(json['checkInDate'] is String){
      checkInDate = DateTime.tryParse(json['checkInDate']);
    }
    if(json['checkOutDate'] is String){
      checkOutDate = DateTime.tryParse(json['checkOutDate']);
    }
    orderStatus = json['orderStatus'];
    contactName = json['contactName'];
    contactPhone = json['contactPhone'];
    contactEmail = json['contactEmail'];
    remark = json['remark'];
  }
  ImNotificationOrderHotel.fromSqlMap(dynamic map) : super.fromSqlMap(map){
    customerId = map['customer_id'];
    customerName = map['customer_name'];
    customerHead = map['customer_head'];
    hotelId = map['hotel_id'];
    hotelName = map['hotel_name'];
    planName = map['plan_name'];
    quantity = map['quantity'];
    if(map['check_in_date'] is int){
      checkInDate = DateTime.fromMillisecondsSinceEpoch(map['check_in_date']);
    }
    if(map['check_out_date'] is int){
      checkOutDate = DateTime.fromMillisecondsSinceEpoch(map['check_out_date']);
    }
    orderStatus = map['order_status'];
    contactName = map['contact_name'];
    contactPhone = map['contact_phone'];
    contactEmail = map['contact_email'];
    remark = map['remark'];
    checked = (map['checked'] != null && map['checked'] > 0);
  }
  Map<String, Object?> toExtraSqlMap(){
    Map<String, Object?> map = {};
    map['nid'] = id;
    map['customer_id'] = customerId;
    map['customer_name'] = customerName;
    map['customer_head'] = customerHead;
    map['hotel_id'] = hotelId;
    map['hotel_name'] = hotelName;
    map['plan_name'] = planName;
    map['quantity'] = quantity;
    map['check_in_date'] = checkInDate?.millisecondsSinceEpoch;
    map['check_out_date'] = checkOutDate?.millisecondsSinceEpoch;
    map['order_status'] = orderStatus;
    map['contact_name'] = contactName;
    map['contact_phone'] = contactPhone;
    map['contact_email'] = contactEmail;
    map['remark'] = remark;
    map['checked'] = checked == true ? 1 : 0;
    return map;
  }

  @override
  ImNotificationAdapter? getAdapter(){
    return ImNotificationOrderHotelAdapter();
  }
}

class ImNotificationOrderRestaurant extends ImNotification{

  int? customerId;
  String? customerName;
  String? customerHead;
  int? restaurantId;
  String? restaurantName;
  String? restaurantAddress;
  int? numberPeople;
  DateTime? arrivalDate;
  int? diningMethods;
  String? contactName;
  String? contactPhone;
  String? remark;
  int? orderStatus;
  String? unfinishedReason;
  bool? checked;

  ImNotificationOrderRestaurant.fromJson(dynamic json) : super.fromJson(json) {
    customerId = json['customerId'];
    customerName = json['customerName'];
    customerHead = json['customerHead'];
    restaurantId = json['restaurantId'];
    restaurantName = json['restaurantName'];
    restaurantAddress = json['restaurantAddress'];
    numberPeople = json['numberPeople'];
    if (json['arrivalDate'] is String) {
      arrivalDate = DateTime.tryParse(json['arrivalDate']);
    }
    diningMethods = json['diningMethods'];
    contactName = json['contactName'];
    contactPhone = json['contactPhone'];
    remark = json['remark'];
    orderStatus = json['orderStatus'];
    unfinishedReason = json['unfinishedReason'];
  }
  ImNotificationOrderRestaurant.fromSqlMap(dynamic map)
      : super.fromSqlMap(map) {
    customerId = map['customer_id'];
    customerName = map['customer_name'];
    customerHead = map['customer_head'];
    restaurantId = map['restaurant_id'];
    restaurantName = map['restaurant_name'];
    restaurantAddress = map['restaurant_address'];
    numberPeople = map['number_people'];
    if (map['arrival_date'] is int) {
      arrivalDate = DateTime.fromMillisecondsSinceEpoch(map['arrival_date']);
    }
    diningMethods = map['dining_methods'];
    contactName = map['contact_name'];
    contactPhone = map['contact_phone'];
    remark = map['remark'];
    orderStatus = map['order_status'];
    unfinishedReason = map['unfinished_reason'];
    checked = (map['checked'] != null && map['checked'] > 0);
  }

  Map<String, Object?> toExtraSqlMap() {
    Map<String, Object?> map = {};
    map['nid'] = id;
    map['customer_id'] = customerId;
    map['customer_name'] = customerName;
    map['customer_head'] = customerHead;
    map['restaurant_id'] = restaurantId;
    map['restaurant_name'] = restaurantName;
    map['restaurant_address'] = restaurantAddress;
    map['number_people'] = numberPeople;
    map['arrival_date'] = arrivalDate?.millisecondsSinceEpoch;
    map['dining_methods'] = diningMethods;
    map['contact_name'] = contactName;
    map['contact_phone'] = contactPhone;
    map['remark'] = remark;
    map['order_status'] = orderStatus;
    map['unfinished_reason'] = unfinishedReason;
    map['checked'] = checked == true ? 1 : 0;
    return map;
  }

  @override
  ImNotificationAdapter? getAdapter(){
    return ImNotificationOrderRestaurantAdapter();
  }
}

enum DiningMethodsStatus { unconfirmed, dineIn, takeOut }

extension DiningMethodsStatusExt on DiningMethodsStatus{
  int getNum() {
    switch (this) {
      case DiningMethodsStatus.unconfirmed:
        return 0;
      case DiningMethodsStatus.dineIn:
        return 1;
      case DiningMethodsStatus.takeOut:
        return 2;
    }
  }

  static DiningMethodsStatus? getType(int num){
    for (DiningMethodsStatus status in DiningMethodsStatus.values) {
      if (status.getNum() == num) {
        return status;
      }
    }
    return null;
  }
}

class ImNotificationOrderTravel extends ImNotification{

  int? customerId;
	String? customerName;
	String? customerHead;
	int? travelId;
	int? travelSuitId;
	String? travelName;
	String? travelSuitName;
	int? number;
	int? oldNumber;
	int? childNumber;
	DateTime? startDate;
	DateTime? endDate;
	int? dayNum;
	int? nightNum;
	String? province;
	String? city;
	String? rendezvousTime;
	String? rendezvousLocation;
	String? destProvince;
	String? destCity;
	String? destAddress;
	int? cancelRuleType;
	String? cancelRuleDesc;
	DateTime? cancelLatestTime;
	String? contactName;
	String? contactPhone;
	String? contactEmail;
	String? emergencyName;
	String? emergencyPhone;
	int? orderStatus;
	String? unfinishedReason;
	String? remark;
  bool? checked;

  ImNotificationOrderTravel.fromJson(dynamic json) : super.fromJson(json) {
    customerId = json['customerId'];
    customerName = json['customerName'];
    customerHead = json['customerHead'];
    travelId = json['travelId'];
    travelSuitId = json['travelSuitId'];
    travelName = json['travelName'];
    travelSuitName = json['travelSuitName'];
    number = json['number'];
    oldNumber = json['oldNumber'];
    childNumber = json['childNumber'];
    if(json['startDate'] is String){
      startDate = DateTime.tryParse(json['startDate']);
    }
    if (json['endDate'] is String) {
      endDate = DateTime.tryParse(json['endDate']);
    }
    dayNum = json['dayNum'];
    nightNum = json['nightNum'];
    province = json['province'];
    city = json['city'];
    rendezvousTime = json['rendezvousTime'];
    rendezvousLocation = json['rendezvousLocation'];
    destProvince = json['destProvince'];
    destCity = json['destCity'];
    destAddress = json['destAddress'];
    cancelRuleType = json['cancelRuleType'];
    cancelRuleDesc = json['cancelRuleDesc'];
    if (json['cancelLatestTime'] is String) {
      cancelLatestTime = DateTime.tryParse(json['cancelLatestTime']);
    }
    contactName = json['contactName'];
    contactPhone = json['contactPhone'];
    contactEmail = json['contactEmail'];
    emergencyName = json['emergencyName'];
    emergencyPhone = json['emergencyPhone'];
    orderStatus = json['orderStatus'];
    unfinishedReason = json['unfinishedReason'];
    remark = json['remark'];
  }
  ImNotificationOrderTravel.fromSqlMap(dynamic map)
      : super.fromSqlMap(map) {
    customerId = map['customer_id'];
    customerName = map['customer_name'];
    customerHead = map['customer_head'];
    travelId = map['travel_id'];
    travelSuitId = map['travel_suit_id'];
    travelName = map['travel_name'];
    travelSuitName = map['travel_suit_name'];
    number = map['number'];
    oldNumber = map['old_number'];
    childNumber = map['child_number'];
    if(map['start_date'] is int){
      startDate = DateTime.fromMillisecondsSinceEpoch(map['start_date']);
    }
    if (map['end_date'] is int) {
      endDate = DateTime.fromMillisecondsSinceEpoch(map['end_date']);
    }
    dayNum = map['day_num'];
    nightNum = map['night_num'];
    province = map['province'];
    city = map['city'];
    rendezvousTime = map['rendezvous_time'];
    rendezvousLocation = map['rendezvous_location'];
    destProvince = map['dest_province'];
    destCity = map['dest_city'];
    destAddress = map['dest_address'];
    cancelRuleType = map['cancel_rule_type'];
    cancelRuleDesc = map['cancel_rule_desc'];
    if (map['cancel_latest_time'] is String) {
      cancelLatestTime = DateTime.fromMillisecondsSinceEpoch(map['cancel_latest_time']);
    }
    contactName = map['contact_name'];
    contactPhone = map['contact_phone'];
    contactEmail = map['contact_email'];
    emergencyName = map['emergency_name'];
    emergencyPhone = map['emergency_phone'];
    orderStatus = map['order_status'];
    unfinishedReason = map['unfinished_reason'];
    remark = map['remark'];
    checked = (map['checked'] != null && map['checked'] > 0);
  }

  Map<String, Object?> toExtraSqlMap() {
    Map<String, Object?> map = {};
    map['nid'] = id;
    map['customer_id'] = customerId;
    map['customer_name'] = customerName;
    map['customer_head'] = customerHead;
    map['travel_id'] = travelId;
    map['travel_suit_id'] = travelSuitId;
    map['travel_name'] = travelName;
    map['travel_suit_name'] = travelSuitName;
    map['number'] = number;
    map['old_number'] = oldNumber;
    map['child_number'] = childNumber;
    map['start_date'] = startDate?.millisecondsSinceEpoch;
    map['end_date'] = endDate?.millisecondsSinceEpoch;
    map['day_num'] = dayNum;
    map['night_num'] = nightNum;
    map['province'] = province;
    map['city'] = city;
    map['rendezvous_time'] = rendezvousTime;
    map['rendezvous_location'] = rendezvousLocation;
    map['dest_province'] = destProvince;
    map['dest_city'] = destCity;
    map['dest_address'] = destAddress;
    map['cancel_rule_type'] = cancelRuleType;
    map['cancel_rule_desc'] = cancelRuleDesc;
    map['cancel_latest_time'] = cancelLatestTime?.millisecondsSinceEpoch;
    map['contact_name'] = contactName;
    map['contact_phone'] = contactPhone;
    map['contact_email'] = contactEmail;
    map['emergency_name'] = emergencyName;
    map['emergency_phone'] = emergencyPhone;
    map['order_status'] = orderStatus;
    map['unfinished_reason'] = unfinishedReason;
    map['remark'] = remark;
    map['checked'] = checked == true ? 1 : 0;
    return map;
  }

  @override
  ImNotificationAdapter? getAdapter(){
    return ImNotificationOrderTravelAdapter();
  }
}

class ImNotificationInteractCircleActivityApplied extends ImNotification {
  int? circleId;
  String? circleName;
  int? applierId;
  String? applierName;
  String? applierHead;
  String? remark;
  int? applyStatus;

  ImNotificationInteractCircleActivityApplied.fromJson(dynamic json) : super.fromJson(json){
    circleId = json['circleId'];
    circleName = json['circleName'];
    applierId = json['applierId'];
    applierName = json['applierName'];
    applierHead = json['applierHead'];
    remark = json['remark'];
    applyStatus = json['applyStatus'];
  }
  ImNotificationInteractCircleActivityApplied.fromSqlMap(dynamic map) : super.fromSqlMap(map){
    circleId = map['circle_id'];
    circleName = map['circle_name'];
    applierId = map['applier_id'];
    applierName = map['applier_name'];
    applierHead = map['applier_head'];
    remark = map['remark'];
    applyStatus = map['apply_status'];
  }
  Map<String, Object?> toExtraSqlMap(){
    Map<String, Object?> map = {};
    map['nid'] = id;
    map['circle_id'] = circleId;
    map['circle_name'] = circleName;
    map['applier_id'] = applierId;
    map['applier_name'] = applierName;
    map['applier_head'] = applierHead;
    map['remark'] = remark;
    map['apply_status'] = applyStatus;
    return map;
  }

  @override
  ImNotificationAdapter getAdapter(){
    return ImNotificationInteractCircleActivityAppliedAdapter();
  }
}

class ImNotificationInteractCommentLiked extends ImNotification{
  int? partnerId;
  String? partnerName;
  String? partnerHead;
  int? productId;
  String? productName;
  String? content;

  ImNotificationInteractCommentLiked.fromJson(dynamic json) : super.fromJson(json){
    partnerId = json['partnerId'];
    partnerName = json['partnerName'];
    partnerHead = json['partnerHead'];
    productId = json['productId'];
    productName = json['productName'];
    content = json['content'];
  }
  ImNotificationInteractCommentLiked.fromSqlMap(dynamic map) : super.fromSqlMap(map){
    partnerId = map['partner_id'];
    partnerName = map['partner_name'];
    partnerHead = map['partner_head'];
    productId = map['product_id'];
    productName = map['product_name'];
    content = map['content'];
  }
  Map<String, Object?> toExtraSqlMap(){
    Map<String, Object?> map = {};
    map['nid'] = id;
    map['partner_id'] = partnerId;
    map['partner_name'] = partnerName;
    map['partner_head'] = partnerHead;
    map['product_id'] = productId;
    map['product_name'] = productName;
    map['content'] = content;
    return map;
  }

  @override
  ImNotificationAdapter? getAdapter(){
    return ImNotificationInteractCommentLikedAdapter();
  }
}

class ImNotificationInteractProductLikedMonument extends ImNotification{
  
  int? productId;
  int? productType;
  String? productName;
  int? count;
  List<SimpleUser>? users;

  ImNotificationInteractProductLikedMonument.fromJson(dynamic json) :super.fromJson(json){
    productId = json['productId'];
    productType = json['productType'];
    productName = json['productName'];
    count = json['count'];
    users = [];
    for(dynamic child in json['users'] ?? []){
      users?.add(SimpleUser.fromJson(child));
    }
  }
  ImNotificationInteractProductLikedMonument.fromSqlMap(dynamic json):super.fromSqlMap(json){
    productId = json['product_id'];
    productType = json['product_type'];
    productName = json['product_name'];
    count = json['count'];
  }

  Map<String, Object?> toExtraSqlMap(){
    Map<String, Object?> map = {};
    map['nid'] = id;
    map['product_id'] = productId;
    map['product_type'] = productType;
    map['product_name'] = productName;
    map['count'] = count;
    return map;
  }
  List<Map<String, Object?>> toExtraUserList(){
    List<Map<String, Object?>> list = [];
    for(SimpleUser simpleUser in users ?? []){
      Map<String, Object?> map = simpleUser.toSqlMap();
      map['nid'] = id;
      list.add(map);
    }
    return list;
  }
  
  @override
  ImNotificationAdapter? getAdapter(){
    return ImNotificationInteractProductLikedMonumentAdapter();
  }
}

class ImNotificationInteractCommentCommented extends ImNotification{

  int? partnerId;
  String? partnerName;
  String? partnerHead;
  int? commentId;
  String? userContent;
  String? partnerContent;
  int? productId;
  String? productName;
  bool? isLiked;

  ImNotificationInteractCommentCommented.fromJson(dynamic json) : super.fromJson(json){
    partnerId = json['partnerId'];
    partnerName = json['partnerName'];
    partnerHead = json['partnerHead'];
    commentId = json['commentId'];
    userContent = json['userContent'];
    partnerContent = json['partnerContent'];
    productId = json['productId'];
    productName = json['productName'];
    isLiked = json['isLiked'];
  }
  ImNotificationInteractCommentCommented.fromSqlMap(dynamic map) : super.fromSqlMap(map){
    partnerId = map['partner_id'];
    partnerName = map['partner_name'];
    partnerHead = map['partner_head'];
    commentId = map['comment_id'];
    userContent = map['user_content'];
    partnerContent = map['partner_content'];
    productId = map['product_id'];
    productName = map['product_name'];
    if(map['is_liked'] != null && map['is_liked'] >= 1){
      isLiked = true;
    }
    else{
      isLiked = false;
    }
  }
  Map<String, Object?> toExtraSqlMap(){
    Map<String, Object?> map = {};
    map['nid'] = id;
    map['partner_id'] = partnerId;
    map['partner_name'] = partnerName;
    map['partner_head'] = partnerHead;
    map['comment_id'] = commentId;
    map['user_content'] = userContent;
    map['partner_content'] = partnerContent;
    map['product_id'] = productId;
    map['product_name'] = productName;
    map['is_liked'] = (isLiked == true ? 1 : 0);
    return map;
  }

  @override
  ImNotificationAdapter getAdapter(){
    return ImNotificationInteractCommentCommentedAdapter();
  }
}

class ImNotificationInteractProductCommented extends ImNotification{

  int? partnerId;
  String? partnerName;
  String? partnerHead;
  String? content;
  int? productId;
  String? productName;
  bool? isLiked;

  ImNotificationInteractProductCommented.fromJson(dynamic json): super.fromJson(json){
    partnerId = json['partnerId'];
    partnerName = json['partnerName'];
    partnerHead = json['partnerHead'];
    content = json['content'];
    productId = json['productId'];
    productName = json['productName'];
    isLiked = json['isLiked'];
  }
  ImNotificationInteractProductCommented.fromSqlMap(dynamic map) : super.fromSqlMap(map){
    partnerId = map['partner_id'];
    partnerName = map['partner_name'];
    partnerHead = map['partner_head'];
    productId = map['partner_id'];
    content = map['content'];
    productId = map['product_id'];
    productName = map['product_name'];
    if(map['is_liked'] != null && map['is_liked'] >= 1){
      isLiked = true;
    }
    else{
      isLiked = false;
    }
  }
  Map<String, Object?> toExtraSqlMap(){
    Map<String, Object?> map = {};
    map['nid'] = id;
    map['partner_id'] = partnerId;
    map['partner_name'] = partnerName;
    map['partner_head'] = partnerHead;
    map['content'] = content;
    map['product_id'] = productId;
    map['product_name'] = productName;
    map['is_liked'] = (isLiked == true ? 1 : 0);
    return map;
  }

  @override
  ImNotificationAdapter? getAdapter(){
    return ImNotificationInteractProductCommentedAdapter();
  }
}

class ImNotificationInteractProductLiked extends ImNotification{
  
  int? partnerId;
  String? partnerName;
  String? partnerHead;
  int? productId;
  String? productName;

  ImNotificationInteractProductLiked.fromJson(dynamic json) : super.fromJson(json){
    partnerId = json['partnerId'];
    partnerName = json['partnerName'];
    partnerHead = json['partnerHead'];
    productId = json['productId'];
    productName = json['productName'];
  }
  ImNotificationInteractProductLiked.fromSqlMap(dynamic map) : super.fromSqlMap(map){
    partnerId = map['partner_id'];
    partnerName = map['partner_name'];
    partnerHead = map['partner_head'];
    productId = map['product_id'];
    productName = map['product_name'];
  }
  Map<String, Object?> toExtraSqlMap(){
    Map<String, Object?> map = {};
    map['nid'] = id;
    map['partner_id'] = partnerId;
    map['partner_name'] = partnerName;
    map['partner_head'] = partnerHead;
    map['product_id'] = productId;
    map['product_name'] = productName;
    return map;
  }

  @override
  ImNotificationAdapter? getAdapter(){
    return ImNotificationInteractProductLikedAdapter();
  }
}

class ImNotificationInteractFriendApply extends ImNotification{

  int? partnerId;
  String? partnerName;
  String? partnerHead;
  String? description;
  int? status;

  ImNotificationInteractFriendApply.fromJson(dynamic json) : super.fromJson(json){
    partnerId = json['partnerId'];
    partnerName = json['partnerName'];
    partnerHead = json['partnerHead'];
    description = json['description'];
    status = json['status'];
  }
  ImNotificationInteractFriendApply.fromSqlMap(dynamic map) : super.fromSqlMap(map){
    partnerId = map['partner_id'];
    partnerName = map['partner_name'];
    partnerHead = map['partner_head'];
    description = map['description'];
    status = map['status'];
  }
  Map<String, Object?> toExtraSqlMap(){
    Map<String, Object?> map = {};
    map['nid'] = id;
    map['partner_id'] = partnerId;
    map['partner_name'] = partnerName;
    map['partner_head'] = partnerHead;
    map['description'] = description;
    map['status'] = status;
    return map;
  }

  @override
  ImNotificationAdapter? getAdapter(){
    return ImNotificationInteractFriendApplyAdapter();
  }
}

enum UserFriendApplyStatus{
  waiting,
  success,
  rejected
}

extension UserFriendApplyStatusExt on UserFriendApplyStatus{
  int getNum(){
    switch(this){
      case UserFriendApplyStatus.waiting:
        return 0;
      case UserFriendApplyStatus.success:
        return 1;
      case UserFriendApplyStatus.rejected:
        return 2;
    }
  }
  static UserFriendApplyStatus? getType(int num){
    for(UserFriendApplyStatus status in UserFriendApplyStatus.values){
      if(status.getNum() == num){
        return status;
      }
    }
    return null;
  }
}

class ImNotificationReply<T>{
  int? roomId;
  int? commandType;
  T? commandValue;

  Map<String, Object?> toJson(){
    Map<String, Object?> map = {};
    map['roomId'] = roomId;
    map['commandType'] = commandType;
    map['commandValue'] = commandValue;
    return map;
  }
}
