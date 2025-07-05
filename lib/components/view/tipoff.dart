import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/components/view/image_input.dart';
import 'package:freego_flutter/http/http_tipoff.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';

class TipOffWidget extends StatefulWidget{
  
  final TipoffType type;
  final ProductType? productType;
  final int targetId;

  const TipOffWidget({this.type = TipoffType.content, this.productType, required this.targetId, super.key});

  @override
  State<StatefulWidget> createState() {
    return TipOffState();
  }

}

class TipOffState extends State<TipOffWidget> with TickerProviderStateMixin, WidgetsBindingObserver{

  static const double MODAL_HEIGHT = 400;

  static const double MODAL_CANCEL_ICON_SIZE = 40;
  static const double TYPE_CHOOSE_WIDTH = 200;
  static const double TYPE_CHOOSE_HEIGHT = 25;
  static const List<String> TIPOFF_TYPES = ['色情低俗', '政治敏感', '造谣宣传', '涉嫌欺诈', '侵犯权益', '违法犯罪', '其他'];

  static const int TIPOFF_DESCRIP_LENGTH_MAX = 140;
  static const int TIPOFF_IMAGE_COUNT_MAX = 4;
  static const double TIPOFF_IMAGE_SIZE = 50;

  static const double SUBMIT_BUTTON_WIDTH = 160;
  static const double SUBMIT_BUTTON_HEIGHT = 40;

  String type = '';
  Widget svgCancelWidget = SvgPicture.asset('svg/cancel.svg');
  late AnimationController keyboardAnim;

  bool choiceState = false;
  late AnimationController choiceAnim;

  TextEditingController textController = TextEditingController();
  int currentLength = 0;

  List<String> picList = const [];

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    keyboardAnim = AnimationController(vsync: this, lowerBound: 0, upperBound: double.infinity);
    choiceAnim = AnimationController(vsync: this, lowerBound: 0, upperBound: TIPOFF_TYPES.length * TYPE_CHOOSE_HEIGHT, duration: const Duration(milliseconds: 350));
  }

  @override
  void dispose(){
    WidgetsBinding.instance.removeObserver(this);
    keyboardAnim.dispose();
    choiceAnim.dispose();
    textController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics(){
    super.didChangeMetrics();
    keyboardAnim.value = EdgeInsets.fromWindowPadding(
      WidgetsBinding.instance.window.viewInsets, 
      WidgetsBinding.instance.window.devicePixelRatio).bottom;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    for(String type in TIPOFF_TYPES){
      widgets.add(
        InkWell(
          onTap: (){
            this.type = type;
            choiceState = false;
            setState(() {
            });
            choiceAnim.reverse();
          },
          child: Container(
            width: TYPE_CHOOSE_WIDTH,
            height: TYPE_CHOOSE_HEIGHT,
            color: Colors.white,
            alignment: Alignment.center,
            child: Text(type),
          ),
        )
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: MODAL_HEIGHT,
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                color: ThemeUtil.backgroundColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: (){
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(MODAL_CANCEL_ICON_SIZE * 0.15),
                            width: MODAL_CANCEL_ICON_SIZE * 0.7,
                            height: MODAL_CANCEL_ICON_SIZE * 0.7,
                            child: svgCancelWidget,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text('举报类型', style: TextStyle(color: Colors.grey),),
                    const SizedBox(height: 10,),
                    Container(
                      width: TYPE_CHOOSE_WIDTH,
                      height: TYPE_CHOOSE_HEIGHT,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4
                          )
                        ]
                      ),
                      child: InkWell(
                        onTap: (){
                          if(choiceState){
                            choiceState = false;
                            choiceAnim.reverse();
                          }
                          else{
                            choiceState = true;
                            choiceAnim.forward();
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(type),
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down_sharp, size: 20,)
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10,),
                    const Text('请详细描述投诉内容', style: TextStyle(color: Colors.grey),),
                    const SizedBox(height: 10,),
                    Container(
                      width: double.infinity,
                      height: 100,
                      color: Colors.white,
                      child: TextField(
                        controller: textController,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.fromLTRB(8, 10, 8, 10),
                          border: InputBorder.none,
                          counterText: '',
                        ),
                        maxLines: 99,
                        maxLength: TIPOFF_DESCRIP_LENGTH_MAX,
                        onChanged: (val){
                          currentLength = val.length;
                          setState((){});
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('$currentLength/$TIPOFF_DESCRIP_LENGTH_MAX', style: const TextStyle(color: Colors.grey),)
                      ],
                    ),
                    const SizedBox(height: 10,),
                    ImageInputWidget(
                      maxLength: TIPOFF_IMAGE_COUNT_MAX,
                      onChange: (pics){
                        picList = pics;
                      },
                      size: TIPOFF_IMAGE_SIZE,
                      borderRadius: TIPOFF_IMAGE_SIZE / 8,
                      addIcon: (count){
                        return Container(
                          width: TIPOFF_IMAGE_SIZE,
                          height: TIPOFF_IMAGE_SIZE,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(TIPOFF_IMAGE_SIZE / 8),
                            color: Colors.white
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: TIPOFF_IMAGE_SIZE / 10,),
                              Image.asset('assets/icon_camera.png', width: TIPOFF_IMAGE_SIZE * 0.6, height: TIPOFF_IMAGE_SIZE * 0.6,),
                              Text('$count/$TIPOFF_IMAGE_COUNT_MAX', style: const TextStyle(fontSize: TIPOFF_IMAGE_SIZE / 5),)
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap
                          ),
                          onPressed: () async{
                            if(!TIPOFF_TYPES.any((element) => element == type)){
                              ToastUtil.warn('请选择类型');
                              return;
                            }
                            if(textController.text.trim().isEmpty){
                              ToastUtil.warn('请填写投诉内容');
                              return;
                            }
                            bool result = await HttpTipoff.postTipoff(
                              reason: type, 
                              descrip: textController.text.trim(),
                              type: widget.type.getNum(),
                              targetType: widget.productType?.getNum(),
                              picList: picList,
                              targetId: widget.targetId
                            );
                            if(result){
                              ToastUtil.hint('举报成功');
                              Future.delayed(const Duration(seconds: 1), (){
                                if(context.mounted){
                                  Navigator.of(context).pop();
                                }
                              });
                            }
                            else{
                              ToastUtil.error('举报失败');
                            }
                          }, 
                          child: Container(
                            width: SUBMIT_BUTTON_WIDTH,
                            height: SUBMIT_BUTTON_HEIGHT,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(SUBMIT_BUTTON_WIDTH / 4)),
                            ),
                            clipBehavior: Clip.hardEdge,
                            alignment: Alignment.center,
                            child: const Text('提交'),
                          )
                        )
                      ],
                    )
                  ],
                ),
              ),
              Positioned(
                top: 116,
                left: 16,
                child: AnimatedBuilder(
                  animation: choiceAnim,
                  builder: (context, child){
                    return SizedBox(
                      width: TYPE_CHOOSE_WIDTH,
                      height: choiceAnim.value,
                      child: Wrap(
                        clipBehavior: Clip.hardEdge,
                        direction: Axis.vertical,
                        children: widgets,
                      ),
                    );
                  },
                )
              )
            ],
          ),
          AnimatedBuilder(
            animation: keyboardAnim, 
            builder: (context, child){
              return Container(
                color: ThemeUtil.backgroundColor,
                height: keyboardAnim.value,
              );
            }
          )
        ],
      ),
    );
  }

}