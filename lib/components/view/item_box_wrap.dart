
import 'package:flutter/material.dart';

class ItemBoxWrap extends StatelessWidget{

  final ItemBox Function(int) builder;
  final int count;
  final int column;
  final double? childWidth;
  final double? childHeight;
  const ItemBoxWrap({required this.builder, required this.count, this.column = 0, this.childWidth, this.childHeight, super.key});
  
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _getBoxes(),
    );
  }

  List<Widget> _getBoxes(){
    List<Widget> widgets = [];
    for(int i = 0; i < count; ++i){
      widgets.add(
        builder(i)
      );
    }
    if(column > 0 && childWidth != null && childHeight != null){
      while(widgets.length < column){
        widgets.add(
          SizedBox(
            width: childWidth,
            height: childHeight,
          )
        );
      }
    }
    return widgets;
  }

}

class ItemBox extends StatelessWidget{

  final double? width;
  final double? height;
  final Image cover;
  final Widget? top;
  final Widget? bottom;
  final void Function()? onClick;
  final void Function()? onLongPress;
  
  const ItemBox({required this.width, required this.height, required this.cover, this.top, this.bottom, this.onClick, this.onLongPress, super.key});
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      onLongPress: onLongPress,
      child: Container(
        width: width,
        height: height,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8)
        ),
        child: Stack(
          children: [
            cover,
            top == null ?
            const SizedBox() :
            Positioned(
              top: 0,
              child: top!,
            ),
            bottom == null ?
            const SizedBox() :
            Positioned(
              bottom: 0,
              child: bottom!,
            )
          ],
        ),
      )
    );
  }

}
