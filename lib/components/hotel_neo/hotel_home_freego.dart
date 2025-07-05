
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/chat_neo/chat_common.dart';
import 'package:freego_flutter/components/chat_neo/chat_room.dart';
import 'package:freego_flutter/components/chat_neo/chat_util.dart';
import 'package:freego_flutter/components/hotel_neo/api/hotel_api.dart';
import 'package:freego_flutter/components/hotel_neo/comment/comment_hotel_page.dart';
import 'package:freego_flutter/components/hotel_neo/comment/comment_hotel_widget.dart';
import 'package:freego_flutter/components/hotel_neo/hotel_common.dart';
import 'package:freego_flutter/components/hotel_neo/hotel_desc_freego.dart';
import 'package:freego_flutter/components/hotel_neo/hotel_reserve_freego.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/components/product_question/product_question_widget.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/common_map_show.dart';
import 'package:freego_flutter/components/view/date_choose_view.dart';
import 'package:freego_flutter/components/view/image_viewer.dart';
import 'package:freego_flutter/components/view/menu_action.dart';
import 'package:freego_flutter/components/view/navigated_view.dart';
import 'package:freego_flutter/components/view/pics_swiper.dart';
import 'package:freego_flutter/components/view/tipoff.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/util/date_choose_util.dart';
import 'package:freego_flutter/util/date_time_util.dart';
import 'package:freego_flutter/util/dialog_util.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:intl/intl.dart';

class HotelHomePage extends StatefulWidget{
  final Hotel hotel;
  final DateTime? startDate;
  final DateTime? endDate;
  const HotelHomePage(this.hotel, {this.startDate, this.endDate, super.key});

  @override
  State<StatefulWidget> createState() {
    return HotelHomePageState();
  }
  
}

class HotelHomePageState extends State<HotelHomePage>{
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
      body: HotelHomeWidget(widget.hotel, startDate: widget.startDate, endDate: widget.endDate,),
    );
  }

}

class HotelHomeWidget extends StatefulWidget{
  final Hotel hotel;
  final DateTime? startDate;
  final DateTime? endDate;
  const HotelHomeWidget(this.hotel, {this.startDate, this.endDate, super.key});

  @override
  State<StatefulWidget> createState() {
    return HotelHomeState();
  }

}

class HotelHomeState extends State<HotelHomeWidget> with SingleTickerProviderStateMixin{

  NavigatedController naviController = NavigatedController();

  AMapFlutterLocation amapLocation = AMapFlutterLocation();
  double? distance;

  late DateTime firstDate;
  late DateTime lastDate;

  late DateTime startDate;
  late DateTime endDate;
  bool chamberShortMode = true;

  late AnimationController rightMenuAnim;
  bool rightMenuShow = false;
  static const int RIGHT_MENU_ANIM_MILLI_SECONDS = 150;
  static const double RIGHT_MENU_WIDTH = 100;
  static const double RIGHT_MENU_ITEM_HEIGHT = 40;

  Widget svgQuestion = SvgPicture.asset('svg/question.svg', color: Colors.lightBlue,);

  CommonMenuController? menuController;

  @override
  void initState(){
    super.initState();
    firstDate = DateTime.now();
    firstDate = DateTime(firstDate.year, firstDate.month, firstDate.day);
    lastDate = firstDate.add(const Duration(days: 90));
    if(widget.startDate != null){
      startDate = widget.startDate!;
    }
    else{
      startDate = DateTime(firstDate.year, firstDate.month, firstDate.day);
    }
    if(widget.endDate != null){
      endDate = widget.endDate!;
    }
    else{
      endDate = startDate.add(const Duration(days: 1));
    }
    startGetDistance();

    rightMenuAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: RIGHT_MENU_ANIM_MILLI_SECONDS));
  }

  @override
  void dispose(){
    amapLocation.stopLocation();
    amapLocation.destroy();
    rightMenuAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Hotel hotel = widget.hotel;
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
                      getPicWidget(),
                      getInfoWidget(),
                      getContackWidget(),
                      getDateChooseWidget(),
                      getChamberWidget(),
                      getCommentWidget(),
                      getQuestionWidget()
                    ]
                  ),
                ),
              ],
            ),
            rightMenuShow ?
            Positioned.fill(
              child: InkWell(
                onTap: (){
                  rightMenuShow = false;
                  rightMenuAnim.reverse();
                  setState(() {
                  });
                },
              ),
            ) : const SizedBox(),
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
                            Navigator.of(context).push(MaterialPageRoute(builder: (context){
                              return HotelDescPage(hotel);
                            }));
                            rightMenuAnim.reverse();
                            rightMenuShow = false;
                            setState(() {
                            });
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
                            child: const Text('酒店介绍', style: TextStyle(color: Colors.white),),
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

  Widget getQuestionWidget(){
    Hotel hotel = widget.hotel;
    if(hotel.id == null){
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 0, 0, 8),
            child: Text('问答', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
          ),
          ProductQuestionShowWidget(
            productId: hotel.id!, 
            productType: ProductType.hotel,
            ownnerId: hotel.userId,
            title: hotel.name,
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

  Widget getCommentWidget(){
    Hotel hotel = widget.hotel;
    if(hotel.id == null){
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 0, 0, 8),
            child: Text('评论', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
          ),
          CommentHotelShowWidget(
            hotelId: hotel.id!,
            ownnerId: hotel.userId,
            hotelName: hotel.name,
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

  Widget getChamberWidget(){
    Hotel hotel = widget.hotel;
    bool hasChamber = false;
    for(HotelChamber chamber in hotel.chamberList ?? []){
      for(HotelChamberPlan plan in chamber.planList ?? []){
        hasChamber = true;
        break;
      }
      if(hasChamber){
        break;
      }
    }

    if(!hasChamber){
      return const SizedBox();
    }

    List<Widget> chamberViews = [];
    for(int i = 0; i < (chamberShortMode ? 1 : hotel.chamberList!.length); ++i){
      HotelChamber chamber = hotel.chamberList![i];
      if(chamber.planList == null || chamber.planList!.isEmpty){
        continue;
      }
      String? pic;
      if(chamber.pictureList != null && chamber.pictureList!.isNotEmpty){
        pic = chamber.pictureList!.first.path;
      }
      if(pic != null){
        pic = getFullUrl(pic);
      }
      List<Widget> planViews = [];
      
      for(HotelChamberPlan plan in chamber.planList!){
        bool hasStock = plan.priceList != null && plan.priceList!.isNotEmpty;
        for(HotelChamberPlanPrice priceObj in plan.priceList ?? []){
          if(priceObj.stock == null || priceObj.stock! <= 0){
            hasStock = false;
            break;
          }
        }
        int? price;
        if(hasStock && plan.priceList != null && plan.priceList!.isNotEmpty){
          price = plan.priceList!.first.price;
        }
        planViews.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              pic != null ?
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: InkWell(
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context){
                        return ImageViewer(pic!);
                      }));
                    },
                    child: Image.network(
                      pic, 
                      fit: BoxFit.cover,
                      errorBuilder:(context, error, stackTrace) {
                        return Container(
                          color: ThemeUtil.backgroundColor,
                          alignment: Alignment.center,
                          child: const Icon(Icons.error_outline, color: ThemeUtil.foregroundColor,),
                        );
                      },
                    ),
                  ),
                ),
              ): const SizedBox(),
              const SizedBox(width: 10,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plan.name ?? '', style: const TextStyle(),),
                    const SizedBox(height: 4,),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        chamber.bedType != null ?
                        Text(chamber.bedType ?? '', style: const TextStyle(color: Colors.grey)) : const SizedBox(),
                        chamber.area != null ?
                        Text('${chamber.area}平米', style: const TextStyle(color: Colors.grey),) : const SizedBox(),
                        chamber.capacity != null ?
                        Text('可住${chamber.capacity}人',style: const TextStyle(color: Colors.grey),) : const SizedBox()
                      ],
                    ),
                    const SizedBox(height: 4,),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        plan.breakfast != null ?
                        Text(plan.breakfast!, style: const TextStyle(color: Colors.grey),) : const SizedBox(),
                        plan.cancelRuleName != null ?
                        Text(plan.cancelRuleName!, style: const TextStyle(color: Colors.grey),) : const SizedBox()
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        price != null ?
                        Container(
                          padding: const EdgeInsets.only(right: 10),
                          child: Text('￥${StringUtil.getPriceStr(price)}', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16),),
                        ) : const SizedBox(),
                        hasStock ?
                        TextButton(
                          onPressed: (){
                            DialogUtil.loginRedirectConfirm(context, callback: (isLogined){
                              if(isLogined){
                                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                  return HotelReservePage(hotel: hotel, chamber: chamber, plan: plan, startDate: startDate, endDate: endDate,);
                                }));
                              }
                            });
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: ThemeUtil.buttonColor,
                              borderRadius: BorderRadius.all(Radius.circular(8))
                            ),
                            padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
                            child: const Text('预订', style: TextStyle(color: Colors.white),),
                          ),
                        ) :
                        Container(
                          decoration: const BoxDecoration(
                            color: ThemeUtil.backgroundColor,
                            borderRadius: BorderRadius.all(Radius.circular(8))
                          ),
                          padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
                          child: const Text('无库存', style: TextStyle(color: Colors.white),),
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          )
        );
        planViews.add(const Divider());
      }
      chamberViews.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(chamber.name ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
            const SizedBox(height: 10,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: planViews,
            )
          ],
        )
      );
    }
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(16))
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: chamberViews
          ),
        ),
        chamberShortMode ?
        TextButton(
          onPressed: (){
            chamberShortMode = false;
            setState(() {
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('更多', style: TextStyle(color: Colors.grey, fontSize: 14),),
                Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 18,)
              ]
            ),
          ),
        ) : const SizedBox(),
        const SizedBox(height: 16,)
      ],
    );
  }

  Future reloadPrice() async{
    Hotel hotel = widget.hotel;
    if(hotel.id == null && (hotel.outerId == null || hotel.source == null)){
      ToastUtil.error('数据错误');
      return;
    }
    List<HotelChamber>? tmpList = await HotelApi().chamber(id: hotel.id, outerId: hotel.outerId, source: hotel.source, startDate: startDate, endDate: endDate,
      fail: (response){
        String? message = response.data['message'];
        ToastUtil.warn(message ?? '好像除了点小问题');
      });
    tmpList ??= [];
    widget.hotel.chamberList = tmpList;
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }

  Widget getDateChooseWidget(){
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
            onTap: () async{
              final config = DateChooseConfig(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width,
                firstDate: firstDate,
                lastDate: lastDate,
                chooseMode: DateChooseMode.range
              );
              List<DateTime>? results = await DateChooseUtil.chooseDate(context, config);
              if(results != null && results.length > 1){
                startDate = results.first;
                endDate = results[1];
                if(mounted && context.mounted){
                  setState(() {
                  });
                }
                reloadPrice();
              }
            },
            child: Text(DateFormat('yyyy-MM-dd').format(startDate), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.underline),),
          ),
          Text(DateTimeUtil.getWeekDayCn(startDate), style: const TextStyle(color: Colors.grey),),
          const Text(' 至 ', style: TextStyle(color: Colors.grey),),
          InkWell(
            onTap: () async{
              final config = DateChooseConfig(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width,
                firstDate: firstDate,
                lastDate: lastDate,
                chooseMode: DateChooseMode.range
              );
              List<DateTime>? results = await DateChooseUtil.chooseDate(context, config);
              if(results != null && results.length > 1){
                startDate = results.first;
                endDate = results[1];
                if(mounted && context.mounted){
                  setState(() {
                  });
                }
                reloadPrice();
              }
            },
            child: Text(DateFormat('yyyy-MM-dd').format(endDate), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.underline),),
          ),
          Text(DateTimeUtil.getWeekDayCn(endDate), style: const TextStyle(color: Colors.grey),),        
        ],
      ),
    );
  }

  Widget getContackWidget(){
    Hotel hotel = widget.hotel;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color.fromRGBO(129, 212, 250, 1), Color.fromRGBO(182, 232, 255, 1)]
                ),
                borderRadius: BorderRadius.all(Radius.circular(12))
              ),
              padding: const EdgeInsets.fromLTRB(10, 14, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('位置：${hotel.address}', style: const TextStyle(color: ThemeUtil.foregroundColor),),
                  const SizedBox(height: 10,),
                  Text('距您：${distance == null ? '未知' : distance!.toStringAsFixed(1)}千米', style: const TextStyle(color: ThemeUtil.foregroundColor),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: (){
                          if(hotel.latitude == null || hotel.longitude == null){
                            return;
                          }
                          Navigator.of(context).push(MaterialPageRoute(builder: (context){
                            return CommonMapShowPage(address: hotel.address ?? '', latitude: hotel.latitude!, longitude: hotel.longitude!);
                          }));
                        },
                        child: Row(
                          children: const [
                            Icon(Icons.location_on_rounded, color: Colors.lightBlue, size: 26,),
                            Text('地图/周边', style: TextStyle(fontSize: 14, color: Colors.lightBlue),)
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          if(hotel.userId != null)
          const SizedBox(width: 10,),
          if(hotel.userId != null)
          InkWell(
            onTap: () async{
              if(hotel.userId == null){
                return;
              }
              DialogUtil.loginRedirectConfirm(context, callback: (isLogined) async{
                if(isLogined){
                  ImSingleRoom? room = await ChatUtilSingle.enterRoom(hotel.userId!);
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
          )
        ],
      ),
    );
  }

  Widget getInfoWidget(){
    Hotel hotel = widget.hotel;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    Text(hotel.name ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 20),),
                    hotel.stars == null ?
                    const SizedBox() :
                    Text(
                      hotel.stars! >= 4 ? '高档型' :
                      hotel.stars! >= 2 ? '舒适型' :
                      '经济型',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: InkWell(
                  onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context){
                      return HotelDescPage(hotel);
                    }));
                  },
                  child: Row(
                    children: const [
                      Text('详情/设施', style: TextStyle(color: Colors.lightBlue),),
                      Icon(Icons.keyboard_arrow_right_rounded, size: 30, color: Colors.lightBlue, weight: 1000,)
                    ],
                  ),
                ),
              )
            ],
          ),
          const Divider(),
          Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                child: Container(
                  color: Colors.lightBlue,
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                  child: Text('${((hotel.score ?? 100) / 10.0).toStringAsFixed(1)}分', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),),
                ),
              ),
              const Expanded(
                child: SizedBox(),
              ),
              InkWell(
                onTap: (){
                  if(hotel.id == null){
                    ToastUtil.error('数据错误');
                    return;
                  }
                  Navigator.of(context).push(MaterialPageRoute(builder: (context){
                    return CommentHotelPage(hotel.id!, hotelName: hotel.name, creatorId: hotel.userId,);
                  }));
                },
                child: Row(
                  children: [
                    Text('${hotel.commentNum ?? 0}条评论', style: const TextStyle(color: Colors.lightBlue),),
                    const Icon(Icons.keyboard_arrow_right_rounded, size: 30, color: Colors.lightBlue, weight: 1000,)
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget getPicWidget(){
    Hotel hotel = widget.hotel;
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12))
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          hotel.pictureList == null || hotel.pictureList!.isEmpty ?
          const SizedBox() :
          PicsSwiper(
            urlBuilder: (idx){
              String? url = hotel.pictureList![idx].path;
              if(url != null){
                url = getFullUrl(url);
              }
              return url ?? '';
            }, 
            count: hotel.pictureList!.length
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
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white,),
                ),
              ),
              right: TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap
                ),
                onPressed: (){
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
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.all(Radius.circular(4))
                  ),
                  width: 48,
                  height: 48,
                  child: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 32,),
                ),
              ),
              backgroundColor: Colors.transparent,
            ),
          )
        ],
      ),
    );
  }

  void startGetDistance(){
    Hotel hotel = widget.hotel;
    if(hotel.latitude == null || hotel.longitude == null){
      return;
    }
    LatLng hotelPos = LatLng(hotel.latitude!, hotel.longitude!);
    amapLocation.onLocationChanged().listen((event) {
      var latitude = event['latitude'];
      if(latitude is String){
        latitude = double.tryParse(latitude);
      }
      var longitude = event['longitude'];
      if(longitude is String){
        longitude = double.tryParse(longitude);
      }
      if(latitude is double && longitude is double){
        LatLng userPos = LatLng(latitude, longitude);
        double dist = AMapTools.distanceBetween(userPos, hotelPos);
        dist /= 1000;
        distance = dist;
        setState(() {
        });
      }
    });
    amapLocation.startLocation();
  }
}
