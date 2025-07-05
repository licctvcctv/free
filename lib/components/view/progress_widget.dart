
import 'package:flutter/material.dart';

class ProgressWidget extends StatelessWidget{

  final int current;
  final int total;
  const ProgressWidget({required this.current, required this.total, super.key});
  
  @override
  Widget build(BuildContext context) {
    double ratio = 1 - current / total;
    if(ratio <= 0.0){
      ratio = 0.0;
    }
    if(ratio > 1.0){
      ratio = 1.0;
    }
    return Container(
      width: double.infinity,
      height: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.blue, Colors.lightBlue]
        )
      ),
      alignment: Alignment.centerRight,
      child: FractionallySizedBox(
        widthFactor: ratio,
        child: Container(
          color: Colors.white,
        ),
      )
    );
  }
  
}
