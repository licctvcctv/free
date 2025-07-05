
import 'package:flutter/material.dart';

mixin PageViewIndexAware{
  int? pageViewIndex;
}

class PageViewIndexData extends InheritedWidget{
  final int index;
  const PageViewIndexData(this.index, {super.key, required super.child});

  @override
  bool updateShouldNotify(covariant PageViewIndexData oldWidget) {
    return oldWidget.index != index;
  }

  static PageViewIndexData? of(BuildContext context){
    return context.dependOnInheritedWidgetOfExactType<PageViewIndexData>();
  }
}
