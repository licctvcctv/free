import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchCityWidget extends ConsumerWidget {
  const SearchCityWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Container(
          height: 36,
          color: const Color.fromRGBO(128, 128, 128, 1),
          padding: const EdgeInsets.only(right: 12, left: 12),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 20),
                child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20,),
              ),
              Container(
                margin: const EdgeInsets.only(left: 20),
                padding: const EdgeInsets.only(left: 24, right: 24),
                width: 180,
                height: 24,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5)),
                  color: Color.fromRGBO(198, 198, 198, 1)
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: "搜索城市名称",
                    border: InputBorder.none
                  ),
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ),
              Container(
                width: 40,
                height: 24,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(topRight: Radius.circular(5), bottomRight: Radius.circular(5)),
                  color: Colors.white
                ),
                child: const Icon(Icons.tune)
              )
            ]
          )  
        )
      ],
    );
  }
}
