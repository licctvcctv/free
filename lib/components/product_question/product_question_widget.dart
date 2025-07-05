
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/components/product_question/product_question_answer_util.dart';
import 'package:freego_flutter/components/product_question/product_question_common.dart';
import 'package:freego_flutter/components/product_question/product_question_create.dart';
import 'package:freego_flutter/components/product_question/product_question_http.dart';
import 'package:freego_flutter/components/product_question/product_question_page.dart';
import 'package:freego_flutter/components/product_question/product_question_util.dart';
import 'package:freego_flutter/components/view/image_display.dart';
import 'package:freego_flutter/components/view/menu_action.dart';
import 'package:freego_flutter/components/view/notify_empty.dart';
import 'package:freego_flutter/components/view/notify_loading.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/util/date_time_util.dart';
import 'package:freego_flutter/util/dialog_util.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';

class ProductQuestionShowWidget extends StatefulWidget{
  final int productId;
  final ProductType productType;
  final int? ownnerId;
  final String? title;
  final Function(CommonMenuController)? onMenuShow;
  final Function(ProductQuestion)? onTipoffQuestion;
  final Function(ProductQuestionAnswer)? onTipoffQuestionAnswer;
  const ProductQuestionShowWidget({required this.productId, required this.productType, this.ownnerId, this.title, this.onMenuShow, this.onTipoffQuestion, this.onTipoffQuestionAnswer, super.key});

  @override
  State<StatefulWidget> createState() {
    return ProductQuestionShowState();
  }
  
}

class _MyAfterPostQuestionHandler implements AfterPostQuestionHandler{

  final ProductQuestionShowState state;
  _MyAfterPostQuestionHandler(this.state);
  
  @override
  void handle(ProductQuestion question) {
    if(question.productId == state.widget.productId && question.productType == state.widget.productType.getNum()){
      state.questionList ??= [];
      state.questionList!.insert(0, question);
      state.resetState();
    }
  }
}



class ProductQuestionShowState extends State<ProductQuestionShowWidget> with AutomaticKeepAliveClientMixin{

  static const int DEFAULT_INIT_COUNT = 4;


  List<ProductQuestion>? questionList; 

  late _MyAfterPostQuestionHandler _afterPostQuestionHandler;
  

  @override
  void dispose(){
    ProductQuestionUtil().removeAfterPostQuestionHandler(_afterPostQuestionHandler);
    super.dispose();
  }

  @override
  void initState(){
    super.initState();

    _afterPostQuestionHandler = _MyAfterPostQuestionHandler(this);
    ProductQuestionUtil().addAfterPostQuestionHandler(_afterPostQuestionHandler);

    Future.delayed(Duration.zero, () async{
      List<ProductQuestion>? tmpList = await ProductQuestionHttp().listHistory(productId: widget.productId, productType: widget.productType, limit: DEFAULT_INIT_COUNT);
      if(tmpList != null){
        questionList = tmpList;
        if(mounted && context.mounted){
          setState(() {
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if(questionList == null){
      return const NotifyLoadingWidget();
    }
    if(questionList!.isEmpty){
      return InkWell(
        onTap: (){
          DialogUtil.loginRedirectConfirm(context, callback: (isLogined){
            if(isLogined){
              if(mounted && context.mounted){
                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                  return ProductQuestionCreatePage(productId: widget.productId, type: widget.productType);
                }));
              }
            }
          });

        },
        child: const NotifyEmptyWidget(info: '我要第一个提问',),
      );
    }
    return InkWell(
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(builder: (context){
          return ProductQuestionPage(productId: widget.productId, type: widget.productType, merchantId: widget.ownnerId, title: widget.title,);
        }));
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12))
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: getQuestionWidgets(),
        ),
      ),
    );
  }

  List<Widget> getQuestionWidgets(){
    List<Widget> widgets = [];
    for(ProductQuestion question in questionList ?? []){
      widgets.add(
        QuestionBlockWidget(question: question, productType: widget.productType, ownnerId: widget.ownnerId, onMenuShow: widget.onMenuShow, onTipoffQuestion: widget.onTipoffQuestion, onTipoffQuestionAnswer: widget.onTipoffQuestionAnswer,)
      );
      widgets.add(
        const Divider()
      );
    }
    return widgets;
  }

  void resetState(){
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }
  
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class QuestionBlockWidget extends StatefulWidget{
  final ProductQuestion question;
  final ProductType productType;
  final int? ownnerId;
  final CommonMenuController? controller;
  final Function(CommonMenuController)? onMenuShow;
  final Function(ProductQuestion)? onTipoffQuestion;
  final Function(ProductQuestionAnswer)? onTipoffQuestionAnswer;
  const QuestionBlockWidget({required this.question, required this.productType, this.ownnerId, this.controller, this.onMenuShow, this.onTipoffQuestion, this.onTipoffQuestionAnswer, super.key});

  @override
  State<StatefulWidget> createState() {
    return QuestionBlockState();
  }
  
}

class _MyAfterPostProductQuestionAnswerHandler implements AfterPostProductQuestionAnswerHandler{

  final QuestionBlockState state;
  _MyAfterPostProductQuestionAnswerHandler(this.state);

  @override
  void handler(ProductQuestionAnswer answer) {
    if(answer.questionId == null){
      return;
    }
    ProductQuestion question = state.widget.question;
    if(question.id == answer.questionId){
      question.answerList ??= [];
      question.answerList!.insert(0, answer);
      state.resetState();
    }
  }
  
}

class QuestionBlockState extends State<QuestionBlockWidget> with SingleTickerProviderStateMixin{

  static const double AVATAR_SIZE = 56;
  static const double AVATAR_SUB_SIZE = 36;

  late _MyAfterPostProductQuestionAnswerHandler _afterPostProductQuestionAnswerHandler;

  late AnimationController rightMenuAnim;
  bool rightMenuShow = false;
  static const int RIGHT_MENU_ANIM_MILLI_SECONDS = 150;
  static const double RIGHT_MENU_WIDTH = 100;
  static const double RIGHT_MENU_ITEM_HEIGHT = 40;

  late CommonMenuController controller;

  @override
  void initState(){
    super.initState();
    _afterPostProductQuestionAnswerHandler = _MyAfterPostProductQuestionAnswerHandler(this);
    ProductQuestionAnswerUtil().addHandler(_afterPostProductQuestionAnswerHandler);
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
    ProductQuestionAnswerUtil().removeHandler(_afterPostProductQuestionAnswerHandler);
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
    List<String> picList = [];
    if(question.pics != null && question.pics!.isNotEmpty){
      picList = question.pics!.split(',');
      for(int i = 0; i < picList.length; ++i){
        String pic = picList[i];
        picList[i] = getFullUrl(pic);
      }
    }
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: AVATAR_SIZE,
                    height: AVATAR_SIZE,
                    child: question.userHead == null ?
                    ThemeUtil.defaultUserHead :
                    Image.network(getFullUrl(question.userHead!), fit: BoxFit.cover,),
                  ),
                ),
                const SizedBox(width: 8,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(question.userName ?? '匿名用户', style: const TextStyle(color: ThemeUtil.foregroundColor,),),
                          question.userId == widget.ownnerId && question.userId != null ?
                          Container(
                            padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                            decoration: const BoxDecoration(
                              color: Colors.lightBlueAccent,
                              borderRadius: BorderRadius.all(Radius.circular(4))
                            ),
                            child: Text(StringUtil.getAuthorTag(widget.productType), style: const TextStyle(color: ThemeUtil.foregroundColor),),
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
            const SizedBox(height: 6,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: AVATAR_SIZE,
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                    decoration: const BoxDecoration(
                      color: Colors.lightBlue,
                      borderRadius: BorderRadius.all(Radius.circular(4))
                    ),
                    child: const Text('问：', style: TextStyle(color: Colors.white),),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(8, 0, 0, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if(picList.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ImageDisplayWidget(
                              picList
                            ),
                            const SizedBox(height: 10,),
                          ],
                        ),
                        Text(question.title ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor),),
                        question.answerList != null && question.answerList!.isNotEmpty ?
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: getQuestionAnswerWidgets(question.answerList!),
                          ),
                        ) : const SizedBox()
                      ],
                    ),
                  ),
                )
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
    );

  }

  List<Widget> getQuestionAnswerWidgets(List<ProductQuestionAnswer> answerList){
    List<Widget> widgets = [];
    for(int i = 0; i < answerList.length; ++i){
      ProductQuestionAnswer answer = answerList[i];
      widgets.add(const Divider());
      widgets.add(
        QuestionAnswerBlockWidget(answer: answer, productType: widget.productType, ownnerId: widget.ownnerId, onMenuShow: widget.onMenuShow, onTipoffQuestionAnswer: widget.onTipoffQuestionAnswer,)
      );
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

class QuestionAnswerBlockWidget extends StatefulWidget{
  final ProductQuestionAnswer answer;
  final ProductType productType;
  final int? ownnerId;
  final CommonMenuController? controller;
  final Function(CommonMenuController)? onMenuShow;
  final Function(ProductQuestionAnswer)? onTipoffQuestionAnswer;

  const QuestionAnswerBlockWidget({required this.answer, required this.productType, this.ownnerId, this.controller, this.onMenuShow, this.onTipoffQuestionAnswer, super.key});

  @override
  State<StatefulWidget> createState() {
    return QuestionAnswerBlockState();
  }
  
}

class QuestionAnswerBlockState extends State<QuestionAnswerBlockWidget> with SingleTickerProviderStateMixin{

  static const double AVATAR_SIZE = 56;
  static const double AVATAR_SUB_SIZE = 36;

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
    ProductQuestionAnswer answer = widget.answer;
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: AVATAR_SUB_SIZE,
                    height: AVATAR_SUB_SIZE,
                    child: answer.userHead == null ?
                    ThemeUtil.defaultUserHead :
                    Image.network(getFullUrl(answer.userHead!))
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(answer.userName ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: ThemeUtil.foregroundColor),),
                          answer.userId == widget.ownnerId ?
                          Container(
                            padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                            decoration: const BoxDecoration(
                              color: Colors.lightBlueAccent,
                              borderRadius: BorderRadius.all(Radius.circular(4))
                            ),
                            child: Text(StringUtil.getAuthorTag(widget.productType), style: const TextStyle(color: ThemeUtil.foregroundColor),),
                          ) : const SizedBox(),
                        ],
                      ),
                      answer.createTime == null ?
                      const SizedBox() :
                      Text(DateTimeUtil.shortTime(answer.createTime!), style: const TextStyle(color: Colors.grey),)
                    ],
                  ),
                ),
                const Expanded(child: SizedBox()),
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
              padding: const EdgeInsets.only(left: AVATAR_SUB_SIZE + 8, top: 6),
              child: Text(answer.content ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor),),
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
      ]
    );
  }
  
}
