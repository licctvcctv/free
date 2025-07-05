
extension StringExt on String{

  String camel2under(){
    RegExp exp = RegExp('[A-Z]');
    return replaceAllMapped(exp, (match){
      return '_${match[0]!.toLowerCase()}';
    });
  }

  String under2camel(){
    RegExp exp = RegExp('_(\\w)');
    return replaceAllMapped(exp, (match){
      return match[1]!.toUpperCase();
    });
  }

}
