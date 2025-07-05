
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/user_block/page/user_block_user_home.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/util/theme_util.dart';

class BlockHomeItem{
  final String text;
  final IconData icon;
  final Function(BuildContext context)? onclick;

  BlockHomeItem({required this.text, required this.icon, required this.onclick});
}

class BlockHomePage extends StatelessWidget{

  static final List<BlockHomeItem> itemList = [
    BlockHomeItem(
      text: '黑名单', 
      icon: Icons.assignment_late,
      onclick: (BuildContext context){
        Navigator.of(context).push(MaterialPageRoute(builder: (context){
          return const UserBlockUserHomePage();
        }));
      }
    )
  ];

  const BlockHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 10,
        backgroundColor: ThemeUtil.backgroundColor,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      body: Container(
        color: ThemeUtil.backgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CommonHeader(
              center: Text('屏蔽设置', style: TextStyle(color: Colors.white, fontSize: 18),),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  for(BlockHomeItem item in itemList)
                  InkWell(
                    onTap: (){
                      item.onclick?.call(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(4))
                      ),
                      child: Row(
                        children: [
                          Icon(item.icon, color: ThemeUtil.foregroundColor, size: 28,),
                          const SizedBox(width: 10,),
                          Text(item.text, style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
                          const Expanded(
                            child: SizedBox(),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: ThemeUtil.foregroundColor, size: 20,)
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  
}
