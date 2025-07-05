
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:freego_flutter/components/view/simple_input.dart';

class CustomEmojiPicKerController{
  late CustomEmojiPickerState _state;
  CustomEmojiPicKerController();
  Future showEmoji() async{
    return await _state.showEmoji();
  }
  Future hideEmoji() async{
    return await _state.hideEmoji();
  }
}

class CustomEmojiPickerWidget extends StatefulWidget{
  final TextEditingController textController;
  final CustomEmojiPicKerController? outerController;
  const CustomEmojiPickerWidget({required this.textController, this.outerController, super.key});

  @override
  State<StatefulWidget> createState() {
    return CustomEmojiPickerState();
  }


}

class CustomEmojiPickerState extends State<CustomEmojiPickerWidget> with SingleTickerProviderStateMixin{

  late AnimationController _animController;

  @override
  void initState(){
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    widget.outerController?._state = this;
  }

  @override
  void dispose(){
    _animController.dispose();
    super.dispose();
  }

  Future showEmoji() async{
    return await _animController.forward();
  }

  Future hideEmoji() async{
    return await _animController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _animController,
      axisAlignment: -1,
      child: Container(
        alignment: Alignment.topCenter,
        width: double.infinity,
        height: SimpleInputState.EMOJI_LIST_HEIGHT,
        decoration: const BoxDecoration(
          color: Color.fromRGBO(243, 243, 243, 1)
        ),
        child: EmojiPicker(
          textEditingController: widget.textController,
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
        ),
      ),
    );
  }

}
