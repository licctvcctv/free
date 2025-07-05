
enum PoiType{
  hotel,
  scenic,
  restaurant,
  all
}

extension PoiTypeExt on PoiType{

  int getNum(){
    switch(this){
      case PoiType.hotel:
        return 1;
      case PoiType.scenic:
        return 2;
      case PoiType.restaurant:
        return 3;
      case PoiType.all:
        return 0;
    }
  }

  static PoiType? getType(int num){
    for(PoiType type in PoiType.values){
      if(type.getNum() == num){
        return type;
      }
    }
    return null;
  }
}

class MapPoiModel{

  String? name;
  String? address;
  String? city;
  double? lat;
  double? lng;

  String? score;
  String? cost;
  List<String>? tagList;
  List<String>? photoList;
  PoiType? poiType;

  MapPoiModel();
  MapPoiModel.fromJson(dynamic json) {

    name = json['name'];
    address = json['address'];
    city = json['cityname'];
    String location = json['location'];
    var locationList = location.split(",");
    lat = double.parse(locationList[1]);
    lng = double.parse(locationList[0]);

    dynamic business = json['business'];
    dynamic photos = json['photos'];

    String? typeStr = json['typecode'];
    if(typeStr != null){
      if(typeStr.startsWith('050')){
        poiType = PoiType.restaurant;
      }
      else if(typeStr.startsWith('100')){
        poiType = PoiType.hotel;
      }
      else if(typeStr.startsWith('110')){
        poiType = PoiType.scenic;
      }
    }
    if(business != null){
      if(business['rating'] is String){
        double? scoreVal = double.tryParse(business['rating']);
        if(scoreVal != null){
          score = (scoreVal * 2).toStringAsFixed(1);
        }
      }
      if(business['cost'] is String){
        double? costVal = double.tryParse(business['cost']);
        if(costVal != null && costVal > 0){
          cost = costVal.toStringAsFixed(0);
        }
      }
      tagList = [];
      if(business['tag'] != null){
        tagList = (business['tag'] as String).split(',');
      }
    }

    photoList = [];
    if(photos != null){
      for(dynamic item in photos){
        photoList!.add(item['url']);
      }
    }

  }
}

extension MapPoiModelListExt on List<MapPoiModel>{

  void sortByScore(){
    sort((a, b){
      if(b.score == null){
        return -1;
      }
      if(a.score == null){
        return 1;
      }
      double? scoreB = double.tryParse(b.score!);
      if(scoreB == null){
        return - 1;
      }
      double? scoreA = double.tryParse(a.score!);
      if(scoreA == null){
        return 1;
      }
      if(scoreA >= scoreB){
        return -1;
      }
      return 1;
    });
  }

}
