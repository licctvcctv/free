
import 'package:flutter/material.dart';

class CommonHeader extends StatelessWidget{
  static const double PADDING_LEFT = 10;
  static const double PADDING_RIGHT = 10;
  static const double HEADER_HEIGHT = 50;
  static const double DEFAULT_LEFT_WIDTH = 48;
  static const double DEFAULT_RIGHT_WIDTH = 48;
  static const Color DEFAULT_BACKGROUND_COLOR = Color.fromRGBO(203,211,220,1);
  final Widget? left;
  final Widget? center;
  final Widget? right;
  final Color backgroundColor;
  const CommonHeader({this.left, this.center, this.right, this.backgroundColor = DEFAULT_BACKGROUND_COLOR, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: HEADER_HEIGHT,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.fromLTRB(PADDING_LEFT, 0, PADDING_RIGHT, 0),
      color: backgroundColor,
      child: Row(
        children: [
          left != null ? left! :
          Container(
            width: 48,
            alignment: Alignment.center,
            child: IconButton(
              onPressed: (){
                if(Navigator.of(context).canPop()){
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white,),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: center != null ? center! :
              const SizedBox(),
            ) 
          ),
          SizedBox(
            width: DEFAULT_RIGHT_WIDTH,
            child: right,
          )
        ],
      ),
    );
  }

}
