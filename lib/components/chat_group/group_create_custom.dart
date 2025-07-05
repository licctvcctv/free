
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/util/cropped_util.dart';
import 'package:freego_flutter/util/dictionary_util.dart';
import 'package:freego_flutter/util/file_upload_util.dart';
import 'package:freego_flutter/util/image_util.dart';
import 'package:freego_flutter/util/permission_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class GroupCreatePage extends StatelessWidget{
  const GroupCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 10,
        backgroundColor: ThemeUtil.backgroundColor,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      resizeToAvoidBottomInset: false,
      body: const GroupCreateWidget(),
    );
  }
  
}

class GroupCreateWidget extends StatefulWidget{
  const GroupCreateWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return GroupCreateState();
  }
  
}

class GroupCreateState extends State<GroupCreateWidget>{

  String? avatar;
  String? name;
  String? description;

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void dispose(){
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Container(
        color: ThemeUtil.backgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CommonHeader(
              center: Text('创建群聊', style: TextStyle(color: Colors.white, fontSize: 18),),
            ),
            Expanded(
              child: Stack(
                children: [
                  Opacity(
                    opacity: 0.6,
                    child: Image.asset(
                      'images/scenary.jpg',
                      fit: BoxFit.fill,
                      height: double.infinity,
                    ),
                  ),
                  ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const ClampingScrollPhysics(),
                    children: [
                      const SizedBox(height: 60,),
                      getAvatarWidget(),
                      const SizedBox(height: 30,),
                      getNameWidget(),
                      const SizedBox(height: 40,),
                      getDescriptionWidget(),
                      const SizedBox(height: 60,),
                      getSubmitWidget()
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget getSubmitWidget(){
    const double height = 60;
    const double width = 200;
    return Column(
      children: [
        SizedBox(
          width: width,
          height: height,
          child: TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: Colors.lightBlue
            ),
            onPressed: (){
              
            },
            child: const Text('创建', style: TextStyle(color: Colors.white, fontSize: 18),),
          ),
        )
      ],
    );
  }

  Widget getDescriptionWidget(){
    const double height = 60;
    const double width = 240;
    return Container(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('群介绍：', style: TextStyle(color: ThemeUtil.foregroundColor),),
          const SizedBox(height: 10,),
          Container(
            height: height,
            width: width,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4
                )
              ]
            ),
            child: TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.all(4),
                counterText: '',
                hintText: 'We like free to go',
                hintStyle: TextStyle(color: Colors.grey)
              ),
              maxLength: DictionaryUtil.GROUP_DESCRIPTION_MAX_LENGTH,
              style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 18),
            ),
          )
        ],
      ),
    );
  }

  Widget getNameWidget(){
    const double height = 60;
    const double width = 240;
    return Container(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('群名称：', style: TextStyle(color: ThemeUtil.foregroundColor),),
          const SizedBox(height: 10,),
          Container(
            height: height,
            width: width,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4
                )
              ]
            ),
            child: TextField(
              controller: nameController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.all(4),
                counterText: '',
                hintText: 'I like free to go',
                hintStyle: TextStyle(color: Colors.grey)
              ),
              maxLength: DictionaryUtil.GROUP_NAME_MAX_LENGTH,
              style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 18),
            ),
          )
        ],
      ),
    );
  }
  
  Widget getAvatarWidget(){
    const double avatarSize = 120;
    return GestureDetector(
      onTap: () async{
        bool isGranted = await PermissionUtil().requestPermission(context: context, permission: Permission.storage, info: '希望获取存储权限用于从相册中选择图片');
        if(!isGranted){
          ToastUtil.error('获取存储权限失败');
          return;
        }
        if(mounted && context.mounted){

          AssetPickerConfig config = ImageUtil.buildDefaultImagePickerConfig();
          final List<AssetEntity>? result = await AssetPicker.pickAssets(
            context,
            pickerConfig: config,
          );
          if(result == null || result.isEmpty){
            return;
          }
          File? file = await result.first.file;
          if (file == null) {
            ToastUtil.error('获取路径失败');
            return;
          }
          String? croppedPath = await CroppedUtil().getCroppedFile(file);
          if(croppedPath == null){
            return;
          }
          // String name = LocalFileUtil.getFileName(croppedPath);
          String? url = await FileUploadUtil().upload(path: croppedPath);
          if(url == null){
            ToastUtil.error('上传文件失败');
            return;
          }
          avatar = url;
          resetState();
        }
      },
      child: SizedBox(
        width: avatarSize,
        height: avatarSize,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            avatar != null ?
            CircleAvatar(
              radius: avatarSize / 2,
              backgroundImage: NetworkImage(getFullUrl(avatar!)),
            ) :
            const CircleAvatar(
              radius: avatarSize / 2,
              backgroundColor: ThemeUtil.buttonColor,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Text('群头像', style: TextStyle(color: Colors.white, fontSize: 18),),
                Icon(
                  Icons.add,
                  size: avatarSize / 3,
                  color: Colors.white,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void resetState(){
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }
}
