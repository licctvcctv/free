
import 'package:flutter/material.dart';

class StarsPickerWidget extends StatefulWidget{
  final Function(int)? afterPick;
  final int initStarNum ;
  const StarsPickerWidget({this.afterPick, this.initStarNum = 10, super.key});

  @override
  State<StatefulWidget> createState() {
    return StarPickerState();
  }

}

class StarPickerState extends State<StarsPickerWidget>{

  static const int starMax = 5;
  late int rank;

  @override
  void initState(){
    super.initState();
    rank = widget.initStarNum;
  }  

  @override
  Widget build(BuildContext context) {
    int fullStarNum = rank ~/ 2;
    int outlineStarNum = rank % 2;
    int darkStarNum = starMax - fullStarNum - outlineStarNum;
    List<Widget> widgets = [];
    for(int i = 0; i < fullStarNum; ++i){
      if(i < fullStarNum - 1){
        widgets.add(InkWell(
          onTap: (){
            setState(() {
              rank = 2 * (i + 1);
            });
            if(widget.afterPick != null){
              widget.afterPick!(rank);
            }
          },
          child: const Icon(Icons.star_rounded, size: 36, color: Color.fromRGBO(0xff, 0xf8, 0x4f, 1))),
        );
      }
      else{
        widgets.add(InkWell(
          onTap: (){
            setState(() {
              --rank;
            });
            if(widget.afterPick != null){
              widget.afterPick!(rank);
            }
          },
          child: const Icon(Icons.star_rounded, size: 36, color: Color.fromRGBO(0xff, 0xf8, 0x4f, 1))),
        );
      }
    }
    for(int i = 0; i < outlineStarNum; ++i){
      widgets.add(InkWell(
        onTap: (){
          setState(() {
            ++rank;
          });
          if(widget.afterPick != null){
            widget.afterPick!(rank);
          }
        },
        child: const Icon(Icons.star_border_rounded, size: 36, color: Color.fromRGBO(0xff, 0xf8, 0x4f, 1)),
      ));
    }
    for(int i = 0; i < darkStarNum; ++i){
      widgets.add(InkWell(
        onTap: (){
          setState(() {
            rank = 2 * (fullStarNum + outlineStarNum + i + 1);
          });
          if(widget.afterPick != null){
            widget.afterPick!(rank);
          }
        },
        child: const Icon(Icons.star_rounded, size: 36, color: Colors.grey)),
      );
    }
    return Row(
      children: widgets,
    );
  }

}
