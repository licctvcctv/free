
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/order_neo/order_common.dart';
import 'package:freego_flutter/components/order_neo/order_hotel_detail.dart';
import 'package:freego_flutter/components/order_neo/api/order_neo_api.dart';
import 'package:freego_flutter/components/order_neo/order_restaurant_detail.dart';
import 'package:freego_flutter/components/order_neo/order_scenic_detail.dart';
import 'package:freego_flutter/components/order_neo/order_travel_detail.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';

class OrderRedirector{

  OrderRedirector._internal();
  static final OrderRedirector _instance = OrderRedirector._internal();
  factory OrderRedirector(){
    return _instance;
  }

  Future redirect(int orderId, ProductType type, BuildContext context) async{
    switch(type){
      case ProductType.hotel:
        OrderHotel? order = await OrderNeoApi().getOrderHotel(id: orderId);
        if(order == null){
          throw OrderNotFoundException();
        }
        if(context.mounted){
          Navigator.of(context).push(MaterialPageRoute(builder: (context){
            return OrderHotelDetailPage(order);
          }));
          return true;
        }
        break;
      case ProductType.scenic:
        OrderScenic? order = await OrderNeoApi().getOrderScenic(id: orderId);
        if(order == null){
          throw OrderNotFoundException();
        }
        if(context.mounted){
          Navigator.of(context).push(MaterialPageRoute(builder: (context){
            return OrderScenicDetailPage(order);
          }));
        }
        break;
      case ProductType.restaurant:
        OrderRestaurant? order = await OrderNeoApi().getOrderRestaurant(id: orderId);
        if(order == null){
          throw OrderNotFoundException();
        }
        if(context.mounted){
          Navigator.of(context).push(MaterialPageRoute(builder: (context){
            return OrderRestaurantDetailPage(order);
          }));
        }
        break;
      case ProductType.travel:
        OrderTravel? order = await OrderNeoApi().getOrderTravel(id: orderId);
        if(order == null){
          throw OrderNotFoundException();
        }
        if(context.mounted){
          Navigator.of(context).push(MaterialPageRoute(builder: (context){
            return OrderTravelDetailPage(order);
          }));
        }
        break;
      default:
        throw UnsupportedTypeException();
    }
  }

}

class OrderNotFoundException implements Exception{

}

class UnsupportedTypeException implements Exception{

}
