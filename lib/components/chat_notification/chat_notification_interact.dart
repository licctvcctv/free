
import 'dart:convert' show json;
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
import 'package:freego_flutter/components/chat_notification_neo/model/im_notification_get_gift.dart';
import 'package:freego_flutter/components/chat_notification_neo/parser/im_notification_parser.dart';
import 'package:freego_flutter/components/circle_neo/circle_common.dart';
import 'package:freego_flutter/components/circle_neo/circle_http.dart';
import 'package:freego_flutter/components/circle_neo/detail/circle_activity.dart';
import 'package:freego_flutter/components/circle_neo/detail/circle_activity_apply_http.dart';
import 'package:freego_flutter/components/comment/comment_model.dart';
import 'package:freego_flutter/components/comment/comment_sub_util.dart';
import 'package:freego_flutter/components/friend_neo/friend_http.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/custom_indicator.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/http/http_tool.dart';
import 'package:freego_flutter/local_storage/model/local_guide.dart';
import 'package:freego_flutter/local_storage/model/local_item.dart';
import 'package:freego_flutter/local_storage/model/local_user.dart';
import 'package:freego_flutter/local_storage/util/local_guide_util.dart';
import 'package:freego_flutter/local_storage/util/local_item_util.dart';
import 'package:freego_flutter/local_storage/util/local_user_util.dart';
import 'package:freego_flutter/util/date_time_util.dart';
import 'package:freego_flutter/util/dictionary_util.dart';
import 'package:freego_flutter/util/label_util.dart';
import 'package:freego_flutter/util/product_redirector.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:freego_flutter/util/user_like_util.dart';

class ChatNotificationInteractPage extends StatefulWidget{
  final ImNotificationRoom room;
  const ChatNotificationInteractPage(this.room, {super.key});

  @override
  State<StatefulWidget> createState() {
    return ChatNotificationInteractPageState();
  }
  
}

class ChatNotificationInteractPageState extends State<ChatNotificationInteractPage>{
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
      body: ChatNotificationInteractWidget(widget.room),
    );
  }

}

class ChatNotificationInteractWidget extends StatefulWidget{
  final ImNotificationRoom room;
  const ChatNotificationInteractWidget(this.room, {super.key});

  @override
  State<StatefulWidget> createState() {
    return ChatNotificationInteractState();
  }

}

class MyChatNotificationHandler extends ChatMessageHandler{

  ChatNotificationInteractState state;
  MyChatNotificationHandler(this.state) :super(priority: 10);

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
    state.topBuffer = await state.getNotificationWidgets([notification]);
    state.resetState();
    ChatNotificationUtil().readAll(notification.roomId!);
  }

}

class _MyReconnectHandler extends SocketReconnectHandler{

  final ChatNotificationInteractState _state;
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
    _state.topBuffer = await _state.getNotificationWidgets(tmpList);
    _state.resetState();
    ChatNotificationUtil().readAll(_state.widget.room.id!);
  }

}

class ChatNotificationInteractState extends State<ChatNotificationInteractWidget>{

  List<ImNotification> notificationList = [];

  List<Widget> topBuffer = [];
  List<Widget> content = [];
  List<Widget> bottomBuffer = [];

  late MyChatNotificationHandler newNotificationHandler;
  late _MyReconnectHandler _myReconnectHandler;

  static final MyChatNotificationVisitor notificationVisitor = MyChatNotificationVisitor();

  @override
  void initState(){
    super.initState();
    int? roomId = widget.room.id;
    Future.delayed(Duration.zero, () async{
      if(roomId == null){
        return;
      }
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
      topBuffer = await getNotificationWidgets(notificationList);
      if(mounted && context.mounted){
        setState(() {
        });
      }
    });
    if(roomId != null){
      ChatNotificationUtil().readAll(roomId);
    }
    newNotificationHandler = MyChatNotificationHandler(this);
    ChatSocket.addMessageHandler(newNotificationHandler);
    _myReconnectHandler = _MyReconnectHandler(this);
    ChatSocket.addReconnectHandler(_myReconnectHandler);
  }

  @override
  void dispose(){
    ChatSocket.removeMessageHandler(newNotificationHandler);
    ChatSocket.removeReconnectHandler(_myReconnectHandler);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: ThemeUtil.backgroundColor,
      child: Column(
        children: [
          const CommonHeader(
            center: Text('互动消息', style: TextStyle(color: Colors.white),),
          ),
          Expanded(
            child: AnimatedCustomIndicatorWidget(
              topBuffer: topBuffer,
              contents: content,
              bottomBuffer: bottomBuffer,
              touchBottom: () async{
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
                List<ImNotification> newList = [];
                for(ImNotification notification in tmpList){
                  ImNotification? tmp = ImNotificationParser().parse(notification);
                  if(tmp == null){
                    newList.add(notification);
                  }
                  else{
                    newList.add(tmp);
                  }
                }
                notificationList.addAll(newList);
                bottomBuffer = await getNotificationWidgets(newList);
                if(mounted && context.mounted){
                  setState(() {
                  });
                } 
              },
            )
          )
        ],
      ),
    );
  }

  Future<List<Widget>> getNotificationWidgets(List<ImNotification> notificationList) async{
    List<Widget> widgets = [];
    for(ImNotification notification in notificationList){
      Future<Widget?>? future = notification.visitBy(notificationVisitor);
      if(future != null){
        Widget? widget = await future;
        if(widget != null){
          widgets.add(widget);
        }
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

class MyChatNotificationVisitor extends ChatNotificationVisitor<Future<Widget?>>{
  
  @override
  Future<Widget?> visit(ImNotification notification) async{
    if(notification is ImNotificationInteractFriendApply){
      return NotificationWrapper(
        NotificationFriendApplyWidget(notification,),
        key: ValueKey('notification_${notification.id}'),
      );
    }
    else if(notification is ImNotificationInteractProductLiked){
      return NotificationWrapper(
        NotificationProductLikedWidget(notification,),
        key: ValueKey('notification_${notification.id}'),
      );
    }
    else if(notification is ImNotificationInteractProductCommented){
      return NotificationWrapper(
        NotificationProductCommentedWidget(notification,),
        key: ValueKey('notification_${notification.id}'),
      );
    }
    else if(notification is ImNotificationInteractProductLikedMonument){
      return NotificationWrapper(
        NotificationProductLikedMonumentWidget(notification,),
        key: ValueKey('notification_${notification.id}'),
      );
    }
    else if(notification is ImNotificationInteractCommentCommented){
      return NotificationWrapper(
        NotificationCommentCommentedWidget(notification,),
        key: ValueKey('notification_${notification.id}'),
      );
    }
    else if(notification is ImNotificationInteractCommentLiked){
      return NotificationWrapper(
        NotificationCommentLikedWidget(notification,),
        key: ValueKey('notification_${notification.id}'),
      );
    }
    else if(notification is ImNotificationInteractCircleActivityApplied){
      return NotificationWrapper(
        NotificationCircleActivityAppliedWidget(notification,),
        key: ValueKey('notification_${notification.id}'),
      );
    }
    return null;
  }

  @override
  Future<Widget?> visitGetGift(ImNotificationGetGift notification) async{
    List<Object?> results = await Future.wait([LocalUserUtil().get(notification.giver!), LocalGuideUtil().get(notification.productId!), LocalItemUtil().get(notification.itemId!)]);
    LocalUser? localUser;
    LocalGuide? localGuide;
    LocalItem? localItem;
    for(Object? obj in results){
      if(obj is LocalUser){
        localUser = obj;
      }
      if(obj is LocalGuide){
        localGuide = obj;
      }
      if(obj is LocalItem){
        localItem = obj;
      }
    }
    return NotificationWrapper(
      NotificationGetGiftWidget(
        notification: notification,
        localUser: localUser,
        localGuide: localGuide,
        localItem: localItem
      ),
      key: ValueKey('notification_${notification.id}'),
    );
  }
}

class NotificationGetGiftWidget extends StatefulWidget{

  final ImNotificationGetGift notification;
  final LocalUser? localUser;
  final LocalGuide? localGuide;
  final LocalItem? localItem;
  const NotificationGetGiftWidget({required this.notification, this.localUser, this.localGuide, this.localItem, super.key});
  
  @override
  State<StatefulWidget> createState() {
    return NotificationGetGiftState();
  }

}

class NotificationGetGiftState extends State<NotificationGetGiftWidget>{

  static const double AVATAR_SIZE = 60;
  static const double ITEM_SIZE = 40;

  late ImNotificationGetGift notification;

  @override
  void initState(){
    super.initState();
    notification = widget.notification;
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    ClipOval(
                      child: SizedBox(
                        width: AVATAR_SIZE,
                        height: AVATAR_SIZE,
                        child: 
                        widget.localUser == null ?
                        Container(
                          color: Colors.grey,
                          child: const Icon(Icons.question_mark_rounded, color: Colors.white, size: AVATAR_SIZE),
                        ) :
                        Image.network(
                          getFullUrl(widget.localUser!.headUrl!),
                          fit: BoxFit.cover,
                          width: AVATAR_SIZE,
                          height: AVATAR_SIZE,
                        )
                      ),
                    ),
                    const SizedBox(width: 10,),
                    Expanded(
                      child: Text(StringUtil.getLimitedText(widget.localUser?.name ?? '', DictionaryUtil.USERNAME_MAX_LENGTH), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(width: AVATAR_SIZE + 10,),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(text: '在', style: TextStyle(color: ThemeUtil.foregroundColor)),
                            TextSpan(
                              text: '《${widget.localGuide?.name}》',
                              style: const TextStyle(color: Colors.lightBlue),
                              recognizer: TapGestureRecognizer()..onTap = () async{
                                if(notification.productId == null){
                                  ToastUtil.error('目标不存在');
                                  return;
                                }
                                bool result = await ProductRedirector().redirect(productId: notification.productId!, type: ProductType.guide, context: context);
                                if(!result){
                                  ToastUtil.error('目标已失效');
                                }
                              }
                            ),
                            const TextSpan(text: '中打赏了礼物', style: TextStyle(color: ThemeUtil.foregroundColor))
                          ]
                        ),
                      )
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const SizedBox(width: AVATAR_SIZE + 10,),
                    Expanded(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 10,
                        children: [
                          widget.localItem == null ?
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.all(Radius.circular(10))
                            ),
                            width: ITEM_SIZE,
                            height: ITEM_SIZE,
                            child: const Icon(Icons.question_mark_rounded, size: ITEM_SIZE, color: Colors.white,),
                          ) : 
                          ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                            child: Image.network(getFullUrl(widget.localItem!.imageUrl!), fit: BoxFit.cover, width: ITEM_SIZE, height: ITEM_SIZE,),
                          ),
                          Expanded(
                            child: Text(widget.localItem?.name ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold))
                          ),
                          Text('X ${notification.count}', style: const TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold, fontSize: 16))
                        ],
                      )
                    )
                  ],
                )
              ],
            ),
          ),
          const SizedBox(width: 10),
          notification.createTime == null ?
          const SizedBox() :
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(DateTimeUtil.getRelativeTime(notification.createTime!), style: const TextStyle(color: Colors.grey),),
          )
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

class NotificationCommentCommentReplyWidget extends StatefulWidget{

  final ImNotificationInteractCommentCommented notification;
  const NotificationCommentCommentReplyWidget(this.notification, {super.key});

  @override
  State<StatefulWidget> createState() {
    return NotificationCommentCommentedState();
  }

}

class NotificationCommentReplyWidget extends StatefulWidget{

  final String? partnerName;
  final String? partnerHead;
  final String? content;
  final Function(String)? onReply;
  const NotificationCommentReplyWidget({this.partnerName, this.partnerHead, this.content, this.onReply, super.key});

  @override
  State<StatefulWidget> createState() {
    return NotificationCommentReplyState();
  }

}

class NotificationCommentReplyState extends State<NotificationCommentReplyWidget>{

  static const double HEIGHT = 400;
  static const double AVATAR_SIZE = 60;
  static const double SUBMIT_BUTTON_HEIGHT = 60;
  static const double SUBMIT_BUTTON_WIDTH = 200;

  TextEditingController textController = TextEditingController();

  @override
  void dispose(){
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Material(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: (){
              FocusScope.of(context).unfocus();
            },
            child: Container(
              height: HEIGHT,
              width: double.infinity,
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
              clipBehavior: Clip.hardEdge,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: ThemeUtil.backgroundColor,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    clipBehavior: Clip.hardEdge,
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            ClipOval(
                              child: SizedBox(
                                width: AVATAR_SIZE,
                                height: AVATAR_SIZE,
                                child: widget.partnerHead == null ?
                                ThemeUtil.defaultUserHead :
                                Image.network(getFullUrl(widget.partnerHead!), fit: BoxFit.fill,),
                              ),
                            ),
                            const SizedBox(width: 10,),
                            widget.partnerName == null ?
                            const SizedBox() :
                            Text(StringUtil.getLimitedText(widget.partnerName!, DictionaryUtil.USERNAME_MAX_LENGTH), style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),)
                          ],
                        ),
                        const SizedBox(height: 10,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: AVATAR_SIZE + 10,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text('评论：', style: TextStyle(color: ThemeUtil.foregroundColor),),
                              ),
                            ),
                            Text(widget.content ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: ThemeUtil.foregroundColor),)
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20,),
                  Container(
                    width: double.infinity,
                    height: 100,
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
                    child: TextField(
                      controller: textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: 10,
                      decoration: const InputDecoration(
                        hintText: '友好的回复一下哟~',
                        hintStyle: TextStyle(color: Colors.grey),
                        isDense: true,
                        contentPadding: EdgeInsets.fromLTRB(8, 10, 8, 10),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20,),
                  TextButton(
                    onPressed: () {
                      widget.onReply?.call(textController.text);
                    },
                    child: Container(
                      width: SUBMIT_BUTTON_WIDTH,
                      height: SUBMIT_BUTTON_HEIGHT,
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(3, 169, 244, 0.6),
                        borderRadius: BorderRadius.all(Radius.circular(12))
                      ),
                      alignment: Alignment.center,
                      child: const Text('回 复', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),)
                    )
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

}

class NotificationCommentLikedWidget extends StatelessWidget{

  static const double AVATAR_SIZE = 60;

  final ImNotificationInteractCommentLiked notification;
  const NotificationCommentLikedWidget(this.notification, {super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    ClipOval(
                      child: SizedBox(
                        width: AVATAR_SIZE,
                        height: AVATAR_SIZE,
                        child: notification.partnerHead == null ?
                        ThemeUtil.defaultUserHead :
                        Image.network(getFullUrl(notification.partnerHead!), fit: BoxFit.fill,)
                      ),
                    ),
                    const SizedBox(width: 10,),
                    Expanded(
                      child: Text(notification.partnerName == null ? '' : StringUtil.getLimitedText(notification.partnerName!, DictionaryUtil.USERNAME_MAX_LENGTH), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(width: AVATAR_SIZE + 10,),
                    Expanded(
                      child: getNameWidget(context)
                    )
                  ],
                ),
                const SizedBox(height: 10,),
                Row(
                  children: [
                    const SizedBox(width: AVATAR_SIZE + 10,),
                    Expanded(
                      child: getContentWidget(),
                    )
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          notification.createTime == null ?
          const SizedBox() :
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(DateTimeUtil.getRelativeTime(notification.createTime!), style: const TextStyle(color: Colors.grey),),
          )
        ],
      )
    );
  }

  Widget getContentWidget(){
    return RichText(
      text: TextSpan(
        text: '我的评论：${notification.innerContent ?? ''}',
        style: const TextStyle(color: ThemeUtil.foregroundColor)
      ),
    );
  }

  Widget getNameWidget(BuildContext context){
    if(notification.subType == null){
      return const SizedBox();
    }
    ProductType? type = ProductTypeExt.getType(notification.subType!);
    if(type == null){
      return const SizedBox();
    }
    String nameStr = notification.productName ?? '';
    switch(type){
      case ProductType.guide:
      case ProductType.hotel:
      case ProductType.video:
      case ProductType.restaurant:
      case ProductType.scenic:
      case ProductType.travel:
      case ProductType.circle:
        nameStr =  '《$nameStr》';
        break;
      default:
        nameStr = ': $nameStr';
    }
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: '在${LabelUtil.getProductName(type)}', style: const TextStyle(color: ThemeUtil.foregroundColor)),
          TextSpan(
            text: nameStr, 
            style: const TextStyle(color: Colors.lightBlue),
            recognizer: TapGestureRecognizer()
              ..onTap = () async{
                if(notification.productId == null){
                  ToastUtil.error('目标不存在');
                  return;
                }
                bool result = await ProductRedirector().redirect(productId: notification.productId!, type: type, context: context);
                if(!result){
                  ToastUtil.error('目标已失效');
                }
              }
          ),
          const TextSpan(text: '中点赞了您的评论', style: TextStyle(color: ThemeUtil.foregroundColor))
        ]
      ),
    );
  }
}

class NotificationCommentCommentedWidget extends StatefulWidget{
  
  final ImNotificationInteractCommentCommented notification;
  const NotificationCommentCommentedWidget(this.notification, {super.key});

  @override
  State<StatefulWidget> createState() {
    return NotificationCommentCommentedState();
  }
  
}

class CommentCommentedAfterUserLikeHandler implements AfterUserLikeHandler{

  NotificationCommentCommentedState state;
  CommentCommentedAfterUserLikeHandler(this.state);

  @override
  void handle(int id, ProductType type) {
    if(type == ProductType.productCommentSub && id == state.notification.linkedId){
      state.notification.isLiked = true;
      state.resetState();
      ChatNotificationStorage.updateCommentSubIsLiked(state.notification.id!, true);
    }
  }

}

class CommentCommentedAfterUserUnlikeHandler implements AfterUserUnlikeHandler{

  NotificationCommentCommentedState state;
  CommentCommentedAfterUserUnlikeHandler(this.state);

  @override
  void handle(int id, ProductType type) {
    if(type == ProductType.productCommentSub && id == state.notification.linkedId){
      state.notification.isLiked = false;
      state.resetState();
      ChatNotificationStorage.updateCommentSubIsLiked(state.notification.id!, false);
    }
  }

}

class NotificationCommentCommentedState extends State<NotificationCommentCommentedWidget>{

  static const double AVATAR_SIZE = 60;
  static const double ICON_LIKE_SIZE = 20;

  late ImNotificationInteractCommentCommented notification;

  late CommentCommentedAfterUserLikeHandler afterUserLikeHandler;
  late CommentCommentedAfterUserUnlikeHandler afterUserUnlikeHandler;

  @override
  void initState(){
    super.initState();
    notification = widget.notification;
    afterUserLikeHandler = CommentCommentedAfterUserLikeHandler(this);
    UserLikeUtil.addAfterUserLikeHandler(afterUserLikeHandler);
    afterUserUnlikeHandler = CommentCommentedAfterUserUnlikeHandler(this);
    UserLikeUtil.addAfterUserUnlikeHandler(afterUserUnlikeHandler);
  }

  @override
  void dispose(){
    UserLikeUtil.removeAfterUserLikeHandler(afterUserLikeHandler);
    UserLikeUtil.removeAfterUserUnlikeHandler(afterUserUnlikeHandler);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: AVATAR_SIZE,
                    height: AVATAR_SIZE,
                    child: notification.partnerHead == null ?
                    ThemeUtil.defaultUserHead :
                    Image.network(getFullUrl(notification.partnerHead!), fit: BoxFit.fill,)
                  ),
                ),
                const SizedBox(width: 10,),
                Expanded(
                  child: Text(notification.partnerName == null ? '' : StringUtil.getLimitedText(notification.partnerName!, DictionaryUtil.USERNAME_MAX_LENGTH), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
            Row(
              children: [
                const SizedBox(width: AVATAR_SIZE + 10,),
                Expanded(
                  child: getNameWidget()
                )
              ],
            ),
            const SizedBox(height: 10,),
            Row(
              children: [
                const SizedBox(width: AVATAR_SIZE + 10,),
                Expanded(
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      getUserContentWidget(),
                      const SizedBox(height: 6,),
                      getPartnerContentWidget()
                    ],
                  )
                )
              ],
            ),
            const SizedBox(height: 10,),
            Row(
              children: [
                const SizedBox(width: AVATAR_SIZE + 10,),
                Expanded(
                  child: getBehaviorWidget(),
                )
              ],
            ),
            const SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                notification.createTime == null ?
                const SizedBox() :
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(DateTimeUtil.getRelativeTime(notification.createTime!), style: const TextStyle(color: Colors.grey),),
                )
              ],
            )
          ],
        ),
      )
    );
  }

  Widget getBehaviorWidget(){
    return Wrap(
      children: [
        InkWell(
          onTap: (){
            showGeneralDialog(
              context: context, 
              barrierDismissible: true,
              barrierColor: Colors.transparent,
              barrierLabel: '',
              transitionBuilder: (context, animation, secondaryAnimation, child) {
                return Transform.scale(
                  scaleY: animation.value,
                  child: child,
                );
              },
              pageBuilder: (context, animation, secondaryAnimtaion){
                return NotificationCommentReplyWidget(
                  partnerHead: notification.partnerHead,
                  partnerName: notification.partnerName,
                  content: notification.partnerContent,
                  onReply: (val) async{
                    String content = val.trim();
                    if(content.isEmpty){
                      ToastUtil.warn('请输入内容');
                      return;
                    }
                    if(notification.linkedId == null || notification.commentId == null){
                      ToastUtil.error('数据错误');
                      return;
                    }
                    CommentSub commentSub = CommentSub();
                    commentSub.commentId = notification.commentId;
                    commentSub.replyId = notification.linkedId;
                    commentSub.content = content;
                    CommentSub? result = await CommentSubUtil().post(commentSub);
                    if(result != null){
                      ToastUtil.hint('评论成功');
                      Future.delayed(const Duration(seconds: 1), (){
                        if(mounted && context.mounted){
                          Navigator.of(context).pop();
                        }
                      });
                    }
                  }
                );
              }
            );
          },
          child: Container(
            decoration: const BoxDecoration(
              color: ThemeUtil.backgroundColor,
              borderRadius: BorderRadius.all(Radius.circular(12))
            ),
            clipBehavior: Clip.hardEdge,
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: const Text('回复评论~', style: TextStyle(fontSize: 14, color: ThemeUtil.foregroundColor),),
          ),
        ),
        const SizedBox(width: 10,),
        InkWell(
          onTap: () {
            if(notification.linkedId == null){
              return;
            }
            if(widget.notification.isLiked == true){
              UserLikeUtil.unlike(notification.linkedId!, ProductType.productCommentSub);
            }
            else{
              UserLikeUtil.like(notification.linkedId!, ProductType.productCommentSub);
            }
          },
          child: Container(
            decoration: const BoxDecoration(
              color: ThemeUtil.backgroundColor,
              borderRadius: BorderRadius.all(Radius.circular(12))
            ),
            clipBehavior: Clip.hardEdge,
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                widget.notification.isLiked == true ?
                SizedBox(
                  width: ICON_LIKE_SIZE,
                  height: ICON_LIKE_SIZE,
                  child: Image.asset('assets/comment/icon_comment_like_on.png', fit: BoxFit.fill)
                ) :
                SizedBox(
                  width: ICON_LIKE_SIZE,
                  height: ICON_LIKE_SIZE,
                  child: Image.asset('assets/comment/icon_comment_like.png', fit: BoxFit.fill,),
                ),
                const SizedBox(width: 6,),
                const Text('赞', style: TextStyle(fontSize: 14, color: ThemeUtil.foregroundColor),),
              ],
            )
          ),
        )
      ],
    );
  }

  Widget getPartnerContentWidget(){
    return RichText(
      text: TextSpan(
        text: '对方：${notification.partnerContent}',
        style: const TextStyle(color: ThemeUtil.foregroundColor)
      ),
    );
  }

  Widget getUserContentWidget(){
    return RichText(
      text: TextSpan(
        text: '我：${notification.userContent}',
        style: const TextStyle(color: ThemeUtil.foregroundColor)
      ),
    );
  }

  Widget getNameWidget(){
    if(notification.subType == null){
      return const SizedBox();
    }
    ProductType? type = ProductTypeExt.getType(notification.subType!);
    if(type == null){
      return const SizedBox();
    }
    String nameStr = notification.productName ?? '';
    switch(type){
      case ProductType.guide:
      case ProductType.hotel:
      case ProductType.video:
      case ProductType.restaurant:
      case ProductType.scenic:
      case ProductType.travel:
      case ProductType.circle:
        nameStr =  '《$nameStr》';
        break;
      default:
        nameStr = ': $nameStr';
    }
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: '在${LabelUtil.getProductName(type)}', style: const TextStyle(color: ThemeUtil.foregroundColor)),
          TextSpan(
            text: nameStr, 
            style: const TextStyle(color: Colors.lightBlue),
            recognizer: TapGestureRecognizer()
              ..onTap = () async{
                if(notification.productId == null){
                  ToastUtil.error('目标不存在');
                  return;
                }
                bool result = await ProductRedirector().redirect(productId: notification.productId!, type: type, context: context);
                if(!result){
                  ToastUtil.error('目标已失效');
                }
              }
          ),
          const TextSpan(text: '中回复了您的评论', style: TextStyle(color: ThemeUtil.foregroundColor))
        ]
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

class NotificationProductLikedMonumentWidget extends StatelessWidget{

  static const double AVATAR_SIZE = 50;

  final ImNotificationInteractProductLikedMonument notification;
  const NotificationProductLikedMonumentWidget(this.notification, {super.key});
  
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            children: getUserWidgets(context),
          ),
          const SizedBox(height: 10,),
          Row(
            children: [
              Expanded(
                child: getNameWidget(context),
              ),
              Text(DateTimeUtil.getRelativeTime(notification.createTime!), style: const TextStyle(color: Colors.grey),),
            ],
          ),
        ],
      ),
    );
  }

  Widget getNameWidget(BuildContext context){
    if(notification.subType == null){
      return const SizedBox();
    }
    ProductType? type = ProductTypeExt.getType(notification.subType!);
    if(type == null){
      return const SizedBox();
    }
    String nameStr = notification.productName ?? '';
    switch(type){
      case ProductType.guide:
      case ProductType.hotel:
      case ProductType.video:
      case ProductType.restaurant:
      case ProductType.scenic:
      case ProductType.travel:
      case ProductType.circle:
        nameStr =  '《$nameStr》';
        break;
      default:
        nameStr = ': $nameStr';
    }
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: '等${notification.count}人点赞了您的${LabelUtil.getProductName(type)}', style: const TextStyle(color: ThemeUtil.foregroundColor)),
          TextSpan(
            text: nameStr, 
            style: const TextStyle(color: Colors.lightBlue),
            recognizer: TapGestureRecognizer()
              ..onTap = () async{
                if(notification.productId == null){
                  ToastUtil.error('目标不存在');
                  return;
                }
                bool result = await ProductRedirector().redirect(productId: notification.productId!, type: type, context: context);
                if(!result){
                  ToastUtil.error('目标已失效');
                }
              }
          )
        ]
      ),
    );
  }

  List<Widget> getUserWidgets(BuildContext context){
    List<Widget> widgets = [];
    for(SimpleUser simpleUser in notification.users ?? []){
      widgets.add(
        Column(
          children: [
            ClipOval(
              child: SizedBox(
                width: AVATAR_SIZE,
                height: AVATAR_SIZE,
                child: simpleUser.head == null ?
                ThemeUtil.defaultUserHead :
                Image.network(getFullUrl(simpleUser.head!), fit: BoxFit.fill,)
              ),
            ),
            const SizedBox(height: 8,),
            Text(simpleUser.name ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 14),)
          ],
        )
      );
      widgets.add(
        const SizedBox(width: 10,)
      );
    }
    widgets.add(
      const Icon(Icons.more_horiz, color: ThemeUtil.foregroundColor,)
    );
    return widgets;
  }
}

class NotificationProductCommentedWidget extends StatefulWidget{

  final ImNotificationInteractProductCommented notification;
  const NotificationProductCommentedWidget(this.notification, {super.key});
  
  @override
  State<StatefulWidget> createState() {
    return NotificationProductCommentedState();
  }

}

class ProductCommentedAfterUserLikeHandler implements AfterUserLikeHandler{
  NotificationProductCommentedState state;
  ProductCommentedAfterUserLikeHandler(this.state);
  @override
  void handle(int id, ProductType type) {
    if(type == ProductType.productComment && id == state.notification.linkedId){
      state.notification.isLiked = true;
      state.resetState();
      ChatNotificationStorage.updateCommentIsLiked(state.notification.id!, true);
    }
  }
  
}

class ProductCommentedAfterUserUnlikeHandler implements AfterUserUnlikeHandler{
  NotificationProductCommentedState state;
  ProductCommentedAfterUserUnlikeHandler(this.state);
  @override
  void handle(int id, ProductType type) {
    if(type == ProductType.productComment && id == state.notification.linkedId){
      state.notification.isLiked = false;
      state.resetState();
      ChatNotificationStorage.updateCommentIsLiked(state.notification.id!, false);
    }
  }

}

class NotificationProductCommentedState extends State<NotificationProductCommentedWidget>{

  static const double AVATAR_SIZE = 60;
  static const double ICON_LIKE_SIZE = 20;
  late ImNotificationInteractProductCommented notification;

  late ProductCommentedAfterUserLikeHandler afterUserLikeHandler;
  late ProductCommentedAfterUserUnlikeHandler afterUserUnlikeHandler;

  @override
  void initState(){
    super.initState();
    notification = widget.notification;
    afterUserLikeHandler = ProductCommentedAfterUserLikeHandler(this);
    afterUserUnlikeHandler = ProductCommentedAfterUserUnlikeHandler(this);
    UserLikeUtil.addAfterUserLikeHandler(afterUserLikeHandler);
    UserLikeUtil.addAfterUserUnlikeHandler(afterUserUnlikeHandler);
  }

  @override
  void dispose(){
    UserLikeUtil.removeAfterUserLikeHandler(afterUserLikeHandler);
    UserLikeUtil.removeAfterUserUnlikeHandler(afterUserUnlikeHandler);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      ClipOval(
                        child: SizedBox(
                          width: AVATAR_SIZE,
                          height: AVATAR_SIZE,
                          child: notification.partnerHead == null ?
                          ThemeUtil.defaultUserHead :
                          Image.network(getFullUrl(notification.partnerHead!), fit: BoxFit.fill,)
                        ),
                      ),
                      const SizedBox(width: 10,),
                      Expanded(
                        child: Text(notification.partnerName == null ? '' : StringUtil.getLimitedText(notification.partnerName!, DictionaryUtil.USERNAME_MAX_LENGTH), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(width: AVATAR_SIZE + 10,),
                      Expanded(
                        child: getNameWidget()
                      )
                    ],
                  ),
                  const SizedBox(height: 10,),
                  Row(
                    children: [
                      const SizedBox(width: AVATAR_SIZE + 10,),
                      Expanded(
                        child: getContentWidget(),
                      )
                    ],
                  ),
                  const SizedBox(height: 10,),
                  Row(
                    children: [
                      const SizedBox(width: AVATAR_SIZE + 10,),
                      Expanded(
                        child: getBehaviorWidget(),
                      )
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(width: 10,),
            notification.createTime == null ?
            const SizedBox() :
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(DateTimeUtil.getRelativeTime(notification.createTime!), style: const TextStyle(color: Colors.grey),),
            )
          ],
        )
      ),
    );
  }

  Widget getBehaviorWidget(){
    return Wrap(
      children: [
        InkWell(
          onTap: (){
            showGeneralDialog(
              context: context, 
              barrierDismissible: true,
              barrierColor: Colors.transparent,
              barrierLabel: '',
              transitionBuilder: (context, animation, secondaryAnimation, child) {
                return Transform.scale(
                  scaleY: animation.value,
                  child: child,
                );
              },
              pageBuilder: (context, animation, secondaryAnimtaion){
                return NotificationCommentReplyWidget(
                  partnerHead: notification.partnerHead,
                  partnerName: notification.partnerName,
                  content: notification.innerContent,
                  onReply: (val) async{
                    String content = val.trim();
                    if(content.isEmpty){
                      ToastUtil.warn('请输入内容');
                      return;
                    }
                    if(notification.linkedId == null){
                      ToastUtil.error('数据错误');
                      return;
                    }
                    CommentSub commentSub = CommentSub();
                    commentSub.commentId = notification.linkedId;
                    commentSub.content = content;
                    CommentSub? result = await CommentSubUtil().post(commentSub);
                    if(result != null){
                      ToastUtil.hint('评论成功');
                      Future.delayed(const Duration(seconds: 1), (){
                        if(mounted && context.mounted){
                          Navigator.of(context).pop();
                        }
                      });
                    }
                  }
                );
              }
            );
          },
          child: Container(
            decoration: const BoxDecoration(
              color: ThemeUtil.backgroundColor,
              borderRadius: BorderRadius.all(Radius.circular(12))
            ),
            clipBehavior: Clip.hardEdge,
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: const Text('回复评论~', style: TextStyle(fontSize: 14, color: ThemeUtil.foregroundColor),),
          ),
        ),
        const SizedBox(width: 10,),
        InkWell(
          onTap: () {
            if(notification.linkedId == null){
              return;
            }
            if(widget.notification.isLiked == true){
              UserLikeUtil.unlike(notification.linkedId!, ProductType.productComment);
            }
            else{
              UserLikeUtil.like(notification.linkedId!, ProductType.productComment);
            }
          },
          child: Container(
            decoration: const BoxDecoration(
              color: ThemeUtil.backgroundColor,
              borderRadius: BorderRadius.all(Radius.circular(12))
            ),
            clipBehavior: Clip.hardEdge,
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                widget.notification.isLiked == true ?
                SizedBox(
                  width: ICON_LIKE_SIZE,
                  height: ICON_LIKE_SIZE,
                  child: Image.asset('assets/comment/icon_comment_like_on.png', fit: BoxFit.fill)
                ) :
                SizedBox(
                  width: ICON_LIKE_SIZE,
                  height: ICON_LIKE_SIZE,
                  child: Image.asset('assets/comment/icon_comment_like.png', fit: BoxFit.fill,),
                ),
                const SizedBox(width: 6,),
                const Text('赞', style: TextStyle(fontSize: 14, color: ThemeUtil.foregroundColor),),
              ],
            )
          ),
        )
      ],
    );
  }

  Widget getContentWidget(){
    return RichText(
      text: TextSpan(
        text: '评论：${notification.innerContent ?? ''}',
        style: const TextStyle(color: ThemeUtil.foregroundColor)
      ),
    );
  }

  Widget getNameWidget(){
    if(notification.subType == null){
      return const SizedBox();
    }
    ProductType? type = ProductTypeExt.getType(notification.subType!);
    if(type == null){
      return const SizedBox();
    }
    String nameStr = notification.productName ?? '';
    switch(type){
      case ProductType.guide:
      case ProductType.hotel:
      case ProductType.video:
      case ProductType.restaurant:
      case ProductType.scenic:
      case ProductType.travel:
      case ProductType.circle:
        nameStr =  '《$nameStr》';
        break;
      default:
        nameStr = ': $nameStr';
    }
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: '评论了您的${LabelUtil.getProductName(type)}', style: const TextStyle(color: ThemeUtil.foregroundColor)),
          TextSpan(
            text: nameStr, 
            style: const TextStyle(color: Colors.lightBlue),
            recognizer: TapGestureRecognizer()
              ..onTap = () async{
                if(notification.productId == null){
                  ToastUtil.error('目标不存在');
                  return;
                }
                bool result = await ProductRedirector().redirect(productId: notification.productId!, type: type, context: context);
                if(!result){
                  ToastUtil.error('目标已失效');
                }
              }
          )
        ]
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

class NotificationProductLikedWidget extends StatelessWidget{

  static const double AVATAR_SIZE = 60;

  final ImNotificationInteractProductLiked notification;
  const NotificationProductLikedWidget(this.notification, {super.key});
  
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    ClipOval(
                      child: SizedBox(
                        width: AVATAR_SIZE,
                        height: AVATAR_SIZE,
                        child: notification.partnerHead == null ?
                        ThemeUtil.defaultUserHead :
                        Image.network(getFullUrl(notification.partnerHead!), fit: BoxFit.fill,)
                      ),
                    ),
                    const SizedBox(width: 10,),
                    Expanded(
                      child: Text(notification.partnerName == null ? '' : StringUtil.getLimitedText(notification.partnerName!, DictionaryUtil.USERNAME_MAX_LENGTH), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(width: AVATAR_SIZE + 10,),
                    Expanded(
                      child: getShowTextWidget(context)
                    )
                  ],
                )
              ],
            ),
          ),
          const SizedBox(width: 10,),
          notification.createTime == null ?
          const SizedBox() :
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(DateTimeUtil.getRelativeTime(notification.createTime!), style: const TextStyle(color: Colors.grey),),
          )
        ],
      ),
    );
  }

  Widget getShowTextWidget(BuildContext context){
    if(notification.subType == null){
      return const SizedBox();
    }
    ProductType? type = ProductTypeExt.getType(notification.subType!);
    if(type == null){
      return const SizedBox();
    }
    String nameStr = notification.productName ?? '';
    switch(type){
      case ProductType.guide:
      case ProductType.hotel:
      case ProductType.video:
      case ProductType.restaurant:
      case ProductType.scenic:
      case ProductType.travel:
      case ProductType.circle:
        nameStr =  '《$nameStr》';
        break;
      default:
        nameStr = ': $nameStr';
    }
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: '点赞了您的${LabelUtil.getProductName(type)}', style: const TextStyle(color: ThemeUtil.foregroundColor)),
          TextSpan(
            text: nameStr, 
            style: const TextStyle(color: Colors.lightBlue),
            recognizer: TapGestureRecognizer()
              ..onTap = () async{
                if(notification.productId == null){
                  ToastUtil.error('目标不存在');
                  return;
                }
                bool result = await ProductRedirector().redirect(productId: notification.productId!, type: type, context: context);
                if(!result){
                  ToastUtil.error('目标已失效');
                }
              }
          )
        ]
      ),
    );
  }
}


class NotificationCircleActivityAppliedWidget extends StatefulWidget{
  final ImNotificationInteractCircleActivityApplied notification;

  const NotificationCircleActivityAppliedWidget(this.notification, {super.key});
  
  @override
  State<StatefulWidget> createState() {
    return NotificationCircleActivityAppliedState();
  }
}

class NotificationCircleActivityAppliedState extends State<NotificationCircleActivityAppliedWidget>{

  static const double AVATAR_SIZE = 60;
  static const double BUTTON_WIDTH = 100;
  static const double BUTTON_HEIGHT = 34;

  @override
  Widget build(BuildContext context) {
    ImNotificationInteractCircleActivityApplied notification = widget.notification;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipOval(
                      child: SizedBox(
                        width: AVATAR_SIZE,
                        height: AVATAR_SIZE,
                        child: notification.applierHead == null ?
                        ThemeUtil.defaultUserHead :
                        Image.network(getFullUrl(notification.applierHead!), fit: BoxFit.fill,)
                      ),
                    ),
                    const SizedBox(width: 10,),
                    Expanded(
                      child: Text(notification.applierName == null ? '' : StringUtil.getLimitedText(notification.applierName!, DictionaryUtil.USERNAME_MAX_LENGTH), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),)
                    )
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(width: AVATAR_SIZE + 10,),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: '申请加入圈子',
                              style: TextStyle(color: ThemeUtil.foregroundColor)
                            ),
                            TextSpan(
                              text: notification.circleName,
                              style: const TextStyle(color: Colors.lightBlue),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async{
                                  if(notification.circleId == null){
                                    return;
                                  }
                                  CircleActivity? vo = await CircleHttp().getCircleActivity(id: notification.circleId!);
                                  if(vo == null){
                                    return;
                                  }
                                  if(mounted && context.mounted){
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                      return CircleActivityPage(vo);
                                    }));
                                  }
                                }
                            )
                          ]
                        ),
                      )
                    )
                  ],
                ),
                const SizedBox(height: 10,),
                Row(
                  children: [
                    const SizedBox(width: AVATAR_SIZE + 10,),
                    Expanded(
                      child: Text('备注信息：${notification.remark ?? ''}', style: const TextStyle(color: Colors.grey),),
                    )
                  ],
                ),
                const SizedBox(height: 10,),
                getStatusWidget(),
                const SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    notification.createTime == null ?
                    const SizedBox() :
                    Text(DateTimeUtil.getRelativeTime(notification.createTime!,), style: const TextStyle(color: Colors.grey)),
                  ],
                )
              ],
            ),
          ),
          
        ],
      )
    );
  }

  Widget getStatusWidget(){
    ImNotificationInteractCircleActivityApplied notification = widget.notification;
    CircleActivityApplyStatus? status;
    if(notification.applyStatus != null){
      status = CircleActivityApplyStatusExt.getStatus(notification.applyStatus!);
    }
    if(status == CircleActivityApplyStatus.waiting){
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: Colors.black
              ),
              onPressed: (){
                setApplyStatus(CircleActivityApplyStatus.rejected);
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(255, 20, 20, 0.6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 4)
                    )
                  ]
                ),
                width: BUTTON_WIDTH,
                height: BUTTON_HEIGHT,
                alignment: Alignment.center,
                child: const Text('拒 绝', style: TextStyle(color: Colors.white),),
              ),
            ),
          ),
          const SizedBox(width: 20,),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: Colors.black
              ),
              onPressed: (){
                setApplyStatus(CircleActivityApplyStatus.success);
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(3, 169, 244, 0.6), 
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 4)
                    )
                  ]
                ),
                width: BUTTON_WIDTH,
                height: BUTTON_HEIGHT,
                alignment: Alignment.center,
                child: const Text('同 意', style: TextStyle(color: Colors.white),),
              ),
            ),
          ),
        ],
      );
    }
    else if(status == CircleActivityApplyStatus.rejected){
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: const [
          SizedBox(
            width: BUTTON_WIDTH,
            height: BUTTON_HEIGHT,
            child: Align(
              alignment: Alignment.center,
              child: Text('已拒绝', style: TextStyle(color: Colors.grey, fontSize: 16),),
            ),
          )
        ],
      );
    }
    else if(status == CircleActivityApplyStatus.success){
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: Colors.black
              ),
              onPressed: () async{
                ImNotificationInteractCircleActivityApplied notification = widget.notification;
                if(notification.applierId == null){
                  ToastUtil.error('数据错误');
                  return;
                }
                ImSingleRoom? room = await ChatUtilSingle.enterRoom(notification.applierId!);
                if(room == null){
                  ToastUtil.error('进入聊天失败');
                  return;
                }
                if(mounted && context.mounted){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context){
                    return ChatRoomPage(room: room);
                  }));
                }
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white, 
                  border: Border.fromBorderSide(BorderSide(color: Color.fromRGBO(3, 169, 244, 0.6))),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 4)
                    )
                  ]
                ),
                width: BUTTON_WIDTH,
                height: BUTTON_HEIGHT,
                alignment: Alignment.center,
                child: const Text('聊 天', style: TextStyle(color: Color.fromRGBO(3, 169, 244, 0.6)),),
              ),
            ),
          ),
        ],
      );
    }
    return const SizedBox();
  }

  Future setApplyStatus(CircleActivityApplyStatus status) async{
    ImNotificationInteractCircleActivityApplied notification = widget.notification;
    if(notification.id == null || notification.linkedId == null){
      return;
    }
    bool result = await CircleActivityApplyHttp().setStatus(applyId: notification.linkedId!, status: status, fail: (response){
      int? code = response.data['code'];
      if(code == ResultCode.RES_CREATED){
        ToastUtil.hint('已加入');
        return;
      }
      ToastUtil.error('操作失败');
    });
    if(result){
      notification.applyStatus = status.getNum();
      ChatNotificationStorage.updateCircleActivityApplyStatus(notification.id!, status,);
      if(mounted && context.mounted){
        setState(() {
        });
      }
    }
  }
}

class NotificationFriendApplyWidget extends StatefulWidget{
  final ImNotificationInteractFriendApply notification;
  const NotificationFriendApplyWidget(this.notification, {super.key});

  @override
  State<StatefulWidget> createState() {
    return NotificationFriendApplyState();
  }

}

class NotificationFriendApplyState extends State<NotificationFriendApplyWidget>{

  static const double AVATAR_SIZE = 60;
  static const double BUTTON_WIDTH = 100;
  static const double BUTTON_HEIGHT = 34;

  @override
  Widget build(BuildContext context) {
    ImNotificationInteractFriendApply notification = widget.notification;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    ClipOval(
                      child: SizedBox(
                        width: AVATAR_SIZE,
                        height: AVATAR_SIZE,
                        child: notification.partnerHead == null ?
                        ThemeUtil.defaultUserHead :
                        Image.network(getFullUrl(notification.partnerHead!), fit: BoxFit.fill,)
                      ),
                    ),
                    const SizedBox(width: 10,),
                    Expanded(
                      child: Text(notification.partnerName == null ? '' : StringUtil.getLimitedText(notification.partnerName!, DictionaryUtil.USERNAME_MAX_LENGTH), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),)
                    )
                  ],
                ),
                Row(
                  children: const [
                    SizedBox(width: AVATAR_SIZE + 10,),
                    Expanded(
                      child: Text('申请添加您为好友', style: TextStyle(color: Colors.grey),),
                    )
                  ],
                ),
                const SizedBox(height: 10,),
                Row(
                  children: [
                    const SizedBox(width: AVATAR_SIZE + 10,),
                    Expanded(
                      child: Text('备注信息：${notification.description ?? ''}', style: const TextStyle(color: Colors.grey),),
                    )
                  ],
                ),
                const SizedBox(height: 10,)
              ],
            ),
          ),
          getStatusWidget()
        ],
      ),
    );
  }

  Widget getStatusWidget(){
    ImNotificationInteractFriendApply notification = widget.notification;
    if(notification.status == null){
      return const SizedBox();
    }
    UserFriendApplyStatus? status = UserFriendApplyStatusExt.getType(notification.status!);
    switch(status){
      case UserFriendApplyStatus.waiting:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: Colors.black
                ),
                onPressed: (){
                  setFriendApplyStatus(UserFriendApplyStatus.success);
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(3, 169, 244, 0.6), 
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 4)
                      )
                    ]
                  ),
                  width: BUTTON_WIDTH,
                  height: BUTTON_HEIGHT,
                  alignment: Alignment.center,
                  child: const Text('同意', style: TextStyle(color: Colors.white),),
                ),
              ),
            ),
            const SizedBox(height: 20,),
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: Colors.black
                ),
                onPressed: (){
                  setFriendApplyStatus(UserFriendApplyStatus.rejected);
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(255, 20, 20, 0.6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 4)
                      )
                    ]
                  ),
                  width: BUTTON_WIDTH,
                  height: BUTTON_HEIGHT,
                  alignment: Alignment.center,
                  child: const Text('拒绝', style: TextStyle(color: Colors.white),),
                ),
              ),
            )
          ],
        );
      case UserFriendApplyStatus.success:
        return const SizedBox(
          width: BUTTON_WIDTH,
          height: BUTTON_HEIGHT,
          child: Align(
            alignment: Alignment.center,
            child: Text('已同意', style: TextStyle(color: Color.fromRGBO(3, 169, 244, 1), fontSize: 16),),
          ),
        );
      case UserFriendApplyStatus.rejected:
        return const SizedBox(
          width: BUTTON_WIDTH,
          height: BUTTON_HEIGHT,
          child: Align(
            alignment: Alignment.center,
            child: Text('已拒绝', style: TextStyle(color: Colors.grey, fontSize: 16),),
          ),
        );
      default:
        return const SizedBox();
    }
  }

  Future setFriendApplyStatus(UserFriendApplyStatus status) async{
    ImNotificationInteractFriendApply notification = widget.notification;
    if(notification.linkedId == null){
      ToastUtil.error('参数错误');
      return;
    }
    FriendHttp.friendReply(notification.linkedId!, status, success: (response){
      if(notification.id != null){
        ChatNotificationStorage.updateImNotificationInteractFriendApplyStatus(notification.id!, status);
      }
      ToastUtil.hint('操作成功');
      notification.status = status.getNum();
      if(context.mounted){
        setState(() {
        });
      }
    }, fail: (response){
      int? code = response.data['code'];
      switch(code){
        case ResultCode.RES_WRONG_PARAM:
          ToastUtil.error('参数错误');
          return;
        case ResultCode.RES_NOT_FOUND:
          ToastUtil.error('目标不存在');
          return;
        case ResultCode.RES_NOT_AUTHED:
          ToastUtil.error('权限不足');
          return;
        case ResultCode.RES_CREATED:
          ToastUtil.error('请求已处理');
          return;
        default:
      }
    });
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
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.fromLTRB(0, MARGIN_TOP, 0, MARGIN_BOTTOM),
      padding: const EdgeInsets.all(PADDING),
      child: content,
    );
  }

}
