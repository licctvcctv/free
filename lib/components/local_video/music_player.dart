
import 'package:flutter/material.dart';
import 'package:freego_flutter/util/theme_util.dart';

class MusicPlayerPage extends StatefulWidget{
  const MusicPlayerPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return MusicPlayerPageState();
  }
  
}

class MusicPlayerPageState extends State<MusicPlayerPage>{
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
      body: const MusicPlayerWidget(),
    );
  }

}

class MusicPlayerWidget extends StatefulWidget{
  const MusicPlayerWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return MusicPlayerState();
  }

}

class MusicPlayerState extends State<MusicPlayerWidget>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

}
