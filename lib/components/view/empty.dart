
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/view/notify_empty.dart';

class EmptyPage extends StatelessWidget{
  const EmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color.fromRGBO(0xf2, 0xf5, 0xfa, 1),
        child: const NotifyEmptyWidget(),
      ),
    );
  }

}
