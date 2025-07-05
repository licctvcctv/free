
import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freego_flutter/components/video/video_holder.dart';
import 'package:freego_flutter/components/web_views/user_privacies.dart';
import 'package:freego_flutter/http/http_user.dart';
import 'package:freego_flutter/model/user.dart';
import 'package:freego_flutter/util/local_user.dart';
import 'package:freego_flutter/util/storage.dart';
import 'package:freego_flutter/util/theme_util.dart';

class IntroPage extends StatefulWidget{
  const IntroPage({super.key});
  
  @override
  State<IntroPage> createState() {
    return IntroState();
  }

}

class IntroState extends State<IntroPage>{

  bool showContract = false;
  bool showTimer = false;
  int seconds = 5;
  Timer? nextTimer;

  void initialize(){
    Future.delayed(Duration.zero, () async{
      String? token = await LocalUser.getSavedToken();
      if(token != null){
        UserModel? user = await HttpUser.loginByToken();
        if(user == null){
          LocalUser.clear();
        }
        else{
          LocalUser.update(user);
        }
      }
    });
    Future.delayed(Duration.zero, () async{
      bool hasLaunched = await getHasLaunched();
      if(hasLaunched){
        showTimer = true;
        nextTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          --seconds;
          if(mounted && context.mounted){
            setState(() {
            });
          }
          if(seconds <= 0){
            if(mounted && context.mounted){
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                goHomePage();
              });
            }
            timer.cancel();
          }
        });
      }
      else{
        showContract = true;
      }
      if(mounted && context.mounted){
        setState(() {
        });
      }
    });
  }

  @override
  void initState(){
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
        backgroundColor: Colors.white,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      body: Stack(
        children: [
          getMainPicWidget(),
          Positioned(
            bottom: 40,
            left: 40,
            right: 40,
            child: getContractWidget(),
          ),
          Positioned(
            right: 40,
            bottom: 40,
            child: getTimerWidget(),
          )
        ],
      ),
    );
  }

  Widget getContractWidget(){
    return Offstage(
      offstage: !showContract,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12)),
          border: Border.fromBorderSide(BorderSide(color: ThemeUtil.foregroundColor))
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('欢迎使用freego'),
            const SizedBox(height: 20,),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: '请您仔细阅读',
                    style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)
                  ),
                  TextSpan(
                    text: '《隐私协议》',
                    recognizer: TapGestureRecognizer()..onTap = (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context){
                        return const UserPrivaciesPage();
                      }));
                    },
                    style: const TextStyle(color: ThemeUtil.buttonColor, fontSize: 16)
                  ),
                  const TextSpan(
                    text: '，同意协议后开始使用',
                    style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)
                  )
                ]
              )
            ),
            const SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: (){
                    SystemNavigator.pop();
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      border: Border.fromBorderSide(BorderSide(color: ThemeUtil.foregroundColor))
                    ),
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    child: const Text('拒 绝', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
                  ),
                ),
                InkWell(
                  onTap: goHomePage,
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      border: Border.fromBorderSide(BorderSide(color: ThemeUtil.buttonColor)),
                      color: ThemeUtil.buttonColor
                    ),
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    child: const Text('同 意', style: TextStyle(color: Colors.white, fontSize: 16),),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void goHomePage(){
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context){
      return const VideoHolderPage();
    }));
  }

  Widget getMainPicWidget(){
    return Positioned.fill(
      child: Image.asset('assets/intro.png', fit: BoxFit.fill,),
    );
  }

  Widget getTimerWidget(){
    return Offstage(
      offstage: !showTimer,
      child: InkWell(
        onTap: (){
          nextTimer?.cancel();
          goHomePage();
        },
        child: Container(
          decoration: const BoxDecoration(
            color: Color.fromRGBO(128, 128, 128, 0.5),
            borderRadius: BorderRadius.all(Radius.circular(20))
          ),
          alignment: Alignment.center,
          width: 100,
          height: 40,
          child: Text('${seconds}s 跳过', style: const TextStyle(color: Colors.white),),
        ),
      ),
    );
  }

  Future<bool> getHasLaunched() async{
    const String key = 'hasLaunched';
    bool? hasLaunched = await Storage.readInfo<bool>(key);
    hasLaunched ??= false;
    Storage.saveInfo(key, true);
    return hasLaunched;
  }
}
