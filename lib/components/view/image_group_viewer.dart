
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/view/notify_loading.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageGroupViewer extends StatefulWidget{

  final List<String> urlList;
  final Widget Function(BuildContext, int)? builder;
  final int initIndex;
  const ImageGroupViewer(this.urlList, {this.builder, this.initIndex = 0, super.key});
  
  @override
  State<StatefulWidget> createState() {
    return ImageGroupState();
  }

}

class ImageGroupState extends State<ImageGroupViewer> with AutomaticKeepAliveClientMixin{

  late PageController controller;
  late int index;

  @override
  void initState(){
    super.initState();
    controller = PageController();
    index = widget.initIndex;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.jumpToPage(index);
    });
  }
  
  @override
  void dispose(){
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
        backgroundColor: Colors.black,
        systemOverlayStyle: ThemeUtil.statusBarThemeLight
      ),
      body: GestureDetector(
        onTap: (){
          Navigator.of(context).pop();
        },
        child: Stack(
          children: [
            PhotoViewGallery.builder(
              pageController: controller,
              itemCount: widget.urlList.length, 
              scrollPhysics: const ClampingScrollPhysics(),
              onPageChanged: (index){
                this.index = index;
                setState(() {
                });
              },
              builder: (context, index){
                return PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(widget.urlList[index]),
                );
              },
              wantKeepAlive: true,
              loadingBuilder: (context, e){
                return Container(
                  color: Colors.black,
                  alignment: Alignment.center,
                  child: const NotifyLoadingWidget()
                );
              },
            ),
            widget.builder == null ?
            const SizedBox() :
            Positioned(
              bottom: 0,
              child: widget.builder!(context, index)
            )
          ],
        )
        
      ),
    );
  }
  
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

}
