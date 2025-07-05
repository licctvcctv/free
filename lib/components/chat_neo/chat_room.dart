
import 'dart:async';
import 'dart:convert' show json;
import 'dart:io';
import 'dart:ui' as ui;

import 'package:amap_flutter_base/amap_flutter_base.dart' as amap_flutter_base;
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/chat_neo/chat_common.dart';
import 'package:freego_flutter/components/chat_neo/chat_socket.dart';
import 'package:freego_flutter/components/chat_neo/chat_storage.dart';
import 'package:freego_flutter/components/chat_neo/chat_util.dart';
import 'package:freego_flutter/components/video/video_home.dart';
import 'package:freego_flutter/components/video/video_model.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/common_locate.dart';
import 'package:freego_flutter/components/view/common_map_show.dart';
import 'package:freego_flutter/components/view/file_viewer.dart';
import 'package:freego_flutter/components/view/image_group_viewer.dart';
import 'package:freego_flutter/components/view/image_viewer.dart';
import 'package:freego_flutter/components/view/tipoff.dart';
import 'package:freego_flutter/config/const_config.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/http/http_gaode.dart';
import 'package:freego_flutter/http/http_tipoff.dart';
import 'package:freego_flutter/http/http_tool.dart';
import 'package:freego_flutter/http/http_video.dart';
import 'package:freego_flutter/model/map_poi.dart';
import 'package:freego_flutter/model/user.dart';
import 'package:freego_flutter/util/context_util.dart';
import 'package:freego_flutter/util/date_time_util.dart';
import 'package:freego_flutter/util/file_upload_util.dart';
import 'package:freego_flutter/util/gaode_util.dart';
import 'package:freego_flutter/util/image_util.dart';
import 'package:freego_flutter/util/local_file_util.dart';
import 'package:freego_flutter/util/local_user.dart';
import 'package:freego_flutter/util/permission_util.dart';
import 'package:freego_flutter/util/route_observer.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:freego_flutter/util/user_home_director.dart';
import 'package:just_audio/just_audio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

class ChatRoomPage extends StatefulWidget{
  final ImSingleRoom room;
  const ChatRoomPage({required this.room, super.key});

  @override
  State<StatefulWidget> createState() {
    return ChatRoomPageState();
  }

}

class ChatRoomPageState extends State<ChatRoomPage> with RouteAware{

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    RouteObserverUtil().routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose(){
    RouteObserverUtil().routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 10,
        elevation: 0,
        backgroundColor: Colors.white,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      body: ChatRoomWidget(room: widget.room,),
    );
  }

}

class ChatRoomWidget extends StatefulWidget{
  final ImSingleRoom room;
  const ChatRoomWidget({required this.room, super.key});

  @override
  State<StatefulWidget> createState() {
    return ChatRoomState();
  }

}

class _MyChatMessageHandler extends ChatMessageHandler{

  final ChatRoomState _state;
  _MyChatMessageHandler(this._state) :super(priority: 10);

  @override
  Future handle(MessageObject rawObj) async{
    if(rawObj.name != ChatSocket.MESSAGE_SINGLE){
      return;
    }
    if(rawObj.body == null){
      return;
    }
    ImSingleMessage message = ImSingleMessage.fromJson(json.decoder.convert(rawObj.body!));
    if(message.receiveRoomId != _state.roomId && message.sendRoomId != _state.roomId){
      return;
    }
    if(message.type == null){
      return;
    }
    MessageType? messageType = MessageTypeExt.getType(message.type!);
    if(messageType == null){
      return;
    }
    switch(messageType){
      case MessageType.command:
      case MessageType.notifyCommand:
        if(message.content == null){
          break;
        }
        MessageCommand rawCommand = MessageCommand.fromText(message.content!);
        if(rawCommand.cmdType == null){
          break;
        }
        CommandType? commandType = CommandTypeExt.getType(rawCommand.cmdType!);
        if(commandType == null){
          break;
        }
        switch(commandType){
          case CommandType.sending:
            if(message.localId == null){
              break;
            }
            if(rawCommand.cmdValue is int){
              int msgId = rawCommand.cmdValue;
              int localId = message.localId!;
              for(ImSingleMessage message in _state.messageList.reversed){
                if(message.id == 0 && message.localId == localId){
                  message.id = msgId;
                  message.sendStatus = SendStatus.sending.getNum();
                  MessageController? controller = _state.msgControllerMap[message];
                  controller?.updateStatus();
                  break;
                }
              }
            }
            break;
          case CommandType.read:
            ImSingleRoom room = _state.widget.room;
            int? oldLastReadId = room.lastReadId;
            for(ImSingleMessage message in _state.messageList.reversed){
              if(message.sendRoomId == _state.roomId){
                if(room.lastReadId == null || message.id > room.lastReadId!){
                  room.lastReadId = message.id;
                }
                if(oldLastReadId != null && message.id < oldLastReadId){
                  break;
                }
                if(oldLastReadId == null || message.id > oldLastReadId){
                  MessageController? controller = _state.msgControllerMap[message];
                  controller?.read();
                }
              }
            }
            break;
          case CommandType.retractFail:
            ToastUtil.error('撤回失败');
            break;
          case CommandType.retracted:
            if(rawCommand.cmdValue is int){
              int msgId = rawCommand.cmdValue;
              for(ImSingleMessage message in _state.messageList.reversed){
                if(message.id == msgId){
                  message.sendStatus = SendStatus.retracted.getNum();
                  break;
                }
              }
              if(_state.onMenuMessage != null && _state.onMenuMessage!.id == msgId){
                _state.onMenuMessage = null;
                if(_state.quoteText != null){
                  String text = _state.textController.text;
                  if(text.startsWith(_state.quoteText!)){
                    text = text.substring(_state.quoteText!.length);
                    _state.textController.text = text;
                  }
                  _state.quoteText = '';
                }
              }
            }
            _state.messageList.add(message);
            _state.chatWidgets = _state.getMessageWidgets(_state.messageList);
            _state.resetState();
            break;
          default:
        }
        break;
      case MessageType.text:
      case MessageType.audio:
      case MessageType.image:
      case MessageType.location:
      case MessageType.file:
        DateTime? preTime = _state.messageList.isEmpty ? null : _state.messageList.last.sendTime;
        _state.chatBottomBuffers = _state.getMessageWidgets([message], preTime: preTime);
        _state.resetState();
        _state.messageList.add(message);
        ImSingleMessage reply = ChatUtilSingle.prepareReadMessage(_state.roomId);
        MessageObject rawMessage = ChatUtilSingle.getRawMessage(reply);
        ChatSocket.sendMessage(rawMessage);
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          _state._messageContainerController.state?.rollToBottom();
        });
        ChatStorageSingle.setLocalRead(_state.roomId);
        break;
      default:
    }
  }

}

class _MyReconnectHandler extends SocketReconnectHandler{

  final ChatRoomState _state;
  _MyReconnectHandler(this._state):super(priority: 99);

  @override
  Future handle() async{
    List<ImSingleMessage> messageList = _state.messageList;
    int? minId;
    for(ImSingleMessage message in messageList.reversed){
      if(message.id > 0 && message.receiveRoomId == _state.roomId){
        minId = message.id;
        break;
      }
    }
    List<ImSingleMessage> tmpList = await ChatStorageSingle.getNewReceiveMessageByRoom(_state.roomId, minId: minId);
    for(ImSingleMessage message in tmpList){
      if(message.receiveRoomId != _state.roomId && message.sendRoomId != _state.roomId){
        return;
      }
      if(message.type == null){
        return;
      }
      MessageType? messageType = MessageTypeExt.getType(message.type!);
      if(messageType == null){
        return;
      }
      switch(messageType){
        case MessageType.command:
        case MessageType.notifyCommand:
          if(message.content == null){
            break;
          }
          MessageCommand rawCommand = MessageCommand.fromText(message.content!);
          if(rawCommand.cmdType == null){
            break;
          }
          CommandType? commandType = CommandTypeExt.getType(rawCommand.cmdType!);
          if(commandType == null){
            break;
          }
          switch(commandType){
            case CommandType.retracted:
              if(rawCommand.cmdValue is int){
                int msgId = rawCommand.cmdValue;
                for(ImSingleMessage message in _state.messageList.reversed){
                  if(message.id == msgId){
                    message.sendStatus = SendStatus.retracted.getNum();
                    break;
                  }
                }
                if(_state.onMenuMessage != null && _state.onMenuMessage!.id == msgId){
                  _state.onMenuMessage = null;
                  if(_state.quoteText != null){
                    String text = _state.textController.text;
                    if(text.startsWith(_state.quoteText!)){
                      text = text.substring(_state.quoteText!.length);
                      _state.textController.text = text;
                    }
                    _state.quoteText = '';
                  }
                }
              }
              break;
            default:
          }
          break;
        default:
      }
    }
    DateTime? preTime = _state.messageList.isEmpty ? null : _state.messageList.last.sendTime;
    _state.chatBottomBuffers = _state.getMessageWidgets(tmpList, preTime: preTime);
    _state.resetState();
    _state.messageList.addAll(tmpList);
    ImSingleMessage reply = ChatUtilSingle.prepareReadMessage(_state.roomId);
    MessageObject rawMessage = ChatUtilSingle.getRawMessage(reply);
    ChatSocket.sendMessage(rawMessage);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _state._messageContainerController.state?.rollToBottom();
    });
    ChatStorageSingle.setLocalRead(_state.roomId);
  }
  
}

class ChatRoomState extends State<ChatRoomWidget> with TickerProviderStateMixin{
  static const int DEFAULT_INIT_LIMIT = 10;
  static const int DEFAULT_HISTORY_LIMIT = 10;

  static const int RECORD_MODE_ANIM_MILLI_SECONDS = 200;
  static const int RECORD_MODE_RHYTHM_SECONDS = 2;
  static const double RECORD_CANCEL_ICON_SIZE = 60;

  static const double IMAGE_MESSAGE_HEIGHT_MAX = 400;
  static const int MENU_MODE_ANIM_MILLI_SECONDS = 200;

  static const double QUOTE_IMAGE_WIDTH_MAX = 120;
  static const double QUOTE_IMAGE_HEIGHT_MAX = 200;

  late int roomId;
  late String? partnerName;
  late String? partnerHead;

  List<Widget> chatWidgets = [];
  List<Widget> chatTopBuffers = [];
  List<Widget> chatBottomBuffers = [];

  late String? localHead;
  late String? localName;

  List<ImSingleMessage> messageList = [];
  late _MyChatMessageHandler _messageHandler;
  final MessageContainerController _messageContainerController = MessageContainerController();
  bool inited = false;

  bool onRecordMode = false;
  late AnimationController recordShadow;
  late AnimationController rhythmController;
  late AnimationController beziereController;
  late Animation beziereAnimation;
  GlobalKey cancelKey = GlobalKey();
  bool voiceCanceled = false;
  final Record record = Record();
  final AudioPlayer audioPlayer = AudioPlayer();
  AudioMessageState? audioMessageState;

  List<String> imageUrlList = [];
  Map<ImSingleMessage, MessageController> msgControllerMap = {};

  double menuDy = 0;
  bool onMenuMode = false;  
  bool onMenuState = false;
  double menuTop = 0;
  bool menuOnTop = true;
  late AnimationController menuAnimController;
  ImSingleMessage? onMenuMessage;

  TextEditingController textController = TextEditingController();
  TextInputFocusNode textFocus = TextInputFocusNode();
  String? quoteText;

  late _MyReconnectHandler _myReconnectHandler;

  late AnimationController rightMenuAnim;
  bool rightMenuShow = false;
  static const int RIGHT_MENU_ANIM_MILLI_SECONDS = 150;
  static const double RIGHT_MENU_WIDTH = 100;
  static const double RIGHT_MENU_ITEM_HEIGHT = 40;

  @override
  void initState(){
    super.initState();

    roomId = widget.room.id;
    partnerName = widget.room.partnerName;
    partnerHead = widget.room.partnerHead;

    localHead = LocalUser.getUser()?.head;
    localName = LocalUser.getUser()?.name;

    Future.delayed(Duration.zero, () async{
      List<ImSingleMessage> tmpList = await ChatStorageSingle.getLocalMessageByRoom(roomId, limit: DEFAULT_INIT_LIMIT);
      if(tmpList.isEmpty){
        return;
      }
      tmpList = tmpList.reversed.toList();
      messageList = tmpList;
      chatTopBuffers = getMessageWidgets(messageList);
      inited = true;
      setState(() {
      });
      for(ImSingleMessage message in messageList){
        if(message.type == MessageType.image.getNum() && message.url != null){
          imageUrlList.add(getFullUrl(message.url!));
        }
      }
    });
    _messageHandler = _MyChatMessageHandler(this);
    ChatSocket.addMessageHandler(_messageHandler);
    _myReconnectHandler = _MyReconnectHandler(this);
    ChatSocket.addReconnectHandler(_myReconnectHandler);
    ChatSocket.init();

    recordShadow = AnimationController(vsync: this, lowerBound: 0, upperBound: 1, duration: const Duration(milliseconds: RECORD_MODE_ANIM_MILLI_SECONDS));
    rhythmController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    beziereController = AnimationController(vsync: this, duration: const Duration(milliseconds: RECORD_MODE_ANIM_MILLI_SECONDS));
    beziereAnimation = Tween(begin: 60.0, end: -60.0).animate(beziereController);

    // 发送已读命令
    Future.delayed(Duration.zero, () async{
      ChatStorageSingle.setLocalRead(roomId);
      ImSingleMessage reply = ChatUtilSingle.prepareReadMessage(roomId);
      MessageObject rawMessage = ChatUtilSingle.getRawMessage(reply);
      ChatSocket.sendMessage(rawMessage);
    });

    menuAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: MENU_MODE_ANIM_MILLI_SECONDS));
    BuildContext? outerContext = ContextUtil.getContext();
    if(outerContext != null){
      menuDy = ThemeUtil.getStatusBarHeight(outerContext) + 10;
    }

    rightMenuAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: RIGHT_MENU_ANIM_MILLI_SECONDS));
  }

  @override
  void dispose(){
    ChatSocket.removeMessageHandler(_messageHandler);
    ChatSocket.removeReconnectHandler(_myReconnectHandler);

    recordShadow.dispose();
    rhythmController.dispose();
    beziereController.dispose();
    record.dispose();
    for(MessageController msgController in msgControllerMap.values){
      msgController.dispose();
    }
    menuAnimController.dispose();
    rightMenuAnim.dispose();
    textController.dispose();
    textFocus.dispose();
    super.dispose();
  }

  void enterMenuMode(){
    menuAnimController.reverse().then((value){
      onMenuState = onMenuMode = true;
      setState(() {
      });
      menuAnimController.forward();
    });
  }

  void leaveMenuMode(){
    if(!onMenuState){
      return;
    }
    onMenuState = false;
    menuAnimController.reverse().then((value){
      onMenuMode = false;
      setState(() {
      });
    });
  }

  void enterRecordMode(){
    onRecordMode = true;
    setState(() {
    });
    recordShadow.forward();
    rhythmController.repeat();
    beziereController.forward();
  }

  void leaveRecordMode(){
    recordShadow.reverse().then((value){
      onRecordMode = false;
      setState(() {
      });
      rhythmController.reset();
    });
    beziereController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Listener(
          onPointerDown: (evt){
            leaveMenuMode();
            if(rightMenuShow){
              rightMenuShow = false;
              rightMenuAnim.reverse();
              return;
            }
          },
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonHeader(
                  center: InkWell(
                    onTap: (){
                      int? partnerId = widget.room.partnerId;
                      if(partnerId == null){
                        return;
                      }
                      UserHomeDirector().goUserHome(context: context, userId: partnerId);
                    },
                    child: Text(partnerName ?? '未知', style: const TextStyle(color: Colors.white, fontSize: 14),)
                  ),
                  right: InkWell(
                    onTap: (){
                      if(!rightMenuShow){
                        rightMenuAnim.forward();
                      }
                      else{
                        rightMenuAnim.reverse();
                      }
                      rightMenuShow = !rightMenuShow;
                      setState(() {
                      });
                    },
                    child: const Icon(Icons.more_vert_rounded, color: Colors.white,),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: (){
                      FocusScope.of(context).unfocus();
                    },
                    behavior: HitTestBehavior.translucent,
                    child: MessageContainerWidget(
                      contents: chatWidgets,
                      topBuffer: chatTopBuffers,
                      bottomBuffer: chatBottomBuffers,
                      controller: _messageContainerController,
                      onScroll: leaveMenuMode,
                      toBottom: inited,
                      touchTop: () async{
                        int? maxId;
                        int? maxUnsentId;
                        DateTime? maxSendTime;
                        if(messageList.isNotEmpty){
                          for(ImSingleMessage message in messageList){
                            if(maxId == null && message.id > 0){
                              maxId = message.id;
                              maxSendTime = message.sendTime;
                            }
                            if(maxUnsentId == null && message.id == 0){
                              maxUnsentId = message.localId;
                            }
                            if(maxId != null && maxUnsentId != null){
                              break;
                            }
                          }
                        }
                        if(maxId == 0){
                          maxId = null;
                        }
                        List<ImSingleMessage>? tmpList = await ChatUtilSingle.getHistory(roomId, maxId: maxId, limit: DEFAULT_HISTORY_LIMIT, maxSendTime: maxSendTime, maxUnsentId: maxUnsentId);
                        if(tmpList == null || tmpList.isEmpty){
                          ToastUtil.hint('已经没有消息了');
                          return;
                        }
                        tmpList = tmpList.reversed.toList();
                        chatTopBuffers = getMessageWidgets(tmpList);
                        setState(() {
                        });
                        messageList.insertAll(0, tmpList);
                        for(ImSingleMessage message in tmpList.reversed){
                          if(message.type == MessageType.image.getNum() && message.url != null){
                            imageUrlList.insert(0, getFullUrl(message.url!));
                          }
                        }
                      },
                    ),
                  )
                ),
                KeyboardWidget(
                  textController: textController,
                  textFocus: textFocus,
                  listener: KeyboardListener(
                    onSendText: (str) async{
                      bool quoted = false;
                      if(quoteText != null && str.startsWith(quoteText!)){
                        if(str.length == quoteText!.length){
                          ToastUtil.warn('请输入内容');
                          return;
                        }
                        quoted = true;
                        str = str.substring(quoteText!.length);
                      }
                      ImSingleMessage message = ChatUtilSingle.prepareTextMessage(roomId, str, quote: quoted ? onMenuMessage : null);
                      ChatStorageSingle.saveMessage(message);
                      MessageObject rawMessage = ChatUtilSingle.getRawMessage(message);
                      ChatSocket.sendMessage(rawMessage);
                      chatBottomBuffers = getMessageWidgets([message], preTime: messageList.isEmpty ? null : messageList.last.sendTime);
                      setState(() {
                      });
                      messageList.add(message);
                      textController.text = '';
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                        _messageContainerController.state?.rollToBottom();
                      });
                    },
                    onShowKeyboard: (){
                      if(_messageContainerController.state != null){
                        Future.delayed(const Duration(milliseconds: KeyboardState.ANIM_MILLI_SECONDS ~/ 2), (){
                          _messageContainerController.state!.extensionHeight = 0;
                        });
                      }
                    },
                    onShowEmoji: (){
                      if(_messageContainerController.state != null){
                        double listenerHeight = _messageContainerController.state!.fullHeight;
                        double realHeigh = _messageContainerController.state!.realHeight;
                        _messageContainerController.state!.extensionHeight = KeyboardState.EMOJI_LIST_HEIGHT;
                        double target = listenerHeight - realHeigh - KeyboardState.EMOJI_LIST_HEIGHT;
                        if(target < 0){
                          target = 0;
                        }
                        _messageContainerController.state!.animationController.animateTo(target, duration: const Duration(milliseconds: KeyboardState.ANIM_MILLI_SECONDS));
                      }
                    },
                    onShowExt: (){
                      if(_messageContainerController.state != null){
                        double listenerHeight = _messageContainerController.state!.fullHeight;
                        double realHeight = _messageContainerController.state!.realHeight;
                        _messageContainerController.state!.extensionHeight = KeyboardState.EXT_LIST_HEIGHT;
                        double target = listenerHeight - realHeight - KeyboardState.EXT_LIST_HEIGHT;
                        if(target < 0){
                          target = 0;
                        }
                        _messageContainerController.state!.animationController.animateTo(target, duration: const Duration(milliseconds: KeyboardState.ANIM_MILLI_SECONDS));
                      }
                    },
                    onHide: (){
                      if(_messageContainerController.state != null){
                        double listenerHeight = _messageContainerController.state!.fullHeight;
                        double realHeight = _messageContainerController.state!.realHeight;
                        double target = listenerHeight - realHeight;
                        if(target < 0){
                          target = 0;
                        }
                        _messageContainerController.state!.animationController.animateTo(target, duration: const Duration(milliseconds: KeyboardState.ANIM_MILLI_SECONDS)).then((value){
                          _messageContainerController.state!.extensionHeight = 0;
                        });
                      }
                    },
                    onVoiceBegin: () async{
                      bool isGranted = await PermissionUtil().requestPermission(context: context, permission: Permission.microphone, info: '希望获取麦克分权限用于录制语音');
                      if(!isGranted){
                        ToastUtil.error('获取录音权限失败');
                        return;
                      }
                      if(!await record.hasPermission()){
                        return;
                      }
                      int? userId = LocalUser.getUser()?.id;
                      if(userId == null){
                        ToastUtil.error('获取当前用户失败');
                        return;
                      }
                      enterRecordMode();
                      voiceCanceled = false;
                      Directory dir = await getApplicationDocumentsDirectory();
                      Directory saveDir = Directory('${dir.path}/audio');
                      if(!await saveDir.exists()){
                        saveDir.create(recursive: true);
                      }
                      int timeStamp = DateTime.now().millisecondsSinceEpoch;
                      String path = '${dir.path}/audio/${userId}_$timeStamp.m4a';
                      record.start(path: path);
                    },
                    onVoiceEnd: () async{
                      if(voiceCanceled){
                        return;
                      }
                      leaveRecordMode();
                      if(!await record.isRecording()){
                        ToastUtil.error('录音出错');
                        return;
                      }
                      String? path = await record.stop();
                      if(path == null){
                        ToastUtil.error('录音失败');
                        return;
                      }
                      //String name = path.substring(path.lastIndexOf('/') + 1, path.length);
                      String? url = await FileUploadUtil().upload(path: path);
                      if(url == null){
                        ToastUtil.error('上传失败');
                        return;
                      }
                      final AudioPlayer audioPlayer = AudioPlayer();
                      Duration? duration = await audioPlayer.setFilePath(path);
                      audioPlayer.dispose();
                      ImSingleMessage message = ChatUtilSingle.prepareAudioMessage(roomId, url, duration);
                      ChatStorageSingle.saveMessage(message);
                      MessageObject rawMessage = ChatUtilSingle.getRawMessage(message);
                      ChatSocket.sendMessage(rawMessage);
                      chatBottomBuffers = getMessageWidgets([message], preTime: messageList.isEmpty ? null : messageList.last.sendTime);
                      setState(() {
                      });
                      messageList.add(message);
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                        _messageContainerController.state?.rollToBottom();
                      });
                    },
                    onVoiceUpdate: (detail){
                      RenderBox? renderBox = cancelKey.currentContext?.findRenderObject() as RenderBox?;
                      if(renderBox == null){
                        return;
                      }
                      Offset touchPosition = detail.globalPosition;
                      Offset iconCenter = renderBox.localToGlobal(const Offset(RECORD_CANCEL_ICON_SIZE / 2, RECORD_CANCEL_ICON_SIZE / 2));
                      double dx = touchPosition.dx - iconCenter.dx;
                      double dy = touchPosition.dy - iconCenter.dy;
                      if(dx * dx + dy * dy < (RECORD_CANCEL_ICON_SIZE / 2) * (RECORD_CANCEL_ICON_SIZE / 2)){
                        voiceCanceled = true;
                        leaveRecordMode();
                      }
                    },
                    onTapPhoto: () async{
                      bool isGranted = await PermissionUtil().requestPermission(context: context, permission: Permission.storage, info: '希望获取存储权限用于发送照片');
                      if(!isGranted){
                        ToastUtil.error('获取照片权限失败');
                        return;
                      }
                      if(context.mounted){
                        AssetPickerConfig config = ImageUtil.buildDefaultImagePickerConfig();
                        final List<AssetEntity>? results = await AssetPicker.pickAssets(
                          context,
                          pickerConfig: config,
                        );
                        if(results == null || results.isEmpty){
                          return;
                        }
                        AssetEntity entity = results[0];
                        File? file = await entity.file;
                        if(file == null){
                          ToastUtil.error('获取路径失败');
                          return;
                        }
                        String path = file.path;
                        //String name = path.substring(path.lastIndexOf('/') + 1, path.length);
                        String? url = await FileUploadUtil().upload(path: path);
                        if(url == null){
                          ToastUtil.error('文件上传失败');
                          return;
                        }
                        ImSingleMessage message = ChatUtilSingle.prepareImageMessage(roomId, url, width: entity.width, height: entity.height);
                        ChatStorageSingle.saveMessage(message);
                        MessageObject rawMessage = ChatUtilSingle.getRawMessage(message);
                        ChatSocket.sendMessage(rawMessage);
                        chatBottomBuffers = getMessageWidgets([message], preTime: messageList.isEmpty ? null : messageList.last.sendTime);
                        setState(() {
                        });
                        messageList.add(message);
                        imageUrlList.add(getFullUrl(url));
                        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                          _messageContainerController.state?.rollToBottom();
                        });
                      }
                    },
                    onTapCamera: () async{
                      bool isGranted = await PermissionUtil().requestPermission(context: context, permission: Permission.camera, info: '希望获取相机权限用于拍照');
                      if(!isGranted){
                        ToastUtil.error('获取相机权限失败');
                        return;
                      }
                      CameraPickerConfig config = const CameraPickerConfig(
                        enableRecording: false,
                      );
                      if(context.mounted){
                        final AssetEntity? asset = await CameraPicker.pickFromCamera(
                          context,
                          pickerConfig: config
                        );
                        if(asset == null){
                          return;
                        }
                        String? url;
                        if(asset.type == AssetType.image || asset.type == AssetType.video){
                          File? file = await asset.file;
                          if(file == null){
                            ToastUtil.error('获取路径失败');
                            return;
                          }
                          String path = file.path;
                          //String name = path.substring(path.lastIndexOf('/') + 1, path.length);
                          url = await FileUploadUtil().upload(path: path);
                        }
                        if(url == null){
                          ToastUtil.error('上传文件失败');
                          return;
                        }
                        ImSingleMessage? message;
                        if(asset.type == AssetType.image){
                          message = ChatUtilSingle.prepareImageMessage(roomId, url, width: asset.width, height: asset.height);
                        }
                        else if(asset.type == AssetType.video){
                          message = ChatUtilSingle.prepareVideoMessage(roomId, url, width: asset.width, height: asset.width, millis: asset.duration);
                        }
                        if(message == null){
                          return;
                        }
                        ChatStorageSingle.saveMessage(message);
                        MessageObject rawMessage = ChatUtilSingle.getRawMessage(message);
                        ChatSocket.sendMessage(rawMessage);
                        chatBottomBuffers = getMessageWidgets([message], preTime: messageList.isEmpty ? null : messageList.last.sendTime);
                        setState(() {
                        });
                        messageList.add(message);
                        if(message.type == MessageType.image.getNum()){
                          imageUrlList.add(getFullUrl(url));
                        }
                        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                          _messageContainerController.state?.rollToBottom();
                        });
                      }
                    },
                    onTapLocation: () async{
                      dynamic poi = await Navigator.of(context).push(MaterialPageRoute(builder: (context){
                        return const CommonLocatePage();
                      }));
                      if(poi is MapPoiModel){
                        if(poi.address == null || poi.lat == null || poi.lng == null){
                          return;
                        }
                        ImSingleMessage message = ChatUtilSingle.prepareLocationMessage(roomId, poi.address!, latitude: poi.lat!, longitude: poi.lng!);
                        ChatStorageSingle.saveMessage(message);
                        MessageObject rawMessage = ChatUtilSingle.getRawMessage(message);
                        ChatSocket.sendMessage(rawMessage);
                        chatBottomBuffers = getMessageWidgets([message], preTime: messageList.isEmpty ? null : messageList.last.sendTime);
                        setState(() {
                        });
                        messageList.add(message);
                        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                          _messageContainerController.state?.rollToBottom();
                        });
                      }
                    },
                    onTapFile: () async{
                      if(Platform.isAndroid){
                        bool isGranted = await PermissionUtil().requestPermission(context: context, permission: Permission.manageExternalStorage, info: '希望获取外部存储权限用于发送文件');
                        if(!isGranted){
                          ToastUtil.error('获取存储权限失败');
                          return;
                        }
                        if(context.mounted){
                          dynamic path = await Navigator.of(context).push(MaterialPageRoute(builder: (context){
                            return const FileViewerPage();
                          }));
                          if(path is String){
                            File file = File(path);
                            if(!file.existsSync()){
                              ToastUtil.error('文件不存在!');
                              return;
                            }
                            String name = path.substring(path.lastIndexOf('/') + 1);
                            String? url = await FileUploadUtil().upload(path: path);
                            if(url == null){
                              ToastUtil.error('文件上传失败');
                              return;
                            }
                            ImSingleMessage message = ChatUtilSingle.prepareFileMessage(roomId, url: url, name: name, localPath: path, bytes: file.lengthSync());
                            ChatStorageSingle.saveMessage(message);
                            MessageObject rawMessage = ChatUtilSingle.getRawMessage(message);
                            ChatSocket.sendMessage(rawMessage);
                            chatBottomBuffers = getMessageWidgets([message], preTime: messageList.isEmpty ? null : messageList.last.sendTime);
                            setState(() {
                            });
                            messageList.add(message);
                            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                              _messageContainerController.state?.rollToBottom();
                            });
                          }
                        }
                      }
                      else if(Platform.isIOS){
                        String? path = await FlutterDocumentPicker.openDocument();
                        if(path == null){
                          return;
                        }
                        File file = File(path);
                        if(!file.existsSync()){
                          ToastUtil.error('文件不存在');
                          return;
                        }
                        String name = path.substring(path.lastIndexOf('/') + 1);
                        String? url = await FileUploadUtil().upload(path: path);
                        if(url == null){
                          ToastUtil.error('文件上传失败');
                          return;
                        }
                        ImSingleMessage message = ChatUtilSingle.prepareFileMessage(roomId, url: url, name: name, localPath: path, bytes: file.lengthSync());
                        ChatStorageSingle.saveMessage(message);
                        MessageObject rawMessage = ChatUtilSingle.getRawMessage(message);
                        ChatSocket.sendMessage(rawMessage);
                        chatBottomBuffers = getMessageWidgets([message], preTime: messageList.isEmpty ? null : messageList.last.sendTime);
                        setState(() {
                        });
                        messageList.add(message);
                        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                          _messageContainerController.state?.rollToBottom();
                        });
                      }
                      else{
                        ToastUtil.error('不支持的平台类型');
                      }
                    }
                  ),
                )
              ],
            ),
          ),
        ),
        Visibility(
          visible: onMenuMode,
          child: Stack(
            children: [
              onMenuMessage?.sendRoomId == roomId ?
              Positioned(
                top: menuTop,
                right: 60,
                child: AnimatedBuilder(
                  animation: menuAnimController, 
                  builder: (context, child){
                    return Transform.scale(
                      scale: menuAnimController.value,
                      alignment: menuOnTop ? Alignment.bottomRight : Alignment.topRight,
                      child: Opacity(
                        opacity: menuAnimController.value,
                        child: LocalMessageMenuWidget(
                          menuOnTop: menuOnTop,
                          onTapRetract: (){
                            if(onMenuMessage == null){
                              return;
                            }
                            if(onMenuMessage!.id == 0){
                              ToastUtil.error('消息发送中');
                              return;
                            }
                            ImSingleMessage message = ChatUtilSingle.prepareRetractMessage(roomId, onMenuMessage!.id);
                            MessageObject rawMessage = ChatUtilSingle.getRawMessage(message);
                            ChatSocket.sendMessage(rawMessage);
                            leaveMenuMode();
                          },
                          onTapQuote: (){
                            if(onMenuMessage == null || onMenuMessage!.type == null){
                              return;
                            }
                            MessageType? type = MessageTypeExt.getType(onMenuMessage!.type!);
                            if(type == null){
                              return;
                            }
                            switch(type){
                              case MessageType.text:
                                if(onMenuMessage!.content == null){
                                  return;
                                }
                                quoteText = StringUtil.getLimitedText(onMenuMessage!.content!, ChatUtilConstants.QUOTE_SHOW_SIZE_MAX);
                                if(quoteText == null || quoteText!.isEmpty){
                                  return;
                                }
                                break;
                              case MessageType.image:
                                if(onMenuMessage!.url == null){
                                  ToastUtil.error('链接错误');
                                  return;
                                }
                                quoteText = '[图片]';
                                break;
                              case MessageType.audio:
                                if(onMenuMessage!.url == null){
                                  ToastUtil.error('链接错误');
                                  return;
                                }
                                quoteText = '[音频]';
                                break;
                              case MessageType.file:
                                if(onMenuMessage!.url == null){
                                  ToastUtil.error('链接错误');
                                  return;
                                }
                                bool setQuoteText = false;
                                if(onMenuMessage!.content != null){
                                  Map<String, Object?> map = json.decoder.convert(onMenuMessage!.content!);
                                  if(map['name'] is String){
                                    quoteText = StringUtil.getLimitedText(map['name'] as String, ChatUtilConstants.QUOTE_SHOW_SIZE_MAX);
                                    setQuoteText = true;
                                  }
                                }
                                if(!setQuoteText){
                                  quoteText = '[文件]';
                                }
                                break;
                              case MessageType.location:
                                bool setQuoteText = false;
                                if(onMenuMessage!.content != null){
                                  Map<String, Object?> map = json.decoder.convert(onMenuMessage!.content!);
                                  if(map['address'] is String){
                                    quoteText = StringUtil.getLimitedText(map['address'] as String, ChatUtilConstants.QUOTE_SHOW_SIZE_MAX);
                                    setQuoteText = true;
                                  }
                                }
                                if(!setQuoteText){
                                  quoteText = '[地址]';
                                }
                                break;
                              case MessageType.freegoVideo:
                                if(onMenuMessage!.content == null){
                                  return;
                                }
                                quoteText = '[视频]';
                                break;
                              default:
                                return;
                            }
                            quoteText = MessageQuoteText.startTag + quoteText! + MessageQuoteText.endTag;
                            textController.text = quoteText!;
                            textController.selection = TextSelection(baseOffset: quoteText!.length, extentOffset: quoteText!.length);
                            FocusScope.of(context).requestFocus(textFocus);
                            leaveMenuMode();
                          },
                          onTapDelete: (){
                            if(onMenuMessage == null || onMenuMessage!.localId == null){
                              return;
                            }
                            onMenuMessage!.sendStatus = SendStatus.deleted.getNum();
                            ChatStorageSingle.deleteMessage(onMenuMessage!.localId!).then((value){
                              chatWidgets = getMessageWidgets(messageList);
                              setState(() {
                              });
                            });
                            leaveMenuMode();
                          }
                        )
                      ),
                    );
                  }
                ),
              ) :
              Positioned(
                top: menuTop,
                left: 60,
                child: AnimatedBuilder(
                  animation: menuAnimController,
                  builder: (context, child){
                    return Transform.scale(
                      scale: menuAnimController.value,
                      alignment: menuOnTop ? Alignment.bottomLeft : Alignment.topLeft,
                      child: Opacity(
                        opacity: menuAnimController.value,
                        child: RemoteMessageMenuWidget(
                          menuOnTop: menuOnTop,
                          onTapQuote: (){
                            if(onMenuMessage == null || onMenuMessage!.type == null){
                              return;
                            }
                            MessageType? type = MessageTypeExt.getType(onMenuMessage!.type!);
                            if(type == null){
                              return;
                            }
                            switch(type){
                              case MessageType.text:
                                if(onMenuMessage!.content == null){
                                  return;
                                }
                                quoteText = StringUtil.getLimitedText(onMenuMessage!.content!, ChatUtilConstants.QUOTE_SHOW_SIZE_MAX);
                                if(quoteText == null || quoteText!.isEmpty){
                                  return;
                                }
                                break;
                              case MessageType.image:
                                if(onMenuMessage!.url == null){
                                  ToastUtil.error('链接错误');
                                  return;
                                }
                                quoteText = '[图片]';
                                break;
                              case MessageType.audio:
                                if(onMenuMessage!.url == null){
                                  ToastUtil.error('链接错误');
                                  return;
                                }
                                quoteText = '[音频]';
                                break;
                              case MessageType.file:
                                if(onMenuMessage!.url == null){
                                  ToastUtil.error('链接错误');
                                  return;
                                }
                                bool setQuoteText = false;
                                if(onMenuMessage!.content != null){
                                  Map<String, Object?> map = json.decoder.convert(onMenuMessage!.content!);
                                  if(map['name'] is String){
                                    quoteText = StringUtil.getLimitedText(map['name'] as String, ChatUtilConstants.QUOTE_SHOW_SIZE_MAX);
                                    setQuoteText = true;
                                  }
                                }
                                if(!setQuoteText){
                                  quoteText = '[文件]';
                                }
                                break;
                              case MessageType.location:
                                bool setQuoteText = false;
                                if(onMenuMessage!.content != null){
                                  Map<String, Object?> map = json.decoder.convert(onMenuMessage!.content!);
                                  if(map['address'] is String){
                                    quoteText = StringUtil.getLimitedText(map['address'] as String, ChatUtilConstants.QUOTE_SHOW_SIZE_MAX);
                                    setQuoteText = true;
                                  }
                                }
                                if(!setQuoteText){
                                  quoteText = '[地址]';
                                }
                                break;
                              default:
                                return;
                            }
                            quoteText = MessageQuoteText.startTag + quoteText! + MessageQuoteText.endTag;
                            textController.text = quoteText!;
                            textController.selection = TextSelection(baseOffset: quoteText!.length, extentOffset: quoteText!.length);
                            FocusScope.of(context).requestFocus(textFocus);
                            leaveMenuMode();
                          },
                          onTapDelete: (){
                            if(onMenuMessage == null || onMenuMessage!.localId == null){
                              return;
                            }
                            onMenuMessage!.sendStatus = SendStatus.deleted.getNum();
                            ChatStorageSingle.deleteMessage(onMenuMessage!.localId!).then((value){
                              chatWidgets = getMessageWidgets(messageList);
                              setState(() {
                              });
                            });
                            leaveMenuMode();
                          }
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: AnimatedBuilder(
            animation: rightMenuAnim,
            builder: (context, child) {
              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: rightMenuAnim.value * RIGHT_MENU_ITEM_HEIGHT
                ),
                child: Wrap(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap
                      ),
                      onPressed: showTipoffModal,
                      child: Container(
                        width: RIGHT_MENU_WIDTH,
                        height: RIGHT_MENU_ITEM_HEIGHT,
                        decoration: const BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(12)
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 2
                            )
                          ]
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.info_outline_rounded, color: Colors.white,),
                            SizedBox(width: 8,),
                            Text('举报', style: TextStyle(color: Colors.white),),
                          ],
                        )
                      ),
                    )
                  ],
                ),
              );
            }
          )
        ),
        Visibility(
          visible: onRecordMode,
          child: Stack(
            children: [
              FadeTransition(
                opacity: recordShadow,
                child: Container(
                  color: const Color.fromRGBO(128, 128, 128, 0.5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 180,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color.fromRGBO(0x95, 0xec, 0x69, 1)
                        ),
                        clipBehavior: Clip.hardEdge,
                        alignment: Alignment.center,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const NeverScrollableScrollPhysics(),
                          child: SlideTransition(
                            position: rhythmController.drive(Tween(begin: const Offset(-0.5, 0), end: const Offset(0, 0))),
                            child: Row(
                              children: [
                                Image.asset('images/chat/recording.png', width: 180, height: 80, fit: BoxFit.cover),
                                Image.asset('images/chat/recording.png', width: 180, height: 80, fit: BoxFit.cover)
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40,),
                      Container(
                        key: cancelKey,
                        width: RECORD_CANCEL_ICON_SIZE,
                        height: RECORD_CANCEL_ICON_SIZE,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(RECORD_CANCEL_ICON_SIZE / 2),
                          color: Colors.white
                        ),
                        alignment: Alignment.center,
                        child: const Text('取消'),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        height: 100,
                        child: AnimatedBuilder(
                          animation: beziereAnimation,
                          builder: (context, child){
                            final size = MediaQuery.of(context).size;
                            return CustomPaint(
                              key: const ValueKey('beziere'),
                              painter: PathPainter(
                                strokeColor: const Color.fromRGBO(0x77, 0x77, 0x77, 0.6),
                                paintingStyle: PaintingStyle.fill,
                                strokeWidth: 1,
                                makePath: (){
                                  var path = Path();
                                  path.moveTo(0, 60);
                                  path.quadraticBezierTo(size.width / 2, beziereAnimation.value, size.width, 60);
                                  path.lineTo(size.width, 100);
                                  path.lineTo(0, 100);
                                  path.lineTo(0, 60);
                                  return path;
                                }
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  void showTipoffModal(){
    int? partnerId = widget.room.partnerId;
    if(partnerId == null){
      return;
    }
    showModalBottomSheet(
      isDismissible: true,
      isScrollControlled: true,
      context: context,
      builder: (context){
        return TipOffWidget(targetId: partnerId, type: TipoffType.user);
      }
    );
  }

  Widget? getMessageQuoteWidget(ImSingleMessage message){
    if(message.quoteType == null){
      return null;
    }
    MessageType? type = MessageTypeExt.getType(message.quoteType!);
    switch(type){
      case MessageType.text:
        if(message.quoteContent == null){
          return null;
        }
        return Text(message.quoteContent!);
      case MessageType.image:
        if(message.quoteUrl == null){
          return null;
        }
        int height = 0;
        int width = 0;
        Map<String, Object?> contentMap = json.decoder.convert(message.quoteContent!);
        if(contentMap['width'] is int){
          width = contentMap['width'] as int;
        }
        if(contentMap['height'] is int){
          height = contentMap['height'] as int;
        }
        Widget imageWidget = Image.network(
          getFullUrl(message.quoteUrl!),
          fit: BoxFit.fitHeight, 
          loadingBuilder: (context, child, progress){
            if(progress == null || progress.expectedTotalBytes == null){
              return child;
            }
            return Center(
              child: CircularProgressIndicator(
                value: progress.cumulativeBytesLoaded / progress.expectedTotalBytes!,
              ),
            );
          },
        );
        return ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: QUOTE_IMAGE_WIDTH_MAX,
            maxHeight: QUOTE_IMAGE_HEIGHT_MAX
          ),
          child: InkWell(
            onTap: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context){
                return ImageViewer(getFullUrl(message.quoteUrl!));
              }));
            },
            child: height > 0 && width > 0 ?
            AspectRatio(
              aspectRatio: width / height,
              child: imageWidget,
            ):
            imageWidget,
          )
        );
      case MessageType.audio:
        if(message.quoteUrl == null){
          return null;
        }
        int millis = 0;
        if(message.quoteContent != null){
          Map<String, Object?> contentMap = json.decoder.convert(message.quoteContent!);
          if(contentMap['millis'] is int){
            millis = contentMap['millis'] as int;
          }
        }
        return AudioMessageWidget(url: message.quoteUrl!, millis: millis,);
      case MessageType.location:
        String? address;
        double? latitude;
        double? longitude;
        if(message.quoteContent != null){
          Map<String, Object?> contentMap = json.decoder.convert(message.quoteContent!);
          if(contentMap['address'] is String){
            address = contentMap['address'] as String;
          }
          if(contentMap['latitude'] is double){
            latitude = contentMap['latitude'] as double;
          }
          if(contentMap['longitude'] is double){
            longitude = contentMap['longitude'] as double;
          }
        }
        if(latitude == null || longitude == null){
          return null;
        }
        address ??= '[地址]';
        return InkWell(
          onTap: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context){
              return CommonMapShowPage(address: address!, latitude: latitude!, longitude: longitude!,);
            }));
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on),
              Expanded(
                child: Text(address),
              )
            ],
          )
        );
      case MessageType.file:
        String fileName = '[文件]';
        if(message.quoteContent != null){
          Map<String, Object?> contentMap = json.decoder.convert(message.quoteContent!);
          if(contentMap['name'] is String){
            fileName = contentMap['name'] as String;
          }
        }
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('文件：'),
            Expanded(
              child: Text(fileName),
            )
          ],
        );
      case MessageType.freegoVideo:
        if(message.quoteContent != null){
          Map<String, Object?> content = json.decoder.convert(message.quoteContent!);
          Object? videoId = content['id'];
          Object? name = content['name'];
          Object? cover = content['cover'];
          if(videoId is! int || name is! String || cover is! String?){
            return null;
          }
          if(cover != null){
            cover = getFullUrl(cover);
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () async{
                  VideoModel? video = await HttpVideo.getById(videoId);
                  if(video == null){
                    ToastUtil.error('目标已失效');
                  }
                  if(context.mounted){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context){
                      return VideoHomePage(initVideo: video,);
                    }));
                  }
                },
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          color: Colors.black,
                        ),
                        if(cover != null)
                        Image.network(
                          cover
                        ),
                        ClipOval(
                          child: Container(
                            color: const Color.fromRGBO(0, 0, 0, 0.7),
                            child: const Icon(Icons.play_arrow, color: Colors.white, size: 40,),
                          ),
                        )
                      ],
                    )
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                child: Text(name, style: const TextStyle(color: ThemeUtil.foregroundColor),),
              )
            ],
          );
        }
        break;
      default:
        return null;
    }
    return null;
  }

  List<Widget> getMessageWidgets(List<ImSingleMessage> messages, {DateTime? preTime}) {
    List<Widget> widgets = [];
    DateTime now = DateTime.now();
    for(ImSingleMessage message in messages){
      if(message.type == null){
        continue;
      }
      MessageType? type = MessageTypeExt.getType(message.type!);
      switch(type){
        case MessageType.command:
        case MessageType.notifyCommand:
          if(message.content == null){
            continue;
          }
          if(message.sendTime == null){
            continue;
          }
          MessageCommand<Object> rawCmd = MessageCommand.fromText(message.content!);
          if(rawCmd.cmdType == null){
            continue;
          }
          CommandType? commandType = CommandTypeExt.getType(rawCmd.cmdType!);
          if(commandType == null){
            continue;
          }
          switch(commandType){
            case CommandType.retracted:
              const String remoteInfo = '对方撤回了一条消息';
              const String localInfo = '您撤回了一条消息';
              if(preTime == null || message.sendTime!.difference(preTime).inMinutes >= 1){
                preTime = message.sendTime;
                widgets.add(SystemMessageWidget(DateTimeUtil.getSimpleTime(now, preTime!)));
              }
              String info = message.sendRoomId == roomId ? localInfo : remoteInfo;
              widgets.add(SystemMessageWidget(info, key: UniqueKey(),));
              break;
            case CommandType.newPartner:
              const String remoteInfo = "#{friendName}同意了您的好友申请";
              const String localInfo = "您同意了#{friendName}的好友申请";
              if(rawCmd.cmdValue == null){
                continue;
              }
              int? confirmUserId = rawCmd.cmdValue as int;
              UserModel? localUser = LocalUser.getUser();
              if(localUser == null){
                continue;
              }
              String? info;
              if(confirmUserId == localUser.id){
                info = formatSystemMessage(localInfo);
              }
              else{
                info = formatSystemMessage(remoteInfo);
              }
              if(preTime == null || message.sendTime!.difference(preTime).inMinutes >= 1){
                preTime = message.sendTime;
                widgets.add(SystemMessageWidget(DateTimeUtil.getSimpleTime(now, preTime!)));
              }
              widgets.add(SystemMessageWidget(info, key: UniqueKey(),));
              break;
            default:
          }
          break;
        case MessageType.text:
          if(message.content == null){
            break;
          }
          if(message.sendRoomId == roomId){
            UserModel? localUser = LocalUser.getUser();
            if(localUser == null || localUser.head == null){
              break;
            }
            if(preTime == null || message.sendTime!.difference(preTime).inMinutes >= 1){
              preTime = message.sendTime;
              widgets.add(SystemMessageWidget(DateTimeUtil.getSimpleTime(now, preTime!)));
            }
            MessageController? controller = msgControllerMap[message];
            bool isRead = message.id > 0 && widget.room.lastReadId != null && message.id <= widget.room.lastReadId!;
            if(controller == null){
              if(message.id == 0 || !isRead || ChatUtilSingle.isRetractable(message)){
                controller = MessageController();
                msgControllerMap[message] = controller;
              }
            }
            widgets.add(
              LocalMessageWrapperWidget(
                message: message,
                content: Text(message.content!,), 
                quote: getMessageQuoteWidget(message),
                head: getFullUrl(localUser.head!), 
                name: localUser.name ?? '',
                isRead: isRead,
                controller: controller,
                key: UniqueKey(),
              )
            );
          }
          else{
            if(partnerHead == null || partnerName == null){
              continue;
            }
            if(preTime == null || message.sendTime!.difference(preTime).inMinutes >= 1){
              preTime = message.sendTime;
              widgets.add(SystemMessageWidget(DateTimeUtil.getSimpleTime(now, preTime!)));
            }
            MessageController? controller = msgControllerMap[message];
            if(controller == null){
              if(ChatUtilSingle.isRetractable(message)){
                controller = MessageController();
                msgControllerMap[message] = controller;
              }
            }
            widgets.add(
              RemoteMessageWrapperWidget(
                message: message,
                content: Text(message.content!,),
                quote: getMessageQuoteWidget(message),
                head: getFullUrl(partnerHead!),
                name: partnerName!,
                controller: controller,
                key: UniqueKey(),
              )
            );
          }
          break;
        case MessageType.audio:
          if(message.url == null){
            break;
          }
          int millis = 0;
          if(message.content != null){
            Map<String, Object?> contentMap = json.decoder.convert(message.content!);
            if(contentMap['millis'] is int){
              millis = contentMap['millis'] as int;
            }
          } 
          if(message.sendRoomId == roomId){
            UserModel? localUser = LocalUser.getUser();
            if(localUser == null || localUser.head == null){
              break;
            }
            if(preTime == null || message.sendTime!.difference(preTime).inMinutes >= 1){
              preTime = message.sendTime;
              widgets.add(SystemMessageWidget(DateTimeUtil.getSimpleTime(now, preTime!)));
            }
            MessageController? controller = msgControllerMap[message];
            bool isRead = message.id > 0 && widget.room.lastReadId != null && message.id <= widget.room.lastReadId!;
            if(controller == null){
              if(message.id == 0 || !isRead || ChatUtilSingle.isRetractable(message)){
                controller = MessageController();
                msgControllerMap[message] = controller;
              }
            }
            widgets.add(
              LocalMessageWrapperWidget(
                message: message,
                content: AudioMessageWidget(url: message.url!, millis: millis,),
                head: getFullUrl(localUser.head!),
                name: localUser.name ?? '',
                isRead: isRead,
                controller: controller,
                key: UniqueKey(),
              )
            );
          }
          else{
            if(partnerHead == null || partnerName == null){
              continue;
            }
            if(preTime == null || message.sendTime!.difference(preTime).inMinutes >= 1){
              preTime = message.sendTime;
              widgets.add(SystemMessageWidget(DateTimeUtil.getSimpleTime(now, preTime!)));
            }
            MessageController? controller = msgControllerMap[message];
            if(controller == null){
              if(ChatUtilSingle.isRetractable(message)){
                controller = MessageController();
                msgControllerMap[message] = controller;
              }
            }
            widgets.add(
              RemoteMessageWrapperWidget(
                message: message,
                content: AudioMessageWidget(url: message.url!, millis: millis,), 
                head: getFullUrl(partnerHead!), 
                name: partnerName!,
                controller: controller,
                key: UniqueKey(),
              )
            );
          }
          break;
        case MessageType.image:
          if(message.url == null){
            break;
          }
          int width = 0;
          int height = 0;
          if(message.content != null){
            Map<String, Object?> content = {};
            content = json.decoder.convert(message.content!);
            width = content['width'] as int;
            height = content['height'] as int;
          }
          if(message.sendRoomId == roomId){
            UserModel? localUser = LocalUser.getUser();
            if(localUser == null || localUser.head == null){
              break;
            }
            if(preTime == null || message.sendTime!.difference(preTime).inMinutes >= 1){
              preTime = message.sendTime;
              widgets.add(SystemMessageWidget(DateTimeUtil.getSimpleTime(now, preTime!)));
            }
            Widget imageWidget = Image.network(
              getFullUrl(message.url!),
              fit: BoxFit.fitHeight, 
              loadingBuilder: (context, child, progress){
                if(progress == null || progress.expectedTotalBytes == null){
                  return child;
                }
                return Center(
                  child: CircularProgressIndicator(
                    value: progress.cumulativeBytesLoaded / progress.expectedTotalBytes!,
                  ),
                );
              },
            );
            MessageController? controller = msgControllerMap[message];
            bool isRead = message.id > 0 && widget.room.lastReadId != null && message.id <= widget.room.lastReadId!;
            if(controller == null){
              if(message.id == 0 || !isRead || ChatUtilSingle.isRetractable(message)){
                controller = MessageController();
                msgControllerMap[message] = controller;
              }
            }
            widgets.add(
              LocalMessageWrapperWidget(
                message: message,
                content: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: IMAGE_MESSAGE_HEIGHT_MAX
                  ),
                  child: InkWell(
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context){
                        return ImageGroupViewer(imageUrlList, initIndex: imageUrlList.indexOf(getFullUrl(message.url!)),);
                      }));
                    },
                    child: width > 0 && height > 0 ?
                    AspectRatio(
                      aspectRatio: width / height,
                      child: imageWidget,
                    ):
                    imageWidget
                  ),
                ),
                head: getFullUrl(localUser.head!),
                name: localUser.name ?? '',
                isRead: isRead,
                controller: controller,
                key: UniqueKey(),
              )
            );
          }
          else{
            if(partnerHead == null || partnerName == null){
              continue;
            }
            if(preTime == null || message.sendTime!.difference(preTime).inMinutes >= 1){
              preTime = message.sendTime;
              widgets.add(SystemMessageWidget(DateTimeUtil.getSimpleTime(now, preTime!)));
            }
            Widget imageWidget = Image.network(
              getFullUrl(message.url!), 
              fit: BoxFit.cover, 
              loadingBuilder: (context, child, progress){
                if(progress == null || progress.expectedTotalBytes == null){
                  return child;
                }
                return Center(
                  child: CircularProgressIndicator(
                    value: progress.cumulativeBytesLoaded / progress.expectedTotalBytes!,
                  ),
                );
              },
            );
            MessageController? controller = msgControllerMap[message];
            if(controller == null){
              if(ChatUtilSingle.isRetractable(message)){
                controller = MessageController();
                msgControllerMap[message] = controller;
              }
            }
            widgets.add(
              RemoteMessageWrapperWidget(
                message: message,
                content: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: IMAGE_MESSAGE_HEIGHT_MAX
                  ),
                  child: InkWell(
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context){
                        return ImageGroupViewer(imageUrlList, initIndex: imageUrlList.indexOf(getFullUrl(message.url!)),);
                      }));
                    },
                    child: width > 0 && height > 0 ?
                    AspectRatio(
                      aspectRatio: width / height,
                      child: imageWidget,
                    ) :
                    imageWidget,
                  ),
                ),
                head: getFullUrl(partnerHead!), 
                name: partnerName!,
                controller: controller,
                key: UniqueKey(),
              )
            );
          }
          break;
        case MessageType.location:
          if(message.content == null){
            continue;
          }
          Map<String, Object?> content = json.decoder.convert(message.content!);
          if(content['address'] == null || content['latitude'] == null || content['longitude'] == null){
            continue;
          }
          SimplePoi poi = SimplePoi(latitude: content['latitude'] as double, longitude: content['longitude'] as double, address: content['address'] as String);
          if(message.sendRoomId == roomId){
            UserModel? localUser = LocalUser.getUser();
            if(localUser == null || localUser.head == null){
              break;
            }
            if(preTime == null || message.sendTime!.difference(preTime).inMinutes >= 1){
              preTime = message.sendTime;
              widgets.add(SystemMessageWidget(DateTimeUtil.getSimpleTime(now, preTime!)));
            }
            MessageController? controller = msgControllerMap[message];
            bool isRead = message.id > 0 && widget.room.lastReadId != null && message.id <= widget.room.lastReadId!;
            if(controller == null){
              if(message.id == 0 || !isRead || ChatUtilSingle.isRetractable(message)){
                controller = MessageController();
                msgControllerMap[message] = controller;
              }
            }
            widgets.add(
              LocalMessageWrapperWidget(
                message: message,
                content: LocationMessageWidget(address: poi.address!, latitude: poi.latitude!, longitude: poi.longitude!),
                head: getFullUrl(localUser.head!),
                name: localUser.name ?? '',
                isRead: isRead,
                controller: controller,
                key: UniqueKey(),
              )
            );
          }
          else{
            if(partnerHead == null || partnerName == null){
              continue;
            }
            if(preTime == null || message.sendTime!.difference(preTime).inMinutes >= 1){
              preTime = message.sendTime;
              widgets.add(SystemMessageWidget(DateTimeUtil.getSimpleTime(now, preTime!)));
            }
            MessageController? controller = msgControllerMap[message];
            if(controller == null){
              if(ChatUtilSingle.isRetractable(message)){
                controller = MessageController();
                msgControllerMap[message] = controller;
              }
            }
            widgets.add(
              RemoteMessageWrapperWidget(
                message: message, 
                content: LocationMessageWidget(address: poi.address!, latitude: poi.latitude!, longitude: poi.longitude!),
                head: getFullUrl(partnerHead!),
                name: partnerName!,
                controller: controller,
                key: UniqueKey(),
              )
            );
          }
          break;
        case MessageType.file:
          if(message.url == null){
            continue;
          }
          if(message.sendRoomId == roomId){
            UserModel? localUser = LocalUser.getUser();
            if(localUser == null || localUser.head == null){
              break;
            }
            if(preTime == null || message.sendTime!.difference(preTime).inMinutes >= 1){
              preTime = message.sendTime;
              widgets.add(SystemMessageWidget(DateTimeUtil.getSimpleTime(now, preTime!)));
            }
            bool isRead = message.id > 0 && widget.room.lastReadId != null && message.id <= widget.room.lastReadId!;
            MessageController? controller = msgControllerMap[message];
            if(controller == null){
              if(message.id == 0 || !isRead || ChatUtilSingle.isRetractable(message)){
                controller = MessageController();
                msgControllerMap[message] = controller;
              }
            }
            widgets.add(
              LocalMessageWrapperWidget(
                message: message,
                content: FileMessageWidget(message),
                head: getFullUrl(localUser.head!),
                name: localUser.name ?? '',
                isRead: isRead,
                controller: controller,
                key: UniqueKey(),
              )
            );
          }
          else{
            if(partnerHead == null || partnerName == null){
              continue;
            }
            if(preTime == null || message.sendTime!.difference(preTime).inMinutes >= 1){
              preTime = message.sendTime;
              widgets.add(SystemMessageWidget(DateTimeUtil.getSimpleTime(now, preTime!)));
            }
            MessageController? controller = msgControllerMap[message];
            if(controller == null){
              if(ChatUtilSingle.isRetractable(message)){
                controller = MessageController();
                msgControllerMap[message] = controller;
              }
            }
            widgets.add(
              RemoteMessageWrapperWidget(
                message: message,
                content: FileMessageWidget(message),
                head: getFullUrl(partnerHead!),
                name: partnerName!,
                controller: controller,
                key: UniqueKey(),
              )
            );
          }
          break;
        case MessageType.freegoVideo:
          if(message.content == null){
            continue;
          }
          Map<String, Object?> content = json.decoder.convert(message.content!);
          Object? videoId = content['id'];
          Object? name = content['name'];
          Object? cover = content['cover'];
          if(videoId is! int || name is! String || cover is! String?){
            continue;
          }
          if(message.sendRoomId == roomId){
            UserModel? localUser = LocalUser.getUser();
            if(localUser == null || localUser.head == null){
              break;
            }
            if(preTime == null || message.sendTime!.difference(preTime).inMinutes >= 1){
              preTime = message.sendTime;
              widgets.add(SystemMessageWidget(DateTimeUtil.getSimpleTime(now, preTime!)));
            }
            bool isRead = message.id > 0 && widget.room.lastReadId != null && message.id <= widget.room.lastReadId!;
            MessageController? controller = msgControllerMap[message];
            if(controller == null){
              if(message.id == 0 || !isRead || ChatUtilSingle.isRetractable(message)){
                controller = MessageController();
                msgControllerMap[message] = controller;
              }
            }
            widgets.add(
              LocalMessageWrapperWidget(
                message: message, 
                head: getFullUrl(localUser.head!), 
                name: localUser.name ?? '', 
                content: FreegoVideoMessageWidget(videoId: videoId, videoName: name, cover: cover,),
                controller: controller,
                isRead: isRead,
                key: UniqueKey()
              )
            );
          }
          else{
            if(partnerHead == null || partnerName == null){
              continue;
            }
            if(preTime == null || message.sendTime!.difference(preTime).inMinutes >= 1){
              preTime = message.sendTime;
              widgets.add(SystemMessageWidget(DateTimeUtil.getSimpleTime(now, preTime!)));
            }
            MessageController? controller = msgControllerMap[message];
            if(controller == null){
              if(ChatUtilSingle.isRetractable(message)){
                controller = MessageController();
                msgControllerMap[message] = controller;
              }
            }
            widgets.add(
              RemoteMessageWrapperWidget(
                message: message, 
                head: getFullUrl(partnerHead!),
                name: partnerName!,
                controller: controller,
                content: FreegoVideoMessageWidget(videoId: videoId, videoName: name, cover: cover),
                key: UniqueKey(),
              )
            );
          }
          break;
        default:
      }
    }
    return widgets;
  }

  String formatSystemMessage(String origin){
    String result = origin.replaceAll('#{friendName}', partnerName!);
    return result;
  }

  void resetState(){
    setState((){
    });
  }
}

class FileMessageWidget extends StatefulWidget{
  final ImSingleMessage message;
  const FileMessageWidget(this.message, {super.key});

  @override
  State<StatefulWidget> createState() {
    return FileMessageState();
  }

}

class FileMessageState extends State<FileMessageWidget>{

  static const double MAX_HEIGHT = 120;
  static const double FILE_ICON_SIZE = 60;

  String name = 'unkown';
  String extName = '?';
  int bytes = -1;
  int loadedBytes = -1;
  FileDownloadState? downloadState;

  @override
  void initState(){
    super.initState();
    if(widget.message.content != null){
      try{
        Map<String, Object?> contentMap = json.decoder.convert(widget.message.content!);
        if(contentMap['name'] is String){
          name = contentMap['name'] as String;
          extName = name.substring(name.lastIndexOf('.') + 1, name.length).toUpperCase();
        }
        if(contentMap['bytes'] is int){
          bytes = contentMap['bytes'] as int;
        }
        if(widget.message.localPath != null){
          Future.delayed(Duration.zero, () async{
            Directory? saveDir = await LocalFileUtil.getProejctPath();
            if(saveDir == null){
              downloadState = FileDownloadState.error;
              return;
            }
            String fullPath = '${saveDir.path}${widget.message.localPath}';
            if(File(fullPath).existsSync()){
              downloadState = FileDownloadState.done;
            }
            else{
              downloadState = FileDownloadState.deleted;
            }
            if(mounted && context.mounted){
              setState(() {
              });
            }
          });
        }
        else{
          downloadState = FileDownloadState.prepare;
        }
      }
      catch(e){
        //
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: MAX_HEIGHT,
      ),
      child: InkWell(
        onTap: () async{
          if(widget.message.url == null){
            ToastUtil.error('文件地址错误');
            return;
          }
          if(downloadState == FileDownloadState.prepare || downloadState == FileDownloadState.deleted || downloadState == FileDownloadState.error){
            ToastUtil.hint('下载中');
            downloadState = FileDownloadState.downloading;
            setState(() {
            });
            if(Platform.isAndroid){
              bool isGranted = await PermissionUtil().requestPermission(context: context, permission: Permission.manageExternalStorage, info: '希望获取外部存储权限用于下载文件');
              if(!isGranted){
                ToastUtil.error('获取存储权限失败');
                return;
              }
            }
            Directory? dir = await LocalFileUtil.getProejctPath();
            if(dir == null){
              ToastUtil.error('获取项目目录失败');
              return;
            }
            int userId = LocalUser.getUser()?.id ?? 0;
            Directory saveDir = Directory('${dir.path}/chat_file/$userId');
            if(!await saveDir.exists()){
              saveDir.create(recursive: true);
            }
            String baseSavePath = '/chat_file/$userId/$name';
            String savePath = baseSavePath;
            String fullPath = '${dir.path}$savePath';
            if(File(fullPath).existsSync()){
              bool pathSetted = false;
              for(int i = 1; i <= ChatUtilConstants.NAME_NUMBER_MAX; ++i){
                String rawPath = LocalFileUtil.getPathWithoutExtension(baseSavePath);
                String ext = LocalFileUtil.getFileExtension(baseSavePath);
                if(ext.isNotEmpty){
                  savePath = '$rawPath($i).$ext';
                }
                else{
                  savePath = '$baseSavePath($i)';
                }
                fullPath = '${dir.path}$savePath';
                if(!File(fullPath).existsSync()){
                  pathSetted = true;
                  break;
                }
              }
              if(!pathSetted){
                ToastUtil.error('保存失败');
                downloadState = FileDownloadState.error;
                if(mounted && context.mounted){
                  setState(() {
                  });
                }
                return;
              }
            }
            bool result = await HttpTool.download(URL_FILE_DOWNLOAD + widget.message.url!, fullPath, onReceive: (current, total){
              loadedBytes = current;
              if(mounted && context.mounted){
                setState(() {
                });
              }
            });
            if(result){
              downloadState = FileDownloadState.done;
              widget.message.localPath = savePath;
              ChatStorageSingle.setLocalPath(widget.message.id, savePath);
            }
            else{
              downloadState = FileDownloadState.error;
            }
            if(mounted && context.mounted){
              setState(() {
              });
            }
          }
          else if(downloadState == FileDownloadState.done){
            Directory? dir = await LocalFileUtil.getProejctPath();
            if(dir == null){
              ToastUtil.error('获取项目目录失败');
              return;
            }
            String fullPath = '${dir.path}${widget.message.localPath}';
            OpenFilex.open(fullPath).then((result){
              if(result.type != ResultType.done){
                switch(result.type){
                  case ResultType.noAppToOpen:
                    // ignore: use_build_context_synchronously
                    ToastUtil.customError(context, '缺少应用程序');
                    break;
                  case ResultType.fileNotFound:
                    // ignore: use_build_context_synchronously
                    ToastUtil.customError(context, '找不到文件路径');
                    downloadState = FileDownloadState.deleted;
                    setState(() {
                    });
                    break;
                  case ResultType.permissionDenied:
                    // ignore: use_build_context_synchronously
                    ToastUtil.customError(context, '缺少权限');
                    break;
                  case ResultType.error:
                    // ignore: use_build_context_synchronously
                    ToastUtil.customError(context, '打开文件失败');
                    break;
                  default:
                }
              }
            });
          }
        },
        child: Container(
          color: Colors.blue,
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: FILE_ICON_SIZE,
                    alignment: Alignment.center,
                    child: Text(extName, style: const TextStyle(color: Colors.white, fontSize: 18),),
                  )
                ],
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      constraints: const BoxConstraints(
                        minHeight: FILE_ICON_SIZE
                      ),
                      color: Colors.lightBlue,
                      alignment: Alignment.centerLeft,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, maxLines: 4, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 16),),
                          bytes <= 0 ?
                          const SizedBox() :
                          Text('（${StringUtil.getSizeText(bytes)}）', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 16),),
                          getStatusWidget(),
                        ],
                      )
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getStatusWidget(){
    switch(downloadState){
      case FileDownloadState.prepare:
        return const Text('准备下载', style: TextStyle(color: Colors.white70),);
      case FileDownloadState.suspend:
        return const Text('暂停', style: TextStyle(color: Colors.white70),);
      case FileDownloadState.downloading:
        String text = '下载中';
        if(loadedBytes >=0 && bytes > 0){
          text += '：${(100 * loadedBytes / bytes).toStringAsFixed(1)}%';
        }
        return Text(text, style: const TextStyle(color: Colors.white70),);
      case FileDownloadState.done:
        return Text('下载完成', style: TextStyle(color: Colors.green[200]),);
      case FileDownloadState.deleted:
        return Text('已删除', style: TextStyle(color: Colors.red[200]),);
      case FileDownloadState.error:
        return Text('下载失败', style: TextStyle(color: Colors.red[200]),);
      default:
      return const SizedBox();
    }
  }
}

class LocationMessageWidget extends StatefulWidget{
  final String address;
  final double latitude;
  final double longitude;
  const LocationMessageWidget({required this.address, required this.latitude, required this.longitude, super.key});

  @override
  State<StatefulWidget> createState() {
    return LocationMessageState();
  }

}

class LocationMessageState extends State<LocationMessageWidget>{

  static const double LOCATION_MESSAGE_HEIGHT = 180;
  static const double LOCATION_MESSAGE_ZOOM = 15;

  Widget svgLocation = SvgPicture.asset('svg/map/location.svg');
  Marker? targetMarker;

  @override
  void initState(){
    super.initState();
    Future.delayed(Duration.zero, () async{
      ByteData? byteData = await GaodeUtil.widgetToByteData(
        SizedBox(
          width: 80,
          height: 80,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: svgLocation,
          ),
        )
      );
      BitmapDescriptor icon = BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
      targetMarker = Marker(
        position: amap_flutter_base.LatLng(widget.latitude, widget.longitude),
        icon: icon,
        anchor: const Offset(0.5, 0.5)
      );
      if(mounted && context.mounted){
        setState(() {
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: LOCATION_MESSAGE_HEIGHT,
          child: AMapWidget(
            apiKey: const amap_flutter_base.AMapApiKey(androidKey:ConstConfig.amapApiKeyOfAndroid, iosKey: ConstConfig.amapApiKeyOfIOS),
            privacyStatement: const amap_flutter_base.AMapPrivacyStatement(hasContains: true, hasShow: true, hasAgree: true),
            initialCameraPosition: CameraPosition(target: amap_flutter_base.LatLng(widget.latitude, widget.longitude), zoom: LOCATION_MESSAGE_ZOOM),
            markers: targetMarker == null ? {} : {targetMarker!},
            rotateGesturesEnabled: false,
            scaleEnabled: false,
            scrollGesturesEnabled: false,
            tiltGesturesEnabled: false,
            touchPoiEnabled: false,
            zoomGesturesEnabled: false,
            mapType: MapType.navi,
            onTap: (pos){
              Navigator.of(context).push(MaterialPageRoute(builder: (context){
                return CommonMapShowPage(address: widget.address, latitude: widget.latitude, longitude: widget.longitude,);
              }));
            },
          ),
        ),
        const SizedBox(height: 10,),
        Text(widget.address)
      ],
    );
  }

}

class AudioMessageWidget extends StatefulWidget{
  final int millis;
  final String url;
  const AudioMessageWidget({required this.url, this.millis = 0, super.key});

  @override
  State<StatefulWidget> createState() {
    return AudioMessageState();
  }

}

class AudioMessageState extends State<AudioMessageWidget> with SingleTickerProviderStateMixin{

  static const double RHYTHM_ICON_WIDTH = 32;
  static const double RHYTHM_ICON_HEIGHT = 40;
  static const int RHYTHM_ANIM_MILLI_SECONDS = 500;

  Duration? total;
  Duration? left;
  Duration? position;

  bool isPlaying = false;
  late AnimationController rhythmController;
  late ChatRoomState? parentState;
  StreamSubscription? subscription;

  @override
  void initState(){
    super.initState();
    if(widget.millis > 0){
      total = Duration(milliseconds: widget.millis);
      left = Duration(milliseconds: widget.millis);
    }
    rhythmController = AnimationController(vsync: this, duration: const Duration(milliseconds: RHYTHM_ANIM_MILLI_SECONDS));
    parentState = context.findRootAncestorStateOfType();
  }

  @override
  void dispose(){
    rhythmController.dispose();
    subscription?.cancel();
    super.dispose();
  }

  void startPlay() async{
    if(parentState == null){
      ToastUtil.error('播放出错');
      return;
    }
    isPlaying = true;
    AudioPlayer audioPlayer = parentState!.audioPlayer;
    if(parentState!.audioMessageState == this){
      audioPlayer.play();
    }
    else{
      parentState!.audioMessageState?.resetPlay();
      parentState!.audioMessageState = this;
      await audioPlayer.setUrl(getFullUrl(widget.url), initialPosition: position);
      subscription = audioPlayer.positionStream.listen((duration) { 
        position = duration;
        left = Duration(milliseconds: total!.inMilliseconds - duration.inMilliseconds);
        if(left!.compareTo(Duration.zero) <= 0){
          stopPlay();
          rhythmController.reset();
          audioPlayer.seek(Duration.zero);
          left = total;
          position = Duration.zero;
        }
        setState(() {
        });
      });
      audioPlayer.play();
    }
    rhythmController.repeat();
  }

  void stopPlay() async{
    if(parentState == null){
      ToastUtil.error('播放出错');
      return;
    }
    if(parentState!.audioMessageState != this){
      return;
    }
    isPlaying = false;
    rhythmController.stop();
    AudioPlayer audioPlayer = parentState!.audioPlayer;
    await audioPlayer.stop();
  }

  void resetPlay(){
    stopPlay();
    subscription?.cancel();
    parentState?.audioMessageState = null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: Row(
        children: [
          InkWell(
            onTap: (){
              if(isPlaying){
                stopPlay();
              }
              else{
                startPlay();
              }
            },
            child: SizedBox(
              width: RHYTHM_ICON_WIDTH,
              height: RHYTHM_ICON_HEIGHT,
              child: ListView(
                padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                children: [
                  SlideTransition(
                    position: rhythmController.drive(Tween(begin: const Offset(-0.5, 0), end: Offset.zero)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: RHYTHM_ICON_WIDTH,
                          height: RHYTHM_ICON_HEIGHT,
                          child: Image.asset('assets/chat/audio_play.png', width: double.infinity, height: double.infinity, fit: BoxFit.fill,),
                        ),
                        SizedBox(
                          width: RHYTHM_ICON_WIDTH,
                          height: RHYTHM_ICON_HEIGHT,
                          child: Image.asset('assets/chat/audio_play.png', width: double.infinity, height: double.infinity, fit: BoxFit.fill,),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(width: 20,),        
          left == null ?
          const SizedBox() :
          Text(DateTimeUtil.getAudioTime(left!))
        ],
      ),
    );
  }

}

class FreegoVideoMessageWidget extends StatelessWidget{
  final int videoId;
  final String videoName;
  final String? cover;
  const FreegoVideoMessageWidget({required this.videoId, required this.videoName, this.cover, super.key});

  @override
  Widget build(BuildContext context) {
    String? cover = this.cover;
    if(cover != null){
      cover = getFullUrl(cover);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () async{
            VideoModel? video = await HttpVideo.getById(videoId);
            if(video == null){
              ToastUtil.error('目标已失效');
            }
            if(context.mounted){
              Navigator.of(context).push(MaterialPageRoute(builder: (context){
                return VideoHomePage(initVideo: video,);
              }));
            }
          },
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 1,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    color: Colors.black,
                  ),
                  if(cover != null)
                  Image.network(
                    cover
                  ),
                  ClipOval(
                    child: Container(
                      color: const Color.fromRGBO(0, 0, 0, 0.7),
                      child: const Icon(Icons.play_arrow, color: Colors.white, size: 40,),
                    ),
                  )
                ],
              )
            ),
          ),
        ),
        const SizedBox(height: 10,),
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
          child: Text(videoName, style: const TextStyle(color: ThemeUtil.foregroundColor),),
        )
      ],
    );
  }
  
}

class RemoteMessageMenuWidget extends StatefulWidget{
  final bool menuOnTop;
  final void Function()? onTapDelete;
  final void Function()? onTapQuote;

  const RemoteMessageMenuWidget({this.menuOnTop = true, this.onTapDelete, this.onTapQuote, super.key});

  @override
  State<StatefulWidget> createState() {
    return RemoteMessageMenuState();
  }

}

class RemoteMessageMenuState extends State<RemoteMessageMenuWidget>{

  static const double MENU_WIDTH = 140;
  static const double MENU_HEIGHT = MENU_BOTTOM_HEIGHT + MENU_CONTENT_HEIGHT;
  static const double MENU_CONTENT_HEIGHT = 60;
  static const double MENU_BOTTOM_HEIGHT = 12;
  static const double MENU_TOP_HEIGTH = MENU_BOTTOM_HEIGHT;
  static const double MENU_ITEM_ICON_SIZE = 32;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.menuOnTop ?
        const SizedBox() :
        Container(
          alignment: Alignment.topLeft,
          color: Colors.white,
          height: MENU_TOP_HEIGTH,
          width: MENU_WIDTH,
          child: Transform.translate(
            offset: const Offset(16, 0),
            child: CustomPaint(
              painter: PathPainter(
                strokeColor: ThemeUtil.backgroundColor,
                paintingStyle: PaintingStyle.fill,
                strokeWidth: 1.0,
                makePath: (){
                  Path path = Path();
                  path.moveTo(0, MENU_TOP_HEIGTH);
                  path.lineTo(8, MENU_TOP_HEIGTH - 8);
                  path.lineTo(16, MENU_TOP_HEIGTH);
                  return path;
                }
              ),
            ),
          ),
        ),
        Container(
          width: MENU_WIDTH ,
          height: MENU_CONTENT_HEIGHT,
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(
            color: ThemeUtil.backgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap
                ),
                onPressed: widget.onTapDelete,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.delete, size: MENU_ITEM_ICON_SIZE, color: ThemeUtil.foregroundColor,),
                    Text('删除', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 14),)
                  ],
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap
                ),
                onPressed: widget.onTapQuote,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.format_quote, size: MENU_ITEM_ICON_SIZE, color: ThemeUtil.foregroundColor,),
                    Text('引用', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 14),)
                  ],
                ),
              ),
            ],
          ),
        ),
        !widget.menuOnTop ?
        const SizedBox() :
        SizedBox(
          height: MENU_BOTTOM_HEIGHT,
          child: Transform.translate(
            offset: const Offset(16, 0),
            child: CustomPaint(
              painter: PathPainter(
                strokeColor: ThemeUtil.backgroundColor,
                paintingStyle: PaintingStyle.fill,
                strokeWidth: 1.0,
                makePath: (){
                  Path path = Path();
                  path.moveTo(0, 0);
                  path.lineTo(8, 8);
                  path.lineTo(16, 0);
                  return path;
                }
              ),
            ),
          ),
        )
      ]
    );
  }

}

class RemoteMessageWrapperWidget extends StatefulWidget{
  final ImSingleMessage message;
  final String head;
  final String name;
  final Widget content;
  final Widget? quote;
  final MessageController? controller;
  const RemoteMessageWrapperWidget({required this.message, required this.head, required this.name, required this.content, this.controller, this.quote, super.key});

  @override
  State<StatefulWidget> createState() {
    return RemoteMessageWrapperState();
  }

}

class RemoteMessageWrapperState extends State<RemoteMessageWrapperWidget>{
  static const avatarWidth = 48.0;
  static const avatarHeight = 48.0;

  static const messageBoxWidth = 240.0;
  static const messageLineHeight = 18;

  late ChatRoomState? roomState;
  GlobalKey contentKey = GlobalKey();

  void actionListener(){
    MessageAction? action = widget.controller?._action;
    if(action == MessageAction.updateStatus){
      setState(() {
      });
    }
  }

  @override
  void initState(){
    super.initState();
    widget.controller?.addListener(actionListener);
    roomState = context.findAncestorStateOfType();
  }

  @override
  void dispose(){
    widget.controller?.removeListener(actionListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int? sendStatusNum = widget.message.sendStatus;
    if(sendStatusNum == null || sendStatusNum == SendStatus.retracted.getNum() || sendStatusNum == SendStatus.deleted.getNum()){
      return const SizedBox();
    }
    return Container(
      padding: const EdgeInsets.only(bottom: 12, left: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ClipOval(
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: avatarWidth,
                  height: avatarHeight,
                  child: Image.network(widget.head, fit: BoxFit.cover, width: double.infinity, height: double.infinity,),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 6),
                child: Text(widget.name),
              )
            ],
          ),
          GestureDetector(
            key: contentKey,
            onLongPress: (){
              RenderBox? box = contentKey.currentContext?.findRenderObject() as RenderBox?;
              if(box != null){
                Offset pos = box.localToGlobal(Offset.zero);
                double menuY = pos.dy - (roomState?.menuDy ?? 0) - LocalMessageMenuState.MENU_HEIGHT;
                if(menuY > CommonHeader.HEADER_HEIGHT){
                  roomState?.menuOnTop = true;
                  roomState?.menuTop = menuY;
                }
                else{
                  roomState?.menuOnTop = false;
                  menuY = pos.dy - (roomState?.menuDy ?? 0) + box.size.height;
                  roomState?.menuTop = menuY;
                }
                roomState?.onMenuMessage = widget.message;
                roomState?.enterMenuMode();
              }
            },
            child: Container(
              margin: const EdgeInsets.only(left: 52),
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                      maxWidth: messageBoxWidth,
                      minWidth: avatarWidth,
                    ),
                    decoration: const BoxDecoration(
                      color: ThemeUtil.dialogueColor,
                      borderRadius: BorderRadius.all(Radius.circular(8))
                    ),
                    child: widget.content,
                  ),
                  CustomPaint(
                    painter: PathPainter(
                      strokeColor: ThemeUtil.dialogueColor,
                      paintingStyle: PaintingStyle.fill,
                      strokeWidth: 1.0,
                      makePath: (){
                        var path = Path();
                        path.moveTo(8, 0);
                        path.lineTo(0, 8);
                        path.lineTo(-5, -5);
                        return path;
                      }
                    ),
                  ),
                ],
              ),
            ),
          ),
          widget.quote == null ?
          const SizedBox() :
          Container(
            margin: const EdgeInsets.only(left: 52, top: 8),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(
              maxWidth: messageBoxWidth,
              minWidth: avatarWidth,
            ),
            decoration: const BoxDecoration(
              color: ThemeUtil.backgroundColor,
              borderRadius: BorderRadius.all(Radius.circular(8))
            ),
            child: Column(
              children: [
                widget.quote!
              ],
            )
          )
        ],
      ),
    );
  }

}

class LocalMessageMenuWidget extends StatefulWidget{
  final bool menuOnTop;
  final void Function()? onTapDelete;
  final void Function()? onTapQuote;
  final void Function()? onTapRetract;
  const LocalMessageMenuWidget({this.menuOnTop = true, this.onTapDelete, this.onTapQuote, this.onTapRetract, super.key});

  @override
  State<StatefulWidget> createState() {
    return LocalMessageMenuState();
  }

}

class LocalMessageMenuState extends State<LocalMessageMenuWidget>{

  static const double MENU_WIDTH = 200;
  static const double MENU_HEIGHT = MENU_BOTTOM_HEIGHT + MENU_CONTENT_HEIGHT;
  static const double MENU_CONTENT_HEIGHT = 60;
  static const double MENU_BOTTOM_HEIGHT = 12;
  static const double MENU_TOP_HEIGTH = MENU_BOTTOM_HEIGHT;
  static const double MENU_ITEM_ICON_SIZE = 32;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        widget.menuOnTop ?
        const SizedBox() :
        Container(
          alignment: Alignment.topRight,
          color: Colors.white,
          height: MENU_TOP_HEIGTH,
          width: MENU_WIDTH,
          child: Transform.translate(
            offset: const Offset(-16, 0),
            child: CustomPaint(
              painter: PathPainter(
                strokeColor: ThemeUtil.backgroundColor,
                paintingStyle: PaintingStyle.fill,
                strokeWidth: 1.0,
                makePath: (){
                  Path path = Path();
                  path.moveTo(0, MENU_TOP_HEIGTH);
                  path.lineTo(-8, MENU_TOP_HEIGTH - 8);
                  path.lineTo(-16, MENU_TOP_HEIGTH);
                  return path;
                }
              ),
            ),
          ),
        ),
        Container(
          width: MENU_WIDTH ,
          height: MENU_CONTENT_HEIGHT,
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(
            color: ThemeUtil.backgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap
                ),
                onPressed: widget.onTapDelete,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.delete, size: MENU_ITEM_ICON_SIZE, color: ThemeUtil.foregroundColor,),
                    Text('删除', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 14),)
                  ],
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap
                ),
                onPressed: widget.onTapQuote,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.format_quote, size: MENU_ITEM_ICON_SIZE, color: ThemeUtil.foregroundColor,),
                    Text('引用', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 14),)
                  ],
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap
                ),
                onPressed: widget.onTapRetract,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.undo, size: MENU_ITEM_ICON_SIZE, color: ThemeUtil.foregroundColor,),
                    Text('撤回', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 14),)
                  ],
                )
              ),
            ],
          ),
        ),
        !widget.menuOnTop ?
        const SizedBox() :
        SizedBox(
          height: MENU_BOTTOM_HEIGHT,
          child: Transform.translate(
            offset: const Offset(-16, 0),
            child: CustomPaint(
              painter: PathPainter(
                strokeColor: ThemeUtil.backgroundColor,
                paintingStyle: PaintingStyle.fill,
                strokeWidth: 1.0,
                makePath: (){
                  Path path = Path();
                  path.moveTo(0, 0);
                  path.lineTo(-8, 8);
                  path.lineTo(-16, 0);
                  return path;
                }
              ),
            ),
          ),
        )
      ],
    );
  }

}

enum MessageAction{
  updateStatus,
  read
}

class MessageController extends ChangeNotifier{
  MessageAction? _action;
  void updateStatus(){
    _action = MessageAction.updateStatus;
    notifyListeners();
    _action = null;
  }
  void read(){
    _action = MessageAction.read;
    notifyListeners();
    _action = null;
  }

}

class LocalMessageWrapperWidget extends StatefulWidget{
  final ImSingleMessage message;
  final String head;
  final String name;
  final Widget content;
  final bool isRead;
  final MessageController? controller;
  final Widget? quote;

  const LocalMessageWrapperWidget({required this.message, required this.head, required this.name, required this.content, required this.isRead, this.controller, this.quote, super.key});

  @override
  State<StatefulWidget> createState() {
    return LocalMessageWrapperState();
  }

}

class LocalMessageWrapperState extends State<LocalMessageWrapperWidget>{
  static const double avatarWidth = 48;
  static const double avatarHeight = 48;
  static const double messageBoxWidth = 240;
  static const double messageLineHeight = 18;

  late String head;
  late String name;
  late Widget content;
  late bool isRead;

  late ChatRoomState? roomState;
  GlobalKey contentKey = GlobalKey();

  void actionListener(){
    MessageAction? action = widget.controller?._action;
    switch(action){
      case MessageAction.updateStatus:
        if(context.mounted){
          setState(() {
          });
        }
        break;
      case MessageAction.read:
        isRead = true;
        if(context.mounted){
          setState(() {
          });
        }
        break;
      default:
    }
  }

  @override
  void initState(){
    super.initState();
    head = widget.head;
    name = widget.name;
    content = widget.content;
    isRead = widget.isRead;
    widget.controller?.addListener(actionListener);
    roomState = context.findAncestorStateOfType();
    if(widget.message.id == 0 && widget.message.sendStatus != null){
      SendStatus? sendStatus = SendStatusExt.getStatus(widget.message.sendStatus!);
        if(sendStatus == SendStatus.unsent){
        Future.delayed(const Duration(seconds: ChatSocket.heartBeatSeconds * 2), () async{
          if(widget.message.id == 0){
            widget.message.sendStatus = SendStatus.fail.getNum();
            ImSingleMessage? savedMessage = await ChatStorageSingle.getMessageByLocalId(widget.message.localId!);
            if(savedMessage == null || savedMessage.sendStatus == null){
              return;
            }
            SendStatus? savedStatus = SendStatusExt.getStatus(savedMessage.sendStatus!);
            if(savedStatus != SendStatus.unsent){
              return;
            }
            ChatStorageSingle.updateStatusByLocal(widget.message.localId!, SendStatus.fail);
            if(mounted && context.mounted){
              setState(() {
              });
            }
          }
        });
      }
    }
  }

  @override
  void dispose(){
    widget.controller?.removeListener(actionListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(widget.message.sendStatus == null || widget.message.sendStatus == SendStatus.retracted.getNum() || widget.message.sendStatus == SendStatus.deleted.getNum()){
      return const SizedBox();
    }
    return Container(
      padding: const EdgeInsets.only(bottom: 12, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 6),
                child: Text(name),
              ),
              ClipOval(
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: avatarWidth,
                  height: avatarHeight,
                  child: Image.network(head, fit: BoxFit.cover, width: double.infinity, height: double.infinity,),
                ),
              )
            ],
          ),
          GestureDetector(
            key: contentKey,
            onLongPress: (){
              RenderBox? box = contentKey.currentContext?.findRenderObject() as RenderBox?;
              if(box != null){
                Offset pos = box.localToGlobal(Offset.zero);
                double menuY = pos.dy - (roomState?.menuDy ?? 0) - LocalMessageMenuState.MENU_HEIGHT;
                if(menuY > CommonHeader.HEADER_HEIGHT){
                  roomState?.menuOnTop = true;
                  roomState?.menuTop = menuY;
                }
                else{
                  roomState?.menuOnTop = false;
                  menuY = pos.dy - (roomState?.menuDy ?? 0) + box.size.height;
                  roomState?.menuTop = menuY;
                }
                roomState?.onMenuMessage = widget.message;
                roomState?.enterMenuMode();
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 52),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                      maxWidth: messageBoxWidth,
                      minWidth: avatarWidth,
                    ),
                    decoration: const BoxDecoration(
                      color: ThemeUtil.dialogueColor,
                      borderRadius: BorderRadius.all(Radius.circular(8))
                    ),
                    child: Column(
                      children: [
                        content
                      ],
                    )
                  ),
                  CustomPaint(
                    painter: PathPainter(
                      strokeColor: ThemeUtil.dialogueColor,
                      paintingStyle: PaintingStyle.fill,
                      strokeWidth: 1.0,
                      makePath: (){
                        var path = Path();
                        path.moveTo(-8, 0);
                        path.lineTo(0, 8);
                        path.lineTo(5, -5);
                        return path;
                      }
                    ),
                  ),
                ],
              )
            ),
          ),
          widget.quote == null ?
          const SizedBox() :
          Container(
            margin: const EdgeInsets.only(right: 52, top: 8),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(
              maxWidth: messageBoxWidth,
              minWidth: avatarWidth,
            ),
            decoration: const BoxDecoration(
              color: ThemeUtil.backgroundColor,
              borderRadius: BorderRadius.all(Radius.circular(8))
            ),
            child: Column(
              children: [
                widget.quote!
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 52),
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: getStateWidget()
            )
          )
        ],
      ),
    );
  }

  Widget getStateWidget(){
    SendStatus? sendStatus;
    if(widget.message.sendStatus != null){
      sendStatus = SendStatusExt.getStatus(widget.message.sendStatus!);
    }
    switch(sendStatus){
      case SendStatus.unsent:
        return const Text('发送中', style: TextStyle(color: Colors.black12),);
      case SendStatus.sending:
      case SendStatus.sent:
        return isRead ?
        const Text('已读', style: TextStyle(color: Color.fromRGBO(78, 89, 105, 0.7)),) :
        const Text('未读', style: TextStyle(color: Color.fromRGBO(255, 138, 128, 1)),);
      case SendStatus.fail:
        return const Text('发送失败', style: TextStyle(color: Color.fromRGBO(255, 50, 50, 0.7)),);
      default:
      return const SizedBox();
    }
  }

  void resetState(){
    setState(() {
    });
  }
}

class PathPainter extends CustomPainter{

  final Color strokeColor;
  final PaintingStyle paintingStyle;
  final double strokeWidth;
  final Function makePath;

  PathPainter({required this.strokeColor, required this.paintingStyle, required this.strokeWidth, required this.makePath});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = strokeColor
      ..style = paintingStyle
      ..strokeWidth = strokeWidth;
    Path path = makePath();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant PathPainter oldDelegate) {
    return true;
  }
}

class SystemMessageWidget extends StatelessWidget{
  final String text;

  const SystemMessageWidget(this.text, {super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(40, 8, 40, 8),
      child: Text(text, style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center,),
    );
  }

}

class KeyboardListener{

  void Function(String)? onSendText;

  void Function()? onShowKeyboard;
  void Function()? onKeyboardChange;
  void Function()? onShowEmoji;
  void Function()? onShowExt;
  void Function()? onHide;

  void Function()? onTapVoice;
  void Function()? onTapKeyboard;

  void Function()? onVoiceBegin;
  void Function()? onVoiceEnd;
  void Function(LongPressMoveUpdateDetails)? onVoiceUpdate;

  void Function()? onTapPhoto;
  void Function()? onTapCamera;
  void Function()? onTapLocation;
  void Function()? onTapFile;

  KeyboardListener({
    this.onSendText,
    this.onShowKeyboard,
    this.onKeyboardChange,
    this.onShowEmoji,
    this.onShowExt,
    this.onHide,
    this.onTapVoice,
    this.onTapKeyboard,
    this.onVoiceBegin,
    this.onVoiceEnd,
    this.onVoiceUpdate,
    this.onTapPhoto,
    this.onTapCamera,
    this.onTapLocation,
    this.onTapFile
  });
}

class KeyboardWidget extends StatefulWidget{
  final KeyboardListener? listener;
  final TextEditingController? textController;
  final TextInputFocusNode? textFocus;
  const KeyboardWidget({this.listener, this.textController, this.textFocus, super.key});

  @override
  State<StatefulWidget> createState() {
    return KeyboardState();
  }

}

class KeyboardState extends State<KeyboardWidget> with TickerProviderStateMixin, WidgetsBindingObserver{

  static const double EMOJI_LIST_HEIGHT = 220;
  static const double EXT_LIST_HEIGHT = 140;

  static const int ANIM_MILLI_SECONDS = 175;
  static const double EXT_ICON_SIZE = 60;

  final double _iconWidth = 40;
  late TextEditingController _contentController;
  late FocusNode _focusNode;

  bool _showTextInput = true;
  bool _showVoiceInput = false;

  late AnimationController _emojiAnim;
  late AnimationController _extAnim;
  bool _isShowKeyboard = false;
  bool _isShowEmoji = false;
  bool _isShowExt = false;

  late AnimationController _keyboardAnim;

  Widget svgPhoto = SvgPicture.asset('svg/chat/chat_photo.svg');
  Widget svgCamera = SvgPicture.asset('svg/chat/chat_camera.svg');
  Widget svgLocation = SvgPicture.asset('svg/chat/chat_location.svg');
  Widget svgFile = SvgPicture.asset('svg/chat/chat_file.svg');

  void Function()? keyboardHideCallback;
  late KeyboardListener? listener;

  SpecialTextSpanBuilder specialTextSpanBuilder = SimpleInputSpecialTextBuilder();

  @override
  void initState(){
    super.initState();
    _emojiAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: ANIM_MILLI_SECONDS));
    _extAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: ANIM_MILLI_SECONDS));
    _keyboardAnim = AnimationController(vsync: this, lowerBound: 0, upperBound: double.infinity);
    WidgetsBinding.instance.addObserver(this);
    listener = widget.listener;
    _contentController = widget.textController ?? TextEditingController();
    _focusNode = widget.textFocus ?? TextInputFocusNode();
  }

  @override
  void dispose(){
    if(widget.textController == null){
      _contentController.dispose();
    }
    if(widget.textFocus == null){
      _focusNode.dispose();
    }
    WidgetsBinding.instance.removeObserver(this);
    _emojiAnim.dispose();
    _extAnim.dispose();
    _keyboardAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        if(_isShowEmoji){
          hideEmoji();
          return false;
        }
        if(_isShowExt){
          hideExt();
          return false;
        }
        return true;
      },
      child: Column(
        children: [
          Container(
            height: 50,
            color: const Color.fromRGBO(0xf2, 0xf5, 0xfa, 1),
            child: Row(
              children: [
                Visibility(
                  visible: _showTextInput,
                  child: Container(
                    width: 52,
                    alignment: Alignment.center,
                    child: IconButton(
                      onPressed: (){
                        hideEmoji();
                        hideExt();
                        setState(() {
                          _showTextInput = false;
                          _showVoiceInput = true;
                        });
                        listener?.onTapVoice?.call();
                      },
                      icon: const Icon(Icons.keyboard_voice, size: 30,),
                    ),
                  ),
                ),
                Visibility(
                  visible: _showTextInput,
                  child: Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4
                          )
                        ]
                      ),
                      margin: const EdgeInsets.only(top: 4, bottom: 4),
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                      child: Listener(
                        onPointerDown: (event){
                          if(_keyboardAnim.value > 0 || _isShowKeyboard){
                            return;
                          }
                          if(_isShowEmoji){
                            hideEmoji().then((value){
                              showKeyboard();
                            });
                          }
                          else if(_isShowExt){
                            hideExt().then((value){
                              showKeyboard();
                            });
                          }
                          else{
                            showKeyboard();
                          }
                        },
                        child: ExtendedTextField(
                          specialTextSpanBuilder: specialTextSpanBuilder,
                          onSubmitted: (String str){
                            FocusScope.of(context).requestFocus(_focusNode);
                            if(str.trim().isEmpty){
                              FocusScope.of(context).requestFocus(_focusNode);
                              _contentController.text = '';
                              ToastUtil.warn('请输入内容');
                              return;
                            }
                            widget.listener?.onSendText?.call(str);
                          },
                          textInputAction: TextInputAction.send,
                          controller: _contentController,
                          focusNode: _focusNode,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '请输入内容',
                            hintMaxLines: 10,
                            isDense: true,
                          ),
                          maxLines: 10,
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: _showVoiceInput,
                  child: Container(
                    width: 52,
                    alignment: Alignment.center,
                    child: IconButton(
                      onPressed: (){
                        setState(() {
                          _showTextInput = true;
                          _showVoiceInput = false;
                          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                            FocusScope.of(context).requestFocus(_focusNode);
                          });
                        });
                        listener?.onTapKeyboard?.call();
                      },
                      icon: const Icon(Icons.keyboard_alt_outlined, size: 30,),
                    ),
                  ),
                ),
                Visibility(
                  visible: _showVoiceInput,
                  child: Expanded(
                    child: GestureDetector(
                      onLongPress: widget.listener?.onVoiceBegin,
                      onLongPressUp: widget.listener?.onVoiceEnd,
                      onLongPressMoveUpdate: widget.listener?.onVoiceUpdate,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4
                            )
                          ]
                        ),
                        margin: const EdgeInsets.only(top: 4, bottom: 4),
                        child: const Text('按住说话'),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: _showTextInput,
                  child: Container(
                    width: _iconWidth,
                    alignment: Alignment.center,
                    child: IconButton(
                      onPressed: (){
                        shiftEmoji();
                      },
                      icon: const Icon(Icons.emoji_emotions_outlined, size: 30,),
                    )
                  ),
                ),
                Visibility(
                  visible: _showTextInput,
                  child: Container(
                    width: _iconWidth,
                    alignment: Alignment.center,
                    child: IconButton(
                      onPressed: (){
                        shiftExt();
                      },
                      icon: const Icon(Icons.add_rounded, size: 30,),
                    ),
                  ),
                ),
                Visibility(
                  visible: _showVoiceInput,
                  child: const SizedBox(width: 40,),
                ),
                const SizedBox(width: 12)
              ],
            ),
          ),
          Stack(
            children: [
              SizeTransition(
                sizeFactor: _emojiAnim,
                axisAlignment: -1.0,
                child: SizedBox(
                  width: double.infinity,
                  height: EMOJI_LIST_HEIGHT,
                  child: EmojiPicker(
                    textEditingController: _contentController,
                    config: Config(
                      columns: 7,
                      emojiSizeMax: 32 * (foundation.defaultTargetPlatform == TargetPlatform.iOS ? 1.30 : 1.0),
                      verticalSpacing: 0,
                      horizontalSpacing: 0,
                      gridPadding: EdgeInsets.zero,
                      initCategory: Category.RECENT,
                      bgColor: ThemeUtil.backgroundColor,
                      indicatorColor: Colors.blue,
                      iconColor: Colors.grey,
                      iconColorSelected: Colors.blue,
                      backspaceColor: Colors.blue,
                      skinToneDialogBgColor: Colors.white,
                      skinToneIndicatorColor: Colors.grey,
                      enableSkinTones: true,
                      recentTabBehavior: RecentTabBehavior.RECENT,
                      recentsLimit: 28,
                      noRecents: const Text(
                        '暂无历史记录',
                        style: TextStyle(fontSize: 20, color: Colors.black26),
                        textAlign: TextAlign.center,
                      ), // Needs to be const Widget
                      loadingIndicator: const SizedBox.shrink(), // Needs to be const Widget
                      tabIndicatorAnimDuration: kTabScrollDuration,
                      categoryIcons: const CategoryIcons(),
                      buttonMode: ButtonMode.MATERIAL,
                    ),
                  ),
                )
              ),
              SizeTransition(
                sizeFactor: _extAnim,
                axisAlignment: -1.0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(26, 12, 26, 12),
                  height: EXT_LIST_HEIGHT,
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(0xf2, 0xf5, 0xfa, 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: EXT_ICON_SIZE,
                              height: EXT_ICON_SIZE,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                              ),
                              child: InkWell(
                                onTap: widget.listener?.onTapPhoto,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    width: EXT_ICON_SIZE * 0.6,
                                    height: EXT_ICON_SIZE * 0.6,
                                    child: svgPhoto,
                                  ),
                                )
                              )
                            ),
                            const SizedBox(height: 8,),
                            const Text('照片'),
                          ],
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: EXT_ICON_SIZE,
                              height: EXT_ICON_SIZE,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                              ),
                              child: InkWell(
                                onTap: widget.listener?.onTapCamera,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    width: EXT_ICON_SIZE * 0.6,
                                    height: EXT_ICON_SIZE * 0.6,
                                    child: svgCamera,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8,),
                            const Text('拍摄'),
                          ],
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: EXT_ICON_SIZE,
                              height: EXT_ICON_SIZE,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                              ),
                              child: InkWell(
                                onTap: widget.listener?.onTapLocation,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    width: EXT_ICON_SIZE * 0.6,
                                    height: EXT_ICON_SIZE * 0.6,
                                    child: svgLocation,
                                  ),
                                ),
                              )
                            ),
                            const SizedBox(height: 8,),
                            const Text('位置'),
                          ],
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: EXT_ICON_SIZE,
                              height: EXT_ICON_SIZE,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                              ),
                              child: InkWell(
                                onTap: widget.listener?.onTapFile,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    width: EXT_ICON_SIZE * 0.6,
                                    height: EXT_ICON_SIZE * 0.6,
                                    child: svgFile,
                                  ),
                                )
                              )
                            ),
                            const SizedBox(height: 8,),
                            const Text('文件'),
                          ],
                        ),
                      ),
                    ],
                  )
                )
              ),
              AnimatedBuilder(
                animation: _keyboardAnim, 
                builder: (context, child){
                  return Container(
                    height: _keyboardAnim.value,
                    color: ThemeUtil.backgroundColor,
                  );
                }
              ),
            ],
          )
        ],
      ),
    );
  }

  void showKeyboard(){
    _isShowKeyboard = true;
    FocusScope.of(context).unfocus();
    if(Platform.isAndroid){
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        FocusScope.of(context).requestFocus(_focusNode);
        SystemChannels.textInput.invokeMethod('TextInput.show');
      });
    }
    else{
      FocusScope.of(context).requestFocus(_focusNode);
      SystemChannels.textInput.invokeMethod('TextInput.show');
    }
    widget.listener?.onShowKeyboard?.call();
  }

  Future showExt() async{
    if(_isShowExt){
      return;
    }
    _isShowExt = true;
    setState(() {
    });
    widget.listener?.onShowExt?.call();
    return _extAnim.forward();
  }
  Future hideExt() async{
    if(!_isShowExt){
      return;
    }
    if(!_isShowKeyboard && !_isShowEmoji){
      widget.listener?.onHide?.call();
    }
    return _extAnim.reverse().then((value){
      _isShowExt = false;
      setState(() {
      });
    });
  }
  void shiftExt(){
    if(_isShowExt){
      hideExt();
      return;
    }
    if(_isShowKeyboard){
      keyboardHideCallback = showExt;
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    }
    else if(_isShowEmoji){
      hideEmoji().then((value){
        showExt();
      });
    }
    else{
      showExt();
    }
  }

  Future showEmoji() async{
    if(_isShowEmoji){
      return;
    }
    _isShowEmoji = true;
    setState(() {
    });
    widget.listener?.onShowEmoji?.call();
    return _emojiAnim.forward();
  }
  Future hideEmoji() async{
    if(!_isShowEmoji){
      return;
    }
    if(!_isShowKeyboard && !_isShowExt){
      widget.listener?.onHide?.call();
    }
    return _emojiAnim.reverse().then((value){
      _isShowEmoji = false;
      setState(() {
      });
    });
  }
  void shiftEmoji(){
    if(_isShowEmoji){
      hideEmoji();
      return;
    }
    if(_isShowKeyboard){
      keyboardHideCallback = showEmoji;
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    }
    else if(_isShowExt){
      hideExt().then((value){
        showEmoji();
      });
    }
    else{
      showEmoji();
    }
  }

  @override
  void didChangeMetrics(){
    super.didChangeMetrics();
    listener?.onKeyboardChange?.call();
    double keyboardHeight = EdgeInsets.fromWindowPadding(
      WidgetsBinding.instance.window.viewInsets, 
      WidgetsBinding.instance.window.devicePixelRatio).bottom;
    _keyboardAnim.value = keyboardHeight;
    if(keyboardHeight <= 0){
      _isShowKeyboard = false;
      keyboardHideCallback?.call();
      keyboardHideCallback = null;
    }
    else{
      _isShowKeyboard = true;
    }
  }
}

class SimpleInputSpecialTextBuilder extends SpecialTextSpanBuilder{
  @override
  SpecialText? createSpecialText(String flag, {TextStyle? textStyle, SpecialTextGestureTapCallback? onTap, required int index}) {
    if(flag.trim().isEmpty){
      return null;
    }
    if(isStart(flag, MessageQuoteText.startTag)){
      return MessageQuoteText(
        index - (MessageQuoteText.startTag.length - 1), 
        textStyle
      );
    }
    return null;
  }
}

class MessageQuoteText extends SpecialText{

  static const String startTag = '<@quote>';
  static const String endTag = '</@quote>';

  int start;

  MessageQuoteText(this.start, TextStyle? textStyle): super(startTag, endTag, textStyle);
  
  @override
  InlineSpan finishText() {
    final String text = toString();
    String showText = '${text.substring(startTag.length, text.length - endTag.length)}：';

    return ExtendedWidgetSpan(
      start: start,
      actualText: text,
      alignment: ui.PlaceholderAlignment.bottom,
      child: Container(
        clipBehavior: Clip.hardEdge,
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          color: Colors.black12,
        ),
        child: SelectableText.rich(
          TextSpan(
            children: [
              TextSpan(text: showText)
            ]
          )
        ),
      )
    );
  }

}
