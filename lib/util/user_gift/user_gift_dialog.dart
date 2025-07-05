import 'package:flutter/material.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/components/purchase_item/api/user_purchase_item_api.dart';
import 'package:freego_flutter/components/purchase_item/model/user_purchase_item.dart';
import 'package:freego_flutter/components/user_gift/page/user_item_choose.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:freego_flutter/util/user_home_director.dart';

class UserGiftWidget extends StatefulWidget{
  final String? authorName;
  final String? authorHead;
  final int authorId;

  final String? productName;
  final int productId;
  final ProductType productType;

  const UserGiftWidget({required this.authorId, required this.authorName, required this.authorHead, required this.productName, required this.productId, required this.productType, super.key});

  @override
  State<StatefulWidget> createState() {
    return UserGiftState();
  }
  
}

class UserGiftState extends State<UserGiftWidget>{

  static const double AUTHOR_HEAD_SIZE = 48;
  static int AUTHOR_NAME_LENGTH_MAX = 14;

  static const double ITEM_SIZE = 60;

  UserPurchaseItem? choosedItem;
  int count = 0;

  TextEditingController countController = TextEditingController();

  @override
  void dispose(){
    countController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4
            )
          ]
        ),
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10,),
            Row(
              children: [
                const SizedBox(width: 10,),
                const Text('送给', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold),),
                const SizedBox(width: 10,),
                InkWell(
                  onTap: (){
                    UserHomeDirector().goUserHome(context: context, userId: widget.authorId);
                  },
                  child: ClipOval(
                    child: SizedBox(
                      width: AUTHOR_HEAD_SIZE,
                      height: AUTHOR_HEAD_SIZE,
                      child: widget.authorHead == null ?
                      ThemeUtil.defaultUserHead :
                      Image.network(getFullUrl(widget.authorHead!), width: double.infinity, height: double.infinity, fit: BoxFit.cover,)
                    ),
                  ),
                ),
                const SizedBox(width: 10,),
                InkWell(
                  onTap: (){
                    UserHomeDirector().goUserHome(context: context, userId: widget.authorId);
                  },
                  child: Text(widget.authorName == null ? '' : StringUtil.getLimitedText(widget.authorName!, AUTHOR_NAME_LENGTH_MAX), style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold),),
                )
              ],
            ),
            const SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(choosedItem?.name ?? '选择礼物', style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
            ),
            const SizedBox(height: 10,),
            Row(
              children: [
                const SizedBox(width: 10,),
                InkWell(
                  onTap: () async{
                    dynamic result = await Navigator.of(context).push(MaterialPageRoute(builder: (context){
                      return const UserItemChoosePage(effectBeans: ["giftEffect"]);
                    }));
                    if(result is UserPurchaseItem){
                      choosedItem = result;
                      count = 1;
                      countController.text = '$count';
                      resetState();
                    }
                  },
                  child: choosedItem == null ?
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    width: ITEM_SIZE,
                    height: ITEM_SIZE,
                    child: const Icon(Icons.question_mark_rounded, size: ITEM_SIZE, color: Colors.white,),
                  ) : 
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: Image.network(getFullUrl(choosedItem!.imageUrl!), fit: BoxFit.cover, width: ITEM_SIZE, height: ITEM_SIZE,),
                  ),
                ),
                const SizedBox(width: 20,),
                Expanded(
                  child: Container(
                    height: ITEM_SIZE,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 4
                        )
                      ]
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      controller: countController,
                      onChanged: (val){
                        int? newCount = int.tryParse(val);
                        if(newCount != null && newCount >= 0){
                          if(newCount > (choosedItem?.count ?? 1)){
                            newCount = choosedItem?.count ?? 1;
                          }
                          count = newCount;
                        }
                        else{
                          countController.text = '';
                          count = 0;
                        }
                      },
                      keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: false),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '数量',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 18),
                        isDense: true,
                        contentPadding: EdgeInsets.zero
                      ),
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: ThemeUtil.foregroundColor),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap
                  ),
                  onPressed: () async{
                    if(choosedItem == null){
                      return;
                    }
                    if(choosedItem!.id == null || choosedItem!.beanName == null){
                      return;
                    }
                    if(count <= 0){
                      return;
                    }
                    dynamic result = await showGeneralDialog(
                      context: context,
                      barrierDismissible: true,
                      barrierColor: Colors.transparent,
                      barrierLabel: '',
                      pageBuilder:(context, animation, secondaryAnimation) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: 4
                                    )
                                  ]
                                ),
                                padding: const EdgeInsets.all(16),
                                margin: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                                          child: Image.network(getFullUrl(choosedItem!.imageUrl!), fit: BoxFit.cover, width: ITEM_SIZE, height: ITEM_SIZE,),
                                        ),
                                        const SizedBox(width: 10,),
                                        const Text('X', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
                                        const SizedBox(width: 10,),
                                        Text('$count', style: const TextStyle(color: ThemeUtil.buttonColor, fontWeight: FontWeight.bold, fontSize: 18),)
                                      ],
                                    ),
                                    const SizedBox(height: 10,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        InkWell(
                                          onTap: (){
                                            Navigator.of(context).pop();
                                          },
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.all(Radius.circular(8)),
                                              border: Border.fromBorderSide(BorderSide(color: ThemeUtil.foregroundColor))
                                            ),
                                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                                            child: const Text('再想想', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () async{
                                            Navigator.of(context).pop(true);
                                          },
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: ThemeUtil.buttonColor,
                                              borderRadius: BorderRadius.all(Radius.circular(8)),
                                              border: Border.fromBorderSide(BorderSide(color: ThemeUtil.buttonColor))
                                            ),
                                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                                            child: const Text('打赏', style: TextStyle(color: Colors.white, fontSize: 16),),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                )
                              ),
                            )
                          ],
                        );
                      },
                    );
                    if(result == true){
                      result = await UserPurchaseItemApi().use(
                        itemId: choosedItem!.id!, 
                        count: count, 
                        effectBean: choosedItem!.beanName!,
                        extra: {
                          'productId': widget.productId,
                          'productType': widget.productType.getNum()
                        },
                        fail: (response){
                          String? message = response.data['message'];
                          message ??= '打赏失败';
                          ToastUtil.error(message);
                        }
                      );
                      if(result){
                        ToastUtil.hint('感谢您的赠与');
                      }
                    }
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(
                          color: ThemeUtil.buttonColor,
                          blurRadius: 4
                        )
                      ]
                    ),
                    padding: const EdgeInsets.all(10),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: Image.asset('images/present-box.png'),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void resetState(){
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }
}
