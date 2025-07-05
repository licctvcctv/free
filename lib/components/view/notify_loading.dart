
import 'package:flutter/material.dart';

class NotifyLoadingWidget extends StatelessWidget{
  final Color? color;
  const NotifyLoadingWidget({this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: color,
      ),
    );
  }

}
