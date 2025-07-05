
import 'package:flutter/material.dart';
import 'package:freego_flutter/util/theme_util.dart';

class Switcher extends StatefulWidget{
  final String leftText;
  final String rightText;
  final Function()? onTapLeft;
  final Function()? onTapRight;
  final int initIndex;
  final Color? backgroundColor;
  final Color? coverColor;
  const Switcher({required this.leftText, required this.rightText, this.onTapLeft, this.onTapRight, this.initIndex = 0, this.backgroundColor, this.coverColor, super.key});

  @override
  State<StatefulWidget> createState() {
    return SwitcherState();
  }

}

class SwitcherState extends State<Switcher> with SingleTickerProviderStateMixin{

  static const double ITEM_WIDTH = 80;
  static const double ITEM_HEIGHT = 32;
  static const int ANIM_MILLISECONDS = 100;

  late int currentIndex;
  late AnimationController animController;

  @override
  void initState(){
    super.initState();
    currentIndex = widget.initIndex;
    animController = AnimationController(vsync: this, duration: const Duration(milliseconds: ANIM_MILLISECONDS));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ITEM_WIDTH * 2,
      height: ITEM_HEIGHT,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4
          )
        ]
      ),
      alignment: Alignment.center,
      child: Stack(
        children: [
          Row(
            children: [
              InkWell(
                onTap: (){
                  animController.reverse();
                  currentIndex = 0;
                  widget.onTapLeft?.call();
                  setState(() {
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: ANIM_MILLISECONDS),
                  width: ITEM_WIDTH,
                  height: ITEM_HEIGHT,
                  alignment: Alignment.center,
                  child: Text(widget.leftText, style: const TextStyle(color: ThemeUtil.foregroundColor),),
                ),
              ),
              InkWell(
                onTap: (){
                  animController.forward();
                  currentIndex = 1;
                  widget.onTapRight?.call();
                  setState(() {
                  });
                },
                child: Container(
                  width: ITEM_WIDTH,
                  height: ITEM_HEIGHT,
                  alignment: Alignment.center,
                  child: Text(widget.rightText, style: const TextStyle(color: ThemeUtil.foregroundColor),),
                ),
              )
            ],
          ),
          SlideTransition(
            position: animController.drive(Tween(begin: Offset.zero, end: const Offset(1, 0))),
            child: Container(
              width: ITEM_WIDTH,
              height: ITEM_HEIGHT,
              decoration: BoxDecoration(
                color: widget.coverColor ?? Color.fromRGBO(4, 182, 221, 0.2),
                borderRadius: const BorderRadius.all(Radius.circular(8))
              ),
              alignment: Alignment.center,
            ),
          )
        ],
      )
    );
  }

}
