
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:freego_flutter/components/purchase_in_app/page/purchase_in_apple_home.dart';
import 'package:freego_flutter/components/purchase_item/api/purchase_suit_api.dart';
import 'package:freego_flutter/components/purchase_item/api/user_credit_api.dart';
import 'package:freego_flutter/components/purchase_item/api/user_credit_use_api.dart';
import 'package:freego_flutter/components/purchase_item/api/user_purchase_order_api.dart';
import 'package:freego_flutter/components/purchase_item/enums/pay_type.dart';
import 'package:freego_flutter/components/purchase_item/model/pre_pay_info.dart';
import 'package:freego_flutter/components/purchase_item/model/purchase_suit.dart';
import 'package:freego_flutter/components/purchase_item/model/user_credit.dart';
import 'package:freego_flutter/components/purchase_item/util/pay_type_util.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/custom_indicator.dart';
import 'package:freego_flutter/components/view/notify_empty.dart';
import 'package:freego_flutter/components/view/notify_loading.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/model/user.dart';
import 'package:freego_flutter/util/dialog_util.dart';
import 'package:freego_flutter/util/local_user.dart';
import 'package:freego_flutter/util/pay_util_neo.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';

class PurchasePayPage extends StatelessWidget{
  const PurchasePayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 10,
        backgroundColor: ThemeUtil.backgroundColor,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      body: const PurchasePayWidget(),
    );
  }
  
}

class PurchasePayWidget extends StatefulWidget{
  const PurchasePayWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return PurchasePayState();
  }
  
}

class _MyAfterLoginHandler implements AfterLoginHandler{

  final PurchasePayState _state;
  const _MyAfterLoginHandler(this._state);

  @override
  void handle(UserModel user) {
    _state.getCreditPoint();
  }
  
}

class PurchasePayState extends State<PurchasePayWidget>{

  static const int PAGE_SIZE = 10;

  @override
  void initState(){
    super.initState();
    appendSuit();
    if(Platform.isIOS){
      getCreditPoint();
      _myAfterLoginHandler = _MyAfterLoginHandler(this);
      LocalUser.addAfterLoginHandler(_myAfterLoginHandler!);
    }
  }

  @override
  void dispose(){
    if(_myAfterLoginHandler != null){
      LocalUser.removeAfterLoginHandler(_myAfterLoginHandler!);
    }
    super.dispose();
  }

  bool _onAppend = false;
  final List<PurchaseSuit> _suitList = [];
  bool _inited = false;
  int _page = 1;

  final List<Widget> _topWidgets = [];
  final List<Widget> _contentWidgets = [];
  final List<Widget> _bufferWidgets = [];

  int creditPoint = 0;
  _MyAfterLoginHandler? _myAfterLoginHandler;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeUtil.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonHeader(
            center: const Text('购买', style: TextStyle(color: Colors.white, fontSize: 18),),
            right: 
            Platform.isIOS ?
            TextButton(
              onPressed: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                  return const PurchaseInAppleHomePage();
                }));
              },
              child: const Text('充值', style: TextStyle(color: Colors.white, fontSize: 16),),
            ) : null,
          ),
          if(Platform.isIOS && LocalUser.isLogined())
          getCreditPointWidget(),
          Expanded(
            child: 
            !_inited ?
            const NotifyLoadingWidget() :
            _suitList.isEmpty ?
            const NotifyEmptyWidget() :
            AnimatedCustomIndicatorWidget(
              topBuffer: _topWidgets,
              contents: _contentWidgets,
              bottomBuffer: _bufferWidgets,
              touchBottom: _inited ? appendSuit : null,
            ),
          )
        ],
      ),
    );
  }

  Widget getCreditPointWidget(){
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12))
      ),
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Image.asset('images/bean.png', width: 20, height: 20, fit: BoxFit.cover,),
          const SizedBox(width: 10,),
          Text('$creditPoint', style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),)
        ],
      ),
    );
  }

  Widget getSuitWidget(PurchaseSuit suit){
    return Container(
      key: ValueKey('purchase_suit_${suit.id}'),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(8)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 4
          )
        ]
      ),
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            getFullUrl(suit.imageUrl!),
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder:(context, error, stackTrace) {
              return Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(8))
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.question_mark_rounded, color: Colors.white, size: 40,),
              );
            },
          ),
          const SizedBox(width: 10,),
          Expanded(
            child: SizedBox(
              height: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(suit.name ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
                  Text(suit.description ?? '', overflow: TextOverflow.ellipsis, style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
                  Row(
                    children: [
                      if(Platform.isIOS)
                      Image.asset('images/bean.png', width: 20, height: 20, fit: BoxFit.cover,),
                      if(Platform.isAndroid)
                      const Text('¥', style: TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold, fontSize: 18),),
                      const SizedBox(width: 8,),
                      if(Platform.isIOS)
                      Text('${suit.price}', style: const TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold, fontSize: 18),),
                      if(Platform.isAndroid)
                      Text('${StringUtil.getPriceStr(suit.price)}', style: const TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold, fontSize: 18),),
                      const Expanded(child: SizedBox()),
                      ElevatedButton(
                        onPressed: () async{
                          if(suit.id == null){
                            return;
                          }
                          DialogUtil.loginRedirectConfirm(context, callback: (isLogined){
                            if(isLogined){
                              if(Platform.isAndroid){
                                payInAndroid(suit);
                              }
                              else if(Platform.isIOS){
                                payInIos(suit);
                              }
                            }
                          });
                        },
                        child: const Text('购买', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),)
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      )
    );
  }

  Future payInIos(PurchaseSuit suit) {
    return DialogUtil.showConfirm(
      context, 
      info: '确认购买？',
      success: (){
        UserCreditUseApi().buySuit(
          suitId: suit.id!, 
          fail: (response){
            String message = response.data['message'] ?? '购买失败';
            ToastUtil.warn(message);
          },
          success: (response){
            ToastUtil.hint('购买成功');
            getCreditPoint();
          }
        );
      }
    );
  }

  Future payInAndroid(PurchaseSuit suit) async{
    PayType? payType = await PayTypeUtil().choosePayType(context: context);
    if(payType == null){
      return;
    }
    PrePayInfo? prePayInfo = await UserPurchaseOrderApi().orderSuit(suitId: suit.id!, fail: (response){
      String? message = response.data['message'];
      message ??= '下单失败';
      ToastUtil.error(message);
    });
    if(prePayInfo == null || prePayInfo.serial == null || prePayInfo.price == null){
      return;
    }
    String? code = await UserPurchaseOrderApi().pay(serial: prePayInfo.serial!, payType: payType, fail: (response){
      String? message = response.data['message'];
      message ??= '预支付失败';
      ToastUtil.error(message);
    });
    if(code == null){
      return;
    }
    if(payType == PayType.wechat){
      PayUtilNeo().wechatPay(code, onFail: payFail, onSuccess: paySuccess);
    }
    else if(payType == PayType.alipay){
      bool result = await PayUtilNeo().alipay(code);
      if(result){
        paySuccess();
      }
      else{
        payFail();
      }
    }
  }

  void paySuccess(){
    ToastUtil.hint('支付成功');
    Timer.periodic(const Duration(seconds: 3), (timer) { 
      timer.cancel();
      if(mounted && context.mounted){
        Navigator.of(context).pop(true);
      }
    });
  }

  void payFail(){
    ToastUtil.error('支付失败');
  }
  
  Future appendSuit() async{
    if(_onAppend){
      return;
    }
    _onAppend = true;
    List<PurchaseSuit>? list = await PurchaseSuitApi().search(pageNum: _page, pageSize: PAGE_SIZE);
    if(list != null && list.isNotEmpty){
      _suitList.addAll(list);
      _inited = true;
      ++_page;
      for(PurchaseSuit suit in list){
        _bufferWidgets.add(getSuitWidget(suit));
      }
    }
    _onAppend = false;
    resetState();
  }

  Future getCreditPoint() async{
    UserCredit? userCredit = await UserCreditApi().getCredit();
    if(userCredit != null){
      if(userCredit.creditPoint != null){
        creditPoint = userCredit.creditPoint!;
        resetState();
      }
    }
  }

  void resetState(){
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }
}
