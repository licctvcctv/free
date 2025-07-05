
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/circle_neo/circle_common.dart';
import 'package:freego_flutter/components/circle_neo/detail/circle_question_answer_http.dart';
import 'package:freego_flutter/components/circle_neo/detail/circle_question_answer_model.dart';
import 'package:freego_flutter/components/circle_neo/detail/circle_question_answer_util.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/custom_indicator.dart';
import 'package:freego_flutter/components/view/image_display.dart';
import 'package:freego_flutter/components/view/notify_empty.dart';
import 'package:freego_flutter/components/view/notify_loading.dart';
import 'package:freego_flutter/components/view/simple_input.dart';
import 'package:freego_flutter/components/view/tipoff.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/util/date_time_util.dart';
import 'package:freego_flutter/util/dialog_util.dart';
import 'package:freego_flutter/util/dictionary_util.dart';
import 'package:freego_flutter/util/local_user.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:freego_flutter/util/user_home_director.dart';
import 'package:freego_flutter/util/user_like_util.dart';

class CircleQuestionPage extends StatelessWidget{
  final CircleQuestion circle;
  const CircleQuestionPage(this.circle, {super.key});
  
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
      body: CircleQuestionWidget(circle),
    );
  }
  
}

class CircleQuestionWidget extends StatefulWidget{
  final CircleQuestion circle;
  const CircleQuestionWidget(this.circle, {super.key});

  @override
  State<StatefulWidget> createState() {
    return CircleQuestionState();
  }

}

class _MyAfterPostCircleQuestionAnswerHandler implements AfterPostCircleQuestionAnswerHandler{

  final CircleQuestionState state;
  const _MyAfterPostCircleQuestionAnswerHandler(this.state);

  @override
  void handle(CircleQuestionAnswer answer) {
    state.answerList.insert(0, answer);
    state.topBuffer = state.getAnswerWidget([answer]);
    state.resetState();
  }

}

class CircleQuestionState extends State<CircleQuestionWidget> with SingleTickerProviderStateMixin{

  static const double AVATAR_SIZE = 68;
  static const double MAKE_FRIEND_SIZE = 28;
  static const double BEHAVIOR_ICON_SIZE = 32;

  Widget svgComment = SvgPicture.asset('svg/comment/comment.svg');

  List<Widget> contents = [];
  List<Widget> topBuffer = [];
  List<Widget> bottomBuffer = [];

  List<CircleQuestionAnswer> answerList = [];
  bool inited = false;

  late _MyAfterPostCircleQuestionAnswerHandler _afterPostCircleQuestionAnswerHandler;

  late AnimationController rightMenuAnim;
  bool rightMenuShow = false;
  static const int RIGHT_MENU_ANIM_MILLI_SECONDS = 150;
  static const double RIGHT_MENU_WIDTH = 100;
  static const double RIGHT_MENU_ITEM_HEIGHT = 40;

  CircleQuestionAnswerController? answerBlockController;

  @override
  void dispose(){
    CircleQuestionAnswerUtil().removeHandler(_afterPostCircleQuestionAnswerHandler);
    rightMenuAnim.dispose();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();

    _afterPostCircleQuestionAnswerHandler = _MyAfterPostCircleQuestionAnswerHandler(this);
    CircleQuestionAnswerUtil().addHandler(_afterPostCircleQuestionAnswerHandler);

    CircleQuestion question = widget.circle;
    if(question.id != null){
      Future.delayed(Duration.zero, () async{
        List<CircleQuestionAnswer>? tmpList = await CircleQuestionAnswerHttp().listHistory(questionId: question.id!);
        if(tmpList != null){
          inited = true;
          answerList = tmpList;
          topBuffer = getAnswerWidget(answerList);
          if(mounted && context.mounted){
            setState(() {
            });
          }
        }
      });
    }

    rightMenuAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: RIGHT_MENU_ANIM_MILLI_SECONDS));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeUtil.backgroundColor,
      child: GestureDetector(
        onTap: (){
          if(rightMenuShow){
            rightMenuShow = false;
            rightMenuAnim.reverse();
            setState(() {
            });
            return;
          }
          answerBlockController?.hideMenu();
          answerBlockController = null;
        },
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonHeader(
                  center: const Text('问答', style: TextStyle(color: Colors.white, fontSize: 18),),
                  right: InkWell(
                    onTap: (){
                      answerBlockController?.hideMenu();
                      answerBlockController = null;

                      if(!rightMenuShow){
                        rightMenuAnim.forward();
                      }
                      else{
                        rightMenuAnim.reverse();
                      }
                      rightMenuShow = !rightMenuShow;
                      setState(() {
                      });
                    },
                    child: const Icon(Icons.more_vert_rounded, color: Colors.white,),
                  ),
                ),
                Expanded(
                  child: CircleQuestionAnswerShare(
                    answerBlockController: answerBlockController,
                    child: !inited ?
                    const NotifyLoadingWidget() :
                    AnimatedCustomIndicatorWidget(
                      header: Column(
                        children: [
                          getAuthorInfoWidget(),
                          getContentWidget(),
                          if(answerList.isEmpty)
                          const NotifyEmptyWidget(info: '还没有回答',)
                        ],
                      ),
                      contents: contents,
                      topBuffer: topBuffer,
                      bottomBuffer: bottomBuffer
                    ),
                  )
                ),
                if(LocalUser.isLogined())
                SimpleInputWidget(
                  hintText: '我要回答',
                  onSubmit: (val) async{
                    String content = val.trim();
                    if(content.isEmpty){
                      return false;
                    }
                    CircleQuestion question = widget.circle;
                    if(question.id == null){
                      return false;
                    }
                    CircleQuestionAnswer? answer = await CircleQuestionAnswerUtil().post(questionId: question.id!, content: content);
                    if(answer == null){
                      ToastUtil.error('回答失败');
                    }
                    return answer != null;
                  },
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
                          onPressed: showTipoffModal,
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
      ),
    );
  }

  void showTipoffModal(){
    Circle circle = widget.circle;
    if(circle.id == null){
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
              return TipOffWidget(targetId: circle.id!, productType: ProductType.circle,);
            }
          );
        }
      }
    });
  }

  Future loadNew() async{
    int? minId;
    if(answerList.isNotEmpty){
      minId = answerList.first.id;
    }
    CircleQuestion question = widget.circle;
    if(question.id == null){
      ToastUtil.error('数据错误');
      return;
    }
    List<CircleQuestionAnswer>? tmpList = await CircleQuestionAnswerHttp().listNew(questionId: question.id!, minId: minId);
    if(tmpList == null){
      ToastUtil.error('好像出了点小问题');
      return;
    }
    if(tmpList.isEmpty){
      ToastUtil.hint('已更新到最新');
      return;
    }
    topBuffer = getAnswerWidget(tmpList);
    answerList.insertAll(0, tmpList);
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }

  Future loadHistory() async{
    int? maxId;
    if(answerList.isNotEmpty){
      maxId = answerList.last.id;
    }
    CircleQuestion question = widget.circle;
    if(question.id == null){
      ToastUtil.error('数据错误');
      return;
    }
    List<CircleQuestionAnswer>? tmpList = await CircleQuestionAnswerHttp().listHistory(questionId: question.id!, maxId: maxId);
    if(tmpList == null){
      ToastUtil.error('好像出了点小问题');
      return;
    }
    if(tmpList.isEmpty){
      ToastUtil.hint('已经没有了呢');
      return;
    }
    bottomBuffer = getAnswerWidget(tmpList);
    answerList.addAll(tmpList);
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }

  List<Widget> getAnswerWidget(List<CircleQuestionAnswer> answerList){
    List<Widget> widgets = [];
    for(CircleQuestionAnswer answer in answerList){
      widgets.add(
        ConstrainedBox(
          key: UniqueKey(),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width
          ),
          child: CircleQuestionAnswerBlock(
            answer,
            onShowMenu: (controller){
              if(rightMenuShow){
                rightMenuShow = false;
                rightMenuAnim.reverse();
                setState(() {
                });
              }
              answerBlockController?.hideMenu();
              answerBlockController = controller;
            },
            onTipoff: showAnswerTipoffModal,
          ),
        )
      );
    }
    return widgets;
  }

  void showAnswerTipoffModal(answer){
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
              return TipOffWidget(targetId: answer.id!, productType: ProductType.circleQuestionAnswer,);
            }
          );
        }
      }
    });
  }
  
  Widget getContentWidget(){
    CircleQuestion circle = widget.circle;
    List<String>? picList;
    if(circle.pics != null && circle.pics!.isNotEmpty){
      picList = circle.pics!.split(',');
      for(int i = 0; i < picList.length; ++i){
        if(!picList[i].startsWith('http')){
          picList[i] = getFullUrl(picList[i]);
        }
      }
    }
    double size = MediaQuery.of(context).size.width;
    size = (size - 32 - 20) / 3;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(circle.title ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
          const SizedBox(height: 10,),
          Html(
            data: circle.content,
            style: {
              'body': Style(
                padding: HtmlPaddings.zero,
                margin: Margins.zero
              ),
              'html': Style(
                lineHeight: const LineHeight(1.5)
              ),
            },
          ),
          picList != null && picList.isNotEmpty ?
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: ImageDisplayWidget(picList, size: size,),
          ) : const SizedBox(),
        ],
      ),
    );
  }

  Widget getAuthorInfoWidget(){
    CircleQuestion circle = widget.circle;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          InkWell(
            onTap: (){
              if(circle.userId != null){
                UserHomeDirector().goUserHome(context: context, userId: circle.userId!);
              }
            },
            child: ClipOval(
              child: SizedBox(
                width: AVATAR_SIZE,
                height: AVATAR_SIZE,
                child: circle.authorHead == null ?
                ThemeUtil.defaultUserHead :
                Image.network(getFullUrl(circle.authorHead!), fit: BoxFit.cover,),
              ),
            ),
          ),
          const SizedBox(width: 10,),
          InkWell(
            onTap: (){
              if(circle.userId != null){
                UserHomeDirector().goUserHome(context: context, userId: circle.userId!);
              }
            },
            child: Text(StringUtil.getLimitedText(circle.authorName ?? '', DictionaryUtil.USERNAME_MAX_LENGTH), style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
          ),
          const SizedBox(width: 10,),
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

class CircleQuestionAnswerShare extends InheritedWidget{
  final CircleQuestionAnswerController? answerBlockController;
  const CircleQuestionAnswerShare({required this.answerBlockController, super.key, required super.child});

  @override
  bool updateShouldNotify(covariant CircleQuestionAnswerShare oldWidget) {
    return true;
  }
  
}

class CircleQuestionAnswerBlock extends StatefulWidget{
  final CircleQuestionAnswer answer;
  final Function(CircleQuestionAnswerController)? onShowMenu;
  final Function(CircleQuestionAnswer)? onTipoff;
  final CircleQuestionAnswerController? controller;
  const CircleQuestionAnswerBlock(this.answer, {this.onShowMenu, this.onTipoff, this.controller, super.key});

  @override
  State<StatefulWidget> createState() {
    return CircleQuestionAnswerState();
  }

}

class _MyAfterUserLikeHandler implements AfterUserLikeHandler{

  final CircleQuestionAnswerState state;
  const _MyAfterUserLikeHandler(this.state);

  @override
  void handle(int id, ProductType type) {
    if(type != ProductType.circleQuestionAnswer){
      return;
    }
    CircleQuestionAnswer answer = state.widget.answer;
    if(answer.id != id){
      return;
    }
    if(answer.isLiked != true){
      answer.isLiked = true;
      answer.likeNum = (answer.likeNum ?? 0) + 1;
    }
    state.resetState();
  }
  
}

class _MyAfterUserUnlikeHandler implements AfterUserUnlikeHandler{

  final CircleQuestionAnswerState state;
  const _MyAfterUserUnlikeHandler(this.state);
  
  @override
  void handle(int id, ProductType type) {
    if(type != ProductType.circleQuestionAnswer){
      return;
    }
    CircleQuestionAnswer answer = state.widget.answer;
    if(answer.id != id){
      return;
    }
    if(answer.isLiked == true){
      answer.isLiked = false;
      answer.likeNum = (answer.likeNum ?? 1) - 1;
    }
    state.resetState();
  }

}

enum CircleQuestionAnswerAction{
  showMenu,
  hideMenu
}

class CircleQuestionAnswerController extends ChangeNotifier{
  CircleQuestionAnswerAction? action;
  void showMenu(){
    action = CircleQuestionAnswerAction.showMenu;
    notifyListeners();
  }
  void hideMenu(){
    action = CircleQuestionAnswerAction.hideMenu;
    notifyListeners();
  }
}

class CircleQuestionAnswerState extends State<CircleQuestionAnswerBlock> with SingleTickerProviderStateMixin{

  static const double AVATAR_SIZE = 40;
  static const double OPERATION_ICON_SIZE = 28;

  late _MyAfterUserLikeHandler _afterUserLikeHandler;
  late _MyAfterUserUnlikeHandler _afterUserUnlikeHandler;

  late AnimationController rightMenuAnim;
  bool rightMenuShow = false;
  static const int RIGHT_MENU_ANIM_MILLI_SECONDS = 150;
  static const double RIGHT_MENU_WIDTH = 100;
  static const double RIGHT_MENU_ITEM_HEIGHT = 40;

  late CircleQuestionAnswerController controller;

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
      controller = CircleQuestionAnswerController();
    }
    else{
      controller = widget.controller!;
    }
    controller.addListener(() { 
      if(mounted && context.mounted){
        switch(controller.action){
          case CircleQuestionAnswerAction.showMenu:
            showMenu();
            break;
          case CircleQuestionAnswerAction.hideMenu:
            hideMenu();
            break;
          default:
        }
      }
    });
  }

  void showMenu(){
    widget.onShowMenu?.call(controller);
    rightMenuAnim.forward();
    rightMenuShow = true;
    setState(() {
    });
  }

  void hideMenu(){
    rightMenuAnim.reverse();
    rightMenuShow = false;
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    CircleQuestionAnswer answer = widget.answer;
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 4, 0, 4),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(4))
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
                        width: AVATAR_SIZE,
                        height: AVATAR_SIZE,
                        child: answer.userHead == null ?
                        ThemeUtil.defaultUserHead :
                        Image.network(getFullUrl(answer.userHead!))
                      ),
                    ),
                  ),
                  const SizedBox(width: 10,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: (){
                          if(answer.userId != null){
                            UserHomeDirector().goUserHome(context: context, userId: answer.userId!);
                          }
                        },
                        child: Text(answer.userName ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor,),),
                      ),
                      answer.createTime == null ?
                      const SizedBox() :
                      Text(DateTimeUtil.shortTime(answer.createTime!), style: const TextStyle(color: Colors.grey),)
                    ],
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
                    child: const Icon(Icons.more_vert_rounded, color: ThemeUtil.foregroundColor, size: 24,),
                  )
                ],
              ),
              const SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.only(left: AVATAR_SIZE + 10),
                child: Text(answer.content ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
              ),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: (){
                      CircleQuestionAnswer answer = widget.answer;
                      if(answer.id == null){
                        return;
                      }
                      if(answer.isLiked == true){
                        UserLikeUtil.unlike(answer.id!, ProductType.circleQuestionAnswer);
                      }
                      else{
                        UserLikeUtil.like(answer.id!, ProductType.circleQuestionAnswer);
                      }
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
          if(rightMenuShow)
          Positioned.fill(
            child: InkWell(
              onTap: (){
                rightMenuShow = false;
                rightMenuAnim.reverse();
                setState(() {
                });
              },
            ),
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
                          widget.onTipoff?.call(widget.answer);
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
