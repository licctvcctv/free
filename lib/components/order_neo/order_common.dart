
class OrderGuest {
  int? id;
  int? orderId;
  String? name;
  String? phone;
  int? cardType;
  String? cardNo;

  OrderGuest();
  OrderGuest.fromJson(dynamic json) {
    id = json['id'];
    orderId = json['orderId'];
    name = json['name'];
    phone = json['phone'];
    cardType = json['cardType'];
    cardNo = json['cardNo'];
  }

  Map<String, Object?> toJson() {
    Map<String, Object?> map = {};
    map['id'] = id;
    map['orderId'] = orderId;
    map['name'] = name;
    map['phone'] = phone;
    map['cardType'] = cardType;
    map['cardNo'] = cardNo;
    return map;
  }
}

enum CardType {
  none, // 无
  idCard, // 身份证
  passport, // 护照
  homeVisit, // 回乡证
  taiwanIdCard, // 台胞证
  hongkongMacaoPass, // 港澳通行证
  taiwanPass, // 台湾通行证
  militaryCard, // 军人证
  permanentResidence, // 外国人永久居留身份证
  hongkongMacaoTaiwanResidence, // 港澳台永久居留身份证
  householdRegister, // 户口簿
  birthCertificate, // 出生证明
  studentCard // 学生证
}

extension CardTypeExt on CardType {
  String getName() {
    switch (this) {
      case CardType.none:
        return '无';
      case CardType.idCard:
        return '身份证';
      case CardType.passport:
        return '护照';
      case CardType.homeVisit:
        return '回乡证';
      case CardType.taiwanIdCard:
        return '台胞证';
      case CardType.hongkongMacaoPass:
        return '港澳通行证';
      case CardType.taiwanPass:
        return '台湾通行证';
      case CardType.militaryCard:
        return '军人证';
      case CardType.permanentResidence:
        return '外国人永久居留身份证';
      case CardType.hongkongMacaoTaiwanResidence:
        return '港澳台永久居留身份证';
      case CardType.householdRegister:
        return '户口簿';
      case CardType.birthCertificate:
        return '出生证明';
      case CardType.studentCard:
        return '学生证';
    }
  }

  int getNum() {
    switch (this) {
      case CardType.none:
        return 0;
      case CardType.idCard:
        return 1;
      case CardType.passport:
        return 2;
      case CardType.homeVisit:
        return 3;
      case CardType.taiwanIdCard:
        return 4;
      case CardType.hongkongMacaoPass:
        return 5;
      case CardType.taiwanPass:
        return 6;
      case CardType.militaryCard:
        return 7;
      case CardType.permanentResidence:
        return 8;
      case CardType.hongkongMacaoTaiwanResidence:
        return 9;
      case CardType.householdRegister:
        return 10;
      case CardType.birthCertificate:
        return 11;
      case CardType.studentCard:
        return 12;
    }
  }

  static CardType? getType(int num) {
    for (CardType type in CardType.values) {
      if (type.getNum() == num) {
        return type;
      }
    }
    return null;
  }
}

enum PayType { none, alipay, wechat, zftalipay, sftwechat, unionpay}

extension PayTypeExt on PayType {
  int getNum() {
    switch (this) {
      case PayType.none:
        return 0;
      case PayType.alipay:
        return 2;
      case PayType.wechat:
        return 3;
      case PayType.zftalipay:
        return 5;
      case PayType.sftwechat:
        return 6;
      case PayType.unionpay:
        return 7;

    }
  }

  String getName(){
    switch(this){
      case PayType.none:
        return 'none';
      case PayType.alipay:
        return 'alipay';
      case PayType.wechat:
        return 'wechat';
      case PayType.zftalipay:
        return 'zftalipay';
      case PayType.sftwechat:
        return 'sftwechat';
      case PayType.unionpay:
        return 'unionpay';
    }
  }

  static PayType? getType(int num) {
    for (PayType type in PayType.values) {
      if (type.getNum() == num) {
        return type;
      }
    }
    return null;
  }

  static PayType? getTypeByName(String name){
    for(PayType type in PayType.values){
      if(type.getName() == name){
        return type;
      }
    }
    return null;
  }
}

abstract class OrderNeo {
  int? id;
  String? source;
  String? outerNo;

  String? orderSerial;
  int? userId;
  int? merchantId;
  int? orderType;
  int? amount;
  int? payStatus;
  DateTime? payTime;
  int? payType;
  String? payTransactionNo;
  DateTime? payLimitTime;

  DateTime? confirmLimitTime;
  DateTime? confirmTime;

  int? refundAmount;
  DateTime? refundSuccessTime;
  String? refundTransactionNo;
  int? refundPayType;

  DateTime? createTime;
  DateTime? updateTime;

  OrderNeo.fromJson(dynamic json) {
    id = json['id'];
    source = json['source'];
    outerNo = json['outerNo'];

    orderSerial = json['orderSerial'];
    userId = json['userId'];
    merchantId = json['merchantId'];
    orderType = json['orderType'];
    amount = json['amount'];
    payStatus = json['payStatus'];
    if (json['payTime'] is String) {
      payTime = DateTime.tryParse(json['payTime']);
    }
    payType = json['payType'];
    payTransactionNo = json['payTransactionNo'];
    if (json['payLimitTime'] is String) {
      payLimitTime = DateTime.tryParse(json['payLimitTime']);
    }

    if(json['confirmLimitTime'] is String){
      confirmLimitTime = DateTime.tryParse(json['confirmLimitTime']);
    }
    if(json['confirmTime'] is String){
      confirmTime = DateTime.tryParse(json['confirmTime']);
    }

    refundAmount = json['refundAmount'];
    if (json['refundSuccessTime'] is String) {
      refundSuccessTime = DateTime.tryParse(json['refundSuccessTime']);
    }
    refundTransactionNo = json['refundTransactionNo'];
    refundPayType = json['refundPayType'];

    if (json['createTime'] is String) {
      createTime = DateTime.tryParse(json['createTime']);
    }
    if (json['updateTime'] is String) {
      updateTime = DateTime.tryParse(json['updateTime']);
    }
  }
}

class OrderHotel extends OrderNeo {
  int? oid;
  int? hotelId;
  int? chamberId;
  int? planId;

  String? hotelName;
  String? chamberName;
  String? planName;
  String? hotelAddress;
  String? outerHotelId;
  String? outerPlanId;

  int? numberOfRooms;
  int? numberOfNights;

  DateTime? checkInDate;
  DateTime? checkOutDate;

  String? remark;
  int? orderStatus;
  String? priceArr;

  int? cancelRuleType;
  String? cancelRuleDesc;
  DateTime? cancelLatestTime;
  int? cancelRuleFeeType;
  int? cancelRuleFee;

  String? confirmNum;
  String? contactName;
  String? contactPhone;
  String? contactEmail;
  String? unfinishedReason;

  String? merchantPhone;

  List<OrderGuest>? guestList;

  OrderHotel.fromJson(dynamic json) : super.fromJson(json) {
    oid = json['oid'];
    hotelId = json['hotelId'];
    chamberId = json['chamberId'];
    planId = json['planId'];

    hotelName = json['hotelName'];
    chamberName = json['chamberName'];
    planName = json['planName'];
    hotelAddress = json['hotelAddress'];
    outerHotelId = json['outerHotelId'];
    outerPlanId = json['outerPlanId'];

    numberOfRooms = json['numberOfRooms'];
    numberOfNights = json['numberOfNights'];

    if (json['checkInDate'] is String) {
      checkInDate = DateTime.tryParse(json['checkInDate']);
    }
    if (json['checkOutDate'] is String) {
      checkOutDate = DateTime.tryParse(json['checkOutDate']);
    }

    remark = json['remark'];
    orderStatus = json['orderStatus'];
    priceArr = json['priceArr'];

    cancelRuleType = json['cancelRuleType'];
    cancelRuleDesc = json['cancelRuleDesc'];
    if (json['cancelLatestTime'] is String) {
      cancelLatestTime = DateTime.tryParse(json['cancelLatestTime']);
    }
    cancelRuleFeeType = json['cancelRuleFeeType'];
    cancelRuleFee = json['cancelRuleFee'];

    confirmNum = json['confirmNum'];
    contactName = json['contactName'];
    contactPhone = json['contactPhone'];
    contactEmail = json['contactEmail'];
    unfinishedReason = json['unfinishedReason'];

    merchantPhone = json['merchantPhone'];

    if(json['guestList'] is List){
      guestList = [];
      for(dynamic json in json['guestList']){
        guestList!.add(OrderGuest.fromJson(json));
      }
    }
  }
}

class OrderScenic extends OrderNeo {
  int? oid;
  String? providerNo;
  String? confirmOrderId;

  int? scenicId;
  int? ticketId;
  String? scenicName;
  String? ticketName;

  String? outerScenicId;
  String? outerTicketId;

  int? orderStatus;
  String? drawAddress;
  DateTime? travelDate;
  int? quantity;
  String? voucherCode;
  String? voucherUrl;
  String? unfinishedReason;

  String? contactName;
  String? contactPhone;
  int? contactCardType;
  String? contactCardNo;

  String? bookNotice;
  String? refundChangeRule;
  String? costDescription;
  String? useDescription;
  String? otherDescription;

  List<OrderGuest>? guestList;

  OrderScenic.fromJson(dynamic json) : super.fromJson(json) {
    oid = json['oid'];
    providerNo = json['providerNo'];
    confirmOrderId = json['confirmOrderId'];

    scenicId = json['scenicId'];
    ticketId = json['ticketId'];
    scenicName = json['scenicName'];
    ticketName = json['ticketName'];

    outerScenicId = json['outerScenicId'];
    outerTicketId = json['outerTicketId'];

    orderStatus = json['orderStatus'];
    drawAddress = json['drawAddress'];
    if (json['travelDate'] is String) {
      travelDate = DateTime.tryParse(json['travelDate']);
    }
    quantity = json['quantity'];
    voucherCode = json['voucherCode'];
    voucherUrl = json['voucherUrl'];
    unfinishedReason = json['unfinishedReason'];

    contactName = json['contactName'];
    contactPhone = json['contactPhone'];
    contactCardType = json['contactCardType'];
    contactCardNo = json['contactCardNo'];

    bookNotice = json['bookNotice'];
    refundChangeRule = json['refundChangeRule'];
    costDescription = json['costDescription'];
    useDescription = json['useDescription'];
    otherDescription = json['otherDescription'];

    if(json['guestList'] is List){
      guestList = [];
      for(dynamic item in json['guestList']){
        guestList!.add(OrderGuest.fromJson(item));
      }
    }
  }
}

enum OrderHotelStatus {
  unpaid,
  unconfirmed,
  confirmed,
  confirmFail,
  completed,
  canceling,
  cancelFail,
  canceled,
  servicing
}

extension OrderHotelStatusExt on OrderHotelStatus {

  bool canCancel(){
    switch(this){
      case OrderHotelStatus.unconfirmed:
      case OrderHotelStatus.confirmed:
      case OrderHotelStatus.confirmFail:
        return true;
      default: 
        return false;
    }
  }

  int getNum() {
    switch (this) {
      case OrderHotelStatus.unpaid:
        return 1;
      case OrderHotelStatus.unconfirmed:
        return 2;
      case OrderHotelStatus.confirmed:
        return 3;
      case OrderHotelStatus.confirmFail:
        return 4;
      case OrderHotelStatus.completed:
        return 5;
      case OrderHotelStatus.canceling:
        return 6;
      case OrderHotelStatus.cancelFail:
        return 7;
      case OrderHotelStatus.canceled:
        return 8;
      case OrderHotelStatus.servicing:
        return 10;
    }
  }

  String getText(){
    switch(this){
      case OrderHotelStatus.unpaid:
        return '未支付';
      case OrderHotelStatus.unconfirmed:
        return '下单成功';
      case OrderHotelStatus.confirmed:
        return '已确认';
      case OrderHotelStatus.confirmFail:
        return '确认失败';
      case OrderHotelStatus.completed:
        return '已完成';
      case OrderHotelStatus.canceling:
        return '取消中';
      case OrderHotelStatus.cancelFail:
        return '取消失败';
      case OrderHotelStatus.canceled:
        return '已取消';
      case OrderHotelStatus.servicing:
        return '服务中';
    }
  }

  static OrderHotelStatus? getStatus(int num) {
    for (OrderHotelStatus status in OrderHotelStatus.values) {
      if (status.getNum() == num) {
        return status;
      }
    }
    return null;
  }

}

enum OrderScenicStatus {
  unpaid,
  drawing,
  drawn,
  drawFail,
  unsubscribing,
  unsubscribeFail,
  unsubscribed,
  canceled,
}

extension OrderScenicStatusExt on OrderScenicStatus {
  int getNum() {
    switch(this){
      case OrderScenicStatus.unpaid:
        return 1;
      case OrderScenicStatus.drawing:
        return 2;
      case OrderScenicStatus.drawn:
        return 3;
      case OrderScenicStatus.drawFail:
        return 4;
      case OrderScenicStatus.unsubscribing:
        return 5;
      case OrderScenicStatus.unsubscribeFail:
        return 6;
      case OrderScenicStatus.unsubscribed:
        return 7;
      case OrderScenicStatus.canceled:
        return 99;
    }
  }

  String getText(){
    switch(this){
      case OrderScenicStatus.unpaid:
        return '待付款';
      case OrderScenicStatus.drawing:
        return '出票中';
      case OrderScenicStatus.drawn:
        return '已出票';
      case OrderScenicStatus.drawFail:
        return '出票失败';
      case OrderScenicStatus.unsubscribing:
        return '退订中';
      case OrderScenicStatus.unsubscribeFail:
        return '退订失败';
      case OrderScenicStatus.unsubscribed:
        return '已退订';
      case OrderScenicStatus.canceled:
        return '已取消';
    }
  }

  static OrderScenicStatus? getStatus(int num) {
    for (OrderScenicStatus status in OrderScenicStatus.values) {
      if (status.getNum() == num) {
        return status;
      }
    }
    return null;
  }
}

enum PayStatus { unpaid, paid, error, refunded, canceled }

extension PayStatusExt on PayStatus {
  int getNum() {
    switch (this) {
      case PayStatus.unpaid:
        return 0;
      case PayStatus.paid:
        return 1;
      case PayStatus.error:
        return 2;
      case PayStatus.refunded:
        return 3;
      case PayStatus.canceled:
        return 4;
    }
  }

  static PayStatus? getStatus(int num) {
    for (PayStatus status in PayStatus.values) {
      if (status.getNum() == num) {
        return status;
      }
    }
    return null;
  }
}

class Dish {
  String? dishName;
  int? restaurantDishId;
  int? dishNumber;
  int? dishPrice;
  int? dishPriceOld;

  Dish.fromJson(dynamic json) {
    dishName = json['dishName'];
    restaurantDishId = json['restaurantDishId'];
    dishNumber = json['dishNumber'];
    dishPrice = json['dishPrice'];
    dishPriceOld = json['dishPriceOld'];
  }
}

class OrderRestaurant extends OrderNeo {
  int? oid;
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
  String? merchantPhone;

  List<OrderRestaurantDish>? dishList;

  OrderRestaurant.fromJson(dynamic json) : super.fromJson(json) {
    oid = json['oid'];
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
    merchantPhone = json['merchantPhone'];

    if(json['dishList'] != null){
      List<OrderRestaurantDish> list = [];
      for(dynamic item in json['dishList']){
        list.add(OrderRestaurantDish.fromJson(item));
      }
      dishList = list;
    }
  }
}

class OrderRestaurantDish {
  int? oid;
  int? orderId;
  int? restaurantId;
  int? restaurantDishId;

  String? dishName;
  int? dishNumber;
  int? price;
  int? priceOld;

  int? flavour;

  String? remark;

  OrderRestaurantDish();

  OrderRestaurantDish.fromJson(dynamic json)  {
    oid = json['oid'];
    orderId = json['orderId'];
    restaurantId = json['restaurantId'];
    restaurantDishId = json['restaurantDishId'];

    dishName = json['dishName'];
    dishNumber = json['dishNumber'];
    price = json['price'];
    priceOld = json['priceOld'];

    flavour = json['flavour'];
    remark = json['remark'];
  }
}

enum OrderRestaurantDining {
  dineIn,
  takeOut,
  unconfirmed,
}

extension OrderRestaurantDiningExt on OrderRestaurantDining {
  int getNum() {
    switch (this) {
      case OrderRestaurantDining.dineIn:
        return 1;
      case OrderRestaurantDining.takeOut:
        return 2;
      case OrderRestaurantDining.unconfirmed:
        return 0;
    }
  }

  static OrderRestaurantDining? getStatus(int num) {
    for (OrderRestaurantDining status in OrderRestaurantDining.values) {
      if (status.getNum() == num) {
        return status;
      }
    }
    return null;
  }
}

enum OrderRestaurantStatus {
  unpaid,
  unconfirmed,
  confirmed,
  confirmFail,
  servicing,
  completed,
  canceling,
  cancelFail,
  canceled,
  refunding,
  refunded,
  refundFail,
  error
}

extension OrderRestaurantStatusExt on OrderRestaurantStatus {

  bool canCancel(){
    switch(this){
      case OrderRestaurantStatus.unpaid:
        return true;
      default: 
        return false;
    }
  }

  bool canRefund(){
    return false;
  }

  int getNum() {
    switch (this) {
      case OrderRestaurantStatus.unpaid:
        return 1;
      case OrderRestaurantStatus.unconfirmed:
        return 2;
      case OrderRestaurantStatus.confirmed:
        return 3;
      case OrderRestaurantStatus.confirmFail:
        return 4;
      case OrderRestaurantStatus.servicing:
        return 5;
      case OrderRestaurantStatus.completed:
        return 6;
      case OrderRestaurantStatus.canceling:
        return 11;
      case OrderRestaurantStatus.cancelFail:
        return 12;
      case OrderRestaurantStatus.canceled:
        return 13;
      case OrderRestaurantStatus.refunding:
        return 21;
      case OrderRestaurantStatus.refunded:
        return 23;
      case OrderRestaurantStatus.refundFail:
        return 22;
      case OrderRestaurantStatus.error:
        return -1;
    }
  }

  String getText(){
    switch(this){
      case OrderRestaurantStatus.unpaid:
        return '未支付';
      case OrderRestaurantStatus.unconfirmed:
        return '待确认';
      case OrderRestaurantStatus.confirmFail:
        return '确认失败';
      case OrderRestaurantStatus.confirmed:
        return '已接单';
      case OrderRestaurantStatus.servicing:
        return '服务中';
      case OrderRestaurantStatus.completed:
        return '已完成';
      case OrderRestaurantStatus.canceling:
        return '取消中';
      case OrderRestaurantStatus.cancelFail:
        return '取消失败';
      case OrderRestaurantStatus.canceled:
        return '已取消';
      case OrderRestaurantStatus.refunding:
        return '退款中';
      case OrderRestaurantStatus.refundFail:
        return '退款失败';
      case OrderRestaurantStatus.refunded:
        return '已退款';
      case OrderRestaurantStatus.error:
        return '订单失败';
    }
  }

  static OrderRestaurantStatus? getStatus(int num) {
    for (OrderRestaurantStatus status in OrderRestaurantStatus.values) {
      if (status.getNum() == num) {
        return status;
      }
    }
    return null;
  }
}

class OrderTravel extends OrderNeo {
  int? oid;

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
  
  List<OrderGuest>? guestList;

  OrderTravel.fromJson(dynamic json) : super.fromJson(json) {
    oid = json['oid'];

    travelId = json['travelId'];
    travelSuitId = json['travelSuitId'];
    travelName = json['travelName'];
    travelSuitName = json['travelSuitName'];

    number = json['number'];
    oldNumber = json['oldNumber'];
    childNumber = json['childNumber'];

    if (json['startDate'] is String) {
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
    
    if(json['guestList'] is List){
      guestList = [];
      for(dynamic item in json['guestList']){
        guestList!.add(OrderGuest.fromJson(item));
      }
    }

  }
}

enum OrderTravelCancelRuleType {
  cancelledNot,
  cancelled,
  error,
}

extension OrderTravelCancelRuleTypeExt on OrderTravelCancelRuleType {
  int getCancelRuleType() {
    switch (this) {
      case OrderTravelCancelRuleType.cancelledNot:
        return 0;
      case OrderTravelCancelRuleType.cancelled:
        return 1;
      case OrderTravelCancelRuleType.error:
        return -1;
    }
  }

  static OrderTravelCancelRuleType? getStatus(int num) {
    for (OrderTravelCancelRuleType status in OrderTravelCancelRuleType.values) {
      if (status.getCancelRuleType() == num) {
        return status;
      }
    }
    return null;
  }
}

enum OrderTravelStatus {
  unpaid,
  unconfirmed,
  confirmed,
  confirmFail,
  servicing,
  completed,
  canceling,
  cancelFail,
  canceled,
  refunding,
  refundFail,
  refunded,
  error,
}

extension OrderTravelStatusExt on OrderTravelStatus {

  bool canCancel(){
    switch(this){
      case OrderTravelStatus.unpaid:
        return true;
      default: 
        return false;
    }
  }

  bool canRefund(){
    switch(this){
      case OrderTravelStatus.unconfirmed:
      case OrderTravelStatus.confirmed:
        return true;
      default:
        return false;
    }
  }

  int getNum() {
    switch (this) {
      case OrderTravelStatus.unpaid:
        return 1;
      case OrderTravelStatus.unconfirmed:
        return 2;
      case OrderTravelStatus.confirmed:
        return 3;
      case OrderTravelStatus.confirmFail:
        return 4;
      case OrderTravelStatus.servicing:
        return 5;
      case OrderTravelStatus.completed:
        return 6;
      case OrderTravelStatus.canceling:
        return 11;
      case OrderTravelStatus.cancelFail:
        return 12;
      case OrderTravelStatus.canceled:
        return 13;
      case OrderTravelStatus.refunding:
        return 21;
      case OrderTravelStatus.refundFail:
        return 22;
      case OrderTravelStatus.refunded:
        return 23;
      case OrderTravelStatus.error:
        return -1;
    }
  }

  String getText(){
    switch(this){
      case OrderTravelStatus.unpaid:
        return '未支付';
      case OrderTravelStatus.unconfirmed:
        return '待确认';
      case OrderTravelStatus.confirmed:
        return '已确认';
      case OrderTravelStatus.confirmFail:
        return '确认失败';
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

  static OrderTravelStatus? getStatus(int num) {
    for (OrderTravelStatus status in OrderTravelStatus.values) {
      if (status.getNum() == num) {
        return status;
      }
    }
    return null;
  }
}
