import 'dart:async';

import 'package:freego_flutter/components/purchase_in_app/api/purchase_in_apple_api.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';

class IapUtil {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  IapUtil._internal() {
    _inAppPurchase.purchaseStream.listen((purchaseDetails) async {
      for (PurchaseDetails purchaseDetail in purchaseDetails) {
        PurchaseStatus status = purchaseDetail.status;
        if (status == PurchaseStatus.canceled) {
          _inAppPurchase.completePurchase(purchaseDetail);
          continue;
        }
        if (status == PurchaseStatus.purchased ||
            status == PurchaseStatus.restored) {
          //todo  先主动完成,只是临时解决方案，不然支付只能第一次成功，后面支付不了
          _inAppPurchase.completePurchase(purchaseDetail);
          // 这里后端接口 报500，这个需要后端解决下
          bool result = await PurchaseInAppleApi().verify(
              receipt: purchaseDetail.verificationData.serverVerificationData);
          if (result) {
            // 报 500 ，执行不到这里
            _inAppPurchase.completePurchase(purchaseDetail);
          }
        }
      }
    });
  }

  static final IapUtil _instance = IapUtil._internal();

  factory IapUtil() {
    return _instance;
  }

  Future<List<ProductDetails>?> listProductDetails(
      List<String> productIds) async {
    ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(productIds.toSet());
    if (response.error != null) {
      return null;
    }
    return response.productDetails;
  }

  Future<ProductDetails?> getProductDetail(String productId) async {
    ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails({productId});
    if (response.error != null) {
      return null;
    }
    List<ProductDetails> list = response.productDetails;
    if (list.isEmpty) {
      return null;
    }
    return list.first;
  }

  Future<bool> buyComsumable({required String productId}) async {
    List<ProductDetails>? list = await listProductDetails([productId]);
    if (list == null || list.isEmpty) {
      return false;
    }
    ProductDetails details = list.first;
    //ios 18以上软件系统闪退，applicationUserName为null造成
    PurchaseParam param =
        PurchaseParam(productDetails: details, applicationUserName: "freeGo");
    try {
      bool result = await _inAppPurchase.buyConsumable(purchaseParam: param);
      return result;
    } catch (e) {
      return false;
    }
  }

  Future restorePurchase() {
    return _inAppPurchase.restorePurchases();
  }

  Future<List<MyPurchasedItem>?> listPurchaseHistory() async {
    await FlutterInappPurchase.instance.initialize();
    List<PurchasedItem>? list =
        await FlutterInappPurchase.instance.getPurchaseHistory();
    if (list == null) {
      return null;
    }
    List<MyPurchasedItem> myList = [];
    for (PurchasedItem item in list) {
      MyPurchasedItem myPurchasedItem = MyPurchasedItem();
      myPurchasedItem.productId = item.productId;
      myPurchasedItem.transactionId = item.transactionId;
      myPurchasedItem.transactionDate = item.transactionDate;
      myPurchasedItem.transactionReceipt = item.transactionReceipt;
      myPurchasedItem.purchaseToken = item.purchaseToken;

      if (item.productId != null) {
        ProductDetails? productDetails =
            await getProductDetail(item.productId!);
        myPurchasedItem.name = productDetails?.title;
        myPurchasedItem.description = productDetails?.description;
      }
    }
    return myList;
  }
}

class MyPurchasedItem {
  String? productId;
  String? transactionId;
  DateTime? transactionDate;
  String? transactionReceipt;
  String? purchaseToken;

  String? name;
  String? description;
}
