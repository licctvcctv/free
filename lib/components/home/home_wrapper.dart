
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/chat_neo/chat_home.dart';
import 'package:freego_flutter/components/home/home_map.dart';
import 'package:freego_flutter/components/local_video/beauty_camera.dart';
import 'package:freego_flutter/components/user/login.dart';
import 'package:freego_flutter/util/local_user.dart';

class HomeWrapperPage extends StatefulWidget{
  const HomeWrapperPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return HomeWrapperState();
  }

}

class HomeWrapperState extends State<HomeWrapperPage>{

  static const DEFAULT_INDEX = HOME_MAP_INDEX;
  static const CAMERA_INDEX = 0;
  static const HOME_MAP_INDEX = 1;
  static const CHAT_HOME_INDEX = 2;

  final PageController _controller = PageController(initialPage: DEFAULT_INDEX);

  final List<Widget> widgets = [
    const BeautyCameraPage(),
    const HomeMapPage(),
    const ChatHomePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return PageView(
      physics: const ClampingScrollPhysics(),
      controller: _controller,
      children: widgets,
      onPageChanged: (index){
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
    );
  }

}
