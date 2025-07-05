
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/components/product_question/product_question_answer_page.dart';
import 'package:freego_flutter/components/product_question/product_question_answer_util.dart';
import 'package:freego_flutter/components/product_question/product_question_common.dart';
import 'package:freego_flutter/components/product_question/product_question_create.dart';
import 'package:freego_flutter/components/product_question/product_question_http.dart';
import 'package:freego_flutter/components/product_question/product_question_util.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/custom_indicator.dart';
import 'package:freego_flutter/components/view/image_display.dart';
import 'package:freego_flutter/components/view/menu_action.dart';
import 'package:freego_flutter/components/view/notify_empty.dart';
import 'package:freego_flutter/components/view/notify_loading.dart';
import 'package:freego_flutter/components/view/search_bar.dart';
import 'package:freego_flutter/components/view/tipoff.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/util/date_time_util.dart';
import 'package:freego_flutter/util/dialog_util.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';

class ProductQuestionPage extends StatelessWidget{
  final int productId;
  final ProductType type;
  final int? merchantId;
  final String? title;
  const ProductQuestionPage({required this.productId, required this.type, this.merchantId, this.title, super.key});
  
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
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: ProductQuestionWidget(productId: productId, type: type, merchantId: merchantId, title: title,),
      ),
    );
  }
}

class ProductQuestionWidget extends StatefulWidget{

  final int productId;
  final ProductType type;
  final int? merchantId;
  final String? title;

  const ProductQuestionWidget({required this.productId, required this.type, this.merchantId, this.title, super.key});

  @override
  State<StatefulWidget> createState() {
    return ProductQuestionState();
  }

}

class _MyAfterPostQuestionHandler implements AfterPostQuestionHandler{

  ProductQuestionState state;
  _MyAfterPostQuestionHandler(this.state);

  @override
  void handle(ProductQuestion question) {
    if(question.productId == state.widget.productId && question.productType == state.widget.type.getNum()){
      List<ProductQuestion> questionList = state.questionList;
      List<Widget> widgets = state.getQuestionWidgets([question]);
      questionList.insert(0, question);
      state.topBuffer = widgets;
      state.resetState();
    }
  }

}

class ProductQuestionState extends State<ProductQuestionWidget>{

  List<ProductQuestion> questionList = [];
  bool inited = false;
  String? keyword;

  List<Widget> contents = [];
  List<Widget> topBuffer = [];
  List<Widget> bottomBuffer = [];

  late _MyAfterPostQuestionHandler _afterPostQuestionHandler;

  CommonMenuController? menuController;

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
      List<ProductQuestion>? tmpList = await ProductQuestionHttp().listHistory(productId: widget.productId, productType: widget.type);
      if(tmpList == null){
        ToastUtil.error('好像出了点小问题');
        return;
      }
      inited = true;
      questionList = tmpList;
      topBuffer = getQuestionWidgets(questionList);
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
      },
      child: Container(
        color: ThemeUtil.backgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonHeader(
              center: Text(widget.title ?? '全部问答', style: const TextStyle(color: Colors.white, fontSize: 18),),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: SearchBar(
                onSubmit: (val){
                  keyword = val;
                  refresh();
                },
              )
            ),
            Expanded(
              child: Stack(
                children: [
                  !inited ?
                  const NotifyLoadingWidget() :
                  questionList.isEmpty ?
                  const NotifyEmptyWidget() :
                  AnimatedCustomIndicatorWidget(
                    contents: contents,
                    topBuffer: topBuffer,
                    bottomBuffer: bottomBuffer,
                    touchTop: loadNew,
                    touchBottom: loadHistory,
                  ),
                  Positioned(
                    bottom: 40,
                    left: 0,
                    child: InkWell(
                      onTap: (){
                        DialogUtil.loginRedirectConfirm(context, callback: (isLogined){
                          if(isLogined){
                            if(mounted && context.mounted){
                              Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                return ProductQuestionCreatePage(productId: widget.productId, type: widget.type, title: widget.title,);
                              }));
                            }
                          }
                        });
                      },
                      child: Opacity(
                        opacity: 0.6,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(4, 182, 221, 1),
                            borderRadius: BorderRadius.horizontal(right: Radius.circular(40))
                          ),
                          width: 104,
                          height: 56,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.edit, color: Colors.white,),
                              Text('去提问', style: TextStyle(color: Colors.white, fontSize: 16),),
                            ],
                          )
                        ),
                      ),
                    ),
                  )
                ],
              )
            )
          ],
        ),
      ),
    );
  }

  Future refresh() async{
    List<ProductQuestion>? tmpList = await ProductQuestionHttp().listHistory(productId: widget.productId, productType: widget.type, keyword: keyword);
    if(tmpList == null){
      ToastUtil.error('好像出了点小问题');
      return;
    }
    questionList = tmpList;
    topBuffer = getQuestionWidgets(questionList);
    contents = [];
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }

  Future loadNew() async{
    int? minId;
    if(questionList.isNotEmpty){
      minId = questionList.first.id;
    }
    List<ProductQuestion>? tmpList = await ProductQuestionHttp().listNew(productId: widget.productId, productType: widget.type, keyword: keyword, minId: minId);
    if(tmpList == null){
      ToastUtil.error('好像出了点小问题');
      return;
    }
    if(tmpList.isEmpty){
      ToastUtil.hint('已更新到最新');
      return;
    }
    List<Widget> widgets = getQuestionWidgets(tmpList);
    topBuffer = widgets;
    questionList.insertAll(0, tmpList);
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }

  Future loadHistory() async{
    int? maxId;
    if(questionList.isNotEmpty){
      maxId = questionList.last.id;
    }
    List<ProductQuestion>? tmpList = await ProductQuestionHttp().listHistory(productId: widget.productId, productType: widget.type, keyword: keyword, maxId: maxId);
    if(tmpList == null){
      ToastUtil.error('好像出了点小问题');
      return;
    }
    if(tmpList.isEmpty){
      ToastUtil.hint('已经没有了呢');
      return;
    }
    List<Widget> widgets = getQuestionWidgets(tmpList);
    bottomBuffer = widgets;
    questionList.addAll(tmpList);
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }

  List<Widget> getQuestionWidgets(List<ProductQuestion> questionList){
    List<Widget> widgets = [];
    for(ProductQuestion question in questionList){
      widgets.add(
        Container(
          key: UniqueKey(),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(4))
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width
          ),
          margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          padding: const EdgeInsets.all(16),
          child: ProductQuestionBlock(
            question, 
            merchantType: widget.type,
            merchantId: widget.merchantId,
            key: UniqueKey(),
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
          ),
        )
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

class ProductQuestionBlock extends StatefulWidget{

  final ProductQuestion question;
  final ProductType merchantType;
  final int? merchantId;

  final CommonMenuController? controller;
  final Function(CommonMenuController)? onMenuShow;
  final Function(ProductQuestion)? onTipoffQuestion;
  final Function(ProductQuestionAnswer)? onTipoffQuestionAnswer;

  const ProductQuestionBlock(this.question, {required this.merchantType, this.merchantId, this.controller, this.onMenuShow, this.onTipoffQuestion, this.onTipoffQuestionAnswer, super.key});

  @override
  State<StatefulWidget> createState() {
    return ProductQuestionBlockState();
  }

}

class _MyAfterPostProductQuestionAnswerHandler implements AfterPostProductQuestionAnswerHandler{

  final ProductQuestionBlockState state;
  _MyAfterPostProductQuestionAnswerHandler(this.state);

  @override
  void handler(ProductQuestionAnswer answer) {
    ProductQuestion question = state.widget.question;
    if(answer.questionId != null && answer.questionId == question.id){
      question.answerList ??= [];
      question.answerList!.insert(0, answer);
      state.resetState();
    }
  }
  
}

class ProductQuestionBlockState extends State<ProductQuestionBlock> with SingleTickerProviderStateMixin{

  static const int DEFAULT_INIT_COUNT = 4;
  static const double AVATAR_SIZE = 56;

  static const double OPERATION_ICON_SIZE = 28;

  late _MyAfterPostProductQuestionAnswerHandler _afterPostProductQuestionAnswerHandler;

  late AnimationController rightMenuAnim;
  bool rightMenuShow = false;
  static const int RIGHT_MENU_ANIM_MILLI_SECONDS = 150;
  static const double RIGHT_MENU_WIDTH = 100;
  static const double RIGHT_MENU_ITEM_HEIGHT = 40;

  late CommonMenuController controller;

  @override
  void dispose(){
    ProductQuestionAnswerUtil().removeHandler(_afterPostProductQuestionAnswerHandler);
    rightMenuAnim.dispose();
    if(widget.controller == null){
      controller.dispose();
    }
    super.dispose();
  }

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
    Widget inner = Stack(
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
                          if(question.userId == widget.merchantId && question.userId != null)
                          Container(
                            padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                            decoration: const BoxDecoration(
                              color: Colors.lightBlueAccent,
                              borderRadius: BorderRadius.all(Radius.circular(4))
                            ),
                            child: Text(StringUtil.getAuthorTag(widget.merchantType), style: const TextStyle(color: ThemeUtil.foregroundColor),),
                          ),
                          const Expanded(
                            child: SizedBox(),
                          ),
                        ],
                      ),
                      question.createTime == null ?
                      const SizedBox() :
                      Text(DateTimeUtil.shortTime(question.createTime!), style: const TextStyle(color: Colors.grey),),
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
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context){
                        return ProductQuestionAnswerPage(question, merchantType: widget.merchantType, merchantId: widget.merchantId,);
                      }));
                    },
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(8, 0, 0, 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          picList.isEmpty ?
                          const SizedBox() :
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ImageDisplayWidget(
                              picList
                            ),
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
    return inner;
  }

  List<Widget> getQuestionAnswerWidgets(List<ProductQuestionAnswer> answerList){
    List<Widget> widgets = [];
    for(int i = 0; i < answerList.length; ++i){
      ProductQuestionAnswer answer = answerList[i];
      widgets.add(const Divider());
      widgets.add(
        ProductQuestionAnswerBlock(answer: answer, productType: widget.merchantType, merchantId: widget.merchantId, onMenuShow: widget.onMenuShow, onTipoffQuestionAnswer: widget.onTipoffQuestionAnswer,)
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

class ProductQuestionAnswerBlock extends StatefulWidget{

  final ProductQuestionAnswer answer;
  final ProductType productType;
  final int? merchantId;
  final CommonMenuController? controller;
  final Function(CommonMenuController)? onMenuShow;
  final Function(ProductQuestionAnswer)? onTipoffQuestionAnswer;

  const ProductQuestionAnswerBlock({required this.answer, required this.productType, this.merchantId, this.controller, this.onMenuShow, this.onTipoffQuestionAnswer, super.key});
  
  @override
  State<StatefulWidget> createState() {
    return ProductQuestinAnswerBlockState();
  }

}

class ProductQuestinAnswerBlockState extends State<ProductQuestionAnswerBlock> with SingleTickerProviderStateMixin{

  static const int DEFAULT_INIT_COUNT = 4;
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
          key: UniqueKey(),
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
                          answer.userId == widget.merchantId ?
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
      ],
    );
  }
  
}
