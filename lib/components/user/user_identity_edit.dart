
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freego_flutter/http/http_user.dart';
import 'package:freego_flutter/model/user_fo.dart';
import 'package:freego_flutter/provider/user_provider.dart';
import 'package:freego_flutter/util/dialog_util.dart';
import 'package:freego_flutter/util/regular_util.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/toast_util.dart';

class UserIdentityEditPage extends StatelessWidget{
  const UserIdentityEditPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      )
    );
    return const Scaffold(
      extendBodyBehindAppBar: true,
      body: UserIdentityEditWidget()
    );
  }
}

class UserIdentityEditWidget extends ConsumerStatefulWidget {
  const UserIdentityEditWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return UserIdentityEditState();
  }
}

class UserIdentityEditState extends ConsumerState{

  String? identityNum;
  String? realName;

  FocusNode nameFocusNode = FocusNode();
  FocusNode identityFocusNode = FocusNode();

  late TextEditingController nameController;
  late TextEditingController identityController;

  @override
  void initState() {
    super.initState();
    UserFoModel userFo  = ref.read(userFoProvider);
    realName = userFo.realName;
    identityNum = userFo.identityNum;
    // basicInfo['head'] =userFo.head!=null?userFo.head!:null;
    // basicInfo['name'] = userFo.name;
    // basicInfo['sex'] = userFo.sex;
    // basicInfo['birthday'] = userFo.birthday;
    // basicInfo['description'] = userFo.description;

    nameController = TextEditingController(text: realName);
    identityController = TextEditingController(text: identityNum);
  }

  @override
  void dispose(){
    nameFocusNode.dispose();
    identityFocusNode.dispose();
    nameController.dispose();
    identityController.dispose();
    super.dispose();
  }

  onScreenTap() {
    nameFocusNode.unfocus();
    identityFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    var statusHeight = MediaQuery.of(context).viewPadding.top;
    return GestureDetector(
      onTap: onScreenTap,
      child:Container(
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
                  color: const Color.fromRGBO(203, 211, 220, 1),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        child: IconButton(
                          onPressed: (){
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_back_ios_outlined,color: Colors.white,)
                        )
                      ),
                      const Center(
                        child:Text("实名认证",style:TextStyle(fontSize: 18,color: Colors.white))
                      )
                    ],
                  )
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                    child: Column(
                      children:[
                        //个人信息设置
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("姓名",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                              Container(
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                child: TextField(
                                  textAlign: TextAlign.center,
                                  focusNode: nameFocusNode,
                                  controller: nameController,
                                  onChanged: (value){
                                    realName = value.trim();
                                  },
                                  decoration: const InputDecoration(
                                    hintText: "请填写你的真实姓名",
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Color.fromRGBO(153, 153, 153, 0.1)),
                                    )
                                  )
                                )
                              ),
                              const SizedBox(height: 50,),
                              const Text("身份证号",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                              const SizedBox(height: 10,),
                              Container(
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                alignment: Alignment.center,
                                child: TextField(
                                  focusNode: identityFocusNode,
                                  textAlign: TextAlign.center,
                                  controller: identityController,
                                  onChanged: (value){
                                    identityNum = value.trim();
                                  },
                                  decoration: const InputDecoration(
                                    hintText: "请填写你的身份证号",
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Color.fromRGBO(153, 153, 153, 0.2)),
                                    )
                                  )
                                )
                              ),
                              const SizedBox(height: 40,),
                              const Padding(
                                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                                child: Text('注：实名信息通过后无法修改，请填写真实个人信息', style: TextStyle(color: Colors.red),),
                              )
                            ],
                          )
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0) ,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromRGBO(4, 182, 221, 1),
                              padding: const EdgeInsets.fromLTRB(0, 14, 0, 14)
                            ),
                            onPressed: (){
                              saveUser();
                            },
                            child: const Text('保存',style:TextStyle(color:Colors.white)),
                          )
                        ),
                        const SizedBox(height: 14,)
                      ],
                    )
                  )
                ),
              ],
            )
          ]
        )
      ),
    );
  }

  saveUser() {
    onScreenTap();
    try{
      checkUser();
    }
    catch(e) {
      ToastUtil.error(e.toString());
      return;
    }
    DialogUtil.showProgressDlg(context);
    HttpUser.saveIdentity(realName!, identityNum!, (isSuccess, data, msg, code) {
      DialogUtil.closeProgressDlg();
      if(isSuccess) {
        ref.read(userFoProvider.notifier).update((state){
          state.realName = realName;
          state.identityNum = identityNum;
          state.verifyStatus = 2;
          return state;
        });
        ToastUtil.hint("修改成功");
        Timer.periodic(const Duration(seconds: 1), (timer) { //callback function
          //1s 回调一次
          timer.cancel();  // 取消定时器
          Navigator.pop(context);
        });
      }
      else {
        ToastUtil.error(msg ?? '修改失败');
      }
    });
  }

  checkUser() {
    if(StringUtil.isEmpty(realName)) {
      throw '真实姓名不能为空';
    }
    if(StringUtil.isEmpty(identityNum)) {
      throw '身份证号不能为空';
    }
    if(!RegularUtil.checkIdCard(identityNum ?? '')){
      throw '身份证号格式错误';
    }
  }

}
