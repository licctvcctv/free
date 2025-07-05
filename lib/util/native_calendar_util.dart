
import 'dart:collection';
import 'dart:io';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';

class NativeCalendarUtil{

  NativeCalendarUtil._internal(){
    initTimeZone();
  }
  static final NativeCalendarUtil _instance = NativeCalendarUtil._internal();
  factory NativeCalendarUtil() => _instance;

  void initTimeZone(){
    if(Platform.isAndroid){
      try{
        setLocalLocation(getLocation('Asia/Shanghai'));
      }
      finally{}
    }
  }

  Event makeEvent({String? title, required DateTime startTime, DateTime? endTime, bool? allDay, String? location, String? description}){
    Event event = Event(null);
    event.title = title;
    event.start = TZDateTime.local(startTime.year, startTime.month, startTime.day, startTime.hour, startTime.minute, startTime.second, startTime.millisecond, startTime.microsecond);
    if(endTime != null){
      event.end = TZDateTime.local(endTime.year, endTime.month, endTime.day, endTime.hour, endTime.minute, endTime.second, endTime.millisecond, endTime.microsecond);
    }
    event.allDay = allDay;
    event.recurrenceRule = RecurrenceRule(RecurrenceFrequency.Daily, endDate: event.end);
    event.availability = Availability.Free;
    event.status = EventStatus.Confirmed;
    event.location = location;
    event.description = description;
    return event;
  }

  Future showEventOption({required BuildContext context, required List<Event> eventList, required String title, int? hours}) async{
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      barrierLabel: '',
      pageBuilder:(context, animation, secondaryAnimation) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: Colors.transparent,
              child: CalendarInsertWidget(eventList: eventList, title: title, remiderHours: hours,),
            )
          ],
        );
      },
    );
  }

  Future<int> saveEvent({required List<Event> eventList}) async{
    await DeviceCalendarPlugin().requestPermissions();
    if((await DeviceCalendarPlugin().hasPermissions()).data != true){
      throw UnAuthedException('获取日历权限失败');
    }
    initTimeZone();
    Result<UnmodifiableListView<Calendar>> calendars = await DeviceCalendarPlugin().retrieveCalendars();
    if(!calendars.isSuccess || calendars.data == null || calendars.data!.isEmpty){
      return 0;
    }
    int count = 0;
    for(Calendar calendar in calendars.data!){
      if(calendar.isReadOnly == true){
        continue;
      }
      if(Platform.isIOS){
        if(calendar.isDefault != true){
          continue;
        }
      }
      String? id = calendar.id;
      if(id == null){
        continue;
      }
      for(Event event in eventList){
        event.calendarId = id;
        Result<String>? result = await DeviceCalendarPlugin().createOrUpdateEvent(event);
        if(result != null && result.isSuccess){
          ++count;
        }
      }
    }
    return count;
  }

  Future<int> createEvent({required String title, required DateTime startTime, required DateTime endTime, String? location, String? description, int? reminderMinutes}) async{
    await DeviceCalendarPlugin().requestPermissions();
    if((await DeviceCalendarPlugin().hasPermissions()).data != true){
      throw UnAuthedException('获取日历权限失败');
    }
    initTimeZone();
    Result<UnmodifiableListView<Calendar>> calendars = await DeviceCalendarPlugin().retrieveCalendars();
    if(!calendars.isSuccess || calendars.data == null || calendars.data!.isEmpty){
      return 0;
    }
    int count = 0;
    for(Calendar calendar in calendars.data!){
      if(calendar.isReadOnly == true){
        continue;
      }
      if(Platform.isIOS){
        if(calendar.isDefault != true){
          continue;
        }
      }
      String? id = calendar.id;
      if(id == null){
        continue;
      }
      Event event = Event(id);
      event.title = title;
      event.start = TZDateTime.local(startTime.year, startTime.month, startTime.day, startTime.hour, startTime.minute, startTime.second, startTime.millisecond, startTime.microsecond);
      event.end = TZDateTime.local(endTime.year, endTime.month, endTime.day, endTime.hour, endTime.minute, endTime.second, endTime.millisecond, endTime.microsecond);
      event.recurrenceRule = RecurrenceRule(RecurrenceFrequency.Daily, endDate: event.end);
      event.reminders = [Reminder(minutes: reminderMinutes)];
      event.availability = Availability.Free;
      event.status = EventStatus.Confirmed;
      event.location = location;
      event.description = description;
      Result<String>? result = await DeviceCalendarPlugin().createOrUpdateEvent(event);
      if(result != null && result.isSuccess){
        ++count;
      }
    }
    return count;
  }

  Future<int> createEventForDay({required String title, required DateTime setDate, String? location,  String? description, int? reminderMinutes}) async{
    await DeviceCalendarPlugin().requestPermissions();
    if((await DeviceCalendarPlugin().hasPermissions()).data != true){
      throw UnAuthedException('获取日历权限失败');
    }
    initTimeZone();
    Result<UnmodifiableListView<Calendar>> calendars = await DeviceCalendarPlugin().retrieveCalendars();
    if(!calendars.isSuccess || calendars.data == null || calendars.data!.isEmpty){
      return 0;
    }
    int count = 0;
    for(Calendar calendar in calendars.data!){
      if(calendar.isReadOnly == true){
        continue;
      }
      if(Platform.isIOS){
        if(calendar.isDefault != true){
          continue;
        }
      }
      String? id = calendar.id;
      if(id == null){
        continue;
      }
      Event event = Event(id);
      event.title = title;
      event.start = TZDateTime.local(setDate.year, setDate.month, setDate.day);
      event.end = event.start?.add(const Duration(seconds: 60 * 60 * 24 - 1));
      event.allDay = true;
      event.recurrenceRule = RecurrenceRule(RecurrenceFrequency.Daily, endDate: event.end);
      event.reminders = [Reminder(minutes: reminderMinutes)];
      event.availability = Availability.Free;
      event.status = EventStatus.Confirmed;
      event.location = location;
      event.description = description;
      Result<String>? result = await DeviceCalendarPlugin().createOrUpdateEvent(event);
      if(result != null && result.isSuccess){
        ++count;
      }
    }
    return count;
  }
}

class UnAuthedException implements Exception{

  final String message;

  UnAuthedException(this.message);

  @override
  String toString(){
    return message;
  }
}

class CalendarInsertWidget extends StatefulWidget{
  final String title;
  final int? remiderHours;
  final List<Event> eventList;
  const CalendarInsertWidget({required this.title, this.remiderHours, required this.eventList, super.key});

  @override
  State<StatefulWidget> createState() {
    return CalendarInsertState();
  }
  
}

class CalendarInsertState extends State<CalendarInsertWidget>{

  static const double FIELD_WIDTH = 80;
  static const int REMINDER_HOURS_DEFAULT = 4;
  bool showDetail = false;

  TextEditingController titleController = TextEditingController();
  TextEditingController hoursController = TextEditingController();

  @override
  void initState(){
    super.initState();
    titleController.text = widget.title;
    hoursController.text = (widget.remiderHours ?? REMINDER_HOURS_DEFAULT).toString();
  }

  @override
  void dispose(){
    titleController.dispose();
    hoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4
            )
          ]
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            showDetail ?
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: FIELD_WIDTH,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('标', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16, fontWeight: FontWeight.bold),),
                          Text('题', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16, fontWeight: FontWeight.bold),)
                        ],
                      )
                    ),
                    const Text(' ： ', style: TextStyle(color: ThemeUtil.foregroundColor)),
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          border: Border.fromBorderSide(BorderSide(color: Colors.grey)),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: TextField(
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '',
                            isDense: true,
                            contentPadding: EdgeInsets.zero
                          ),
                          textAlign: TextAlign.end,
                          controller: titleController,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    SizedBox(
                      width: FIELD_WIDTH,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('提', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16, fontWeight: FontWeight.bold),),
                          Text('前', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16, fontWeight: FontWeight.bold),),
                          Text('提', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16, fontWeight: FontWeight.bold),),
                          Text('醒', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16, fontWeight: FontWeight.bold),),
                        ],
                      )
                    ),
                    const Text(' ： ', style: TextStyle(color: ThemeUtil.foregroundColor)),
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          border: Border.fromBorderSide(BorderSide(color: Colors.grey)),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: TextField(
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '',
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            suffixText: '小时'
                          ),
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.end,
                          controller: hoursController,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ) :
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: (){
                    showDetail = true;
                    setState(() {
                    });
                  },
                  child: const Text('显示选项', style: TextStyle(color: ThemeUtil.buttonColor, fontWeight: FontWeight.bold),),
                )
              ],
            ),
            const SizedBox(height: 16,),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap
                  ),
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      border: Border.fromBorderSide(BorderSide(color: ThemeUtil.buttonColor))
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(8),
                    child: const Text(' 否 ', style: TextStyle(color: ThemeUtil.buttonColor, fontWeight: FontWeight.bold, fontSize: 18),)
                  ),
                ),
                const SizedBox(width: 16,),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap
                  ),
                  onPressed: (){
                    if(!checkInput()){
                      return;
                    }
                    createCalendarEvent();
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: ThemeUtil.buttonColor,
                      borderRadius: BorderRadius.all(Radius.circular(8))
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(8),
                    child: const Text(' 是 ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
  
  bool checkInput(){
    String title = titleController.text.trim();
    if(title.isEmpty){
      ToastUtil.warn('请输入标题');
      return false;
    }
    String hoursText = hoursController.text.trim();
    if(hoursText.isEmpty){
      ToastUtil.warn('请输入提醒时间');
      return false;
    }
    int? hours = int.tryParse(hoursController.text);
    if(hours == null){
      ToastUtil.warn('请输入正确的提醒时间');
      return false;
    }
    return true;
  }

  Future createCalendarEvent() async{
    String title = titleController.text.trim();
    int hours = int.tryParse(hoursController.text) ?? 4;
    for(Event event in widget.eventList){
      event.title = title;
      event.reminders = [Reminder(minutes: hours * 60)];
    }
    try{
      await NativeCalendarUtil().saveEvent(eventList: widget.eventList);
    }
    on UnAuthedException catch(e){
      ToastUtil.error(e.message);
    }
  }
}
