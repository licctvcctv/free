
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

class UserInvoiceEditPage extends StatelessWidget{
  const UserInvoiceEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent
    ));
    return const Scaffold(
      extendBodyBehindAppBar: true,
      body: UserInvoiceEditWidget()
    );
  }
}

class UserInvoiceEditWidget extends ConsumerStatefulWidget {
  const UserInvoiceEditWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return UserInvoiceEditState();
  }
}

class UserInvoiceEditState extends ConsumerState{

  String? identityNum;
  int billType = 0;
  String? billTitle;
  String? billAccount;
  String? billAccountBank;
  String? billTaxNum;
  String? billNoticeEmail;
  String? billAddress;
  Color tabColorOn = const Color.fromRGBO(4, 182, 221, 1);
  Color tabColorOff = Colors.white;

  final inputDecoration = const InputDecoration(
    isDense: true,
    contentPadding: EdgeInsets.fromLTRB(4, 10, 0, 10),
    filled:true,
    fillColor: Colors.white,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(4.0)),
      borderSide:  BorderSide(color:Color.fromRGBO(0, 0, 0, 0.1), width: 2.0)
    ),
    focusedBorder:  OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(4.0)),
      borderSide:  BorderSide(color:Color.fromRGBO(0, 0, 0, 0.1), width: 2.0)
    )
  );

  TextEditingController billTitleController = TextEditingController();
  TextEditingController billAddressController = TextEditingController();
  TextEditingController billAccountController = TextEditingController();
  TextEditingController billAccountBankController = TextEditingController();
  TextEditingController billTaxNumController = TextEditingController();
  TextEditingController billNoticeEmailController = TextEditingController();

  static const double FIELD_WIDTH = 100;

  @override
  void dispose(){
    billTitleController.dispose();
    billAddressController.dispose();
    billAccountController.dispose();
    billAccountBankController.dispose();
    billTaxNumController.dispose();
    billNoticeEmailController.dispose();
    super.dispose();
  }

  onScreenTap() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }


  @override
  Widget build(BuildContext context) {
    var statusHeight = MediaQuery.of(context).viewPadding.top;
    return GestureDetector(
      onTap: onScreenTap,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color.fromRGBO(242, 245, 250, 1),
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
                          icon: const Icon(Icons.arrow_back_ios_outlined, color: Colors.white,)
                        )
                      ),
                      const Center(
                        child: Text("发票信息", style:TextStyle(fontSize: 18,color: Colors.white))
                      )
                    ],
                  )
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20,20),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: (){
                            setBillType(1);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: billType == 1 ? tabColorOn : tabColorOff,
                              borderRadius: const BorderRadius.horizontal(left:Radius.circular(6))
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Text('公司单位', style: TextStyle(color: billType == 1 ? Colors.white: Colors.black),)
                          ),
                        )
                      ),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: (){
                            setBillType(0);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: billType == 0 ? tabColorOn : tabColorOff,
                              borderRadius: const BorderRadius.horizontal(right:Radius.circular(6))
                            ),
                            child: Text('个人/非企业单位', style: TextStyle(color: billType == 0 ? Colors.white: Colors.black))
                          ),
                        )
                      )
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: double.infinity,
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //个人信息设置
                        Expanded(
                          flex: 1,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: FIELD_WIDTH,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: const [
                                            Text("发", textAlign: TextAlign.justify, style: TextStyle(fontSize: 16.0, color: Colors.black54,)),
                                            Text("票", textAlign: TextAlign.justify, style: TextStyle(fontSize: 16.0, color: Colors.black54,)),
                                            Text("抬", textAlign: TextAlign.justify, style: TextStyle(fontSize: 16.0, color: Colors.black54,)),
                                            Text("头", textAlign: TextAlign.justify, style: TextStyle(fontSize: 16.0, color: Colors.black54,)),
                                          ],
                                        )
                                      ),
                                      const Text(" : "),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: TextField(
                                            controller: billTitleController,
                                            //style: TextStyle(height: 1),
                                            decoration: inputDecoration,
                                            onChanged: (value){
                                              billTitle = value;
                                            },
                                          ),
                                        )
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: FIELD_WIDTH,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: const [
                                            Text("地", textAlign: TextAlign.justify, style: TextStyle(fontSize: 16.0, color: Colors.black54)),
                                            Text("址", textAlign: TextAlign.justify, style: TextStyle(fontSize: 16.0, color: Colors.black54)),
                                          ],
                                        )
                                      ),
                                      const Text(" : "),
                                      Expanded(
                                        flex:1,
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: TextField(
                                            //style: TextStyle(height: 1),
                                            controller: billAddressController,
                                            decoration: inputDecoration,
                                            onChanged: (value){
                                              // = value;
                                              billAddress = value;
                                            },
                                          )
                                        )
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: FIELD_WIDTH,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: const [
                                            Text("银", textAlign: TextAlign.justify, style: TextStyle(fontSize: 16.0, color: Colors.black54)),
                                            Text("行", textAlign: TextAlign.justify, style: TextStyle(fontSize: 16.0, color: Colors.black54)),
                                            Text("账", textAlign: TextAlign.justify, style: TextStyle(fontSize: 16.0, color: Colors.black54)),
                                            Text("号", textAlign: TextAlign.justify, style: TextStyle(fontSize: 16.0, color: Colors.black54)),
                                          ],
                                        )
                                      ),
                                      const Text(" : "),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: TextField(
                                            controller: billAccountController,
                                            //style: TextStyle(height: 1),
                                            decoration: inputDecoration,
                                            onChanged: (value){
                                              // = value;
                                              billAccount = value;
                                            },
                                          )
                                        )
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: FIELD_WIDTH,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: const [
                                            Text("开", textAlign: TextAlign.justify, style: TextStyle(fontSize: 16.0, color: Colors.black54)),
                                            Text("户", textAlign: TextAlign.justify, style: TextStyle(fontSize: 16.0, color: Colors.black54)),
                                            Text("行", textAlign: TextAlign.justify, style: TextStyle(fontSize: 16.0, color: Colors.black54)),
                                          ],
                                        )
                                      ),
                                      const Text(" : "),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: TextField(
                                            //style: TextStyle(height: 1),
                                            controller: billAccountBankController,
                                            //style: TextStyle(height: 1),
                                            decoration: inputDecoration,
                                            onChanged: (value){
                                              // = value;
                                              billAccountBank = value;
                                            },
                                          )
                                        )
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: FIELD_WIDTH,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: const [
                                            Text("税", textAlign: TextAlign.justify, style: TextStyle(fontSize: 16.0, color: Colors.black54)),
                                            Text("号", textAlign: TextAlign.justify, style: TextStyle(fontSize: 16.0, color: Colors.black54)),
                                          ],
                                        )
                                      ),
                                      const Text(" : "),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: TextField(
                                            //style: TextStyle(height: 1),
                                            controller: billTaxNumController,
                                            //style: TextStyle(height: 1),
                                            decoration: inputDecoration,
                                            onChanged: (value){
                                              // = value;
                                              billTaxNum = value;
                                            },
                                          )
                                        )
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                  width: double.infinity,
                                  child: const Text('送达方式',style: TextStyle(fontSize: 18),)
                                ),
                                Container(
                                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: FIELD_WIDTH,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: const [
                                            Text("邮", textAlign: TextAlign.justify, style: TextStyle(fontSize: 16.0, color: Colors.black54)),
                                            Text("箱", textAlign: TextAlign.justify, style: TextStyle(fontSize: 16.0, color: Colors.black54)),
                                          ],
                                        )
                                      ),
                                      const Text(" : "),
                                      Expanded(
                                        flex:1,
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: TextField(
                                            //style: TextStyle(height: 1),
                                            controller: billNoticeEmailController,
                                            //style: TextStyle(height: 1),
                                            decoration: inputDecoration,
                                            onChanged: (value){
                                              // = value;
                                              billNoticeEmail = value;
                                            },
                                          )
                                        )
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            )
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
                              save();
                            },
                            child: const Text('保存', style: TextStyle(color: Colors.white)),               
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
      //color: Color.fromRGBO(242,245,250,1),
    );
  }

  setBillType(int type) {
    billType = type;
    setState(() {
    });
  }

  save(){
    onScreenTap();
    try{
      checkUser();
    }
    catch(e) {
      ToastUtil.error(e.toString());
      return;
    }
    // DialogUtil.showProgressDlg(context);
    DialogUtil.showProgressDlg(context);
    Map info = {
      'billType': billType,
      'billTitle': billTitle,
      'billAddress': billAddress,
      'billAccount': billAccount,
      'billAccountBank': billAccountBank,
      'billTaxNum':billTaxNum,
      'billNoticeEmail': billNoticeEmail
    };
    HttpUser.saveInvoice(info, (isSuccess, data, msg, code){
      DialogUtil.closeProgressDlg();
      if(isSuccess) {
        ref.read(userFoProvider.notifier).update((state){
          state.billType = billType;
          state.billTitle = billTitle;
          state.billAccount = billAccount;
          state.billAddress = billAddress;
          state.billAccountBank=billAccountBank;
          state.billTaxNum= billTaxNum;
          state.billNoticeEmail=billNoticeEmail;
          return state;
        });
        ToastUtil.hint("修改成功");
        Timer.periodic(const Duration(seconds: 1), (timer) { //callback function
          //1s 回调一次
          timer.cancel();  // 取消定时器
          if(mounted && context.mounted){
            Navigator.pop(context);
          }
        });
      }
      else {
        ToastUtil.error(msg ?? '修改失败');
      }
    });
  }

  checkUser(){
    if(StringUtil.isEmpty(billTitle)) {
      throw '发票抬头不能为空';
    }
    if(StringUtil.isEmpty(billAddress)) {
      throw '发票地址不能为空';
    }
    if(StringUtil.isEmpty(billAccount)) {
      throw '银行账号不能为空';
    }
    if(!RegularUtil.checkBankCard(billAccount ?? '')){
      throw '银行账号格式错误';
    }
    if(StringUtil.isEmpty(billAccountBank)) {
      throw '开户银行不能为空';
    }
    if(billType == 1 && StringUtil.isEmpty(billTaxNum)) {
      throw '税号不能为空';
    }
    if(StringUtil.isEmpty(billNoticeEmail)) {
      throw '通知邮箱不能为空';
    }
    if(!RegularUtil.checkEmail(billNoticeEmail ?? '')){
      throw '通知邮箱格式错误';
    };
  }

  @override
  void initState() {
    super.initState();
    UserFoModel userFo = ref.read(userFoProvider);
    billType = userFo.billType ?? 0;
    billAccount = userFo.billAccount;
    billAccountBank = userFo.billAccountBank;
    billNoticeEmail = userFo.billNoticeEmail;
    billTitle = userFo.billTitle??userFo.realName;
    billTaxNum = userFo.billTaxNum;
    billAddress = userFo.billAddress;
    billAccountController.text = billAccount ?? '';
    billAccountBankController.text = billAccountBank ?? '';
    billTitleController.text = billTitle ?? '';
    billAddressController.text = billAddress ?? '';
    billTaxNumController.text = billTaxNum ?? '';
    billNoticeEmailController.text = billNoticeEmail ?? '';
  }

}
