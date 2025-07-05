
import 'package:flutter/material.dart';

class GradientOpacityWidget extends StatefulWidget{
  final Widget content;
  const GradientOpacityWidget(this.content, {super.key});

  @override
  State<StatefulWidget> createState() {
    return GradientOpacityState();
  }

}

class GradientOpacityState extends State<GradientOpacityWidget>{

  GlobalKey stackKey = GlobalKey();
  double shadowHeight = 0;

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) { 
      RenderBox? box = stackKey.currentContext?.findRenderObject() as RenderBox?;
      if(box == null){
        return;
      }
      shadowHeight = box.size.height;
      setState(() {
      });
    });
  } 

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: stackKey,
      children: [
        widget.content,
        Container(
          height: shadowHeight,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color.fromRGBO(255, 255, 255, 0), Color.fromRGBO(255, 255, 255, 1)]
            )
          ),
        )
      ],
    );
  }

}