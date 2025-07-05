
import 'dart:ui' as ui;

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/services.dart';
import 'package:freego_flutter/util/toast_util.dart';

class SimpleInputWidget extends StatefulWidget{
  final String hintText;
  final TextEditingController? textController;
  final FocusNode? focusNode;
  final Function(String)? onChange;
  final Future<bool> Function(String)? onSubmit;
  final Color? backgroundColor;

  const SimpleInputWidget({required this.hintText, required this.onSubmit, this.textController, this.focusNode, this.onChange, this.backgroundColor, super.key});

  @override
  State<StatefulWidget> createState() {
    return SimpleInputState();
  }

}

class SimpleInputState extends State<SimpleInputWidget> with TickerProviderStateMixin, WidgetsBindingObserver{

  static const double INPUT_HEIGHT = 44;
  static const double EMOJI_LIST_HEIGHT = 220;
  static const int EMOJI_ANIM_MILLI_SECONDS = 200;

  late TextEditingController _textController;
  late FocusNode _focusNode;

  late AnimationController _emojiController;
  bool _isShowEmoji = false;

  late AnimationController _keyboardAnim;
  SpecialTextSpanBuilder specialTextSpanBuilder = SimpleInputSpecialTextBuilder();

  @override
  void initState(){
    super.initState();
    _textController = widget.textController ?? TextEditingController();
    _focusNode = widget.focusNode ?? TextInputFocusNode();
    _emojiController = AnimationController(vsync: this, duration: const Duration(milliseconds: EMOJI_ANIM_MILLI_SECONDS));
    _keyboardAnim = AnimationController(vsync: this, lowerBound: 0, upperBound: double.infinity);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose(){
    if(widget.textController == null){
      _textController.dispose();
    }
    if(widget.focusNode == null){
      _focusNode.dispose();
    }
    _emojiController.dispose();
    _keyboardAnim.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics(){
    super.didChangeMetrics();
    double keyboardHeight = EdgeInsets.fromWindowPadding(
      WidgetsBinding.instance.window.viewInsets, 
      WidgetsBinding.instance.window.devicePixelRatio).bottom;
    _keyboardAnim.value = keyboardHeight;
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async{
        if(_isShowEmoji){
          _emojiController.reverse().then((value){
            _isShowEmoji = false;
          });
          return false;
        }
        return true;
      },
      child: Container(
        width: double.infinity,
        alignment: Alignment.centerLeft,
        color: widget.backgroundColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: const BoxDecoration(
                color:Color.fromRGBO(243, 243, 243, 1)
              ),
              clipBehavior: Clip.hardEdge,
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: INPUT_HEIGHT,
                      child: Listener(
                        onPointerDown: (evt){
                          double keyboardHeight = EdgeInsets.fromWindowPadding(
                            WidgetsBinding.instance.window.viewInsets, 
                            WidgetsBinding.instance.window.devicePixelRatio).bottom;
                          if(keyboardHeight > 0){
                            return;
                          }
                          _isShowEmoji = false;
                          _emojiController.reverse();
                          _focusNode.unfocus();
                          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                            FocusScope.of(context).requestFocus(_focusNode);
                            SystemChannels.textInput.invokeMethod('TextInput.show');
                          });
                          setState(() {
                          });
                        },
                        child: ExtendedTextField(
                          specialTextSpanBuilder: specialTextSpanBuilder,
                          maxLines: 9999,
                          minLines: 1,
                          controller: _textController,
                          focusNode: _focusNode,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.send,
                          decoration: InputDecoration(
                            hintText: widget.hintText,
                            hintStyle: const TextStyle(color: Colors.grey),
                            isDense: true,
                            contentPadding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
                            border: InputBorder.none,
                          ),
                          onChanged: widget.onChange,
                          onSubmitted: (val) async{
                            if(widget.onSubmit == null){
                              return;
                            }
                            if(val.trim().isEmpty){
                              ToastUtil.warn('请输入内容');
                              FocusScope.of(context).requestFocus(_focusNode);
                              return;
                            }
                            bool result = await widget.onSubmit!(val);
                            if(result){
                              _textController.clear();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: (){
                      if(!_isShowEmoji){
                        _isShowEmoji = true;
                        double keyboardHeight = EdgeInsets.fromWindowPadding(
                          WidgetsBinding.instance.window.viewInsets, 
                          WidgetsBinding.instance.window.devicePixelRatio).bottom;
                        if(keyboardHeight > 0){
                          _emojiController.value  = keyboardHeight / EMOJI_LIST_HEIGHT;
                          SystemChannels.textInput.invokeMethod('TextInput.hide');
                        }
                        _emojiController.forward(from: 0.0);
                        setState(() {
                        });
                        FocusScope.of(context).requestFocus(_focusNode);
                      }
                      else{
                        _isShowEmoji = false;
                        _focusNode.unfocus();
                        _emojiController.reverse();
                      }
                    }, 
                    icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.grey, size: 30)
                  ),
                ],
              ),
            ),
            Stack(
              children: [
                SizeTransition(
                  sizeFactor: _emojiController,
                  axisAlignment: -1.0,
                  child: Container(
                    alignment: Alignment.topCenter,
                    width: double.infinity,
                    height: EMOJI_LIST_HEIGHT,
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(243, 243, 243, 1)
                    ),
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                        columns: 7,
                        emojiSizeMax: 32 * (foundation.defaultTargetPlatform == TargetPlatform.iOS ? 1.30 : 1.0), // Issue: https://github.com/flutter/flutter/issues/28894
                        verticalSpacing: 0,
                        horizontalSpacing: 0,
                        gridPadding: EdgeInsets.zero,
                        initCategory: Category.RECENT,
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
                    )
                  )
                ),
                AnimatedBuilder(
                  animation: _keyboardAnim, 
                  builder: (context, child){
                    return SizedBox(
                      height: _keyboardAnim.value,
                    );
                  }
                )
              ],
            )
          ],
        ),
      ),
    );
  }
  
}

class SimpleInputSpecialTextBuilder extends SpecialTextSpanBuilder{
  @override
  SpecialText? createSpecialText(String flag, {TextStyle? textStyle, SpecialTextGestureTapCallback? onTap, required int index}) {
    if(flag.trim().isEmpty){
      return null;
    }
    if(isStart(flag, UserRefererText.startTag)){
      return UserRefererText(
        index - (UserRefererText.startTag.length - 1), 
        textStyle
      );
    }
    return null;
  }

}

class UserRefererText extends SpecialText{
  static const String startTag = '回复 @';
  static const String endTag = '：';
  
  int start;

  UserRefererText(this.start, TextStyle? textStyle): super(startTag, endTag, textStyle);

  @override
  InlineSpan finishText() {
    final String text = toString();

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
              TextSpan(text: text)
            ]
          )
        )
      )
    );
  }

}
