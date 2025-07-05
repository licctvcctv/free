
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freego_flutter/components/user/delete_account.dart';
import 'package:freego_flutter/components/user/forget_password_reset.dart';
import 'package:freego_flutter/components/user_block/page/block_home.dart';
import 'package:freego_flutter/components/web_views/user_privacies.dart';
import 'package:freego_flutter/components/web_views/user_terms.dart';
import 'package:freego_flutter/http/http_user.dart';
import 'package:freego_flutter/model/user.dart';
import 'package:freego_flutter/provider/user_provider.dart';
import 'package:freego_flutter/util/local_user.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../model/user_fo.dart';

class UserSetPage extends StatelessWidget{
  const UserSetPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
        backgroundColor: ThemeUtil.backgroundColor,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      resizeToAvoidBottomInset: false,
      body: const UserSetWidget()
    );
  }
}

class UserSetWidget extends ConsumerStatefulWidget {
  const UserSetWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return UserSetState();
  }
}

class UserSetState extends ConsumerState{

  int? verifyStatus;
  final itemPadding = const EdgeInsets.fromLTRB(8, 10, 8, 10);
  final itemDecoration =  BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(4));

  onScreenTap() {
  }

  @override
  Widget build(BuildContext context) {
    var statusHeight = MediaQuery.of(context).viewPadding.top;
    final  verifyStatusName = getVerfyStatusName();
    return VisibilityDetector(
      key: const Key("video"),
      onVisibilityChanged: (VisibilityInfo visibilityInfo) {
        var visiblePercentage = visibilityInfo.visibleFraction * 100;
        if(visiblePercentage == 0){

        }
        else if(visiblePercentage == 100) {
            initData();
        }
      },
      child: GestureDetector(
        onTap: onScreenTap,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color.fromRGBO(242,245,250,1),
          child: Stack(
            children:[
              Column(
                children: [
                  SizedBox(height: statusHeight + 10,),
                  Container(
                    height: 50,
                    color: const Color.fromRGBO(203,211,220,1),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          child: IconButton(
                            onPressed: (){
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.arrow_back_ios_outlined, color: Colors.white,)
                          )
                        ),
                        const Center(
                          child:Text("个人设置", style: TextStyle(fontSize: 18, color: Colors.white))
                        )
                      ],
                    )
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      child: Column(
                        children: [
                          //个人信息设置
                          GestureDetector(
                            onTap: (){
                              Navigator.pushNamed(context, '/user/edit');
                            },
                            child: Container(
                              padding: itemPadding,
                              decoration: itemDecoration,
                              child: Row(
                                children: const [
                                  Icon(Icons.person),
                                  SizedBox(width: 6,),
                                  Text('个人信息'),
                                  Expanded(flex: 1, child: SizedBox()),
                                  Icon(Icons.arrow_forward_ios, size: 20,)
                                ],
                              ),
                            )
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () async {
                              if(verifyStatus == 0 || verifyStatus == 3 || verifyStatus == null) {
                                await Navigator.pushNamed(context, '/user/identity');
                                initData();
                                setState(() {
                                });
                              }
                            },
                            child: Container(
                              padding: itemPadding,
                              decoration: itemDecoration,
                              child: Row(
                                children: [
                                  const Icon(Icons.credit_card_outlined),
                                  const SizedBox(width: 6,),
                                  const Text('实名认证'),
                                  Expanded(
                                    flex:1, 
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(verifyStatusName, style: TextStyle(color:getVerifystatusColor()),),
                                    )
                                  ),
                                  const Icon(Icons.arrow_forward_ios, size: 20,)
                                ],
                              ),
                            )
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: (){
                              Navigator.pushNamed(context, '/user/invoice');
                            },
                            child: Container(
                              padding: itemPadding,
                              decoration: itemDecoration,
                              child: Row(
                                children: const [
                                  Icon(Icons.receipt_long),
                                  SizedBox(width: 6,),
                                  Text('发票信息'),
                                  Expanded(flex: 1, child: SizedBox()),
                                  Icon(Icons.arrow_forward_ios, size: 20,)
                                ],
                              ),
                            )
                          ),
                          //修改密码
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ForgetPasswordResetPage()),
                              );
                            },
                            child: Container(
                              padding: itemPadding,
                              decoration: itemDecoration,
                              child: Row(
                                children: const [
                                  Icon(Icons.password),
                                  SizedBox(width: 6,),
                                  Text('密码设置'),
                                  Expanded(flex: 1, child: SizedBox()),
                                  Icon(Icons.arrow_forward_ios, size: 20,)
                                ],
                              ),
                            )
                          ),
                          const SizedBox(height:10),
                          /*
                          Container(
                            padding: itemPadding,
                            decoration: itemDecoration,
                            child: Row(
                              children: const [
                                Icon(Icons.delete),
                                SizedBox(width: 6,),
                                Text('清除缓存'),
                                Expanded(flex: 1, child: SizedBox()),
                                Icon(Icons.arrow_forward_ios, size: 20,)
                              ],
                            ),
                          )
                          */
                          GestureDetector(
                            onTap: (){
                              Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                return const UserTermsPage();
                              }));
                            },
                            child: Container(
                              padding: itemPadding,
                              decoration: itemDecoration,
                              child: Row(
                                children: const [
                                  Icon(Icons.assignment),
                                  SizedBox(width: 6,),
                                  Text('用户协议'),
                                  Expanded(child: SizedBox()),
                                  Icon(Icons.arrow_forward_ios, size: 20,)
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10,),
                          GestureDetector(
                            onTap: (){
                              Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                return const UserPrivaciesPage();
                              }));
                            },
                            child: Container(
                              padding: itemPadding,
                              decoration: itemDecoration,
                              child: Row(
                                children: const [
                                  Icon(Icons.privacy_tip_outlined),
                                  SizedBox(width: 6,),
                                  Text('隐私协议'),
                                  Expanded(child: SizedBox()),
                                  Icon(Icons.arrow_forward_ios, size: 20,)
                                ]
                              )
                            )
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: (){
                              Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                return const BlockHomePage();
                              }));
                            },
                            child: Container(
                              padding: itemPadding,
                              decoration: itemDecoration,
                              child: Row(
                                children: const [
                                  Icon(Icons.block),
                                  SizedBox(width: 6,),
                                  Text('屏蔽设置'),
                                  Expanded(child: SizedBox()),
                                  Icon(Icons.arrow_forward_ios, size: 20)
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10,),
                          GestureDetector(
                            onTap: () async{
                              UserModel? user = await HttpUser.getUserInfo();
                              if(user == null){
                                ToastUtil.error('获取用户信息失败');
                                return;
                              }
                              if(mounted && context.mounted){
                                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                  return DeleteAccountPage(user: user);
                                }));
                              }
                            },
                            child: Container(
                              padding: itemPadding,
                              decoration: itemDecoration,
                              child: Row(
                                children: const [
                                  Icon(Icons.delete),
                                  SizedBox(width: 6,),
                                  Text('注销用户'),
                                  Expanded(child: SizedBox()),
                                  Icon(Icons.arrow_forward_ios, size: 20)
                                ],
                              ),
                            ),
                          )
                        ],
                      )
                    )
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0) ,
                    child: ElevatedButton(
                      onPressed: (){
                        loginOut();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.fromLTRB(0, 14, 0, 14)
                      ),
                      child: const Text('退出登录',style:TextStyle(color:Color.fromRGBO(245, 113, 84, 1))),     
                    )
                  ),
                  const SizedBox(height: 14,)
                ],
              )
            ]
          )
        ),
        //color: Color.fromRGBO(242,245,250,1),
      )
    );
  }

  loginOut() {
    showDialog(
      context: context,
      builder: (buildContext){
        return AlertDialog(
          title: const Text('提示'),
          content: const Text('确定退出登录'),
          actions: [
            FilledButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  return Colors.grey;
                }),
              ),
              onPressed: (){
                Navigator.of(buildContext).pop();
              },
              child: const Text('取消')
            ),
            FilledButton(
              onPressed: (){
                LocalUser.logout();
                Navigator.of(context).popUntil((route) => route.isFirst);
              }, 
              child: const Text('确定')
            )
          ],
        );
      }
    );
    // Navigator.of(context)
    //  .pushNamedAndRemoveUntil('/index', (Route<dynamic> route) => false);
  }

  @override
  void initState() {
    super.initState();
    initData();
  }

  String getVerfyStatusName() {
    Map statusName = {
      0: '未认证',
      1: '认证中',
      2: '认证通过',
      3: '认证不通过'
    };
    if(verifyStatus == null) {
      return '未认证';
    }
    return statusName[verifyStatus!];
  }

  Color getVerifystatusColor() {
    switch(verifyStatus) {
      case null:
      case 0:
      case 3:
        return Colors.red;
      case 1:
        return Colors.black54;
      case 2:
        return const Color.fromRGBO(4, 182, 221, 1);
    }
    return Colors.red;
  }

  initData() {
    UserFoModel userFo  = ref.read(userFoProvider);
    verifyStatus = userFo.verifyStatus;
  }

}
