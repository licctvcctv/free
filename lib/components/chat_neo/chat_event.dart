
import 'package:freego_flutter/components/chat_neo/chat_common.dart';

abstract class ChatEventHandler{
  Future handle(ChatEvent event);
}

abstract class ChatEvent{}
class ChatEventNewSingleRoom extends ChatEvent{
  final int roomId;
  ChatEventNewSingleRoom(this.roomId);
}

class ChatEventNewSingleMessage extends ChatEvent{
  final ImSingleMessage message;
  ChatEventNewSingleMessage(this.message);
}

class ChatEventBus{
  static final ChatEventBus _instance = ChatEventBus._internal();
  ChatEventBus._internal();
  factory ChatEventBus(){
    return _instance;
  }

  List<ChatEventHandler> handlerList = [];
  bool addEventHandler(ChatEventHandler handler){
    if(handlerList.contains(handler)){
      return false;
    }
    handlerList.add(handler);
    return true;
  }
  bool removeEventHandler(ChatEventHandler handler){
    return handlerList.remove(handler);
  }

  Future triggerEvent(ChatEvent event) async{
    for(ChatEventHandler handler in handlerList){
      await handler.handle(event);
    }
  }
}
