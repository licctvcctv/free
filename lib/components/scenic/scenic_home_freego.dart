
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/chat_neo/chat_common.dart';
import 'package:freego_flutter/components/chat_neo/chat_room.dart';
import 'package:freego_flutter/components/chat_neo/chat_util.dart';
import 'package:freego_flutter/components/comment/comment_page.dart';
import 'package:freego_flutter/components/comment/comment_widget.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/components/product_neo/product_source.dart';
import 'package:freego_flutter/components/product_question/product_question_widget.dart';
import 'package:freego_flutter/components/scenic/api/panhe_scenic_api.dart';
import 'package:freego_flutter/components/scenic/scenic_buy_freego.dart';
import 'package:freego_flutter/components/scenic/scenic_common.dart';
import 'package:freego_flutter/components/scenic/scenic_desc_freego.dart';
import 'package:freego_flutter/components/scenic/scenic_notice_freego.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/common_map_show.dart';
import 'package:freego_flutter/components/view/menu_action.dart';
import 'package:freego_flutter/components/view/navigated_view.dart';
import 'package:freego_flutter/components/view/pics_swiper.dart';
import 'package:freego_flutter/components/view/tipoff.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/util/dialog_util.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';

class ScenicHomePage extends StatelessWidget{
  final Scenic scenic;
  const ScenicHomePage(this.scenic, {super.key});

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
      body: ScenicHomeWidget(scenic),
    );
  }

}

class ScenicHomeWidget extends StatefulWidget{
  final Scenic scenic;
  const ScenicHomeWidget(this.scenic, {super.key});

  @override
  State<StatefulWidget> createState() {
    return ScenicHomeState();
  }

}

class ScenicHomeState extends State<ScenicHomeWidget> with SingleTickerProviderStateMixin{

  NavigatedController naviController = NavigatedController();

  AMapFlutterLocation amapLocation = AMapFlutterLocation();
  double? distance;

  ScrollController scrollController = ScrollController();

  late AnimationController rightMenuAnim;
  bool rightMenuShow = false;
  static const int RIGHT_MENU_ANIM_MILLI_SECONDS = 150;
  static const double RIGHT_MENU_WIDTH = 100;
  static const double RIGHT_MENU_ITEM_HEIGHT = 40;

  Widget svgQuestion = SvgPicture.asset('svg/question.svg', color: const Color.fromRGBO(178, 232, 89, 1),);

  CommonMenuController? menuController;

  @override
  void initState(){
    super.initState();
    startGetDistance();
    rightMenuAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: RIGHT_MENU_ANIM_MILLI_SECONDS));
  }

  @override
  void dispose(){
    amapLocation.stopLocation();
    amapLocation.destroy();
    scrollController.dispose();
    rightMenuAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Scenic scenic = widget.scenic;
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
            ListView(
              padding: EdgeInsets.zero,
              physics: const ClampingScrollPhysics(),
              children: [
                getPicWidget(),
                getInfoWidget(),
                getContackWidget(),
                getTicketsWidget(),
                getQuestionWidget(),
                getCommentWidget()
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
                      maxHeight: rightMenuAnim.value * RIGHT_MENU_ITEM_HEIGHT * 2
                    ),
                    child: Wrap(
                      clipBehavior: Clip.hardEdge,
                      children: [
                        Container(
                          width: RIGHT_MENU_WIDTH,
                          decoration: const BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(12)
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 2
                              )
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
                                onPressed: (){
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                    return ScenicDescPage(scenic);
                                  }));
                                  rightMenuAnim.reverse();
                                  rightMenuShow = false;
                                  setState(() {
                                  });
                                },
                                child: Container(
                                  width: RIGHT_MENU_WIDTH,
                                  height: RIGHT_MENU_ITEM_HEIGHT,
                                  alignment: Alignment.center,
                                  child: const Text('景点介绍', style: TextStyle(color: Colors.white),),
                                ),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap
                                ),
                                onPressed: (){
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                    return ScenicNoticePage(scenic);
                                  }));
                                  rightMenuAnim.reverse();
                                  rightMenuShow = false;
                                  setState(() {
                                  });
                                },
                                child: Container(
                                  width: RIGHT_MENU_WIDTH,
                                  height: RIGHT_MENU_ITEM_HEIGHT,
                                  alignment: Alignment.center,
                                  child: const Text('预订须知', style: TextStyle(color: Colors.white),),
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

  Widget getCommentWidget(){
    Scenic scenic = widget.scenic;
    if(scenic.id == null){
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
          CommentShowWidget(
            productId: scenic.id!, 
            type: ProductType.scenic,
            ownnerId: scenic.userId,
            productName: scenic.name,
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

  Widget getQuestionWidget(){
    Scenic scenic = widget.scenic;
    if(scenic.id == null){
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
            productId: scenic.id!, 
            productType: ProductType.scenic,
            ownnerId: scenic.userId,
            title: scenic.name,
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

  Widget getTicketsWidget(){
    Scenic scenic = widget.scenic;
    List<ScenicTicket>? ticketList = scenic.ticketList;
    if(ticketList == null || ticketList.isEmpty){
      return const SizedBox();
    }
    List<Widget> widgets = [];
    for(int i = 0; i < ticketList.length; ++i){
      ScenicTicket ticket = ticketList[i];
      widgets.add(
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: ThemeUtil.backgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(4))
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ticket.name ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
              const SizedBox(height: 10,),
              if(ticket.advanceDay != null && ticket.advanceDay! <= 0)
              const Text('可立即预订', style: TextStyle(color: Colors.grey),),
              if(ticket.advanceDay != null && ticket.advanceTime == null)
              Text('需提前${ticket.advanceDay}天预订', style: const TextStyle(color: Colors.grey),),
              if(ticket.advanceDay != null && ticket.advanceTime != null)
              Text('需提前${ticket.advanceDay}天在${ticket.advanceTime}前预订', style: const TextStyle(color: Colors.grey),),
              ticket.minBuyCount != null && ticket.minBuyCount! > 1 ?
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text('${ticket.minBuyCount}张起订', style: const TextStyle(color: Colors.grey),),
              ) : const SizedBox(),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('￥${StringUtil.getPriceStr(ticket.settlePrice)}', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () async{
                      ProductSource? source;
                      if(scenic.source != null){
                        source = ProductSourceExt.getSource(scenic.source!);
                      }
                      if(source == null){
                        DialogUtil.loginRedirectConfirm(context, callback: (isLogined){
                          if(isLogined){
                            Navigator.of(context).push(MaterialPageRoute(builder: (context){
                              return ScenicBuyPage(scenic: scenic, ticket: ticket);
                            }));
                          }
                        });
                        return;
                      }
                      switch(source){
                        case ProductSource.local:
                          if(ticket.id == null){
                            return;
                          }
                          if(mounted && context.mounted){
                            DialogUtil.loginRedirectConfirm(context, callback: (isLogiend){
                              if(isLogiend){
                                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                  return ScenicBuyPage(scenic: scenic, ticket: ticket);
                                }));
                              }
                            });
                          }
                          break;
                        case ProductSource.panhe:
                          if(ticket.outerId == null){
                            return;
                          }
                          ScenicTicket? theTicket = await PanheScenicApi().ticket(outerId: ticket.outerId!);
                          if(theTicket == null){
                            return;
                          }
                          if(mounted && context.mounted){
                            DialogUtil.loginRedirectConfirm(context, callback: (isLogined){
                              if(isLogined){
                                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                  return ScenicBuyPage(scenic: scenic, ticket: theTicket);
                                }));
                              }
                            });
                          }
                          return;
                        default:
                      }
                    }, 
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(178, 232, 89, 1),
                        borderRadius: BorderRadius.all(Radius.circular(8))
                      ),
                      padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
                      child: const Text('预订', style: TextStyle(color: Colors.white),),
                    )
                  )
                ],
              )
            ],
          )
        )
      );
      if(i < ticketList.length - 1){
        widgets.add(const SizedBox(height: 16,));
      }
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16))
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
    );
  }

  Widget getContackWidget(){
    Scenic scenic = widget.scenic;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color.fromRGBO(178, 232, 89, 1), Color.fromRGBO(241, 248, 233, 1)]
                ),
                borderRadius: BorderRadius.all(Radius.circular(12))
              ),
              padding: const EdgeInsets.fromLTRB(10, 14, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('位置：${scenic.address}', style: const TextStyle(color: ThemeUtil.foregroundColor),),
                  const SizedBox(height: 10,),
                  Text('距您：${distance == null? '未知' : distance!.toStringAsFixed(1)}千米', style: const TextStyle(color: ThemeUtil.foregroundColor),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: (){
                          if(scenic.latitude == null || scenic.longitude == null){
                            return;
                          }
                          Navigator.of(context).push(MaterialPageRoute(builder: (context){
                            return CommonMapShowPage(address: scenic.address ?? '', latitude: scenic.latitude!, longitude: scenic.longitude!);
                          }));
                        },
                        child: Row(
                          children: const [
                            Icon(Icons.location_on_rounded, color: Colors.lightGreen, size: 26,),
                            Text('地图/周边', style: TextStyle(fontSize: 14, color: Colors.lightGreen),)
                          ],
                        ),
                      )
                    ],
                  )
                ],
              )
            ),
          ),
          const SizedBox(width: 10,),
          if(scenic.userId != null)
          InkWell(
            onTap: () async{
              if(scenic.userId == null){
                return;
              }
              DialogUtil.loginRedirectConfirm(context, callback: (isLogined) async{
                if(isLogined){
                  ImSingleRoom? room = await ChatUtilSingle.enterRoom(scenic.userId!);
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

  Widget getInfoWidget(){
    Scenic scenic = widget.scenic;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(scenic.name ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 20),),
                    const SizedBox(width: 10,),
                    scenic.stars == null ?
                    const SizedBox() :
                    Text(
                      scenic.stars! == 5 ? '5A级景区' :
                      scenic.stars! == 4 ? '4A级景区' :
                      scenic.stars! == 3 ? '3A级景区' :
                      scenic.stars! == 2 ? '热门景区' :
                      '网红景区',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context){
                    return ScenicDescPage(scenic);
                  }));
                },
                child: Row(
                  children: const [
                    Text('详情', style: TextStyle(color: Color.fromRGBO(154, 208, 65, 1)),),
                    Icon(Icons.keyboard_arrow_right_rounded, size: 30, color: Color.fromRGBO(154, 208, 65, 1), weight: 1000,)
                  ],
                ),
              )
            ]
          ),
          const Divider(),
          Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                child: Container(
                  color: const Color.fromRGBO(178, 232, 89, 1),
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                  child: Text('${((scenic.score ?? 100) / 10.0).toStringAsFixed(1)}分', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),),
                ),
              ),
              const Expanded(
                child: SizedBox(),
              ),
              if(scenic.id != null)
              InkWell(
                onTap: (){
                  if(scenic.id == null){
                    ToastUtil.error('数据错误');
                    return;
                  }
                  Navigator.of(context).push(MaterialPageRoute(builder: (context){
                    return CommentPage(productId: scenic.id!, type: ProductType.scenic);
                  }));
                },
                child: Row(
                  children: [
                    Text('${scenic.commentNum ?? 0}条评论', style: const TextStyle(color: Color.fromRGBO(154, 208, 65, 1)),),
                    const Icon(Icons.keyboard_arrow_right_rounded, size: 30, color: Color.fromRGBO(154, 208, 65, 1), weight: 1000,)
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
    Scenic scenic = widget.scenic;
    List<String> picList = [];
    if(scenic.pics != null){
      picList = scenic.pics!.split(',');
      for(int i = 0; i < picList.length; ++i){
        if(!picList[i].startsWith('http')){
          picList[i] = getFullUrl(picList[i]);
        }
      }
    }
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12))
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          picList.isEmpty ?
          const SizedBox() :
          PicsSwiper(
            urlBuilder: (idx){
              return picList[idx];
            }, 
            count: picList.length
          ),
          Align(
            alignment: Alignment.topCenter,
            child: CommonHeader(
              backgroundColor: Colors.transparent,
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
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.all(Radius.circular(4))
                  ),
                  child: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 32,),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void startGetDistance(){
    Scenic scenic = widget.scenic;
    if(scenic.latitude == null || scenic.longitude == null){
      return;
    }
    LatLng scenicPos = LatLng(scenic.latitude!, scenic.longitude!);
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
        double dist = AMapTools.distanceBetween(userPos, scenicPos);
        dist /= 1000;
        distance = dist;
        setState(() {
        });
      }
    });
    amapLocation.startLocation();
  }
}
