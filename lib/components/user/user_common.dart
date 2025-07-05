
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freego_flutter/http/http.dart';

class UserItemWidget extends ConsumerWidget{

  static const CIRCLE_ITEM_TEXT_HEIGHT = 32.0;

  final String? pic;
  final String content;
  final String? title;
  final Function() onTap;
  final Function()? onLongPress;

  const UserItemWidget({required this.pic, this.title, required this.content, required this.onTap, this.onLongPress, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = (MediaQuery.of(context).size.width - 40) / 2;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        height: width,
        width: width,
        alignment: Alignment.topCenter,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey, strokeAlign: BorderSide.strokeAlignOutside)
        ),
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: width,
                  width: width,
                  child: pic != null && pic!.isNotEmpty ?
                  Image.network(getFullUrl(pic!)) :
                  Image.asset('images/user_circle.png', fit: BoxFit.fill,),
                ),
                if(title != null)
                Container(
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(6)
                  ),
                  child: Text(title!, style: const TextStyle(color: Colors.black),),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(0, 0, 0, 0.3)
                    ),
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    alignment: Alignment.center,
                    height: CIRCLE_ITEM_TEXT_HEIGHT,
                    width: width,
                    child: Text(content, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white),),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
