
import 'package:flutter/material.dart';

class NotifyEmptyWidget extends StatelessWidget{

  final String? info;
  const NotifyEmptyWidget({this.info, super.key});

  @override
  Widget build(BuildContext context) {
    String notify;
    if(info == null || info!.isEmpty){
      notify = '暂时无数据';
    }
    else{
      notify = info!;
    }
    return Wrap(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 40),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/image_no_data.png'),
              const SizedBox(height: 20,),
              Text(notify, style: const TextStyle(color: Colors.cyan),)
            ],
          )
        )
      ],
    );
  }

}
