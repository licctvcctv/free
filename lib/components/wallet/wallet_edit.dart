
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/view/common_header.dart';

class WalletEditPage extends StatefulWidget{
  const WalletEditPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return WalletEditState();
  }

}

class WalletEditState extends State<WalletEditPage>{

  String? bankAccount;
  String? bankName;
  String? wxNickName;
  String? aliNickName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color.fromRGBO(0xf2, 0xf5, 0xfa, 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CommonHeader(
                center: Text('编辑钱包', style: TextStyle(color: Colors.white, fontSize: 16),),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text('账户', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                    const SizedBox(height: 12,),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(0xee, 0xee, 0xee, 1),
                            offset: Offset(0, 2),
                            blurRadius: 2
                          )
                        ]
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                alignment: Alignment.centerRight,
                                height: 38,
                                width: 64,
                                child: const Text('开户行：', style: TextStyle(fontWeight: FontWeight.bold),),
                              ),
                              Expanded(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    border: Border(bottom: BorderSide(color: Colors.grey))
                                  ),
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      hintText: '',
                                      hintStyle: TextStyle(color: Color.fromRGBO(0xc5, 0xc5, 0xc6, 1)),
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                      border: InputBorder.none
                                    ),
                                    onChanged: (val){
                                      bankName = val;
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 14,),
                          Row(
                            children: [
                              Container(
                                alignment: Alignment.centerRight,
                                height: 38,
                                width: 64,
                                child: const Text('卡号：', style: TextStyle(fontWeight: FontWeight.bold),),
                              ),
                              Expanded(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    border: Border(bottom: BorderSide(color: Colors.grey))
                                  ),
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      hintText: '',
                                      hintStyle: TextStyle(color: Color.fromRGBO(0xc5, 0xc5, 0xc6, 1)),
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                      border: InputBorder.none
                                    ),
                                    onChanged: (val){
                                      bankAccount = val;
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              )
            ],
          ),
        ),
      ),
    );
  }

}
