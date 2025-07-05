
import 'package:flutter/material.dart';

class NavigatedController{
  late NavigatedState _state;
  void animatedTo(int index){
    _state.animatedTo(index);
  }
}

class NavigatedView extends StatefulWidget{
  final List<Widget> children;
  final Widget Function(int) navi; // 元素与索引的关系，由控制器中调用animatedTo跳转到指定索引
  final int count; // 可定位的元素个数
  final NavigatedController controller;
  final ScrollController? scrollController;
  const NavigatedView(this.children, {required this.navi, required this.count, required this.controller, this.scrollController, super.key});

  @override
  State<StatefulWidget> createState() {
    return NavigatedState();
  }

}

class NavigatedState extends State<NavigatedView>{

  late ScrollController _controller;
  final GlobalKey _listKey = GlobalKey();
  final List<GlobalKey> _naviKeys = [];

  @override
  void initState(){
    super.initState();
    widget.controller._state = this;
    for(int i = 0; i < widget.count; ++i){
      _naviKeys.add(GlobalKey());
    }
    _controller = widget.scrollController ?? ScrollController();
  }

  @override
  void dispose(){
    if(widget.scrollController == null){
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    for(Widget item in widget.children){
      int i;
      for(i = 0; i < widget.count; ++i){
        if(widget.navi(i) == item){
          break;
        }
      }
      if(i == widget.count){
        // 非定位元素
        widgets.add(item);
      }
      else{
        // 可定位元素
        widgets.add(
          Wrap(
            key: _naviKeys[i],
            children: [item],
          )
        );
      }
    }

    return SingleChildScrollView(
      key: _listKey,
      padding: EdgeInsets.zero,
      controller: _controller,
      child: Column(
        children: widgets,
      )
    );
  }

  void animatedTo(int index){
    RenderBox listRender = _listKey.currentContext?.findRenderObject() as RenderBox;
    RenderBox targetRender = _naviKeys[index].currentContext?.findRenderObject() as RenderBox;
    Offset targetOffset = targetRender.localToGlobal(Offset.zero);
    Offset compare = listRender.globalToLocal(targetOffset);
    double moveY = compare.dy + _controller.offset;
    _controller.animateTo(moveY, duration: const Duration(milliseconds: 350), curve: Curves.ease);
  }
}
