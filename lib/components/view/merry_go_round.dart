
import 'package:flutter/material.dart';

class MerryGoRound extends StatefulWidget{
  final Widget content;
  const MerryGoRound(this.content, {super.key});

  @override
  State<StatefulWidget> createState() {
    return MerryGoRoundState();
  }
  
}

class MerryGoRoundState extends State<MerryGoRound>{

  ScrollController scrollController = ScrollController();

  @override
  void dispose(){
    scrollController.dispose();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if(scrollController.position.maxScrollExtent > 0){
        resetOffset();
      }
    });
  }

  void resetOffset(){
    if(mounted && context.mounted){
      if(scrollController.offset <= 0){
        double maxOffset = scrollController.position.maxScrollExtent;
        scrollController.animateTo(maxOffset, duration: Duration(milliseconds: maxOffset.toInt() * 50), curve: Curves.linear).then((value){
          Future.delayed(const Duration(seconds: 1), resetOffset);
        });
      }
      else if(scrollController.offset >= scrollController.position.maxScrollExtent){
        double maxOffset = scrollController.position.maxScrollExtent;
        scrollController.animateTo(0, duration: Duration(milliseconds: maxOffset.toInt() * 50), curve: Curves.linear).then((value){
          Future.delayed(const Duration(seconds: 1), resetOffset);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: scrollController,
      physics: const NeverScrollableScrollPhysics(),
      child: widget.content,
    );
  }

}
