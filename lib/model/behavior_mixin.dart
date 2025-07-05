
class BehaviorMixin{
  bool? isLiked;
  bool? isFavorited;
  behaviorByJson(dynamic json){
    isLiked = json['isLiked'];
    isFavorited = json['isFavorited'];
  }
}

class LikeableMixin{
  bool? isLiked;
  likeableByJson(dynamic json){
    isLiked = json['isLiked'];
  }
}
