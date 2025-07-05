
enum NotificationType{
  interactFriendApplied,
  interactProductLiked,
  interactProductLikedMonument,
  interactProductCommented,
  interactCommentCommented,
  interactCommentSubCommented,
  interactCommentLiked,
  interactCommentSubLiked,
  interactGroupInvited,
  interactCircleActivityApply,
  interactGiftReceived,
  
  orderHotelStateForMerchant,
  orderScenicStateForMerchant,
  orderRestaurantStateForMerchant,
  orderTravelStateForMerchant,

  systemOrderHotelState,
  systemOrderScenicState,
  systemOrderRestaurantState,
  systemOrderTravelState,
  systemGetReward,
  systemTipoffConfirmed,
  systemTipoffWarned,
  systemCashwithdrawResult,
  systemMerchantapplyResult
}

extension NotificationTypeExt on NotificationType{
  String getVal(){
    switch(this){
      case NotificationType.interactFriendApplied:
        return 'interact_friend_applied';
      case NotificationType.interactProductLiked:
        return 'interact_product_liked';
      case NotificationType.interactProductLikedMonument:
        return 'interact_product_liked_monument';
      case NotificationType.interactProductCommented:
        return 'interact_product_commented';
      case NotificationType.interactCommentCommented:
        return 'interact_comment_commented';
      case NotificationType.interactCommentSubCommented:
        return 'interact_comment_sub_commented';
      case NotificationType.interactCommentLiked:
        return 'interact_comment_liked';
      case NotificationType.interactCommentSubLiked:
        return 'interact_comment_sub_liked';
      case NotificationType.interactGroupInvited:
        return 'interact_group_invited';
      case NotificationType.interactCircleActivityApply:
        return 'interact_circle_activity_apply';
      case NotificationType.interactGiftReceived:
        return 'interact_gift_received';
      case NotificationType.orderHotelStateForMerchant:
        return 'order_hotel_state_for_merchant';
      case NotificationType.orderScenicStateForMerchant:
        return 'order_scenic_state_for_merchant';
      case NotificationType.orderRestaurantStateForMerchant:
        return 'order_restaurant_state_for_merchant';
      case NotificationType.orderTravelStateForMerchant:
        return 'order_travel_state_for_merchant';
      case NotificationType.systemOrderHotelState:
        return 'system_order_hotel_state';
      case NotificationType.systemOrderScenicState:
        return 'system_order_scenic_state';
      case NotificationType.systemOrderRestaurantState:
        return 'system_order_restaurant_state';
      case NotificationType.systemOrderTravelState:
        return 'system_order_travel_state';
      case NotificationType.systemGetReward:
        return 'system_get_reward';
      case NotificationType.systemTipoffConfirmed:
        return 'system_tipoff_confirmed';
      case NotificationType.systemTipoffWarned:
        return 'system_tipoff_warned';
      case NotificationType.systemCashwithdrawResult:
        return 'system_cashwithdraw_result';
      case NotificationType.systemMerchantapplyResult:
        return 'system_merchantapply_result';
    }
  }
  static NotificationType? getType(String val){
    for(NotificationType type in NotificationType.values){
      if(type.getVal() == val){
        return type;
      }
    }
    return null;
  }
}
