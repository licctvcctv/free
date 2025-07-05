
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freego_flutter/components/comment/comment_model.dart';
import 'package:freego_flutter/components/hotel_neo/comment/comment_hotel_dict.dart';
import 'package:freego_flutter/components/hotel_neo/comment/comment_hotel_model.dart';
import 'package:freego_flutter/components/hotel_neo/comment/comment_hotel_util.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/custom_emoji_picker.dart';
import 'package:freego_flutter/components/view/image_input.dart';
import 'package:freego_flutter/components/view/simple_input.dart';
import 'package:freego_flutter/components/view/stars_picker.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';

class CommentHotelCreatePage extends StatelessWidget{
  final int hotelId;
  final String? title;
  const CommentHotelCreatePage({required this.hotelId, this.title, super.key});

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
      body: CommentHotelCreateWidget(hotelId: hotelId, title: title,),
    );
  }
  
}

class CommentHotelCreateWidget extends StatefulWidget{
  final int hotelId;
  final String? title;
  const CommentHotelCreateWidget({required this.hotelId, this.title, super.key});

  @override
  State<StatefulWidget> createState() {
    return CommentHotelCreateState();
  }

}

class CommentHotelCreateState extends State<CommentHotelCreateWidget> with WidgetsBindingObserver{

  double _bottom = 0;

  int cleanScore = 100;
  int positionScore = 100;
  int serviceScore = 100;
  int facilityScore = 100;

  TextEditingController controller = TextEditingController();
  FocusNode focusNode = FocusNode();
  CustomEmojiPicKerController emojiPicKerController = CustomEmojiPicKerController();
  String content = '';
  List<String> picList = [];

  bool isShowKeyboard = true;
  bool isShowEmojiPicker = false;
  bool onSubmit = false;

  @override
  void dispose(){
    controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
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
        child: Container(
          color: ThemeUtil.backgroundColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonHeader(
                center: Text(widget.title ?? '', style: const TextStyle(color: Colors.white, fontSize: 18),),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height - CommonHeader.HEADER_HEIGHT
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                              padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(12))
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text('        卫生 ', style: TextStyle(color: Color.fromRGBO(0xc5, 0xc5, 0xc6, 1), fontSize: 18),),
                                      StarsPickerWidget(
                                        initStarNum: cleanScore ~/ 10,
                                        afterPick: (rank){
                                          cleanScore = rank * 10;
                                          setState(() {
                                          });
                                        }
                                      ),
                                      Text('  "${CommentHotelDict().cleanTagList[(cleanScore - 10) ~/ 20]}"', style: const TextStyle(color: ThemeUtil.foregroundColor),)
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Text('        位置 ', style: TextStyle(color: Color.fromRGBO(0xc5, 0xc5, 0xc6, 1), fontSize: 18),),
                                      StarsPickerWidget(
                                        initStarNum: positionScore ~/ 10,
                                        afterPick: (rank){
                                          positionScore = rank * 10;
                                          setState(() {
                                          });
                                        }
                                      ),
                                      Text('  "${CommentHotelDict().positionTagList[(positionScore - 10) ~/ 20]}"', style: const TextStyle(color: ThemeUtil.foregroundColor),)
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Text('        服务 ', style: TextStyle(color: Color.fromRGBO(0xc5, 0xc5, 0xc6, 1), fontSize: 18),),
                                      StarsPickerWidget(
                                        initStarNum: serviceScore ~/ 10,
                                        afterPick: (rank){
                                          serviceScore = rank * 10;
                                          setState(() {
                                          });
                                        }
                                      ),
                                      Text('  "${CommentHotelDict().serviceTagList[(serviceScore - 10) ~/ 20]}"', style: const TextStyle(color: ThemeUtil.foregroundColor),)
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Text('        设施 ', style: TextStyle(color: Color.fromRGBO(0xc5, 0xc5, 0xc6, 1), fontSize: 18),),
                                      StarsPickerWidget(
                                        initStarNum: facilityScore ~/ 10,
                                        afterPick: (rank){
                                          facilityScore = rank * 10;
                                          setState(() {
                                          });
                                        }
                                      ),
                                      Text('  "${CommentHotelDict().facilityTagList[(facilityScore - 10) ~/ 20]}"', style: const TextStyle(color: ThemeUtil.foregroundColor),)
                                    ],
                                  ),
                                  const Divider(),
                                  Row(
                                    children: [
                                      Container(
                                        height: 60,
                                        padding: const EdgeInsets.only(left: 40),
                                        alignment: Alignment.centerLeft,
                                        child: const Text('内容', style: TextStyle(color: Color.fromRGBO(0xc5, 0xc5, 0xc5, 1), fontSize: 18),),
                                      ),
                                      const Expanded(child: SizedBox()),
                                      Container(
                                        margin: const EdgeInsets.only(right: 20),
                                        child: TextButton(
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
                                              FocusScope.of(context).requestFocus(focusNode);
                                            });
                                          },
                                          child: const Icon(Icons.emoji_emotions_outlined, size: 34, color: Colors.grey,),
                                        ),
                                      )
                                    ],
                                  ),
                                  Container(
                                    height: 180,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color.fromRGBO(0xf3, 0xf3, 0xf3, 1),
                                      borderRadius: BorderRadius.circular(12)
                                    ),
                                    child: Listener(
                                      onPointerDown: (evt){
                                        if(isShowEmojiPicker){
                                          isShowKeyboard = true;
                                          focusNode.unfocus();
                                          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                                            FocusScope.of(context).requestFocus(focusNode);
                                          });
                                          hideEmoji();
                                          SystemChannels.textInput.invokeMethod('TextInput.show');
                                        }
                                      },
                                      child: TextField(
                                        controller: controller,
                                        focusNode: focusNode,
                                        keyboardType: isShowKeyboard ? TextInputType.multiline : TextInputType.none,
                                        decoration: const InputDecoration(
                                          hintText: '        你感觉怎么样呢？',
                                          hintStyle: TextStyle(color: Color.fromRGBO(0xc5, 0xc5, 0xc6, 1)),
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                          border: InputBorder.none,
                                        ),
                                        minLines: 1,
                                        maxLines: 9999,
                                        onChanged: (val){
                                          content = val;
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ImageInputWidget(
                              onChange: (pics){
                                picList = pics;
                              },
                            ),
                            SizedBox(
                              height: _bottom,
                            )
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 40 + _bottom,
                      child: InkWell(
                        onTap: submit,
                        child: Container(
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
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: CustomEmojiPickerWidget(
                        textController: controller,
                        outerController: emojiPicKerController,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future submit() async{
    String content = controller.text.trim();
    if(content.isEmpty){
      ToastUtil.warn('请填写评论内容');
      return;
    }
    if(onSubmit){
      return;
    }
    onSubmit = true;
    Comment comment = Comment();
    comment.productId = widget.hotelId;
    comment.typeId = ProductType.hotel.getNum();
    comment.content = controller.text.trim();
    if(picList.isNotEmpty){
      comment.pics = picList.join(',');
    }
    List<String> tagList = [];
    tagList.add(CommentHotelDict().cleanTagList[(cleanScore - 10) ~/ 20]);
    tagList.add(CommentHotelDict().positionTagList[(positionScore - 10) ~/ 20]);
    tagList.add(CommentHotelDict().serviceTagList[(serviceScore - 10) ~/ 20]);
    tagList.add(CommentHotelDict().facilityTagList[(facilityScore - 10) ~/ 20]);
    comment.tags = tagList.join(',');

    CommentHotelRaw raw = CommentHotelRaw();
    raw.cleanScore = cleanScore;
    raw.positionScore = positionScore;
    raw.serviceScore = serviceScore;
    raw.facilityScore = facilityScore;

    Comment? result = await CommentHotelUtil().post(comment, raw);
    if(result == null){
      ToastUtil.error('评论失败');
    }
    else{
      ToastUtil.hint('发表评论成功');
      Future.delayed(const Duration(seconds: 3), () {
        if(mounted && context.mounted){
          Navigator.of(context).pop();
        }
      });
    }
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
    _bottom = SimpleInputState.EMOJI_LIST_HEIGHT;
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
      _bottom = 0;
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
      _bottom = keyboardHeight;
      setState(() {
      });
    });
  }
}