
abstract class NotificationEventHandler{
  Future handle(NotificationEvent event);
}

abstract class NotificationEvent{}

class NotificationEventNewRoom extends NotificationEvent{
  final int roomId;
  NotificationEventNewRoom(this.roomId);
}

class NotificationOrderStateChange extends NotificationEvent{
  final int notificationId;
  NotificationOrderStateChange(this.notificationId);
}

class NotificationEventBus{
  NotificationEventBus._internal();
  static final NotificationEventBus _instance = NotificationEventBus._internal();
  factory NotificationEventBus(){
    return _instance;
  }

  List<NotificationEventHandler> handlerList = [];
  bool addNotificationEventHandler(NotificationEventHandler handler){
    if(handlerList.contains(handler)){
      return false;
    }
    handlerList.add(handler);
    return true;
  }
  bool removeNotificationEventHandler(NotificationEventHandler handler){
    return handlerList.remove(handler);
  }

  Future triggerEvent(NotificationEvent event) async{
    for(NotificationEventHandler handler in handlerList){
      await handler.handle(event);
    }
  }
}
