
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:freego_flutter/components/guide_neo/guide_http.dart';
import 'package:freego_flutter/components/guide_neo/guide_model.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/common_locate.dart';
import 'package:freego_flutter/components/view/image_input.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/http/http_gaode.dart';
import 'package:freego_flutter/model/map_poi.dart';
import 'package:freego_flutter/util/file_upload_util.dart';
import 'package:freego_flutter/util/image_util.dart';
import 'package:freego_flutter/util/permission_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class GuideCreatePage extends StatelessWidget{
  const GuideCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 10,
        backgroundColor: ThemeUtil.backgroundColor,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      body: GestureDetector(
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: const GuideCreateWidget(),
      ),
    );
  }
  
}

class GuideCreateWidget extends StatefulWidget{
  const GuideCreateWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return GuideCreateState();
  }

}

class GuideCreateState extends State<GuideCreateWidget> with SingleTickerProviderStateMixin{

  String? cover;

  static const int REASON_ANIM_MILLI_SECONDS = 150;
  late AnimationController reasonAnim;
  TextEditingController titleController = TextEditingController();
  TextEditingController reasonController = TextEditingController();
  FocusNode reasonFocus = FocusNode();

  int dayNum = 1;
  int currentDay = 1;
  List<GuidePoint> pointList = [];
  List<GuidePoint> currentPointList = [];

  @override
  void initState(){
    super.initState();
    reasonAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: REASON_ANIM_MILLI_SECONDS));
    reasonFocus.addListener(reasonFocusListener);
  }

  @override
  void dispose(){
    titleController.dispose();
    reasonController.dispose();
    reasonAnim.dispose();
    reasonFocus.removeListener(reasonFocusListener);
    reasonFocus.dispose();
    super.dispose();
  }

  void reasonFocusListener(){
    if(reasonFocus.hasFocus){
      reasonAnim.forward();
    }
    else{
      reasonAnim.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: ThemeUtil.backgroundColor,
          child: ListView(
            padding: EdgeInsets.zero,
            physics: const ClampingScrollPhysics(),
            children: [
              InkWell(
                onTap: () async{
                  bool isGranted = await PermissionUtil().requestPermission(context: context, permission: Permission.storage, info: '希望获取存储权限用于选择封面');
                  if(!isGranted){
                    ToastUtil.error('获取存储权限失败');
                    return;
                  }
                  AssetPickerConfig config = ImageUtil.buildDefaultImagePickerConfig();
                  if(mounted && context.mounted){
                    final List<AssetEntity>? results = await AssetPicker.pickAssets(
                      context,
                      pickerConfig: config,
                    );
                    if(results == null || results.isEmpty){
                      return;
                    }
                    AssetEntity entity = results[0];
                    File? file = await entity.file;
                    if(file == null){
                      ToastUtil.error('获取路径失败');
                      return;
                    }
                    CroppedFile? croppedFile = await ImageCropper().cropImage(
                      sourcePath: file.path,
                      aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
                      aspectRatioPresets: [
                        CropAspectRatioPreset.ratio16x9,
                      ],
                      uiSettings: [
                        AndroidUiSettings(
                          toolbarTitle: '攻略封面',
                          toolbarColor: ThemeUtil.buttonColor,
                          toolbarWidgetColor: Colors.white,
                          initAspectRatio: CropAspectRatioPreset.original,
                          lockAspectRatio: true
                        ),
                        IOSUiSettings(
                          title: '攻略封面',
                          aspectRatioLockEnabled: true,
                          aspectRatioPickerButtonHidden: true,
                          resetButtonHidden: true,
                          cancelButtonTitle: '取消',
                          doneButtonTitle: '确定'
                        ),
                      ],
                    );
                    if(croppedFile == null){
                      return;
                    }
                    String path = croppedFile.path;
                    //String name = path.substring(path.lastIndexOf('/') + 1, path.length);
                    String? url = await FileUploadUtil().upload(path: path);
                    if(url == null){
                      ToastUtil.error('文件上传失败');
                      return;
                    }
                    cover = url;
                    if(mounted && context.mounted){
                      setState(() {
                      });
                    }
                  }
                },
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: cover == null ?
                  Stack(
                    children: [
                      Image.asset('assets/trip/trip_title.png', fit: BoxFit.fill, width: double.infinity,),
                      Positioned.fill(
                        child: Container(
                          color: Colors.black26,
                          alignment: Alignment.center,
                          child: const Text('选择封面', style: TextStyle(color: Colors.white),),
                        ),
                      )
                    ],
                  ):
                  Image.network(getFullUrl(cover!), fit: BoxFit.fill, width: double.infinity,)
                ),
              ),
              Container(
                height: 70,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(4))
                ),
                clipBehavior: Clip.hardEdge,
                alignment: Alignment.center,
                child: TextField(
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    hintText: '请输入标题',
                    hintStyle: TextStyle(color: Color.fromRGBO(0xc5, 0xc5, 0xc6, 1)),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                  controller: titleController,
                  cursorColor: Colors.grey,
                ),
              ),
              const SizedBox(height: 10,),
              AnimatedBuilder(
                animation: reasonAnim,
                builder:(context, child) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 60 + reasonAnim.value * 80
                    ),
                    child: Wrap(
                      clipBehavior: Clip.hardEdge,
                      children: [
                        Container(
                          height: 140,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(4))
                          ),
                          padding: const EdgeInsets.all(16),
                          clipBehavior: Clip.hardEdge,
                          child: TextField(
                            textInputAction: TextInputAction.done,
                            decoration: const InputDecoration(
                              hintText: '推荐理由',
                              hintStyle: TextStyle(color: Color.fromRGBO(0xc5, 0xc5, 0xc6, 1)),
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                            ),
                            controller: reasonController,
                            focusNode: reasonFocus,
                            cursorColor: Colors.grey,
                            maxLines: null,
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
              getCurrentPointListWidget(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: (){
                      GuidePoint point = GuidePoint();
                      point.day = currentDay;
                      point.orderNum = currentPointList.isEmpty ? 1 : (currentPointList.last.orderNum ?? 0) + 1;
                      currentPointList.add(point);
                      pointList.add(point);
                      setState(() {
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 8),
                      decoration: const BoxDecoration(
                        color: ThemeUtil.buttonColor,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4
                          )
                        ]
                      ),
                      alignment: Alignment.center,
                      width: 160,
                      height: 48,
                      child: const Icon(Icons.add_rounded, size: 32, color: Colors.white,),
                    ),
                  )
                ],
              ),
              getDaySelectWidget(),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 10),
          width: MediaQuery.of(context).size.width,
          height: CommonHeader.HEADER_HEIGHT,
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4
              )
            ]
          ),
          padding: const EdgeInsets.only(left: 8, right: 8),
          alignment: Alignment.center,
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
              Row(
                children: [
                  /*
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap
                    ),
                    onPressed: (){

                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(12))
                      ),
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                      child: const Text('选择行程', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
                    ),
                  ),
                  const SizedBox(width: 10,),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap
                    ),
                    onPressed: () async{
                      
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(12))
                      ),
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                      child: const Text('保存', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
                    ),
                  ),
                  */
                  const SizedBox(width: 10,),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap
                    ),
                    onPressed: () async{
                      if(cover == null){
                        ToastUtil.warn('请选择封面');
                        return;
                      }
                      if(titleController.text.trim().isEmpty){
                        ToastUtil.warn('请填写标题');
                        return;
                      }
                      if(reasonController.text.trim().isEmpty){
                        ToastUtil.warn('请填写推荐理由');
                        return;
                      }
                      if(pointList.isEmpty){
                        ToastUtil.warn('请添加途径点');
                        return;
                      }

                      for(int i = 1; i <= dayNum; ++i){
                        if(!pointList.any((element){
                          return element.day == i;
                        })){
                          ToastUtil.warn('请为第$i天添加地点');
                          currentDay = i;
                          currentPointList = pointList.where((element) => element.day == currentDay).toList();
                          if(mounted && context.mounted){
                            setState(() {
                            });
                          }
                          return;
                        }
                      }

                      int? errorDay;
                      for(GuidePoint point in pointList){
                        if(point.name == null || point.address == null || point.latitude == null || point.longitude == null){
                          ToastUtil.warn('请选择途径点地址');
                          errorDay = point.day;
                        }
                        else if(point.pics == null || point.pics!.trim().isEmpty){
                          ToastUtil.warn('请为途径点上传图片');
                          errorDay = point.day;
                        }
                        else if(point.description == null || point.description!.trim().isEmpty){
                          ToastUtil.warn('请为途径点填写描述');
                          errorDay = point.day;
                        }
                        if(errorDay != null){
                          break;
                        }
                      }
                      if(errorDay != null){
                        currentDay = errorDay;
                        currentPointList = pointList.where((element) => element.day == currentDay).toList();
                        if(mounted && context.mounted){
                          setState(() {
                          });
                        }
                        return;
                      }

                      Guide guide = Guide();
                      guide.title = titleController.text.trim();
                      guide.reason = reasonController.text.trim();
                      guide.cover = cover;
                      guide.dayNum = dayNum;
                      guide.isDraft = false;
                      
                      bool result = await GuideHttp().create(guide: guide, pointList: pointList, fail: (response){
                        ToastUtil.error(response.data?.message ?? '发布失败');
                      });
                      if(result){
                        ToastUtil.hint('发布成功');
                        Future.delayed(const Duration(seconds: 3), (){
                          if(mounted && context.mounted){
                            Navigator.of(context).pop(true);
                          }
                        });
                      }
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(12))
                      ),
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                      child: const Text('发布', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
                    ),
                  )
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  Widget getCurrentPointListWidget(){
    List<Widget> widgets = [];
    for(int i=0;i<currentPointList.length;i++){
      GuidePoint point = currentPointList[i];
      widgets.add(
        GuidePointFillWidget(
          point, 
          onDelete: (){
            currentPointList.remove(point);
            pointList.remove(point);
            for(GuidePoint other in currentPointList){
              if(other.orderNum != null && point.orderNum != null && other.orderNum! > point.orderNum!){
                other.orderNum = other.orderNum! - 1;
              }
            }
            setState(() {
            });
          },
          // key: UniqueKey(),//iOS18 键盘弹出导致焦点丢失、UI刷新	使用了 UniqueKey() 导致 widget 重建
            key: ValueKey(i)
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
    );
  }

  Widget getDaySelectWidget(){
    List<Widget> widgets = [];
    for(int i = 1; i <= dayNum; ++i){
      widgets.add(
        GestureDetector(
          onTap: (){
            currentDay = i;
            currentPointList = pointList.where((element) => element.day == i).toList();
            setState(() {
            });
          },
          onLongPressStart: (evt){
            if(dayNum <= 1){
              return;
            }
            showGeneralDialog(
              context: context,
              pageBuilder:(context, animation, secondaryAnimation) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: AlertDialog(
                        title: Text('删除DAY $i？'),
                        actions: [
                          InkWell(
                            onTap: (){
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                border: Border.fromBorderSide(BorderSide(color: ThemeUtil.foregroundColor)),
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                color: Colors.white
                              ),
                              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                              child: const Text('取消', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
                            ),
                          ),
                          const SizedBox(width: 14,),
                          InkWell(
                            onTap: (){
                              pointList = pointList.where((element) => element.day != i).toList();
                              for(GuidePoint point in pointList){
                                if(point.day != null && point.day! > i){
                                  point.day = point.day! - 1;
                                }
                              }
                              --dayNum;
                              if(currentDay > dayNum){
                                currentDay = dayNum;
                              }
                              currentPointList = pointList.where((element) => element.day == currentDay).toList();
                              setState(() {
                              });
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(4)),
                                color: ThemeUtil.buttonColor
                              ),
                              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                              child: const Text('确定', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                );
              },
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: i == currentDay ? Colors.lightBlue : Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4
                )
              ]
            ),
            clipBehavior: Clip.hardEdge,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Text('DAY $i', style: TextStyle(color: i == currentDay ? Colors.white : ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
          ),
        )
      );
    }
    widgets.add(
      InkWell(
        onTap: (){
          ++dayNum;
          setState(() {
          });
        },
        child: const Icon(Icons.add_circle_rounded, color: Colors.lightGreen, size: 28,),
      )
    );
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: widgets,
      ),
    );
  }
}

class GuidePointFillWidget extends StatefulWidget{
  final GuidePoint guidePoint;
  final Function()? onDelete;
  const GuidePointFillWidget(this.guidePoint, {this.onDelete, super.key});

  @override
  State<StatefulWidget> createState() {
    return GuidePointFillState();
  }

}

class GuidePointFillState extends State<GuidePointFillWidget>{

  FocusNode nameFocus = FocusNode();
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();

  bool searchResultShow = false;
  String searchKeyword = '';
  List<MapPoiModel> searchResult = [];

  @override
  void dispose(){
    nameFocus.removeListener(nameFocusListener);
    nameFocus.dispose();
    nameController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    GuidePoint point = widget.guidePoint;
    point.type ??= GuidePointType.scenic.getNum();
    nameFocus.addListener(nameFocusListener);
    nameController.text = point.name ?? '';
    descController.text = point.description ?? '';
  }

  void nameFocusListener(){
    if(!nameFocus.hasFocus){
      GuidePoint point = widget.guidePoint;
      if(point.latitude == null || point.longitude == null){
        nameController.text = '';
      }
    }else{
      //光标移到最后
      _nameMoveSelectionLast();
    }
  }

  @override
  Widget build(BuildContext context) {
    GuidePoint point = widget.guidePoint;
    GuidePointType? pointType;
    if(point.type != null){
      pointType = GuidePointTypeExt.getType(point.type!);
    }
    List<String>? initPics;
    if(point.pics != null && point.pics!.isNotEmpty){
      initPics = point.pics!.split(',');
    }
    return GestureDetector(
      onTap: (){
        searchResultShow = false;
        setState(() {
        });
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(8))
        ),
        margin: const EdgeInsets.fromLTRB(0, 8, 0, 8),
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () async{
                        Object? result = await showGeneralDialog(
                          barrierColor: Colors.black12,
                          barrierDismissible: true,
                          barrierLabel: '',
                          context: context, 
                          pageBuilder:(context, animation, secondaryAnimation) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  child: Container(
                                    width: 140,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(Radius.circular(8)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 4
                                        )
                                      ]
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        InkWell(
                                          onTap: (){
                                            Navigator.of(context).pop(GuidePointType.scenic);
                                          },
                                          child: Container(
                                            height: 60,
                                            alignment: Alignment.center,
                                            child: const Text('景点', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 18),),
                                          ),
                                        ),
                                        const Divider(),
                                        InkWell(
                                          onTap: (){
                                            Navigator.of(context).pop(GuidePointType.hotel);
                                          },
                                          child: Container(
                                            height: 60,
                                            alignment: Alignment.center,
                                            child: const Text('酒店', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 18),),
                                          ),
                                        ),
                                        const Divider(),
                                        InkWell(
                                          onTap: (){
                                            Navigator.of(context).pop(GuidePointType.restaurant);
                                          },
                                          child: Container(
                                            height: 60,
                                            alignment: Alignment.center,
                                            child: const Text('美食', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 18),),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            );
                          },
                        );
                        if(result is GuidePointType){
                          widget.guidePoint.type = result.getNum();
                          if(mounted && context.mounted){
                            setState(() {
                            });
                          }
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                            width: 44,
                            height: 36,
                            alignment: Alignment.center,
                            child: pointType == GuidePointType.scenic ?
                            const Text('景点', style: TextStyle(color: ThemeUtil.foregroundColor),) :
                            pointType == GuidePointType.hotel ?
                            const Text('酒店', style: TextStyle(color: ThemeUtil.foregroundColor),) :
                            pointType == GuidePointType.restaurant ?
                            const Text('美食', style: TextStyle(color: ThemeUtil.foregroundColor),) :
                            const Text('请选择', style: TextStyle(color: Colors.grey),)
                          ),
                          const Icon(Icons.keyboard_arrow_down, color: ThemeUtil.foregroundColor, size: 24),
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4
                          )
                        ]
                      ),
                      alignment: Alignment.centerLeft,
                      child: TextField(
                        maxLines: 1,
                        decoration: const InputDecoration(
                          hintText: '请输入名称',
                          hintStyle: TextStyle(color: Colors.grey),
                          isDense: true,
                          contentPadding: EdgeInsets.fromLTRB(8, 2, 8, 2),
                          border: InputBorder.none,
                          counterText: '',
                        ),
                        style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),
                        controller: nameController,
                        focusNode: nameFocus,
                        onChanged: (val) async{
                          searchKeyword = val;
                          GuidePoint point = widget.guidePoint;
                          GuidePointType? pointType;
                          if(point.type != null){
                            pointType = GuidePointTypeExt.getType(point.type!);
                          }
                          if(pointType == null){
                            return;
                          }
                          List<MapPoiModel>? tmpList;
                          switch(pointType){
                            case GuidePointType.scenic:
                              tmpList = await HttpGaode.searchByKeyword(val, type: PoiType.scenic.getNum());
                              break;
                            case GuidePointType.hotel:
                              tmpList = await HttpGaode.searchByKeyword(val, type: PoiType.hotel.getNum());
                              break;
                            case GuidePointType.restaurant:
                              tmpList = await HttpGaode.searchByKeyword(val, type: PoiType.restaurant.getNum());
                              break;
                            default:
                          }
                          if(tmpList != null){
                            searchResult = tmpList;
                            searchResultShow = true;
                            if(mounted && context.mounted){
                              setState(() {
                              });
                            }
                          }
                        },
                      )
                    ),
                    const Expanded(
                      child: SizedBox(),
                    ),
                    InkWell(
                      onTap: widget.onDelete,
                      child: const Icon(Icons.delete_outline_rounded, color: Colors.grey, size: 28),
                    )
                  ],
                ),
                const SizedBox(height: 12,),
                ImageInputWidget(
                  maxLength: 9,
                  onChange: (urlList){
                    widget.guidePoint.pics = urlList.join(',');
                  },
                  initPics: initPics,
                ),
                const SizedBox(height: 12,),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4
                      )
                    ]
                  ),
                  height: 140,
                  child: TextField(
                    maxLines: null,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      hintText: '请输入文字内容',
                      hintStyle: TextStyle(color: Colors.grey),
                      isDense: true,
                      contentPadding: EdgeInsets.fromLTRB(8, 10, 8, 10),
                      border: InputBorder.none,
                      counterText: '',
                    ),
                    controller: descController,
                    onChanged: (val){
                      GuidePoint point = widget.guidePoint;
                      point.description = val;
                    },
                  ),
                )
              ],
            ),
            Positioned(
              top: 36,
              left: 68,
              child: Offstage(
                offstage: !searchResultShow,
                child: Container(
                  constraints: const BoxConstraints(
                    maxHeight: 200,
                  ),
                  width: MediaQuery.of(context).size.width * 0.6,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4
                      )
                    ]
                  ),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    children: getResultWidgets(),
                  ),
                ),
              )
            )
          ],
        ),
      ),
    );
  }

  List<Widget> getResultWidgets(){
    Map<String, HighlightedWord> map = {
      searchKeyword: HighlightedWord(
        textStyle: const TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        )
      ),
    };
    List<Widget> widgets = [];
    if(searchResult.isEmpty){
      widgets.add(
        InkWell(
          onTap: () async{
            Object? result = await Navigator.of(context).push(MaterialPageRoute(builder: (context){
              return const CommonLocatePage();
            }));
            if(result is MapPoiModel){
              GuidePoint point = widget.guidePoint;
              point.name = result.name;
              nameController.text = result.name ?? '';
              _nameMoveSelectionLast();
              point.address = result.address;
              point.latitude = result.lat;
              point.longitude = result.lng;
              searchResultShow = false;
              if(mounted && context.mounted){
                setState(() {
                });
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Row(
              children: const [
                SizedBox(width: 12),
                Icon(Icons.search, color: Colors.lightBlue,),
                SizedBox(width: 12),
                Text('手动搜索', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold))
              ],
            ),
          ),
        )
      );
    }
    for(MapPoiModel poi in searchResult){
      widgets.add(
        InkWell(
          onTap: (){
            GuidePoint point = widget.guidePoint;
            point.name = poi.name;
            nameController.text = poi.name ?? '';
            _nameMoveSelectionLast();
            point.address = poi.address;
            point.latitude = poi.lat;
            point.longitude = poi.lng;
            searchResultShow = false;
            setState(() {
            });
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.black12))
            ),
            child: TextHighlight(text: poi.name ?? '', words: map, textStyle: const TextStyle(fontWeight: FontWeight.bold, color: ThemeUtil.foregroundColor),),
          ),
        )
      );
    }
    return widgets;
  }

  void _nameMoveSelectionLast() {
    nameController.selection = TextSelection.fromPosition(
      TextPosition(offset: nameController.text.length),
    );
  }
}
