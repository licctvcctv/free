
import 'package:flutter/material.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewer extends StatelessWidget{

  final String url;
  final Widget Function(BuildContext)? builder;
  const ImageViewer(this.url, {this.builder, super.key});
  
  @override
  Widget build(BuildContext context) {
    if(builder == null){
      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          elevation: 0,
          backgroundColor: Colors.black,
          systemOverlayStyle: ThemeUtil.statusBarThemeLight,
        ),
        body: InkWell(
          onTap: (){
            Navigator.of(context).pop();
          },
          child: PhotoView(
            imageProvider: NetworkImage(url),
          )
        ),
      );
    }
    else{
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 0,
          backgroundColor: Colors.black,
          systemOverlayStyle: ThemeUtil.statusBarThemeLight,
        ),
        body: InkWell(
          onTap: (){
            Navigator.of(context).pop();
          },
          child: Stack(
            children: [
              PhotoView(
                imageProvider: NetworkImage(url),
              ),
              Positioned(
                bottom: 0,
                child: builder!(context),
              )
            ],
          ),
        ),
      );
    }
  }

}
