
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freego_flutter/components/user/forget_password_reset.dart';
import 'package:freego_flutter/http/http_user.dart';
import 'package:freego_flutter/model/user.dart';
import 'package:freego_flutter/util/regular_util.dart';
import 'package:freego_flutter/util/storage.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';

class ForgetPasswordWidget extends StatefulWidget{
  const ForgetPasswordWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return ForgetPasswordState();
  }

}

class ForgetPasswordState extends State<ForgetPasswordWidget>{

  static const COOL_DOWN_VALUE = 60;

  String phone = '';
  String code = '';
  bool hasSend = false;
  int coolDown = 0;
  Timer? timer;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
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
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/bg.png"),
              fit: BoxFit.fill
            )
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FractionallySizedBox(
                widthFactor: 0.9,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 10.0, bottom: 10.0, left: 20.0, right: 20.0
                  ),
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 0.5),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 30,),
                      const Text(
                        "找回密码",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                      ),
                      const SizedBox(height: 30,),
                      TextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8.0))
                          ),
                          enabledBorder: OutlineInputBorder(
                            // width: 0.0 produces a thin "hairline" border
                            borderSide: BorderSide(color: Colors.white, width: 1.0),
                            borderRadius: BorderRadius.all(Radius.circular(8.0))
                          ),
                          labelText: '手机号码',
                          labelStyle: TextStyle(color: Colors.white)
                        ),
                        onChanged: (val) {
                          phone = val;
                        },
                      ),
                      const SizedBox(height: 30,),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(6), // 限制验证码长度
                              ],
                              autofillHints: const [AutofillHints.oneTimeCode],
                              onChanged: (val){
                                // 防止自动填充重复输入
                                if (val.length <= 6) {
                                  code = val;
                                }
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(8.0))
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white, width: 1.0),
                                  borderRadius: BorderRadius.all(Radius.circular(8.0))
                                ),
                                labelText: '验证码',
                                labelStyle: TextStyle(color: Colors.white),
                              )
                            ),
                          ),
                          const SizedBox(width: 24,),
                          SizedBox(
                            height: 45,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.lightBlue,
                                minimumSize: Size.zero,
                                padding: EdgeInsets.zero
                              ),
                              onPressed: () async{
                                if(phone.isEmpty){
                                  ToastUtil.error('手机号不能为空');
                                  return;
                                }
                                if(!RegularUtil.checkPhone(phone)){
                                  ToastUtil.warn('手机号格式错误');
                                  return;
                                }
                                bool result = await HttpUser.sendCodeForForgetPassword(phone, fail: (response){
                                  ToastUtil.warn(response.data['message']);
                                }, success: (response){
                                  ToastUtil.hint('验证码发送成功');
                                });
                                if(result){
                                  hasSend = true;
                                  setState(() {
                                  });
                                }
                                if(coolDown > 0){
                                  return;
                                }
                                coolDown = COOL_DOWN_VALUE;
                                timer = Timer.periodic(const Duration(seconds: 1), (timer) { 
                                  --coolDown;
                                  if(coolDown <= 0){
                                    coolDown = 0;
                                    timer.cancel();
                                  }
                                  setState(() {
                                  });
                                });

                              }, 
                          child: Container(
                            alignment: Alignment.center,
                            width: 80,
                            height: 40,
                            child: 
                            coolDown <= 0 ?
                            const Text('发送', style: TextStyle(color: Colors.black54),) :
                            Text('发送($coolDown)', style: const TextStyle(color: Colors.grey),)
                          )
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: (){
                              Navigator.of(context).pop();
                            }, 
                            child: const Text('返回登录页', style: TextStyle(color: Colors.white),)
                          ),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                                  if (states.contains(MaterialState.pressed)) {
                                    return Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.5);
                                  }
                                  return Colors.white; // Use the component's default.
                                }
                              ), 
                              padding: MaterialStateProperty.resolveWith<EdgeInsets?>(
                                (Set<MaterialState> states) {
                                  return const EdgeInsets.only(
                                    top: 10.0, bottom: 10.0, left: 40.0, right: 40.0);
                                }
                              )
                            ),
                            onPressed: () async{
                              if(!RegularUtil.checkPhone(phone)){
                                ToastUtil.warn('手机号格式错误');
                                return;
                              }
                              if(!RegularUtil.checkCode(code)){
                                ToastUtil.warn('验证码格式错误');
                                return;
                              }
                              UserModel? user = await HttpUser.passwordResetCodeCheck(phone, code);
                              if(user == null){
                                return;
                              }
                              await Storage.saveInfo('user_token', user.token);
                              await Storage.saveInfo('user_id', user.id);
                              await Storage.saveInfo('user_name', user.name);
                              await Storage.saveInfo('user_head', user.head);
                              await Storage.saveInfo('user_identity_type', user.identityType);
                              if(context.mounted){
                                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                  return const ForgetPasswordResetPage();
                                }));
                              }
                            }, 
                            child: const Text('提交', style: TextStyle(color: Colors.lightBlue),)
                          ),
                        ],
                      ),
                      const SizedBox(height: 30,)
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 100,)
            ],
          ),
        ),
      ),
    );
  }

}
