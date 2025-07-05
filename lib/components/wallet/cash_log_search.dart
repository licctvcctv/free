
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/custom_indicator.dart';
import 'package:freego_flutter/components/view/notify_loading.dart';
import 'package:freego_flutter/http/http_cash.dart';
import 'package:freego_flutter/model/cash.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:intl/intl.dart';

class CashLogPage extends StatefulWidget{
  const CashLogPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return CashLogState();
  }

}

class CashLogState extends State<CashLogPage>{

  late DateTime startDate;
  late DateTime endDate;

  List<CashLog>? cashLogs;
  bool isGetting = false;
  int page = 1;
  static const int PAGE_SIZE = 10;

  @override
  void initState(){
    super.initState();
    DateTime now = DateTime.now();
    endDate = DateTime(now.year, now.month, now.day + 1);
    startDate = endDate.subtract(const Duration(days: 1));
    Future.delayed(Duration.zero, () async{
      cashLogs = await HttpCash.getCashLogByDateRange(startDate, endDate, pageSize: PAGE_SIZE);
      if(cashLogs != null){
        ++page;
      }
      setState(() {
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 10,
        elevation: 0,
        backgroundColor: ThemeUtil.backgroundColor,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color.fromRGBO(0xf2, 0xf5, 0xfa, 1),
        child: cashLogs == null ?
        const NotifyLoadingWidget() :
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CommonHeader(
              center: Text('我的流水', style: TextStyle(color: Colors.white, fontSize: 16),),
            ),
            Expanded(
              child: AnimatedCustomIndicatorWidget(
                contents: [
                  getTimeChooseWidget(),
                  getCashLogsWidget()
                ],
                touchBottom: () async{
                  await more();
                  if(mounted && context.mounted){
                    setState(() {
                    });
                  }
                },
              )
            )
          ],
        )
      ),
    );
  }

  Future init() async{
    page = 1;
    cashLogs = await HttpCash.getCashLogByDateRange(startDate, endDate, pageSize: PAGE_SIZE);
    if(cashLogs != null){
      ++page;
    }
    setState(() {
    });
  }

  Future more() async{
    if(isGetting){
      return;
    }
    List<CashLog>? result = await HttpCash.getCashLogByDateRange(startDate, endDate, pageNum: page, pageSize: PAGE_SIZE);
    if(result != null && result.isNotEmpty){
      ++page;
      cashLogs!.addAll(result);
    }
    isGetting = false;
  }

  List<Widget> getCashLogList(){
    List<Widget> widgets = [];
    DateFormat format = DateFormat("yyyy年MM月dd HH:mm");
    for(int i = 0; i < (cashLogs ?? []).length; ++i){
      CashLog cashLog = cashLogs![i];
      widgets.add(
        TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minimumSize: const Size(double.infinity, 0)
          ),
          onPressed: (){

          },
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${cashLog.description}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
                const SizedBox(height: 8,),
                cashLog.type == CashLogType.entry.getNum() ?
                Text('+ ￥${(cashLog.amount! / 100).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),) :
                Text('- ￥${(cashLog.amount! / 100).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),),
                const SizedBox(height: 8,),
                Text(format.format(cashLog.createTime!), style: const TextStyle(color: Colors.grey),)
              ],
            ),
          ),
        )
      );
      if(i < cashLogs!.length - 1){
        widgets.add(
          const Divider()
        );
      }
    }
    return widgets;
  }

  Widget getCashLogsWidget(){
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('流水', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
          const SizedBox(height: 12,),
          cashLogs == null || cashLogs!.isEmpty ?
          const Center(
            child: Text('没有流水记录', style: TextStyle(color: Colors.grey),),
          ) :
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0xee, 0xee, 0xee, 1),
                  offset: Offset(0, 2),
                  blurRadius: 2
                )
              ]
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: getCashLogList(),
              ),
            )
          ),
        ],
      ),
    );
  }

  Widget getTimeChooseWidget(){
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('日期', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
          const SizedBox(height: 12,),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0xee, 0xee, 0xee, 1),
                  offset: Offset(0, 2),
                  blurRadius: 2
                )
              ]
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap
                  ),
                  onPressed: () async{
                    DateTime lastDate = DateTime.now();
                    DateTime? result = await pickTime(startDate, lastDate: lastDate);
                    if(result != null){
                      startDate = result;
                      init();
                      setState(() {
                      });
                    }
                  },
                  child: Text(DateFormat('yyyy年MM月dd日').format(startDate), style: const TextStyle(decoration: TextDecoration.underline),),
                ),
                const Text('至'),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap
                  ),
                  onPressed: () async{
                    DateTime lastDate = DateTime.now().add(const Duration(days: 1));
                    DateTime? result = await pickTime(endDate, lastDate: lastDate);
                    if(result != null){
                      endDate = result;
                      init();
                      setState(() {
                      });
                    }
                  }, 
                  child: Text(DateFormat('yyyy年MM月dd日').format(endDate), style: const TextStyle(decoration: TextDecoration.underline),),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<DateTime?> pickTime(DateTime choosed, {DateTime? firstDate, DateTime? lastDate}){
    return showModalBottomSheet<DateTime?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context){
        return StatefulBuilder(builder: ((context, setState) {
          return CalendarDatePicker2(
            config: CalendarDatePicker2Config(
              firstDate: firstDate,
              lastDate: lastDate
            ), 
            value: [choosed],
            onValueChanged: (dates){
              Navigator.of(context).pop(dates[0]);
            },
          );
        }));
      }
    );
  }
}
