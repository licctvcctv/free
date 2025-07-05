
import 'dart:async';

import 'package:flutter/material.dart';

class TitledSwiperController{
  TitledSwiperState? _state;
  Function(int)? onChange;
  Future rollTo(int page) async{
    _state?.rollWaitingList.add(page);
    await _state?.startRolling();
  }
  bool canPop(){
    return _state != null && _state!.canPop();
  }
  Future pop() async{
    await _state?.startPoping();
  }
  int getPage(){
    return _state?.historyList.last ?? 0;
  }
}

class TitledSwiperMixin{
  TitledSwiperController? swiperController;
}

class TitledSwiper extends StatefulWidget{
  final List<Widget> titles;
  final List<Widget> pages;
  final TitledSwiperController? controller;
  final bool traceHistory; // 是否启用历史追踪模式，若启用，按回退按钮时不会返回上一个页面，而是切换上上一个滑动页面
  const TitledSwiper({required this.titles, required this.pages, this.controller, this.traceHistory = false, super.key});

  @override
  State<StatefulWidget> createState() {
    return TitledSwiperState();
  }

}

class TitledSwiperState extends State<TitledSwiper>{

  static const double TITLE_HEIGHT = 48;
  late TitledSwiperController localController;
  late PageController _pageController;
  double floatLeft = 0;

  bool updateIgnoreTag = false;
  bool historyUpdatingTag = false;

  List<int> historyList = [0];
  List<int> rollWaitingList = [];
  int popNum = 0;
  bool updatingIgnore = false;

  bool isRolling = false;
  Timer? popTimer;

  @override
  void initState(){
    super.initState();
    localController = widget.controller ?? TitledSwiperController();
    localController._state = this;
    for(Widget page in widget.pages){
      if(page is TitledSwiperMixin){
        (page as TitledSwiperMixin).swiperController = localController;
      }
    }
    _pageController = PageController();
    _pageController.addListener(() {
      double? pos = _pageController.page;
      if(pos == null){
        return;
      }
      double itemWidth = MediaQuery.of(context).size.width / widget.titles.length;
      setState(() {
        floatLeft = pos * itemWidth;
      });
    });
  }

  @override
  void dispose(){
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(widget.titles.length != widget.pages.length){
      throw Exception('length of titles should be equal to length of pages!');
    }
    double itemWidth = MediaQuery.of(context).size.width / widget.titles.length;
    return WillPopScope(
      onWillPop: () async{
        if(!widget.traceHistory){
          return true;
        }
        ++popNum;
        popTimer?.cancel();
        bool result = await startPoping();
        if(!result){
          popTimer?.cancel();
          popTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) async{ 
            result = await startPoping();
            if(result){
              timer.cancel();
            }
          });
        }
        return false;
      },
      child: Column(
        children: [
          Stack(
            children: [
              Positioned(
                bottom: 0,
                left: floatLeft + 10,
                child: Container(
                  width: itemWidth - 20,
                  height: 10,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.cyan,
                    borderRadius: BorderRadius.all(Radius.circular(6))
                  ),
                ),
              ),
              SizedBox(
                height: TITLE_HEIGHT,
                child: ListView.builder(
                  itemBuilder: (context, index){
                    return SizedBox(
                      width: itemWidth,
                      height: TITLE_HEIGHT,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero
                        ),
                        onPressed: () async{
                          rollWaitingList.add(index);
                          await startRolling();
                        },
                        child: widget.titles[index],
                      ),
                    );
                  },
                  itemCount: widget.titles.length,
                  scrollDirection: Axis.horizontal,
                ),
              ),
            ], 
          ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification){
                if(notification is ScrollUpdateNotification){
                  if(notification.depth == 0 && !updateIgnoreTag){
                    PageMetrics metrics = notification.metrics as PageMetrics;
                    int? page = metrics.page?.round();
                    if(page != null){
                      if((rollWaitingList.isNotEmpty && page != rollWaitingList.last) || (rollWaitingList.isEmpty && page != historyList.last)){
                        rollWaitingList.add(page);
                        startRolling();
                      }
                    }
                  }
                }
                return false;
              },
              child: PageView(
                controller: _pageController,
                children: widget.pages,
              ),
            ),
          )
        ],
      ),
    );
  }

  Future startRolling() async{
    if(isRolling){
      return;
    }
    isRolling = true;
    updateIgnoreTag = true;
    while(rollWaitingList.isNotEmpty){
      int page = rollWaitingList.first;
      rollWaitingList.removeAt(0);
      historyList.add(page);
      if(localController.onChange != null){
        localController.onChange!(page);
      }
      await rollTo(page);
    }
    isRolling = false;
  }

  Future<bool> startPoping() async{
    if(isRolling){
      return false;
    }
    isRolling = true;
    updateIgnoreTag = true;
    while(popNum > 0){
      --popNum;
      if(rollWaitingList.isNotEmpty){
        rollWaitingList.removeLast();
      }
      else if(historyList.length > 1){
        historyList.removeLast();
        int page = historyList.last;
        if(localController.onChange != null){
          localController.onChange!(page);
        }
        await rollTo(page);
      }
      else{
        if(Navigator.of(context).canPop()){
          Navigator.of(context).pop();
        }
      }
    }
    if(rollWaitingList.isEmpty && popNum == 0){
      updateIgnoreTag = false;
    }
    isRolling = false;
    return false;
  }

  Future rollTo(int index) async{
    if(!_pageController.hasClients || _pageController.page == null){
      return;
    }
    double bias = _pageController.page! - index;
    if(bias < 0){
      bias = -bias;
    }
    await _pageController.animateToPage(index, duration: Duration(milliseconds: (bias.toInt() + 1) * 250), curve: Curves.ease);
    if(rollWaitingList.isEmpty && popNum == 0){
      updateIgnoreTag = false;
    }
  }

  bool canPop(){
    if(popNum > historyList.length + rollWaitingList.length){
      return false;
    }
    return true;
  }

}
