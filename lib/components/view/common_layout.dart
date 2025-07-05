
import 'package:flutter/material.dart';
import 'package:freego_flutter/util/theme_util.dart';

class CommonLayout extends StatefulWidget{
  final bool resizeForKeyboard ;
  final bool hasInput;
  final Widget header;
  final List<Widget> children;
  final Widget? floating;
  const CommonLayout({required this.header, required this.children, this.floating, this.resizeForKeyboard = false, this.hasInput = false, super.key});

  @override
  State<StatefulWidget> createState() {
    return CommonLayoutState();
  }

}

class CommonLayoutState extends State<CommonLayout>{
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: widget.resizeForKeyboard,
      appBar: AppBar(
        toolbarHeight: 10,
        elevation: 0,
        backgroundColor: ThemeUtil.backgroundColor,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      floatingActionButton: widget.floating,
      body: widget.hasInput ?
      GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: getChild(context),
      ):
      getChild(context)
    );
  }

  Widget getChild(BuildContext context){
    return Container(
      color: const Color.fromRGBO(242,245,250,1),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.header,
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: widget.children,
            ),
          )
        ],
      ),
    );
  }
}
