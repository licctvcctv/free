
class CommentDict{
  CommentDict._internal();
  static final CommentDict _instance = CommentDict._internal();
  factory CommentDict(){
    return _instance;
  }

  List<String> tagList = ['非常差评', '差评', '一般', '好评', '特别好评'];
}
