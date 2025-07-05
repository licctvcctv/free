
class StatisticMixin{
  
  double? score;
  int? likeNum;
  int? favoriteNum;
  int? commentNum;
  int? questionNum;
  int? shareNum;
  int? showNum;
  int? giftNum;

  statisticByJson(dynamic json){
    score = json['score'];
    likeNum = json['likeNum'];
    favoriteNum = json['favoriteNum'];
    commentNum = json['commentNum'];
    questionNum = json['questionNum'];
    shareNum = json['shareNum'];
    showNum = json['showNum'];
    giftNum = json['giftNum'];
  }
}

class HotelScoreMixin{

  double? cleanScore;
  double? positionScore;
  double? serviceScore;
  double? facilityScore;

  hotelScoreByJson(dynamic json){
    cleanScore = json['cleanScore'];
    positionScore = json['positionScore'];
    serviceScore = json['serviceScore'];
    facilityScore = json['facilityScore'];
  }
}
