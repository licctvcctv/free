
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:freego_flutter/components/user/delete_account_http.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/model/user.dart';
import 'package:freego_flutter/util/ali_login.dart';
import 'package:freego_flutter/util/apple_login.dart';
import 'package:freego_flutter/util/local_user.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:freego_flutter/util/wx_login.dart';

class DeleteAccountPage extends StatelessWidget{
  final UserModel user;
  const DeleteAccountPage({required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 10,
        backgroundColor: ThemeUtil.backgroundColor,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: DeleteAccountWidget(user: user),
      ),
    );
  }
  
}

class DeleteAccountWidget extends StatefulWidget{
  final UserModel user;
  const DeleteAccountWidget({required this.user, super.key});

  @override
  State<StatefulWidget> createState() {
    return DeleteAccountState();
  }

}

class DeleteAccountState extends State<DeleteAccountWidget>{

  static const String stepOneName = '确认信息';
  static const String stepTwoName = '填写验证码';

  static const double stepIconSize = 60;
  static const double avatarSize = 100;
  static const int cooldownSeconds = 60;

  int step = 0;
  PageController pageController = PageController();
  Timer? cooldownTimer;
  int coolDown = 0;
  String code = '';

  @override
  void dispose(){
    pageController.dispose();
    cooldownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeUtil.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonHeader(
            center: Text('注销账号', style: TextStyle(color: Colors.white, fontSize: 18),),
          ),
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.fromBorderSide(BorderSide(color: step == 0 ? Colors.blue : Colors.grey, width: 5))
                          ),
                          width: stepIconSize,
                          height: stepIconSize,
                          alignment: Alignment.center,
                          child: Text('1', style: TextStyle(color: step == 0 ? Colors.blue : Colors.grey),),
                        ),
                        const SizedBox(height: 10,),
                        Text(stepOneName, style: TextStyle(color: step == 0 ? Colors.blue : Colors.grey, fontWeight: FontWeight.bold, fontSize: 16),)
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.fromBorderSide(BorderSide(color: step == 1 ? Colors.blue : Colors.grey, width: 5))
                          ),
                          width: stepIconSize,
                          height: stepIconSize,
                          alignment: Alignment.center,
                          child: Text('2', style: TextStyle(color: step == 1 ? Colors.blue : Colors.grey),),
                        ),
                        const SizedBox(height: 10,),
                        Text(stepTwoName, style: TextStyle(color: step == 1 ? Colors.blue : Colors.grey, fontWeight: FontWeight.bold, fontSize: 16),)
                      ],
                    )
                  ],
                ),
                const Divider(),
                Expanded(
                  child: PageView.builder(
                    physics: const ClampingScrollPhysics(),
                    controller: pageController,
                    itemCount: 2,
                    itemBuilder: (context, index){
                      if(index == 0){
                        return getStepOneWidget(); 
                      }
                      else{
                        return getStepTwoWidget();
                      }
                    },
                  ),
                )
              ],
            )         
          )
        ],
      ),
    );
  }

  void pageTo(int index){
    pageController.animateToPage(1, duration: const Duration(milliseconds: 350), curve: Curves.ease);
    step = index;
    setState(() {
    });
  }

  Widget getStepTwoWidget(){
    double width = MediaQuery.of(context).size.width;
    String? phone = widget.user.phone;
    if(phone != null && phone.isNotEmpty){
      return ListView(
        children: [
          const SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: width * 0.8,
                child: const Text('*您正在注销账户！', style: TextStyle(color: Colors.redAccent,),),
              )
            ],
          ),
          const SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: width * 0.8,
                child: const Text('请输入验证码', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
              )
            ],
          ),
          const SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: width * 0.8,
                height: 60,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border.fromBorderSide(BorderSide(color: ThemeUtil.foregroundColor)),
                          borderRadius: BorderRadiusDirectional.horizontal(start: Radius.circular(10))
                        ),
                        alignment: Alignment.center,
                        child: TextField(
                          maxLines: 1,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: '验证码',
                            hintStyle: TextStyle(color: Colors.grey),
                            isDense: true,
                            contentPadding: EdgeInsets.fromLTRB(8, 10, 8, 10),
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 18),
                          onChanged: (code){
                            this.code = code;
                          },
                        ),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap
                      ),
                      onPressed: coolDown <= 0 ? sendCode : null,
                      child: Container(
                        width: width * 0.26,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border.fromBorderSide(BorderSide(color: ThemeUtil.foregroundColor)),
                          borderRadius: BorderRadiusDirectional.horizontal(end: Radius.circular(10))
                        ),
                        alignment: Alignment.center,
                        child: coolDown > 0 ?
                        Text('$coolDown s', style: const TextStyle(color: Colors.grey),) :
                        const Text('发送', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),)
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 40,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap
                ),
                onPressed: (){
                  code = code.trim();
                  if(code.isEmpty){
                    ToastUtil.warn('请输入验证码');
                    return;
                  }
                  closeAccount((){
                    ToastUtil.hint('注销成功');
                    Timer.periodic(const Duration(seconds: 3), (timer) {
                      LocalUser.logout();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    });
                  });
                },
                child: Container(
                  width: width * 0.6,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                  alignment: Alignment.center,
                  child: const Text('确 认 注 销', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),),
                ),
              )
            ],
          )
        ],
      );
    }
    else{
      const String checkStr = "确认注销";
      String? wxUnionId = widget.user.wxUnionId;
      String? alipayUserId = widget.user.alipayUserId;
      String? appleId = widget.user.appleUserId;
      return ListView(
        children: [
          const SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: width * 0.8,
                child: const Text('*您正在注销账户！', style: TextStyle(color: Colors.redAccent,),),
              )
            ],
          ),
          const SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: width * 0.8,
                child: const Text('请输入“$checkStr”', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
              )
            ],
          ),
          const SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: width * 0.8,
                height: 60,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border.fromBorderSide(BorderSide(color: ThemeUtil.foregroundColor)),
                          borderRadius: BorderRadiusDirectional.horizontal(start: Radius.circular(10))
                        ),
                        alignment: Alignment.center,
                        child: TextField(
                          maxLines: 1,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            hintText: checkStr,
                            hintStyle: TextStyle(color: Colors.grey),
                            isDense: true,
                            contentPadding: EdgeInsets.fromLTRB(8, 10, 8, 10),
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 18),
                          onChanged: (code){
                            this.code = code;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 40,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap
                ),
                onPressed: (){
                  code = code.trim();
                  if(code != checkStr){
                    ToastUtil.error('验证错误');
                    return;
                  }
                  if(wxUnionId != null && wxUnionId.isNotEmpty){
                    deleteByWechat(onCloseSuccess);
                  }
                  else if(alipayUserId != null && alipayUserId.isNotEmpty){
                    deleteByAlipay(onCloseSuccess);
                  }
                  else if(appleId != null){
                    deleteByApple(onCloseSuccess);
                  }
                },
                child: Container(
                  width: width * 0.6,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                  alignment: Alignment.center,
                  child: const Text('确 认 注 销', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),),
                ),
              )
            ],
          )
        ],
      );
    }
  }

  Widget getStepOneWidget(){
    String? avatar = widget.user.head;
    String? username = widget.user.name;
    String? phone = widget.user.phone;
    return ListView(
      children: [
        const SizedBox(height: 20,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: SizedBox(
                width: avatarSize,
                height: avatarSize,
                child: avatar != null ?
                Image.network(getFullUrl(avatar)) :
                ThemeUtil.defaultUserHead
              ),
            )
          ],
        ),
        const SizedBox(height: 20,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(username ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 18),)
          ],
        ),
        const SizedBox(height: 20,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap
              ),
              onPressed: (){
                if(phone != null && phone.isNotEmpty){
                  sendCode(onSuccess: (){
                    pageTo(1);
                  });
                }
                else{
                  pageTo(1);
                }
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6,
                height: 52,
                decoration: const BoxDecoration(
                  color: Colors.lightBlue,
                  borderRadius: BorderRadius.all(Radius.circular(10))
                ),
                alignment: Alignment.center,
                child: const Text('下 一 步', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),),
              ),
            )
          ],
        ),
      ]
    );
  }

  void onCloseSuccess(){
    ToastUtil.hint('注销成功');
    LocalUser.logout();
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if(mounted && context.mounted){
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });
  }

  void closeAccount(Function()? onSuccess){
    DeleteAccountHttp().closeAccount(
      code: code,
      onSuccess: (response){
        onSuccess?.call();
      },
      onFail: (response){
        String? message = response.data['message'];
        message ??= '注销失败';
        ToastUtil.error(message);
      }
    );
  }

  Future deleteByApple(Function()? onSuccess) async{
    String? code = await AppleLogin().getIdentityToken();
    if(code == null){
      ToastUtil.error('授权失败');
      return;
    }
    DeleteAccountHttp().closeAccountByApple(code: code, onSuccess: (response){
      onSuccess?.call();
    }, onFail: (response){
      String? message = response.data['message'];
      message ??= '注销失败';
      ToastUtil.error(message);
    });
  }

  Future deleteByAlipay(Function()? onSuccess) async{
    String? code = await AlipayLogin.doAuth();
    if(code == null){
      ToastUtil.error('授权失败');
      return;
    }
    DeleteAccountHttp().closeAccountByWechat(code: code, onSuccess: (response){
      onSuccess?.call();
    }, onFail: (response){
      String? message = response.data['message'];
      message ??= '注销失败';
      ToastUtil.error(message);
    });
  }
  
  void deleteByWechat(Function()? onSuccess){
    WxLogin.wxCode(success: (code){
      DeleteAccountHttp().closeAccountByWechat(code: code, onSuccess: (response){
        onSuccess?.call();
      }, onFail: (response){
        String? message = response.data['message'];
        message ??= '注销失败';
        ToastUtil.error(message);
      });
    });
  }

  void sendCode({Function()? onSuccess}){
    DeleteAccountHttp().sendCode(
      onSuccess: (response){
        onSuccess?.call();
      },
      onFail: (response){
        String? message = response.data['message'];
        message ??= '发送失败';
        ToastUtil.error(message);
      }
    );
    coolDown = cooldownSeconds;
    cooldownTimer?.cancel();
    cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) { 
      --coolDown;
      if(mounted && context.mounted){
        setState(() {
        });
      }
      if(coolDown <= 0){
        timer.cancel();
      }
    });
    setState(() {
    });
  }
}
