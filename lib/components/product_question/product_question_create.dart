
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/components/product_question/product_question_common.dart';
import 'package:freego_flutter/components/product_question/product_question_util.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/custom_emoji_picker.dart';
import 'package:freego_flutter/components/view/image_input.dart';
import 'package:freego_flutter/components/view/simple_input.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';

class ProductQuestionCreatePage extends StatelessWidget{
  final int productId;
  final ProductType type;
  final String? title;
  const ProductQuestionCreatePage({required this.productId, required this.type, this.title, super.key});

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
      body: ProductQuestionCreateWidget(productId: productId, type: type, title: title,),
    );
  }
  
}

class ProductQuestionCreateWidget extends StatefulWidget{
  final int productId;
  final ProductType type;
  final String? title;
  const ProductQuestionCreateWidget({required this.productId, required this.type, this.title, super.key});

  @override
  State<StatefulWidget> createState() {
    return ProductQuestionCreateState();
  }

}

class ProductQuestionCreateState extends State<ProductQuestionCreateWidget> with SingleTickerProviderStateMixin, WidgetsBindingObserver{

  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  CustomEmojiPicKerController emojiPicKerController = CustomEmojiPicKerController();
  FocusNode contentFocus = FocusNode();
  bool isShowKeyboard = true;
  List<String>? picList;
  List<String>? tagList;

  Widget svgTags = SvgPicture.asset('svg/question/tags.svg');
  Widget svgAnonymous = SvgPicture.asset('svg/question/anonymous.svg');
  static const double SVG_ICON_SIZE = 40;
  bool isAnonymous = false;

  static const int BOTTOM_ANIM_MILLI_SECONDS = 200;
  late AnimationController bottomAnim;
  bool isShowEmojiPicker = false;
  bool onSubmit = false;

  @override
  void dispose(){
    titleController.dispose();
    contentController.dispose();
    contentFocus.dispose();
    bottomAnim.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    bottomAnim = AnimationController(vsync: this, lowerBound: 0, upperBound: double.infinity, duration: const Duration(milliseconds: BOTTOM_ANIM_MILLI_SECONDS));
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    Widget inner = Container(
      color: ThemeUtil.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonHeader(
            center: Text(widget.title ?? '提问', style: const TextStyle(color: Colors.white, fontSize: 18),),
          ),
          Expanded(
            child: Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                  physics: const ClampingScrollPhysics(),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(6))
                            ),
                            height: 60,
                            alignment: Alignment.center,
                            child: TextField(
                              controller: titleController,
                              decoration: const InputDecoration(
                                hintText: '你想问什么？',
                                hintStyle: TextStyle(color: Color.fromRGBO(0xc5, 0xc5, 0xc6, 1)),
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                border: InputBorder.none,
                                counterText: '',
                              ),
                              textAlign: TextAlign.center,
                              maxLength: 100,
                              maxLines: 1,
                              cursorColor: Colors.grey,
                            ),
                          ),
                          const Divider(),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                            child: Row(
                              children: [
                                Container(
                                  height: 60,
                                  alignment: Alignment.centerLeft,
                                  child: const Text('内容', style: TextStyle(color: Color.fromRGBO(0xc5, 0xc5, 0xc5, 1), fontSize: 18),),
                                ),
                                const Expanded(child: SizedBox()),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap
                                  ),
                                  onPressed: () async{
                                    if(isShowEmojiPicker){
                                      await hideEmoji();
                                    }
                                    else{
                                      await showEmoji();
                                    }
                                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                                      FocusScope.of(context).requestFocus(contentFocus);
                                    });
                                  },
                                  child: const Icon(Icons.emoji_emotions_outlined, size: 34, color: Colors.grey,),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 180,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6)
                            ),
                            child: Listener(
                              onPointerDown: (evt){
                                if(isShowEmojiPicker){
                                  isShowKeyboard = true;
                                  contentFocus.unfocus();
                                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                                    FocusScope.of(context).requestFocus(contentFocus);
                                  });
                                  hideEmoji();
                                  SystemChannels.textInput.invokeMethod('TextInput.show');
                                }
                              },
                              child: TextField(
                                controller: contentController,
                                focusNode: contentFocus,
                                keyboardType: isShowKeyboard ? TextInputType.multiline : TextInputType.none,
                                decoration: const InputDecoration(
                                  hintText: '        能具体地描述一下吗？',
                                  hintStyle: TextStyle(color: Color.fromRGBO(0xc5, 0xc5, 0xc6, 1)),
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none,
                                ),
                                minLines: 1,
                                maxLines: 9999,
                              ),
                            ),
                          ),
                          const Divider(height: 40,),
                          ImageInputWidget(
                            onChange: (picList){
                              this.picList = picList;
                            },
                          ),
                          const Divider(height: 40,),
                          SizedBox(
                            height: SVG_ICON_SIZE,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: SVG_ICON_SIZE,
                                      height: SVG_ICON_SIZE,
                                      child: svgTags,
                                    ),
                                    const SizedBox(width: 10,),
                                    const Text('兴趣标签', style: TextStyle(color: Colors.grey, fontSize: 16),),
                                  ],
                                ),
                                const Expanded(
                                  child: SizedBox(),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: getTags(),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: SVG_ICON_SIZE,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: SVG_ICON_SIZE,
                                      height: SVG_ICON_SIZE,
                                      child: svgAnonymous,
                                    ),
                                    const SizedBox(width: 10,),
                                    const Text('匿名提问', style: TextStyle(color: Colors.grey, fontSize: 16),)
                                  ],
                                ),
                                const SizedBox(width: 20,),
                                const Expanded(child: SizedBox()),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: AnonymousSwitch(
                                    initState: isAnonymous,
                                    onChange: (val){
                                      isAnonymous = val;
                                    },
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: submit,
                          child: Container(
                            margin: const EdgeInsets.only(top: 12),
                            decoration: const BoxDecoration(
                              color: ThemeUtil.buttonColor,
                              borderRadius: BorderRadius.horizontal(left: Radius.circular(40))
                            ),
                            width: 104,
                            height: 56,
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.post_add_outlined, color: Colors.white,),
                                Text('发 表', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),)
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    AnimatedBuilder(
                      animation: bottomAnim,
                      builder: (context, child) {
                        return SizedBox(
                          height: bottomAnim.value,
                        );
                      },
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: CustomEmojiPickerWidget(
                    textController: contentController,
                    outerController: emojiPicKerController,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
    return WillPopScope(
      onWillPop: () async{
        if(isShowEmojiPicker){
          await hideEmoji();
          return false;
        }
        else{
          Navigator.of(context).pop(true);
          return true;
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          FocusScope.of(context).unfocus();
          hideEmoji();
        },
        child: inner,
      ),
    );
  }

  Future submit() async{
    String title = titleController.text.trim();
    if(title.isEmpty){
      ToastUtil.warn('请填写标题');
      return;
    }
    String content = contentController.text.trim();
    if(content.isEmpty){
      ToastUtil.warn('请填写提问内容');
      return;
    }
    if(onSubmit){
      return;
    }
    onSubmit = true;
    ProductQuestion question = ProductQuestion();
    question.productId = widget.productId;
    question.productType = widget.type.getNum();
    question.title = title;
    question.content = content;
    if(picList != null && picList!.isNotEmpty){
      question.pics = picList!.join(',');
    }
    if(tagList != null && tagList!.isNotEmpty){
      question.tags = tagList!.join(',');
    }
    question.isAnonymous = isAnonymous;
    ProductQuestion? result = await ProductQuestionUtil().post(question);
    if(result == null){
      ToastUtil.error('提问失败');
      return;
    }
    ToastUtil.hint('提问成功');
    Future.delayed(const Duration(seconds: 3), () async{
      Navigator.of(context).pop();
    });
    onSubmit = false;
  }

  Future showEmoji() async{
    isShowKeyboard = false;
    setState(() {
    });
    double keyboardHeight = EdgeInsets.fromWindowPadding(
      WidgetsBinding.instance.window.viewInsets, 
      WidgetsBinding.instance.window.devicePixelRatio).bottom;
    if(keyboardHeight > 0){
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    }
    await emojiPicKerController.showEmoji();
    bottomAnim.animateTo(SimpleInputState.EMOJI_LIST_HEIGHT);
    isShowEmojiPicker = true;
    setState(() {
    });
  }

  Future hideEmoji() async{
    isShowKeyboard = true;
    setState(() {
    });
    await emojiPicKerController.hideEmoji();
    isShowEmojiPicker = false;
    double keyboardHeight = EdgeInsets.fromWindowPadding(
      WidgetsBinding.instance.window.viewInsets, 
      WidgetsBinding.instance.window.devicePixelRatio).bottom;
    if(keyboardHeight == 0){
      bottomAnim.animateTo(0);
    }
    setState(() {
    });
  }

  @override
  void didChangeMetrics(){
    super.didChangeMetrics();
    double keyboardHeight = EdgeInsets.fromWindowPadding(
      WidgetsBinding.instance.window.viewInsets, 
      WidgetsBinding.instance.window.devicePixelRatio).bottom;
    Future.delayed(Duration.zero, (){
      bottomAnim.value = keyboardHeight;
      setState(() {
      });
    });
  }

  void showTagsDialog(){
    showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder:(context, animation, secondaryAnimation) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: Colors.transparent,
              child: TagsManagerWidget(
                initList: tagList,
                onChange: (tagList){
                  this.tagList = tagList;
                  setState(() {
                  });
                },
              ),
            )
          ],
        );
      },
    );
  }

  List<Widget> getTags(){
    List<Widget> widgets = [];
    if(tagList == null || tagList!.isEmpty){
      return [
        InkWell(
          onTap: showTagsDialog,
          child: const Text('添加标签', style: TextStyle(color: ThemeUtil.buttonColor, fontSize: 16),),
        )
      ];
    }
    for(String tag in tagList!){
      widgets.add(
        InkWell(
          onTap: showTagsDialog,
          child: Text(tag, style: const TextStyle(color: Colors.grey, fontSize: 16),),
        )
      );
    }
    return widgets;
  }
}

class AnonymousSwitch extends StatefulWidget{

  final bool initState;
  final Function(bool)? onChange;

  const AnonymousSwitch({required this.initState, this.onChange, super.key});
  
  @override
  State<StatefulWidget> createState() {
    return AnonymousSwitchState();
  }

}

class AnonymousSwitchState extends State<AnonymousSwitch> with SingleTickerProviderStateMixin{

  static const double COMMON_HEIGHT = 24;
  static const double BOTTOM_WIDTH = 80;
  static const double TOP_WIDTH = 40;
  static const int ANIM_MILLI_SECONDS = 200;

  late bool checkOn;
  late AnimationController animController;

  @override
  void dispose(){
    animController.dispose();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    animController = AnimationController(vsync: this, lowerBound: 0, upperBound: BOTTOM_WIDTH - TOP_WIDTH, duration: const Duration(milliseconds: ANIM_MILLI_SECONDS));
    checkOn = widget.initState;
    animController.value = checkOn ? animController.lowerBound : animController.upperBound;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        if(checkOn){
          animController.forward();
        }
        else{
          animController.reverse();
        }
        checkOn = !checkOn;
        widget.onChange?.call(checkOn);
        setState(() {
        });
      },
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: ANIM_MILLI_SECONDS),
            width: BOTTOM_WIDTH,
            height: COMMON_HEIGHT,
            decoration: BoxDecoration(
              color: checkOn ? const Color.fromRGBO(0xb5, 0xf0, 0xf8, 1) : const Color.fromRGBO(0xc0, 0xc0, 0xc0, 1),
              borderRadius: const BorderRadius.all(Radius.circular(COMMON_HEIGHT))
            ),
          ),
          const Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('匿名', style: TextStyle(color: Colors.white),),
            ),
          ),
          AnimatedBuilder(
            animation: animController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(animController.value, 0),
                child: child,
              );
            },
            child: Container(
              width: TOP_WIDTH,
              height: COMMON_HEIGHT,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(0x04, 0xb6, 0xdd, 1),
                borderRadius: BorderRadius.all(Radius.circular(COMMON_HEIGHT))
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class TagsManagerWidget extends StatefulWidget{
  final List<String>? initList;
  final Function(List<String>?)? onChange;

  const TagsManagerWidget({this.initList, this.onChange, super.key});
  
  @override
  State<StatefulWidget> createState() {
    return TagsManagerState();
  }

}

class TagsManagerState extends State<TagsManagerWidget>{

  static const double ADD_ICON_SIZE = 40;

  TextEditingController textController = TextEditingController();
  late List<String>? tagList;

  @override
  void initState(){
    super.initState();
    tagList = widget.initList;
  }

  @override
  void dispose(){
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String>? initList = widget.initList;
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4
          )
        ]
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('兴趣标签', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
          const SizedBox(height: 14,),
          Expanded(
            child: tagList == null || tagList!.isEmpty ?
            const Text('还没有添加标签~', style: TextStyle(color: Colors.grey, fontSize: 16),) :
            SingleChildScrollView(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: getTagWidgets(),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4
                      )
                    ]
                  ),
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  alignment: Alignment.centerLeft,
                  child: TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      hintText: '新的标签',
                      hintStyle: TextStyle(color: Color.fromRGBO(0xc5, 0xc5, 0xc6, 1)),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      counterText: ''
                    ),
                    maxLines: 1,
                    maxLength: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12,),
              InkWell(
                onTap: (){
                  String tag = textController.text.trim();
                  if(tag.isEmpty){
                    return;
                  }
                  tagList ??= [];
                  tagList!.add(tag);
                  setState(() {
                  });
                  widget.onChange?.call(tagList);
                  textController.text = '';
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    border: Border.fromBorderSide(BorderSide(color: Color.fromRGBO(78, 89, 105, 0.6)))
                  ),
                  width: ADD_ICON_SIZE,
                  height: ADD_ICON_SIZE,
                  child: const Icon(Icons.add, color: ThemeUtil.buttonColor, size: ADD_ICON_SIZE - 2,),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  List<Widget> getTagWidgets(){
    List<Widget> widgets = [];
    for(int i = 0; i < (tagList?.length ?? 0); ++i){
      String tag = tagList![i];
      widgets.add(
        TagSingleWidget(
          tag,
          onRemove: (){
            tagList!.removeAt(i);
            setState(() {
            });
            widget.onChange?.call(tagList);
          },
        )
      );
    }
    return widgets;
  }
}

class TagSingleWidget extends StatefulWidget{
  final String tag;
  final Function()? onRemove;
  const TagSingleWidget(this.tag, {this.onRemove, super.key});

  @override
  State<StatefulWidget> createState() {
    return TagSingleState();
  }

}

class TagSingleState extends State<TagSingleWidget>{

  bool showRemoveButton = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onLongPress: (){
            showRemoveButton = true;
            setState(() {
            });
          },
          child: Text(widget.tag, style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
        ),
        showRemoveButton ?
        TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap
          ),
          onPressed: widget.onRemove,
          child: const Icon(Icons.remove_circle_outline_rounded, color: Color.fromRGBO(78, 89, 105, 0.5), size: 20,),
        ) : const SizedBox()
      ],
    );
  }

}
