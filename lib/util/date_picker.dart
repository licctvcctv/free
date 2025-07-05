
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/view/price_calendar.dart';
import 'package:freego_flutter/util/context_util.dart';

class DatePicker {
  
  static Future<DateTime?> pickWithPrice(DateTime choosed, DateTime firstDate, DateTime lastDate, String? Function(DateTime) getPrice) async{
    int months = lastDate.month - firstDate.month + 1;
    DateTime today = DateTime.now();
    const double cellHeight = 48;
    BuildContext? context = ContextUtil.getContext();
    if(context == null){
      return null;
    }
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context){
        return StatefulBuilder(
          builder: (context, setState){
            return Container(
              height: MediaQuery.of(context).size.height*0.8,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: Stack(
                      children: [
                        const Center(
                          child: Text('日期选择', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                        ),
                        Positioned(
                          right: 10,
                          top: 10,
                          child: InkWell(
                            onTap: (){
                              Navigator.pop(context);
                            },
                            child: const Icon(Icons.close),
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: PriceCalendar.build(
                      monthNum: months,
                      startDate: firstDate,
                      onDayView: (DateTime day){
                        String? price;
                        if(!day.isBefore(firstDate) && !day.isAfter(lastDate)){
                          price = getPrice(day);
                        }
                        if(day == choosed){
                          return InkWell(
                            onTap: (){
                              Navigator.pop(context, day);
                            },
                            child: Container(
                              height: cellHeight,
                              alignment: Alignment.topCenter,
                              padding: const EdgeInsets.only(top: 6),
                              color: Colors.blue,
                              child: price == null ?
                              Text('${day.day}', style: const TextStyle(color: Colors.white),) :
                              Column(
                                children: [
                                  Text('${day.day}', style: const TextStyle(color: Colors.white),),
                                  Text('￥$price', style: const TextStyle(color: Colors.red, fontSize: 14),)
                                ],
                              )
                            ),
                          );
                        }
                        if(day.year == today.year && day.month == today.month && day.day == today.day){
                          return InkWell(
                            onTap: today.isBefore(firstDate) ?
                            null :
                            (){
                              Navigator.pop(context, day);
                            },
                            child: Container(
                              height: cellHeight,
                              alignment: Alignment.topCenter,
                              padding: const EdgeInsets.only(top: 6),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blue, width: 1),
                              ),
                              child: price == null ?
                              Text('${day.day}', style: const TextStyle(color: Colors.grey)) :
                              Column(
                                children: [
                                  Text('${day.day}'),
                                  Text('￥$price', style: const TextStyle(color: Colors.red, fontSize: 14),)
                                ],
                              ),
                            ),
                          );
                        }
                        if(price == null){
                          return Container(
                            height: cellHeight,
                            alignment: Alignment.topCenter,
                            padding: const EdgeInsets.only(top: 6),
                            child: Text('${day.day}', style: const TextStyle(color: Colors.grey),),
                          );
                        }
                        return InkWell(
                          onTap: (){
                            Navigator.pop(context, day);
                          },
                          child: Container(
                            height: cellHeight,
                            alignment: Alignment.topCenter,
                            padding: const EdgeInsets.only(top: 6),
                            child: Column(
                              children: [
                                Text('${day.day}'),
                                Text('￥$price', style: const TextStyle(color: Colors.red, fontSize: 14),)
                              ],
                            ),
                          ),
                        );
                      }
                    )
                  )
                ],
              )
            );
          }
        );
      }
    );
  }

  static Future<DateTime?> pick(DateTime choosed, DateTime firstDate, DateTime lastDate) async{
    int months = lastDate.month - firstDate.month + 1;
    DateTime today = DateTime.now();
    const double cellHeight = 48;
    BuildContext? context = ContextUtil.getContext();
    if(context == null){
      return null;
    }
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context){
        return StatefulBuilder(
          builder: (context, setState){
            return Container(
              height: MediaQuery.of(context).size.height*0.8,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: Stack(
                      children: [
                        const Center(
                          child: Text('日期选择', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                        ),
                        Positioned(
                          right: 10,
                          top: 10,
                          child: InkWell(
                            onTap: (){
                              Navigator.pop(context);
                            },
                            child: const Icon(Icons.close),
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: PriceCalendar.build(
                      monthNum: months,
                      startDate: firstDate,
                      onDayView: (DateTime day){
                        if(day == choosed){
                          return InkWell(
                            onTap: (){
                              Navigator.pop(context, day);
                            },
                            child: Container(
                              height: cellHeight,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                              color: Colors.blue,
                              child: Text('${day.day}', style: const TextStyle(color: Colors.white),),
                            ),
                          );
                        }
                        if(day.year == today.year && day.month == today.month && day.day == today.day){
                          return InkWell(
                            onTap: today.isBefore(firstDate) ?
                            null :
                            (){
                              Navigator.pop(context, day);
                            },
                            child: Container(
                              height: cellHeight,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blue, width: 1),
                              ),
                              child: today.isBefore(firstDate) ?
                                Text('${day.day}', style: const TextStyle(color: Colors.grey)) :
                                Text('${day.day}'),
                            ),
                          );
                        }
                        if(day.isBefore(firstDate) || day.isAfter(lastDate)){
                          return Container(
                            height: cellHeight,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                            child: Text('${day.day}', style: const TextStyle(color: Colors.grey),),
                          );
                        }
                        return InkWell(
                          onTap: (){
                            Navigator.pop(context, day);
                          },
                          child: Container(
                            height: cellHeight,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                            child: Text('${day.day}'),
                          ),
                        );
                      }
                    )
                  )
                ],
              )
            );
          }
        );
      }
    );
  }
}