import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class DateTimeUtil {

  static toYMD(DateTime dateTime) {
    String dateString = DateFormat("yyyy-MM-dd").format(dateTime).toString();
    return dateString;
  }

  static DateTime getFirstDay(DateTime dateTime)
  {
     var dateFirst = DateTime(dateTime.year,dateTime.month,1);
     return dateFirst;
  }
  static int getMonthDays(DateTime dateTime)
  {
    return  DateTimeRange(
        start: dateTime,
        end: DateTime(dateTime.year, dateTime.month + 1))
        .duration
        .inDays;
  }
  static DateTime monthAdd(DateTime dateTime, int num)
  {
     DateTime newDate = DateTime(dateTime.year,dateTime.month+num,dateTime.day);
     return newDate;
  }

  static List<String> getWeeks()
  {
      return ['日','一','二','三','四','五','六'];
  }

  static String dateToMD(DateTime date)
  {
     return toFormat(date, "MM-dd");
  }

  static strToMD(String dateStr)
  {
      DateTime date = DateTime.parse(dateStr);
      String monthStr = date.month<10?'0${date.month}': date.month.toString();
      String dayStr = date.day<10?'0${date.day}': date.day.toString();
      return '$monthStr-$dayStr';
  }

  static strToWeek(String dateStr)
  {
    Map<int,String>  weekSet = {
        1:'周一',
        2:'周二',
        3:'周三',
        4:'周四',
        5:'周五',
        6:'周六',
        7:'周日',
    };
    DateTime date = DateTime.parse(dateStr);
    return weekSet[date.weekday];

  }

  static String toFormat(DateTime dateTime, String format) {
    String dateString = DateFormat(format).format(dateTime).toString();
    return dateString;
  }

  static String shortTime(DateTime time){
    DateTime now = DateTime.now();
    if(now.year == time.year){
      return toFormat(time, 'MM月dd日 HH:mm');
    }
    else{
      return toFormat(time, 'yyyy年MM月dd日 HH:mm');
    }
  }

  static String answerTime(String dateTime) {
    DateTime date = DateTime.parse(dateTime);
    DateTime now = DateTime.now();
    if (date.year == now.year)
    {
        return toFormat(date, "MM月dd日 HH:mm");
    }
    else
      {
        return toFormat(date, "yyyy年MM月dd日 HH:mm");
      }
  }


  static int differenceDays(DateTime date1, DateTime date2) {
    Duration difference = date2.difference(date1);
    return difference.inDays+1;
  }

  static int getAge(String dateStr) {
    DateTime date = DateTime.parse(dateStr);
    Duration difference = DateTime.now().difference(date);
    return (difference.inDays / 365).floor();
  }

  static String getWeekDayCn(DateTime time){
    switch(time.weekday){
      case 1:
        return '周一';
      case 2:
        return '周二';
      case 3:
        return '周三';
      case 4:
        return '周四';
      case 5:
        return '周五';
      case 6:
        return '周六';
      case 7:
        return '周日';
      default:
        return '未知';
    }
  }

  static String getRelativeTime(DateTime time){
    DateTime now = DateTime.now();
    Duration differ = now.difference(time);
    if(differ.inDays <= 0){
      if(differ.inHours <= 0){
        if(differ.inMinutes <= 0){
          if(differ.inSeconds <= 0){
            return '刚刚';
          }
          return '${differ.inSeconds}秒前';
        }
        return '${differ.inMinutes}分钟前';
      }
      return '${differ.inHours}小时前';
    }
    if(time.year == now.year){
      return '${time.month}月${time.day}日';
    }
    return '${time.year}年${time.month}月${time.day}日';
  }

  static String getSimpleTime(DateTime base, DateTime time){
    DateTime today = DateTime(base.year, base.month, base.day);
    DateTime yesterday = DateTime(base.year, base.month, base.day - 1);
    DateTime beforeYes = DateTime(base.year, base.month, base.day - 2);
    if(time.year == today.year && time.month == today.month && time.day == today.day){
      return DateFormat('HH:mm').format(time);
    }
    if(time.year == yesterday.year && time.month == yesterday.month && time.day == yesterday.day){
      return '昨天 ${DateFormat('HH:mm').format(time)}';
    }
    if(time.year == beforeYes.year && time.month == beforeYes.month && time.day == beforeYes.day){
      return '前天 ${DateFormat('HH:mm').format(time)}';
    }
    if(today.year == time.year){
      return DateFormat('MM月dd日 HH:mm').format(time);
    }
    return DateFormat('yyyy年MM月dd日 HH:mm').format(time);
  }

  static String getAudioTime(Duration duration){
    int hours = duration.inHours;
    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds;
    int millis = duration.inMilliseconds;
    millis = millis - seconds * 1000;
    seconds = seconds - minutes * 60;
    minutes = minutes - hours * 60;
    if(hours > 0){
      return '$hours’h$minutes’m$seconds’s';
    }
    if(minutes > 0){
      return '$minutes’m$seconds’s';
    }
    return '$seconds’s$millis';
  }

  static String getDurationText(Duration duration){
    int hours = duration.inHours;
    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds;
    int millis = duration.inMilliseconds;
    millis = millis - seconds * 1000;
    seconds = seconds - minutes * 60;
    minutes = minutes - hours * 60;
    String secondsStr = seconds < 10 ? '0$seconds' : '$seconds';
    String minutesStr = minutes < 10 ? '0$minutes' : '$minutes';
    if(hours > 0){
      return '$hours:$minutesStr:$secondsStr';
    }
    return '$minutesStr:$secondsStr';
  }

  static String getFormatedForFile(DateTime date){
    final DateFormat format = DateFormat('yyyy-MM-dd-HH-mm-ss-SSS');
    return format.format(date);
  }

  static String getFileTime(DateTime time){
    DateTime now = DateTime.now();
    if(now.year == time.year){
      final DateFormat format = DateFormat('MM月dd日 HH:mm:ss');
      return format.format(time);
    }
    else{
      final DateFormat format = DateFormat('yyyy年MM月dd日 HH:mm:ss');
      return format.format(time);
    }
  }

  static String getVideoTime(Duration duration){
    int hours = duration.inHours;
    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds;
    int millis = duration.inMilliseconds;
    millis = millis - seconds * 1000;
    seconds = seconds - minutes * 60;
    minutes = minutes - hours * 60;
    if(hours > 0){
      return '$hours时$minutes分$seconds秒';
    }
    if(minutes > 0){
      return '$minutes分$seconds秒';
    }
    return '$seconds秒';
  }
}
