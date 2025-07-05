
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/view/date_choose_view.dart';

class DateChooseConfig{

  final double width;
  final double height;
  final DateChooseMode chooseMode;
  final List<DateTime>? initDateList;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Widget Function(DateTime)? cellBuilder;
  final bool Function(DateTime)? choosable;

  DateChooseConfig({
    required this.width,
    required this.height,
    this.chooseMode = DateChooseMode.single,
    this.initDateList,
    this.firstDate,
    this.lastDate,
    this.cellBuilder,
    this.choosable
  });
}

class DateChooseUtil{

  static Future<List<DateTime>?> chooseDate(BuildContext context, DateChooseConfig config) async{
    Object? result = await showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: '',
      context: context, 
      pageBuilder:(context, animation, secondaryAnimation) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Material(
              color: Colors.transparent,
              child: DateChooseWidget(
                width: config.width,
                height: config.height,
                chooseMode: config.chooseMode,
                initDateList: config.initDateList,
                firstDate: config.firstDate,
                lastDate: config.lastDate,
                cellBuilder: config.cellBuilder,
                choosable: config.choosable,
                onPick: (list){
                  Navigator.of(context).pop(list);
                },
              ),
            )
          ],
        );
      },
    );
    if(result is List<DateTime>){
      return result;
    }
    return null;
  }
}
