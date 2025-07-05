
class OrderStatusUtil{

  OrderStatusUtil._internal();
  static final OrderStatusUtil _instance = OrderStatusUtil._internal();
  factory OrderStatusUtil(){
    return _instance;
  }

  List<OrderHotelStatusListener> hotelStatusListenerList = [];
  List<OrderScenicStatusListener> scenicStatusListenerList = [];
  List<OrderRestaurantStatusListener> restaurantStatusListenerList = [];
  List<OrderTravelStatusListener> travelStatusListenerList = [];

  bool addHotelStatusListener(OrderHotelStatusListener listener){
    if(hotelStatusListenerList.contains(listener)){
      return false;
    }
    hotelStatusListenerList.add(listener);
    return true;
  }
  bool removeHotelStatusListener(OrderHotelStatusListener listener){
    return hotelStatusListenerList.remove(listener);
  }

  bool addScenicStatusListener(OrderScenicStatusListener listener){
    if(scenicStatusListenerList.contains(listener)){
      return false;
    }
    scenicStatusListenerList.add(listener);
    return true;
  }
  bool removeScenicStatusListener(OrderScenicStatusListener listener){
    return scenicStatusListenerList.remove(listener);
  }

  bool addRestaurantStatusListener(OrderRestaurantStatusListener listener){
    if(restaurantStatusListenerList.contains(listener)){
      return false;
    }
    restaurantStatusListenerList.add(listener);
    return true;
  }
  bool removeRestaurantStatusListener(OrderRestaurantStatusListener listener){
    return restaurantStatusListenerList.remove(listener);
  }

  bool addTravelStatusListener(OrderTravelStatusListener listener){
    if(travelStatusListenerList.contains(listener)){
      return false;
    }
    travelStatusListenerList.add(listener);
    return true;
  }
  bool removeTravelStatusListener(OrderTravelStatusListener listener){
    return travelStatusListenerList.remove(listener);
  }

  void setOrderHotelStatus(int nid, int status){
    for(OrderHotelStatusListener listener in hotelStatusListenerList){
      listener.setOrderStatus(nid, status);
    }
  }

  void setOrderScenicStatus(int nid, int status){
    for(OrderScenicStatusListener listener in scenicStatusListenerList){
      listener.setOrderStatus(nid, status);
    }
  }

  void setOrderRestaurantStatus(int nid, int status){
    for(OrderRestaurantStatusListener listener in restaurantStatusListenerList){
      listener.setOrderStatus(nid, status);
    }
  }

  void setOrderTravelStatus(int nid, int status){
    for(OrderTravelStatusListener listener in travelStatusListenerList){
      listener.setOrderStatus(nid, status);
    }
  }
}

abstract class OrderHotelStatusListener{

  void setOrderStatus(int nid, int status);
}

abstract class OrderScenicStatusListener{

  void setOrderStatus(int nid, int status);
}

abstract class OrderRestaurantStatusListener{

  void setOrderStatus(int nid, int status);
}

abstract class OrderTravelStatusListener{

  void setOrderStatus(int nid, int status);
}
