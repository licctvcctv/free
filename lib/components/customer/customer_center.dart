
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/circle_neo/circle_common.dart';
import 'package:freego_flutter/components/circle_neo/circle_http.dart';
import 'package:freego_flutter/components/circle_neo/detail/circle_activity.dart';
import 'package:freego_flutter/components/circle_neo/detail/circle_article.dart';
import 'package:freego_flutter/components/circle_neo/detail/circle_question.dart';
import 'package:freego_flutter/components/circle_neo/detail/circle_shop.dart';
import 'package:freego_flutter/components/friend_neo/friend_apply.dart';
import 'package:freego_flutter/components/friend_neo/friend_common.dart';
import 'package:freego_flutter/components/guide_neo/guide_http.dart';
import 'package:freego_flutter/components/guide_neo/guide_map_show.dart';
import 'package:freego_flutter/components/guide_neo/guide_model.dart';
import 'package:freego_flutter/components/user/user_common.dart';
import 'package:freego_flutter/components/user_block/event/user_block_user_facade.dart';
import 'package:freego_flutter/components/video/video_home.dart';
import 'package:freego_flutter/components/video/video_api.dart';
import 'package:freego_flutter/components/video/video_model.dart';
import 'package:freego_flutter/components/view/notify_empty.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/http/http_customer.dart';
import 'package:freego_flutter/model/user_fo.dart';
import 'package:freego_flutter/util/context_util.dart';
import 'package:freego_flutter/util/date_time_util.dart';
import 'package:freego_flutter/util/dialog_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';

final myCircleListPrvd = StateProvider<List<Circle>>((ref) => []);

class CustomerCenterPage extends StatelessWidget{

  final int userId;
  const CustomerCenterPage(this.userId, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 10,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: ThemeUtil.statusBarThemeLight,
      ),
      extendBodyBehindAppBar: true,
      body: CustomerCenterWidget(userId)
    );
  }
}


class CustomerCenterWidget extends ConsumerStatefulWidget {
  final int userId;
  const CustomerCenterWidget(this.userId, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return CustomerCenterState();
  }
}

class MenuItem{
  final String text;
  final IconData icon;
  final Function(BuildContext context)? onClick;

  const MenuItem({required this.text, required this.icon, required this.onClick});
}

class CustomerCenterState extends ConsumerState<CustomerCenterWidget> with SingleTickerProviderStateMixin{

  int  menuIndex = 0; //先中的菜单，0为攻略，1为视频，2为圈子
  UserFoModel userFo = UserFoModel(0);
  late int userId;
  
  final EdgeInsets menuItemPadding = const EdgeInsets.fromLTRB(20, 6, 20, 6);
  final RoundedRectangleBorder menuItemShap = const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)));
  final Color menuItemOnColor = const Color.fromRGBO(185, 218, 250, 1);

  List<Guide>? guideList;
  List<VideoModel>? videoList;
  List<Circle>? circleList;

  static double BOTTOM_INDICATOR_SIZE = 40;
  ScrollController scrollController = ScrollController();
  bool onScrollOperation = false;
  Timer? indicatorTimer;

  static const double MAKE_FRIEND_SIZE = 28;
  Widget svgMakeFriend = SvgPicture.asset('svg/make_friend.svg');

  List<MenuItem> menuItems = [];
  static const double MENU_ITEM_HEIGHT = 40;
  static const double MENU_ITEM_WIDTH = 100;
  late AnimationController _rightMenuController;
  bool _isShowRightMenuWill = false;
  bool _isShowRightMenu = false;

  @override
  void dispose(){
    indicatorTimer?.cancel();
    scrollController.dispose();
    _rightMenuController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    loadGuide();
    loadUser(); 
    scrollController.addListener((){
      if(scrollController.position.maxScrollExtent > 0){
        if(scrollController.offset >= scrollController.position.maxScrollExtent){
          if(onScrollOperation){
            return;
          }
          Future.delayed(Duration.zero, () async{
            onScrollOperation = true;
            switch(menuIndex){
              case 0:
                await appendGuide();
                break;
              case 1:
                await appendVideo();
                break;
              case 2:
                await appendCircle();
                break;
            }
            onScrollOperation = false;
          });
        }
        if(scrollController.offset >= scrollController.position.maxScrollExtent - BOTTOM_INDICATOR_SIZE){
          indicatorTimer?.cancel();
          indicatorTimer = Timer.periodic(const Duration(seconds: 1), (timer) { 
            if(scrollController.positions.isEmpty){
                timer.cancel();
                return;
              }
            int bias = (scrollController.position.maxScrollExtent - scrollController.offset).toInt();
            if(bias < BOTTOM_INDICATOR_SIZE){
              scrollController.animateTo(
                scrollController.position.maxScrollExtent - BOTTOM_INDICATOR_SIZE, 
                duration: Duration(milliseconds: (BOTTOM_INDICATOR_SIZE.toInt() - bias) * 15), 
                curve: Curves.ease
              );
            }
            timer.cancel();
          });
        }
      }
    });
    _rightMenuController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    menuItems = [
      MenuItem(
        text: '拉黑',
        icon: Icons.block,
        onClick: (context) {
          UserBlockUserFacade().block(
            userId: userId,
            success: (response){
              ToastUtil.hint('已加入黑名单');
            },
            fail: (response){
              ToastUtil.error(response.data['message']);
            }
          );
        }
      )
    ];
  }

  Future setMenu(int index) async{
    menuIndex = index;
    onScrollOperation = true;
    switch(menuIndex){
      case 1:
        if(videoList == null){
          await loadVideo();
        }
        break;
      case 2:
        if(circleList == null){
          await loadCircle();
        }
        break;
    }
    onScrollOperation = false;
    setState(() {
    });
  }

  Future appendCircle() async{
    int? maxId;
    if(circleList != null && circleList!.isNotEmpty){
      maxId = circleList!.last.id;
    }
    List<Circle>? tmpList = await CircleHttp().listByUser(userId: userId, maxId: maxId);
    if(tmpList == null){
      ToastUtil.error('好像出了点小问题');
      return;
    }
    if(tmpList.isEmpty){
      ToastUtil.hint('已经没有了呢');
      return;
    }
    circleList ??= [];
    circleList!.addAll(tmpList);
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }

  Future appendVideo() async{
    int? maxId;
    if(videoList != null && videoList!.isNotEmpty){
      maxId = videoList!.last.id;
    }
    List<VideoModel>? tmpList = await VideoApi().listByUser(userId: userId, maxId: maxId);
    if(tmpList == null){
      ToastUtil.error('好像出了点小问题');
      return;
    }
    if(tmpList.isEmpty){
      ToastUtil.hint('已经没有了呢');
      return;
    }
    videoList ??= [];
    videoList!.addAll(tmpList);
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }

  Future appendGuide() async{
    int? maxId;
    if(guideList != null && guideList!.isNotEmpty){
      maxId = guideList!.last.id;
    }
    List<Guide>? tmpList = await GuideHttp().listByUser(userId: userId, maxId: maxId);
    if(tmpList == null){
      ToastUtil.error('好像出了点小问题');
      return;
    }
    if(tmpList.isEmpty){
      ToastUtil.hint('已经没有了呢');
      return;
    }
    guideList ??= [];
    guideList!.addAll(tmpList);
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }

  void showRightMenu(){
    _isShowRightMenuWill = true;
    _isShowRightMenu = true;
    _rightMenuController.forward();
    setState(() {
    });
  }

  void hideRightMenu(){
    _isShowRightMenuWill = false;
    _rightMenuController.reverse().then((value) {
      _isShowRightMenu = false;
      resetState();
    });
  }

  void shiftRightMenu(){
    if(_isShowRightMenuWill){
      hideRightMenu();
    }
    else{
      showRightMenu();
    }
  }

  @override
  Widget build(BuildContext context) {
    double statusHeight = ThemeUtil.getStatusBarHeight(ContextUtil.getContext() ?? context);
    UserFoModel? info  =  userFo;
    return Container(
      color: ThemeUtil.backgroundColor,
      child: Stack(
        children: [
          Column(
            children:[
              Image.asset("images/user_center_bg.jpg",fit: BoxFit.fitWidth,),
              Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  boxShadow: [ 
                    BoxShadow(
                      color:Colors.black.withOpacity(0.8),
                      offset: const Offset(0, -10),  //阴影在X和Y轴的偏移量，正值代表右和下，
                      blurRadius: 20,  //阴影大小，如果它大于偏移量，那么两边都可能出现阴影
                    )
                  ],
                  gradient: const LinearGradient(      //渐变位置
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.99, 1.0],         //[渐变起始点, 渐变结束点]
                    //渐变颜色[始点颜色, 结束颜色]
                    colors: [Color.fromRGBO(0, 0, 0, 1),Color.fromRGBO(0, 0, 0, 1), Color.fromRGBO(0, 0, 0, 1)]
                  )
                ),
              )
            ]
          ),
          Positioned(
            top: statusHeight + 10,
            bottom: 0,
            left: 0,
            right: 0,
            child: SingleChildScrollView(
              controller: scrollController,
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(      //渐变位置
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.0, 0.9, 1.0],         //[渐变起始点, 渐变结束点]
                        //渐变颜色[始点颜色, 结束颜色]
                        colors: [Color.fromRGBO(0, 0, 0, 0),Color.fromRGBO(0, 0, 0, 0.5), Color.fromRGBO(0, 0, 0, 8)]
                      )
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          color: Colors.white.withOpacity(0.2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: (){
                                  Navigator.pop(context);
                                }, 
                                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white,)
                              ),
                              IconButton(
                                onPressed: shiftRightMenu,
                                icon: const Icon(Icons.more_horiz, color: Colors.white,),
                              )
                            ],
                          )
                        ),
                        const SizedBox(height: 5,),
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  getHeadImage(info.head,info.sex),
                                  const SizedBox(width: 10,),
                                  if(userFo.isDeleted != true)
                                  InkWell(
                                    onTap: () async{
                                      await DialogUtil.loginRedirectConfirm(context, callback: (isLogined){
                                        if(isLogined){
                                          SimpleUser partner = SimpleUser();
                                          partner.id = userFo.id;
                                          partner.head = userFo.head;
                                          partner.name = userFo.name;
                                          Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                            return FriendApplyPage(partner);
                                          }));
                                        }
                                      });
                                    },
                                    child: SizedBox(
                                      width: MAKE_FRIEND_SIZE,
                                      height: MAKE_FRIEND_SIZE,
                                      child: svgMakeFriend,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height:10),
                              Container(
                                alignment:Alignment.centerLeft,
                                child: Text(info.name == null ? '未设置':info.name!, style: const TextStyle(color:Colors.white,fontSize: 18))
                              ),
                              const SizedBox(height: 6,),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children:[
                                    Text(info.sex == 1? '女':'男', style: const TextStyle(color: Colors.white),),
                                    const SizedBox(width:4),
                                    const Text('|',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                                    const SizedBox(width:4),
                                    Text(info.birthday == null ? '无': "${DateTimeUtil.getAge(info.birthday!)}岁",style: const TextStyle(color: Colors.white),),
                                  ]
                                )
                              ),
                              const SizedBox(height: 6,),
                              Container(
                                alignment:Alignment.centerLeft,
                                child: Text(info.description ?? '这是我的介绍', maxLines: 3, style: const TextStyle(color: Colors.white60,fontWeight: FontWeight.bold))
                              ),
                              const SizedBox(height: 10,),
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Wrap(
                                  spacing: 30,
                                  children:[
                                    Text('点赞 ${info.likeNum == null ? '0': info.likeNum.toString()}', style: const TextStyle(color: Colors.white, fontSize: 16)),
                                    Text('获赞 ${info.getLikedNum == null ? '0': info.getLikedNum.toString()}',style: const TextStyle(color: Colors.white, fontSize: 16)),
                                    Text('收藏 ${info.favoriteNum == null ? '0': info.favoriteNum.toString()}',style: const TextStyle(color: Colors.white, fontSize: 16)),
                                    if((info.getGiftNum ?? 0) > 0)
                                    Text('礼物 ${info.getGiftNum}', style: const TextStyle(color: Colors.white, fontSize: 16),)
                                  ]
                                )
                              ),
                              const SizedBox(height:10)
                            ],
                          )
                        )
                      ],
                    ),
                  ),
                  Container(
                    color: const Color.fromRGBO(242,245,250,1),
                    child: Column(
                      children:[
                        Container(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(bottom: Radius.circular(8))
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor:menuIndex==0? menuItemOnColor:Colors.white,
                                  padding:menuItemPadding,
                                  shape:menuItemShap,
                                  minimumSize: Size.zero,
                                ),
                                onPressed: (){
                                  setMenu(0);
                                }, 
                                child: const Text('攻略',style: TextStyle(color:Colors.black),),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor:menuIndex==1? menuItemOnColor:Colors.white,
                                  padding:menuItemPadding,
                                  shape:menuItemShap,
                                  minimumSize: Size.zero,
                                ),
                                onPressed: (){
                                  setMenu(1);
                                }, 
                                child: const Text('视频',style: TextStyle(color:Colors.black),),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor:menuIndex==2? menuItemOnColor:Colors.white,
                                  padding:menuItemPadding,
                                  shape:menuItemShap,
                                  minimumSize: Size.zero,
                                ),
                                onPressed: (){
                                  setMenu(2);
                                }, 
                                child: const Text('圈子',style: TextStyle(color:Colors.black),),
                            ),
                          ],
                          )
                        )
                      ]
                    )
                  ),
                  Container(
                    color: const Color.fromRGBO(242,245,250,1),
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
                    child: IndexedStack(
                      index: menuIndex,
                      children: [
                        Visibility(visible: menuIndex == 0, child: getGuideContainer()),
                        Visibility(visible: menuIndex == 1, child: getVideoContainer()),
                        Visibility(visible: menuIndex == 2, child: getCircleContainer()),
                      ],
                    )
                  ),
                  Container(
                    height: BOTTOM_INDICATOR_SIZE,
                    color: ThemeUtil.backgroundColor,
                  )
                ],
              ),
            ),
          ),
          if(_isShowRightMenu)
          Positioned.fill(
            child: InkWell(
              onTap: hideRightMenu,
            ),
          ),
          Positioned(
            right: 0,
            top: statusHeight + 50,
            child: AnimatedBuilder(
              animation: _rightMenuController,
              builder:(context, child) {
                return Container(
                  constraints: BoxConstraints(
                    maxHeight: _rightMenuController.value * menuItems.length * MENU_ITEM_HEIGHT
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 2
                      )
                    ]
                  ),
                  alignment: Alignment.center,
                  child: Wrap(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      for(MenuItem menuItem in menuItems)
                      InkWell(
                        onTap: (){
                          menuItem.onClick?.call(context);
                        },
                        child: Container(
                          height: MENU_ITEM_HEIGHT,
                          width: MENU_ITEM_WIDTH,
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              Icon(menuItem.icon, color: Colors.white, size: 20,),
                              const SizedBox(width: 10,),
                              Expanded(
                                child: Text(menuItem.text, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            )
          )
        ],
      )
    );
  }

  Widget getGuideContainer() {
    List<Widget> widgets = [];
    double width =  (MediaQuery.of(context).size.width - 40) / 2;
    for(Guide guide in guideList ?? []){
      widgets.add(
        UserItemWidget(
          pic: guide.cover, 
          title: '攻略', 
          content: guide.title ?? '', 
          onTap: () async{
            if(guide.id == null){
              ToastUtil.error('数据错误');
              return;
            }
            Guide? result = await GuideHttp().get(id: guide.id!);
            if(result == null){
              ToastUtil.error('目标已失效');
              return;
            }
            if(mounted && context.mounted){
              Navigator.of(context).push(MaterialPageRoute(builder: (context){
                return GuideMapShowPage(result);
              }));
            }
          }
        )
      );
    }
    if(widgets.length == 1){
      widgets.add(
        SizedBox(
          width: width,
          height: width
        )
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child:Column(
        mainAxisSize: MainAxisSize.min,
        children:[
          const SizedBox(height: 10,),
          guideList == null ?
          const SizedBox() :
          guideList!.isEmpty ?
          const NotifyEmptyWidget() :
          Wrap(
            direction: Axis.horizontal,
            spacing: 10,
            runSpacing: 10,
            children: widgets
          ),
        ]
      )
    );
  }

  Widget getVideoContainer() {
    List<Widget> widgets = [];
    double width =  (MediaQuery.of(context).size.width - 40) / 2;
    for(VideoModel video in videoList ?? []){
      widgets.add(
        UserItemWidget(
          pic: video.pic, 
          title: '视频', 
          content: video.name ?? '', 
          onTap: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context){
              return VideoHomePage(initVideo: video,);
            }));
          }
        )
      );
    }
    if(widgets.length == 1){
      widgets.add(
        SizedBox(
          width: width,
          height: width,
        )
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10,),
          videoList == null ?
          const SizedBox() :
          videoList!.isEmpty ?
          const NotifyEmptyWidget() :
          Wrap(
            direction:Axis.horizontal,
            spacing: 10,
            runSpacing: 10,
            children: widgets,
          )
        ]
      )
    );
  }

  Widget getCircleContainer() {
    List<Widget> widgets = [];
    double width =  (MediaQuery.of(context).size.width - 40) / 2;
    for(Circle circle in circleList ?? []){
      String hintText = '';
      CircleType? circleType;
      if(circle.type != null){
        circleType = CircleTypeExt.getType(circle.type!);
      }
      switch(circleType){
        case CircleType.activity:
          hintText = '寻找驴友';
          break;
        case CircleType.article:
          hintText = '图文消息';
          break;
        case CircleType.question:
          hintText = '问答';
          break;
        case CircleType.shop:
          hintText = '发现店家';
          break;
        default:
      }
      widgets.add(
        UserItemWidget(
          pic: circle.pic,
          title: hintText, 
          content: circle.name ?? '', 
          onTap: (){
            if(circle is CircleActivity){
              Navigator.of(context).push(MaterialPageRoute(builder: (context){
                return CircleActivityPage(circle);
              }));
            }
            else if(circle is CircleArticle){
              Navigator.of(context).push(MaterialPageRoute(builder: (context){
                return CircleArticlePage(circle);
              }));
            }
            else if(circle is CircleQuestion){
              Navigator.of(context).push(MaterialPageRoute(builder: (context){
                return CircleQuestionPage(circle);
              }));
            }
            else if(circle is CircleShop){
              Navigator.of(context).push(MaterialPageRoute(builder: (context){
                return CircleShopPage(circle);
              }));
            }
          }
        )
      );
    }
    if(widgets.length == 1){
      widgets.add(
        SizedBox(
          width: width,
          height: width,
        )
      );
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Column(
        children: [
          const SizedBox(height: 10,),
          circleList == null ?
          const SizedBox() :
          circleList!.isEmpty ?
          const NotifyEmptyWidget() :
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: widgets
          ),
        ],
      ),
    );
  }

  Future loadGuide() async{
    guideList ??= [];
    List<Guide>? tmpList = await GuideHttp().listByUser(userId: userId);
    if(tmpList != null){
      guideList = tmpList;
      resetState();
    }
  }

  Future loadVideo() async{
    videoList ??= [];
    List<VideoModel>? tmpList = await VideoApi().listByUser(userId: userId);
    if(tmpList != null){
      videoList = tmpList;
      resetState();
    }
  }

  Future loadCircle() async{
    circleList ??= [];
    List<Circle>? tmpList = await CircleHttp().listByUser(userId: userId);
    if(tmpList != null){
      circleList = tmpList;
      resetState();
    }
  }

  Widget getHeadImage(String? head,int? sex) {
    if( head != null) {
      return CircleAvatar(
        radius: 30,
        backgroundImage: NetworkImage(getFullUrl(head)),
      );
    }
    if(sex == null || sex == 0) {
      return Image.asset('images/default_head.png', width: 56, height: 56,);
    }
    else {
      return Image.asset("images/default_head_woman.png",width: 56,height: 56,);
    }
  }

  void loadUser() {
    HttpCustomer.customerDetail(userId, (isSuccess, data, msg, code) {
      if(isSuccess) {
        userFo = UserFoModel.fromJson(data);
        resetState();
      }
    });
  }

  void resetState(){
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }
}
