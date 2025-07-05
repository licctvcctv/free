
import 'package:flutter/material.dart';

class KeepAliveWrapperWidget extends StatefulWidget{

  final Widget content;

  const KeepAliveWrapperWidget({required this.content, super.key});
  
  @override
  State<StatefulWidget> createState() {
    return KeepAliveWrapperState();
  }

}

class KeepAliveWrapperState extends State<KeepAliveWrapperWidget> with AutomaticKeepAliveClientMixin{
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.content;
  }
  
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

}
