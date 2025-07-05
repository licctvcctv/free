
import 'package:flutter/material.dart';

/*class RadioGroupController extends ChangeNotifier{
  int? value;
  void setValue(int? val){
    value = val;
    notifyListeners();
  }
}*/
class RadioGroupController extends ChangeNotifier {
  int? _value;
  RadioGroupController({int? value}) : _value = value;
  int? get value => _value;
  void setValue(int? newValue) {
    if (_value != newValue) {
      _value = newValue;
      notifyListeners(); // 通知监听器值已更改
    }
  }
}

class RadioGroupWidget extends StatefulWidget{
  final Axis axis;
  final CrossAxisAlignment crossAxisAlignment;
  final List<RadioItemWidget> members;
  final RadioGroupController? controller;
  const RadioGroupWidget({required this.members, this.axis = Axis.vertical, this.crossAxisAlignment = CrossAxisAlignment.center, this.controller, super.key});
  
  @override
  State<StatefulWidget> createState() {
    return RadioGroupState();
  }
  
}

class RadioGroupState extends State<RadioGroupWidget>{
  RadioItemWidget? choosed;
  int? choosedValue;

  @override
  void initState(){
    super.initState();
    RadioGroupController? controller = widget.controller;
    if(controller != null){
      controller.addListener(() { 
        choosedValue = controller.value;
        setState(() {
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if(widget.axis == Axis.horizontal){
      return Row(
        crossAxisAlignment: widget.crossAxisAlignment,
        children: getChildren(),
      );
    }
    return Column(
      crossAxisAlignment: widget.crossAxisAlignment,
      children: getChildren(),
    );
  }

  List<Widget> getChildren(){
    List<Widget> widgets = [];
    for(RadioItemWidget member in widget.members){
      widgets.add(
        InkWell(
          onTap: member.onChoose,
          child: member.content,
        )
      );
    }
    return widgets;
  }
}

class RadioItemWidget extends StatefulWidget{
  final Widget content;
  final Function()? onChoose;
  final int? value;

  const RadioItemWidget({required this.content, this.onChoose, this.value, super.key});

  @override
  State<StatefulWidget> createState() {
    return RadioItemState();
  }

}

class RadioItemState extends State<RadioItemWidget>{
  @override
  Widget build(BuildContext context) {
    return widget.content;
  }

}
