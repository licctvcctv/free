
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:freego_flutter/components/local_video/music_http.dart';
import 'package:freego_flutter/components/local_video/music_model.dart';
import 'package:freego_flutter/components/view/collapsible_view.dart';
import 'package:freego_flutter/components/view/progress_widget.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/http/http_tool.dart';
import 'package:freego_flutter/util/local_file_util.dart';
import 'package:freego_flutter/util/permission_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class MusicChoosePage extends StatefulWidget{
  const MusicChoosePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return MusicChoosePageState();
  }

}

class MusicChoosePageState extends State<MusicChoosePage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
        backgroundColor: Colors.black87,
        systemOverlayStyle: ThemeUtil.statusBarThemeLight,
      ),
      resizeToAvoidBottomInset: false,
      body: const MusicChooseWidget(),
    );
  }

}

class MusicChooseWidget extends StatefulWidget{
  const MusicChooseWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return MusicChooseState();
  }

}

class PathWrapper{
  AssetPathEntity path;
  List<AssetEntity> list = [];
  int count = 0;
  bool isCollapsed = true;
  CollapsibleController? controller;
  PathWrapper(this.path, {this.controller});
}

class MusicChooseState extends State<MusicChooseWidget>{

  static const double SINGLE_ROW_HEIGHT = 32;

  List<PathWrapper> wrapperList = [];

  Widget isCollapsed = const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 36,);
  Widget notCollapsed = const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white, size: 36,);
  Widget musicIcon = const Icon(Icons.music_note_rounded, color: Colors.white, size: 36,);

  AssetEntity? choosedLocalEntity;

  bool isRecommendedCollapsed = true;
  List<OnlineMusic> recommendedList = [];
  CollapsibleController recommendedController = CollapsibleController();
  OnlineMusic? choosedOnlineMusic;

  @override
  void initState(){
    super.initState();
    Future.delayed(Duration.zero, () async{
      int? maxId;
      if(recommendedList.isNotEmpty){
        maxId = recommendedList.last.id;
      }
      List<OnlineMusic>? tmpList = await MusicHttp().list(maxId: maxId);
      if(tmpList != null){
        recommendedList = tmpList;
        if(mounted && context.mounted){
          setState(() {
          });
        }
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) { 
          recommendedController.shift();
          isRecommendedCollapsed = false;
        });
      }
    });
    Future.delayed(Duration.zero, () async{
      PMFilter filter = FilterOptionGroup(
        imageOption: const FilterOption(
          needTitle: true,
          sizeConstraint: SizeConstraint(ignoreSize: true),
        ),
        audioOption: const FilterOption(
          needTitle: true,
          sizeConstraint: SizeConstraint(ignoreSize: true),
        ),
        containsPathModified: false,
        containsLivePhotos: false,
        createTimeCond: DateTimeCond.def().copyWith(ignore: true),
        updateTimeCond: DateTimeCond.def().copyWith(ignore: true),
      );
      List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(type: RequestType.audio, filterOption: filter);
      for(AssetPathEntity path in paths){
        PathWrapper wrapper = PathWrapper(path, controller: CollapsibleController());
        wrapperList.add(wrapper);
      }
      if(mounted && context.mounted){
        setState(() {
        });
      }
      for(PathWrapper wrapper in wrapperList){
        wrapper.count = await wrapper.path.assetCountAsync;
        if(wrapper.count > 0){
          wrapper.list = await wrapper.path.getAssetListRange(start: 0, end: wrapper.count);
        }
      }
      if(mounted && context.mounted){
        setState(() {
        });
      }
    });
  }

  @override
  void dispose(){
    recommendedController.dispose();
    for(PathWrapper wrapper in wrapperList){
      wrapper.controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(48, 48, 48, 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: const Color.fromRGBO(80, 80, 80, 1),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 48,
                    alignment: Alignment.center,
                    child: IconButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white,),
                    ),
                  ),
                  InkWell(
                    onTap: () async{
                      if(choosedLocalEntity != null){
                        File? file = await choosedLocalEntity?.file;
                        String? path = file?.path;
                        if(mounted && context.mounted){
                          Navigator.of(context).pop(path);
                        }
                      }
                      else if(choosedOnlineMusic != null){
                        Directory? directory = await LocalFileUtil.getProejctPath();
                        if(directory == null){
                          return;
                        }
                        String saveDirPath = directory.path;
                        if(choosedOnlineMusic!.path == null){
                          return;
                        }
                        String savePath = '$saveDirPath/music/${LocalFileUtil.getFileName(choosedOnlineMusic!.path!)}';
                        File file = File(savePath);
                        if(file.existsSync()){
                          if(mounted && context.mounted){
                            Navigator.of(context).pop(savePath);
                          }
                          if(choosedOnlineMusic!.id != null){
                            MusicHttp().incUseNum(choosedOnlineMusic!.id!);
                          }
                        }
                        else{
                          if(mounted && context.mounted){
                            bool isGranted = true;
                            if(Platform.isAndroid){
                              isGranted = await PermissionUtil().requestPermission(context: context, permission: Permission.manageExternalStorage, info: '希望获取外部存储权限用于保存音乐');
                            }
                            if(!isGranted){
                              ToastUtil.error('获取存储权限失败');
                            }
                            else{
                              if(mounted && context.mounted){
                                await showGeneralDialog(
                                  context: context, 
                                  pageBuilder: (context, anim, anim2){
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        MusicDownloadDialog(url: URL_FILE_DOWNLOAD + choosedOnlineMusic!.path!, savePath: savePath),
                                      ],
                                    );
                                  }
                                );
                                ToastUtil.hint('下载成功');
                              }
                            }
                          }
                          if(mounted && context.mounted){
                            Navigator.of(context).pop(savePath);
                          }
                        }
                      }
                      else if(mounted && context.mounted){
                        Navigator.of(context).pop();
                      }
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
                      child: const Text('确定', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),),
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              physics: const ClampingScrollPhysics(),
              children: [
                getRecommendedMusic(),
                getLocalMusic()
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget getRecommendedMusic(){
    List<Widget> widgets = [];
    widgets.add(
      Container(
        padding: const EdgeInsets.all(14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color.fromRGBO(80, 80, 80, 1)))
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: InkWell(
            onTap: () async{  
              recommendedController.shift();
              isRecommendedCollapsed = !isRecommendedCollapsed;
              setState(() {
              });
            },
            child: Row(
              children: [
                const Text('在线', style: TextStyle(color: ThemeUtil.backgroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
                const SizedBox(width: 4,),
                isRecommendedCollapsed ?
                isCollapsed : notCollapsed
              ],
            ),
          )
        ),
      )
    );
    List<Widget> musicItems = [];
    for(OnlineMusic music in recommendedList){
      if(music.path == null){
        continue;
      }
      musicItems.add(
        Container(
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color.fromRGBO(80, 80, 80, 1)))
          ),
          child: InkWell(
            onTap: (){
              if(choosedOnlineMusic == music){
                choosedOnlineMusic = null;
              }
              else{
                choosedOnlineMusic = music;
                choosedLocalEntity = null;
              }
              setState(() {
              });
            },
            child: Row(
              children: [
                musicIcon,
                const SizedBox(width: 6,),
                Expanded(
                  child: Text(LocalFileUtil.getFileName(music.path!), overflow: TextOverflow.ellipsis, style: const TextStyle(color: ThemeUtil.backgroundColor, fontWeight: FontWeight.bold, fontSize: 16),)
                ),
                const SizedBox(width: 6,),
                SizedBox(
                  width: SINGLE_ROW_HEIGHT,
                  height: SINGLE_ROW_HEIGHT,
                  child: Align(
                    alignment: Alignment.center,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(Icons.circle_outlined, size: SINGLE_ROW_HEIGHT, color: ThemeUtil.foregroundColor,),
                        music == choosedOnlineMusic ?
                        const Icon(Icons.done_rounded, size: SINGLE_ROW_HEIGHT, color: Colors.green,) :
                        const SizedBox()
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        )
      );
    }
    widgets.add(
      CollapsibleView(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: musicItems,
        ),
        controller: recommendedController,
      )
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget getLocalMusic(){
    List<Widget> widgets = [];
    for(PathWrapper wrapper in wrapperList){
      List<Widget> items = [];
      for(AssetEntity entity in wrapper.list){
        items.add(
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color.fromRGBO(80, 80, 80, 1)))
            ),
            child: InkWell(
              onTap: (){
                if(choosedLocalEntity == entity){
                  choosedLocalEntity = null;
                }
                else{
                  choosedLocalEntity = entity;
                  choosedOnlineMusic = null;
                }
                setState(() {
                });
                if(choosedLocalEntity != null){
                  Future.delayed(Duration.zero, () async{
                    File? file = await choosedLocalEntity!.file;
                    if(file == null){
                      return;
                    }
                    MusicHttp().upload(file.path);
                  });
                }
              },
              child: Row(
                children: [
                  musicIcon,
                  const SizedBox(width: 6,),
                  Expanded(
                    child: Text(entity.title ?? '', overflow: TextOverflow.ellipsis, style: const TextStyle(color: ThemeUtil.backgroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
                  ),
                  const SizedBox(width: 6,),
                  SizedBox(
                    width: SINGLE_ROW_HEIGHT,
                    height: SINGLE_ROW_HEIGHT,
                    child: Align(
                      alignment: Alignment.center,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(Icons.circle_outlined, size: SINGLE_ROW_HEIGHT, color: ThemeUtil.foregroundColor,),
                          entity == choosedLocalEntity ?
                          const Icon(Icons.done_rounded, size: SINGLE_ROW_HEIGHT, color: Colors.green,) :
                          const SizedBox()
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        );
      }
      widgets.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: (){
                wrapper.controller?.shift();
                wrapper.isCollapsed = !wrapper.isCollapsed;
                setState(() {
                });
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color.fromRGBO(80, 80, 80, 1)))
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Text(wrapper.path.name, style: const TextStyle(color: ThemeUtil.backgroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
                      const SizedBox(width: 4,),
                      wrapper.isCollapsed ?
                      isCollapsed : notCollapsed
                    ],
                  ),
                ),
              ),
            ),
            CollapsibleView(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: items,
              ),
              controller: wrapper.controller,
            )
          ],
        )
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}

class MusicDownloadDialog extends StatefulWidget{

  final String url;
  final String savePath;

  const MusicDownloadDialog({required this.url, required this.savePath, super.key});
  
  @override
  State<StatefulWidget> createState() {
    return MusicDownloadDialogState();
  }
}

class MusicDownloadDialogState extends State<MusicDownloadDialog>{

  int current = 0;
  int total = 1;

  @override
  void initState(){
    super.initState();
    HttpTool.download(widget.url, widget.savePath, onReceive: (current, total){
      this.current = current;
      this.total = total;
      if(mounted && context.mounted){
        if(current >= total){
          Navigator.of(context).pop();
        }
        else{
          setState(() {
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 20,
      height: 36,
      child: ProgressWidget(current: current, total: total),
    );
  }

}
