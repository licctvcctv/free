
import 'package:flutter/material.dart';
import 'package:freego_flutter/util/date_time_util.dart';

typedef OnDayView = Widget Function(DateTime day);

class PriceCalendar extends StatelessWidget {
  
  OnDayView? onDayView;
  DateTime startDate = DateTime.now();
  int monthNum = 4;

  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: getWeekViews(),
          ),
          const SizedBox(height: 10,),
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              child:Column(
                children: getMonthViews()
              )
            )
          )
        ],
      )
    );
  }
  getWeekViews() {
    List<Widget> listWeekDayViews = [];
    var weeks = DateTimeUtil.getWeeks();
    for(var i=0;i<weeks.length;i++) {
      listWeekDayViews.add(
        Container(
          child: Text(weeks[i],style: TextStyle(color: i==0||i==6?Colors.orange:Colors.black),),
        )
      );
    }
    return listWeekDayViews;
  }

  Widget dayView(DateTime day) {
    return Container(
      child: Text(DateTimeUtil.dateToMD(day)),
    );
  }

  List<Widget> getMonthViews() {
    var monthViewList = <Widget>[];
    var firstDayList = getMonthFirstDays();
    for (var i = 0; i < firstDayList.length; i++) {
      if(i>0 || i<firstDayList.length-1) {
        monthViewList.add(Divider(color: Colors.black.withOpacity(0.2),));
      }
      monthViewList.add(getMonthView(firstDayList[i]));
    }
    //var newDate = new DateTime(date.year, date.month - 1, date.day);
    return monthViewList;
  }

  Widget getMonthView(DateTime firstDay) {
    int rowNum = getMonthRowNum(firstDay);
    int weekDay = firstDay.weekday;
    if(weekDay==7) {
      weekDay=0;
    }
    int monthDays = DateTimeUtil.getMonthDays(firstDay);
    List<Widget> weekRows = [];
    for(var i=0;i<rowNum;i++) {
      List<Widget> dayViews = [];
      for(var j=0;j<7;j++) {
        var index = i*7+j;
        if(index<weekDay || index>weekDay+monthDays-1) {
          dayViews.add(Expanded(flex: 1,child: Container(),));
        }
        else {
          DateTime day = firstDay.add(Duration(days: index-weekDay));
          dayViews.add(
            Expanded(flex: 1,child: Container(child: onDayView==null?dayView(day):onDayView!(day),),)
          );
        }
      }
      weekRows.add(Row( mainAxisAlignment:MainAxisAlignment.spaceBetween,children: dayViews,));
    }
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(DateTimeUtil.toFormat(firstDay,"yyyy年MM月"),style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
          const SizedBox(height: 10,),
          Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: weekRows,
            ),
          )
        ]
      ),
    );
  }

  int getMonthRowNum(DateTime datetime) {
    int rowNum = ((DateTimeUtil.getMonthDays(datetime)+datetime.weekday-1)/7).ceil();
    return rowNum;
  }

  List<DateTime> getMonthFirstDays() {
    var firstDayList = <DateTime>[];
    var firstDay = DateTimeUtil.getFirstDay(startDate);
    firstDayList.add(firstDay);
    for(var i =1;i<monthNum;i++) {
      firstDayList.add(DateTimeUtil.monthAdd(firstDay, i));
    }
    return firstDayList;
  }

  PriceCalendar.build({required OnDayView? onDayView, DateTime? startDate, monthNum=4 }) {
    this.onDayView = onDayView;
    this.startDate = startDate??this.startDate;
    this.monthNum = monthNum;
   }

}
