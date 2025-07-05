import 'package:flutter/material.dart';
import 'package:freego_flutter/components/chat_neo/chat_home.dart';
import 'package:freego_flutter/components/local_video/beauty_camera.dart';
import 'package:freego_flutter/components/user/login.dart';
import 'package:freego_flutter/components/video/video_home.dart';
import 'package:freego_flutter/util/local_user.dart';
import 'package:freego_flutter/util/page_view_ext.dart';
import 'package:freego_flutter/util/route_observer.dart';
import 'package:freego_flutter/util/theme_util.dart';

class VideoHolderPage extends StatefulWidget{
  const VideoHolderPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return VideoHolderState();
  }

}

class VideoHolderState extends State<VideoHolderPage> with RouteAware{

  static const DEFAULT_INDEX = 1;
  static const CAMERA_INDEX = 0;
  static const VIDEO_HOME_INDEX = 1;
  static const CHAT_HOME_INDEX = 2;
  int pageIndex = DEFAULT_INDEX;

  final PageController _controller = PageController(initialPage: DEFAULT_INDEX);
  final List<Widget> widgets = [
    const BeautyCameraPage(),
    const VideoHomePage(),
    const ChatHomePage(),
  ];

  @override
  void didPush(){
    setStatusBarTheme();
  }

  @override
  void didPopNext(){
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setStatusBarTheme();
    });
  }

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    RouteObserverUtil().routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose(){
    _controller.dispose();
    RouteObserverUtil().routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    _controller.addListener(() {
      _controller.page;
      // 此处还需暂停页面活动
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageViewIndexData(
      pageIndex, 
      child: PageView(
        physics: const ClampingScrollPhysics(),
        controller: _controller,
        //children: widgets,
        children: [
          const BeautyCameraPage(),
          const VideoHomePage(),
          ChatHomePage(
            onBack: () => _controller.animateToPage(VIDEO_HOME_INDEX, 
              duration: const Duration(milliseconds: 350), 
              curve: Curves.ease),
          ),
        ],
        onPageChanged: (index){
          setState(() {
          });
          pageIndex = index;
          setStatusBarTheme();
          if(index == CHAT_HOME_INDEX && LocalUser.getUser() == null){
            showGeneralDialog(
              context: context, 
              barrierLabel: '',
              barrierColor: Colors.transparent,
              pageBuilder: ((context, animation, secondaryAnimation) {
                return AlertDialog(
                  title: const Text('提示'),
                  content: const Text('您还没有登录'),
                  actions: [
                    FilledButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith((states) {
                          return Colors.grey;
                        }),
                      ),
                      onPressed: (){
                        _controller.animateToPage(1, duration: const Duration(milliseconds: 350), curve: Curves.ease);
                        Navigator.of(context).pop();
                      }, 
                      child: const Text('取消')
                    ),
                    FilledButton(
                      onPressed: () async{
                        Navigator.of(context).pop();
                        await Navigator.push(context, MaterialPageRoute(
                          builder: (type) {
                            return const LoginPage();
                          }
                        ));
                        if(!LocalUser.isLogined()){
                          _controller.animateToPage(1, duration: const Duration(milliseconds: 350), curve: Curves.ease);
                        }
                        else{
                          _controller.jumpToPage(CHAT_HOME_INDEX);
                        }
                      }, 
                      child: const Text('确定')
                    )
                  ],
                );
              })
            );
          }          
        },
      )
    );
  }

  void setStatusBarTheme(){
    Future.delayed(const Duration(milliseconds: 200), () {
      switch(pageIndex){
        case CHAT_HOME_INDEX:
          ThemeUtil.setStatusBarDark();
          break;
        case VIDEO_HOME_INDEX:
          ThemeUtil.setStatusBarStyle(VideoHomePageState.statusBarStyle);
          break;
        case CAMERA_INDEX:
          ThemeUtil.setStatusBarStyle(BeautyCameraPageState.statusBarStyle);
          break;
      }
    });
  }
}