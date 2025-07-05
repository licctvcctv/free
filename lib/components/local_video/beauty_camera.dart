
import 'dart:async';
import 'dart:io';

import 'package:beauty_cam/beauty_cam.dart';
import 'package:beauty_cam/camera_view.dart';
import 'package:ffmpeg_kit_flutter_video/ffmpeg_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/local_video/filter.dart';
import 'package:freego_flutter/components/local_video/local_video.dart';
import 'package:freego_flutter/components/local_video/music_choose.dart';
import 'package:freego_flutter/components/local_video/video_upload.dart';
import 'package:freego_flutter/components/view/merry_go_round.dart';
import 'package:freego_flutter/util/date_time_util.dart';
import 'package:freego_flutter/util/local_file_util.dart';
import 'package:freego_flutter/util/local_user.dart';
import 'package:freego_flutter/util/permission_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock/wakelock.dart';

class BeautyCameraPage extends StatefulWidget{
  const BeautyCameraPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return BeautyCameraPageState();
  }
  
}

class BeautyCameraPageState extends State<BeautyCameraPage>{

  static SystemUiOverlayStyle statusBarStyle = ThemeUtil.statusBarThemeLight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size.zero,
        child: Container(
          color: Colors.black,
        ),
      ),
      body: const BeautyCameraWidget(),
    ); 
  }

}

class BeautyCameraWidget extends StatefulWidget{
  const BeautyCameraWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return BeautyCameraState();
  }

}

class BeautyCameraState extends State<BeautyCameraWidget> with TickerProviderStateMixin, WidgetsBindingObserver{

  static const String saveDirName = 'camera';
  static const String savePrefix = 'free-video';

  static const double FILTER_HEIGHT = 40;
  static const int ANIM_MILLI_SECONDS = 350;

  BeautyCam? cameraFlutterPluginDemo;
  late CameraView cameraView;

  Widget svgCameraStart = SvgPicture.asset('assets/camera/camera_start.svg', color: ThemeUtil.foregroundColor,);
  Widget svgCameraStop = SvgPicture.asset('assets/camera/camera_start.svg', color: const Color.fromRGBO(3, 169, 244, 0.8),);
  Widget svgCameraSwitch = SvgPicture.asset('assets/camera/camera_switch.svg', color: ThemeUtil.foregroundColor,);
  Widget svgCameraFilter = SvgPicture.asset('assets/camera/camera_filter.svg', color: ThemeUtil.foregroundColor,);
  Widget svgCameraMusic = SvgPicture.asset('assets/camera/camera_music.svg', color: ThemeUtil.foregroundColor,);
  Widget svgCameraCancel = SvgPicture.asset('assets/camera/camera_cancel.svg', color: ThemeUtil.foregroundColor,);
  Widget svgCameraBrowse = SvgPicture.asset('assets/camera/camera_browse.svg', color: ThemeUtil.foregroundColor,);

  bool showFilterOptionsWill = false;
  bool showFilterOptions = false;
  late AnimationController filterOptionsController;

  bool showBubble = false;
  bool showBubbleQuit = false;
  String? lastOutputPath;
  String? lastCoverPath;
  Timer? bubbleTimer;
  static const int BUBBLE_FADE_MILLI_SECONDS = 350;
  static const String coverDirPath = '/camera/cover';
  late AnimationController bubbleFadeController;

  List<Filter> filterList = [
    FilterLib().noFilter,
    FilterLib().motionFlow,
    FilterLib().softlight,
    FilterLib().hardlight,
    FilterLib().vividlight,
    FilterLib().linearlight,
    FilterLib().pinlight,
    FilterLib().hardmix,
    FilterLib().colorburn,
    FilterLib().colorodge,
    FilterLib().sharpen,
    FilterLib().saturation
  ];

  bool isRecording = false;
  String? musicPath;
  int recordSeconds = 0;
  Timer? recordingTimer;
  bool isShowMusicCancel = false;

  void onCameraCreate(BeautyCam beautyCam) async{

    if(!mounted || !context.mounted){
      return;
    }

    bool isGranted = await PermissionUtil().requestPermission(context: context, permission: Permission.camera, info: '希望获取相机权限用于录制视频');
    if(!isGranted){
      ToastUtil.error('获取相机权限失败');
    }
    else{
      beautyCam.switchCamera();
      beautyCam.switchCamera();
    }

    cameraFlutterPluginDemo = beautyCam;
    beautyCam.setBeautyLevel(1);
    beautyCam.enableBeauty(true);
    Directory? baseDir = await LocalFileUtil.getResourcePath();
    Directory? directory;
    if(baseDir != null){
      String directoryPath = '${baseDir.path}/$saveDirName';
      directory = Directory(directoryPath);
    }
    if(directory == null){
      return;
    }
    if(!directory.existsSync()){
      directory.createSync(recursive: true);
    }
    beautyCam.setOuPutFilePath(directory.path);
    FilterLib().loadResources().then((path){
      if(path == null){
        return;
      }
      beautyCam.setLoadImageResource(path);
      filterList.add(FilterLib().edgyamber);
      filterList.add(FilterLib().filmstock);
      filterList.add(FilterLib().foggynight);
      filterList.add(FilterLib().latesunset);
      filterList.add(FilterLib().softwarming);
      filterList.add(FilterLib().wildbird);
      if(mounted && context.mounted){
        setState(() {
        });
      }
    });
  }

  @override
  void initState(){
    super.initState();
    cameraView = CameraView(
      onCreated: onCameraCreate,
    );
    filterOptionsController = AnimationController(vsync: this, duration: const Duration(milliseconds: ANIM_MILLI_SECONDS));
    bubbleFadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: ANIM_MILLI_SECONDS));
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose(){
    filterOptionsController.dispose();
    bubbleFadeController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state){
    if(state == AppLifecycleState.paused){
      resetRecord();
    }
    else if(state == AppLifecycleState.resumed){
      setState(() {
      });
    }
  }

  void resetRecord(){
    isRecording = false;
    Wakelock.disable();
    recordingTimer?.cancel();
    setState(() {
    });
  }

  Future stopRecord() async{
    if(Platform.isAndroid){
      bool isGranted = await PermissionUtil().requestPermission(context: context, permission: Permission.manageExternalStorage, info: '希望获取外部存储权限用于保存视频');
      if(!isGranted){
        ToastUtil.error('获取存储权限失败');
        return;
      }
    }
    else{
      bool isGranted = await PermissionUtil().requestPermission(context: context, permission: Permission.storage, info: '希望获取存储权限用于保存视频');
      if(!isGranted){
        ToastUtil.error('获取存储权限失败');
        return;
      }
    }
    String? savePath = await cameraFlutterPluginDemo?.stopVideo();
    isRecording = false;
    Wakelock.disable();
    if(mounted && context.mounted){
      setState(() {
      });
    }
    recordingTimer?.cancel();
    if(savePath == null){
      return;
    }
    File file = File(savePath);
    if(!file.existsSync()){
      ToastUtil.error('保存失败');
      return;
    }

    String fastOutputPath = '';
    {
      int index = savePath.lastIndexOf('.');
      fastOutputPath = '${savePath.substring(0, index)}_tmp.mp4';
    }

    String fastCommand = '-y -i "$savePath" -c copy -map 0 -movflags +faststart "$fastOutputPath"';
    await FFmpegKit.execute(fastCommand);
    File(savePath).deleteSync();
    File(fastOutputPath).renameSync(savePath);

    String? cameraDirPath;
    if(Platform.isAndroid){
      cameraDirPath = LocalFileUtil.androidRootCamera;
    }
    else if(Platform.isIOS){
      Directory? directory = await LocalFileUtil.getProejctPath();
      if(directory == null){
        ToastUtil.error('获取保存目录失败');
        return;
      }
      cameraDirPath = '${directory.path}/$saveDirName';
    }
    if(cameraDirPath == null){
      ToastUtil.error('不支持的平台');
      return;
    }
    String outputPath = '$cameraDirPath/$savePrefix-${DateTimeUtil.getFormatedForFile(DateTime.now())}.mp4';
    if(musicPath == null){
      File destFile = file.copySync(outputPath);
      file.deleteSync();
      file = destFile;
    }
    else{
      String command = '-i "$savePath" -stream_loop -1 -i "$musicPath" -c:v copy -filter_complex "[0:a]aformat=fltp:44100:stereo,apad[0a];[1]aformat=fltp:44100:stereo,volume=40[1a];[0a][1a]amerge[a]" -map 0:v -map "[a]" -ac 2 -shortest "$outputPath"';
      await FFmpegKit.execute(command);
      file.deleteSync();
    }
    Directory? coverDir = await LocalFileUtil.getResourcePath();
    if(coverDir == null){
      return;
    }
    coverDir = Directory(coverDir.path + coverDirPath);
    if(!coverDir.existsSync()){
      coverDir.createSync(recursive: true);
    }
    String pureName = LocalFileUtil.getFileNameWithoutExtendsion(outputPath);
    String coverPath = '${coverDir.path}/$pureName.jpg';
    String coverCommand = '-i "$outputPath" -frames:v 1 -q:v 5 -s 180x320 "$coverPath"';
    await FFmpegKit.execute(coverCommand);

    File coverFile = File(coverPath);
    if(coverFile.existsSync()){
      if(LocalUser.isLogined()){
        showBubble = true;
        showBubbleQuit = false;
        lastOutputPath = outputPath;
        lastCoverPath = coverPath;
        if(mounted && context.mounted){
          setState(() {
          });
        }
        bubbleFadeController.value = 1;
        bubbleTimer?.cancel();
        bubbleTimer = Timer.periodic(const Duration(seconds: 20), (timer) { 
          bubbleFadeController.reverse(from: 1).then((value){
            showBubble = showBubbleQuit = false;
            if(mounted && context.mounted){
              setState(() {
              });
            }
          });
          timer.cancel();
        });
      }
      else{
        ToastUtil.hint('保存成功');
      }
    }
    if(Platform.isAndroid){
      MediaScanner.loadMedia(path: outputPath);
    }
  }

  Future startRecord() async{
    {
      bool isGranted = await PermissionUtil().requestPermission(context: context, permission: Permission.microphone, info: '希望获取麦克风权限用于录制声音');
      if(!isGranted){
        ToastUtil.error('获取录音权限失败');
        return;
      }
    }
    if(mounted && context.mounted){
      bool isGranted = await PermissionUtil().requestPermission(context: context, permission: Permission.camera, info: '希望获取相机权限用于录制画面');
      if(!isGranted){
        ToastUtil.error('获取相机权限失败');
        return;
      }
    }
    if(mounted && context.mounted){
      if(Platform.isAndroid){
        bool isGranted = await PermissionUtil().requestPermission(context: context, permission: Permission.manageExternalStorage, info: '希望获取外部存储权限用于保存视频');
        if(!isGranted){
          ToastUtil.error('获取存储权限失败');
          return;
        }
      }
      else{
        bool isGranted = await PermissionUtil().requestPermission(context: context, permission: Permission.storage, info: '希望获取存储权限用于保存视频');
        if(!isGranted){
          ToastUtil.error('获取存储权限失败');
          return;
        }
      }
    }
    cameraFlutterPluginDemo?.takeVideo();
    Wakelock.enable();
    isRecording = true;
    setState(() {
    });
    recordSeconds = 0;
    recordingTimer?.cancel();
    recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) { 
      recordSeconds++;
      setState(() {
      });
    });
  }

  Future chooseMusic() async{
    bool isGranted = await PermissionUtil().requestPermission(context: context, permission: Permission.storage, info: '希望获取存储权限用于选择音乐');
    if(!isGranted){
      ToastUtil.error('获取存储权限失败');
      return;
    }
    if(mounted && context.mounted){
      String? path = await Navigator.of(context).push(MaterialPageRoute(builder: (context){
        return const MusicChoosePage();
      }));
      if(path != null){
        musicPath = path;
      }
    }
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.black,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          cameraView,
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              isRecording ?
              Container(
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(255, 255, 255, 0.8),
                  borderRadius: BorderRadius.all(Radius.circular(12))
                ),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                child: Text(DateTimeUtil.getDurationText(Duration(seconds: recordSeconds))),
              ):
              const SizedBox(),
              Container(
                width: double.infinity,
                height: 100,
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(255, 255, 255, 0.8),
                  borderRadius: BorderRadius.all(Radius.circular(20))
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(
                      width: 40
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: InkWell(
                        onTap: (){
                          if(isRecording){
                            stopRecord();
                          }
                          else{
                            startRecord();
                          }
                        },
                        child: isRecording ?
                        svgCameraStop :
                        svgCameraStart
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () async{
                          if(Platform.isAndroid){
                            bool isGranted = await PermissionUtil().requestPermission(context: context, permission: Permission.manageExternalStorage, info: '希望获取外部存储权限用于访问手机视频');
                            if(!isGranted){
                              ToastUtil.error('获取存储权限失败');
                              return;
                            }
                          }
                          else if(Platform.isIOS){
                            bool isGranted = await PermissionUtil().requestPermission(context: context, permission: Permission.storage, info: '希望获取存储权限用于访问手机视频');
                            if(!isGranted){
                              ToastUtil.error('获取存储权限失败');
                              return;
                            }
                          }
                          if(mounted && context.mounted){
                            Navigator.of(context).push(MaterialPageRoute(builder: (context){
                              return const LocalVideoPage();
                            }));
                          }
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: svgCameraBrowse,
                            ),
                            const Text('相册', style: TextStyle(color: ThemeUtil.foregroundColor),)
                          ],
                        ),
                      ),
                    )
                  ],
                )
              )
            ],
          ),
          Positioned(
            left: 0,
            top: 10,
            child: 
            musicPath == null ?
            const SizedBox() :
            GestureDetector(
              onLongPress: (){
                isShowMusicCancel = true;
                setState(() {
                });
              },
              child: Container(
                width: screenSize.width / 2 - 10,
                height: 66,
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(255, 255, 255, 0.6),
                  borderRadius: BorderRadius.all(Radius.circular(12))
                ),
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if(isShowMusicCancel)
                    Align(
                      alignment: Alignment.topRight,
                      child: InkWell(
                        onTap: (){
                          musicPath = null;
                          isShowMusicCancel = false;
                          setState(() {
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 4),
                          child: SizedBox(
                            width: 12,
                            height: 12,
                            child: svgCameraCancel,
                          ),
                        ),
                      )
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: svgCameraMusic,
                        ),
                        Expanded(
                          child: MerryGoRound(
                            Text(LocalFileUtil.getFileName(musicPath!), style: const TextStyle(color: ThemeUtil.foregroundColor)),
                          ),
                        )
                      ],
                    )
                  ],
                )
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 10,
            child: Container(
              width: screenSize.width / 2,
              height: 66,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 0.6),
                borderRadius: BorderRadius.all(Radius.circular(20))
              ),
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: (){
                      cameraFlutterPluginDemo?.switchCamera();
                    },
                    child: svgCameraSwitch,
                  ),
                  InkWell(
                    onTap: shiftFilterOptions,
                    child: Column(
                      children: [
                        svgCameraFilter,
                        const Text('滤镜', style: TextStyle(fontSize: 14, color: ThemeUtil.foregroundColor),)
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: chooseMusic,
                    child: Column(
                      children: [
                        svgCameraMusic,
                        const Text('音乐', style: TextStyle(fontSize: 14, color: ThemeUtil.foregroundColor),)
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 80,
            child: Offstage(
              offstage: !showFilterOptions,
              child: FadeTransition(
                opacity: filterOptionsController,
                child: Container(
                  width: 100,
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 0.6),
                    borderRadius: BorderRadius.all(Radius.circular(12))
                  ),
                  constraints: const BoxConstraints(
                    maxHeight: 400
                  ),
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: getFilterOptionsWidget()
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 8,
            bottom: 8,
            child: showBubble ?
            GestureDetector(
              onTap: (){
                if(lastOutputPath == null){
                  ToastUtil.error('视频不存在');
                  showBubble = false;
                  setState(() {
                  });
                  return;
                }
                File file = File(lastOutputPath!);
                if(!file.existsSync()){
                  ToastUtil.error('视频不存在');
                  showBubble = false;
                  setState(() {
                  });
                }
                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                  return VideoUploadPage(entity: file, cover: lastCoverPath,);
                }));
              },
              onLongPress: (){
                showBubbleQuit = true;
                setState(() {
                });
              },
              child: FadeTransition(
                opacity: bubbleFadeController,
                child: Stack(
                  children: [
                    Container(
                      width: 80,
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12), bottomRight: Radius.circular(12))
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 72,
                            height: 72,
                            child: Image.file(File(lastCoverPath!), fit: BoxFit.cover,),
                          ),
                          const SizedBox(height: 8,),
                          const Text('发布', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 14),),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: showBubbleQuit ?
                      InkWell(
                        onTap: (){
                          showBubble = false;
                          setState(() {
                          });
                        },
                        child: const Icon(Icons.cancel, color: Color.fromRGBO(244, 67, 54, 0.8), size: 30,),
                      ) : const SizedBox()
                    )
                  ],
                ),
              ),
            ) : const SizedBox()
          )
        ],
      ),
    );
  }

  List<Widget> getFilterOptionsWidget(){
    List<Widget> widgets = [];
    for(Filter filter in filterList){
      widgets.add(
        InkWell(
          onTap: (){
            cameraFlutterPluginDemo?.addFilter(filter.script);
          },
          child: SizedBox(
            height: FILTER_HEIGHT,
            child: Align(
              alignment: Alignment.center,
              child: Text(filter.name, style: const TextStyle(color: ThemeUtil.foregroundColor),),
            ),
          ),
        )
      );
    }
    return widgets;
  }

  void shiftFilterOptions(){
    if(!showFilterOptionsWill){
      showFilterOptionsWill = true;
      showFilterOptions = true;
      setState(() {
      });
      filterOptionsController.forward();
    }
    else{
      showFilterOptionsWill = false;
      filterOptionsController.reverse().then((value) {
        showFilterOptions = false;
        setState(() {
        });
      });
    }
  }
}
