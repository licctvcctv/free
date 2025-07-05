
import 'package:flutter/material.dart';
import 'package:freego_flutter/util/theme_util.dart';

enum DateChooseMode{
  single,
  range
}

class DateChooseWidget extends StatefulWidget{
  final double width;
  final double height;
  final DateChooseMode chooseMode;
  final List<DateTime>? initDateList;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Widget Function(DateTime)? cellBuilder;
  final bool Function(DateTime)? choosable;
  final Function(List<DateTime>)? onPick;
  const DateChooseWidget({
    required this.width,
    required this.height,
    this.chooseMode = DateChooseMode.single,
    this.initDateList,
    this.firstDate,
    this.lastDate,
    this.cellBuilder,
    this.choosable,
    this.onPick,
    super.key
  });

  @override
  State<StatefulWidget> createState() {
    return DateChooseState();
  }

}

class DateChooseState extends State<DateChooseWidget>{

  static const double PADDING = 16;
  static const double FONT_SIZE = 18;

  late DateTime firstDate;
  late DateTime lastDate;
  late int currentYear;
  late int currentMonth;
  DateTime today = DateTime.now();

  late double cellSize;

  late PageController pageController;

  late List<DateTime> results;

  @override
  void initState(){
    super.initState();

    cellSize = (widget.width - 2 * PADDING) / 7;
    results = widget.initDateList ?? [];

    List<DateTime>? initDateList = widget.initDateList;
    if(initDateList != null && initDateList.isNotEmpty){
      DateTime date = initDateList.first;
      currentYear = date.year;
      currentMonth = date.month;
    }
    else{
      currentYear = today.year;
      currentMonth = today.month;
    }

    firstDate = widget.firstDate ?? DateTime(1970);
    lastDate = widget.lastDate ?? DateTime(today.year + 50);

    pageController = PageController(initialPage: DateUtils.monthDelta(firstDate, DateTime(currentYear, currentMonth)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 4, right: 12),
          child: Row(
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
                child: const Icon(Icons.cancel_outlined, color: Colors.white, size: 32,),
              ),
            ],
          ),
        ),
        Container(
          width: widget.width,
          constraints: BoxConstraints(
            minHeight: widget.height,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(16))
          ),
          clipBehavior: Clip.hardEdge,
          padding: const EdgeInsets.all(PADDING),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12, left: 6, right: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap
                      ),
                      onPressed: (){
                        pageController.previousPage(duration: const Duration(milliseconds: 350), curve: Curves.ease);
                      },
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: Transform.translate(
                          offset: const Offset(-12, -12),
                          child: const Icon(Icons.arrow_left_outlined, size: 56, color: ThemeUtil.foregroundColor,),
                        ),
                      )
                    ),
                    Text('$currentYear年$currentMonth月', style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: FONT_SIZE),),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap
                      ),
                      onPressed: (){
                        pageController.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.ease);
                      },
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: Transform.translate(
                          offset: const Offset(-12, -12),
                          child: const Icon(Icons.arrow_right_outlined, size: 56, color: ThemeUtil.foregroundColor,) ,
                        )
                      ),
                    )
                  ],
                ),
              ),
              getWeekLabelWidget(),
              SizedBox(
                width: cellSize * 7,
                height: cellSize * 6,
                child: PageView.builder(
                  controller: pageController,
                  itemBuilder: (context, index) {
                    DateTime month = DateUtils.addMonthsToMonthDate(firstDate, index);
                    return getMonthDateWidget(month.year, month.month);
                  },
                  itemCount: DateUtils.monthDelta(firstDate, lastDate) + 1,
                  onPageChanged: (index){
                    DateTime month = DateUtils.addMonthsToMonthDate(firstDate, index);
                    currentMonth = month.month;
                    currentYear = month.year;
                    setState(() {
                    });
                  },
                ),
              ),
              getActionWidget(),
            ],
          ),
        )
      ],
    );
  }

  Widget getActionWidget(){
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap
            ),
            onPressed: (){
              Navigator.of(context).pop(results);
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              decoration: const BoxDecoration(
                color: ThemeUtil.buttonColor,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              child: const Text('O K', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: FONT_SIZE),),
            ),
          )
        ],
      ),
    );
  }

  Widget getMonthDateWidget(int year, int month){
    DateTime monthFirstDate = DateTime(year, month, 1);
    DateTime weekStart = monthFirstDate.copyWith();
    List<Widget> rows = [];
    while(weekStart.month == month){
      if(weekStart.weekday != 7){
        weekStart = weekStart.subtract(Duration(days: weekStart.weekday % 7));
      }
      List<Widget> columns = [];
      for(int i = 0; i < 7; ++i){
        DateTime date = weekStart.add(Duration(days: i));
        Widget? background = getBackground(date);
        bool clickable = !date.isBefore(firstDate) && !date.isAfter(lastDate) && widget.choosable?.call(date) != false;
        Widget view = SizedBox(
          width: cellSize,
          height: cellSize,
          child: background == null ?
          widget.cellBuilder?.call(date) ?? Align(
            alignment: Alignment.center,
            child: Text(date.day.toString(), style: getStyle(date, year, month),),
          ) :
          Stack(
            children: [
              background,
              Align(
                alignment: Alignment.center,
                child: Text(date.day.toString(), style: getStyle(date, year, month),),
              )
            ],
          )
        );
        columns.add(
          clickable ?
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap
            ),
            onPressed: (){
              clickDate(date);
            },
            child: view,
          ) : view
        );
      }
      weekStart = weekStart.add(const Duration(days: 7));
      rows.add(
        Row(
          children: columns,
        )
      );
    }
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: cellSize * 6
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows,
      ),
    );
  }

  Widget getWeekLabelWidget(){
    List<String> labelList = const ['日', '一', '二', '三', '四', '五', '六'];
    List<Widget> widgets = [];
    for(String label in labelList){
      widgets.add(
        SizedBox(
          width: cellSize,
          height: cellSize,
          child: Align(
            alignment: Alignment.center,
            child: Text(label, style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: FONT_SIZE),),
          ),
        )
      );
    }
    return Row(
      children: widgets,
    );
  }

  void clickDate(DateTime date){
    if(widget.chooseMode == DateChooseMode.single){
      results = [date];
      setState(() {
      });
      return;
    }
    if(widget.chooseMode == DateChooseMode.range){
      if(results.isEmpty){
        results.add(date);
      }
      else if(results.length == 1){
        if(date.isAfter(results.first)){
          results.add(date);
        }
        else if(date.isBefore(results.first)){
          results = [date];
        }
      }
      else if(results.length == 2){
        results = [date];
      }
      setState(() {
      });
    }
  }

  Widget? getBackground(DateTime date){
    if(widget.chooseMode == DateChooseMode.single){
      if(results.any((element) => DateUtils.isSameDay(date, element))){
        if(date.year != currentYear || date.month != currentMonth){
          return ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            child: Container(
              color: const Color.fromRGBO(3, 169, 244, 0.5),
            ),
          );
        }
        else{
          return ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            child: Container(
              color: Colors.lightBlue,
            ),
          );
        }
      }
    }
    if(widget.chooseMode == DateChooseMode.range){
      if(date.year != currentYear || date.month != currentMonth){
        if(results.isNotEmpty){
          if(DateUtils.isSameDay(date, results.first)){
            return ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(4)),
              child: Container(
                color: const Color.fromRGBO(3, 169, 244, 0.5),
              ),
            );
          }
          else if(results.length > 1 && DateUtils.isSameDay(date, results[1])){
            return ClipRRect(
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
              child: Container(
                color: const Color.fromRGBO(3, 169, 244, 0.5),
              ),
            );
          }
          else if(results.length > 1 && date.isAfter(results.first) && date.isBefore(results[1])){
            return Container(
              color: const Color.fromRGBO(187, 222, 251, 1),
            );
          }
        }
      }
      else{
        if(results.isNotEmpty){
          if(DateUtils.isSameDay(date, results.first)){
            return ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(4)),
              child: Container(
                color: Colors.lightBlue,
              ),
            );
          }
          else if(results.length > 1 && DateUtils.isSameDay(date, results[1])){
            return ClipRRect(
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
              child: Container(
                color: Colors.lightBlue,
              ),
            );
          }
          else if(results.length > 1 && date.isAfter(results.first) && date.isBefore(results[1])){
            return Container(
              color: const Color.fromRGBO(187, 222, 251, 1),
            );
          }
        }
      }
    }
    return null;
  }

  TextStyle getStyle(DateTime date, int year, int month){
    if(date.year != year || date.month != month){
      if(results.any((element) => DateUtils.isSameDay(date, element))){
        return const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: FONT_SIZE, shadows: [BoxShadow(color: Colors.grey, blurRadius: 1)]);
      }
      else if(DateUtils.isSameDay(date, today)){
        return const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: FONT_SIZE, shadows: [BoxShadow(color: Colors.blue, blurRadius: 1)]);
      }
      else if(!date.isBefore(firstDate) && !date.isAfter(lastDate) && widget.choosable?.call(date) != false){
        return const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: FONT_SIZE, shadows: [BoxShadow(color: Colors.black, blurRadius: 1)]);
      }
      else{
        return const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: FONT_SIZE, shadows: [BoxShadow(color: Colors.grey, blurRadius: 1)]);
      }
    }
    else { 
      if(results.any((element) => DateUtils.isSameDay(date, element))){
        return const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: FONT_SIZE);
      }
      else if(DateUtils.isSameDay(date, today)){
        return const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: FONT_SIZE);
      }
      else if(!date.isBefore(firstDate) && !date.isAfter(lastDate) && widget.choosable?.call(date) != false){
        return const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: FONT_SIZE);
      }
      else{
        return const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: FONT_SIZE);
      }
    }
  }
}
