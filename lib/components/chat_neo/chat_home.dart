import 'dart:convert' show json;

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/chat_neo/chat_common.dart';
import 'package:freego_flutter/components/chat_neo/chat_event.dart';
import 'package:freego_flutter/components/chat_neo/chat_room.dart';
import 'package:freego_flutter/components/chat_neo/chat_socket.dart';
import 'package:freego_flutter/components/chat_neo/chat_storage.dart';
import 'package:freego_flutter/components/chat_neo/chat_util.dart';
import 'package:freego_flutter/components/chat_notification/chat_notification_common.dart';
import 'package:freego_flutter/components/chat_notification/chat_notification_event.dart';
import 'package:freego_flutter/components/chat_notification/chat_notification_interact.dart';
import 'package:freego_flutter/components/chat_notification/chat_notification_order.dart';
import 'package:freego_flutter/components/chat_notification/chat_notification_storage.dart';
import 'package:freego_flutter/components/chat_notification/chat_notification_system.dart';
import 'package:freego_flutter/components/chat_notification/chat_notification_util.dart';
import 'package:freego_flutter/components/chat_notification/chat_notification_visitor.dart';
import 'package:freego_flutter/components/chat_notification_neo/model/im_notification_get_gift.dart';
import 'package:freego_flutter/components/chat_notification_neo/model/im_notification_order_hotel_state.dart';
import 'package:freego_flutter/components/chat_notification_neo/model/im_notification_order_hotel_state_for_merchant.dart';
import 'package:freego_flutter/components/chat_notification_neo/model/im_notification_order_restaurant_for_merchant.dart';
import 'package:freego_flutter/components/chat_notification_neo/model/im_notification_order_restaurant_state.dart';
import 'package:freego_flutter/components/chat_notification_neo/model/im_notification_order_scenic_state.dart';
import 'package:freego_flutter/components/chat_notification_neo/model/im_notification_order_scenic_state_for_merchant.dart';
import 'package:freego_flutter/components/chat_notification_neo/parser/im_notification_parser.dart';
import 'package:freego_flutter/components/friend_neo/friend_add.dart';
import 'package:freego_flutter/components/friend_neo/friend_home.dart';
import 'package:freego_flutter/components/order_merchant/order_merchant_hotel.dart';
import 'package:freego_flutter/components/order_merchant/order_merchant_restaurant.dart';
import 'package:freego_flutter/components/order_merchant/order_merchant_scenic.dart';
import 'package:freego_flutter/components/order_neo/order_common.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/util/date_time_util.dart';
import 'package:freego_flutter/util/route_observer.dart';
import 'package:freego_flutter/util/theme_util.dart';

class ChatHomePage extends StatefulWidget {
  //const ChatHomePage({super.key});
  final VoidCallback? onBack;
  const ChatHomePage({super.key, this.onBack});
  @override
  State<StatefulWidget> createState() {
    return ChatHomePageState();
  }
}

class ChatHomePageState extends State<ChatHomePage> with RouteAware {
  ChatHomeMenuController menuController = ChatHomeMenuController();

  @override
  void dispose() {
    menuController.dispose();
    RouteObserverUtil().routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    RouteObserverUtil()
        .routeObserver
        .subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void didPush() {
    ThemeUtil.setStatusBarDark();
  }

  @override
  void didPopNext() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ThemeUtil.setStatusBarDark();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 10,
          backgroundColor: ThemeUtil.backgroundColor,
          systemOverlayStyle: ThemeUtil.statusBarThemeDark,
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).unfocus();
            menuController.hide();
          },
          child: ChatHomeWidget(
            menuController: menuController,
            onBack: widget.onBack,
          ),
        ));
  }
}

enum ChatHomeMenuAction { show, hide }

class ChatHomeMenuController extends ChangeNotifier {
  ChatHomeMenuAction? action;
  void show() {
    action = ChatHomeMenuAction.show;
    notifyListeners();
  }

  void hide() {
    action = ChatHomeMenuAction.hide;
    notifyListeners();
  }

  void clear() {
    action = null;
  }
}

class ChatHomeWidget extends StatefulWidget {
  final ChatHomeMenuController? menuController;
  final VoidCallback? onBack;
  const ChatHomeWidget({this.menuController, this.onBack, super.key});

  @override
  State<StatefulWidget> createState() {
    return ChatHomeState();
  }
}

class _MyChatMessageHandler extends ChatMessageHandler {
  final ChatHomeState state;
  _MyChatMessageHandler(this.state) : super(priority: 10);
  @override
  Future handle(MessageObject rawObj) async {
    if (rawObj.name == ChatSocket.MESSAGE_SINGLE) {
      if (rawObj.body == null) {
        return;
      }
      ImSingleMessage message =
          ImSingleMessage.fromJson(json.decoder.convert(rawObj.body!));
      if (message.type == null) {
        return;
      }
      MessageType? type = MessageTypeExt.getType(message.type!);
      switch (type) {
        case MessageType.notifyCommand:
        case MessageType.text:
        case MessageType.image:
        case MessageType.audio:
        case MessageType.location:
        case MessageType.file:
        case MessageType.freegoVideo:
          bool findRoom = false;
          for (ImSingleRoom room in state.singleRoomList) {
            if (room.id == message.receiveRoomId) {
              room.unreadNum = (room.unreadNum ?? 0) + 1;
              if (room.lastMessageId == null ||
                  room.lastMessageId! < message.id) {
                room.lastMessageId = message.id;
                room.lastMessageType = message.type;
                room.lastMessageSender = SenderType.partner.getNum();
                room.lastMessageTime = message.sendTime;
                if (message.type == MessageType.text.getNum()) {
                  if (message.content != null &&
                      message.content!.length > ChatUtilConstants.BRIEF_SIZE) {
                    room.lastMessageBrief = message.content!
                        .substring(0, ChatUtilConstants.BRIEF_SIZE);
                  } else {
                    room.lastMessageBrief = message.content;
                  }
                } else {
                  room.lastMessageBrief = null;
                }
              }
              state.resetState();
              findRoom = true;
              break;
            }
          }
          if (!findRoom) {
            if (message.receiveRoomId != null) {
              ImSingleRoom? room =
                  await ChatStorageSingle.getRoom(message.receiveRoomId!);
              if (room != null) {
                if (!state.singleRoomList
                    .any((element) => element.id == room.id)) {
                  state.singleRoomList.add(room);
                  state.resetState();
                }
              }
            }
          }
          break;
        default:
      }
    } else if (rawObj.name == ChatSocket.MESSAGE_NOTIFICATION) {
      if (rawObj.body == null) {
        return;
      }
      ImNotification? notification =
          ImNotificationConverter.fromJson(json.decoder.convert(rawObj.body!));
      if (notification == null) {
        return;
      }
      if (notification.id == null || notification.roomId == null) {
        return;
      }
      bool findRoom = false;
      for (ImNotificationRoom room in state.notificationRoomList) {
        if (room.id == notification.roomId) {
          room.unreadNum = (room.unreadNum ?? 0) + 1;
          if (room.lastMessageId == null ||
              room.lastMessageId! < notification.id!) {
            room.lastMessageId = notification.id;
            room.lastMessageTime = notification.createTime;
          }
          findRoom = true;
          state.resetState();
          break;
        }
      }
      if (!findRoom) {
        ImNotificationRoom? room =
            await ChatNotificationStorage.getRoom(notification.roomId!);
        if (room != null) {
          if (!state.notificationRoomList
              .any((element) => element.id == room.id)) {
            state.notificationRoomList.add(room);
            state.resetState();
          }
        }
      }
    } else if (rawObj.name == ChatSocket.MESSAGE_GROUP) {}
  }
}

class _MyChatEventHandler implements ChatEventHandler {
  final ChatHomeState state;
  _MyChatEventHandler(this.state);

  @override
  Future handle(ChatEvent event) async {
    if (event is ChatEventNewSingleRoom) {
      int roomId = event.roomId;
      bool exists = false;
      List<ImSingleRoom> roomList = state.singleRoomList;
      for (ImSingleRoom room in roomList) {
        if (room.id == roomId) {
          exists = true;
          break;
        }
      }
      if (!exists) {
        ImSingleRoom? room = await ChatStorageSingle.getRoom(roomId);
        if (room != null) {
          state.singleRoomList.add(room);
          state.resetState();
        }
      }
    }
  }
}

class _MyNotificationEventHandler implements NotificationEventHandler {
  final ChatHomeState state;
  _MyNotificationEventHandler(this.state);

  @override
  Future handle(NotificationEvent event) async {
    if (event is NotificationEventNewRoom) {
      int roomId = event.roomId;
      bool exists = false;
      List<ImNotificationRoom> roomList = state.notificationRoomList;
      for (ImNotificationRoom room in roomList) {
        if (room.id == roomId) {
          exists = true;
          break;
        }
      }
      if (!exists) {
        ImNotificationRoom? room =
            await ChatNotificationStorage.getRoom(roomId);
        if (room != null) {
          state.notificationRoomList.add(room);
          state.resetState();
        }
      }
    }
  }
}

class _MyReconnectHandler extends SocketReconnectHandler {
  ChatHomeState state;
  _MyReconnectHandler(this.state) : super(priority: 99);

  @override
  Future handle() async {
    state.loadLocalData();
  }
}

class _MenuItem {
  final Widget icon;
  final String text;
  final Function(BuildContext) onClick;

  _MenuItem(this.icon, this.text, this.onClick);
}

class ChatHomeState extends State<ChatHomeWidget>
    with TickerProviderStateMixin, RouteAware {
  static const double HEADER_ICON_SIZE = 40;
  static const double MENU_ITEM_HEIGHT = 40;

  static const int MENU_ANIM_MILLI_SECONDS = 200;

  List<ImSingleRoom> singleRoomList = [];
  List<ImNotificationRoom> notificationRoomList = [];

  Widget svgMenuWidget = SvgPicture.asset('svg/chat/chat_menu.svg');

  late AnimationController menuAnim;
  bool isMenuShow = false;

  Widget svgOrderWidget = SvgPicture.asset('svg/chat/chat_order.svg');
  Widget svgInteractWidget = SvgPicture.asset('svg/chat/chat_interact.svg');
  Widget svgSystemWidget = SvgPicture.asset('svg/chat/chat_system.svg');

  late _MyChatMessageHandler _chatMessageHandler;
  late _MyChatEventHandler _chatEventHandler;
  late _MyNotificationEventHandler _notificationEventHandler;
  late _MyReconnectHandler _chatReconnectHandler;

  bool unreadMode = false;
  bool inited = false;

  String searchKeyword = '';

  List<_MenuItem> _menuItems = [];

  Widget svgPerson = SvgPicture.asset('svg/chat/person.svg');
  Widget svgPersonAdd = SvgPicture.asset('svg/chat/person_add.svg');
  Widget svgGroup = SvgPicture.asset('svg/chat/group.svg');
  Widget svgGroupAdd = SvgPicture.asset('svg/chat/group_add.svg');

  void loadLocalData() {
    Future.delayed(Duration.zero, () async {
      List<ImSingleRoom> roomResult = await ChatStorageSingle.getLocalRooms();
      singleRoomList = roomResult;
      if (mounted && context.mounted) {
        setState(() {});
      }
    });
    Future.delayed(Duration.zero, () async {
      List<ImNotificationRoom> roomResult =
          await ChatNotificationStorage.getLocalRooms();
      notificationRoomList = roomResult;
      if (mounted && context.mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didPopNext() {
    loadLocalData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    RouteObserverUtil()
        .routeObserver
        .subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    menuAnim.dispose();
    ChatSocket.removeMessageHandler(_chatMessageHandler);
    ChatEventBus().removeEventHandler(_chatEventHandler);
    NotificationEventBus()
        .removeNotificationEventHandler(_notificationEventHandler);
    RouteObserverUtil().routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    try {
      Future.delayed(Duration.zero, () async {
        singleRoomList = await ChatStorageSingle.getLocalRooms();
        notificationRoomList = await ChatNotificationStorage.getLocalRooms();
        if (mounted && context.mounted) {
          setState(() {});
        }
        // 先建立socket连接，
        // 再拉取未读消息
        // 避免拉取未读消息时新消息无法收到
        // 不过可能出现消息被获取两次的情况
        // 数据库中重复消息id一致会自动去重
        // 可能出现未读数统计2次的情况
        await ChatSocket.init();
        Future.delayed(Duration.zero, () async {
          await ChatUtilSingle.getAllUnsent();
          singleRoomList = await ChatStorageSingle.getLocalRooms();
          if (mounted && context.mounted) {
            setState(() {});
          }
        });
        Future.delayed(Duration.zero, () async {
          await ChatNotificationUtil.getAllUnsent();
          notificationRoomList = await ChatNotificationStorage.getLocalRooms();
          if (mounted && context.mounted) {
            setState(() {});
          }
        });
      });
    } finally {}
    menuAnim = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: MENU_ANIM_MILLI_SECONDS),
        lowerBound: 0,
        upperBound: 1);
    if (widget.menuController != null) {
      ChatHomeMenuController controller = widget.menuController!;
      controller.addListener(() {
        ChatHomeMenuAction? action = controller.action;
        if (action == ChatHomeMenuAction.show) {
          isMenuShow = true;
          menuAnim.forward();
          controller.clear();
        } else if (action == ChatHomeMenuAction.hide) {
          isMenuShow = false;
          menuAnim.reverse();
          controller.clear();
        }
      });
    }
    _chatMessageHandler = _MyChatMessageHandler(this);
    ChatSocket.addMessageHandler(_chatMessageHandler);
    _chatReconnectHandler = _MyReconnectHandler(this);
    ChatSocket.addReconnectHandler(_chatReconnectHandler);
    _chatEventHandler = _MyChatEventHandler(this);
    ChatEventBus().addEventHandler(_chatEventHandler);
    _notificationEventHandler = _MyNotificationEventHandler(this);
    NotificationEventBus()
        .addNotificationEventHandler(_notificationEventHandler);

    _menuItems = [
      _MenuItem(svgPersonAdd, '添加好友', (context) {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return const FriendAddPage();
        }));
      }),
      /*
      _MenuItem(
        svgGroupAdd, 
        '创建群聊', 
        (context){
          Navigator.of(context).push(MaterialPageRoute(builder: (context){
            return const GroupCreateSectPage();
          }));
        }
      ),
      */
      _MenuItem(svgPerson, '我的好友', (context) {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return const FriendHomePage();
        }));
      }),
      /*
      _MenuItem(
        svgGroup, 
        '我的群聊', 
        (context){
          Navigator.of(context).push(MaterialPageRoute(builder: (context){
            return const GroupViewPage();
          }));
        }
      )
      */
    ];
  }

  @override
  Widget build(BuildContext context) {
    int unreadNum = getTotalUnread();
    return Stack(
      children: [
        Container(
          color: ThemeUtil.backgroundColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonHeader(
                //left: Navigator.of(context).canPop() ?
                //null : const SizedBox(),
                left: (widget.onBack != null || Navigator.of(context).canPop())
                    ? IconButton(
                        icon: Icon(Icons.arrow_back_ios, size: 24),
                        color: Colors.white,
                        onPressed: () {
                          if (widget.onBack != null) {
                            widget.onBack!();
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                      )
                    : const SizedBox(),
                center: Text(
                  '消息中心${unreadNum > 0 ? '($unreadNum)' : ''}',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                right: InkWell(
                  onTap: () {
                    if (isMenuShow) {
                      isMenuShow = false;
                      menuAnim.reverse();
                    } else {
                      isMenuShow = true;
                      menuAnim.forward();
                    }
                  },
                  child: Container(
                    width: HEADER_ICON_SIZE,
                    height: HEADER_ICON_SIZE,
                    padding: const EdgeInsets.all(HEADER_ICON_SIZE * 0.25),
                    child: svgMenuWidget,
                  ),
                ),
              ),
              ChatHomeSearchBar(
                unreadNum: unreadNum,
                onSearchSubmit: (val) {
                  val = val.trim();
                  searchKeyword = val;
                  setState(() {});
                },
                onUnreadModeChange: (mode) {
                  unreadMode = mode;
                  setState(() {});
                },
              ),
              const DottedLine(
                dashColor: ThemeUtil.dividerColor,
              ),
              Expanded(
                  child: FutureBuilder<List<Widget>>(
                future: getChatCards(),
                builder: (context, snapShot) {
                  if (!inited &&
                      snapShot.connectionState != ConnectionState.done) {
                    return const SizedBox();
                  }
                  inited = true;
                  return ListView(
                    padding: EdgeInsets.zero,
                    physics: const ClampingScrollPhysics(),
                    children: snapShot.requireData,
                  );
                },
              ))
            ],
          ),
        ),
        Positioned(
          top: CommonHeader.HEADER_HEIGHT / 2 + HEADER_ICON_SIZE / 2,
          right: 10,
          child: AnimatedBuilder(
            animation: menuAnim,
            builder: (context, child) {
              return SizedBox(
                height: menuAnim.value *
                    (MENU_ITEM_HEIGHT * _menuItems.length +
                        12 * _menuItems.length),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  child: Container(
                      color: Colors.white,
                      child: Wrap(
                        children: [
                          Column(children: [
                            for (_MenuItem _menuItem in _menuItems)
                              TextButton(
                                style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap),
                                onPressed: () {
                                  _menuItem.onClick.call(context);
                                },
                                child: Container(
                                  height: MENU_ITEM_HEIGHT,
                                  margin:
                                      const EdgeInsets.only(top: 6, bottom: 6),
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 0, 12, 0),
                                  alignment: Alignment.center,
                                  child: Wrap(
                                    alignment: WrapAlignment.center,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 36,
                                        height: 36,
                                        child: _menuItem.icon,
                                      ),
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      Text(
                                        _menuItem.text,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: ThemeUtil.foregroundColor,
                                            fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                          ]

                              /*
                          [
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap
                              ),
                              onPressed: (){
                                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                  return const FriendHomePage();
                                }));
                              },
                              child: SizedBox(
                                width: MENU_ITEM_WIDTH,
                                height: MENU_ITEM_HEIGHT,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(MENU_ITEMS[0], style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black),),
                                ),
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: (){
                                Navigator.of(context).push(MaterialPageRoute(builder: ((context) {
                                  return const FriendAddPage();
                                })));
                              },
                              child: SizedBox(
                                width: MENU_ITEM_WIDTH,
                                height: MENU_ITEM_HEIGHT,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(MENU_ITEMS[1], style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black),),
                                ),
                              ),
                            ),
                          ],
                          */
                              ),
                        ],
                      )),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Future<List<Widget>> getChatCards() async {
    List<ChatCardWidget> cardWidgets = [];
    for (ImNotificationRoom room in notificationRoomList) {
      if (room.type == null) {
        continue;
      }
      if (unreadMode && room.unreadNum != null && room.unreadNum! <= 0) {
        continue;
      }
      NotificationRoomType? type = NotificationRoomTypeExt.getType(room.type!);
      switch (type) {
        case NotificationRoomType.interact:
          if ('互动消息'.contains(searchKeyword)) {
            String content = '';
            if (room.lastMessageId != null) {
              ImNotification? notification =
                  await ChatNotificationStorage.getNotification(
                      room.lastMessageId!);
              if (notification != null) {
                ImNotification? tmp =
                    ImNotificationParser().parse(notification);
                if (tmp != null) {
                  notification = tmp;
                }
              }
              content =
                  notification?.visitBy(ChatNotificationTitleVisitor()) ?? '';
            }
            cardWidgets.add(ChatCardWidget(
              title: '互动消息',
              content: content,
              time: room.lastMessageTime,
              unreadNum: room.unreadNum ?? 0,
              notDisturb: false,
              headWidget: Container(
                  width: ChatCardState.HEAD_SIZE,
                  height: ChatCardState.HEAD_SIZE,
                  decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(ChatCardState.HEAD_SIZE / 2),
                      gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color.fromRGBO(0xf5, 0xc1, 0xf3, 1),
                            Color.fromRGBO(0xfc, 0x67, 0xfa, 1)
                          ])),
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: ChatCardState.HEAD_SIZE * 0.7,
                    height: ChatCardState.HEAD_SIZE * 0.7,
                    child: svgInteractWidget,
                  )),
              isSystem: true,
              onClick: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return ChatNotificationInteractPage(room);
                }));
              },
            ));
          }
          break;
        case NotificationRoomType.order:
          if ('订单消息'.contains(searchKeyword)) {
            String content = '';
            if (room.lastMessageId != null) {
              ImNotification? notification =
                  await ChatNotificationStorage.getNotification(
                      room.lastMessageId!);
              if (notification != null) {
                ImNotification? tmp =
                    ImNotificationParser().parse(notification);
                if (tmp != null) {
                  notification = tmp;
                }
              }
              content =
                  notification?.visitBy(ChatNotificationTitleVisitor()) ?? '';
            }
            cardWidgets.add(ChatCardWidget(
              title: '订单消息',
              content: content,
              time: room.lastMessageTime,
              unreadNum: room.unreadNum ?? 0,
              notDisturb: false,
              headWidget: Container(
                  width: ChatCardState.HEAD_SIZE,
                  height: ChatCardState.HEAD_SIZE,
                  decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(ChatCardState.HEAD_SIZE / 2),
                      gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color.fromRGBO(0xc5, 0xf4, 0xc3, 1),
                            Color.fromRGBO(0x67, 0xfc, 0xac, 1)
                          ])),
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: ChatCardState.HEAD_SIZE * 0.7,
                    height: ChatCardState.HEAD_SIZE * 0.7,
                    child: svgOrderWidget,
                  )),
              isSystem: true,
              onClick: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return ChatNotificationOrderPage(room);
                }));
              },
            ));
          }
          break;
        case NotificationRoomType.system:
          if ('系统消息'.contains(searchKeyword)) {
            String content = '';
            if (room.lastMessageId != null) {
              ImNotification? notification =
                  await ChatNotificationStorage.getNotification(
                      room.lastMessageId!);
              if (notification != null) {
                ImNotification? tmp =
                    ImNotificationParser().parse(notification);
                if (tmp != null) {
                  notification = tmp;
                }
              }
              content =
                  notification?.visitBy(ChatNotificationTitleVisitor()) ?? '';
            }
            cardWidgets.add(ChatCardWidget(
              title: '系统消息',
              content: content,
              time: room.lastMessageTime,
              unreadNum: room.unreadNum ?? 0,
              notDisturb: false,
              headWidget: Container(
                width: ChatCardState.HEAD_SIZE,
                height: ChatCardState.HEAD_SIZE,
                decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(ChatCardState.HEAD_SIZE / 2),
                    gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.fromRGBO(0xa1, 0xfa, 0xfa, 1),
                          Color.fromRGBO(0x20, 0xd7, 0xf8, 1)
                        ])),
                alignment: Alignment.center,
                child: SizedBox(
                  width: ChatCardState.HEAD_SIZE * 0.7,
                  height: ChatCardState.HEAD_SIZE * 0.7,
                  child: svgSystemWidget,
                ),
              ),
              isSystem: true,
              onClick: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return ChatNotificationSystemPage(room: room);
                }));
              },
            ));
          }
          break;
        default:
      }
    }
    for (ImSingleRoom room in singleRoomList) {
      if (room.partnerName == null ||
          !room.partnerName!.contains(searchKeyword)) {
        continue;
      }
      if (unreadMode && room.unreadNum != null && room.unreadNum! <= 0) {
        continue;
      }
      String content = '';
      if (room.lastMessageType != null) {
        MessageType? type = MessageTypeExt.getType(room.lastMessageType!);
        switch (type) {
          case MessageType.notifyCommand:
            if (room.lastMessageBrief == null) {
              break;
            }
            MessageCommand<Object> rawCmd =
                MessageCommand.fromText(room.lastMessageBrief!);
            if (rawCmd.cmdType == null) {
              break;
            }
            CommandType? commandType = CommandTypeExt.getType(rawCmd.cmdType!);
            switch (commandType) {
              case CommandType.retracted:
                const String remoteInfo = '对方撤回了一条消息';
                const String localInfo = '您撤回了一条消息';
                if (room.lastMessageSender == SenderType.ownner.getNum()) {
                  content = localInfo;
                } else if (room.lastMessageSender ==
                    SenderType.partner.getNum()) {
                  content = remoteInfo;
                }
                break;
              case CommandType.newPartner:
                const String remoteInfo = "#{friendName}同意了您的好友申请";
                const String localInfo = "您同意了#{friendName}的好友申请";
                if (room.partnerName != null) {
                  if (room.lastMessageSender == SenderType.ownner.getNum()) {
                    content = localInfo.replaceAll(
                        '#{friendName}', room.partnerName!);
                  } else {
                    content = remoteInfo.replaceAll(
                        '#{friendName}', room.partnerName!);
                  }
                }
                break;
              default:
            }
            break;
          case MessageType.text:
            content = room.lastMessageBrief ?? '';
            break;
          case MessageType.image:
            content = '[图片]';
            break;
          case MessageType.audio:
            content = '[音频]';
            break;
          case MessageType.location:
            content = '[地址]';
            break;
          case MessageType.file:
            content = '[文件]';
            break;
          case MessageType.freegoVideo:
            content = '[视频]';
            break;
          default:
        }
        switch (type) {
          case MessageType.text:
          case MessageType.image:
          case MessageType.audio:
          case MessageType.location:
          case MessageType.file:
          case MessageType.freegoVideo:
            if (room.lastMessageSender == SenderType.ownner.getNum()) {
              content = '我：$content';
            } else if (room.lastMessageSender == SenderType.partner.getNum()) {
              content = '${room.partnerName}：$content';
            }
            break;
          default:
        }
      }
      cardWidgets.add(ChatCardWidget(
        title: room.partnerName ?? '',
        content: content,
        time: room.lastMessageTime ?? room.createTime,
        unreadNum: room.unreadNum ?? 0,
        notDisturb: room.notDisturb ?? false,
        headWidget: room.partnerHead != null
            ? Image.network(
                getFullUrl(room.partnerHead!),
                fit: BoxFit.fill,
                width: double.infinity,
                height: double.infinity,
              )
            : Image.asset(
                'images/default_head.png',
                fit: BoxFit.fill,
                width: double.infinity,
                height: double.infinity,
              ),
        isSystem: false,
        onClick: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return ChatRoomPage(
              room: room,
            );
          }));
        },
      ));
    }
    cardWidgets.sort((a, b) {
      if (b.time == null) {
        return -1;
      }
      if (a.time == null) {
        return 1;
      }
      return b.time!.compareTo(a.time!);
    });
    List<Widget> widgets = [];
    for (ChatCardWidget cardWidget in cardWidgets) {
      widgets.add(cardWidget);
      widgets.add(getDashedDivider());
    }
    return widgets;
  }

  Widget getDashedDivider() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
      child: DottedLine(dashColor: ThemeUtil.dividerColor),
    );
  }

  int getTotalUnread() {
    int total = 0;
    for (ImSingleRoom room in singleRoomList) {
      total += (room.unreadNum ?? 0);
    }
    for (ImNotificationRoom room in notificationRoomList) {
      total += (room.unreadNum ?? 0);
    }
    return total;
  }

  void resetState() {
    if (mounted && context.mounted) {
      setState(() {});
    }
  }
}

class ChatCardWidget extends StatefulWidget {
  final String title;
  final String content;
  final DateTime? time;
  final int unreadNum;
  final bool notDisturb;
  final Widget headWidget;
  final void Function()? onClick;
  final bool isSystem;

  const ChatCardWidget(
      {required this.title,
      required this.content,
      required this.time,
      required this.unreadNum,
      required this.notDisturb,
      required this.headWidget,
      this.onClick,
      required this.isSystem,
      super.key});

  @override
  State<StatefulWidget> createState() {
    return ChatCardState();
  }
}

class ChatCardState extends State<ChatCardWidget> {
  static const double CARD_HEIGHT = 72;
  static const double HEAD_SIZE = 56;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: CARD_HEIGHT,
      padding: const EdgeInsets.only(left: 12),
      decoration: const BoxDecoration(
        color: Color.fromRGBO(242, 245, 250, 1),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onLongPressStart: (e) {},
        onTap: widget.onClick,
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ClipOval(
                  clipBehavior: Clip.hardEdge,
                  child: SizedBox(
                    width: HEAD_SIZE,
                    height: HEAD_SIZE,
                    child: widget.headWidget,
                  ),
                ),
                widget.unreadNum <= 0
                    ? const SizedBox()
                    : Positioned(
                        top: 0,
                        right: 0,
                        child: widget.notDisturb
                            ? Container(
                                height: 10,
                                width: 10,
                                decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10)),
                              )
                            : Container(
                                height: 14,
                                width: 14,
                                decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(14)),
                                alignment: Alignment.center,
                                child: Text(
                                  '${widget.unreadNum <= 99 ? widget.unreadNum : 99}',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 10),
                                ),
                              ))
              ],
            ),
            Expanded(
                child: Container(
              height: 40,
              margin: const EdgeInsets.only(left: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 20,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.title,
                      textDirection: TextDirection.ltr,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    height: 20,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.content,
                      textDirection: TextDirection.ltr,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color.fromRGBO(0x99, 0x99, 0x99, 1)),
                    ),
                  )
                ],
              ),
            )),
            Container(
              margin: const EdgeInsets.only(right: 16),
              width: 60,
              height: 40,
              alignment: Alignment.centerRight,
              child: widget.isSystem
                  ? const Icon(
                      Icons.arrow_forward_ios,
                      size: 20,
                      color: Color.fromRGBO(0x99, 0x99, 0x99, 1),
                    )
                  : widget.time == null
                      ? const SizedBox()
                      : Text(
                          DateTimeUtil.getRelativeTime(widget.time!),
                          style: const TextStyle(
                              fontSize: 14,
                              color: Color.fromRGBO(0x99, 0x99, 0x99, 1)),
                        ),
            )
          ],
        ),
      ),
    );
  }
}

class ChatHomeSearchBarController extends ChangeNotifier {
  int? unreadNum;
  void setUnreadNum(int num) {
    unreadNum = num;
    notifyListeners();
  }
}

class ChatHomeSearchBar extends StatefulWidget {
  final Function(String)? onSearchSubmit;
  final Function(bool)? onUnreadModeChange;
  final int unreadNum;
  const ChatHomeSearchBar(
      {this.onSearchSubmit,
      this.onUnreadModeChange,
      this.unreadNum = 0,
      super.key});

  @override
  State<StatefulWidget> createState() {
    return ChatHomeSearchBarState();
  }
}

class ChatHomeSearchBarState extends State<ChatHomeSearchBar>
    with TickerProviderStateMixin {
  static const double SEARCH_ROW_HEIGHT = 72;
  static const double SEARCH_BAR_WIDTH_FACTOR = 0.64;
  static const double UNREAD_SWITCH_WIDTH_FACTOR = 0.36;
  static const double SEARCH_ROW_ITEM_HEIGHT_FACTOR = 0.56;
  static const double SEARCH_BAR_SUBMIT_WIDTH_FACTOR = 0.22;

  static const int SEARCH_BAR_ANIM_MILLI_SECONDS = 200;

  TextEditingController textController = TextEditingController();
  FocusNode textFocus = FocusNode();
  late AnimationController searchBarTransform;
  bool isShowSearchNavi = true;
  late AnimationController searchBarOpacity;

  Widget svgSearch = SvgPicture.asset('svg/chat/chat_search.svg');
  Widget svgSearchSubmit = SvgPicture.asset('svg/chat/chat_search_submit.svg');

  bool unreadMode = false;

  @override
  void initState() {
    super.initState();
    searchBarTransform = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: SEARCH_BAR_ANIM_MILLI_SECONDS),
        lowerBound: 0,
        upperBound: 1 - UNREAD_SWITCH_WIDTH_FACTOR);
    searchBarOpacity = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: SEARCH_BAR_ANIM_MILLI_SECONDS));
    textFocus.addListener(() {
      if (!textFocus.hasFocus) {
        if (textController.text == '') {
          searchBarTransform.reverse().then((value) {
            isShowSearchNavi = true;
            setState(() {});
          });
          searchBarOpacity.reverse();
        }
      }
    });
  }

  @override
  void dispose() {
    textController.dispose();
    textFocus.dispose();
    searchBarTransform.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SEARCH_ROW_HEIGHT,
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Wrap(runAlignment: WrapAlignment.center, children: [
        if (isShowSearchNavi)
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () {
                isShowSearchNavi = false;
                setState(() {});
                searchBarTransform.forward();
                searchBarOpacity.forward();
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  FocusScope.of(context).requestFocus(textFocus);
                });
              },
              child: SizedBox(
                width: SEARCH_ROW_HEIGHT * SEARCH_ROW_ITEM_HEIGHT_FACTOR,
                height: SEARCH_ROW_HEIGHT * SEARCH_ROW_ITEM_HEIGHT_FACTOR,
                child: svgSearch,
              ),
            ),
          ),
        if (!isShowSearchNavi)
          AnimatedBuilder(
              animation: searchBarTransform,
              builder: (context, child) {
                return ConstrainedBox(
                  constraints: const BoxConstraints(
                      minWidth:
                          SEARCH_ROW_HEIGHT * SEARCH_ROW_ITEM_HEIGHT_FACTOR +
                              10),
                  child: FadeTransition(
                    opacity: searchBarOpacity,
                    child: FractionallySizedBox(
                      widthFactor: searchBarTransform.value,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Wrap(
                          clipBehavior: Clip.hardEdge,
                          runAlignment: WrapAlignment.center,
                          children: [
                            FractionallySizedBox(
                              widthFactor:
                                  0.99 - SEARCH_BAR_SUBMIT_WIDTH_FACTOR,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: const BorderRadius.horizontal(
                                      left: Radius.circular(
                                          SEARCH_ROW_HEIGHT * 0.15)),
                                ),
                                height: SEARCH_ROW_HEIGHT *
                                    SEARCH_ROW_ITEM_HEIGHT_FACTOR,
                                child: TextField(
                                  keyboardType: TextInputType.multiline,
                                  textInputAction: TextInputAction.search,
                                  decoration: const InputDecoration(
                                    hintText: '    搜 索',
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                    ),
                                    isDense: true,
                                    contentPadding:
                                        EdgeInsets.fromLTRB(8, 10, 8, 10),
                                    border: InputBorder.none,
                                  ),
                                  style: const TextStyle(
                                      color: Colors.black54, fontSize: 16),
                                  controller: textController,
                                  focusNode: textFocus,
                                  onSubmitted: (val) {
                                    widget.onSearchSubmit?.call(val);
                                  },
                                ),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor:
                                  SEARCH_BAR_SUBMIT_WIDTH_FACTOR - 0.01,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.horizontal(
                                      right: Radius.circular(
                                          SEARCH_ROW_HEIGHT * 0.15)),
                                ),
                                height: SEARCH_ROW_HEIGHT *
                                    SEARCH_ROW_ITEM_HEIGHT_FACTOR,
                                alignment: Alignment.center,
                                child: SizedBox(
                                  width: SEARCH_ROW_HEIGHT *
                                      SEARCH_ROW_ITEM_HEIGHT_FACTOR *
                                      0.7,
                                  height: SEARCH_ROW_HEIGHT *
                                      SEARCH_ROW_ITEM_HEIGHT_FACTOR *
                                      0.7,
                                  child: svgSearchSubmit,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
        FractionallySizedBox(
          widthFactor: UNREAD_SWITCH_WIDTH_FACTOR,
          child: InkWell(
            onTap: () {
              unreadMode = !unreadMode;
              widget.onUnreadModeChange?.call(unreadMode);
              setState(() {});
            },
            child: ClipRRect(
              borderRadius: const BorderRadius.all(
                  Radius.circular(SEARCH_ROW_HEIGHT * 0.15)),
              child: Container(
                  color: unreadMode ? ThemeUtil.buttonColor : Colors.white,
                  height: SEARCH_ROW_HEIGHT * SEARCH_ROW_ITEM_HEIGHT_FACTOR,
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '未读消息',
                          style: TextStyle(
                              color:
                                  unreadMode ? Colors.white : Colors.black54),
                        ),
                        Text(
                          '（${widget.unreadNum < 100 ? widget.unreadNum : '99+'}条）',
                          style: TextStyle(
                              color: unreadMode ? Colors.white : Colors.grey),
                        )
                      ],
                    ),
                  )),
            ),
          ),
        )
      ]),
    );
  }
}

class ChatNotificationTitleVisitor extends ChatNotificationVisitor<String> {
  ChatNotificationTitleVisitor._internal();
  static final ChatNotificationTitleVisitor _instance =
      ChatNotificationTitleVisitor._internal();
  factory ChatNotificationTitleVisitor() {
    return _instance;
  }

  @override
  String? visit(ImNotification notification) {
    NotificationType? type;
    if (notification.type != null) {
      type = NotificationTypeExt.getType(notification.type!);
    }
    return type?.getName();
  }

  @override
  String? visitGetGift(ImNotificationGetGift notification) {
    return '收到打赏';
  }

  @override
  String? visitHotelOrderState(ImNotificationOrderHotelState notification) {
    OrderHotelStatus? orderStatus;
    if (notification.orderStatus != null) {
      orderStatus = OrderHotelStatusExt.getStatus(notification.orderStatus!);
    }
    return OrderHotelStatusExt(orderStatus)?.getText();
  }

  @override
  String? visitScenicOrderState(ImNotificationOrderScenicState notification) {
    OrderScenicStatus? orderStatus;
    if (notification.orderStatus != null) {
      orderStatus = OrderScenicStatusExt.getStatus(notification.orderStatus!);
    }
    return OrderScenicStatusExt(orderStatus)?.getText();
  }

  @override
  String? visitRestaurantOrderState(
      ImNotificationOrderRestaurantState notification) {
    OrderRestaurantStatus? orderStatus;
    if (notification.orderStatus != null) {
      orderStatus =
          OrderRestaurantStatusExt.getStatus(notification.orderStatus!);
    }
    return OrderRestaurantStatusExt(orderStatus)?.getText();
  }

  @override
  String? visitHotelOrderStateForMerchant(
      ImNotificationOrderHotelStateForMerchant notification) {
    OrderHotelStatus? orderStatus;
    if (notification.orderStatus != null) {
      orderStatus = OrderHotelStatusExt.getStatus(notification.orderStatus!);
    }
    return MyOrderHotelStatusExt(orderStatus)?.getText();
  }

  @override
  String? visitScenicOrderStateForMerchant(
      ImNotificationOrderScenicStateForMerchant notification) {
    OrderScenicStatus? orderStatus;
    if (notification.orderStatus != null) {
      orderStatus = OrderScenicStatusExt.getStatus(notification.orderStatus!);
    }
    return MyOrderScenicStatusExt(orderStatus)?.getText();
  }

  @override
  String? visitRestaurantOrderStateForMerchant(
      ImNotificationOrderRestaurantStateForMerchant notification) {
    OrderRestaurantStatus? orderStatus;
    if (notification.orderStatus != null) {
      orderStatus =
          OrderRestaurantStatusExt.getStatus(notification.orderStatus!);
    }
    return MyOrderRestaurantStatusExt(orderStatus)?.getText();
  }
}
