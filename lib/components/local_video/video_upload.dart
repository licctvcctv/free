
import 'dart:io';

import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/hotel_neo/api/hotel_api.dart';
import 'package:freego_flutter/components/hotel_neo/hotel_common.dart';
import 'package:freego_flutter/components/hotel_neo/hotel_home_freego.dart';
import 'package:freego_flutter/components/local_video/local_video_http.dart';
import 'package:freego_flutter/components/local_video/video_choose.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/components/restaurant/restaurant_common.dart';
import 'package:freego_flutter/components/restaurant/restaurant_home.dart';
import 'package:freego_flutter/components/restaurant/restaurant_api.dart';
import 'package:freego_flutter/components/scenic/api/scenic_api.dart';
import 'package:freego_flutter/components/scenic/scenic_common.dart';
import 'package:freego_flutter/components/scenic/scenic_home_freego.dart';
import 'package:freego_flutter/components/view/city_picker.dart';
import 'package:freego_flutter/components/view/common_locate.dart';
import 'package:freego_flutter/components/view/custom_indicator.dart';
import 'package:freego_flutter/components/view/field_requred_tag.dart';
import 'package:freego_flutter/components/view/keep_alive_wrapper.dart';
import 'package:freego_flutter/components/view/notify_empty.dart';
import 'package:freego_flutter/components/view/notify_loading.dart';
import 'package:freego_flutter/components/view/search_bar.dart';
import 'package:freego_flutter/components/view/video_player.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/components/video/video_model.dart';
import 'package:freego_flutter/http/http_restaurant.dart';
import 'package:freego_flutter/model/map_poi.dart';
import 'package:freego_flutter/util/file_upload_util.dart';
import 'package:freego_flutter/util/image_util.dart';
import 'package:freego_flutter/util/permission_util.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class VideoUploadPage extends StatefulWidget{
  final FileSystemEntity? entity;
  final String? cover;
  final bool rechoosable;
  const VideoUploadPage({this.entity, this.cover, this.rechoosable = false, super.key});

  @override
  State<StatefulWidget> createState() {
    return VideoUpdatePageState();
  }

}

class VideoUpdatePageState extends State<VideoUploadPage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
        elevation: 0,
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
      ),
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: VideoUpdateWidget(entity: widget.entity, cover: widget.cover, rechoosable: widget.rechoosable,),
      )
    );
  }

}

class VideoUpdateWidget extends StatefulWidget{
  final FileSystemEntity? entity;
  final String? cover;
  final bool rechoosable;
  const VideoUpdateWidget({required this.entity, this.cover, this.rechoosable = false, super.key});

  @override
  State<StatefulWidget> createState() {
    return VideoUpdateState();
  }

}

class VideoUpdateState extends State<VideoUpdateWidget>{

  static const double COVER_SIZE = 66;
  static const double ACTION_SIZE = 36;

  late FileSystemEntity? entity;
  late String? entityCover;

  TextEditingController descController = TextEditingController();
  List<String> keywordList = [];
  TextEditingController keywordController = TextEditingController();
  FocusNode descFocusNode = FocusNode();

  int? linkProductType;
  int? linkProductId;
  String? linkProductName;

  Widget iconHotel = SvgPicture.asset('svg/icon_hotel.svg', color: ThemeUtil.foregroundColor,);
  Widget iconScenic = SvgPicture.asset('svg/icon_scenic.svg', color: ThemeUtil.foregroundColor,);
  Widget iconRestaurnt = SvgPicture.asset('svg/icon_restaurant.svg', color: ThemeUtil.foregroundColor,);

  List<Hotel> resultHotels = [];
  List<Scenic> resultScenics = [];
  List<SimpleRestaurant> resultRestaurants = [];

  String? city;
  String? address;
  double? latitude;
  double? longitude;

  ShowType showType = ShowType.public;

  TextEditingController nameController = TextEditingController();
  FocusNode nameFocusNode = FocusNode();

  String? cover;

  int videoUploadCount = 0;
  int videoUploadTotal = 1;
  bool showUploadingProgress = false;

  @override
  void initState(){
    super.initState();
    entity = widget.entity;
    entityCover = widget.cover;
  }

  @override
  void dispose(){
    descController.dispose();
    descFocusNode.dispose();
    keywordController.dispose();
    nameController.dispose();
    nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: ThemeUtil.backgroundColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  physics: const ClampingScrollPhysics(),
                  children: [
                    const SizedBox(height: 60,),
                    SizedBox(
                      height: 60,
                      child: Row(
                        children: [
                          InkWell(
                            onTap: (){
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              height: 60,
                              width: 60,
                              decoration: const BoxDecoration(
                                color: Color.fromRGBO(204, 204, 204, 0.5),
                                borderRadius: BorderRadius.horizontal(right: Radius.circular(20))
                              ),
                              alignment: Alignment.centerLeft,
                              child: const Padding(
                                padding: EdgeInsets.only(left: 16),
                                child: Icon(Icons.arrow_back_ios_new, color: ThemeUtil.foregroundColor,),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    getLocalInfoWidget(),
                    getCoverWidget(),
                    getNameWidget(),
                    getDescriptionWidget(),
                    getKeywordsWidget(),
                    getLinkWidget(),
                    getLocationWidget(),
                    getSubmitWidget()
                  ],
                ),
              )
            ],
          ),
        ),
        Offstage(
          offstage: !showUploadingProgress,
          child: Container(
            color: const Color.fromRGBO(255, 242, 245, 0.5),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const NotifyLoadingWidget(
                  color: ThemeUtil.foregroundColor,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(StringUtil.getSizeText(videoUploadCount), style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
                    const Text('/', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
                    Text(StringUtil.getSizeText(videoUploadTotal), style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),)
                  ],
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget getSubmitWidget(){
    return InkWell(
      onTap: () async{
        if(entity == null){
          ToastUtil.warn('请选择视频');
          return;
        }
        if(cover == null){
          ToastUtil.warn('请选择视频封面');
          return;
        }
        if(nameController.text.trim().isEmpty){
          ToastUtil.warn('请填写视频名称');
          FocusScope.of(context).requestFocus(nameFocusNode);
          return;
        }
        if(descController.text.trim().isEmpty){
          ToastUtil.warn('请填写视频描述');
          FocusScope.of(context).requestFocus(descFocusNode);
          return;
        }
        if(keywordList.isEmpty){
          ToastUtil.warn('请至少填写一个标签');
          return;
        }
        String path = entity!.path;
        //String name = path.substring(path.lastIndexOf('/') + 1, path.length);
        showUploadingProgress = true;
        if(mounted && context.mounted){
          setState(() {
          });
        }
        String? url = await FileUploadUtil().upload(path: path, onSend: (count, total){
          videoUploadCount = count;
          videoUploadTotal = total;
          if(mounted && context.mounted){
            setState(() {
            });
          }
        });

        if(url == null){
          ToastUtil.error('上传失败');
          showUploadingProgress = false;
          if(mounted && context.mounted){
            setState(() {
            });
          }
          return;
        }
        VideoModel video = VideoModel();
        video.name = nameController.text.trim();
        video.path = url;
        video.pic = cover;
        video.keywords = keywordList.join(',');
        video.description = descController.text.trim();
        video.linkProductId = linkProductId;
        video.linkProductType = linkProductType;
        video.city = city;
        video.address = address;
        video.lat = latitude;
        video.lng = longitude;
        video.showType = showType.getNum();
        bool result = await LocalVideoHttp().create(video);
        if(result){
          ToastUtil.hint('发布成功');
        }
        else{
          ToastUtil.warn('发布失败');
        }
        showUploadingProgress = false;
        if(mounted && context.mounted){
          setState(() {
          });
        }
        Future.delayed(const Duration(seconds: 3), (){
          if(mounted && context.mounted){
            Navigator.of(context).pop(true);
          }
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 12, bottom: 12),
        margin: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: ThemeUtil.buttonColor,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        alignment: Alignment.center,
        child: const Text('发布', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),),
      ),
    );
  }

  Widget getCoverWidget(){
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4, bottom: 4),
      padding: const EdgeInsets.all(16),
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
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text('视频封面', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
              SizedBox(width: 4),
              FieldRequiredTag()
            ],
          ),
          const SizedBox(height: 10,),
          InkWell(
            onTap: () async{
              bool isGranted = await PermissionUtil().requestPermission(context: context, permission: Permission.storage, info: '希望获取存储权限用于选择封面');
              if(!isGranted){
                ToastUtil.error('获取存储权限失败');
                return;
              }
              if(mounted && context.mounted){

                AssetPickerConfig config = ImageUtil.buildDefaultImagePickerConfig();
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
                      toolbarTitle: '视频封面',
                      toolbarColor: ThemeUtil.buttonColor,
                      toolbarWidgetColor: Colors.white,
                      initAspectRatio: CropAspectRatioPreset.original,
                      lockAspectRatio: true
                    ),
                    IOSUiSettings(
                      title: '视频封面',
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
                String? url = await FileUploadUtil().upload(
                  path: path,
                );
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
              Container(
                decoration: const BoxDecoration(
                  color: ThemeUtil.backgroundColor,
                  borderRadius: BorderRadius.all(Radius.circular(10))
                ),
                alignment: Alignment.center,
                width: double.infinity,
                child: const Text('+', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 40))
              ) :
              Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10))
                ),
                width: double.infinity,
                child: Image.network(getFullUrl(cover!), fit: BoxFit.contain,)
              )
            )
          )
        ],
      )
    );
  }

  Widget getNameWidget(){
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4, bottom: 4),
      padding: const EdgeInsets.all(16),
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
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text('视频名称', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(width: 4),
              FieldRequiredTag(),
            ]
          ),
          const SizedBox(height: 10),
          Container(
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4
                )
              ]
            ),
            child: TextField(
              controller: nameController,
              focusNode: nameFocusNode,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.fromLTRB(8, 10, 8, 10),
                border: InputBorder.none,
                counterText: '',
              ),
              maxLength: 50,
              maxLines: 1,
            )
          ),
        ],
      )
    );
  }

  Widget getLocationWidget(){
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4, bottom: 4),
      padding: const EdgeInsets.all(16),
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
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text('位置', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
              SizedBox(width: 4),
            ]
          ),
          const SizedBox(height: 10,),
          Row(
            children: [
              const Text('经：', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
              latitude == null ?
              const Text('未知', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),) :
              Text(latitude!.toStringAsFixed(6), style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(width: 40,),
              const Text('纬：', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
              longitude == null ?
              const Text('未知', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),) :
              Text(longitude!.toStringAsFixed(6), style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),)
            ]
          ),
          const SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('城市：', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
              Text(city ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),)
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('地址：', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: address == null ? InkWell(
                    onTap: chooseLocationPoi,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(40, 4, 40, 4),
                      decoration: const BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.all(Radius.circular(4))
                      ),
                      child: const Text('+', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),),
                    ) ,
                  ):
                  InkWell(
                    onTap: chooseLocationPoi,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                      decoration: const BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.all(Radius.circular(4))
                      ),
                      child: Text(address!, style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.end, maxLines: 99, softWrap: true,),
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  void chooseLocationPoi() async{
    dynamic result = await Navigator.of(context).push(MaterialPageRoute(builder: (context){
      return CommonLocatePage(
        initLat: latitude,
        initLng: longitude,
      );
    }));
    if(result is MapPoiModel){
      latitude = result.lat;
      longitude = result.lng;
      city = result.city;
      address = result.address;
      setState(() {
      });
    }
  }

  Future showLinkChooseDialog() async{
    Object? result = await showGeneralDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      barrierLabel: '',
      transitionBuilder:(context, animation, secondaryAnimation, child) {
        return Transform.scale(
          scaleY: animation.value,
          alignment: Alignment.center,
          child: child,
        );
      },
      pageBuilder:(context, animation, secondaryAnimation) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Material(
              color: Colors.transparent,
              child: ProductChooseWidget(),
            )
          ],
        );
      },
    );
    if(result is Hotel){
      result = await HotelApi().detail(id: result.id, outerId: result.outerId, source: result.source);
      if(result is Hotel){
        linkProductId = result.id;
        linkProductName = result.name;
        linkProductType = ProductType.hotel.getNum();
        latitude = result.latitude;
        longitude = result.longitude;
        city = result.city;
        address = result.address;
        if(mounted && context.mounted){
          setState(() {
          });
        }
      }
    }
    else if(result is Scenic){
      result = await ScenicApi().detail(id: result.id, outerId: result.outerId, source: result.source);
      if(result is Scenic){
        linkProductId = result.id;
        linkProductName = result.name;
        linkProductType = ProductType.scenic.getNum();
        latitude = result.latitude;
        longitude = result.longitude;
        city = result.city;
        address = result.address;
        if(mounted && context.mounted){
          setState(() {
          });
        }
      }
    }
    else if(result is Restaurant){
      linkProductId = result.id;
      linkProductName = result.name;
      linkProductType = ProductType.restaurant.getNum();
      latitude = result.lat;
      longitude = result.lng;
      city = result.city;
      address = result.address;
      if(mounted && context.mounted){
        setState(() {
        });
      }
    }
  }

  Widget getLinkWidget(){
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4, bottom: 4),
      padding: const EdgeInsets.all(16),
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
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('链接', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
          const SizedBox(height: 10,),
          linkProductId != null && linkProductName != null ?
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: linkProductType == ProductType.hotel.getNum() ?
                iconHotel :
                linkProductType == ProductType.scenic.getNum() ?
                iconScenic :
                linkProductType == ProductType.restaurant.getNum() ?
                iconRestaurnt :
                const SizedBox(),
              ),
              InkWell(
                onTap: showLinkChooseDialog,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  decoration: const BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Text(linkProductName!, style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16))
                ),
              )
            ],
          ) :
          InkWell(
            onTap: showLinkChooseDialog,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.all(Radius.circular(4))
              ),
              padding: const EdgeInsets.fromLTRB(40, 4, 40, 4),
              child: const Text('+', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }

  Widget getKeywordsWidget(){
    List<Widget> keywordWidgets = [];
    for(int i = 0; i < keywordList.length; ++i){
      String keyword = keywordList[i];
      keywordWidgets.add(
        KeywordItemWidget(
          key: UniqueKey(),
          keyword: keyword,
          onDelete: (){
            keywordList.removeAt(i);
            setState(() {
            });
          },
        )
      );
    }
    keywordWidgets.add(
      InkWell(
        onTap: (){
          keywordController.text = '';
          showGeneralDialog(
            context: context, 
            barrierDismissible: true,
            barrierColor: Colors.transparent,
            barrierLabel: '',
            transitionDuration: const Duration(milliseconds: 350),
            transitionBuilder: (context, animation, secondaryAnimation, child) {
              return Transform.scale(
                scaleY: animation.value,
                alignment: Alignment.center,
                child: child,
              );
            },
            pageBuilder: (context, animation, secondaryAnimation) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Material(
                    child: Container(
                      padding: const EdgeInsets.all(20),
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('添加标签', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
                          const SizedBox(height: 10,),
                          Container(
                            height: 40,
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
                              controller: keywordController,
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.fromLTRB(8, 10, 8, 10),
                                border: InputBorder.none,
                                counterText: '',
                              ),
                              textAlign: TextAlign.end,
                              maxLength: 12,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white
                                ),
                                onPressed: (){
                                  Navigator.of(context).pop();
                                }, 
                                child: const Text('取消', style: TextStyle(color: ThemeUtil.foregroundColor),)
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: (){
                                  if(keywordController.text.trim().isEmpty){
                                    ToastUtil.warn('请输入标签');
                                    return;
                                  }
                                  String keyword = keywordController.text.trim();
                                  if(keywordList.contains(keyword)){
                                    ToastUtil.warn('标签已存在');
                                    return;
                                  }
                                  keywordList.add(keyword);
                                  setState(() {
                                  });
                                  ToastUtil.hint('添加成功');
                                  Navigator.of(context).pop();
                                }, 
                                child: const Text('添加', style: TextStyle(color: Colors.white,),)
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                ],
              );
            },
          );
        },
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.all(Radius.circular(4))
          ),
          padding: const EdgeInsets.fromLTRB(40, 4, 40, 4),
          child: const Text('+', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      )
    );
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4, bottom: 4),
      padding: const EdgeInsets.all(16),
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
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text('标签', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
              SizedBox(width: 4,),
              FieldRequiredTag()
            ]
          ),
          const SizedBox(height: 10,),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: keywordWidgets,
          )
        ],
      ),
    );
  }

  Widget getDescriptionWidget(){
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 4),
      padding: const EdgeInsets.all(16),
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
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text('视频描述', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
              SizedBox(width: 4),
              FieldRequiredTag()
            ]
          ),
          const SizedBox(height: 10),
          Container(
            height: 100,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4
                )
              ]
            ),
            child: TextField(
              controller: descController,
              focusNode: descFocusNode,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.fromLTRB(8, 10, 8, 10),
                border: InputBorder.none,
                counterText: '',
              ),
              maxLines: 99,
            )
          ),
        ],
      ),
    );
  }

  Widget getLocalInfoWidget(){
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      padding: const EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width,
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
      clipBehavior: Clip.hardEdge,
      child: 
      entity != null ?
      Row(
        children: [
          const Text('视频：', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
          const SizedBox(width: 10,),
          ClipOval(
            child: SizedBox(
              width: COVER_SIZE,
              height: COVER_SIZE,
              child: entityCover == null ?
              const ColoredBox(color: Colors.black) :
              Image.file(File(entityCover!), fit: BoxFit.cover)
            ),
          ),
          const SizedBox(width: 10,),
          InkWell(
            onTap: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context){
                return VideoPlayerPage(entity!.path, sourceType: VideoSourceType.local,);
              }));
            },
            child: const Icon(Icons.play_arrow_rounded, color: ThemeUtil.foregroundColor, size: ACTION_SIZE,),
          ),
          const Expanded(
            child: SizedBox(),
          ),
          if(widget.rechoosable)
          InkWell(
            onTap: () async{
              dynamic result = await Navigator.of(context).push(MaterialPageRoute(builder: (context){
                return const VideoChoosePage();
              }));
              if(result is Map){
                if(result['entity'] is FileSystemEntity){
                  entity = result['entity'];
                }
                if(result['cover'] is String?){
                  entityCover = result['cover'];
                }
                if(mounted && context.mounted){
                  setState(() {
                  });
                }
              }
            },
            child: const Icon(Icons.arrow_forward_ios, color: ThemeUtil.foregroundColor, size: ACTION_SIZE,),
          )
        ],
      ) :
      Row(
        children: [
          const Text('视频：', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
          const FieldRequiredTag(),
          const SizedBox(width: 10,),
          Expanded(
            child: InkWell(
              onTap: () async{
                dynamic result = await Navigator.of(context).push(MaterialPageRoute(builder: (context){
                  return const VideoChoosePage();
                }));
                if(result is Map){
                  if(result['entity'] is FileSystemEntity){
                    entity = result['entity'];
                  }
                  if(result['cover'] is String?){
                    entityCover = result['cover'];
                  }
                  if(mounted && context.mounted){
                    setState(() {
                    });
                  }
                }
              },
              child: Row(
                children: const [
                  Text('未选择', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16),),
                  Expanded(
                    child: SizedBox(),
                  ),
                  Icon(Icons.arrow_forward_ios, color: ThemeUtil.foregroundColor, size: ACTION_SIZE,),
                ],
              )
            ),
          )
        ],
      )
    );
  }
}

class KeywordItemWidget extends StatefulWidget{
  final String keyword;
  final Function()? onDelete;
  const KeywordItemWidget({required this.keyword, this.onDelete, super.key});

  @override
  State<StatefulWidget> createState() {
    return KeywordItemState();
  }
  
}

class KeywordItemState extends State<KeywordItemWidget> with AutomaticKeepAliveClientMixin{

  bool showRemoveIcon = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        GestureDetector(
          onLongPress: (){
            showRemoveIcon = true;
            setState(() {
            });
          },
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.all(Radius.circular(4))
            ),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Text(widget.keyword, style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
          ),
        ),
        if(showRemoveIcon)
        Positioned(
          right: 0,
          top: 0,
          child: InkWell(
            onTap: widget.onDelete,
            child: ClipOval(
              child: Container(
                width: 16,
                height: 16,
                alignment: Alignment.center,
                child: const Text('X', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 14, ),),
              ),
            ),
          ),
        )
      ],
    );
  }
  
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
  
}

class ProductChooseWidget extends StatefulWidget{
  const ProductChooseWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return ProductChooseState();
  }
  
}

class ProductChooseState extends State<ProductChooseWidget>{

  List<Hotel>? hotelList;
  List<Scenic>? scenicList;
  List<Restaurant>? restaurantList;

  Widget iconHotel = SvgPicture.asset('svg/icon_hotel.svg', color: ThemeUtil.foregroundColor,);
  Widget iconScenic = SvgPicture.asset('svg/icon_scenic.svg', color: ThemeUtil.foregroundColor,);
  Widget iconRestaurnt = SvgPicture.asset('svg/icon_restaurant.svg', color: ThemeUtil.foregroundColor,);

  ProductType? type;
  String keyword = '';
  String keywordHotel = '';
  String keywordScenic = '';
  String keywordRestaurant = '';

  String city = '杭州市';
  final AMapFlutterLocation amapLocation = AMapFlutterLocation();

  int hotelPage = 1;
  int scenicPage = 1;
  int restaurantPage = 1;

  Key hotelKey = UniqueKey();
  Key scenicKey = UniqueKey();
  Key restaurantKey = UniqueKey();

  @override
  void initState(){
    super.initState();
    startLocation();
  }

  Future search(String val) async{
    switch(type){
      case ProductType.hotel:
        keywordHotel = keyword.trim();
        List<Hotel>? tmpList = await HotelApi().search(city: city, keyword: keywordHotel);
        if(tmpList != null){
          hotelList = tmpList;
          hotelPage = 1;
          if(mounted && context.mounted){
            setState(() {
            });
          }
        }
        break;
      case ProductType.scenic:
        keywordScenic = keyword.trim();
        List<Scenic>? tmpList = await ScenicApi().search(city: city, keyword: keywordScenic);
        if(tmpList != null){
          scenicList = tmpList;
          scenicPage = 1;
          if(mounted && context.mounted){
            setState(() {
            });
          }
        }
        break;
      case ProductType.restaurant:
        keywordRestaurant = keyword.trim();
        List<Restaurant>? tmpList = await RestaurantApi().search(city: city, keyword: keywordRestaurant);
        if(tmpList != null){
          restaurantList = tmpList;
          restaurantPage = 1;
          if(mounted && context.mounted){
            setState(() {
            });
          }
        }
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.6,
      margin: const EdgeInsets.only(top: 4, bottom: 4),
      padding: const EdgeInsets.all(16),
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
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('链接', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
          const SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: (){
                  type = ProductType.hotel;
                  if(hotelList == null){
                    search(keyword);
                  }
                  setState(() {
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: type == ProductType.hotel ? ThemeUtil.buttonColor : Colors.black12 ,
                    borderRadius: const BorderRadius.all(Radius.circular(4))
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: iconHotel,
                      ),
                      const SizedBox(width: 8,),
                      Text('酒店', style: TextStyle(color: type == ProductType.hotel ? Colors.white : ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
                    ],
                  )
                ),
              ),
              InkWell(
                onTap: (){
                  type = ProductType.scenic;
                  if(scenicList == null){
                    search(keyword);
                  }
                  setState(() {
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: type == ProductType.scenic ? ThemeUtil.buttonColor : Colors.black12,
                    borderRadius: const BorderRadius.all(Radius.circular(4))
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: iconScenic,
                      ),
                      const SizedBox(width: 8,),
                      Text('景点', style: TextStyle(color: type == ProductType.scenic ? Colors.white : ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
                    ],
                  )
                ),
              ),
              InkWell(
                onTap: (){
                  type = ProductType.restaurant;
                  if(restaurantList == null){
                    search(keyword);
                  }
                  setState(() {
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: type == ProductType.restaurant ? ThemeUtil.buttonColor : Colors.black12,
                    borderRadius: const BorderRadius.all(Radius.circular(4))
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: iconRestaurnt,
                      ),
                      const SizedBox(width: 8,),
                      Text('美食', style: TextStyle(color: type == ProductType.restaurant ? Colors.white : ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
                    ],
                  )
                ),
              )
            ],
          ),
          const SizedBox(height: 10,),
          Row(
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap
                ),
                onPressed: () async{
                  String? cityName = await Navigator.of(context).push(MaterialPageRoute(builder: (context){
                    return const CityPickerPage();
                  }));
                  if(cityName != null && cityName != city){
                    city = cityName;
                    if(mounted && context.mounted){
                      setState(() {
                      });
                    }
                    hotelList = null;
                    scenicList = null;
                    restaurantList = null;
                    search(keyword);
                  }
                },
                child: Container(
                  height: 36,
                  decoration: const BoxDecoration(
                    color: ThemeUtil.dividerColor,
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(10))
                  ),
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                  alignment: Alignment.center,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: city, style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
                        const TextSpan(text: '>', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
                      ]
                    ),
                  )
                ),
              ),
              const SizedBox(width: 20,),
              Expanded(
                child: SearchBar( 
                  onSubmit: (val) async{
                    keyword = val;
                    search(keyword);
                  },
                ),
              )
            ],
          ),
          const SizedBox(height: 20,),
          Expanded(
            child: type == ProductType.hotel ?
            getHotelWidget() :
            type == ProductType.scenic ?
            getScenicWidget() :
            type == ProductType.restaurant ?
            getRestaurantWidget() :
            const SizedBox()
          )
        ],
      ),
    );
  }

  Widget getRestaurantWidget(){
    if(restaurantList == null){
      return const Center(
        child: Text('无', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16),),
      );
    }
    if(restaurantList!.isEmpty){
      return const NotifyEmptyWidget();
    }
    List<Widget> widgets = [];
    for(Restaurant restaurant in restaurantList!){
      widgets.add(
        GestureDetector(
          onTap: (){
            Navigator.of(context).pop(restaurant);
          },
          onLongPressStart: (evt){
            double posX = evt.globalPosition.dx;
            double posY = evt.globalPosition.dy;
            const double BUTTON_WIDTH = 80;
            const double BUTTON_HEIGHT = 36;
            if(posX + BUTTON_WIDTH > MediaQuery.of(context).size.width){
              posX -= BUTTON_WIDTH;
            }
            if(posY + BUTTON_HEIGHT > MediaQuery.of(context).size.height){
              posY -= BUTTON_HEIGHT;
            }
            showGeneralDialog(
              context: context, 
              barrierDismissible: true,
              barrierLabel: '',
              barrierColor: Colors.transparent,
              pageBuilder:(context, animation, secondaryAnimation) {
                return Stack(
                  children: [
                    Positioned(
                      left: posX,
                      top: posY,
                      child: TextButton(
                        onPressed: () async{
                          if(restaurant.id == null){
                            return;
                          }
                          Restaurant? target = await HttpRestaurant.getById(restaurant.id!);
                          if(target == null){
                            ToastUtil.error('目标已失效');
                            return;
                          }
                          if(mounted && context.mounted){
                            Navigator.of(context).push(MaterialPageRoute(builder: (context){
                              return RestaurantHomePage(target);
                            }));
                          }
                        }, 
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4
                              )
                            ]
                          ),
                          width: BUTTON_WIDTH,
                          height: BUTTON_HEIGHT,
                          alignment: Alignment.center,
                          child: const Text('详情', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),)
                        )
                      ),
                    )
                  ],
                );
              },
            );
          },
          child: Container(
            height: 60,
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black26)),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded, size: 32, color: ThemeUtil.foregroundColor),
                Expanded(
                  child: Text(restaurant.name ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.end,)
                )
              ],
            ),
          )
        )
      );
    }
    return KeepAliveWrapperWidget(
      content: CustomIndicatorWidget(
        key: restaurantKey,
        content: Column(
          children: widgets,
        ),
        touchBottom: () async{
          List<Restaurant>? tmpList = await RestaurantApi().search(city: city, keyword: keywordRestaurant, pageNum: restaurantPage + 1);
          if(tmpList == null){
            ToastUtil.error('好像出了点小问题');
            return;
          }
          if(tmpList.isEmpty){
            ToastUtil.hint('已经没有了呢~');
            return;
          }
          ++restaurantPage;
          restaurantList ??= [];
          restaurantList!.addAll(tmpList);
          if(mounted && context.mounted){
            setState(() {
            });
          }
        },
      ),
    );
  }

  Widget getScenicWidget(){
    if(scenicList == null){
      return const Center(
        child: Text('无', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16),),
      );
    }
    if(scenicList!.isEmpty){
      return const NotifyEmptyWidget();
    }
    List<Widget> widgets = [];
    for(Scenic scenic in scenicList!){
      widgets.add(
        GestureDetector(
          onTap: (){
            Navigator.of(context).pop(scenic);
          },
          onLongPressStart: (evt){
            double posX = evt.globalPosition.dx;
            double posY = evt.globalPosition.dy;
            const double BUTTON_WIDTH = 80;
            const double BUTTON_HEIGHT = 36;
            if(posX + BUTTON_WIDTH > MediaQuery.of(context).size.width){
              posX -= BUTTON_WIDTH;
            }
            if(posY + BUTTON_HEIGHT > MediaQuery.of(context).size.height){
              posY -= BUTTON_HEIGHT;
            }
            showGeneralDialog(
              context: context, 
              barrierDismissible: true,
              barrierLabel: '',
              barrierColor: Colors.transparent,
              pageBuilder:(context, animation, secondaryAnimation) {
                return Stack(
                  children: [
                    Positioned(
                      left: posX,
                      top: posY,
                      child: TextButton(
                        onPressed: () async{
                          if(scenic.id == null){
                            return;
                          }
                          Scenic? target = await ScenicApi().detail(id: scenic.id, outerId: scenic.outerId, source: scenic.source);
                          if(target == null){
                            ToastUtil.error('目标已失效');
                            return;
                          }
                          if(mounted && context.mounted){
                            Navigator.of(context).push(MaterialPageRoute(builder: (context){
                              return ScenicHomePage(target);
                            }));
                          }
                        }, 
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4
                              )
                            ]
                          ),
                          width: BUTTON_WIDTH,
                          height: BUTTON_HEIGHT,
                          alignment: Alignment.center,
                          child: const Text('详情', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),)
                        )
                      ),
                    )
                  ],
                );
              },
            );
          },
          child: Container(
            height: 60,
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black26)),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded, size: 32, color: ThemeUtil.foregroundColor),
                Expanded(
                  child: Text(scenic.name ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.end,)
                )
              ],
            ),
          )
        )
      );
    }
    return KeepAliveWrapperWidget(
      content: CustomIndicatorWidget(
        key: scenicKey,
        content: Column(
          children: widgets,
        ),
        touchBottom: () async{
          List<Scenic>? tmpList = await ScenicApi().search(city: city, keyword: keywordScenic, pageNum: scenicPage + 1);
          if(tmpList == null){
            ToastUtil.error('好像出了点小问题');
            return;
          }
          if(tmpList.isEmpty){
            ToastUtil.hint('已经没有了呢~');
            return;
          }
          ++scenicPage;
          scenicList ??= [];
          scenicList!.addAll(tmpList);
          if(mounted && context.mounted){
            setState(() {
            });
          }
        },
      ),
    );
  }

  Widget getHotelWidget(){
    if(hotelList == null){
      return const Center(
        child: Text('无', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16),),
      );
    }
    if(hotelList!.isEmpty){
      return const NotifyEmptyWidget();
    }
    List<Widget> widgets = [];
    for(Hotel hotel in hotelList!){
      widgets.add(
        GestureDetector(
          onTap: (){
            Navigator.of(context).pop(hotel);
          },
          onLongPressStart: (evt){
            double posX = evt.globalPosition.dx;
            double posY = evt.globalPosition.dy;
            const double BUTTON_WIDTH = 80;
            const double BUTTON_HEIGHT = 36;
            if(posX + BUTTON_WIDTH > MediaQuery.of(context).size.width){
              posX -= BUTTON_WIDTH;
            }
            if(posY + BUTTON_HEIGHT > MediaQuery.of(context).size.height){
              posY -= BUTTON_HEIGHT;
            }
            showGeneralDialog(
              context: context, 
              barrierDismissible: true,
              barrierLabel: '',
              barrierColor: Colors.transparent,
              pageBuilder:(context, animation, secondaryAnimation) {
                return Stack(
                  children: [
                    Positioned(
                      left: posX,
                      top: posY,
                      child: TextButton(
                        onPressed: () async{
                          if(hotel.id == null){
                            return;
                          }
                          Hotel? target = await HotelApi().detail(id: hotel.id, outerId: hotel.outerId, source: hotel.source);
                          if(target == null){
                            ToastUtil.error('目标已失效');
                            return;
                          }
                          if(mounted && context.mounted){
                            Navigator.of(context).push(MaterialPageRoute(builder: (context){
                              return HotelHomePage(target);
                            }));
                          }
                        }, 
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4
                              )
                            ]
                          ),
                          width: BUTTON_WIDTH,
                          height: BUTTON_HEIGHT,
                          alignment: Alignment.center,
                          child: const Text('详情', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),)
                        )
                      ),
                    )
                  ],
                );
              },
            );
          },
          child: Container(
            height: 60,
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black26)),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded, size: 32, color: ThemeUtil.foregroundColor),
                Expanded(
                  child: Text(hotel.name ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.end,)
                )
              ],
            ),
          )
        )
      );
    }
    return KeepAliveWrapperWidget(
      content: CustomIndicatorWidget(
        key: hotelKey,
        content: Column(
          children: widgets,
        ),
        touchBottom: () async{
          List<Hotel>? tmpList = await HotelApi().search(city: city, keyword: keywordHotel, pageNum: hotelPage + 1);
          if(tmpList == null){
            ToastUtil.error('好像出了点小问题');
            return;
          }
          if(tmpList.isEmpty){
            ToastUtil.hint('已经没有了呢~');
            return;
          }
          ++hotelPage;
          hotelList ??= [];
          hotelList!.addAll(tmpList);
          if(mounted && context.mounted){
            setState(() {
            });
          }
        },
      ),
    );
  }

  Future startLocation() async{
    bool isGranted = await PermissionUtil().requestPermission(context: context, permission: Permission.location, info: '希望获取当前位置用于获取视频拍摄所在位置');
    if(!isGranted){
      return;
    }
    amapLocation.onLocationChanged().listen((event) {
      if(event['city'] is String){
        city = event['city'].toString();
        //city = city.substring(0, city.length - 1);
        if(mounted && context.mounted){
          setState(() {
          });
        }
        amapLocation.stopLocation();
      }
    });
    amapLocation.startLocation();
  }
  
}
