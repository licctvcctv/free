
import 'package:flutter/material.dart';
import 'package:freego_flutter/http/http_user.dart';
import 'package:freego_flutter/util/local_user.dart';
import 'package:freego_flutter/util/regular_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';

class ForgetPasswordResetPage extends StatefulWidget{
  const ForgetPasswordResetPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return ForgetPasswordResetState();
  }

}

class ForgetPasswordResetState extends State<ForgetPasswordResetPage>{

  String password = '';
  String password2 = '';

  @override
  Widget build(BuildContext context) {
    bool isLogin =  LocalUser.isLogined();
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
                        '重置密码',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                      ),
                      const SizedBox(height: 30,),
                      TextField(
                        keyboardType: TextInputType.multiline,
                        obscureText: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8.0))
                          ),
                          enabledBorder: OutlineInputBorder(
                            // width: 0.0 produces a thin "hairline" border
                            borderSide: BorderSide(color: Colors.white, width: 1.0),
                            borderRadius: BorderRadius.all(Radius.circular(8.0))
                          ),
                          labelText: '新密码',
                          labelStyle: TextStyle(color: Colors.white)
                        ),
                        onChanged: (val) {
                          password = val;
                        },
                      ),
                      const SizedBox(height: 30,),
                      TextField(
                        keyboardType: TextInputType.multiline,
                        obscureText: true,
                        onChanged: (val) {
                          password2 = val;
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8.0))
                          ),
                          enabledBorder: OutlineInputBorder(
                          // width: 0.0 produces a thin "hairline" border
                          borderSide: BorderSide(color: Colors.white, width: 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(8.0))),
                          labelText: '确认密码',
                          labelStyle: TextStyle(color: Colors.white),
                        )
                      ),
                      const SizedBox(height: 30,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: (){
                              Navigator.of(context).pop();
                            }, 
                            child: const Text('返回上一页', style: TextStyle(color: Colors.white),)
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
                              if(!RegularUtil.checkPassword(password)){
                                ToastUtil.warn('密码格式错误，至少包含一位数字和一位字母');
                                return;
                              }
                              if(password != password2){
                                ToastUtil.warn('两次密码不一致');
                                return;
                              }
                              bool result = await HttpUser.passwordModify(password);
                              if(!result){
                                ToastUtil.error('密码修改失败');
                                return;
                              }
                              ToastUtil.hint('密码修改成功');
                              if(context.mounted){
                                if(isLogin) {
                                  Navigator.of(context).pop();
                                } else{
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                }
                              }
                            }, 
                            child: const Text('确认', style: TextStyle(color: Colors.black54),)
                          )
                        ],
                      ),
                      const SizedBox(height: 30,)
                    ],
                  )
                )
              )
            ],
          ),
        ),
      )
    );
  }
}
