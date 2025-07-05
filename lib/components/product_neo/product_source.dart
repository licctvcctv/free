
enum ProductSource{
  local,
  panhe
}

extension ProductSourceExt on ProductSource{

  String getName(){
    switch(this){
      case ProductSource.local:
        return "local";
      case ProductSource.panhe:
        return "panhe";
    }
  }

  static ProductSource? getSource(String name){
    for(ProductSource source in ProductSource.values){
      if(source.name == name){
        return source;
      }
    }
    return null;
  }
}
