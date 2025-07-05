import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/chat_neo/chat_common.dart';
import 'package:freego_flutter/components/chat_neo/chat_room.dart';
import 'package:freego_flutter/components/chat_neo/chat_util.dart';
import 'package:freego_flutter/components/comment/comment_page.dart';
import 'package:freego_flutter/components/comment/comment_widget.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/components/product_question/product_question_widget.dart';
import 'package:freego_flutter/components/travel/travel_api.dart';
import 'package:freego_flutter/components/travel/travel_book.dart';
import 'package:freego_flutter/components/travel/travel_common.dart';
import 'package:freego_flutter/components/travel/travel_desc_freego.dart';
import 'package:freego_flutter/components/travel/travel_detail_freego.dart';
import 'package:freego_flutter/components/travel/travel_notice_freego.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/date_choose_view.dart';
import 'package:freego_flutter/components/view/menu_action.dart';
import 'package:freego_flutter/components/view/navigated_view.dart';
import 'package:freego_flutter/components/view/pics_swiper.dart';
import 'package:freego_flutter/components/view/price_calendar.dart';
import 'package:freego_flutter/components/view/tipoff.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/http/http_tool.dart';
import 'package:freego_flutter/http/http_travel.dart';
import 'package:freego_flutter/model/travel_suit.dart';
import 'package:freego_flutter/model/travel_suit_price.dart';
import 'package:freego_flutter/util/date_choose_util.dart';
import 'package:freego_flutter/util/date_time_util.dart';
import 'package:freego_flutter/util/dialog_util.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:intl/intl.dart';

class TravelDetailPage extends StatefulWidget {
  final Travel travel;
  const TravelDetailPage(this.travel, {super.key});

  @override
  State<StatefulWidget> createState() {
    return TravelDetailPageState();
  }
}

class TravelDetailPageState extends State<TravelDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 10,
        elevation: 0,
        backgroundColor: const Color.fromRGBO(0xf2, 0xf5, 0xfa, 1),
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      resizeToAvoidBottomInset: false,
      body: TravelDetailWidget(widget.travel),
    );
  }
}

class TravelDetailWidget extends StatefulWidget {
  final Travel travel;
  const TravelDetailWidget(this.travel, {super.key});

  @override
  State<StatefulWidget> createState() {
    return TravelDetailState();
  }
}

class TravelDetailState extends State<TravelDetailWidget> with SingleTickerProviderStateMixin {

  int picIndex = 0;
  List<TravelSuitModel> travelSuitList = [];

  Map<int, List<TravelSuitPriceModel>> priceMap = {};

  Map<int, Map<String, TravelSuitPriceModel>> priceDeepMap = {};

  NavigatedController naviController = NavigatedController();

  late DateTime firstDate;
  late DateTime lastDate;
  late DateTime startDate;
  late DateTime endDate;

  bool showCalendar = false;

  late AnimationController rightMenuAnim;

  AMapFlutterLocation amapLocation = AMapFlutterLocation();
  bool rightMenuShow = false;

  static const int RIGHT_MENU_ANIM_MILLI_SECONDS = 150;
  static const double RIGHT_MENU_WIDTH = 100;
  static const double RIGHT_MENU_ITEM_HEIGHT = 40;

  bool showMoreSuits = false;

  Widget svgQuestion = SvgPicture.asset('svg/question.svg', color: const Color.fromRGBO(163, 129, 250, 1),);

  CommonMenuController? menuController;

  late Travel travel;

  @override
  void initState() {
    travel = widget.travel;
    super.initState();
    firstDate = DateTime.now();
    startDate = DateTime.now();
    firstDate = DateTime(firstDate.year, firstDate.month, firstDate.day);
    lastDate = firstDate.add(const Duration(days: 90));
    startDate = firstDate.add(Duration(days: travel.orderBeforeDays ?? 0));
    endDate = startDate.add(Duration(days: travel.nightNum ?? 0));
    if (mounted && context.mounted) {
      setState(() {});
    }
    rightMenuAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: RIGHT_MENU_ANIM_MILLI_SECONDS));
  }

  @override
  void dispose() {
    amapLocation.stopLocation();
    amapLocation.destroy();
    rightMenuAnim.dispose();
    super.dispose();
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
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    physics: const ClampingScrollPhysics(),
                    children: [
                      getPicsView(),
                      getBasicView(),
                      getContackWidget(),
                      getDateChooseWidget(),
                      getReserveView(),
                      getCommentWidget(),
                      getQuestionWidget(),
                    ],
                  ),
                )
              ],
            ),
            rightMenuShow? 
            Positioned.fill(
              child: InkWell(
                onTap: () {
                  rightMenuShow = false;
                  rightMenuAnim.reverse();
                  setState(() {});
                },
              ),
            )
            : const SizedBox(),
            Positioned(
              top: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: rightMenuAnim,
                builder: (context, child) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: rightMenuAnim.value * RIGHT_MENU_ITEM_HEIGHT * 2
                    ),
                    child: Wrap(
                      clipBehavior: Clip.hardEdge,
                      children: [
                        Container(
                          width: RIGHT_MENU_WIDTH,
                          decoration: const BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12)),
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 2)
                            ]
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                                    return TravelDescPage(travel);
                                  }));
                                  rightMenuAnim.reverse();
                                  rightMenuShow = false;
                                  setState(() {});
                                },
                                child: Container(
                                  width: RIGHT_MENU_WIDTH,
                                  height: RIGHT_MENU_ITEM_HEIGHT,
                                  alignment: Alignment.center,
                                  child: const Text(
                                    '行程介绍',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                                    return TravelNoticePage(travel);
                                  }));
                                  rightMenuAnim.reverse();
                                  rightMenuShow = false;
                                  setState(() {});
                                },
                                child: Container(
                                  width: RIGHT_MENU_WIDTH,
                                  height: RIGHT_MENU_ITEM_HEIGHT,
                                  alignment: Alignment.center,
                                  child: const Text(
                                    '预订须知',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              )
                            ],
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

  Widget getBasicView() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        // Wrap Text widget with Flexible
                        child: Text(
                          travel.name ?? '',
                          style: const TextStyle(
                            color: ThemeUtil.foregroundColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return TravelDescPage(travel);
                    }));
                  },
                  child: Row(
                    children: const [
                      Text(
                        '详情',
                        style: TextStyle(color: Color.fromRGBO(163, 129, 250, 1)),
                      ),
                      Icon(
                        Icons.keyboard_arrow_right_rounded,
                        size: 30,
                        color: Color.fromRGBO(163, 129, 250, 1),
                        weight: 1000,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          const Divider(),
          Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                child: Container(
                  color: const Color.fromRGBO(163, 129, 250, 1),
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                  child: Text(
                    travel.score == null ?
                    '暂无评分' : 
                    '${((travel.score ?? 0) / 10).toStringAsFixed(1)}分',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const Expanded(
                child: SizedBox(),
              ),
              InkWell(
                onTap: () async {
                  if (travel.id == null) {
                    ToastUtil.error('数据错误');
                    return;
                  }
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                    return CommentPage(productId: travel.id!, type: ProductType.travel);
                  }));
                },
                child: Row(
                  children: [
                    Text(
                      '${travel.commentNum}条评论',
                      style: const TextStyle(color: Color.fromRGBO(163, 129, 250, 1)),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_right_rounded,
                      size: 30,
                      color: Color.fromRGBO(163, 129, 250, 1),
                      weight: 1000,
                    )
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget getContackWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color.fromRGBO(163, 129, 250, 1),
                      Color.fromRGBO(241, 248, 233, 1)
                    ]
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(12))
                ),
                padding: const EdgeInsets.fromLTRB(10, 14, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '出发城市：${travel.city}',
                      style: const TextStyle(color: ThemeUtil.foregroundColor),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      '游玩天数：${travel.dayNum!}天${travel.nightNum!}晚',
                      style: const TextStyle(color: ThemeUtil.foregroundColor),
                    ),
                  ],
                )
              ),
            ),
          ),
          const SizedBox(width: 10,),
          InkWell(
            onTap: () async{
              if(travel.userId == null){
                return;
              }
              DialogUtil.loginRedirectConfirm(context, callback: (isLogined) async{
                if(isLogined){
                  ImSingleRoom? room = await ChatUtilSingle.enterRoom(travel.userId!);
                  if(room == null){
                    return;
                  }
                  if(mounted && context.mounted){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context){
                      return ChatRoomPage(room: room,);
                    }));
                  }
                }
              });
              
            }, 
            child: SizedBox(
              width: 40,
              height: 40,
              child: svgQuestion,
            )
          ),
        ],
      ),
    );
  }

  Widget getPicsView() {
    List<String>? picList = [];
    if (travel.pics != null) {
      picList = travel.pics!.split(',');
      for (int i = 0; i < picList.length; ++i) {
        picList[i] = getFullUrl(picList[i]);
      }
    }
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12))
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          picList.isEmpty? 
          const SizedBox() : 
          PicsSwiper(
            urlBuilder: (idx) {
              return picList![idx];
            },
            count: picList.length
          ),
          Align(
            alignment: Alignment.topCenter,
            child: CommonHeader(
              left: Container(
                decoration: const BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.all(Radius.circular(4))
                ),
                width: 48,
                height: 48,
                alignment: Alignment.center,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                  ),
                ),
              ),
              right: TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap
                ),
                onPressed: () {
                  if (!rightMenuShow) {
                    rightMenuAnim.forward();
                  } else {
                    rightMenuAnim.reverse();
                  }
                  rightMenuShow = !rightMenuShow;
                  setState(() {});
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.all(Radius.circular(4))
                  ),
                  width: 48,
                  height: 48,
                  child: const Icon(
                    Icons.more_vert_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              backgroundColor: Colors.transparent,
            ),
          )
        ],
      ),
    );
  }

  Future setPrices() async{
    if(travel.id == null){
      return;
    }
    List<TravelSuit>? suits = await TravelApi().suits(travelId: travel.id!, day: startDate);
    travel.suitList = suits;
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }

  Widget getDateChooseWidget() {
    DateTime currentDate = DateTime.now()
      .subtract(
        Duration(
          hours: DateTime.now().hour,
          minutes: DateTime.now().minute,
          seconds: DateTime.now().second,
          milliseconds: DateTime.now().millisecond,
          microseconds: DateTime.now().microsecond,
        )
      )
      .add(
        Duration(
          days: (travel.orderBeforeDays ?? 0) + (travel.nightNum ?? 0),
        ),
      );
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
            onTap: () async {
              final config = DateChooseConfig(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width,
                firstDate: DateTime.now()
                  .subtract(
                    Duration(
                      hours: DateTime.now().hour,
                      minutes: DateTime.now().minute,
                      seconds: DateTime.now().second,
                      milliseconds: DateTime.now().millisecond,
                      microseconds: DateTime.now().microsecond,
                    )
                  )
                  .add(Duration(days: travel.orderBeforeDays ?? 0)),
                lastDate: firstDate.add(const Duration(days: 90)),
                chooseMode: DateChooseMode.single
              );
              List<DateTime>? results = await DateChooseUtil.chooseDate(context, config);
              if (results != null /*&& results.length > 1*/) {
                startDate = results.first;
                endDate = startDate.add(Duration(days: travel.nightNum ?? 0));
                showCalendar = true;
                if (mounted && context.mounted) {
                  setState(() {});
                }
              }
              setPrices();
            },
            child: Text(
              DateFormat('yyyy-MM-dd').format(startDate),
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                decoration: TextDecoration.underline
              ),
            ),
          ),
          Text(
            DateTimeUtil.getWeekDayCn(startDate),
            style: const TextStyle(color: Colors.grey),
          ),
          const Text(
            ' 至 ',
            style: TextStyle(color: Colors.grey),
          ),
          InkWell(
            onTap: () async {
              final config = DateChooseConfig(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width,
                firstDate: currentDate,
                lastDate: firstDate.add(const Duration(days: 90)),
                chooseMode: DateChooseMode.single
              );
              List<DateTime>? results = await DateChooseUtil.chooseDate(context, config);
              if (results != null /*&& results.length > 1*/) {
                endDate = results.first;
                startDate = endDate.subtract(Duration(days: travel.nightNum ?? 0));
                showCalendar = true;
                if (mounted && context.mounted) {
                  setState(() {});
                }
              }
              setPrices();
            },
            child: Text(
              DateFormat('yyyy-MM-dd').format(endDate),
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                decoration: TextDecoration.underline
              ),
            ),
          ),
          Text(
            DateTimeUtil.getWeekDayCn(endDate),
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget getReserveView() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Row(
              children: [
                Text(
                  travel.orderBeforeDays! != 0 ? 
                  "提前${travel.orderBeforeDays!}天预定" : 
                  "当天可预定",
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(width: 20),
                Text(
                  travel.isCancelAllowed == 1 ? '可取消' : '不可取消',
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          travel.suitList!.isEmpty ? 
          const Text(
            '当前无套餐',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ): 
          Column(
            children: [
              getSuitViews(),
              if (travel.suitList!.length > 2)
              TextButton(
                onPressed: () {
                  setState(() {
                    showMoreSuits = !showMoreSuits;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      showMoreSuits ? '收起' : '更多',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    Icon(
                      showMoreSuits ? 
                      Icons.keyboard_arrow_up : 
                      Icons.keyboard_arrow_down,
                      color: Colors.grey,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget getSuitViews() {
    int suitsToShow = travel.suitList?.length ?? 0;
    if(!showMoreSuits){
      if(suitsToShow > 2){
        suitsToShow = 2;
      }
    }

    List<TravelSuit>? suitList = travel.suitList;
    if(suitList == null || suitList.isEmpty){
      return const SizedBox();
    }

    List<Widget> widgets = [];
    for(TravelSuit suit in suitList){
      widgets.add(
        InkWell(
          onTap: () async{
            List<TravelSuitPrice>? priceList = await TravelApi().suitPrices(suitId: suit.id!, startDate: startDate, endDate: endDate);
            if(priceList == null){
              return;
            }
            if(mounted && context.mounted){
              DialogUtil.loginRedirectConfirm(
                context, 
                callback: (isLogined){
                  if(isLogined){
                    if(mounted && context.mounted){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                        return TravelDetailGoPage(
                          travel: travel,
                          startDate: startDate,
                          endDate: endDate,
                          selectedSuit: suit,
                          travelSuitPrice: priceList.isEmpty ? null : priceList.first,
                        );
                      }));
                    }
                  }
                }
              );
            }
          },
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: ThemeUtil.backgroundColor,
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suit.name ?? '',
                  style: const TextStyle(
                    color: ThemeUtil.foregroundColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  suit.description!,
                  style: TextStyle(color: Colors.black.withOpacity(0.5)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [    
                    Text(
                      suit.dayPrice != null ? 
                      '￥${StringUtil.getPriceStr(suit.dayPrice)}起' :
                      '当日无库存',
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 20
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ],
            ),
          )
        )
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget getQuestionWidget() {
    if (travel.id == null) {
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 0, 0, 8),
            child: Text(
              '问答',
              style: TextStyle(
                color: ThemeUtil.foregroundColor,
                fontWeight: FontWeight.bold,
                fontSize: 18
              ),
            ),
          ),
          ProductQuestionShowWidget(
            productId: travel.id!,
            productType: ProductType.travel,
            ownnerId: travel.userId,
            title: travel.name,
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
          )
        ],
      ),
    );
  }

  Future<void> showDateDlg() async {
    final config = DateChooseConfig(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width,
      firstDate: DateTime.now()
        .subtract(
          Duration(
            hours: DateTime.now().hour,
            minutes: DateTime.now().minute,
            seconds: DateTime.now().second,
            milliseconds: DateTime.now().millisecond,
            microseconds: DateTime.now().microsecond,
          ),
        )
        .add(Duration(days: travel.orderBeforeDays ?? 0)),
      lastDate: firstDate.add(const Duration(days: 90)),
      chooseMode: DateChooseMode.single,
    );

    List<DateTime>? results = await DateChooseUtil.chooseDate(context, config);
    if (results != null /*&& results.length > 1*/) {
      startDate = results.first;
      endDate = startDate.add(Duration(days: travel.nightNum ?? 0));
      showCalendar = true;
      if (mounted && context.mounted) {
        setState(() {});
      }
    }
  }

  Widget getCommentWidget() {
    if (travel.id == null) {
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 0, 0, 8),
            child: Text(
              '评论',
              style: TextStyle(
                color: ThemeUtil.foregroundColor,
                fontWeight: FontWeight.bold,
                fontSize: 18
              ),
            ),
          ),
          CommentShowWidget(
            productId: travel.id!,
            type: ProductType.travel,
            ownnerId: travel.userId,
            productName: travel.name,
            onMenuShow: (controller){
              menuController?.hideMenu();
              menuController = controller;
            },
            onTipoffComment: (comment){
              if(comment.id == null){
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
                        return TipOffWidget(targetId: comment.id!, productType: ProductType.productComment,);
                      }
                    );
                  }
                }
              });
            },
            onTipoffCommentSub: (commentSub){
              if(commentSub.id == null){
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
                        return TipOffWidget(targetId: commentSub.id!, productType: ProductType.productCommentSub,);
                      }
                    );
                  }
                }
              });
            },
          )
        ],
      ),
    );
  }

  Future loadTravel() async {
    if(travel.id == null){
      return;
    }
    return HttpTravel.detail(travel.id!, (isSuccess, data, msg, code) {
      if (isSuccess) {
        travel = Travel.fromJson(data);
        if(mounted && context.mounted){
          setState(() {});
        }
      }
    });
  }

  Future getSuits() async {
    if(travel.id == null){
      return;
    }
    return HttpTravel.suits(travel.id!, (isSuccess, data, msg, code) {
      if (isSuccess) {
        var list = data as List<dynamic>;
        for (var i = 0; i < list.length; i++) {
          var suit = TravelSuitModel.fromJson(list[i]);
          travelSuitList.add(suit);
        }
        if(mounted && context.mounted){
          setState(() {});
        }
      }
    });
  }

  Future showDateDlg11(TravelSuitModel suit) async {
    int suitId = suit.id;
    var priceDayMap = priceDeepMap[suitId];
    TravelSuitPriceModel priceModel = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (buildContext) {
        return StatefulBuilder(builder: (context2, setState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
              color: Colors.white,
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 40,
                  child: Stack(
                    children: [
                      const Center(
                        child: Text(
                          '日期选择',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        )
                      ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(buildContext);
                          },
                          child: const Icon(Icons.close)
                        )
                      )
                    ],
                  )
                ),
                Expanded(
                  child: PriceCalendar.build(
                    monthNum: 8,
                    onDayView: (DateTime day) {
                      String dayStr = DateTimeUtil.toYMD(day);
                      TravelSuitPriceModel? priceModel;
                      if (priceDayMap != null && priceDayMap.containsKey(dayStr)) {
                        priceModel = priceDayMap[dayStr];
                      }
                      return Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                        child: priceModel != null ? 
                        TextButton(
                          onPressed: () {
                            Navigator.pop(buildContext, priceModel);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                day.day.toString(),
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.5)
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                '￥${StringUtil.getPriceStr(priceModel.price)!}',
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 11
                                ),
                              )
                            ]
                          )
                        ): 
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(day.day.toString()),
                            const SizedBox(
                              height: 4,
                            ),
                            const Text('')
                          ]
                        )
                      );
                    }
                  )
                )
              ],
            ),
          );
        });
      }
    );
    if (context.mounted) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TravelBookPage(travel, suit, priceModel),
      ));
    }
  }
}

Future<TravelSuitPriceModel?> getTravelSuitPrice(/*int travelId, */int travelSuitId, DateTime day) async {
  final formattedDate = DateFormat('yyyy-MM-dd').format(day);
  const String url = '/travel/travelSuitPriceModel';
  final response = await HttpTool.get(
    url,
    {
      //'travelId': travelId,
      'travelSuitId': travelSuitId,
      'day': formattedDate,
    },
    (response) {
      final dynamic jsonData = response.data['data'];
      if (jsonData is List) {
        if (jsonData.isNotEmpty) {
          final dynamic firstItem = jsonData[0];
          return TravelSuitPriceModel.fromJson(firstItem);
        } else {
          return null;
        }
      } else {
        return TravelSuitPriceModel.fromJson(jsonData);
      }
    },
  );
  return response;
}
