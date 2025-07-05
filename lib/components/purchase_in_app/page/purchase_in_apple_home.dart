
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/purchase_in_app/api/purchase_in_apple_api.dart';
import 'package:freego_flutter/components/purchase_in_app/model/purchase_in_apple.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/custom_indicator.dart';
import 'package:freego_flutter/components/view/notify_empty.dart';
import 'package:freego_flutter/components/view/notify_loading.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/util/dialog_util.dart';
import 'package:freego_flutter/util/iap_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';

class PurchaseInAppleHomePage extends StatelessWidget{
  const PurchaseInAppleHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 10,
        backgroundColor: ThemeUtil.backgroundColor,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      body: const PurchsaeInAppleHomeWidget(),
    );
  }
  
}

class PurchsaeInAppleHomeWidget extends StatefulWidget{
  const PurchsaeInAppleHomeWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return PurchsaeInAppleHomeState();
  }
  
}

class _MenuItem{
  final String text;
  final Function(BuildContext)? onClick;
  _MenuItem({required this.text, required this.onClick});
}

class PurchsaeInAppleHomeState extends State<PurchsaeInAppleHomeWidget> with SingleTickerProviderStateMixin{

  final List<PurchaseInApple> _list = [];
  bool _inited = false;

  final List<Widget> _topBuffer = [];
  final List<Widget> _contetnWidgets = [];
  final List<Widget> _bottomWidgets = [];

  List<_MenuItem> _menuItems = [];
  late AnimationController _rightAnimController;
  bool _menuShowWill = false;
  bool _menuShow = false;
  static const int RIGHT_MENU_ANIM_MILLI_SECONDS = 150;
  static const double RIGHT_MENU_WIDTH = 100;
  static const double RIGHT_MENU_ITEM_HEIGHT = 40;

  @override
  void initState(){
    super.initState();
    appendSuit();
    _rightAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: RIGHT_MENU_ANIM_MILLI_SECONDS));
    _menuItems = [
      _MenuItem(
        text: '恢复购买', 
        onClick: (context){
          IapUtil().restorePurchase();
        }
      )
    ];
  }

  @override
  void dispose(){
    _rightAnimController.dispose();
    super.dispose();
  }

  void showMenu(){
    _rightAnimController.forward();
    _menuShowWill = true;
    _menuShow = true;
    setState(() {
    });
  }

  void hideMenu(){
    _menuShowWill = false;
    _rightAnimController.reverse().then((value){
      _menuShow = false;
      resetState();
    });
  }

  void shiftMenu(){
    if(_menuShowWill){
      hideMenu();
    }
    else{
      showMenu();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeUtil.backgroundColor,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonHeader(
                center: const Text('商城', style: TextStyle(color: Colors.white, fontSize: 18),),
                right: InkWell(
                  onTap: shiftMenu,
                  child: const Icon(Icons.more_horiz_rounded, color: Colors.white,),
                ),
              ),
              Expanded(
                child: 
                !_inited ?
                const NotifyLoadingWidget() : 
                _list.isEmpty ?
                const NotifyEmptyWidget() :
                AnimatedCustomIndicatorWidget(
                  topBuffer: _topBuffer,
                  contents: _contetnWidgets,
                  bottomBuffer: _bottomWidgets,
                )
              )
            ],
          ),
          Positioned.fill(
            child: Offstage(
              offstage: !_menuShow,
              child: InkWell(
                onTap: hideMenu,
              ),
            ),
          ),
          Positioned(
            top: CommonHeader.HEADER_HEIGHT,
            right: 0,
            child: Offstage(
              offstage: !_menuShow,
              child: AnimatedBuilder(
                animation: _rightAnimController,
                builder: (context, child) {
                  return Container(
                    constraints: BoxConstraints(
                      maxHeight: RIGHT_MENU_ITEM_HEIGHT * _menuItems.length * _rightAnimController.value
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12)
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 2
                        )
                      ]
                    ),
                    child: Wrap(
                      children: [
                        for(_MenuItem item in _menuItems)
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap
                          ),
                          onPressed: (){
                            item.onClick?.call(context);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: RIGHT_MENU_WIDTH,
                            height: RIGHT_MENU_ITEM_HEIGHT,
                            child: Text(item.text, style: const TextStyle(color: Colors.white, fontSize: 16),),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
  
  Widget getItemWidget(PurchaseInApple item){
    return Container(
      key: ValueKey('purchase_in_apple_${item.id}'),
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
            getFullUrl(item.imageUrl!),
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
                  Text(item.name ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
                  Text(item.description ?? '', overflow: TextOverflow.ellipsis, style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () async{
                          if(item.purchaseId == null){
                            return;
                          }
                          DialogUtil.loginRedirectConfirm(
                            context, 
                            callback: (isLogined) async{
                            if(isLogined){
                              bool result = false;
                              try{
                                result = await IapUtil().buyComsumable(productId: item.purchaseId!);
                              }
                              catch(e){
                                //
                              }
                              if(result){
                                ToastUtil.hint('购买中，请不要退出应用或退出账号');
                              }
                              else{
                                ToastUtil.error('购买失败，请稍等');
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
      ),
    );
  }

  Future appendSuit() async{
    int? minVal;
    if(_list.isNotEmpty){
      minVal = _list.last.id;
    }
    List<PurchaseInApple>? tmp = await PurchaseInAppleApi().range(minVal: minVal);
    if(tmp != null){
      _inited = true;
      _list.addAll(tmp);
      for(PurchaseInApple item in tmp){
        _bottomWidgets.add(getItemWidget(item));
      }
    }
    resetState();
  }

  void resetState(){
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }
}
