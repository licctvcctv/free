
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/util/user_gift/user_gift_dialog.dart';

class UserGiftUtil{

  UserGiftUtil._internal();
  static final UserGiftUtil _instance = UserGiftUtil._internal();
  factory UserGiftUtil(){
    return _instance;
  }

  Future showGiftDialog({required BuildContext context, required int authorId, required String? authorName, required String? authorHead, required String? productName, required int productId, required ProductType productType}){
    return showGeneralDialog(
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder:(context, animation, secondaryAnimation) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: Colors.transparent,
              child: UserGiftWidget(
                authorHead: authorHead,
                authorName: authorName,
                authorId: authorId,
                productName: productName,
                productId: productId,
                productType: productType,
              ),
            )
          ],
        );
      },
    );
  }
}
