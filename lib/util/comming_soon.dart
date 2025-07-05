
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';

class CommingSoon{

  CommingSoon._internal();
  static final CommingSoon _instance = CommingSoon._internal();
  factory CommingSoon(){
    return _instance;
  }

  Future showWidget(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierLabel: '',
      barrierDismissible: true,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: Colors.transparent,
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                clipBehavior: Clip.hardEdge,
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  children: const [
                    CommingSoonWidget()
                  ],
                ),
              ),
            )
          ],
        );
      },
    );
  }
}

class CommingSoonWidget extends StatelessWidget{
  const CommingSoonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.asset(
              'images/banner.png',
              fit: BoxFit.fill,
            ),
          ),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('即将上线中', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 18),),
                  const SizedBox(height: 20,),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: '视频号搜索“',
                          style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 18)
                        ),
                        TextSpan(
                          text: '业余人员freego',
                          style: const TextStyle(color: ThemeUtil.buttonColor, fontSize: 18),
                          recognizer: TapGestureRecognizer()..onTap = () {
                            Clipboard.setData(const ClipboardData(text: '业务人员freego')).then((value){
                              ToastUtil.hint('复制成功');
                            });
                          }
                        ),
                        const TextSpan(
                          text: '”，\n马上去旅行!',
                          style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 18)
                        )
                      ]
                    ),
                  )
                ],
              )
              
            ),
          )
        ],
      ),
    );
  }
  
}
