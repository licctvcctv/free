
class ListenersMixin<T>{

  List<T> listenerList = [];

  bool addListener(T listener){
    if(listenerList.contains(listener)){
      return false;
    }
    List<T> tmpList = [];
    tmpList.addAll(listenerList);
    tmpList.add(listener);
    listenerList = tmpList;
    return true;
  }

  bool removeListener(T listener){
    return listenerList.remove(listener);
  }
}
