
import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/chat_group/group_meta.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/local_storage/model/local_group.dart';
import 'package:freego_flutter/local_storage/model/local_group_room.dart';
import 'package:freego_flutter/local_storage/util/local_group_util.dart';
import 'package:freego_flutter/util/theme_util.dart';

import 'package:flutter/foundation.dart' as foundation;
import 'dart:ui' as ui;

import 'package:freego_flutter/util/toast_util.dart';

class GroupRoomPage extends StatelessWidget{
  final LocalGroupRoomVo room;
  const GroupRoomPage({required this.room, super.key});

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
      body: GroupRoomWidget(room: room),
    );
  }
  
}

class GroupRoomWidget extends StatefulWidget{
  final LocalGroupRoomVo room;
  const GroupRoomWidget({required this.room, super.key});

  @override
  State<StatefulWidget> createState() {
    return GroupRoomState();
  }
  
}

class GroupRoomState extends State<GroupRoomWidget>{

  TextEditingController textController = TextEditingController();
  TextInputFocusNode textFocus = TextInputFocusNode();

  final KeyboardController _keyboardController = KeyboardController();

  @override
  void dispose(){
    textController.dispose();
    textFocus.dispose();
    _keyboardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Stack(
        children: [
          Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonHeader(
                  center: Text(widget.room.getShowName(), overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 18),),
                  right: InkWell(
                    onTap: () async{
                      if(widget.room.groupId == null){
                        return;
                      }
                      LocalGroup? group = await LocalGroupUtil().get(widget.room.groupId!);
                      if(group == null){
                        return;
                      }
                      if(mounted && context.mounted){
                        Navigator.of(context).push(MaterialPageRoute(builder: (context){
                          return GroupMetaPage(group: group, room: widget.room);
                        }));
                      }
                    },
                    child: const Icon(Icons.more_vert_rounded, color: Colors.white,),
                  ),
                ),
                Expanded(
                  child: getMessageWidget(),
                ),
                MultiKeyboardWidget(
                  textController: textController,
                  textFocus: textFocus,
                  controller: _keyboardController,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
  
  Widget getMessageWidget(){
    return ListView(

    );
  }
}

enum KeyboardAction{
  hide
}

class KeyboardController extends ChangeNotifier {
  KeyboardAction? _action;
  void hide(){
    _action = KeyboardAction.hide;
    notifyListeners();
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

class MultiKeyboardWidget extends StatefulWidget{
  final TextEditingController? textController;
  final TextInputFocusNode? textFocus;
  final KeyboardListener? listener;
  final KeyboardController? controller;
  const MultiKeyboardWidget({this.listener, this.textController, this.textFocus, this.controller, super.key});

  @override
  State<StatefulWidget> createState() {
    return MultiKeyboardState();
  }
  
}

class MultiKeyboardState extends State<MultiKeyboardWidget> with TickerProviderStateMixin, WidgetsBindingObserver{

  static const double EMOJI_LIST_HEIGHT = 220;
  static const double EXT_LIST_HEIGHT = 140;

  static const int ANIM_MILLI_SECONDS = 175;
  static const double EXT_ICON_SIZE = 60;

  final double _iconWidth = 40;
  late TextEditingController _contentController;
  late TextInputFocusNode _focusNode;

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
    if(widget.controller != null){
      widget.controller!.addListener((){
        KeyboardAction? _action = widget.controller!._action;
        switch(_action){
          case KeyboardAction.hide:
            handleHide();
            break;
          default:
        }
      });
    }
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

  void handleHide(){
    if(_isShowEmoji){
      hideEmoji();
    }
    if(_isShowExt){
      hideExt();
    }
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
          getTextInputWidget(),
          Stack(
            children: [
              getEmojiWidget(),
              getExtWidget(),
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

  Widget getTextInputWidget(){
    return Container(
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
    );
  }

  Widget getExtWidget(){
    return SizeTransition(
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
    );
  }
  
  Widget getEmojiWidget(){
    return SizeTransition(
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
    );
  }

  void showKeyboard(){
    FocusScope.of(context).unfocus();
    if(Platform.isAndroid){
      SystemChannels.textInput.invokeMethod('TextInput.show');
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

  double getKeyboardHeight(){
    return EdgeInsets.fromWindowPadding(
      WidgetsBinding.instance.window.viewInsets, 
      WidgetsBinding.instance.window.devicePixelRatio).bottom;
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

extension _LocalGroupRoomVoExt on LocalGroupRoomVo{
  String getShowName(){
    if(groupRemark != null && groupRemark != ''){
      return groupRemark!;
    }
    if(groupName != null){
      return groupName!;
    }
    return '';
  }
}