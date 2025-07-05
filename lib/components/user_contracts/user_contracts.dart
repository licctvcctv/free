
import 'package:flutter/material.dart';
import 'package:freego_flutter/util/theme_util.dart';

class UserContractsPage extends StatelessWidget{
  const UserContractsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
        backgroundColor: ThemeUtil.backgroundColor,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      body: const SizedBox(),
    );
  }
  
}
