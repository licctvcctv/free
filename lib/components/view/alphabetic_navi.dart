
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:freego_flutter/util/theme_util.dart';

const List<String> alphabets = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 
                                'H', 'I', 'J', 'K', 'L', 'M', 'N', 
                                'O', 'P', 'Q', 'R', 'S', 'T', 
                                'U', 'V', 'W', 'X', 'Y', 'Z'];

class AlphabeticNaviController extends ChangeNotifier{
  int? code;
  void focus(int idx){
    code = idx;
    notifyListeners();
  }
}

class AlphabeticNaviWidget extends StatefulWidget{

  final int? focusInitail;
  final AlphabeticNaviController? controller;
  final Function(int)? onClickNavi;
  const AlphabeticNaviWidget({this.controller, this.onClickNavi, this.focusInitail, super.key});

  @override
  State<StatefulWidget> createState() {
    return AlphabeticNaviState();
  }
  
}

class AlphabeticNaviState extends State<AlphabeticNaviWidget>{

  static const double ITEM_SIZE = 44;
  static const double ITEM_WIDTH = 24;
  static const int SHOW_COUNT = 4;
  static const int ABBREV_COUNT = 5;

  static const double SCROLL_SENSITIVITY = 0.5;
  static const int REPOSITION_TIME_FACTOR = 5;

  int? focused;

  ScrollController outerController = ScrollController(initialScrollOffset: ITEM_SIZE * ABBREV_COUNT);
  ScrollController innerController = ScrollController();  

  bool onPressed = false;

  void rePosition(){
    double radio = outerController.offset / outerController.position.maxScrollExtent;
    innerController.jumpTo(innerController.position.maxScrollExtent * (1 - radio));
    if(!onPressed){
      int position = ((1 - radio) * (24 - SHOW_COUNT)).round();
      double offset = outerController.position.maxScrollExtent - position * ABBREV_COUNT / (24 - SHOW_COUNT) * ITEM_SIZE;
      int milliSeconds = (position * ITEM_SIZE - innerController.offset).abs().toInt() + 1;
      outerController.animateTo(offset, duration: Duration(milliseconds: milliSeconds * REPOSITION_TIME_FACTOR), curve: Curves.linear);
      innerController.animateTo(position * ITEM_SIZE, duration: Duration(milliseconds: milliSeconds * REPOSITION_TIME_FACTOR), curve: Curves.linear);
    }
  }

  @override
  void initState(){
    super.initState();
    outerController.addListener(() {
      rePosition();
    });
    if(widget.controller != null){
      AlphabeticNaviController controller = widget.controller!;
      controller.addListener(() {
        if(controller.code != null){
          focused = controller.code!;
        }
      });
    }
    focused = widget.focusInitail;
  }

  @override
  void dispose(){
    outerController.dispose();
    innerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: ITEM_WIDTH
      ),
      child: Wrap(
      children: [
        getAlphabetWidget(0),
        SizedBox(
          width: ITEM_SIZE,
          height: ITEM_SIZE * (SHOW_COUNT + ABBREV_COUNT),
          child: Listener(
            onPointerDown: (evt){
              onPressed = true;
            },
            onPointerUp: (evt){
              onPressed = false;
              rePosition();
            },
            child: RawGestureDetector(
              gestures: <Type, GestureRecognizerFactory>{
                VerticalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<VerticalDragGestureRecognizer>(
                  () => VerticalDragGestureRecognizer(),
                  (VerticalDragGestureRecognizer instance){
                    instance.onUpdate = (detail){
                      double target = outerController.offset + detail.delta.dy * SCROLL_SENSITIVITY;
                      if(target >= 0 && target <= outerController.position.maxScrollExtent){
                        outerController.jumpTo(target);
                      }
                    };
                  }
                )
              },
              child: ListView(
                controller: outerController,
                physics: const NeverScrollableScrollPhysics(),
                children: getContentColumn(),
              ),
            ),
          ),
        ),
        getAlphabetWidget(25),
      ],
    ),
    )
    ;
  }

  Widget getAlphabetWidget(int i){
    return InkWell(
      onTap: (){
        if(widget.onClickNavi != null){
          widget.onClickNavi!(i);
        }
      },
      child: i == focused ?
      SizedBox(
        width: ITEM_WIDTH,
        height: ITEM_SIZE,
        child: Align(
          alignment: Alignment.center,
          child: Container(
            width: ITEM_SIZE * 0.5,
            height: ITEM_SIZE * 0.5,
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.all(Radius.circular(ITEM_SIZE * 0.25)),
            ),
            alignment: Alignment.center,
            child: Text(alphabets[i], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
          ),
        )
      ) :
      SizedBox(
        width: ITEM_WIDTH,
        height: ITEM_SIZE,
        child: Align(
          alignment: Alignment.center,
          child: Text(alphabets[i], style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold),),
        ),
      ),
    );
  }

  List<Widget> getAlphabetColumn(){
    List<Widget> widgets = [];
    for(int i = 1; i < 25; ++i){
      widgets.add(
        getAlphabetWidget(i)
      );
    }
    return widgets;
  }

  List<Widget> getContentColumn(){
    List<Widget> widgets = [];
    for(int i = 0; i < ABBREV_COUNT; ++i){
      widgets.add(
        const SizedBox(
          width: ITEM_WIDTH,
          height: ITEM_SIZE,
          child: Align(
            alignment: Alignment.center,
            child: Text('・'),
          ),
        )
      );
    }
    widgets.add(
      SizedBox(
        width: ITEM_WIDTH,
        height: ITEM_SIZE * SHOW_COUNT,
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          controller: innerController,
          children: getAlphabetColumn(),
        ),
      )
    );
    for(int i = 0; i < ABBREV_COUNT; ++i){
      widgets.add(
        const SizedBox(
          width: ITEM_WIDTH,
          height: ITEM_SIZE,
          child: Align(
            alignment: Alignment.center,
            child: Text('・'),
          ),
        )
      );
    }
    return widgets;
  }
}
