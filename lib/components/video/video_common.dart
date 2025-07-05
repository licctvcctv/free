
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/video/video_model.dart';
import 'package:freego_flutter/http/http.dart';

class VideoItemWidget extends StatelessWidget{
  static const double VIDEO_CONTENT_HEIGHT = 40;

  final VideoModel video;
  final Function()? onTap;
  const VideoItemWidget(this.video, {this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 40) / 2;
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Colors.black,
        padding: EdgeInsets.zero,
        minimumSize: Size.zero
      ),
      onPressed: onTap,
      child: Container(
        height: width,
        width: width,
        alignment: Alignment.topCenter,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey, strokeAlign: BorderSide.strokeAlignOutside)
        ),
        child: Stack(
          children: [
            SizedBox(
              height: width,
              width: width,
              child: Image.network(getFullUrl(video.pic!))
            ),
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.only(left: 4, right: 4),
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(0, 0, 0, 0.3)
                ),
                alignment: Alignment.center,
                height: VIDEO_CONTENT_HEIGHT,
                width: width,
                child: Text(video.name!, style: const TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis, maxLines: 2,),
              ),
            )
          ],
        )
      ),
    );
  }

}
