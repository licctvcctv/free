
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/view/image_group_viewer.dart';

class ImageDisplayWidget extends StatelessWidget{

  static const double SPACING = 10;
  static const double RUN_SPACING = 10;

  final List<String> pics;
  final double? size;
  const ImageDisplayWidget(this.pics, {this.size, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      child: Wrap(
        spacing: SPACING,
        runSpacing: RUN_SPACING,
        children: getImages(context),
      ),
    );
  }

  List<Widget> getImages(BuildContext context){
    List<Widget> widgets = [];
    double width = size ?? (MediaQuery.of(context).size.width - 24) / 3;
    List<String> showList = pics;
    for(int i = 0; i < showList.length; ++i){
      String pic = showList[i];
      widgets.add(
        Container(
          width: width,
          height: width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0xee, 0xee, 0xee, 1),
                offset: Offset(2, 0),
                blurRadius: 2
              ),
              BoxShadow(
                color: Color.fromRGBO(0xee, 0xee, 0xee, 1),
                offset: Offset(0, 2),
                blurRadius: 2
              ),
            ]
          ),
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context){
                return ImageGroupViewer(showList, initIndex: i,);
              }));
            },
            child: Image.network(pic, fit: BoxFit.cover,),
          ),
        )
      );
    }
    return widgets;
  }
}
