
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/view/image_viewer.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/util/file_upload_util.dart';
import 'package:freego_flutter/util/image_util.dart';
import 'package:freego_flutter/util/permission_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class ImageInputWidget extends StatefulWidget{

  final void Function(List<String>)? onChange;
  final int maxLength;
  final double? size;
  final double borderRadius;
  final Widget Function(int count)? addIcon;
  final List<String>? initPics;
  const ImageInputWidget({this.onChange, this.maxLength = 9, this.size, this.borderRadius = 10, this.addIcon, this.initPics, super.key});

  @override
  State<StatefulWidget> createState() {
    return ImageInputState();
  }

}

class ImageInputState extends State<ImageInputWidget>{

  Widget svgPhoto = SvgPicture.asset('svg/icon_photo.svg');
  List<String> pics = [];

  @override
  void initState(){
    super.initState();
    List<String>? initPics = widget.initPics;
    if(initPics != null && initPics.isNotEmpty){
      pics.addAll(initPics);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: getImages(),
    );
  }

  List<Widget> getImages(){
    List<Widget> widgets = [];
    double size = widget.size ?? (MediaQuery.of(context).size.width - 24) / 3;
    for(int i = 0; i < pics.length; ++i){
      String pic = pics[i];
      widgets.add(
        ImageBlockWidget(
          url: pic, 
          borderRadius: widget.borderRadius,
          size: size,
          onRemove: (){
            pics.removeAt(i);
            setState(() {
            });
            widget.onChange?.call(pics);
          },
        )
      );
    }
    if(pics.length < widget.maxLength){
      if(widget.addIcon != null){
        widgets.add(
          InkWell(
            onTap: chooseImage,
            child: widget.addIcon!(pics.length),
          )
        );
      }
      else{
        widgets.add(
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
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
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.grey
              ),
              onPressed: chooseImage,
              child: SizedBox(
                width: 50,
                height: 50,
                child: svgPhoto,
              ),
            ),
          )
        );
      }
    }
    return widgets;
  }

  Future chooseImage() async{
    //收起键盘
    if(context.mounted) {
      FocusScope.of(context).unfocus();
    }
    /*if(pics.length >= widget.maxLength){
      return;
    }*/
    if (pics.length >= widget.maxLength) {
      ToastUtil.error('最多只能选择 ${widget.maxLength} 张图片');
      return;
    }
    bool isGranted = await PermissionUtil().requestPermission(context: context, permission: Permission.storage, info: '希望获取存储权限用于从相册中选择图片');
    if(!isGranted){
      ToastUtil.error('获取存储权限失败');
      return;
    }
    int remainingSlots = widget.maxLength - pics.length;

    AssetPickerConfig config = ImageUtil.buildDefaultImagePickerConfig(maxAssets: remainingSlots);
    /*if(mounted && context.mounted){
      final List<AssetEntity>? results = await AssetPicker.pickAssets(
        context,
        pickerConfig: config,
      );
      if(results != null && results.isNotEmpty){
        AssetEntity entity = results[0];
        File? file = await entity.file;
        String path = file!.path;
        String name = path.substring(path.lastIndexOf('/') + 1, path.length);
        String? url = await FileUploadUtil().upload(path: path);
        if(url == null){
          return;
        }
        setState(() {
          pics.add(url);
        });
        if(widget.onChange != null){
          widget.onChange!(pics);
        }
      }
    }*/
    if (mounted && context.mounted) {
      final List<AssetEntity>? results = await AssetPicker.pickAssets(
        context,
        pickerConfig: config,
      );

      if (results != null && results.isNotEmpty) {
        // 批量上传图片
        List<String> newUrls = [];
        for (AssetEntity entity in results) {
          File? file = await entity.file;
          if (file != null) {
            String? url = await FileUploadUtil().upload(path: file.path);
            if (url != null) {
              newUrls.add(url);
            }
          }
        }

        if (newUrls.isNotEmpty) {
          setState(() {
            pics.addAll(newUrls);
          });
          widget.onChange?.call(pics);
        }
      }
    }
  }
}

class ImageBlockWidget extends StatefulWidget{

  final double size;
  final double? borderRadius;
  final String url;
  final Function()? onRemove;

  const ImageBlockWidget({required this.url, required this.size, this.borderRadius, this.onRemove, super.key});
  
  @override
  State<StatefulWidget> createState() {
    return ImageBlockState();
  }

}

class ImageBlockState extends State<ImageBlockWidget>{

  bool showRemoveButton = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onLongPress: (){
            showRemoveButton = true;
            setState(() {
            });
          },
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 0),
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
                  return ImageViewer(getFullUrl(widget.url));
                }));
              },
              child: Image.network(getFullUrl(widget.url), fit: BoxFit.cover,),
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: showRemoveButton ?
          InkWell(
            onTap: widget.onRemove,
            child: Icon(Icons.cancel, color: const Color.fromRGBO(244, 67, 54, 0.8), size: widget.size / 4,),
          ) : const SizedBox()
        )
      ],
    );
  }

}
