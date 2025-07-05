
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/notify_empty.dart';
import 'package:freego_flutter/components/view/notify_loading.dart';
import 'package:freego_flutter/util/date_time_util.dart';
import 'package:freego_flutter/util/iap_util.dart';
import 'package:freego_flutter/util/theme_util.dart';

class PurchaseInAppleRestorePage extends StatelessWidget{
  const PurchaseInAppleRestorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 10,
        backgroundColor: ThemeUtil.backgroundColor,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      body: const PurchaseInAppleRestoreWidget(),
    );
  }
  
}

class PurchaseInAppleRestoreWidget extends StatefulWidget{
  const PurchaseInAppleRestoreWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return PurchaseInAppleRestoreState();
  }
  
}

class PurchaseInAppleRestoreState extends State<PurchaseInAppleRestoreWidget>{

  List<MyPurchasedItem> _list = [];
  bool _inited = false;
  final DateTime _now = DateTime.now();

  @override
  void initState(){
    super.initState();
    Future.delayed(Duration.zero, () async{
      _list = await IapUtil().listPurchaseHistory() ?? [];
      _inited = true;
      resetState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeUtil.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonHeader(
            center: Text('恢复购买', style: TextStyle(color: Colors.white, fontSize: 18),),
          ),
          Expanded(
            child: 
            !_inited ?
            const NotifyLoadingWidget() :
            _list.isEmpty ?
            const NotifyEmptyWidget() :
            ListView(
              children: [

              ],
            ),
          )
        ],
      ),
    );
  }
  
  Widget getItemWidget(MyPurchasedItem item){
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.name ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
          const SizedBox(height: 10,),
          Text(item.description ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
          if(item.transactionDate != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(DateTimeUtil.getSimpleTime(_now, item.transactionDate!)),
          ),
          const SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: (){

                },
                child: const Text('恢复', style: TextStyle(color: Colors.white),),
              )
            ],
          )
        ],
      )
    );
  }

  void resetState(){
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }
}
