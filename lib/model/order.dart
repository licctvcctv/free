
class Order{
  
  late int id;
  String? orderSerial;
  int? userId;
  int? merchentId;
  int? type;
  int? productId;
  int? productSubId;
  int? status;
  String? pic;
  String? name;
  String? subName;
  int? bookNum;
  int? childNum;
  DateTime? startDay;
  DateTime? endDay;
  DateTime? payTime;
  int? totalPrice;
  int? payType;
  DateTime? createTime;
  DateTime? updateTime;

  Order(this.id);
  Order.fromJson(dynamic json) {
    id = json['id'];
    orderSerial = json['orderSerial'];
    userId  = json['userId'];
    merchentId = json['merchentId'];
    type = json['type'];
    productId = json['productId'];
    productSubId = json['productSubId'];
    status = json['status'];
    pic = json['pic'];
    name = json['name'];
    subName = json['subName'];
    bookNum = json['bookNum'];
    childNum = json['childNum'];
    if(json['startDay'] != null){
      startDay = DateTime.tryParse(json['startDay']);
    }
    if(json['endDay'] != null){
      endDay = DateTime.tryParse(json['endDay']);
    }
    if(json['payTime'] != null){
      payTime = DateTime.tryParse(json['payTime']);
    }
    totalPrice = json['totalPrice'];
    payType= json['payType'];
    if(json['createTime'] != null){
      createTime= DateTime.tryParse(json['createTime']);
    }
    if(json['updateTime'] != null){
      updateTime= DateTime.tryParse(json['updateTime']);
    }
  }

  static const int ORDER_STATUS_NOT_PAID = 0;
  static const int ORDER_STATUS_PAID = 1;
  static const int ORDER_STATUS_RUNNING = 2;
  static const int ORDER_STATUS_FINISHED = 3;
  static const int ORDER_STATUS_CANCELED = 4;
  static const int ORDER_STATUS_ERROR = 5;

  static const int PAY_TYPE_WECHAT = 0;
  static const int PAY_TYPE_ALIPAY = 1;
}

enum OrderStatus{
  notPaid,
  paid,
  running,
  finished,
  canceled,
  error,
}

extension OrderStatusExt on OrderStatus{
  int getNum(){
    switch(this){
      case OrderStatus.notPaid:
        return Order.ORDER_STATUS_NOT_PAID;
      case OrderStatus.paid:
        return Order.ORDER_STATUS_PAID;
      case OrderStatus.running:
        return Order.ORDER_STATUS_RUNNING;
      case OrderStatus.finished:
        return Order.ORDER_STATUS_FINISHED;
      case OrderStatus.canceled:
        return Order.ORDER_STATUS_CANCELED;
      case OrderStatus.error:
        return Order.ORDER_STATUS_ERROR;
    }
  }
  static OrderStatus? getStatus(int num){
    for(OrderStatus status in OrderStatus.values){
      if(status.getNum() == num){
        return status;
      }
    }
    return null;
  }
}

enum PayType{
  wechat,
  alipay
}

extension PayTypeExt on PayType{
  int getNum(){
    switch(this){
      case PayType.wechat:
        return Order.PAY_TYPE_WECHAT;
      case PayType.alipay:
        return Order.PAY_TYPE_ALIPAY;
    }
  }
  static PayType? getType(int num){
    for(PayType type in PayType.values){
      if(type.getNum() == num){
        return type;
      }
    }
    return null;
  }
}
