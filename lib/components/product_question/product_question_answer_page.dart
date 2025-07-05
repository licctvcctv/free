
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/components/product_question/product_question_answer_http.dart';
import 'package:freego_flutter/components/product_question/product_question_answer_util.dart';
import 'package:freego_flutter/components/product_question/product_question_common.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/custom_indicator.dart';
import 'package:freego_flutter/components/view/image_display.dart';
import 'package:freego_flutter/components/view/menu_action.dart';
import 'package:freego_flutter/components/view/simple_input.dart';
import 'package:freego_flutter/components/view/tipoff.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/util/date_time_util.dart';
import 'package:freego_flutter/util/dialog_util.dart';
import 'package:freego_flutter/util/local_user.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:freego_flutter/util/user_home_director.dart';
import 'package:freego_flutter/util/user_like_util.dart';

class ProductQuestionAnswerPage extends StatelessWidget{

  final ProductQuestion question;
  final ProductType merchantType;
  final int? merchantId;
  const ProductQuestionAnswerPage(this.question, {required this.merchantType, this.merchantId, super.key});

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
      body: ProductQuestionAnswerWidget(question, merchantType: merchantType, merchantId: merchantId,),
    );
  }
  
}

class ProductQuestionAnswerWidget extends StatefulWidget{
  final ProductQuestion question;
  final ProductType merchantType;
  final int? merchantId;
  const ProductQuestionAnswerWidget(this.question, {required this.merchantType, this.merchantId, super.key});

  @override
  State<StatefulWidget> createState() {
    return ProductQuestionAnswerState();
  }

}

class _MyAfterPostProductQuestionAnswerHandler implements AfterPostProductQuestionAnswerHandler{

  final ProductQuestionAnswerState state;
  _MyAfterPostProductQuestionAnswerHandler(this.state);

  @override
  void handler(ProductQuestionAnswer answer) {
    ProductQuestion question = state.widget.question;
    if(answer.questionId != null && answer.questionId == question.id){
      state.answerList.insert(0, answer);
      List<Widget> widgets = state.getAnswerWidgets([answer]);
      state.topBuffer = widgets;
      state.resetState();
    }
  }

}

class ProductQuestionAnswerState extends State<ProductQuestionAnswerWidget>{

  List<ProductQuestionAnswer> answerList = [];

  List<Widget> contents = [];
  List<Widget> topBuffer = [];
  List<Widget> bottomBuffer = [];

  late _MyAfterPostProductQuestionAnswerHandler _afterPostProductQuestionAnswerHandler;

  CommonMenuController? menuController;

  @override
  void dispose(){
    ProductQuestionAnswerUtil().removeHandler(_afterPostProductQuestionAnswerHandler);
    super.dispose();
  }

  @override
  void initState(){
    super.initState();

    _afterPostProductQuestionAnswerHandler = _MyAfterPostProductQuestionAnswerHandler(this);
    ProductQuestionAnswerUtil().addHandler(_afterPostProductQuestionAnswerHandler);

    Future.delayed(Duration.zero, () async{
      ProductQuestion question = widget.question;
      if(question.id == null){
        ToastUtil.error('数据错误');
        return;
      }
      List<ProductQuestionAnswer>? tmpList = await ProductQuestionAnswerHttp().listHistory(questionId: question.id!);
      if(tmpList == null){
        ToastUtil.error('好像出了点小问题');
        return;
      }
      answerList = tmpList;
      topBuffer = getAnswerWidgets(answerList);
      if(mounted && context.mounted){
        setState(() {
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        menuController?.hideMenu();
        menuController = null;
        FocusScope.of(context).unfocus();
      },
      child: Container(
        color: ThemeUtil.backgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CommonHeader(
              center: Text('问答详情', style: TextStyle(color: Colors.white, fontSize: 18),),
            ),
            Expanded(
              child: AnimatedCustomIndicatorWidget(
                contents: contents,
                topBuffer: topBuffer,
                bottomBuffer: bottomBuffer,
                header: getQuestionWidget(),
                touchTop: loadNew,
                touchBottom: loadMore,
              ),
            ),
            if(LocalUser.isLogined())
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: SimpleInputWidget(
                hintText: '我要回答',
                backgroundColor: ThemeUtil.backgroundColor,
                onSubmit: answerQuestion,
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<bool> answerQuestion(String val) async{
    val = val.trim();
    if(val.isEmpty){
      return false;
    }
    ProductQuestionAnswer answer = ProductQuestionAnswer();
    answer.questionId = widget.question.id;
    answer.content = val;
    ProductQuestionAnswer? result = await ProductQuestionAnswerUtil().post(answer);
    if(result == null){
      ToastUtil.error('评论失败');
      return false;
    }
    else{
      ToastUtil.hint('评论成功');
      return true;
    }
  }

  Future loadNew() async{
    ProductQuestion question = widget.question;
    if(question.id == null){
      ToastUtil.error('数据错误');
      return;
    }
    int? minId;
    if(answerList.isNotEmpty){
      minId = answerList.first.id;
    }
    List<ProductQuestionAnswer>? tmpList = await ProductQuestionAnswerHttp().listNew(questionId: question.id!, minId: minId);
    if(tmpList == null){
      ToastUtil.error('好像出了点小问题');
      return;
    }
    if(tmpList.isEmpty){
      ToastUtil.hint('已更新到最新');
      return;
    }
    List<Widget> widgets = getAnswerWidgets(tmpList);
    answerList.insertAll(0, tmpList);
    topBuffer = widgets;
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }

  Future loadMore() async{
    ProductQuestion question = widget.question;
    if(question.id == null){
      ToastUtil.error('数据错误');
      return;
    }
    int? maxId;
    if(answerList.isNotEmpty){
      maxId = answerList.last.id;
    }
    List<ProductQuestionAnswer>? tmpList = await ProductQuestionAnswerHttp().listHistory(questionId: question.id!, maxId: maxId);
    if(tmpList == null){
      ToastUtil.error('好像出了点小问题');
      return;
    }
    if(tmpList.isEmpty){
      ToastUtil.hint('已经没有了呢');
      return;
    }
    List<Widget> widgets = getAnswerWidgets(tmpList);
    answerList.addAll(tmpList);
    bottomBuffer = widgets;
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }

  List<Widget> getAnswerWidgets(List<ProductQuestionAnswer> answerList){
    List<Widget> widgets = [];
    for(ProductQuestionAnswer answer in answerList){
      widgets.add(
        AnswerBlock(
          answer: answer, 
          merchantType: widget.merchantType, 
          merchantId: widget.merchantId, 
          key: UniqueKey(),
          onMenuShow: (controller){
            menuController?.hideMenu();
            menuController = controller;
          },
          onTipoffQuestionAnswer: (answer){
            if(answer.id == null){
              ToastUtil.error('数据错误');
              return;
            }
            DialogUtil.loginRedirectConfirm(context, callback: (isLogined){
              if(isLogined){
                if(mounted && context.mounted){
                  showModalBottomSheet(
                    isDismissible: true,
                    isScrollControlled: true,
                    context: context,
                    builder: (context){
                      return TipOffWidget(targetId: answer.id!, productType: ProductType.productQuestionAnswer,);
                    }
                  );
                }
              }
            });
            
          },
        )
      );
    }
    return widgets;
  }

  Widget getQuestionWidget(){
    return QuestionBlock(
      question: widget.question, 
      merchantType: widget.merchantType, 
      merchantId: widget.merchantId, 
      onMenuShow: (controller){
        menuController?.hideMenu();
        menuController = controller;
      },
      onTipoffQuestion: (question){
        if(question.id == null){
          ToastUtil.error('数据错误');
          return;
        }
        DialogUtil.loginRedirectConfirm(context, callback: (isLogined){
          if(isLogined){
            if(mounted && context.mounted){
              showModalBottomSheet(
                isDismissible: true,
                isScrollControlled: true,
                context: context,
                builder: (context){
                  return TipOffWidget(targetId: question.id!, productType: ProductType.productQuestion,);
                }
              );
            }
          }
        });
      },
    );
  }

  void resetState(){
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }
}

class QuestionBlock extends StatefulWidget{

  final ProductQuestion question;
  final ProductType merchantType;
  final int? merchantId;

  final CommonMenuController? controller;
  final Function(CommonMenuController)? onMenuShow;
  final Function(ProductQuestion)? onTipoffQuestion;

  const QuestionBlock({required this.question, required this.merchantType, this.merchantId, this.controller, this.onMenuShow, this.onTipoffQuestion, super.key});

  @override
  State<StatefulWidget> createState() {
    return QuestionState();
  }
  
}

class QuestionState extends State<QuestionBlock> with SingleTickerProviderStateMixin{

  static const double AVATAR_SIZE = 56;

  late AnimationController rightMenuAnim;
  bool rightMenuShow = false;
  static const int RIGHT_MENU_ANIM_MILLI_SECONDS = 150;
  static const double RIGHT_MENU_WIDTH = 100;
  static const double RIGHT_MENU_ITEM_HEIGHT = 40;

  late CommonMenuController controller;

  @override
  void initState(){
    super.initState();
    rightMenuAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: RIGHT_MENU_ANIM_MILLI_SECONDS));
    if(widget.controller == null){
      controller = CommonMenuController();
    }
    else{
      controller = widget.controller!;
    }
    controller.addListener(() { 
      if(mounted && context.mounted){
        switch(controller.action){
          case CommonMenuAction.showMenu:
            showMenu();
            break;
          case CommonMenuAction.hideMenu:
            hideMenu();
            break;
          default:
            break;
        }
      }
    });
  }

  @override
  void dispose(){
    rightMenuAnim.dispose();
    if(widget.controller == null){
      controller.dispose();
    }
    super.dispose();
  }

  void showMenu(){
    widget.onMenuShow?.call(controller);
    rightMenuAnim.forward();
    rightMenuShow = true;
  }

  void hideMenu(){
    rightMenuAnim.reverse();
    rightMenuShow = false;
  }

  @override
  Widget build(BuildContext context) {
    ProductQuestion question = widget.question;
    List<String>? picList;
    if(question.pics != null && question.pics!.isNotEmpty){
      picList = question.pics!.split(',');
      for(int i = 0; i < picList.length; ++i){
        String pic = picList[i];
        picList[i] = getFullUrl(pic);
      }
    }
    double picSize = (MediaQuery.of(context).size.width - 2 * ImageDisplayWidget.SPACING - 36) / 3;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16))
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: (){
                      if(question.userId != null){
                        UserHomeDirector().goUserHome(context: context, userId: question.userId!);
                      }
                    },
                    child: ClipOval(
                      child: SizedBox(
                        width: AVATAR_SIZE,
                        height: AVATAR_SIZE,
                        child: question.userHead == null ?
                        ThemeUtil.defaultUserHead :
                        Image.network(getFullUrl(question.userHead!), fit: BoxFit.cover,),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8,),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            InkWell(
                              onTap: (){
                                if(question.userId != null){
                                  UserHomeDirector().goUserHome(context: context, userId: question.userId!);
                                }
                              },
                              child: Text(question.userName ?? '匿名用户', style: const TextStyle(color: ThemeUtil.foregroundColor,),),
                            ),
                            question.userId == widget.merchantId && question.userId != null ?
                            Container(
                              padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                              decoration: const BoxDecoration(
                                color: Colors.lightBlueAccent,
                                borderRadius: BorderRadius.all(Radius.circular(4))
                              ),
                              child: Text(StringUtil.getAuthorTag(widget.merchantType), style: const TextStyle(color: ThemeUtil.foregroundColor),),
                            ) : const SizedBox(),
                            const Expanded(
                              child: SizedBox(),
                            ),
                          ],
                        ),
                        question.createTime == null ?
                        const SizedBox() :
                        Text(DateTimeUtil.shortTime(question.createTime!), style: const TextStyle(color: Colors.grey),)
                      ],
                    ),
                  ),
                  if(question.answerNum != null && question.answerNum! > 0)
                  Text('${question.answerNum}个回答', style: const TextStyle(color: Colors.grey),),
                  const SizedBox(width: 10,),
                  InkWell(
                    onTap: (){
                      if(rightMenuShow){
                        hideMenu();
                      }
                      else{
                        showMenu();
                      }
                    },
                    child: const Icon(Icons.more_vert_rounded, color: ThemeUtil.foregroundColor,),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Text(question.title ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Text(question.content ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor),),
              ),
              picList != null && picList.isNotEmpty ?
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  ImageDisplayWidget(
                    picList,
                    size: picSize,
                  )
                ],
              ) : const SizedBox(),
            ],
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
                        onPressed: (){
                          widget.onTipoffQuestion?.call(question);
                        },
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
              },
            ),
          )
        ],
      ),
    );
  }

}

class AnswerBlock extends StatefulWidget{
  final ProductQuestionAnswer answer;
  final ProductType merchantType;
  final int? merchantId;

  final CommonMenuController? controller;
  final Function(CommonMenuController)? onMenuShow;
  final Function(ProductQuestionAnswer)? onTipoffQuestionAnswer;

  const AnswerBlock({required this.answer, this.merchantId, required this.merchantType, this.controller, this.onMenuShow, this.onTipoffQuestionAnswer, super.key});
  
  @override
  State<StatefulWidget> createState() {
    return AnswerBlockState();
  }

}

class _MyAfterUserLikeHandler implements AfterUserLikeHandler{

  final AnswerBlockState state;
  _MyAfterUserLikeHandler(this.state);

  @override
  void handle(int id, ProductType type) {
    ProductQuestionAnswer answer = state.widget.answer;
    if(type == ProductType.productQuestionAnswer && id == answer.id){
      if(answer.isLiked != true){
        answer.isLiked = true;
        answer.likeNum = (answer.likeNum ?? 0) + 1;
      }
      state.resetState();
    }
  }

}

class _MyAfterUserUnlikeHandler implements AfterUserUnlikeHandler{

  final AnswerBlockState state;
  _MyAfterUserUnlikeHandler(this.state);

  @override
  void handle(int id, ProductType type) {
    ProductQuestionAnswer answer = state.widget.answer;
    if(type == ProductType.productQuestionAnswer && id == answer.id){
      if(answer.isLiked == true){
        answer.isLiked = false;
        answer.likeNum = (answer.likeNum ?? 1) - 1;
      }
      state.resetState();
    }
  }

}

class AnswerBlockState extends State<AnswerBlock> with SingleTickerProviderStateMixin{

  static const double AVATAR_SUB_SIZE = 36;

  static const double OPERATION_ICON_SIZE = 28;

  late _MyAfterUserLikeHandler _afterUserLikeHandler;
  late _MyAfterUserUnlikeHandler _afterUserUnlikeHandler;

  late AnimationController rightMenuAnim;
  bool rightMenuShow = false;
  static const int RIGHT_MENU_ANIM_MILLI_SECONDS = 150;
  static const double RIGHT_MENU_WIDTH = 100;
  static const double RIGHT_MENU_ITEM_HEIGHT = 40;

  late CommonMenuController controller;

  @override
  void dispose(){
    UserLikeUtil.removeAfterUserLikeHandler(_afterUserLikeHandler);
    UserLikeUtil.removeAfterUserUnlikeHandler(_afterUserUnlikeHandler);
    rightMenuAnim.dispose();
    if(widget.controller == null){
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    _afterUserLikeHandler = _MyAfterUserLikeHandler(this);
    UserLikeUtil.addAfterUserLikeHandler(_afterUserLikeHandler);
    _afterUserUnlikeHandler = _MyAfterUserUnlikeHandler(this);
    UserLikeUtil.addAfterUserUnlikeHandler(_afterUserUnlikeHandler);
    rightMenuAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: RIGHT_MENU_ANIM_MILLI_SECONDS));
    if(widget.controller == null){
      controller = CommonMenuController();
    }
    else{
      controller = widget.controller!;
    }
    controller.addListener(() { 
      if(mounted && context.mounted){
        switch(controller.action){
          case CommonMenuAction.showMenu:
            showMenu();
            break;
          case CommonMenuAction.hideMenu:
            hideMenu();
            break;
          default:
            break;
        }
      }
    });
  }

  void showMenu(){
    widget.onMenuShow?.call(controller);
    rightMenuAnim.forward();
    rightMenuShow = true;
  }

  void hideMenu(){
    rightMenuAnim.reverse();
    rightMenuShow = false;
  }

  @override
  Widget build(BuildContext context) {
    ProductQuestionAnswer answer = widget.answer;
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 4, 0, 4),
      padding: const EdgeInsets.all(16),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: (){
                      if(answer.userId != null){
                        UserHomeDirector().goUserHome(context: context, userId: answer.userId!);
                      }
                    },
                    child: ClipOval(
                      child: SizedBox(
                        width: AVATAR_SUB_SIZE,
                        height: AVATAR_SUB_SIZE,
                        child: answer.userHead == null ?
                        ThemeUtil.defaultUserHead :
                        Image.network(getFullUrl(answer.userHead!), fit: BoxFit.cover,)
                      ),
                    ),
                  ),
                  const SizedBox(width: 8,),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            InkWell(
                              onTap: (){
                                if(answer.userId != null){
                                  UserHomeDirector().goUserHome(context: context, userId: answer.userId!);
                                }
                              },
                              child: Text(answer.userName ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor,),),
                            ),
                            answer.userId == widget.merchantId && answer.userId != null ?
                            Container(
                              padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                              decoration: const BoxDecoration(
                                color: Colors.lightBlueAccent,
                                borderRadius: BorderRadius.all(Radius.circular(4))
                              ),
                              child: Text(StringUtil.getAuthorTag(widget.merchantType), style: const TextStyle(color: ThemeUtil.foregroundColor),),
                            ) : const SizedBox()
                          ],
                        ),
                        answer.createTime == null ?
                        const SizedBox() :
                        Text(DateTimeUtil.shortTime(answer.createTime!), style: const TextStyle(color: Colors.grey),)
                      ],
                    ),
                  ),
                  const SizedBox(width: 10,),
                  InkWell(
                    onTap: (){
                      if(rightMenuShow){
                        hideMenu();
                      }
                      else{
                        showMenu();
                      }
                    },
                    child: const Icon(Icons.more_vert_rounded, color: ThemeUtil.foregroundColor,),
                  )
                ],
              ),
              const SizedBox(height: 6,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: AVATAR_SUB_SIZE,
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                      decoration: const BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.all(Radius.circular(4))
                      ),
                      alignment: Alignment.centerRight,
                      child: const Text('答：', style: TextStyle(color: Colors.white),),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(8, 0, 0, 4),
                      child: Text(answer.content ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor),)
                    ),
                  )
                ],
              ),
              const SizedBox(height: 8,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: (){
                      if(answer.id == null){
                        return;
                      }
                      DialogUtil.loginRedirectConfirm(context, callback: (isLogined){
                        if(isLogined){
                          if(answer.isLiked == true){
                            UserLikeUtil.unlike(answer.id!, ProductType.productQuestionAnswer);
                          }
                          else{
                            UserLikeUtil.like(answer.id!, ProductType.productQuestionAnswer);
                          }
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      width: OPERATION_ICON_SIZE,
                      height: OPERATION_ICON_SIZE,
                      child: answer.isLiked == true ?
                      Image.asset('assets/comment/icon_comment_like_on.png') :
                      Image.asset('assets/comment/icon_comment_like.png')
                    ),
                  ),
                  Text('${answer.likeNum ?? 0}', style: const TextStyle(color: Colors.grey),)
                ],
              )
            ],
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
                        onPressed: (){
                          widget.onTipoffQuestionAnswer?.call(answer);
                        },
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
              },
            ),
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
