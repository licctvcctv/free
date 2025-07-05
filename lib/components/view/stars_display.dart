
import 'package:flutter/material.dart';

class StarsRowWidget extends StatelessWidget{

  final int rank;
  final bool reverse;
  final double? size;
  const StarsRowWidget({required this.rank, this.reverse = false, this.size, super.key});
  
  @override
  Widget build(BuildContext context) {
    int stars = rank;
    if(stars > 10){
      stars = 10;
    }
    else if(stars < 0){
      stars = 0;
    }
    double showSize = size ?? 36;
    const Color color = Color.fromRGBO(0xff, 0xf8, 0x4f, 1);
    List<Widget> starList = [];
    int half = stars ~/ 2;
    if(stars - 2 * half > 0){
      starList.add(Icon(Icons.star_border_rounded, size: showSize, color: color,));
    }
    for(int i = 0; i < half; ++i){
      starList.add(Icon(Icons.star_rounded, size: showSize, color: color));
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      textDirection: reverse ? TextDirection.ltr : TextDirection.rtl,
      children: starList,
    );
  }

}

class StarsBlockWidget extends StatelessWidget{
  final int rank;
  final bool reverse;
  final double? size;

  const StarsBlockWidget({required this.rank, this.reverse = false, this.size, super.key});
  
  @override
  Widget build(BuildContext context) {
    int stars = rank;
    if(stars > 5){
      stars = 5;
    }
    else if(stars < 0){
      stars = 0;
    }
    double showSize = size ?? 24;
    const Color color = Color.fromRGBO(0xff, 0xf8, 0x4f, 1);
    List<Widget> starList = [];
    if(stars <= 2){
      for(int i = 0; i < stars; ++i){
        starList.add(Icon(Icons.star_rounded, size: showSize, color: color));
      }
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        textDirection: reverse ? TextDirection.rtl : TextDirection.ltr,
        children: starList,
      );
    }
    if(stars == 3){
      showSize = showSize / 5 * 4;
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star_rounded, size: showSize, color: color,)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star_rounded, size: showSize, color: color),
              Icon(Icons.star_rounded, size: showSize, color: color)
            ],
          )
        ],
      );
    }
    if(stars == 4){
      showSize = showSize / 4 * 3;
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.star_rounded, size: showSize, color: color,),
              Icon(Icons.star_rounded, size: showSize, color: color),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.star_rounded, size: showSize, color: color,),
              Icon(Icons.star_rounded, size: showSize, color: color)
            ],
          ),
        ],
      );
    }
    if(stars == 5){
      showSize = showSize / 3 * 2;
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star_rounded, size: showSize, color: color,),
              Icon(Icons.star_rounded, size: showSize, color: color),
              Icon(Icons.star_rounded, size: showSize, color: color)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star_rounded, size: showSize, color: color,),
              Icon(Icons.star_rounded, size: showSize, color: color)
            ],
          ),
        ],
      );
    }
    return const SizedBox();
  }

}
