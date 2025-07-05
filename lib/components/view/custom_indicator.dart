
import 'dart:async';

import 'package:flutter/material.dart';

class CustomIndicatorWidget extends StatefulWidget{

  final Function()? touchTop;
  final Function()? touchBottom;
  final Widget content;
  final double? height;
  const CustomIndicatorWidget({required this.content, this.touchTop, this.touchBottom, this.height, super.key});

  @override
  State<StatefulWidget> createState() {
    return CustomIndicatorState();
  }

}

class CustomIndicatorState extends State<CustomIndicatorWidget> {

  static const double TOP_GESTURE_HEIGHT = 40;
  static const double BOTTOM_GESTURE_HEIGHT = 40;

  late ScrollController _controller;
  Timer? timer;
  bool onOperation = false;
  bool autoScroll = true;

  bool showTop = false;
  bool showBottom = false;
  double? listHeight;

  GlobalKey key = GlobalKey();

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    _controller = ScrollController();
    _controller.addListener(() {
      if(onOperation){
        return;
      }
      onOperation = true;
      if(_controller.offset <= 0 && showTop){
        if(widget.touchTop != null){
          widget.touchTop!();
        }
      }
      if(_controller.offset >= _controller.position.maxScrollExtent && showBottom){
        if(widget.touchBottom != null){
          widget.touchBottom!();
        }
      }
      onOperation = false;
      if(showTop && widget.touchTop != null && _controller.offset < TOP_GESTURE_HEIGHT){
        if(timer != null){
          timer!.cancel();
        }
        timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if(!autoScroll){
            return;
          }
          if(_controller.positions.isEmpty){
            timer.cancel();
            return;
          }
          int offset = _controller.offset.toInt();
          if(offset < TOP_GESTURE_HEIGHT){
            _controller.animateTo(TOP_GESTURE_HEIGHT, duration: Duration(milliseconds: (TOP_GESTURE_HEIGHT.toInt() - offset) * 15), curve: Curves.ease);
          }
          timer.cancel();
        });
      }
      if(showBottom && widget.touchBottom != null && _controller.position.maxScrollExtent - _controller.offset < BOTTOM_GESTURE_HEIGHT){
        if(timer != null){
          timer!.cancel();
        }
        timer = Timer.periodic(const Duration(seconds: 1), (timer) { 
          if(!autoScroll){
            return;
          }
          if(_controller.positions.isEmpty){
            timer.cancel();
            return;
          }
          int bias = (_controller.position.maxScrollExtent - _controller.offset).toInt();
          if(bias < BOTTOM_GESTURE_HEIGHT){
            _controller.animateTo(
              _controller.position.maxScrollExtent - BOTTOM_GESTURE_HEIGHT, 
              duration: Duration(milliseconds: (BOTTOM_GESTURE_HEIGHT.toInt() - bias) * 15), 
              curve: Curves.ease
            );
          }
          timer.cancel();
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if(_controller.position.maxScrollExtent > 0){
        showTop = true;
        showBottom = true;
        _controller.jumpTo(widget.touchTop != null ? TOP_GESTURE_HEIGHT : 0);
        setState(() {
        });
      }
      else if(widget.touchTop != null){
        RenderBox? box = key.currentContext?.findRenderObject() as RenderBox?;
        if(box != null){
          listHeight = box.size.height;
          showTop = true;
          _controller.jumpTo(TOP_GESTURE_HEIGHT);
          setState(() {
          });
        }
      }
      else{
        _controller.jumpTo(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      key: key,
      onPointerDown: (event){
        autoScroll = false;
      },
      onPointerUp: (event){
        autoScroll = true;
      },
      child: ListView(
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.zero,
        controller: _controller,
        physics: const ClampingScrollPhysics(),
        children: [
          widget.touchTop == null || !showTop ?
          const SizedBox() :
          Container(
            alignment: Alignment.center,
            height: TOP_GESTURE_HEIGHT,
            child: const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: Colors.grey, strokeWidth: 2.5,)
            ),
          ),
          Container(
            constraints: listHeight != null ? BoxConstraints(
              minHeight: listHeight!,
            ) : null,
            child: widget.content,
          ),
          widget.touchBottom == null || !showBottom ?
          const SizedBox() :
          Container(
            alignment: Alignment.center,
            height: BOTTOM_GESTURE_HEIGHT,
            child: const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: Colors.grey, strokeWidth: 2.5,)
            ),
          ),
        ],
      ),
    );
  }

}

class AnimatedCustomIndicatorWidget extends StatefulWidget{
  final List<Widget> topBuffer;
  final List<Widget> contents;
  final List<Widget> bottomBuffer;

  final Function()? touchTop;
  final Function()? touchBottom;
  final Widget? header;

  const AnimatedCustomIndicatorWidget({this.contents = const [], this.topBuffer = const [], this.bottomBuffer = const [], this.touchTop, this.touchBottom, this.header, super.key});

  @override
  State<StatefulWidget> createState() {
    return AnimatedCustomIndicatorState();
  }

}

class AnimatedCustomIndicatorState extends State<AnimatedCustomIndicatorWidget> with TickerProviderStateMixin{

  static const double TOP_GESTURE_HEIGHT = 40;
  static const double BOTTOM_GESTURE_HEIGHT = 40;

  static const int ANIM_MILLI_SECONDS = 200;
  static const int BUFFER_TIMER_INTERVAL_MILLI_SECONDS = 300;

  GlobalKey headerKey = GlobalKey();
  GlobalKey listenerKey = GlobalKey();
  GlobalKey topBufferKey = GlobalKey();
  GlobalKey bottomBufferKey = GlobalKey();
  GlobalKey contentsKey = GlobalKey();
  double listenerHeight = 0;

  late List<Widget> topBuffer;
  late List<Widget> contents;
  late List<Widget> bottomBuffer;

  List<Widget> topTempArea = [];
  List<Widget> bottomTempArea = [];
  late AnimationController topTempAnim;
  late AnimationController bottomTempAnim;
  late AnimationController topTempOpacity;
  late AnimationController bottomTempOpacity;
  Timer? bufferTimer;
  bool onBufferOperation = false;

  ScrollController scrollController = ScrollController();

  bool showTop = false;
  bool showBottom = false;
  bool autoScroll = true;
  bool onOperation = false;
  Timer? scrollTimer;

  void resetContainerHeight(){
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      RenderBox? box = listenerKey.currentContext?.findRenderObject() as RenderBox?;
      if(box != null){
        RenderBox? headerBox = headerKey.currentContext?.findRenderObject() as RenderBox?;
        listenerHeight = box.size.height - (headerBox?.size.height ?? 0);
        if(listenerHeight < 0){
          listenerHeight = 0;
        }
        setState(() {
        });
      }
    });
  }

  @override
  void initState(){
    super.initState();
    resetContainerHeight();
    if(widget.touchTop != null){
      showTop = true;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        scrollController.jumpTo(TOP_GESTURE_HEIGHT);
      });
    }

    topTempAnim = AnimationController(vsync: this, lowerBound: 0, upperBound: double.infinity);
    bottomTempAnim = AnimationController(vsync: this, lowerBound: 0, upperBound: double.infinity);
    topTempOpacity = AnimationController(vsync: this, duration: const Duration(milliseconds: ANIM_MILLI_SECONDS));
    bottomTempOpacity = AnimationController(vsync: this, duration: const Duration(milliseconds: ANIM_MILLI_SECONDS));

    scrollController.addListener(() {
      if(onOperation){
        return;
      }
      onOperation = true;
      if(scrollController.offset <= 0 && showTop){
        if(widget.touchTop != null){
          widget.touchTop!();
        }
      }
      if(scrollController.offset >= scrollController.position.maxScrollExtent && showBottom){
        if(widget.touchBottom != null){
          widget.touchBottom!();
        }
      }
      onOperation = false; 
      if(showTop && widget.touchTop != null && scrollController.offset < TOP_GESTURE_HEIGHT){
        if(scrollTimer != null){
          scrollTimer!.cancel();
        }
        scrollTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if(!autoScroll){
            return;
          }
          if(scrollController.positions.isEmpty){
            timer.cancel();
            return;
          }
          int offset = scrollController.offset.toInt();
          if(offset < TOP_GESTURE_HEIGHT){
            scrollController.animateTo(TOP_GESTURE_HEIGHT, duration: Duration(milliseconds: (TOP_GESTURE_HEIGHT.toInt() - offset) * 15), curve: Curves.ease);
          }
          timer.cancel();
        });
      }
      if(showBottom && widget.touchBottom != null && scrollController.position.maxScrollExtent - scrollController.offset < BOTTOM_GESTURE_HEIGHT){
        if(scrollTimer != null){
          scrollTimer!.cancel();
        }
        scrollTimer = Timer.periodic(const Duration(seconds: 1), (timer) { 
          if(!autoScroll){
            return;
          }
          if(scrollController.positions.isEmpty){
              timer.cancel();
              return;
            }
          int bias = (scrollController.position.maxScrollExtent - scrollController.offset).toInt();
          if(bias < BOTTOM_GESTURE_HEIGHT){
            scrollController.animateTo(
              scrollController.position.maxScrollExtent - BOTTOM_GESTURE_HEIGHT, 
              duration: Duration(milliseconds: (BOTTOM_GESTURE_HEIGHT.toInt() - bias) * 15), 
              curve: Curves.ease
            );
          }
          timer.cancel();
        });
      }
    });
  }

  @override
  void dispose(){
    scrollController.dispose();
    scrollTimer?.cancel();
    topTempAnim.dispose();
    bottomTempAnim.dispose();
    topTempOpacity.dispose();
    bottomTempOpacity.dispose();
    bufferTimer?.cancel();
    super.dispose();
  }

  void convertBuffer(){
    resetContainerHeight();
    if(topBuffer.isNotEmpty && !onBufferOperation){
      onBufferOperation = true;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        RenderBox? box = topBufferKey.currentContext?.findRenderObject() as RenderBox?;
        if(box != null){
          topTempArea.clear();
          topTempArea.addAll(topBuffer);
          topBuffer.clear();
          setState(() {
          });
          topTempAnim.value = 0;
          topTempOpacity.value = 0;
          topTempAnim.animateTo(box.size.height, duration: const Duration(milliseconds: ANIM_MILLI_SECONDS)).then((value){
            contents.insertAll(0, topTempArea);
            topTempArea.clear();
            onBufferOperation = false;
            setState(() {
            });
          });
          topTempOpacity.forward();
        }
      });
    }
    if(bottomBuffer.isNotEmpty && !onBufferOperation){
      onBufferOperation = true;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        RenderBox? box = bottomBufferKey.currentContext?.findRenderObject() as RenderBox?;
        if(box != null){
          bottomTempArea.clear();
          bottomTempArea.addAll(bottomBuffer);
          bottomBuffer.clear();
          setState(() {
          });
          bottomTempAnim.value = 0;
          bottomTempOpacity.value = 0;
          bottomTempAnim.animateTo(box.size.height, duration: const Duration(milliseconds: ANIM_MILLI_SECONDS)).then((value){
            contents.addAll(bottomTempArea);
            bottomTempArea.clear();
            onBufferOperation = false;
            setState(() {
            });
          });
          bottomTempOpacity.forward();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    topBuffer = widget.topBuffer;
    contents = widget.contents;
    bottomBuffer = widget.bottomBuffer;

    if(topBuffer.isNotEmpty || bottomBuffer.isNotEmpty){
      convertBuffer();
      bufferTimer?.cancel();
      bufferTimer = Timer.periodic(const Duration(milliseconds: BUFFER_TIMER_INTERVAL_MILLI_SECONDS), (timer) { 
        if(topBuffer.isEmpty && bottomBuffer.isEmpty){
          bufferTimer?.cancel();
        }
        convertBuffer();
      });
    }

    if(widget.touchBottom != null && !showBottom){
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) { 
        RenderBox? box = contentsKey.currentContext?.findRenderObject() as RenderBox?;
        if(box != null){
          if(box.size.height >= listenerHeight){
            showBottom = true;
            setState(() {
            });
          }
        }
      });
    }

    return Listener(
      key: listenerKey,
      onPointerDown: (event){
        autoScroll = false;
      },
      onPointerUp: (event){
        autoScroll = true;
      },
      child: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            physics: const ClampingScrollPhysics(),
            scrollDirection: Axis.vertical,
            controller: scrollController,
            children: [
              !showTop ?
              const SizedBox() :
              Container(
                alignment: Alignment.center,
                height: TOP_GESTURE_HEIGHT,
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width,
                ),
                child: const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.grey, strokeWidth: 2.5,)
                ),
              ),
              SizedBox(
                key: headerKey,
                child: widget.header,
              ),
              topTempArea.isEmpty ?
              const SizedBox() :
              AnimatedBuilder(
                animation: topTempAnim, 
                builder: (context, child){
                  return FadeTransition(
                    opacity: topTempOpacity,
                    child: SizedBox(
                      height: topTempAnim.value,
                      width: double.infinity,
                      child: Wrap(
                        clipBehavior: Clip.hardEdge,
                        children: [
                          Column(
                            children: topTempArea,
                          )
                        ],
                      ),
                    ),
                  );
                }
              ),
              Container(
                constraints: BoxConstraints(
                  minHeight: listenerHeight
                ),
                child: Column(
                  key: contentsKey,
                  children: contents,
                ),
              ),
              bottomTempArea.isEmpty ?
              const SizedBox() :
              AnimatedBuilder(
                animation: bottomTempAnim, 
                builder: (context, child){
                  return FadeTransition(
                    opacity: bottomTempOpacity,
                    child: SizedBox(
                      height: bottomTempAnim.value,
                      width: double.infinity,
                      child: Wrap(
                        clipBehavior: Clip.hardEdge,
                        children: [
                          Column(
                            children: bottomTempArea,
                          )
                        ],
                      ),
                    ),
                  );
                }
              ),
              !showBottom ?
              const SizedBox() :
              Container(
                alignment: Alignment.center,
                height: BOTTOM_GESTURE_HEIGHT,
                child: const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.grey, strokeWidth: 2.5,),
                ),
              )
            ],
          ),
          topBuffer.isEmpty ?
          const SizedBox() :
          UnconstrainedBox(
            clipBehavior: Clip.hardEdge,
            child: Opacity(
              opacity: 0,
              child: Wrap(
                key: topBufferKey,
                direction: Axis.vertical,
                children: topBuffer,
              ),
            ),
          ),
          bottomBuffer.isEmpty ?
          const SizedBox() :
          UnconstrainedBox(
            clipBehavior: Clip.hardEdge,
            child: Opacity(
              opacity: 0,
              child: Wrap(
                key: bottomBufferKey,
                direction: Axis.vertical,
                children: bottomBuffer,
              ),
            ),
          )
        ],
      ),
    );
  }

}
