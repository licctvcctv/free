import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/http/http_user.dart';
import 'package:freego_flutter/model/user.dart';
import 'package:freego_flutter/model/user_fo.dart';
import 'package:freego_flutter/provider/user_provider.dart';
import 'package:freego_flutter/util/date_time_util.dart';
import 'package:freego_flutter/util/dialog_util.dart';
import 'package:freego_flutter/util/file_upload_util.dart';
import 'package:freego_flutter/util/image_util.dart';
import 'package:freego_flutter/util/local_user.dart';
import 'package:freego_flutter/util/permission_util.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class UserEditPage extends StatelessWidget {
  const UserEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    return const Scaffold(
      extendBodyBehindAppBar: true, 
      body: UserEditWidget()
    );
  }
}

class UserEditWidget extends ConsumerStatefulWidget {
  const UserEditWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return UserEditState();
  }
}

class UserEditState extends ConsumerState {
  Map basicInfo = {
    'name': '',
    'birthday': null,
    'sex': null,
    'description': null,
  };

  FocusNode nameFocusNode = FocusNode();
  FocusNode descriptionFocusNode = FocusNode();

  final itemPadding = const EdgeInsets.fromLTRB(8, 10, 8, 10);
  final itemDecoration = BoxDecoration(
    color: Colors.white, 
    borderRadius: BorderRadius.circular(4)
  );

  final Record record = Record();
  onScreenTap() {
    nameFocusNode.unfocus();
    descriptionFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    var statusHeight = MediaQuery.of(context).viewPadding.top;
    return GestureDetector(
      onTap: onScreenTap,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color.fromRGBO(242, 245, 250, 1),
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: statusHeight + 10,
                ),
                Container(
                  height: 50,
                  color: const Color.fromRGBO(203, 211, 220, 1),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios_outlined,
                            color: Colors.white,
                          )
                        )
                      ),
                      const Center(
                        child: Text(
                          "个人信息",
                          style: TextStyle(fontSize: 18, color: Colors.white)
                        )
                      )
                    ],
                  )
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(12, 20, 12, 10),
                    child: Column(
                      children: [
                        //个人信息设置
                        Expanded(
                          child: Scrollbar(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: () async {
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
                                        CroppedFile? croppedFile = await ImageCropper().cropImage(
                                          sourcePath: file.path,
                                          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
                                          aspectRatioPresets: [
                                            CropAspectRatioPreset.square,
                                          ],
                                          uiSettings: [
                                            AndroidUiSettings(
                                              toolbarTitle: '头像',
                                              toolbarColor: ThemeUtil.buttonColor,
                                              toolbarWidgetColor: Colors.white,
                                              initAspectRatio: CropAspectRatioPreset.original,
                                              lockAspectRatio: true
                                            ),
                                            IOSUiSettings(
                                              title: '头像',
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
                                        // String name = path.substring(path.lastIndexOf('/') + 1, path.length);
                                        String? url = await FileUploadUtil().upload(path: path);
                                        if (url == null) {
                                          ToastUtil.error('上传文件失败');
                                          return;
                                        }
                                        UserModel? localUser = LocalUser.getUser();
                                        if (localUser == null) {
                                          ToastUtil.error('登录状态错误');
                                          return;
                                        }
                                        basicInfo['head'] = url;
                                        if(mounted && context.mounted){
                                          setState(() {
                                          });
                                        }
                                      }
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: 100,
                                      child: Stack(
                                        children: [
                                          Center(
                                            child: basicInfo['head'] == null ? 
                                            const CircleAvatar(
                                              radius: 50,
                                              backgroundColor: Color.fromRGBO(217, 217, 217, 1),
                                            ): 
                                            CircleAvatar(
                                              radius: 50,
                                              backgroundImage: NetworkImage(getFullUrl(basicInfo['head'])),
                                            ),
                                          ),
                                          const Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Icon(
                                              Icons.add,
                                              size: 40,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    child: const Text(
                                      "昵称",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18
                                      ),
                                    )
                                  ),
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                    child: TextField(
                                      textAlign: TextAlign.center,
                                      focusNode: nameFocusNode,
                                      controller: TextEditingController(text: basicInfo['name']),
                                      onChanged: (value) {
                                        basicInfo['name'] = value.trim();
                                      },
                                      decoration: const InputDecoration(
                                        hintText: "请填写昵称",
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color.fromRGBO(153, 153, 153, 0.1)
                                          ),
                                        )
                                      )
                                    )
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    child: const Text(
                                      "性别",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18
                                      ),
                                    )
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            basicInfo['sex'] = 1;
                                            setState(() {});
                                          },
                                          child: Image.asset(
                                            basicInfo['sex'] != 1 ? "images/woman.png" : 'images/woman_on.png',
                                            width: 50,
                                            height: 50,
                                          )
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            basicInfo['sex'] = 0;
                                            setState(() {});
                                          },
                                          child: Image.asset(
                                            basicInfo['sex'] != 0 ? "images/man.png" : 'images/man_on.png',
                                            width: 50,
                                            height: 50,
                                          )
                                        ),
                                      ],
                                    )
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    child: const Text(
                                      "生日",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18
                                      ),
                                    )
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                    alignment: Alignment.center,
                                    child: TextField(
                                      textAlign: TextAlign.center,
                                      readOnly: true,
                                      onTap: () async {
                                        var selectTime = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(1950, 1, 1),
                                          lastDate: DateTime.now(),
                                          locale: const Locale("zh")
                                        );
                                        if (selectTime != null) {
                                          basicInfo['birthday'] = DateTimeUtil.toYMD(selectTime);
                                          setState(() {});
                                        }
                                      },
                                      controller: TextEditingController(text: basicInfo['birthday']),
                                      decoration: const InputDecoration(
                                        hintText: "请选择生日",
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color.fromRGBO(153, 153, 153, 0.2)
                                          ),
                                        )
                                      )
                                    )
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    child: const Text(
                                      "个人介绍",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18
                                      ),
                                    )
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                    child: TextField(
                                      minLines: 3,
                                      maxLines: 3,
                                      focusNode: descriptionFocusNode,
                                      controller: TextEditingController(text: basicInfo['description']),
                                      onChanged: (value) {
                                        basicInfo['description'] = value.trim();
                                      },
                                      decoration: const InputDecoration(
                                        hintText: "简单的介绍下自己，让大家认识你~",
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color.fromRGBO(153, 153, 153, 0.2)
                                          ),
                                        )
                                      )
                                    )
                                  ),
                                ],
                              )
                            ),
                          )
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromRGBO(4, 182, 221, 1),
                              padding: const EdgeInsets.fromLTRB(0, 14, 0, 14)
                            ),
                            onPressed: () {
                              saveUser();
                            },
                            child: const Text('保存', style: TextStyle(color: Colors.white)),
                          )
                        ),
                        const SizedBox(
                          height: 14,
                        )
                      ],
                    )
                  )
                ),
              ],
            )
          ]
        )
      ),
    );
  }

  saveUser() {
    try {
      checkUser();
    } catch (e) {
      ToastUtil.warn(e.toString());
      return;
    }
    DialogUtil.showProgressDlg(context);
    HttpUser.saveBasic(basicInfo, (isSuccess, data, msg, code) {
      DialogUtil.closeProgressDlg();
      if (isSuccess) {
        ref.read(userFoProvider.notifier).update((state) {
          state.name = basicInfo['name'];
          state.sex = basicInfo['sex'];
          state.head = basicInfo['head'];
          state.birthday = basicInfo['birthday'];
          state.description = basicInfo['description'];
          return state;
        });
        UserModel? user = LocalUser.getUser();
        if(user != null){
          user.name = basicInfo['name'];
          user.head = basicInfo['head'];
        }
        ToastUtil.hint("修改成功");
        Timer.periodic(const Duration(seconds: 1), (timer) {
          //callback function
          //1s 回调一次
          timer.cancel(); // 取消定时器
          Navigator.pop(context);
        });
      } else {
        ToastUtil.error(msg ?? '修改失败');
      }
    });
  }

  checkUser() {
    if(StringUtil.isEmpty(basicInfo['name'])) {
      throw '昵称不能为空';
    }
    if(StringUtil.isEmpty(basicInfo['head'])) {
      throw '头像不能为空';
    }
  }

  @override
  void initState() {
    super.initState();
    UserFoModel userFo = ref.read(userFoProvider);
    basicInfo['head'] = userFo.head != null ? userFo.head! : null;
    basicInfo['name'] = userFo.name;
    basicInfo['sex'] = userFo.sex;
    basicInfo['birthday'] = userFo.birthday;
    basicInfo['description'] = userFo.description;
  }
}
