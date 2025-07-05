
import 'dart:io';

import 'package:dotted_line/dotted_line.dart';
import 'package:ffmpeg_kit_flutter_video/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_video/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_video/media_information.dart';
import 'package:ffmpeg_kit_flutter_video/media_information_session.dart';
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/custom_indicator.dart';
import 'package:freego_flutter/components/view/video_player.dart';
import 'package:freego_flutter/util/date_time_util.dart';
import 'package:freego_flutter/util/local_file_util.dart';
import 'package:freego_flutter/util/permission_util.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class VideoChoosePage extends StatelessWidget{
  const VideoChoosePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 10,
        backgroundColor: Colors.white,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      body: const VideoChooseWidget(),
    );
  }
  
}

class VideoChooseWidget extends StatefulWidget{
  const VideoChooseWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return VideoChooseState();
  }
  
}

class VideoChooseState extends State<VideoChooseWidget>{

  List<AssetPathEntity> pathList = [];
  AssetPathEntity? currentPath;
  
  List<AssetEntity> entityList = [];

  List<FileSystemEntity> entities = [];
  bool isGetting = false;

  @override
  void initState(){
    super.initState();
    Future.delayed(Duration.zero, () async{
      bool isGranted = await PermissionUtil().requestPermission(context: context, permission: Permission.storage, info: '希望获取存储权限用于选择视频');
      if(!isGranted){
        return;
      }
      pathList = await PhotoManager.getAssetPathList(
        type: RequestType.video,
        filterOption: FilterOptionGroup(
          orders: const [OrderOption(type: OrderOptionType.createDate, asc: false)],
          containsLivePhotos: false
        )
      );
      if(pathList.isNotEmpty){
        choosePath(pathList.first);
      }
    });
  }

  Future choosePath(AssetPathEntity path) async{
    currentPath = path;
    entities = [];
    setState(() {
    });
    entityList = await currentPath!.getAssetListRange(start: 0, end: 10);
    for(AssetEntity entity in entityList){
      File? file = await entity.file;
      if(file != null){
        entities.add(file);
      }
    }
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeUtil.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonHeader(
            center: Text('我的拍摄', style: TextStyle(color: Colors.white),),
          ),
          InkWell(
            onTap: showPathChooseDialog,
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Text(currentPath?.name ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
            ),
          ),
          const DottedLine(
            dashColor: ThemeUtil.dividerColor,
          ),
          if(entities.isNotEmpty)
          Expanded(
            child: CustomIndicatorWidget(
              content: Column(
                children: getChilds(),
              ),
              touchBottom: () async{
                if(currentPath == null){
                  return;
                }
                if(isGetting){
                  return;
                }
                isGetting = true;
                int start = entityList.length;
                int end = start + 10;
                List<AssetEntity> tmpList = await currentPath!.getAssetListRange(start: start, end: end);
                if(tmpList.isNotEmpty){
                  entityList.addAll(tmpList);
                  for(AssetEntity entity in tmpList){
                    File? file = await entity.file;
                    if(file != null){
                      entities.add(file);
                    }
                  }
                  if(mounted && context.mounted){
                    setState(() {
                    });
                  }
                }
                isGetting = false;
              },
            )
          )
        ],
      )
    );
  }
  
  List<Widget> getChilds(){
    List<Widget> widgets = [];
    for(FileSystemEntity entity in entities){
      widgets.add(LocalVideoItemWidget(entity));
      widgets.add(getDashedDivider());
    }
    return widgets;
  }

  Widget getDashedDivider(){
    return const Padding(
      padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
      child: DottedLine(dashColor: ThemeUtil.dividerColor),
    );
  }

  void showPathChooseDialog(){
    showGeneralDialog(
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: Colors.transparent,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4
                    )
                  ]
                ),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 3,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  physics: const ClampingScrollPhysics(),
                  itemCount: pathList.length + 1,
                  itemBuilder: (context, index) {
                    if(index == 0){
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Text('选择目录', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
                          ),
                          Divider(),
                        ],
                      );
                    }
                    AssetPathEntity path = pathList[index - 1];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: (){
                            choosePath(path);
                            Navigator.of(context).pop();
                            setState(() {
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            width: double.infinity,
                            child: Text(path.name, style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
                          ),
                        ),
                        const Divider(),
                      ],
                    );
                  },
                ),
              ),
            )
          ],
        );
      },
    );
  }
}

class LocalVideoItemWidget extends StatefulWidget{
  final FileSystemEntity entity;
  const LocalVideoItemWidget(this.entity, {super.key});

  @override
  State<StatefulWidget> createState() {
    return LocalVideoItemState();
  }

}

class LocalVideoItemState extends State<LocalVideoItemWidget>{

  static const double COVER_SIZE = 66;
  static const double ACTION_SIZE = 36;
  static const String coverDirPath = '/camera/cover';

  String? coverPath;

  @override
  void initState(){
    super.initState();
    FileSystemEntity entity = widget.entity;
    Future.delayed(Duration.zero, () async{
      Directory? coverDir = await LocalFileUtil.getResourcePath();
      if(coverDir == null){
        return;
      }
      coverDir = Directory(coverDir.path + coverDirPath);
      if(!coverDir.existsSync()){
        coverDir.createSync(recursive: true);
      }
      String pureName = LocalFileUtil.getFileNameWithoutExtendsion(entity.path);
      String coverPath = '${coverDir.path}/$pureName.jpg';
      String command = '-i "${entity.path}" -frames:v 1 -q:v 5 -s 180x320 "$coverPath"';
      await FFmpegKit.execute(command);
      this.coverPath = coverPath;
      if(mounted && context.mounted){
        setState((){});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    FileSystemEntity entity = widget.entity;
    return Container(
      margin: const EdgeInsets.only(top: 5, bottom: 5),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          ClipOval(
            child: SizedBox(
              width: COVER_SIZE,
              height: COVER_SIZE,
              child: coverPath == null ?
              const ColoredBox(color: Colors.black) :
              Image.file(File(coverPath!), fit: BoxFit.cover)
            ),
          ),
          const SizedBox(width: 6,),
          Row(
            children: [
              InkWell(
                onTap: onTapPlay,
                child: const Icon(Icons.play_arrow_rounded, color: ThemeUtil.foregroundColor, size: ACTION_SIZE,),
              ),
              const SizedBox(width: 6,),
              InkWell(
                onTap: onTapInfo,
                child: const Icon(Icons.info_outline, color: ThemeUtil.foregroundColor, size: ACTION_SIZE,),
              ),
              const SizedBox(width: 6,)
            ],
          ),
          Expanded(
            child: Text(DateTimeUtil.getFileTime(entity.statSync().modified), textAlign: TextAlign.start, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 14),),
          ),
          InkWell(
            onTap: (){
              Navigator.of(context).pop({
                'entity': widget.entity,
                'cover': coverPath
              });
            },
            child: const Icon(Icons.arrow_forward_outlined, color: ThemeUtil.foregroundColor, size: ACTION_SIZE,),
          ),
        ],
      ),
    );   
  }

  void onTapPlay(){
    Navigator.of(context).push(MaterialPageRoute(builder: (context){
      return VideoPlayerPage(widget.entity.path, sourceType: VideoSourceType.local,);
    }));
  }

  Future onTapInfo() async{
    FileStat stat = widget.entity.statSync();
    MediaInformationSession session = await FFprobeKit.getMediaInformation(widget.entity.path);
    MediaInformation? info = session.getMediaInformation();
    Duration? duration;
    if(info != null){
      String? durationStr = info.getDuration();
      if(durationStr != null){
        int? seconds = double.tryParse(durationStr)?.toInt();
        if(seconds != null){
          duration = Duration(seconds: seconds);
        }
      }
    }
    if(context.mounted){
      showGeneralDialog(
        context: context, 
        barrierDismissible: true,
        barrierLabel: '',
        barrierColor: Colors.transparent,
        transitionBuilder: ((context, animation, secondaryAnimation, child) {
          return Transform.scale(
            scaleY: animation.value,
            alignment: Alignment.center,
            child: child,
          );
        }),
        pageBuilder: ((context, animation, secondaryAnimation) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Material(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4
                      )
                    ]
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text('路径：', style: TextStyle(color: ThemeUtil.foregroundColor),),
                          Expanded(
                            child: Text(widget.entity.path, style: const TextStyle(color: ThemeUtil.foregroundColor),),
                          )
                        ],
                      ),
                      const SizedBox(height: 10,),
                      Row(
                        children: [
                          const Text('大小：', style: TextStyle(color: ThemeUtil.foregroundColor),),
                          Expanded(
                            child: Text(StringUtil.getSizeText(stat.size), style: const TextStyle(color: ThemeUtil.foregroundColor),),
                          )
                        ],
                      ),
                      const SizedBox(height: 10,),
                      Row(
                        children: [
                          const Text('修改时间：', style: TextStyle(color: ThemeUtil.foregroundColor),),
                          Expanded(
                            child: Text(DateTimeUtil.getFileTime(stat.modified), style: const TextStyle(color: ThemeUtil.foregroundColor),),
                          )
                        ],
                      ),
                      const SizedBox(height: 10,),
                      Row(
                        children: [
                          const Text('时长：', style: TextStyle(color: ThemeUtil.foregroundColor),),
                          Expanded(
                            child: Text(duration != null ? DateTimeUtil.getVideoTime(duration) : '未知', style: const TextStyle(color: ThemeUtil.foregroundColor),),
                          )
                        ],
                      ),
                      const SizedBox(height: 10,),
                      Row(
                        children: [
                          const Text('码率：', style: TextStyle(color: ThemeUtil.foregroundColor),),
                          Expanded(
                            child: Text(info?.getBitrate() ?? '未知', style: const TextStyle(color: ThemeUtil.foregroundColor),),
                          )
                        ]
                      ),
                      const SizedBox(height: 10,),
                    ],
                  ),
                ),
              )
            ],
          );
        })
      );
    }
  }
}
