import 'dart:math';

import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/chat_neo/chat_common.dart';
import 'package:freego_flutter/components/chat_neo/chat_home.dart';
import 'package:freego_flutter/components/chat_neo/chat_socket.dart';
import 'package:freego_flutter/components/chat_neo/chat_storage.dart';
import 'package:freego_flutter/components/chat_neo/chat_util.dart';
import 'package:freego_flutter/components/chat_notification/chat_notification_util.dart';
import 'package:freego_flutter/components/circle_neo/circle_home.dart';
import 'package:freego_flutter/components/comment/comment_model.dart';
import 'package:freego_flutter/components/comment/comment_page.dart';
import 'package:freego_flutter/components/comment/comment_util.dart';
import 'package:freego_flutter/components/friend_neo/friend_choose.dart';
import 'package:freego_flutter/components/guide_neo/guide_home.dart';
import 'package:freego_flutter/components/hotel_neo/hotel_common.dart';
import 'package:freego_flutter/components/hotel_neo/hotel_home_freego.dart';
import 'package:freego_flutter/components/hotel_neo/api/local_hotel_api.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/components/product_neo/product_home.dart';
import 'package:freego_flutter/components/purchase_item/pages/purchase_pay.dart';
import 'package:freego_flutter/components/restaurant/restaurant_common.dart';
import 'package:freego_flutter/components/restaurant/restaurant_home.dart';
import 'package:freego_flutter/components/trip/my_trip.dart';
import 'package:freego_flutter/components/user/user_center.dart';
import 'package:freego_flutter/components/user_block/event/user_block_user_facade.dart';
import 'package:freego_flutter/components/user_favorite/user_favorite_util.dart';
import 'package:freego_flutter/components/video/go/frame_go.dart';
import 'package:freego_flutter/components/video/go/video_go.dart';
import 'package:freego_flutter/components/video/video_api.dart';
import 'package:freego_flutter/components/video/video_holder.dart';
import 'package:freego_flutter/components/video/video_search.dart';
import 'package:freego_flutter/components/view/city_picker.dart';
import 'package:freego_flutter/components/view/simple_input.dart';
import 'package:freego_flutter/components/view/tipoff.dart';
import 'package:freego_flutter/components/view/video_player.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/http/http_restaurant.dart';
import 'package:freego_flutter/http/http_video.dart';
import 'package:freego_flutter/components/video/video_model.dart';
import 'package:freego_flutter/model/user.dart';
import 'package:freego_flutter/components/friend_neo/user_friend.dart';
import 'package:freego_flutter/util/dialog_util.dart';
import 'package:freego_flutter/util/local_user.dart';
import 'package:freego_flutter/util/page_view_ext.dart';
import 'package:freego_flutter/util/route_observer.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:freego_flutter/util/user_home_director.dart';
import 'package:freego_flutter/util/user_like_util.dart';
//import 'package:tencent_kit/tencent_kit.dart';
import 'package:video_player/video_player.dart';

class VideoHomePage extends StatefulWidget {
  final VideoModel? initVideo;
  const VideoHomePage({super.key, this.initVideo});

  @override
  State<StatefulWidget> createState() {
    return VideoHomePageState();
  }
}

class VideoHomePageState extends State<VideoHomePage> {
  static SystemUiOverlayStyle statusBarStyle = ThemeUtil.statusBarThemeLight;

  @override
  void initState() {
    super.initState();
    // 如果有初始视频，直接加载
    if (widget.initVideo != null && widget.initVideo!.id != null) {
      context
          .findAncestorStateOfType<VideoHomeState>()
          ?.loadSpecificVideo(widget.initVideo!.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
        backgroundColor: Colors.black,
        systemOverlayStyle: ThemeUtil.statusBarThemeLight,
      ),
      body: VideoHomeWidget(initVideo: widget.initVideo),
    );
  }
}

class VideoHomeWidget extends StatefulWidget {
  final VideoModel? initVideo;
  const VideoHomeWidget({super.key, this.initVideo});

  @override
  VideoHomeState createState() {
    return VideoHomeState();
  }
}

class _MyAfterLoginHandler implements AfterLoginHandler {
  VideoHomeState state;
  _MyAfterLoginHandler(this.state);

  @override
  void handle(UserModel user) {
    state.setMessageHintCount(reloadUnsent: true);
  }
}

class _MyAfterLogoutHandler implements AfterLogoutHandler {
  VideoHomeState state;
  _MyAfterLogoutHandler(this.state);

  @override
  void handle(UserModel user) {
    state.setMessageHintCount();
  }
}

class _MyMessageHandler extends ChatMessageHandler {
  VideoHomeState state;
  _MyMessageHandler(this.state) : super(priority: 99);

  @override
  Future handle(MessageObject rawObj) async {
    await state.setMessageHintCount();
  }
}

class _MyReconnectHandler extends SocketReconnectHandler {
  VideoHomeState state;
  _MyReconnectHandler(this.state) : super(priority: 99);

  @override
  Future handle() async {
    await state.setMessageHintCount();
  }
}

class _MyAfterBlockedUserHandler extends AfterBlockedUserHandler {
  final VideoHomeState _state;
  _MyAfterBlockedUserHandler(this._state);

  @override
  Future handle() async {
    _state.searchVideo();
  }
}

class _MyAfterUnblockedUserHandler extends AfterUnblockedUserHandler {
  final VideoHomeState _state;
  _MyAfterUnblockedUserHandler(this._state);

  @override
  Future handle() async {
    _state.searchVideo();
  }
}

class VideoHomeState extends State<VideoHomeWidget>
    with
        TickerProviderStateMixin,
        WidgetsBindingObserver,
        AutomaticKeepAliveClientMixin,
        RouteAware {
  static const double TOPPER_ICON_SIZE = 32;
  static const double MENU_ICON_SIZE = 20;

  bool isMenuShowReal = false;
  bool isMenuShow = false;
  List<VideoModel> videoList = [];
  PageController pageController = PageController();
  int playingIndex = 0;
  String? city;
  String? keyword;

  bool isHeaderShow = false;
  bool isHeaderShowReal = false;
  late AnimationController _headerAnimController;
  final InteractableVideoPlayerController _videoPlayerController =
      InteractableVideoPlayerController();

  late AnimationController _menuAnimController;

  Widget svgLocationWidget = SvgPicture.asset(
    'svg/location.svg',
    color: const Color.fromRGBO(255, 255, 255, 0.7),
  );
  Widget svgUserWidget = SvgPicture.asset('svg/user.svg');
  Widget svgSearchWidget = SvgPicture.asset(
    'svg/search.svg',
    color: const Color.fromRGBO(255, 255, 255, 0.7),
  );
  Widget svgMoreVertWidget = SvgPicture.asset(
    'svg/more_vert.svg',
    color: const Color.fromRGBO(255, 255, 255, 0.7),
  );

  int messageHintCount = 0;
  late _MyAfterLoginHandler _afterLoginHandler;
  late _MyAfterLogoutHandler _afterLogoutHandler;
  late _MyMessageHandler _chatMessageHandler;
  late _MyReconnectHandler _chatReconnectHandler;

  late _MyAfterBlockedUserHandler _myAfterBlockedUserHandler;
  late _MyAfterUnblockedUserHandler _myAfterUnblockedUserHandler;

  Future setMessageHintCount({bool? reloadUnsent}) async {
    UserModel? user = LocalUser.getUser();
    if (user != null) {
      if (reloadUnsent == true) {
        await ChatUtilSingle.getAllUnsent();
        await ChatNotificationUtil.getAllUnsent();
      }
      int chatSingleCount = await ChatUtilSingle().getUnreadCount();
      int chatNotificationCount = await ChatNotificationUtil().getUnreadCount();
      messageHintCount = chatSingleCount + chatNotificationCount;
      if (mounted && context.mounted) {
        setState(() {});
      }
    } else {
      messageHintCount = 0;
      setState(() {});
    }
  }

  Future<void> loadSpecificVideo(int videoId) async {
    await HttpVideo.getById(
      videoId,
      fail: (response) {
        ToastUtil.error(response.data?['msg'] ?? '视频加载失败');
      },
      success: (response) {
        VideoModel video = VideoModel.fromJson(response.data['data']);
        setState(() {
          videoList = [video];
          playingIndex = 0;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          pageController.jumpToPage(0);
        });
      },
    );
  }

  @override
  void didPopNext() {
    setMessageHintCount();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    RouteObserverUtil()
        .routeObserver
        .subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void initState() {
    super.initState();
    if (widget.initVideo != null) {
      videoList.add(widget.initVideo!);
    }
    searchVideo(append: true);
    _headerAnimController = AnimationController(
        vsync: this,
        duration:
            const Duration(milliseconds: VideoPlayerState.ANIM_MILLI_SECONDS));
    _menuAnimController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _afterLoginHandler = _MyAfterLoginHandler(this);
    _afterLogoutHandler = _MyAfterLogoutHandler(this);
    LocalUser.addAfterLoginHandler(_afterLoginHandler);
    LocalUser.addAfterLogoutHandler(_afterLogoutHandler);
    _chatMessageHandler = _MyMessageHandler(this);
    ChatSocket.addMessageHandler(_chatMessageHandler);
    _chatReconnectHandler = _MyReconnectHandler(this);
    ChatSocket.addReconnectHandler(_chatReconnectHandler);
    setMessageHintCount(reloadUnsent: true);
    ChatSocket.init();
    ChatUtilSingle();
    ChatNotificationUtil();

    _myAfterBlockedUserHandler = _MyAfterBlockedUserHandler(this);
    _myAfterUnblockedUserHandler = _MyAfterUnblockedUserHandler(this);
    UserBlockUserFacade().addBlockedHandler(_myAfterBlockedUserHandler);
    UserBlockUserFacade().addUnblockedHandler(_myAfterUnblockedUserHandler);
  }

  @override
  void dispose() {
    pageController.dispose();
    _headerAnimController.dispose();
    _menuAnimController.dispose();
    _videoPlayerController.dispose();
    RouteObserverUtil().routeObserver.unsubscribe(this);
    LocalUser.removeAfterLoginHandler(_afterLoginHandler);
    LocalUser.removeAfterLogoutHandler(_afterLogoutHandler);
    ChatSocket.removeMessageHandler(_chatMessageHandler);
    ChatSocket.removeReconnectHandler(_chatReconnectHandler);

    UserBlockUserFacade().removeBlockedHandler(_myAfterBlockedUserHandler);
    UserBlockUserFacade().removeUnblockedHandler(_myAfterUnblockedUserHandler);
    super.dispose();
  }

  void resetState() {
    if (mounted && context.mounted) {
      setState(() {});
    }
  }

  void showHeader() {
    isHeaderShow = true;
    isHeaderShowReal = true;
    _headerAnimController.forward();
    setState(() {});
  }

  void hideHeader() {
    isHeaderShow = false;
    _headerAnimController.reverse().then((value) {
      isHeaderShowReal = false;
      if (mounted && context.mounted) {
        setState(() {});
      }
    });
  }

  void showMenu() {
    isMenuShow = true;
    isMenuShowReal = true;
    _menuAnimController.forward();
    setState(() {});
  }

  void hideMenu() {
    isMenuShow = false;
    _menuAnimController.reverse().then((value) {
      isMenuShowReal = false;
      if (mounted && context.mounted) {
        setState(() {});
      }
    });
  }

  void shiftMenu() {
    if (isMenuShow) {
      hideMenu();
    } else {
      showMenu();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      decoration: const BoxDecoration(color: Colors.black),
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: getPageView()),
          Positioned(
            left: 10,
            top: 0,
            child: Row(
              children: [
                if (Navigator.of(context).canPop())
                  Container(
                    width: 48,
                    alignment: Alignment.center,
                    child: IconButton(
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                    ),
                  ),
                TextButton(
                  onPressed: () async {
                    Object? name = await Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return const CityPickerPage(
                        allowAllChoose: true,
                        allChooseValue: '\\全国',
                      );
                    }));
                    if (name == null) {
                      return;
                    }
                    if (city == name) {
                      return;
                    }
                    if (name == '\\全国') {
                      name = null;
                    }
                    if (name is String?) {
                      city = name;
                      searchVideo();
                      setState(() {});
                    }
                    hideHeader();
                  },
                  child: SizedBox(
                    width: TOPPER_ICON_SIZE,
                    height: TOPPER_ICON_SIZE,
                    child: svgLocationWidget,
                  ),
                )
              ],
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Offstage(
              offstage: !isHeaderShowReal,
              child: FadeTransition(
                  opacity: _headerAnimController,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0, 5, 5, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () async {
                            dynamic searchResult = await Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return const VideoSearchPage();
                            }));
                            if (searchResult == null) {
                              return;
                            }
                            String keyword = searchResult['keyword'];
                            List<VideoModel> list = searchResult['videoList'];
                            int clickIndex = searchResult['index'];
                            if (list.isEmpty) {
                              return;
                            }
                            this.keyword = keyword;
                            videoList = list;
                            setState(() {});
                            pageController.jumpToPage(clickIndex);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: SizedBox(
                                width: TOPPER_ICON_SIZE,
                                height: TOPPER_ICON_SIZE,
                                child: svgSearchWidget),
                          ),
                        ),
                        const SizedBox(
                          width: TOPPER_ICON_SIZE / 2,
                        ),
                        InkWell(
                          onTap: shiftMenu,
                          child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: SizedBox(
                                  width: TOPPER_ICON_SIZE,
                                  height: TOPPER_ICON_SIZE,
                                  child: Stack(
                                    children: [
                                      svgMoreVertWidget,
                                      if (messageHintCount > 0)
                                        Align(
                                            alignment: Alignment.topRight,
                                            child: ClipOval(
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 350),
                                                decoration: const BoxDecoration(
                                                  color: Colors.redAccent,
                                                ),
                                                alignment: Alignment.center,
                                                width: 12,
                                                height: 12,
                                              ),
                                            )),
                                    ],
                                  ))),
                        ),
                      ],
                    ),
                  )),
            ),
          ),
          Positioned(
            right: 0,
            top: 15 + TOPPER_ICON_SIZE,
            child: Offstage(
              offstage: !isMenuShowReal,
              child: FadeTransition(
                opacity: _menuAnimController,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(15, 10, 10, 10),
                    width: 125,
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(96, 96, 96, 0.3),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return const CircleHomePage();
                              }));
                            },
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/icon_circle.png',
                                  width: MENU_ICON_SIZE,
                                  height: MENU_ICON_SIZE,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                const Text(
                                  '圈子',
                                  style: TextStyle(color: Colors.white),
                                )
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return const GuideHomePage();
                              }));
                            },
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/icon_guide.png',
                                  width: MENU_ICON_SIZE,
                                  height: MENU_ICON_SIZE,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                const Text(
                                  '攻略',
                                  style: TextStyle(color: Colors.white),
                                )
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return const ProductHomePage();
                              }));
                            },
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.shopping_cart,
                                  color: Colors.white,
                                  size: MENU_ICON_SIZE,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  '服务',
                                  style: TextStyle(color: Colors.white),
                                )
                              ],
                            ),
                          ),
                          TextButton(
                              onPressed: () {
                                DialogUtil.loginRedirectConfirm(context,
                                    callback: (isLogined) {
                                  if (isLogined) {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                      return const MyTripPage();
                                    }));
                                  }
                                });
                              },
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/icon_trip.png',
                                    width: MENU_ICON_SIZE,
                                    height: MENU_ICON_SIZE,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Text(
                                    '行程',
                                    style: TextStyle(color: Colors.white),
                                  )
                                ],
                              )),
                          TextButton(
                              onPressed: () {
                                DialogUtil.loginRedirectConfirm(context,
                                    callback: (isLogined) {
                                  if (isLogined) {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                      return const ChatHomePage();
                                    }));
                                  }
                                });
                              },
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.chat,
                                    color: Colors.white,
                                    size: MENU_ICON_SIZE,
                                  ),
                                  const SizedBox(width: 10),
                                  const Text('消息',
                                      style: TextStyle(color: Colors.white)),
                                  if (messageHintCount > 0)
                                    ClipOval(
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.redAccent,
                                        ),
                                        alignment: Alignment.center,
                                        width: 20,
                                        height: 20,
                                        child: Text(
                                          '${messageHintCount < 99 ? messageHintCount : '99'}',
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                    )
                                ],
                              )),
                          TextButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return const PurchasePayPage();
                                }));
                              },
                              child: Row(children: const [
                                Icon(
                                  Icons.card_giftcard,
                                  color: Colors.white,
                                  size: MENU_ICON_SIZE,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  '商城',
                                  style: TextStyle(color: Colors.white),
                                )
                              ])),
                          TextButton(
                            onPressed: () {
                              DialogUtil.loginRedirectConfirm(context,
                                  callback: (isLogined) {
                                if (isLogined) {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return const UserCenterPage();
                                  }));
                                }
                              });
                            },
                            child: Row(
                              children: [
                                svgUserWidget,
                                const SizedBox(
                                  width: 10,
                                ),
                                const Text(
                                  '我的',
                                  style: TextStyle(color: Colors.white),
                                )
                              ],
                            ),
                          )
                        ]),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getPageView() {
    if (videoList.isEmpty) {
      return InkWell(
        onTap: () {
          if (isHeaderShow) {
            hideHeader();
          } else {
            showHeader();
          }
        },
        child: const SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: Text(
              '暂无内容',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }
    return PageView.builder(
      controller: pageController,
      physics: const ClampingScrollPhysics(),
      scrollDirection: Axis.vertical,
      onPageChanged: (index) {
        playingIndex = index;
        _videoPlayerController.hide();
        if (index == videoList.length - 1) {
          searchVideo(append: true);
        }
        hideMenu();
      },
      itemBuilder: (context, index) {
        return InteractableVideoPlayerWidget(videoList[index],
            controller: _videoPlayerController, onCtrl: (val) {
          if (val) {
            showHeader();
          } else {
            hideHeader();
          }
        },
            onTapReplay: () {},
            key: ValueKey(
              videoList[index].id,
            ));
      },
      itemCount: videoList.length,
    );
  }

  void searchVideo({bool? append}) {
    List<int> excluded = [];
    if (append == true) {
      excluded = getExcludedIds();
    }
    HttpVideo.search(keyword, city, excluded, (isSuccess, data, msg, code) {
      if (isSuccess) {
        if (data != null) {
          if (append != true) {
            videoList = [];
            playingIndex = 0;
          }
          List<dynamic> list = data as List<dynamic>;
          for (dynamic item in list) {
            VideoModel video = VideoModel.fromJson(item);
            videoList.add(video);
          }
          if (mounted && context.mounted) {
            setState(() {});
          }
          if (append != true) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              pageController.jumpToPage(0);
            });
          }
        }
      } else {
        ToastUtil.error(msg ?? '视频搜索失败');
      }
    });
  }

  List<int> getExcludedIds() {
    List<int> list = [];
    for (VideoModel video in videoList) {
      if (video.id != null) {
        list.add(video.id!);
      }
    }
    return list;
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class _InteractAfterUserLikeHandler implements AfterUserLikeHandler {
  final InteractableVideoPlayerState state;
  _InteractAfterUserLikeHandler(this.state);
  @override
  void handle(int id, ProductType type) {
    if (type == ProductType.video && id == state.widget.video.id) {
      VideoModel video = state.widget.video;
      if (video.isLiked != true) {
        video.isLiked = true;
        video.likeNum = (video.likeNum ?? 0) + 1;
      }
      state.resetState();
    }
  }
}

class _InteractAfterUserUnlikeHandler implements AfterUserUnlikeHandler {
  final InteractableVideoPlayerState state;
  _InteractAfterUserUnlikeHandler(this.state);
  @override
  void handle(int id, ProductType type) {
    if (type == ProductType.video && id == state.widget.video.id) {
      VideoModel video = state.widget.video;
      if (video.isLiked == true) {
        video.isLiked = false;
        video.likeNum = (video.likeNum ?? 1) - 1;
      }
      state.resetState();
    }
  }
}

enum InteractableVideoPlayerAction { show, hide }

class InteractableVideoPlayerController extends ChangeNotifier {
  InteractableVideoPlayerAction? action;
  void hide() {
    action = InteractableVideoPlayerAction.hide;
    notifyListeners();
  }

  void show() {
    action = InteractableVideoPlayerAction.show;
    notifyListeners();
  }
}

class InteractableVideoPlayerWidget extends StatefulWidget {
  final VideoModel video;
  final Function(bool)? onCtrl;
  final InteractableVideoPlayerController? controller;
  final Function()? onTapReplay;

  const InteractableVideoPlayerWidget(
    this.video, {
    this.onCtrl,
    this.controller,
    this.onTapReplay,
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return InteractableVideoPlayerState();
  }
}

class _MyAfterPostCommentHandler extends AfterPostCommentHandler {
  final InteractableVideoPlayerState state;
  _MyAfterPostCommentHandler(this.state);

  @override
  void handle(Comment comment) {
    ProductType? type;
    if (comment.typeId != null) {
      type = ProductTypeExt.getType(comment.typeId!);
    }
    if (type != ProductType.video) {
      return;
    }
    VideoModel video = state.widget.video;
    if (video.id != comment.productId) {
      return;
    }
    video.commentNum = (video.commentNum ?? 0) + 1;
    state.resetState();
  }
}

class InteractableVideoPlayerState extends State<InteractableVideoPlayerWidget>
    with SingleTickerProviderStateMixin, PageViewIndexAware {
  static const double USER_BEHAVIOR_ICON_SIZE = 32;
  static const double USER_GO_ICON_HEIGHT = 45;
  static const double USER_GO_ICON_WIDTH = 70;

  static const double SHARE_MODAL_HEIGHT = 400;
  static const double FRIEND_HEAD_SIZE = 60;
  static const double SHARE_TO_PLATFROM_ICON_SIZE = 60;
  static const double MODAL_CANCEL_ICON_SIZE = 40;
  static const List<String> TIPOFF_TYPES = [
    '色情低俗',
    '政治敏感',
    '造谣宣传',
    '涉嫌欺诈',
    '侵犯权益',
    '违法犯罪',
    '其他'
  ];

  VideoHomeState? homeState;

  VideoCtrlController innerCtrlController = VideoCtrlController();
  VideoPlayController innerPlayController = VideoPlayController();
  late AnimationController interactAnimController;

  bool _showInteract = false;
  bool _showInteractReal = false;

  Widget svgLocationWidget = SvgPicture.asset(
    'svg/location.svg',
    color: Colors.white,
  );

  Widget svgLikeWidget = SvgPicture.asset('svg/like.svg');
  Widget svgCommentWidget = SvgPicture.asset('svg/comment.svg');
  Widget svgShareWidget = SvgPicture.asset('svg/share.svg');
  Widget svgGoWidget = SvgPicture.asset('svg/go.svg');
  Widget svgLikeOnWidget = SvgPicture.asset('svg/like_on.svg');

  late _InteractAfterUserLikeHandler _afterUserLikeHandler;
  late _InteractAfterUserUnlikeHandler _afterUserUnlikeHandler;

  Duration? _duration;

  late _MyAfterPostCommentHandler _myAfterPostCommentHandler;

  VideoPlayerController? _insetPlayerController;

  Widget svgPlayWidget = SvgPicture.asset(
    'svg/play_arrow.svg',
    color: const Color.fromRGBO(255, 255, 255, 0.7),
  );
  Widget svgReplayWidget = SvgPicture.asset(
    'svg/replay.svg',
    color: const Color.fromRGBO(255, 255, 255, 0.7),
  );

  bool hasAddShowNum = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((timestamp) {
      if (pageViewIndex != VideoHolderState.VIDEO_HOME_INDEX) {
        innerPlayController.pause();
      }
    });
  }

  @override
  void dispose() {
    innerCtrlController.dispose();
    innerPlayController.dispose();
    interactAnimController.dispose();

    UserLikeUtil.removeAfterUserLikeHandler(_afterUserLikeHandler);
    UserLikeUtil.removeAfterUserUnlikeHandler(_afterUserUnlikeHandler);

    CommentUtil().removeHandler(_myAfterPostCommentHandler);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    homeState = context.findAncestorStateOfType();
    interactAnimController = AnimationController(
        vsync: this,
        upperBound: 0.8,
        duration:
            const Duration(milliseconds: VideoPlayerState.ANIM_MILLI_SECONDS));

    _afterUserLikeHandler = _InteractAfterUserLikeHandler(this);
    _afterUserUnlikeHandler = _InteractAfterUserUnlikeHandler(this);
    UserLikeUtil.addAfterUserLikeHandler(_afterUserLikeHandler);
    UserLikeUtil.addAfterUserUnlikeHandler(_afterUserUnlikeHandler);

    if (widget.controller != null) {
      widget.controller!.addListener(() {
        InteractableVideoPlayerAction? action = widget.controller?.action;
        if (action == InteractableVideoPlayerAction.hide) {
          hideInteract();
        } else if (action == InteractableVideoPlayerAction.show) {
          showInteract();
        }
      });
    }

    _myAfterPostCommentHandler = _MyAfterPostCommentHandler(this);
    CommentUtil().addHandler(_myAfterPostCommentHandler);
  }

  @override
  Widget build(BuildContext context) {
    pageViewIndex = PageViewIndexData.of(context)?.index;
    VideoModel video = widget.video;

    if (video.path == null) {
      return const Center(
          child: Text(
        '视频路径错误',
        style: TextStyle(color: Colors.white),
      ));
    }

    int? likeNum = video.likeNum ?? 0;
    int? commentNum = video.commentNum ?? 0;
    int? shareNum = video.shareNum ?? 0;

    return Stack(
      children: [
        VideoPlayerWidget(
          getFullUrl(widget.video.path!),
          sourceType: VideoSourceType.remote,
          ctrlController: innerCtrlController,
          playController: innerPlayController,
          onTap: () {
            if (homeState?.isMenuShow == true) {
              homeState?.hideMenu();
              return;
            }
            if (innerPlayController.isEnded == true) {
              shiftInteract();
              return;
            }
            if (innerPlayController.isPlaying == true) {
              innerPlayController.pause();
              showInteract();
            } else {
              innerPlayController.play();
              hideInteract();
            }
          },
          onPlay: (duration, total) {
            _duration = duration;
            if (!hasAddShowNum && video.id != null) {
              if (duration.inSeconds > 60 ||
                  (total != null && duration.compareTo(total) >= 0)) {
                VideoApi().addShowNum(
                    videoId: video.id!,
                    success: (response) {
                      hasAddShowNum = true;
                    });
              }
            }
          },
          onCreated: (videoPlayController) {
            _insetPlayerController = videoPlayController;
            videoPlayController.setLooping(true);
          },
          replayBuilder: widget.onTapReplay == null
              ? null
              : () {
                  return InkWell(
                      onTap: () {
                        innerPlayController.play();
                      },
                      child: SizedBox(
                        width: VideoPlayerState.LOCAL_ICON_SIZE,
                        height: VideoPlayerState.LOCAL_ICON_SIZE,
                        child: Transform(
                          transform: Matrix4.rotationX(pi),
                          alignment: Alignment.center,
                          child: svgReplayWidget,
                        ),
                      ));
                },
          playBuilder: () {
            return InkWell(
              onTap: () {
                if (homeState?.isMenuShow == true) {
                  homeState?.hideMenu();
                  return;
                }
                innerPlayController.play();
                hideInteract();
              },
              child: SizedBox(
                width: VideoPlayerState.LOCAL_ICON_SIZE * 1.2,
                height: VideoPlayerState.LOCAL_ICON_SIZE * 1.2,
                child: svgPlayWidget,
              ),
            );
          },
          bottomBuilder: () {
            return InkWell(
              onTap: showVideoInfo,
              child: Container(
                height: VideoPlayerState.PROGRESS_BAR_HEIGHT,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                child: Text(
                  widget.video.description ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            );
          },
        ),
        Positioned(
          bottom: VideoPlayerState.PROGRESS_BAR_HEIGHT + 20,
          right: 0,
          child: Offstage(
            offstage: !_showInteractReal,
            child: FadeTransition(
              opacity: interactAnimController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                          onPressed: () async {
                            if (video.id == null) {
                              ToastUtil.error('数据错误');
                              return;
                            }
                            await DialogUtil.loginRedirectConfirm(context,
                                hint: "需要登录后才能点赞，是否登录？");
                            if (!LocalUser.isLogined()) {
                              return;
                            }
                            if (video.isLiked == true) {
                              await UserLikeUtil.unlike(
                                  video.id!, ProductType.video);
                            } else {
                              await UserLikeUtil.like(
                                  video.id!, ProductType.video);
                            }
                          },
                          child: Column(
                            children: [
                              SizedBox(
                                  width: USER_BEHAVIOR_ICON_SIZE,
                                  height: USER_BEHAVIOR_ICON_SIZE,
                                  child: video.isLiked == true
                                      ? svgLikeOnWidget
                                      : svgLikeWidget),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                likeNum <= 0
                                    ? ''
                                    : StringUtil.getCountStr(likeNum),
                                style: const TextStyle(color: Colors.white),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        TextButton(
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap),
                            onPressed: () {
                              showCommentModal();
                            },
                            child: Column(
                              children: [
                                SizedBox(
                                  width: USER_BEHAVIOR_ICON_SIZE,
                                  height: USER_BEHAVIOR_ICON_SIZE,
                                  child: svgCommentWidget,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                    commentNum <= 0
                                        ? ''
                                        : StringUtil.getCountStr(commentNum),
                                    style:
                                        const TextStyle(color: Colors.white)),
                              ],
                            )),
                        const SizedBox(
                          height: 16,
                        ),
                        TextButton(
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap),
                            onPressed: showShareModal,
                            child: Column(
                              children: [
                                SizedBox(
                                  width: USER_BEHAVIOR_ICON_SIZE,
                                  height: USER_BEHAVIOR_ICON_SIZE,
                                  child: svgShareWidget,
                                ),
                              ],
                            )),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(16),
                    child: TextButton(
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        onPressed: onTapGo,
                        child: SizedBox(
                          width: USER_GO_ICON_WIDTH,
                          height: USER_GO_ICON_HEIGHT,
                          child: svgGoWidget,
                        )),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void showVideoInfo() {
    innerPlayController.pause();
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: Colors.transparent,
              child: Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16))),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                width: double.infinity,
                child: VideoInfoWidget(
                  video: widget.video,
                ),
              ),
            )
          ],
        );
      },
    );
  }

  Future onTapGo() async {
    VideoModel video = widget.video;
    if (video.lat == null || video.lng == null || video.linkProductId == null) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return FrameGoPage(
          videoId: video.id!,
          millis: _duration?.inMilliseconds ?? 0,
        );
      }));
      return;
    }
    ProductType? goType;
    if (video.linkProductType != null) {
      goType = ProductTypeExt.getType(video.linkProductType!);
    }
    switch (goType) {
      case ProductType.hotel:
        DateTime startDate = DateTime.now();
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        DateTime endDate = startDate.add(const Duration(days: 1));
        Hotel? hotel = await LocalHotelApi().detail(
            id: video.linkProductId!, startDate: startDate, endDate: endDate);
        if (hotel == null) {
          ToastUtil.error('目标已失效');
          return;
        }
        if (context.mounted) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return HotelHomePage(hotel, startDate: startDate, endDate: endDate);
          }));
        }
        break;
      case ProductType.restaurant:
        Restaurant? target = await HttpRestaurant.getById(video.linkProductId!);
        if (target == null) {
          ToastUtil.error('目标已失效');
          return;
        }
        if (context.mounted) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return RestaurantHomePage(target);
          }));
        }
        break;
      default:
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return VideoGoPage(video);
        }));
    }
  }

  void showCommentModal() async {
    VideoModel video = widget.video;
    if (video.id == null) {
      ToastUtil.error('数据错误');
      return;
    }
    showGeneralDialog(
        context: context,
        barrierColor: const Color.fromRGBO(128, 128, 128, 0.5),
        barrierDismissible: true,
        barrierLabel: '',
        transitionDuration: const Duration(milliseconds: 350),
        transitionBuilder: ((context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation
                .drive(Tween(begin: const Offset(0, 1), end: Offset.zero)),
            child: child,
          );
        }),
        pageBuilder: ((context, animation, secondaryAnimation) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: Colors.transparent,
                child: VideoCommentWidget(
                  video.id!,
                  creatorId: video.userId,
                ),
              )
            ],
          );
        }));
  }

  void showShareModal() async {
    DialogUtil.loginRedirectConfirm(context, callback: (isLogined) {
      if (isLogined) {
        if (mounted && context.mounted) {
          showGeneralDialog(
              context: context,
              barrierColor: const Color.fromRGBO(128, 128, 128, 0.5),
              barrierDismissible: true,
              barrierLabel: '',
              transitionDuration: const Duration(milliseconds: 350),
              transitionBuilder:
                  ((context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: animation.drive(
                      Tween(begin: const Offset(0, 1), end: Offset.zero)),
                  child: child,
                );
              }),
              pageBuilder: (context, animation, secondaryAnimation) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Material(
                        color: Colors.transparent,
                        child: FooterWidget(widget.video))
                  ],
                );
              });
        }
      }
    });
  }

  void showInteract() {
    _showInteract = true;
    _showInteractReal = true;
    interactAnimController.forward();
    setState(() {});
    innerCtrlController.show();
    widget.onCtrl?.call(true);
  }

  void hideInteract() {
    _showInteract = false;
    if (interactAnimController.isDismissed) {
      return;
    }
    interactAnimController.reverse().then((value) {
      _showInteractReal = false;
      setState(() {});
    });
    innerCtrlController.hide();
    widget.onCtrl?.call(false);
  }

  void shiftInteract() {
    if (_showInteract) {
      hideInteract();
    } else {
      showInteract();
    }
  }

  void resetState() {
    if (mounted && context.mounted) {
      setState(() {});
    }
  }
}

class VideoInfoWidget extends StatefulWidget {
  final VideoModel video;

  const VideoInfoWidget({required this.video, super.key});

  @override
  State<StatefulWidget> createState() {
    return VideoInfoState();
  }
}

class VideoInfoState extends State<VideoInfoWidget> {
  static const double AUTHOR_HEAD_SIZE = 60;
  static const int DESCRIPTION_LENGTH_MAX = 128;
  static const int AUTHOR_NAME_LENGTH_MAX = 14;
  static const int ADDRESS_LENGTH_MAX = 100;

  Widget svgLocationWidget = SvgPicture.asset(
    'svg/location.svg',
    color: ThemeUtil.foregroundColor,
  );

  @override
  Widget build(BuildContext context) {
    VideoModel video = widget.video;
    String? description = video.description;
    String? authorHead =
        video.authorHead == null ? null : getFullUrl(video.authorHead!);
    String? authorName = video.authorName;

    String? city = video.city;
    String? address = video.address;

    String? fullAddress;
    fullAddress = city;
    if (address != null) {
      if (fullAddress == null) {
        fullAddress = address;
      } else {
        fullAddress += '.$address';
      }
    }
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                  onTap: () {
                    if (video.userId == null) {
                      return;
                    }
                    UserHomeDirector()
                        .goUserHome(context: context, userId: video.userId!);
                  },
                  child: ClipOval(
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                        width: AUTHOR_HEAD_SIZE,
                        height: AUTHOR_HEAD_SIZE,
                        child: authorHead == null
                            ? Image.asset(
                                'images/head.png',
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.fill,
                              )
                            : Image.network(
                                authorHead,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.fill,
                              )),
                  )),
              const SizedBox(
                width: 10,
              ),
              InkWell(
                onTap: () {
                  if (video.userId == null) {
                    return;
                  }
                  UserHomeDirector()
                      .goUserHome(context: context, userId: video.userId!);
                },
                child: Text(
                  authorName == null
                      ? ''
                      : StringUtil.getLimitedText(
                          authorName, AUTHOR_NAME_LENGTH_MAX),
                  style: const TextStyle(color: ThemeUtil.foregroundColor),
                ),
              )
            ],
          ),
        ),
        const Divider(),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
          child: Opacity(
            opacity: 0.8,
            child: Text(
              description == null
                  ? ''
                  : StringUtil.getLimitedText(
                      description, DESCRIPTION_LENGTH_MAX),
              style: const TextStyle(color: ThemeUtil.foregroundColor),
            ),
          ),
        ),
        const Divider(),
        if (fullAddress != null)
          ClipRRect(
            borderRadius:
                const BorderRadius.all(Radius.circular(AUTHOR_HEAD_SIZE / 4)),
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
              constraints: const BoxConstraints(minHeight: AUTHOR_HEAD_SIZE),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    height: VideoHomeState.TOPPER_ICON_SIZE,
                    width: VideoHomeState.TOPPER_ICON_SIZE,
                    alignment: Alignment.center,
                    child: svgLocationWidget,
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.6 -
                          24 -
                          VideoHomeState.TOPPER_ICON_SIZE,
                    ),
                    child: Text(
                      StringUtil.getLimitedText(
                          fullAddress, ADDRESS_LENGTH_MAX),
                      maxLines: 99,
                      style: const TextStyle(
                          color: ThemeUtil.foregroundColor,
                          fontSize: 14,
                          height: 1.5),
                    ),
                  )
                ],
              ),
            ),
          )
      ],
    );
  }
}

class VideoCommentWidget extends StatefulWidget {
  final int videoId;
  final int? creatorId;
  const VideoCommentWidget(this.videoId, {this.creatorId, super.key});

  @override
  State<StatefulWidget> createState() {
    return VideoCommentState();
  }
}

class VideoCommentState extends State<VideoCommentWidget>
    with AutomaticKeepAliveClientMixin {
  CommonMenuControllerWrapper controllerWrapper = CommonMenuControllerWrapper();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        controllerWrapper.controller?.hideMenu();
        controllerWrapper.controller = null;
        FocusScope.of(context).unfocus();
      },
      child: Container(
        decoration: const BoxDecoration(
            color: ThemeUtil.backgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 2), // 调整这里的数值来改变间距
                child: IconButton(
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.black,
                    size: 36,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
            Expanded(
              child: CommentWidget(
                productId: widget.videoId,
                type: ProductType.video,
                creatorId: widget.creatorId,
                controllerWrapper: controllerWrapper,
              ),
            ),
            if (LocalUser.isLogined())
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: SimpleInputWidget(
                  hintText: '友好地评论一下哟~',
                  onSubmit: (val) async {
                    String content = val.trim();
                    if (content.isEmpty) {
                      return false;
                    }
                    Comment comment = Comment();
                    comment.productId = widget.videoId;
                    comment.typeId = ProductType.video.getNum();
                    comment.content = content;
                    Comment? result = await CommentUtil().postComment(comment);
                    return result != null;
                  },
                ),
              )
          ],
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class FooterWidget extends StatefulWidget {
  final VideoModel video;
  const FooterWidget(this.video, {super.key});

  @override
  State<StatefulWidget> createState() {
    return FooterState();
  }
}

class _MyAfterUserFavoriteHandler implements AfterUserFavoriteHandler {
  final FooterState state;
  const _MyAfterUserFavoriteHandler(this.state);

  @override
  void handle(int productId, ProductType type) {
    if (type != ProductType.video) {
      return;
    }
    VideoModel video = state.widget.video;
    if (video.id == productId) {
      if (video.isFavorited != true) {
        video.isFavorited = true;
        video.favoriteNum = (video.favoriteNum ?? 0) + 1;
      }
      state.resetState();
    }
  }
}

class _MyAfterUserUnFavoriteHandler implements AfterUserUnFavoriteHandler {
  final FooterState state;
  const _MyAfterUserUnFavoriteHandler(this.state);

  @override
  void handle(int productId, ProductType type) {
    if (type != ProductType.video) {
      return;
    }
    VideoModel video = state.widget.video;
    if (video.id == productId) {
      if (video.isFavorited == true) {
        video.isFavorited = false;
        video.favoriteNum = (video.favoriteNum ?? 1) - 1;
      }
      state.resetState();
    }
  }
}

class FooterState extends State<FooterWidget> {
  static const double VIDEO_OPERATION_ICON_SIZE = 60;
  Widget svgTipOffWidget = SvgPicture.asset(
    'svg/tip_off.svg',
    color: ThemeUtil.foregroundColor,
  );

  late _MyAfterUserFavoriteHandler _afterUserFavoriteHandler;
  late _MyAfterUserUnFavoriteHandler _afterUserUnFavoriteHandler;

  @override
  void dispose() {
    UserFavoriteUtil().removeFavoriteHandler(_afterUserFavoriteHandler);
    UserFavoriteUtil().removeUnFavoriteHandler(_afterUserUnFavoriteHandler);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _afterUserFavoriteHandler = _MyAfterUserFavoriteHandler(this);
    UserFavoriteUtil().addFavoriteHandler(_afterUserFavoriteHandler);
    _afterUserUnFavoriteHandler = _MyAfterUserUnFavoriteHandler(this);
    UserFavoriteUtil().addUnFavoriteHandler(_afterUserUnFavoriteHandler);
  }

  @override
  Widget build(BuildContext context) {
    VideoModel video = widget.video;
    UserModel? localUser = LocalUser.getUser();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      color: ThemeUtil.backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          /*InkWell(
            onTap: () async{
              UserFriend? friend = await Navigator.of(context).push(MaterialPageRoute(builder: (context){
                return const FriendChoosePage();
              }));
              if(friend == null || friend.friendId == null){
                return;
              }
              ImSingleRoom? room = await ChatUtilSingle.enterRoom(friend.friendId!);
              if(room == null){
                return;
              }
              ImSingleMessage message = ChatUtilSingle.prepareFreegoVideoMessage(room.id, video: video);
              ChatStorageSingle.saveMessage(message);
              MessageObject rawMessage = ChatUtilSingle.getRawMessage(message);
              ChatSocket.sendMessage(rawMessage);
              ToastUtil.hint('转发成功');
              if(mounted && context.mounted){
                Navigator.of(context).pop();
              }
            },
            child: Column(
              children: const [
                SizedBox(
                  width: VIDEO_OPERATION_ICON_SIZE,
                  height: VIDEO_OPERATION_ICON_SIZE,
                  child: Icon(Icons.send_rounded, color: ThemeUtil.foregroundColor, size: VIDEO_OPERATION_ICON_SIZE * 0.8,)
                ),
                SizedBox(height: 10,),
                Text('转发', style: TextStyle(color: ThemeUtil.foregroundColor))
              ],
            ),
          ),*/
          InkWell(
            onTap: () async {
              // 显示转发选项弹窗
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('分享到',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // 原有转发功能
                            InkWell(
                              onTap: () async {
                                Navigator.pop(context); // 关闭弹窗
                                UserFriend? friend = await Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return const FriendChoosePage();
                                }));
                                if (friend == null || friend.friendId == null) {
                                  return;
                                }
                                ImSingleRoom? room =
                                    await ChatUtilSingle.enterRoom(
                                        friend.friendId!);
                                if (room == null) {
                                  return;
                                }
                                ImSingleMessage message =
                                    ChatUtilSingle.prepareFreegoVideoMessage(
                                        room.id,
                                        video: video);
                                ChatStorageSingle.saveMessage(message);
                                MessageObject rawMessage =
                                    ChatUtilSingle.getRawMessage(message);
                                ChatSocket.sendMessage(rawMessage);
                                ToastUtil.hint('转发成功');
                              },
                              child: Column(
                                children: [
                                  Image.asset('images/ic_share_friend.png',
                                      width: 50, height: 50),
                                  const SizedBox(height: 8),
                                  const Text('好友转发')
                                ],
                              ),
                            ),
                            // 微信好友分享
                            InkWell(
                              onTap: () async {
                                Navigator.pop(context); // 关闭弹窗
                                await _shareToWeChat(fluwx.WeChatScene.SESSION);
                              },
                              child: Column(
                                children: [
                                  Image.asset('images/ic_share_wechat.png',
                                      width: 50, height: 50),
                                  const SizedBox(height: 8),
                                  const Text('微信好友')
                                ],
                              ),
                            ),
                            // 微信朋友圈分享
                            /*InkWell(
                              onTap: () async {
                                Navigator.pop(context); // 关闭弹窗
                                await _shareToWeChat(
                                    fluwx.WeChatScene.TIMELINE);
                              },
                              child: Column(
                                children: [
                                  Image.asset('images/ic_share_moments.png',
                                      width: 50, height: 50),
                                  const SizedBox(height: 8),
                                  const Text('朋友圈')
                                ],
                              ),
                            ),
                            // QQ好友分享
                            InkWell(
                              /*onTap: () async {
                                Navigator.pop(context);
                                await _shareToQQ(TencentScene.SCENE_QQ);
                              },*/
                              child: Column(
                                children: [
                                  Image.asset('images/ic_share_qq.jpg',
                                      width: 50, height: 50),
                                  const SizedBox(height: 8),
                                  const Text('QQ好友')
                                ],
                              ),
                            ),
                            // QQ空间分享
                            InkWell(
                              /*onTap: () async {
                                Navigator.pop(context);
                                await _shareToQQ(TencentScene.SCENE_QZONE);
                              },*/
                              child: Column(
                                children: [
                                  Image.asset('images/ic_share_qzone.png',
                                      width: 50, height: 50),
                                  const SizedBox(height: 8),
                                  const Text('QQ空间')
                                ],
                              ),
                            ),*/
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('取消'),
                        )
                      ],
                    ),
                  );
                },
              );
            },
            child: Column(
              children: const [
                SizedBox(
                    width: VIDEO_OPERATION_ICON_SIZE,
                    height: VIDEO_OPERATION_ICON_SIZE,
                    child: Icon(
                      Icons.send_rounded,
                      color: ThemeUtil.foregroundColor,
                      size: VIDEO_OPERATION_ICON_SIZE * 0.8,
                    )),
                SizedBox(height: 10),
                Text('转发', style: TextStyle(color: ThemeUtil.foregroundColor))
              ],
            ),
          ),
          InkWell(
              onTap: () {
                VideoModel video = widget.video;
                if (video.id == null) {
                  ToastUtil.error('数据错误');
                  return;
                }
                if (video.isFavorited == true) {
                  UserFavoriteUtil().unFavorite(
                      productId: video.id!, type: ProductType.video);
                } else {
                  UserFavoriteUtil()
                      .favorite(productId: video.id!, type: ProductType.video);
                }
              },
              child: Column(
                children: [
                  SizedBox(
                      width: VIDEO_OPERATION_ICON_SIZE,
                      height: VIDEO_OPERATION_ICON_SIZE,
                      child: Icon(
                        Icons.star_rounded,
                        color: video.isFavorited == true
                            ? Colors.redAccent
                            : ThemeUtil.foregroundColor,
                        size: VIDEO_OPERATION_ICON_SIZE * 0.8,
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    '收藏',
                    style: TextStyle(color: ThemeUtil.foregroundColor),
                  )
                ],
              )),
          InkWell(
              onTap: () {
                showTipOffModal();
              },
              child: Column(
                children: [
                  SizedBox(
                    width: VIDEO_OPERATION_ICON_SIZE,
                    height: VIDEO_OPERATION_ICON_SIZE,
                    child: Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: VIDEO_OPERATION_ICON_SIZE * 0.8,
                        height: VIDEO_OPERATION_ICON_SIZE * 0.8,
                        child: svgTipOffWidget,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text('举报'),
                ],
              )),
          if (video.userId != null && video.userId != localUser?.id)
            InkWell(
                onTap: () async {
                  if (video.userId == null) {
                    return;
                  }
                  DialogUtil.showConfirm(context,
                      info: '屏蔽作者？',
                      confirmText: '屏蔽',
                      cancelText: '再想想', success: () async {
                    await UserBlockUserFacade().block(userId: video.userId!);
                    if (mounted && context.mounted) {
                      Navigator.of(context).pop();
                    }
                  });
                },
                child: Column(
                  children: const [
                    SizedBox(
                      width: VIDEO_OPERATION_ICON_SIZE,
                      height: VIDEO_OPERATION_ICON_SIZE,
                      child: Icon(
                        Icons.block,
                        color: ThemeUtil.foregroundColor,
                        size: VIDEO_OPERATION_ICON_SIZE * 0.8,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text('屏蔽')
                  ],
                ))
        ],
      ),
    );
  }

  Future<void> _shareToWeChat(fluwx.WeChatScene scene) async {
    try {
      final isWeChatInstalled = await fluwx.isWeChatInstalled;
      if (!isWeChatInstalled) {
        ToastUtil.error('未安装微信');
        return;
      }

      final model = fluwx.WeChatShareWebPageModel(
        'https://freego.freemen.work/video/${widget.video.id}',
        title: widget.video.name ?? '视频分享',
        description: widget.video.description ?? '分享一个有趣的视频',
        thumbnail: widget.video.pic != null
            ? fluwx.WeChatImage.network(getFullUrl(widget.video.pic!))
            : fluwx.WeChatImage.asset('images/placeholder.png'),
        scene: scene,
      );

      await fluwx.shareToWeChat(model);
    } catch (e) {
      ToastUtil.error('分享失败: ${e.toString()}');
    }
  }

  /*Future<void> _shareToQQ(int scene) async {
    try {
      // 初始化QQ SDK (appId需要替换成你的实际值)
      await Tencent.instance.registerApp(appId: '你的QQ_APP_ID');
      Tencent.instance.setIsPermissionGranted(granted: true);

      // 检查QQ是否安装
      if (!await Tencent.instance.isQQInstalled()) {
        ToastUtil.error('未安装QQ');
        return;
      }

      // 构建分享参数
      await Tencent.instance.shareWebpage(
        scene: scene == 0 ? TencentScene.SCENE_QQ : TencentScene.SCENE_QZONE,
        title: widget.video.name ?? '视频分享',
        summary: widget.video.description ?? '分享一个有趣的视频',
        imageUri: widget.video.pic != null
            ? Uri.parse(getFullUrl(widget.video.pic!))
            : Uri.parse('https://freego.freemen.work/images/placeholder.png'),
        targetUrl: 'https://freego.freemen.work/video/${widget.video.id}',
      );

      ToastUtil.hint('分享成功');
    } catch (e) {
      ToastUtil.error('分享失败: ${e.toString()}');
    }
  }*/

  void showTipOffModal() async {
    VideoModel video = widget.video;
    if (video.id == null) {
      ToastUtil.error('数据错误');
      return;
    }
    showGeneralDialog(
        context: context,
        barrierColor: Colors.transparent,
        barrierDismissible: true,
        barrierLabel: '',
        transitionDuration: const Duration(milliseconds: 350),
        transitionBuilder: ((context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation
                .drive(Tween(begin: const Offset(0, 1), end: Offset.zero)),
            child: child,
          );
        }),
        pageBuilder: (context, animation, secondaryAnimation) {
          return StatefulBuilder(builder: (context, setState) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    clipBehavior: Clip.hardEdge,
                    child: TipOffWidget(
                      targetId: video.id!,
                      productType: ProductType.video,
                    ))
              ],
            );
          });
        });
  }

  void resetState() {
    if (mounted && context.mounted) {
      setState(() {});
    }
  }
}
