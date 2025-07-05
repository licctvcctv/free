
import 'package:flutter/material.dart';

enum CollapsibleAction{
  shift
}

class CollapsibleController extends ChangeNotifier{
  CollapsibleAction? _action;
  void shift(){
    _action = CollapsibleAction.shift;
    notifyListeners();
  }
}

class CollapsibleView extends StatefulWidget{
  final double minHeight;
  final Widget content;
  final CollapsibleController? controller;
  const CollapsibleView(this.content, {this.minHeight = 0, this.controller, super.key});

  @override
  State<StatefulWidget> createState() {
    return CollapsibleState();
  }
  
}

class CollapsibleState extends State<CollapsibleView> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin{

  late AnimationController animController;
  late Animation animation;
  GlobalKey key = GlobalKey();
  bool collapse = true;
  double minHeight = 0.0;
  double maxHeight = 0.0;

  @override
  void initState(){

    super.initState();
    animController = AnimationController(vsync: this,);
    animation = Tween(begin: 0.0, end: 1.0).animate(animController); 
    minHeight = widget.minHeight;
    widget.controller?.addListener(onListenController);
  }

  void onListenController(){
    RenderBox? box = key.currentContext?.findRenderObject() as RenderBox?;
    if(box != null){
      maxHeight = box.size.height;
    }
    animController.duration = Duration(milliseconds: (maxHeight.toInt() - minHeight.toInt()) ~/ 2);
    if(animController.duration!.compareTo(Duration.zero) <= 0){
      animController.duration = const Duration(milliseconds: 100);
    }
    if(animController.duration!.compareTo(const Duration(seconds: 1)) >= 0){
      animController.duration = const Duration(seconds: 1);
    }
    if(widget.controller?._action == CollapsibleAction.shift){
      if(collapse){
        collapse = false;
        animController.forward();
      }
      else{
        collapse = true;
        animController.reverse();
      }
    }
  }

  @override
  void dispose(){
    animController.dispose();
    widget.controller?.removeListener(onListenController);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnimatedBuilder(
      animation: animation, 
      builder: (context, child){
        return Stack(
          children: [
            Offstage(
              child: Wrap(
                key: key,
                children: [widget.content],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: minHeight + animation.value * (maxHeight - minHeight),
                  alignment: Alignment.center,
                  child: Wrap(
                    clipBehavior: Clip.hardEdge,
                    children: [widget.content],
                  )
                ),
              ],
            )
          ],
        );
        
      }
    );
  }
  
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

}
