import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/user/code_login.dart';
import 'package:freego_flutter/components/user/forget_password.dart';
import 'package:freego_flutter/components/web_views/user_privacies.dart';
import 'package:freego_flutter/components/web_views/user_terms.dart';
import 'package:freego_flutter/http/http_user.dart';
import "package:freego_flutter/model/user.dart";
import 'package:freego_flutter/util/ali_login.dart';
import 'package:freego_flutter/util/apple_login.dart';
import 'package:freego_flutter/util/local_user.dart';
import 'package:freego_flutter/util/regular_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:freego_flutter/util/wx_login.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: ThemeUtil.statusBarThemeLight,
      ),
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: const LoginWidget(),
      ),
    );
  }
}

class LoginWidget extends ConsumerStatefulWidget{
  const LoginWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return LoginState();
  }

}

class LoginState extends ConsumerState<LoginWidget>{

  String phone = '';
  String password = '';
  bool isAgree = false;

  bool isWechatAvailable = false;
  bool isAlipayAvailable = false;
  bool isAppleAvailable = false;

  Widget svgApple = SvgPicture.asset('svg/apple.svg');

  @override
  void initState(){
    super.initState();
    Future.delayed(Duration.zero, () async{
      isWechatAvailable = await WxLogin.check();
      resetState();
    });
    Future.delayed(Duration.zero, () async{
      isAlipayAvailable = await AlipayLogin.check();
      resetState();
    });
    Future.delayed(Duration.zero, () async{
      isAppleAvailable = await AppleLogin().check();
      resetState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("images/bg.png"),
          fit: BoxFit.fill
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FractionallySizedBox(
              widthFactor: 0.9,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(255, 255, 255, 0.5),
                  borderRadius: BorderRadius.all(Radius.circular(8))
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 30,),
                    Platform.isIOS ?
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: InkWell(
                            onTap: (){
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              alignment: Alignment.center,
                              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white,),
                            ),
                          ),
                        ),
                        const Align(
                          alignment: Alignment.center,
                          child: Text(
                            "登录/注册",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white
                            ),
                          ),
                        )
                      ],
                    ) :
                    const Text(
                      "登录/注册",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    TextField(
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8))
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(8))
                        ),
                        labelText: '手机号码',
                        labelStyle: TextStyle(color: Colors.white)
                      ),
                      onChanged: (value){
                        phone = value;
                      },
                    ),
                    const SizedBox(height: 30,),
                    TextField(
                      keyboardType: TextInputType.multiline,
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        labelText: '密码',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      onChanged: (value){
                        password = value;
                      },
                    ),
                    const SizedBox(height: 30,),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith<Color?>((states){
                          if(states.contains(MaterialState.pressed)){
                            return Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.5);
                          }
                          return Colors.white;
                        }),
                        padding: MaterialStateProperty.resolveWith<EdgeInsets?>((states){
                          return const EdgeInsets.fromLTRB(40, 10, 40, 10);
                        })
                      ),
                      onPressed: (){
                        if(phone.isEmpty || password.isEmpty){
                          ToastUtil.error('手机号和密码不能为空');
                          return;
                        }
                        if(!RegularUtil.checkPhone(phone)){
                          ToastUtil.error('手机号格式错误');
                          return;
                        }
                        if(!isAgree){
                          ToastUtil.error('请勾选用户协议');
                          return;
                        }
                        HttpUser.login(phone, password, ((isSuccess, data, msg, code) async {
                          if(isSuccess){
                            UserModel user = UserModel.fromJson(data);
                            LocalUser.login(user);
                            if(mounted && context.mounted){
                              Navigator.of(context).pop();
                            }
                          }
                          else{
                            ToastUtil.error(msg.toString());
                          }
                        }));
                      }, 
                      child: const Text(
                        '登录',
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
                              return const CodeLoginPage();
                            }));
                          },
                          child: const Text(
                            '验证码登录',
                            style: TextStyle(
                              color: Colors.white
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: (){
                            Navigator.of(context).push(MaterialPageRoute(builder: (context){
                              return const ForgetPasswordWidget();
                            }));
                          },
                          child: const Text(
                            '忘记密码',
                            style: TextStyle(
                              color: Colors.white
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20,),
            FractionallySizedBox(
              widthFactor: 0.9,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Radio(
                    value: true, 
                    groupValue: isAgree, 
                    toggleable: true,
                    onChanged: (val){
                      isAgree = !isAgree;
                      setState(() {
                      });
                    },
                    fillColor: MaterialStateProperty.resolveWith((states){
                      if(states.contains(MaterialState.selected)){
                        return Colors.white;
                      }
                      else{
                        return const Color.fromRGBO(255, 255, 255, 0.6);
                      }
                    })
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: '您使⽤本软件及服务！为使⽤本软件及服务，您应当阅读并遵守本协议，以及'
                          ),
                          TextSpan(
                            text: '《服务协议》',
                            recognizer: TapGestureRecognizer()..onTap = (){
                              Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                return const UserTermsPage();
                              }));
                            },
                            style: const TextStyle(color: Colors.lightBlue)
                          ),
                          const TextSpan(
                            text: '、'
                          ),
                          TextSpan(
                            text: '《隐私政策》',
                            recognizer: TapGestureRecognizer()..onTap = (){
                              Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                return const UserPrivaciesPage();
                              }));
                            },
                            style: const TextStyle(color: Colors.lightBlue)
                          ),
                          const TextSpan(
                            text: '。请您务必审慎阅读、充分理解各条款内容，特别是免除或者限制我⽅责任的条款、对⽤ 户权利进⾏限制的条款。'
                          )
                        ]
                      ),
                    ),
                  ),
                  const SizedBox(width: 20,),
                ],
              ),
            ),
            const SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const SizedBox(),
                if(isAlipayAvailable)
                InkWell(
                  onTap: () async{
                    if(!isAgree){
                      ToastUtil.error('请勾选用户协议');
                      return;
                    }
                    UserModel? user = await AlipayLogin.aliLogin();
                    if(user == null){
                      ToastUtil.error('支付宝登录失败');
                      return;
                    }
                    LocalUser.login(user);
                    if(context.mounted){
                      Navigator.of(context).pop(true);
                    }
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(9999))
                    ),
                    child: Image.asset('images/pay_alipay.png', fit: BoxFit.cover),
                  ),
                ),
                if(isWechatAvailable)
                InkWell(
                  onTap: () async{
                    if(!isAgree){
                      ToastUtil.error('请勾选用户协议');
                      return;
                    }
                    bool result = await WxLogin.wxLogin(callback: (user) async{
                      if(user == null){
                        ToastUtil.error('微信登录失败');
                        return;
                      }
                      LocalUser.login(user);
                      if(context.mounted){
                        Navigator.of(context).pop(true);
                      }
                    });
                    if(!result){
                      ToastUtil.error('微信登录失败');
                    }
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(9999))
                    ),
                    child: Image.asset('images/pay_weixin.png', fit: BoxFit.cover,),
                  ),
                ),
                if(isAppleAvailable)
                InkWell(
                  onTap: () async{
                    if(!isAgree){
                      ToastUtil.error('请勾选用户协议');
                      return;
                    }
                    UserModel? user =  await AppleLogin().login();
                    if(user == null){
                      ToastUtil.error('苹果登录失败');
                      return;
                    }
                    LocalUser.login(user);
                    if(mounted && context.mounted){
                      Navigator.of(context).pop(true);
                    }
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(9999))
                    ),
                    child: svgApple,
                  ),
                ),
                const SizedBox(),
              ],
            )
          ],
        ),
      ),
    );
  }

  void resetState(){
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }
}
