
import 'dart:async';
import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:freego_flutter/components/chat_neo/chat_common.dart';
import 'package:freego_flutter/components/chat_neo/chat_event.dart';
import 'package:freego_flutter/components/chat_neo/chat_http.dart';
import 'package:freego_flutter/components/chat_neo/chat_socket.dart';
import 'package:freego_flutter/components/chat_neo/chat_storage.dart';
import 'package:freego_flutter/components/video/video_model.dart';
import 'package:freego_flutter/util/local_user.dart';
import 'package:freego_flutter/util/tuple.dart';

class ChatUtilConstants{
  static const int QUOTE_SHOW_SIZE_MAX = 14;
  static const int NAME_NUMBER_MAX = 100;
  static const int RETRATABLE_MILLI_SECONDS = 180 * 1000; // 允许撤回时间，设置为3分钟
  static const int BRIEF_SIZE = 15; // 保存在聊天室中最新消息缩略的最大长度
}

class ChatUtilSingle{

  late SingleMessageDealer defaultSingleMessageDealer;
  late DefaultSingleMessageHandler defaultSingleMessageHandler;
  late DefaultSingleReconnectHandler defaultSingleReconnectHandler;

  ChatUtilSingle._internal(){
    defaultSingleMessageDealer = DefaultSingleStorageDealer(inner: DefaultSingleCommandDealer());
    defaultSingleMessageHandler = DefaultSingleMessageHandler(defaultSingleMessageDealer);
    ChatSocket.addMessageHandler(defaultSingleMessageHandler);

    defaultSingleReconnectHandler = DefaultSingleReconnectHandler();
    ChatSocket.addReconnectHandler(defaultSingleReconnectHandler);
  }
  static final ChatUtilSingle _instance = ChatUtilSingle._internal();
  factory ChatUtilSingle(){
    return _instance;
  }

  static Future<List<ImSingleMessage>?> getHistory(int roomId, {int? maxId, int limit = 10, DateTime? maxSendTime, int? maxUnsentId}) async{
    return _instance._getHistory(roomId, maxId: maxId, limit: limit, maxSendTime: maxSendTime, maxUnsentId: maxUnsentId);
  }
  static Future getAllUnsent() async{
    return _instance._getAllUnsent();
  }
  static Future<ImSingleRoom?> enterRoom(int partnerId) async{
    return _instance._enterRoom(partnerId);
  }

  Future<int> getUnreadCount() async{
    return ChatStorageSingle.getUnreadCount();
  }

  Future<ImSingleRoom?> _enterRoom(int partnerId) async{
    ImSingleRoom? room = await ChatStorageSingle.enterRoom(partnerId);
    if(room != null){
      return room;
    }
    room = await ChatHttpSingle.enterRoom(partnerId);
    if(room != null){
      ChatStorageSingle.saveRooms([room]);
      return room;
    }
    return null;
  }

  Future<List<ImSingleMessage>?> _getHistory(int roomId, {int? maxId, int limit = 10, DateTime? maxSendTime, int? maxUnsentId}) async{
    List<ImSingleMessage> list = await ChatStorageSingle.getLocalMessageByRoom(roomId, maxId: maxId, limit: limit, sendTime: maxSendTime, unsentLocalId: maxUnsentId);
    if(list.isNotEmpty){
      return list;
    }
    List<ImSingleMessage>? tmpList = await ChatHttpSingle.getHistory(roomId, maxId: maxId);
    if(tmpList != null){
      for(ImSingleMessage message in tmpList){
        message.localId = ChatStorageSingle.nextMid;
      }
      await ChatStorageSingle.saveMessages(tmpList);
    }
    return tmpList;
  }

  Future _getAllUnsent() async{
    Tuple<List<ImSingleRoom>, List<ImSingleMessage>>? tuple = await ChatHttpSingle.getAllUnsent();
    if(tuple == null){
      return;
    }
    List<ImSingleRoom> roomList = tuple.t1;
    List<ImSingleMessage> messageList = tuple.t2;
    // 处理消息
    for(ImSingleMessage message in messageList){
      defaultSingleMessageDealer.deal(message);
    }
    await ChatStorageSingle.saveRooms(roomList);
    // 发送已接收回执
    Map<int, int> roomSendMap = {};
    for(ImSingleMessage message in messageList){
      if(message.receiveRoomId != null){
        int roomId = message.receiveRoomId!;
        if(roomSendMap[roomId] == null || roomSendMap[roomId]! < message.id){
          roomSendMap[roomId] = message.id;
        }
      }
    }
    for(MapEntry<int, int> entry in roomSendMap.entries){
      ImSingleMessage message = prepareSentMessage(entry.key, entry.value);
      MessageObject rawMessage = getRawMessage(message);
      ChatSocket.sendMessage(rawMessage);
    }
  }

  static MessageObject getRawMessage(ImSingleMessage message){
    MessageObject rawMessage = MessageObject();
    rawMessage.name = ChatSocket.MESSAGE_SINGLE;
    rawMessage.body = json.encoder.convert(message.toJson());
    return rawMessage;
  }

  static ImSingleMessage prepareTextMessage(int roomId, String text, {ImSingleMessage? quote}){
    ImSingleMessage message = ImSingleMessage(0);
    message.localId = ChatSocket.nextMidVal;
    message.sendRoomId = roomId;
    message.content = text;
    message.type = MessageType.text.getNum();
    message.sendTime = DateTime.now();
    message.sendStatus = SendStatus.unsent.getNum();

    if(quote != null){
      message.quoteMsgId = quote.id;
      message.quoteType = quote.type;
      message.quoteContent = quote.content;
      message.quoteUrl = quote.url;
    }

    return message;
  }

  static ImSingleMessage prepareAudioMessage(int roomId, String url, Duration? duration){
    ImSingleMessage message = ImSingleMessage(0);
    message.localId = ChatSocket.nextMidVal;
    message.sendRoomId = roomId;
    if(duration != null){
      message.content = json.encoder.convert({
        'millis': duration.inMilliseconds
      });
    }
    message.url = url;
    message.type = MessageType.audio.getNum();
    message.sendTime = DateTime.now();
    message.sendStatus = SendStatus.unsent.getNum();

    return message;
  }

  static ImSingleMessage prepareImageMessage(int roomId, String url, {required int width, required int height}){
    ImSingleMessage message = ImSingleMessage(0);
    message.localId = ChatSocket.nextMidVal;
    message.sendRoomId = roomId;
    message.content = json.encoder.convert({
      'width': width,
      'height': height
    });
    message.url = url;
    message.type = MessageType.image.getNum();
    message.sendTime = DateTime.now();
    message.sendStatus = SendStatus.unsent.getNum();
    return message;
  }

  static ImSingleMessage prepareVideoMessage(int roomId, String url, {required int width, required int height, required millis}){
    ImSingleMessage message = ImSingleMessage(0);
    message.localId = ChatSocket.nextMidVal;
    message.sendRoomId = roomId;
    message.content = json.encoder.convert({
      'width': width,
      'height': height,
      'millis': millis
    });
    message.url = url;
    message.type = MessageType.video.getNum();
    message.sendTime = DateTime.now();
    message.sendStatus = SendStatus.unsent.getNum();
    return message;
  }

  static ImSingleMessage prepareLocationMessage(int roomId, String address, {required double latitude, required double longitude}){
    ImSingleMessage message = ImSingleMessage(0);
    message.localId = ChatSocket.nextMidVal;
    message.sendRoomId = roomId;
    message.content = json.encoder.convert({
      'address': address,
      'latitude': latitude,
      'longitude': longitude
    });
    message.type = MessageType.location.getNum();
    message.sendTime = DateTime.now();
    message.sendStatus = SendStatus.unsent.getNum();
    return message;
  }

  static ImSingleMessage prepareFileMessage(int roomId, {required String url, required String name, required String localPath, required int bytes}){
    ImSingleMessage message = ImSingleMessage(0);
    message.localId = ChatSocket.nextMidVal;
    message.sendRoomId = roomId;
    message.content = json.encoder.convert({
      'name': name,
      'bytes': bytes
    });
    message.url = url;
    message.localPath = localPath;
    message.type = MessageType.file.getNum();
    message.sendTime = DateTime.now();
    message.sendStatus = SendStatus.unsent.getNum();
    return message;
  }

  static ImSingleMessage prepareFreegoVideoMessage(int roomId, {required VideoModel video}){
    ImSingleMessage message = ImSingleMessage(0);
    message.localId = ChatSocket.nextMidVal;
    message.sendRoomId = roomId;
    message.content = json.encoder.convert({
      'name': video.name,
      'id': video.id,
      'cover': video.pic
    });
    message.type = MessageType.freegoVideo.getNum();
    message.sendTime = DateTime.now();
    message.sendStatus = SendStatus.unsent.getNum();
    return message;
  }

  static ImSingleMessage prepareSentMessage(int roomId, int lastSentMessageId){
    MessageCommand<int> command = MessageCommand(CommandType.sent.getNum(), lastSentMessageId);

    ImSingleMessage message = ImSingleMessage(0);
    message.localId = ChatSocket.nextMidVal;
    message.sendRoomId = roomId;
    message.content = json.encoder.convert(command.toJson());
    message.type = MessageType.command.getNum();
    message.sendTime = DateTime.now();
    message.sendStatus = SendStatus.unsent.getNum();

    return message;
  }

  static ImSingleMessage prepareReadMessage(int roomId){
    MessageCommand<void> command = MessageCommand(CommandType.read.getNum(), null);

    ImSingleMessage message = ImSingleMessage(0);
    message.localId = ChatSocket.nextMidVal;
    message.sendRoomId = roomId;
    message.content = json.encoder.convert(command.toJson());
    message.type = MessageType.command.getNum();
    message.sendTime = DateTime.now();
    message.sendStatus = SendStatus.unsent.getNum();

    return message;
  }

  static ImSingleMessage prepareRetractMessage(int roomId, int msgId){
    MessageCommand<int> command = MessageCommand(CommandType.retracting.getNum(), msgId);

    ImSingleMessage message = ImSingleMessage(0);
    message.localId = ChatSocket.nextMidVal;
    message.sendRoomId = roomId;
    message.content = json.encoder.convert(command.toJson());
    message.type = MessageType.command.getNum();
    message.sendTime = DateTime.now();
    message.sendStatus = SendStatus.unsent.getNum();

    return message;
  }

  static bool isRetractable(ImSingleMessage message){
    if(message.sendTime == null){
      return false;
    }
    if(DateTime.now().millisecondsSinceEpoch - message.sendTime!.millisecondsSinceEpoch < ChatUtilConstants.RETRATABLE_MILLI_SECONDS){
      return true;
    }
    return false;
  }
}

class DefaultSingleReconnectHandler extends SocketReconnectHandler{

  DefaultSingleReconnectHandler():super(priority: 10);

  @override
  Future handle() async{
    await ChatUtilSingle.getAllUnsent();
  }
  
}

class DefaultSingleMessageHandler extends ChatMessageHandler{

  final SingleMessageDealer singleMessageDealer;
  DefaultSingleMessageHandler(this.singleMessageDealer) :super(priority: -1);

  @override
  Future handle(MessageObject rawObj) async{
    if(rawObj.name != ChatSocket.MESSAGE_SINGLE){
      return;
    }
    if(rawObj.body == null){
      return;
    }
    ImSingleMessage message = ImSingleMessage.fromJson(json.decoder.convert(rawObj.body!));
    if(message.type == null){
      return;
    }
    MessageType? type = MessageTypeExt.getType(message.type!);
    if(type == null){
      return;
    }

    // 处理消息
    await singleMessageDealer.deal(message);
    // 若消息所在聊天室不存在，获取该聊天室
    if(message.receiveRoomId != null){
      if(type != MessageType.command && type != MessageType.notifyCommand){
        if(await ChatStorageSingle.getRoom(message.receiveRoomId!) == null){
          ImSingleRoom? room = await ChatHttpSingle.getRoom(message.receiveRoomId!);

          if(room != null){
            // 此处需要再次确认该聊天室是否存在，避免数据重复
            if(await ChatStorageSingle.getRoom(message.receiveRoomId!) == null){
              await ChatStorageSingle.saveRooms([room]);
              ChatEventBus().triggerEvent(ChatEventNewSingleRoom(room.id));
            }
          }
        }
      }
    }

    // 发送接收成功
    ImSingleMessage reply = ChatUtilSingle.prepareSentMessage(message.receiveRoomId!, message.id);
    MessageObject rawMessage = ChatUtilSingle.getRawMessage(reply);
    return await ChatSocket.sendMessage(rawMessage);
  }

}

abstract class SingleMessageDealer{

  SingleMessageDealer? inner;
  SingleMessageDealer({this.inner});
  Future deal(ImSingleMessage message);
}

class DefaultSingleCommandDealer extends SingleMessageDealer{
  DefaultSingleCommandDealer({super.inner});
  @override
  Future deal(ImSingleMessage message) async{
    inner?.deal(message);
    if(message.type == null){
      return;
    }
    MessageType? messageType = MessageTypeExt.getType(message.type!);
    if(messageType == null){
      return;
    }

    // 处理命令
    if(messageType == MessageType.command || messageType == MessageType.notifyCommand){
      if(message.content == null){
        return;
      }
      MessageCommand rawCommand = MessageCommand.fromText(message.content!);
      if(rawCommand.cmdType == null){
        return;
      }
      CommandType? commandType = CommandTypeExt.getType(rawCommand.cmdType!);
      switch(commandType){
        case CommandType.sending:
          if(message.localId == null || message.sendTime == null){
            break;
          }
          if(rawCommand.cmdValue is int){
            int msgId = rawCommand.cmdValue;
            int localId = message.localId!;
            DateTime sendTime = message.sendTime!;
            ChatStorageSingle.setSending(localId, msgId, sendTime).then((value) async{
              ImSingleMessage? targetMessage = await ChatStorageSingle.getMessage(msgId);
              if(targetMessage != null){
                ChatStorageSingle.updateLatestMessage(targetMessage);
              }
            });
          }
          break;
        case CommandType.read:
          if(message.receiveRoomId == null){
            break;
          }
          int roomId = message.receiveRoomId!;
          ChatStorageSingle.setRemoteRead(roomId);
          break;
        case CommandType.retracted:
          if(rawCommand.cmdValue is int){
            int msgId = rawCommand.cmdValue;
            ChatStorageSingle.updateStatus(msgId, SendStatus.retracted);
          }
          break;
        case CommandType.newPartner:
          if(rawCommand.cmdValue is int){
            int sponseId = rawCommand.cmdValue;
            int? userId = LocalUser.getUser()?.id;
            if(userId == null){
              break;
            }
            int? roomId;
            if(userId == sponseId){
              roomId = message.sendRoomId;
            }
            else{
              roomId = message.receiveRoomId;
            }
            if(roomId == null){
              break;
            }
            ImSingleRoom? room = await ChatHttpSingle.getRoom(roomId);
            if(room != null && room.ownnerId == userId){
              await ChatStorageSingle.saveRooms([room]);
              ChatEventBus().triggerEvent(ChatEventNewSingleRoom(room.id));
            }
          }
          break;
        default:
      }
    }
  }

}

class DefaultSingleStorageDealer extends SingleMessageDealer{
  DefaultSingleStorageDealer({super.inner});
  
  @override
  Future deal(ImSingleMessage message) async{
    inner?.deal(message);
    if(message.type != MessageType.command.getNum()){
      message.localId = ChatStorageSingle.nextMid;
      ChatStorageSingle.saveMessage(message).then((value){
        ChatStorageSingle.updateLatestMessage(message);
      });
    }
  }

}

class MessageContainerController{
  MessageContainerState? state;
}

class MessageContainerWidget extends StatefulWidget{
  
  final List<Widget> contents;
  final List<Widget> topBuffer;
  final List<Widget> bottomBuffer;
  final Function()? touchTop;
  final MessageContainerController? controller;
  final Function()? onScroll;
  final bool toBottom;
  const MessageContainerWidget({this.contents = const [], this.bottomBuffer = const [], this.topBuffer = const [], this.touchTop, this.controller, this.onScroll, this.toBottom = false, super.key});

  @override
  State<StatefulWidget> createState() {
    return MessageContainerState();
  }

}

class MessageContainerState extends State<MessageContainerWidget> with SingleTickerProviderStateMixin, WidgetsBindingObserver{
  static const double TOP_GESTURE_HEIGHT = 40;

  late List<Widget> contents;
  late List<Widget> topBuffer;
  late List<Widget> bottomBuffer;
  GlobalKey topBufferKey = GlobalKey();
  GlobalKey bottomBufferKey = GlobalKey();
  ScrollController currentScrollController = ScrollController();

  Timer? timer;
  bool onOperation = false;
  bool autoScroll = true;
  GlobalKey listenerKey = GlobalKey();
  GlobalKey contentKey = GlobalKey();
  double fullHeight = 0;
  bool emptyTag = true;
  double realHeight = 0;
  double keyboardHeight = 0;
  double extensionHeight = 0;

  static const int animMilliSecondsLong = 350;
  static const int animMilliSecondsShort = 80;
  late AnimationController animationController;

  late Function(Duration) frameCallback;

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    animationController = AnimationController(vsync: this, lowerBound: 0, upperBound: double.infinity,);
    if(widget.controller != null){
      widget.controller!.state = this;
    }
    currentScrollController.addListener(() {
      widget.onScroll?.call();
      if(onOperation){
        return;
      }
      onOperation = true;
      if(currentScrollController.offset >= currentScrollController.position.maxScrollExtent && widget.touchTop != null){
        widget.touchTop!();
      }
      onOperation = false;
      if(widget.touchTop != null && currentScrollController.offset >= currentScrollController.position.maxScrollExtent - TOP_GESTURE_HEIGHT){
        timer?.cancel();
        timer = Timer.periodic(const Duration(seconds: 1), (timer) { 
          if(!autoScroll){
            return;
          }
          if(currentScrollController.positions.isEmpty){
            timer.cancel();
            return;
          }
          int offset = (currentScrollController.position.maxScrollExtent - currentScrollController.offset).toInt();
          if(offset < TOP_GESTURE_HEIGHT){
            currentScrollController.animateTo(currentScrollController.position.maxScrollExtent - TOP_GESTURE_HEIGHT, duration: Duration(milliseconds: (TOP_GESTURE_HEIGHT.toInt() - offset) * 15), curve: Curves.ease);
          }
          timer.cancel();
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if(widget.touchTop != null){
        RenderBox? box = listenerKey.currentContext?.findRenderObject() as RenderBox?;
        if(box != null){
          fullHeight = box.size.height;
          animationController.value = fullHeight - realHeight;
          setState(() {
          });
        }
      }
    });
    emptyTag = widget.contents.isEmpty;
  }

  @override
  void dispose(){
    WidgetsBinding.instance.removeObserver(this);
    currentScrollController.dispose();
    animationController.dispose();
    super.dispose();
  }

  void rollToBottom(){
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      currentScrollController.animateTo(0, duration: const Duration(milliseconds: 350), curve: Curves.ease);
    });
  }

  @override
  Widget build(BuildContext context) {

    contents = widget.contents;
    topBuffer = widget.topBuffer;
    bottomBuffer = widget.bottomBuffer;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      RenderBox? box = contentKey.currentContext?.findRenderObject() as RenderBox?;
      if(box != null){
        realHeight = box.size.height;
        setState(() {
        });
        if(!animationController.isAnimating){
          double dY = fullHeight - keyboardHeight - extensionHeight - realHeight;
          if(dY < 0){
            dY = 0;
          }
          animationController.value = dY;
        }
      }
    });

    if(topBuffer.isNotEmpty){
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) { 
        RenderBox? box = topBufferKey.currentContext?.findRenderObject() as RenderBox?;
        if(box != null){
          double containerHeight = fullHeight - keyboardHeight - extensionHeight;
          if(realHeight < containerHeight){
            currentScrollController.animateTo(0, duration: const Duration(milliseconds: animMilliSecondsLong), curve: Curves.linear);
          }
          contents.insertAll(0, topBuffer);
          topBuffer.clear();
          if(realHeight < containerHeight){
            realHeight += box.size.height;
            animationController.animateTo(containerHeight > realHeight ? containerHeight - realHeight : 0, duration: const Duration(milliseconds: animMilliSecondsLong));
          }
          else{
            realHeight += box.size.height;
          }
          setState(() {
          });
        }
      });
    }
    if(bottomBuffer.isNotEmpty){
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) { 
        RenderBox? box = bottomBufferKey.currentContext?.findRenderObject() as RenderBox?;
        if(box != null){
          double height = box.size.height;
          double offset = currentScrollController.offset;
          contents.addAll(bottomBuffer);
          bottomBuffer.clear();          
          setState(() {
          });
          double containerHeight = fullHeight - keyboardHeight - extensionHeight;
          if(realHeight + box.size.height <= containerHeight){
            realHeight += box.size.height;
          }
          else{
            if(realHeight >= containerHeight){
              realHeight += box.size.height;
              currentScrollController.jumpTo(height + offset);
            }
            else{
              realHeight += box.size.height;
              currentScrollController.jumpTo(realHeight - containerHeight);
            }
          }
        }
      });
    }

    return Listener(
      key: listenerKey,
      onPointerDown: (event){
        autoScroll = false;
      },
      onPointerUp: (event){
        autoScroll = true;
      },
      child: Stack(
        children: [
          ListView(
            reverse: true,
            controller: currentScrollController,
            physics: const ClampingScrollPhysics(),
            children: [
              AnimatedBuilder(
                animation: animationController, 
                builder: (context, child){
                  return SizedBox(
                    height: animationController.value
                  );
                }
              ),
              Container(
                alignment: Alignment.topCenter,
                child: Column(
                  key: contentKey,
                  children: contents,
                ),
              ),
              widget.touchTop == null ?
              const SizedBox() :
              Container(
                alignment: Alignment.center,
                height: TOP_GESTURE_HEIGHT,
                child: const SizedBox(
                  width: 24,
                  height: 24,
                ),
              ),
            ],
          ),
          bottomBuffer.isEmpty ?
          const SizedBox() :
          UnconstrainedBox(
            clipBehavior: Clip.hardEdge,
            child: Opacity(
              opacity: 0,
              child: Wrap(
                key: bottomBufferKey,
                direction: Axis.vertical,
                children: bottomBuffer,
              ),
            ),
          ),
          topBuffer.isEmpty ?
          const SizedBox() :
          UnconstrainedBox(
            clipBehavior: Clip.hardEdge,
            child: Opacity(
              opacity: 0,
              child: Wrap(
                key: topBufferKey,
                direction: Axis.vertical,
                children: topBuffer,
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void didChangeMetrics(){
    super.didChangeMetrics();
    keyboardHeight = EdgeInsets.fromWindowPadding(
      WidgetsBinding.instance.window.viewInsets, 
      WidgetsBinding.instance.window.devicePixelRatio).bottom;
    if(extensionHeight == 0){
      animationController.value = fullHeight > realHeight + keyboardHeight ? fullHeight - realHeight - keyboardHeight : 0;
    }
  }

}

class BufferedContainerWidget extends StatefulWidget{

  final List<Widget> contents;
  final List<Widget> buffer;
  const BufferedContainerWidget({this.contents = const [], this.buffer = const [], super.key});

  @override
  State<StatefulWidget> createState() {
    return BufferedContainerState();
  }

}

class BufferedContainerState extends State<BufferedContainerWidget>{

  late List<Widget> contents;
  late List<Widget> buffer;
  GlobalKey wrapKey = GlobalKey();
  ScrollController currentScrollController = ScrollController();

  @override
  void initState(){
    super.initState();
  }

  @override
  void dispose(){
    currentScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    contents = widget.contents;
    buffer = widget.buffer;
    if(buffer.isNotEmpty){
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) { 
        RenderBox? box = wrapKey.currentContext?.findRenderObject() as RenderBox?;
        if(box != null){
          double height = box.size.height;
          double offset = currentScrollController.offset;
          contents.insertAll(0, buffer);
          buffer.clear();
          setState(() {
          });
          currentScrollController.jumpTo(height + offset);
        }
      });
    }
    return Stack(
      children: [
        ListView(
          controller: currentScrollController,
          children: contents,
        ),
        buffer.isEmpty ?
        const SizedBox() :
        Opacity(
          opacity: 0,
          child: Wrap(
            key: wrapKey,
            direction: Axis.vertical,
            children: buffer,
          ),
        ),
      ],
    );
  }

}
