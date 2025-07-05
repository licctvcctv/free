
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/purchase_item/api/user_purchase_item_api.dart';
import 'package:freego_flutter/components/purchase_item/model/user_purchase_item.dart';
import 'package:freego_flutter/components/purchase_item/pages/purchase_pay.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/custom_indicator.dart';
import 'package:freego_flutter/components/view/notify_empty.dart';
import 'package:freego_flutter/components/view/notify_loading.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/util/theme_util.dart';

class UserItemChoosePage extends StatelessWidget{
  final List<String> effectBeans;
  const UserItemChoosePage({required this.effectBeans, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 10,
        backgroundColor: ThemeUtil.backgroundColor,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      body: UserItemChooseWidget(effectBeans: effectBeans,),
    );
  }

}

class UserItemChooseWidget extends StatefulWidget{
  final List<String> effectBeans;
  const UserItemChooseWidget({required this.effectBeans, super.key});

  @override
  State<StatefulWidget> createState() {
    return UserItemChooseState();
  }
  
}

class UserItemChooseState extends State<UserItemChooseWidget>{

  static const int PAGE_SIZE = 10;

  bool _onAppend = false;
  final List<UserPurchaseItem> _itemList = [];
  bool _inited = false;
  int _page = 1;

  final List<Widget> _topBuffer = [];
  final List<Widget> _contentWidgets = [];
  final List<Widget> _bufferWidgets = [];

  @override
  void initState(){
    super.initState();
    appendItem();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeUtil.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonHeader(
            center: const Text('选择道具', style: TextStyle(color: Colors.white, fontSize: 18),),
            right: TextButton(
              onPressed: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                  return const PurchasePayPage();
                }));
              },
              child: const Text('商城', style: TextStyle(color: Colors.white, fontSize: 16),),
            ),
          ),
          Expanded(
            child: 
            !_inited ?
            const NotifyLoadingWidget() :
            _itemList.isEmpty ?
            const NotifyEmptyWidget() :
            AnimatedCustomIndicatorWidget(
              topBuffer: _topBuffer,
              contents: _contentWidgets,
              bottomBuffer: _bufferWidgets,
              touchBottom: appendItem,
            ),
          )
        ],
      ),
    );
  }

  Widget getItemWidget(UserPurchaseItem item){
    return Container(
      key: ValueKey('user_purchase_item_${item.id}'),
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
      child: InkWell(
        onTap: (){
          Navigator.of(context).pop(item);
        },
        child: Padding(
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
                          Text('X ${item.count}', style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),)
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      )
    );
  }
  
  Future appendItem() async{
    if(_onAppend){
      return;
    }
    _onAppend = true;
    List<UserPurchaseItem>? list = await UserPurchaseItemApi().search(effectBeans: widget.effectBeans, pageNum: _page, pageSize: PAGE_SIZE);
    if(list != null){
      _itemList.addAll(list);
      _inited = true;
      ++_page;
      for(UserPurchaseItem item in list){
        _bufferWidgets.add(getItemWidget(item));
      }
    }
    _onAppend = false;
    resetState();
  }

  void resetState(){
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }
}
