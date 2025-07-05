
class CommentHotelDict{

  CommentHotelDict._internal();
  static final CommentHotelDict _instance = CommentHotelDict._internal();
  factory CommentHotelDict(){
    return _instance;
  }

  List<String> cleanTagList = ['脏乱差', '打扫欠缺', '卫生一般', '整洁干净', '优雅漂亮'];
  List<String> positionTagList = ['偏僻', '不太好找', '位置一般', '便利', '中心地区'];
  List<String> serviceTagList = ['态度恶劣', '不理不睬', '态度一般', '有求必应', '亲切主动'];
  List<String> facilityTagList = ['设施缺乏', '设施老旧', '设施一般', '设施齐全', '高端大气'];
}
