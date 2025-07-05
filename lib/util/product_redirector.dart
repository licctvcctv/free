
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/circle_neo/circle_common.dart';
import 'package:freego_flutter/components/circle_neo/circle_http.dart';
import 'package:freego_flutter/components/circle_neo/detail/circle_activity.dart';
import 'package:freego_flutter/components/circle_neo/detail/circle_article.dart';
import 'package:freego_flutter/components/circle_neo/detail/circle_question.dart';
import 'package:freego_flutter/components/circle_neo/detail/circle_shop.dart';
import 'package:freego_flutter/components/guide_neo/guide_http.dart';
import 'package:freego_flutter/components/guide_neo/guide_map_show.dart';
import 'package:freego_flutter/components/guide_neo/guide_model.dart';
import 'package:freego_flutter/components/hotel_neo/hotel_common.dart';
import 'package:freego_flutter/components/hotel_neo/hotel_home_freego.dart';
import 'package:freego_flutter/components/hotel_neo/api/local_hotel_api.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/components/restaurant/restaurant_common.dart';
import 'package:freego_flutter/components/restaurant/restaurant_home.dart';
import 'package:freego_flutter/components/restaurant/restaurant_api.dart';
import 'package:freego_flutter/components/scenic/scenic_common.dart';
import 'package:freego_flutter/components/scenic/scenic_home_freego.dart';
import 'package:freego_flutter/components/scenic/api/local_scenic_api.dart';
import 'package:freego_flutter/components/travel/travel_common.dart';
import 'package:freego_flutter/components/travel/travel_detail.dart';
import 'package:freego_flutter/components/video/video_home.dart';
import 'package:freego_flutter/components/video/video_model.dart';
import 'package:freego_flutter/http/http_travel.dart';
import 'package:freego_flutter/http/http_video.dart';

class ProductRedirector{
  ProductRedirector._internal();
  static final ProductRedirector _instance = ProductRedirector._internal();
  factory ProductRedirector(){
    return _instance;
  }

  Future<bool> redirect({required int productId, required ProductType type, required BuildContext context}) async{
    switch(type){
      case ProductType.video:
        VideoModel? video = await HttpVideo.getById(productId);
        if(video == null){
          return false;
        }
        if(context.mounted){
          Navigator.of(context).push(MaterialPageRoute(builder: (context){
            return VideoHomePage(initVideo: video,);
          }));
        }
        return true;
      case ProductType.guide:
        Guide? guide = await GuideHttp().get(id: productId);
        if(guide == null){
          return false;
        }
        if(context.mounted){
          Navigator.of(context).push(MaterialPageRoute(builder: (context){
            return GuideMapShowPage(guide);
          }));
        }
        return true;
      case ProductType.circle:
        Circle? circle = await CircleHttp().getCircle(id: productId);
        if(circle == null){
          return false;
        }
        if(context.mounted){
          CircleRedirector().redirect(circle, context);
        }
        return true;
      case ProductType.hotel:
        Hotel? hotel = await LocalHotelApi().detail(id: productId);
        if(hotel == null){
          return false;
        }
        if(context.mounted){
          Navigator.of(context).push(MaterialPageRoute(builder: (context){
            return HotelHomePage(hotel);
          }));
        }
        return true;
      case ProductType.scenic:
        Scenic? scenic = await LocalScenicApi().detail(productId);
        if(scenic == null){
          return false;
        }
        if(context.mounted){
          Navigator.of(context).push(MaterialPageRoute(builder: (context){
            return ScenicHomePage(scenic);
          }));
        }
        return true;
      case ProductType.restaurant:
        Restaurant? restaurant = await RestaurantApi().getById(productId);
        if(restaurant == null){
          return false;
        }
        if(context.mounted){
          Navigator.of(context).push(MaterialPageRoute(builder: (context){
            return RestaurantHomePage(restaurant);
          }));
        }
        return true;
      case ProductType.travel:
        Travel? travel = await HttpTravel.getById(productId);
        if(travel == null){
          return false;
        }
        if(context.mounted){
          Navigator.of(context).push(MaterialPageRoute(builder: (context){
            return TravelDetailPage(travel);
          }));
        }
        return true;
      default:
    }
    return false;
  }
}

class CircleRedirector{
  CircleRedirector._internal();
  static final CircleRedirector _instance = CircleRedirector._internal();
  factory CircleRedirector(){
    return _instance;
  }

  void redirect(Circle circle, BuildContext context){
    if(circle is CircleActivity){
      Navigator.of(context).push(MaterialPageRoute(builder: (context){
        return CircleActivityPage(circle);
      }));
    }
    else if(circle is CircleArticle){
      Navigator.of(context).push(MaterialPageRoute(builder: (context){
        return CircleArticlePage(circle);
      }));
    }
    else if(circle is CircleQuestion){
      Navigator.of(context).push(MaterialPageRoute(builder: (context){
        return CircleQuestionPage(circle);
      }));
    }
    else if(circle is CircleShop){
      Navigator.of(context).push(MaterialPageRoute(builder: (context){
        return CircleShopPage(circle);
      }));
    }
  }
}
