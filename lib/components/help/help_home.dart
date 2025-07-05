
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpHomePage extends StatelessWidget{
  const HelpHomePage({super.key});

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
      body: const HelpHomeWidget(),
    );
  }
  
}

class HelpHomeWidget extends StatefulWidget{
  const HelpHomeWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return HelpHomeState();
  }
  
}

class HelpHomeState extends State<HelpHomeWidget>{

  static const String phone = '18857865511';
  static const String mail = 'kai.wang@maya-group.com.cn';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeUtil.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonHeader(
            center: Text('客服', style: TextStyle(color: Colors.white, fontSize: 18),),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: '电话：',
                        style: TextStyle(
                          color: ThemeUtil.foregroundColor,
                          fontSize: 16
                        )
                      ),
                      TextSpan(
                        text: phone,
                        style: const TextStyle(
                          color: ThemeUtil.buttonColor,
                          fontSize: 16
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () async{
                          String url = 'tel:$phone';
                          Uri uri = Uri.parse(url);
                          if (await canLaunchUrl(uri)){
                            launchUrl(uri);
                          }
                        }
                      )
                    ]
                  ),
                ),
                const SizedBox(height: 30,),
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: '邮箱：',
                        style: TextStyle(
                          color: ThemeUtil.foregroundColor,
                          fontSize: 16
                        )
                      ),
                      TextSpan(
                        text: mail,
                        style: const TextStyle(
                          color: ThemeUtil.buttonColor,
                          fontSize: 16
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () async{
                          String url = 'mailto:$mail';
                          Uri uri = Uri.parse(url);
                          if(await canLaunchUrl(uri)){
                            launchUrl(uri);
                          }
                        }
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 30,),
                const Text('工作时间：', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
                const Text('周一到周五（法定节假日除外）', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
                const Text('上午：9:00 - 12:00', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
                const Text('下午：13:00 - 17:00', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),)
              ],
            ),
          )
        ],
      ),
    );
  }
  
}
