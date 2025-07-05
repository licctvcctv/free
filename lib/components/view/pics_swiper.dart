
import 'package:flutter/material.dart';
import 'package:flutter_swiper_plus/flutter_swiper_plus.dart';
import 'package:freego_flutter/components/view/image_group_viewer.dart';
import 'package:freego_flutter/util/route_observer.dart';
import 'package:freego_flutter/util/theme_util.dart';

class PicsSwiper extends StatefulWidget{
  final String Function(int) urlBuilder;
  final int count;
  final SwiperController? controller;
  const PicsSwiper({required this.urlBuilder, required this.count, this.controller, super.key});

  @override
  State<StatefulWidget> createState() {
    return PicsSwiperState();
  }

}

class PicsSwiperState extends State<PicsSwiper> with RouteAware{
  static const double HEIGHT = 220;

  late SwiperController _controller;
  bool _isLocalController = false;

  @override
  void didPopNext(){
    _controller.startAutoplay();
  }

  @override
  void didPushNext(){
    _controller.stopAutoplay();
  }

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    RouteObserverUtil().routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void initState(){
    super.initState();
    if(widget.controller != null){
      _controller = widget.controller!;
    }
    else{
      _controller = SwiperController();
      _isLocalController = true;
    }
  }

  @override
  void dispose(){
    if(_isLocalController){
      _controller.dispose();
    }
    RouteObserverUtil().routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    List<String> urlList = [];
    for(int i = 0; i < widget.count; ++i){
      urlList.add(widget.urlBuilder(i));
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: HEIGHT,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Swiper(
            itemBuilder: (context, index){
              String url = widget.urlBuilder(index);
              return InkWell(
                onTap: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context){
                    return ImageGroupViewer(urlList, initIndex: index,);
                  }));
                },
                child: Image.network(
                  url, 
                  fit: BoxFit.cover,
                  errorBuilder:(context, error, stackTrace) {
                    return Container(
                      color: ThemeUtil.backgroundColor,
                      alignment: Alignment.center,
                      child: const Icon(Icons.error_outline, color: ThemeUtil.foregroundColor,),
                    );
                  },
                ),
              );
            },
            itemCount: widget.count,
            autoplay: true,
            controller: _controller,
            physics: const ClampingScrollPhysics(),
          ),
          Row(
            children: [
              InkWell(
                onTap: (){
                  _controller.previous();
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 12),
                  child: const Icon(Icons.arrow_circle_left, color: Colors.white,),
                ),
              ), 
              const Expanded(child: SizedBox()),
              InkWell(
                onTap: (){
                  _controller.next();
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: const Icon(Icons.arrow_circle_right, color: Colors.white),
                ),
              )
            ],
          ),
          Offstage(
            child: ListView(
              children: List.generate(widget.count, (index) => Image.network(widget.urlBuilder(index))),
            ),
          )
        ],
      ),
    );
  }

}
