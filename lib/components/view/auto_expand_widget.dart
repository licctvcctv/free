import 'package:flutter/material.dart';

class AutoExpandWidget extends StatefulWidget{
  final Duration duration;
  final Widget child;
  const AutoExpandWidget({required this.child, required this.duration, super.key});

  @override
  State<StatefulWidget> createState() {
    return AutoExpandState();
  }

}

class AutoExpandState extends State<AutoExpandWidget> with SingleTickerProviderStateMixin{

  late AnimationController animController;

  @override
  void initState(){
    super.initState();
    animController = AnimationController(value: 0, vsync: this);
    animController.animateTo(1, duration: widget.duration, curve: Curves.linear);
  }

  @override
  void dispose(){
    animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animController,
      builder: (context, child){
        return Transform.scale(
          scaleY: animController.value,
          alignment: Alignment.topCenter,
          child: widget.child,
        );
      },
    );
  }

}
