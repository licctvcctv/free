
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/circle_neo/circle_common.dart';
import 'package:freego_flutter/components/circle_neo/circle_http.dart';
import 'package:freego_flutter/components/circle_neo/create/circle_activity.dart';
import 'package:freego_flutter/components/circle_neo/create/circle_article.dart';
import 'package:freego_flutter/components/circle_neo/create/circle_question.dart';
import 'package:freego_flutter/components/circle_neo/create/circle_shop.dart';
import 'package:freego_flutter/components/circle_neo/detail/circle_activity.dart';
import 'package:freego_flutter/components/circle_neo/detail/circle_article.dart';
import 'package:freego_flutter/components/circle_neo/detail/circle_question.dart';
import 'package:freego_flutter/components/circle_neo/detail/circle_shop.dart';
import 'package:freego_flutter/components/guide_neo/guide_create.dart';
import 'package:freego_flutter/components/guide_neo/guide_http.dart';
import 'package:freego_flutter/components/guide_neo/guide_map_show.dart';
import 'package:freego_flutter/components/guide_neo/guide_model.dart';
import 'package:freego_flutter/components/help/help_home.dart';
import 'package:freego_flutter/components/local_video/video_upload.dart';
import 'package:freego_flutter/components/merchent/merchant_apply.dart';
import 'package:freego_flutter/components/order_neo/order_home.dart';
import 'package:freego_flutter/components/qrcode/qr_camera.dart';
import 'package:freego_flutter/components/user/user_common.dart';
import 'package:freego_flutter/components/user/user_set.dart';
import 'package:freego_flutter/components/user_favorite/user_favorite_home.dart';
import 'package:freego_flutter/components/video/video_home.dart';
import 'package:freego_flutter/components/video/video_api.dart';
import 'package:freego_flutter/components/video/video_model.dart';
import 'package:freego_flutter/components/view/notify_empty.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/http/http_user.dart';
import 'package:freego_flutter/model/user.dart';
import 'package:freego_flutter/model/user_fo.dart';
import 'package:freego_flutter/provider/user_provider.dart';
import 'package:freego_flutter/util/context_util.dart';
import 'package:freego_flutter/util/date_time_util.dart';
import 'package:freego_flutter/util/local_user.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';

import '../wallet/wallet_page.dart';

class UserCenterPage extends StatelessWidget{
  const UserCenterPage({super.key});
  
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
      body: const UserCenterWidget()
    );
  }
}

class UserCenterWidget extends ConsumerStatefulWidget {
  const UserCenterWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return UserCenterState();
  }
}

class UserCenterState extends ConsumerState{
  bool isMenuShow = false;
  int  menuIndex = 0; //先中的菜单，0为攻略，1为视频，2为圈子

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

  Widget svgCustomerService = SvgPicture.asset('svg/customer_service.svg', color: Colors.white,);

  @override
  void dispose(){
    indicatorTimer?.cancel();
    scrollController.dispose();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    loadUser();
    loadGuide();
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
  }

  void loadUser() {
    HttpUser.loginedUserDetail((isSuccess, data, msg, code) {
      if(isSuccess) {
        UserFoModel fo = UserFoModel.fromJson(data);
        ref.read(userFoProvider.notifier).state = fo;
      }
    });
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
    UserModel? user = LocalUser.getUser();
    if(user == null){
      return;
    }
    int? maxId;
    if(circleList != null && circleList!.isNotEmpty){
      maxId = circleList!.last.id;
    }
    List<Circle>? tmpList = await CircleHttp().listByUser(userId: user.id, maxId: maxId);
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
    UserModel? user = LocalUser.getUser();
    if(user == null){
      return;
    }
    int? maxId;
    if(videoList != null && videoList!.isNotEmpty){
      maxId = videoList!.last.id;
    }
    List<VideoModel>? tmpList = await VideoApi().listByUser(userId: user.id, maxId: maxId);
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
    UserModel? user = LocalUser.getUser();
    if(user == null){
      return;
    }
    int? maxId;
    if(guideList != null && guideList!.isNotEmpty){
      maxId = guideList!.last.id;
    }
    List<Guide>? tmpList = await GuideHttp().listByUser(userId: user.id, maxId: maxId);
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

  @override
  Widget build(BuildContext context) {
    double statusHeight = ThemeUtil.getStatusBarHeight(ContextUtil.getContext() ?? context);
    UserFoModel info  = ref.watch(userFoProvider);
    return GestureDetector(
      onTap: onScreenTap,
      child: SizedBox(
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
                                  icon: const Icon(Icons.more_vert,color: Colors.white,),
                                  onPressed: (){
                                    showRightMenu(!isMenuShow);
                                  }
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
                                    getHeadImage(info.head, info.sex),
                                    Row(
                                      children: [
                                        const SizedBox(width: 10,),
                                        const Icon(Icons.account_balance_wallet_rounded,color: Color.fromRGBO(2,227,234,1)),
                                        const Text('￥',style: TextStyle(color: Colors.white),),
                                        Text(info.totalAmount == null ? '0':(info.totalAmount! / 100.0).toStringAsFixed(2), style: const TextStyle(color:Colors.white,fontSize: 20),),
                                      ],
                                    ),
                                    OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                                        side: const BorderSide(width: 1.0, color: Colors.white),minimumSize: Size.zero,
                                        padding: const EdgeInsets.fromLTRB(10, 3, 10, 3)
                                      ),
                                      onPressed: (){
                                        Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                          return const WalletPage();
                                        }));
                                      },
                                      child: const Text('钱包中心',style:TextStyle(color:Colors.white)),   
                                    )
                                  ],
                                ),
                                const SizedBox(height:10),
                                Container(
                                  alignment:Alignment.centerLeft,
                                  child: Text(info.name == null ? '未设置':info.name!, style: const TextStyle(color:Colors.white,fontSize: 18))
                                ),
                                const SizedBox(height: 6,),
                                Container(
                                  alignment:Alignment.centerLeft,
                                  child: Row(
                                    children:[
                                      Text(info.sex == 1? '女': '男', style: const TextStyle(color: Colors.white),),
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
                                  child: const Text('攻略',style: TextStyle(color:Colors.black, fontSize: 16),),
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
                                  child: const Text('视频',style: TextStyle(color:Colors.black, fontSize: 16),),
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
                                  child: const Text('圈子',style: TextStyle(color:Colors.black, fontSize: 16),),
                                ),
                              ],
                            )
                          )
                        ]
                      )
                    ),
                    Container(
                      color: const Color.fromRGBO(242,245,250,1),
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
            isMenuShow ? 
            Positioned(
              right: 12,
              top: 90,
              child: Visibility(
                visible: isMenuShow,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 10, 20, 14),
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(184,185,187,1),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  child: Column(
                    children: [
                      TextButton(
                        onPressed: (){
                          Navigator.of(context).push(MaterialPageRoute(builder: (context){
                            return const OrderHomePage();
                          }));
                        }, 
                        child: Row(
                          children: const [
                            Icon(Icons.list_alt,color: Colors.white,),
                            SizedBox(width: 10,),
                            Text('订单',style: TextStyle(color:Colors.white),)
                          ],
                        )
                      ),
                      TextButton(
                        onPressed: (){
                          Navigator.of(context).push(MaterialPageRoute(builder: (context){
                            return const UserFavoriteHomePage();
                          }));
                        },
                        child: Row(
                          children: const [
                            Icon(Icons.star_rounded, color: Colors.white,),
                            SizedBox(width: 10),
                            Text('收藏', style: TextStyle(color: Colors.white),)
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(
                            builder: (type) {
                              return const UserSetPage();
                            }
                          ));
                        }, 
                        child: Row(
                          children: const [
                            Icon(Icons.settings_sharp,color: Colors.white,),
                            SizedBox(width: 10,),
                            Text('设置',style: TextStyle(color:Colors.white),)
                          ],
                        )
                      ),
                      TextButton(
                        onPressed: (){
                          Navigator.of(context).push(MaterialPageRoute(builder: (context){
                            return const QRCameraScanner();
                          }));
                        }, 
                        child: Row(
                          children: const [
                            Icon(Icons.qr_code, color: Colors.white,),
                            SizedBox(width: 10,),
                            Text('扫描', style: TextStyle(color: Colors.white),)
                          ],
                        )
                      ),
                      TextButton(
                        onPressed: (){
                          Navigator.of(context).push(MaterialPageRoute(builder: (context){
                            return const HelpHomePage();
                          }));
                        },
                        child: Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: svgCustomerService,
                            ),
                            const SizedBox(width: 10,),
                            const Text('客服', style: TextStyle(color: Colors.white),)
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: (){
                          Navigator.of(context).push(MaterialPageRoute(builder: (context){
                            UserModel? user = LocalUser.getUser();
                            return MerchantApplyPage(userId: user?.id ?? 0); // 传递 userId 到下一个页面
                          }));
                        }, 
                        child: Row(
                          children: const [
                            Icon(Icons.store,color: Colors.white,),
                            SizedBox(width: 10,),
                            Text('成为商家',style: TextStyle(color:Colors.white),)
                            //Text('商家进件',style: TextStyle(color:Colors.white),)
                          ],
                        )
                      ),
                    ],
                  )
                )
              ),
            ) :
            const SizedBox()
          ]
        )
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
          SizedBox(
            child:TextButton(
              onPressed: () async{
                dynamic result = await Navigator.of(context).push(MaterialPageRoute(builder: (context){
                  return const GuideCreatePage();
                }));
                if(result == true){
                  loadNewGuide();
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('发布攻略', style: TextStyle(color:Colors.black,fontSize: 18),),
                  SizedBox(width: 8,),
                  Icon(Icons.add_circle,color: Colors.black,)
                ],
              )
            )
          ),
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

  Future loadNewGuide() async{
    UserModel? user = LocalUser.getUser();
    if(user == null){
      return;
    }
    int? minId;
    if(guideList != null && guideList!.isNotEmpty){
      minId = guideList!.first.id;
    }
    List<Guide>? list = await GuideHttp().listByUser(userId: user.id, minId: minId, isDesc: false,);
    if(list != null){
      guideList ??= [];
      guideList!.insertAll(0, list.reversed);
      if(mounted && context.mounted){
        setState(() {
        });
      }
    }
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
          SizedBox(
            child:TextButton(
              onPressed: () async{
                dynamic result = await Navigator.of(context).push(MaterialPageRoute(builder: (context){
                  return const VideoUploadPage(rechoosable: true,);
                }));
                if(result == true){
                  loadNewVideo();
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('发布视频', style: TextStyle(color:Colors.black,fontSize: 18),),
                  SizedBox(width: 8,),Icon(Icons.add_circle,color: Colors.black,)
                ],
              )
            )
          ),
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

  Future loadNewVideo() async{
    UserModel? user = LocalUser.getUser();
    if(user == null){
      return;
    }
    int? minId;
    if(videoList != null && videoList!.isNotEmpty){
      minId = videoList!.first.id;
    }
    List<VideoModel>? list = await VideoApi().listByUser(userId: user.id, minId: minId, isDesc: false);
    if(list != null){
      videoList ??= [];
      videoList!.insertAll(0, list.reversed);
      if(mounted && context.mounted){
        setState(() {
        });
      }
    }
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
          height: width
        )
      );
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Column(
        children: [
          TextButton(
            onPressed: (){
              showCircleBtns();
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [Text('发布圈子', style: TextStyle(color:Colors.black,fontSize: 18),),SizedBox(width: 8,),Icon(Icons.add_circle,color: Colors.black,)],
            )
          ),
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

  void showCircleBtns() {
    showGeneralDialog(
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (buildContext, animation, secondaryAnimation){
      return Center(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.all(Radius.circular(6))
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap
                ),
                onPressed: () async {
                  Navigator.of(buildContext).pop();
                  bool? result = await Navigator.push(context, MaterialPageRoute(
                    builder: (type) {
                      return const CircleArticleCreatePage();
                    }
                  ));
                  if(result == true){
                    loadNewCircle();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 4
                      )
                    ]
                  ),
                  child: Wrap(
                    direction: Axis.horizontal,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: const [
                      Icon(Icons.image_aspect_ratio, size: 40, color: ThemeUtil.foregroundColor,),
                      SizedBox(width: 20,),
                      Text('图文消息', style: TextStyle(fontSize: 28, color: ThemeUtil.foregroundColor),)
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12,),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap
                ),
                onPressed: () async{
                  Navigator.of(buildContext).pop();
                  bool? result = await Navigator.of(buildContext).push(MaterialPageRoute(builder: (context){
                    return const CircleActivityCreatePage();
                  }));
                  if(result == true){
                    loadNewCircle();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 4
                      )
                    ]
                  ),
                  child: Wrap(
                    direction: Axis.horizontal,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: const [
                      Icon(Icons.groups, size: 40, color: ThemeUtil.foregroundColor,),
                      SizedBox(width: 20,),
                      Text('寻找驴友', style: TextStyle(fontSize: 28, color: ThemeUtil.foregroundColor),)
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12,),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap
                ),
                onPressed: () async{
                  Navigator.of(buildContext).pop();
                  bool? result = await Navigator.push(context, MaterialPageRoute(
                    builder: (type) {
                      return const CircleQuestionCreatePage();
                    }
                  ));
                  if(result == true){
                    loadNewCircle();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 4
                      )
                    ]
                  ),
                  child: Wrap(
                    direction: Axis.horizontal,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: const [
                      Icon(Icons.question_answer_outlined, size: 40, color: ThemeUtil.foregroundColor,),
                      SizedBox(width: 20,),
                      Text('发布问题', style: TextStyle(fontSize: 28, color: ThemeUtil.foregroundColor),)
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12,),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap
                ),
                onPressed: () async{
                  Navigator.of(buildContext).pop();
                  bool? result = await Navigator.push(context, MaterialPageRoute(
                    builder: (type) {
                      return const CircleShopCreatePage();
                    }
                  ));
                  if(result == true){
                    loadNewCircle();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 4
                      )
                    ]
                  ),
                  child: Wrap(
                    direction: Axis.horizontal,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: const [
                      Icon(Icons.add_business, size: 40, color: ThemeUtil.foregroundColor,),
                      SizedBox(width: 20,),
                      Text('发现店家', style: TextStyle(fontSize: 28, color: ThemeUtil.foregroundColor),)
                    ],  
                  ),
                ),
              ),
            ],
          )
        )
      );
    });
  }

  Future loadNewCircle() async{
    UserModel? user = LocalUser.getUser();
    if(user == null){
      return;
    }
    int? minId;
    if(circleList != null && circleList!.isNotEmpty){
      minId = circleList!.first.id;
      List<Circle>? tmpList = await CircleHttp().listByUser(userId: user.id, minId: minId, isDesc: false);
      if(tmpList != null){
        circleList ??= [];
        circleList!.insertAll(0, tmpList.reversed);
        if(mounted && context.mounted){
          setState(() {
          });
        }
      }
    }
  }

  Future loadGuide() async{
    UserModel? user = LocalUser.getUser();
    if(user == null){
      return;
    }
    guideList ??= [];
    List<Guide>? tmpList = await GuideHttp().listByUser(userId: user.id);
    if(tmpList != null){
      guideList = tmpList;
      if(mounted && context.mounted){
        setState(() {
        });
      }
    }
  }

  Future loadVideo() async{
    UserModel? user = LocalUser.getUser();
    if(user == null){
      return;
    }
    videoList ??= [];
    List<VideoModel>? tmpList = await VideoApi().listByUser(userId: user.id);
    if(tmpList != null){
      videoList = tmpList;
      if(mounted && context.mounted){
        setState(() {
        });
      }
    }
  }

  Future loadCircle() async{
    UserModel? user = LocalUser.getUser();
    if(user == null){
      return;
    }
    circleList ??= [];
    List<Circle>? tmpList = await CircleHttp().listByUser(userId: user.id);
    if(tmpList != null){
      circleList = tmpList;
      if(mounted && context.mounted){
        setState(() {
        });
      }
    }
  }

  Widget getHeadImage(String? head, int? sex) {
    if(head != null) {
      return CircleAvatar(
        radius: 30,
        backgroundImage: NetworkImage(getFullUrl(head),),
      );
    }
    if(sex == null || sex == 0) {
      return Image.asset('images/default_head.png', width: 56, height: 56,);
    }
    else {
      return Image.asset("images/default_head_woman.png", width: 56, height: 56,);
    }
  }

  void onScreenTap() {
    showRightMenu(false);
  }

  void showRightMenu(bool value) {
    isMenuShow = value;
    setState(() {
    });
  }
}
