
import 'package:flutter/material.dart';
import 'package:freego_flutter/util/theme_util.dart';

class LocalVideoEditPage extends StatefulWidget{
  final String path;
  const LocalVideoEditPage(this.path, {super.key});

  @override
  State<StatefulWidget> createState() {
    return LocalVideoEditPageState();
  }

}

class LocalVideoEditPageState extends State<LocalVideoEditPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
        backgroundColor: Colors.black87,
        systemOverlayStyle: ThemeUtil.statusBarThemeLight,
      ),
      resizeToAvoidBottomInset: false,
      body: LocalVideoEditWidget(widget.path),
    );
  }

}

class LocalVideoEditWidget extends StatefulWidget{
  final String path;
  const LocalVideoEditWidget(this.path, {super.key});

  @override
  State<StatefulWidget> createState() {
    return LocalVideoEditState();
  }

}

class LocalVideoEditState extends State<LocalVideoEditWidget>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

}
