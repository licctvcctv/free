import 'dart:async';
import 'dart:io';

import 'package:city_pickers/city_pickers.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freego_flutter/components/view/common_locate.dart';
import 'package:freego_flutter/components/view/image_viewer.dart';
import 'package:freego_flutter/components/web_views/merchant_terms.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/http/http_file.dart';

import 'package:freego_flutter/http/http_user.dart';
import 'package:freego_flutter/model/map_poi.dart';
import 'package:freego_flutter/provider/user_provider.dart';

import 'package:freego_flutter/util/dialog_util.dart';
import 'package:freego_flutter/util/image_util.dart';
import 'package:freego_flutter/util/permission_util.dart';
import 'package:freego_flutter/util/regular_util.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class MerchantIdentifyPage extends StatelessWidget{
  const MerchantIdentifyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 10,
        backgroundColor: ThemeUtil.backgroundColor,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      extendBodyBehindAppBar: true,
      body: const MerchantIdentifyWidget()
    );
  }
}

class MerchantIdentifyWidget extends ConsumerStatefulWidget {
  const MerchantIdentifyWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return MerchantIdentifyState();
  }
}

class MerchantIdentifyState extends ConsumerState{
  int step = 0;
  int businessType = 1;
  int licType = 0;
  String? shopName;
  String? shopsignPic;
  String? frontPic;
  String? address;
  double? addressLng;
  double? addressLat;
  String? fixedPhone;
  int isLicAddrSame = 1;
  int isIdentityLegal = 1;
  String?  licPic;
  String?  licAddrDes;
  String?  identityFrontPic;
  String?  identityBackPic;
  String?  identityHandPic;
  String? grantPic;
  int? payPeriod = 0;
  int? payAccountType = 0;
  String? payAccountName;
  String? payAccountProvince;
  String? payAccountCity;
  String? payAccountDist;
  String? payAccountBank;
  String? payAccountBankSub;
  String? payAccountNum;
  String? payAccountBankCode;
  String? contactName;
  String? contactPhone;
  String? contactEmail;

  bool isAgree = false;
  Color tabColorOn = const Color.fromRGBO(4, 182, 221, 1);
  Color tabColorOff = Colors.white;

  bool isFirstPageChecked = false;
  bool isSecondPageChecked = false;
  bool isThirdPageChecked = false;
  bool isForthPageChecked = false;

  final Color submitBtnColorOn = const Color.fromRGBO(4, 182, 221, 1);
  final Color submitBtnColorOff = const Color.fromRGBO(0,0,0, 0.1);

  final inputDecoration = const InputDecoration(
    isDense: true,
    contentPadding: EdgeInsets.fromLTRB(4, 10, 0, 10),
    filled: true,
    fillColor: Colors.white,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(4.0)),
      borderSide:  BorderSide(color:Color.fromRGBO(0, 0, 0, 0.1), width: 1)
    ),
    focusedBorder:  OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(4.0)),
      borderSide:  BorderSide(color:Color.fromRGBO(0, 0, 0, 0.1), width: 1)
    )
  );

  onScreenTap() {
    //nameFocusNode.unfocus();
    //identityFocusNode.unfocus();
    unFocusAll();
  }

  unFocusAll() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  Future showOrChooseImage(String? url, Function(String) onChoose) async{
    if(url != null){
      Navigator.of(context).push(MaterialPageRoute(builder: (context){
        return ImageViewer(getFullUrl(url));
      }));
      return;
    }
    return chooseImage(onChoose);
  }

  Future chooseImage(Function(String) onChoose) async{
    bool isGranted = await PermissionUtil().requestPermission(context: context, permission: Permission.storage, info: '希望获取存储权限用于从相册中选择图片');
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
      if(results != null && results.isNotEmpty) {
        AssetEntity entity = results[0];
        File? file = await entity.file;
        String path = file!.path;
        String name = path.substring(path.lastIndexOf('/') + 1, path.length);
        String? url = await HttpFile.uploadFile(path, name);
        if (url != null) {
          onChoose.call(url);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var statusHeight = MediaQuery.of(context).viewPadding.top + 20;
    return GestureDetector(
      onTap: onScreenTap,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color.fromRGBO(242, 245, 250, 1),
        child: Stack(
          children:[
            Column(
              children: [
                SizedBox(height: statusHeight + 30,),
                Container(
                  height: 50,
                  color: const Color.fromRGBO(203, 211, 220, 1),
                  child: Stack(
                    children: [
                      Positioned(
                        left:0,
                        child: IconButton(
                          onPressed: (){
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_back_ios_outlined, color: Colors.white,)
                        )
                      ),
                      const Center(
                        child: Text("商家审核", style:TextStyle(fontSize: 18,color: Colors.white))
                      )
                    ],
                  )
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0,20),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: (){
                            setStep(0);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color:step >= 0 ? tabColorOn: tabColorOff,
                              borderRadius: const BorderRadius.horizontal(left:Radius.circular(6))
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Text('商家类型', style: TextStyle(color: step >= 0 ? Colors.white: Colors.black),)
                          ),
                        )
                      ),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: (){
                            setStep(1);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: step >= 1 ? tabColorOn : tabColorOff,
                            ),
                            child: Text('认证信息',style: TextStyle(color:step>=1?Colors.white: Colors.black))
                          ),
                        )
                      ),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: (){
                            setStep(2);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color:step >= 2 ? tabColorOn : tabColorOff,
                            ),
                            child: Text('结算信息',style: TextStyle(color: step >= 2 ?Colors.white: Colors.black))
                          ),
                        )
                      ),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: (){
                            setStep(3);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color:step >= 3 ? tabColorOn : tabColorOff,
                              borderRadius: const BorderRadius.horizontal(right:Radius.circular(6))
                            ),
                            child: Text('合同信息',style: TextStyle(color:step>=3?Colors.white: Colors.black))
                          ),
                        )
                      )
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: IndexedStack(
                    index: step,
                    children: [
                      getFirstPage(),
                      getSecondPage(),
                      getThirdPage(),
                      getForthPage()
                    ]
                  )
                ),
              ],
            )
          ]
        )
      ),
    );
  }

  setStep(int step) {
    this.step = step;
    setState(() {
    });
  }

  save() {
    onScreenTap();
    try{
      checkFirstPage(true);
      checkSecondPage(true);
      checkThirdPage(true);
      checkForthPage();
    }
    catch(e) {
      ToastUtil.error(e.toString());
      return;
    }
    var info = {
      'businessType': businessType,
      'licType': licType,
      'shopName': shopName,
      'shopsignPic': shopsignPic,
      'frontPic': frontPic,
      'address': address,
      'addressLng': addressLng,
      'addressLat': addressLat,
      'fixedPhone': fixedPhone,
      'isLicAddrSame': isLicAddrSame,
      'isIdentityLegal': isIdentityLegal,
      'licPic': licPic,
      'licAddrDes': licAddrDes,
      'identityFrontPic': identityFrontPic,
      'identityBackPic': identityBackPic,
      'identityHandPic': identityHandPic,
      'grantPic': grantPic,
      'payPeriod': payPeriod,
      'payAccountType': payAccountType,
      'payAccountName': payAccountName,
      'payAccountProvince': payAccountProvince,
      'payAccountCity': payAccountCity,
      'payAccountDist': payAccountDist,
      'payAccountBank': payAccountBank,
      'payAccountBankSub': payAccountBankSub,
      'payAccountNum': payAccountNum,
      'payAccountBankCode': payAccountBankCode,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'contactEmail': contactEmail,
    };
    DialogUtil.showProgressDlg(context);
    HttpUser.saveMerchantVerify(info, (isSuccess, data, msg, code) {
      DialogUtil.closeProgressDlg();
      if(isSuccess) {
        ref.read(userFoProvider.notifier).update((state){
          state.merchantVerifyStatus = 1;
          return state;
        });
        ToastUtil.hint("申请成功");
        Timer.periodic(const Duration(seconds: 1), (timer) { //callback function
          //1s 回调一次
          timer.cancel();  // 取消定时器
          Navigator.pop(context);
        });
      }
      else {
        ToastUtil.error(msg ?? '申请失败');
      }
    });
  }

  checkForthPage() {
    isForthPageChecked = false;
    if(StringUtil.isEmpty(contactName)) {
      throw "联系人不能为空";
    }
    if(StringUtil.isEmpty(contactPhone)) {
      throw "联系人电话不能为空";
    }
    if(contactPhone != null && !RegularUtil.checkPhone(contactPhone!)){
      throw '联系人电话格式错误';
    }
    if(StringUtil.isEmpty(contactEmail)) {
      throw "联系人邮箱不能为空";
    }
    if(contactEmail != null && !RegularUtil.checkEmail(contactEmail!)){
      throw '邮箱格式不正确';
    }
    if(!isAgree) {
      throw "请先同意用户协议";
    }
    isForthPageChecked = true;
  }

  @override
  void initState() {
    super.initState();
  }

  Widget getTypeRadio(int value, String name) {
    return GestureDetector(
      onTap: (){
        businessType = value;
        setState(() {
        });
      },
      child: Row(
        children: [
          businessType == value ? 
          const Icon(Icons.radio_button_checked,size: 16,) : 
          const Icon(Icons.radio_button_off,size: 16,color: Colors.black26,),
          const SizedBox(width: 4,),
          Text(name,style: const TextStyle(color:Colors.black),)
        ],
      )
    );
  }

  Widget getLicTypeRadio(int value, String name) {
    return GestureDetector(
      onTap: (){
        licType=value;
        setState(() {
        });
      },
      child: Row(
        children: [
          licType == value ? 
          const Icon(Icons.radio_button_checked,size: 16,) : 
          const Icon(Icons.radio_button_off,size: 16,color: Colors.black26,),
          const SizedBox(width: 4,),
          Text(name, style: const TextStyle(color:Colors.black),)
        ],
      )
    );
  }

  getFirstPage() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("选择类型",style: TextStyle(fontWeight: FontWeight.bold),),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            getTypeRadio(1, '酒店'),
                            const SizedBox(width: 30,),
                            getTypeRadio(2, '美食'),
                            const SizedBox(width: 30,),
                            getTypeRadio(3, '景点'),
                          ],
                        ),
                        const SizedBox(height: 10,),
                        Row(
                          children: [
                            getTypeRadio(4, '旅行社'),
                            const SizedBox(width: 16,),
                            getTypeRadio(5, '其他'),
                          ],
                        ),
                      ],
                    ),
                  )
                )
              ],
            )
          ),
          const SizedBox(height: 10,),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text("店铺名称:",style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8,),
                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.center,
                        child: TextField(
                          decoration: inputDecoration,
                          onChanged: (value){
                            shopName = value.trim();
                            checkFirstPageSumit();
                          },
                        )
                      )
                    )
                  ],
                ),
                const SizedBox(height: 10,),
                const SizedBox(
                  width: double.infinity,
                  child: Text("店招/前台照片:",style:TextStyle(fontWeight: FontWeight.bold))
                ),
                const SizedBox(height: 10,),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Row(
                    children: [
                      Column(
                        children:[
                          GestureDetector(
                            onTap: () {
                              showOrChooseImage(shopsignPic, (url){
                                shopsignPic = url;
                                resetState();
                                checkFirstPageSumit();
                              });
                            },
                            onLongPress: () {
                              chooseImage((url){
                                shopsignPic = url;
                                resetState();
                                checkFirstPageSumit();
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                border: Border.all(color:Colors.black.withOpacity(0.1)),
                                borderRadius: BorderRadius.circular(4)
                              ),
                              child: shopsignPic != null ?
                              Image.network(getFullUrl(shopsignPic!), fit: BoxFit.fitWidth,) :
                              const Icon(Icons.add, size: 30, color: Colors.black54,),
                            )
                          ),
                          const SizedBox(height: 8,),
                          const Text('招牌照片', style: TextStyle(fontSize:12),)
                        ]
                      ),
                      const SizedBox(width: 20,),
                      Column(
                        children:[
                          GestureDetector(
                            onTap: () async {
                              showOrChooseImage(frontPic, (url){
                                frontPic = url;
                                resetState();
                                checkFirstPageSumit();
                              });
                            },
                            onLongPress: () async{
                              chooseImage((url){
                                frontPic = url;
                                resetState();
                                checkFirstPageSumit();
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                border: Border.all(color:Colors.black.withOpacity(0.1)),
                                borderRadius: BorderRadius.circular(4)
                              ),
                              child: frontPic != null ? 
                              Image.network(getFullUrl(frontPic!), fit: BoxFit.fitWidth,) :
                              const Icon(Icons.add,size: 30,color:Colors.black54,),
                            )
                          ),
                          const SizedBox(height: 8,),
                          const Text('前台照片',style: TextStyle(fontSize:12),)
                        ]
                      )
                    ],
                  )
                ),
              ],
            ),
          ),
          const SizedBox(height: 10,),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text("店铺地址:",style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8,),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () async{
                          unFocusAll();
                          dynamic result = await Navigator.of(context).push(MaterialPageRoute(builder: (context){
                            return const CommonLocatePage();
                          }));
                          if(result is MapPoiModel){
                            address = result.name;
                            addressLat = result.lat;
                            addressLng = result.lng;
                            setState(() {
                            });
                            checkFirstPageSumit();
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color:Colors.black.withOpacity(0.1),),
                            borderRadius: BorderRadius.circular(4)
                          ),
                          child: Text(address!=null?address!:'请选择地址')
                        )
                      )
                    ),
                    const SizedBox(width: 40,)
                  ]
                ),
                const SizedBox(height: 10,),
                Row(
                  children: [
                    const Text("联系方式:",style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8,),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        child: Container(
                          alignment: Alignment.center,
                          child: TextField(
                            decoration: getNormalInputDecoration("固话/手机"),
                            onChanged: (value){
                              fixedPhone = value;
                              checkFirstPageSumit();
                            },
                          )
                        )
                      )
                    ),
                    const SizedBox(width: 40,)
                  ]
                )
              ]
            )
          ),
          const SizedBox(height: 20,),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: ElevatedButton(
              onPressed: (){
                try{
                  isFirstPageChecked = checkFirstPage(true);
                }
                catch(e){
                  ToastUtil.warn(e.toString());
                }
                if(isFirstPageChecked) {
                  setStep(1);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isFirstPageChecked ? submitBtnColorOn : submitBtnColorOff,
                padding: const EdgeInsets.fromLTRB(0, 14, 0, 14)
              ),
              child: const Text('下一步',style:TextStyle(color:Colors.white)),
            )
          ),
          const SizedBox(height: 20,)
        ],
      )
    );
  }

  getSecondPage() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children:[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("资质证件",style: TextStyle(fontWeight: FontWeight.bold),),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                getLicTypeRadio(0, '营业执照'),
                                const SizedBox(width: 30,),
                                getLicTypeRadio(1, '其他'),
                              ],
                            ),
                          ]
                        )
                      )
                    )
                  ]
                ),
                const SizedBox(height: 20,),
                Container(
                  alignment: Alignment.centerLeft,
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () {
                      showOrChooseImage(licPic, (url){
                        licPic = url;
                        resetState();
                        checkSecondPageSumit();
                      });
                    },
                    onLongPress: () {
                      chooseImage((url){
                        licPic = url;
                        resetState();
                        checkSecondPageSumit();
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border.all(color:Colors.black.withOpacity(0.1)),
                        borderRadius:BorderRadius.circular(4)
                      ),
                      child: licPic != null ? 
                      Image.network(getFullUrl(licPic!), fit: BoxFit.fitWidth,): 
                      const Icon(Icons.add,size: 30,color:Colors.black54),
                    )
                  )
                ),
                const SizedBox(height: 10,),
                Container(
                  alignment: Alignment.centerLeft,
                  child: const Text('营业执照和实际地址是否一致?', style: TextStyle(fontWeight: FontWeight.bold),),
                ),
                const SizedBox(height: 10,),
                Column(
                  children: [
                    Row(
                      children: [
                        getIsLicAddressSameRadio(1, '是'),
                        const SizedBox(width: 30,),
                        getIsLicAddressSameRadio(0, '否'),
                      ],
                    ),
                  ]
                ),
                const SizedBox(height: 10,),
                isLicAddrSame == 0 ? 
                TextField(
                  decoration: getNormalInputDecoration('请说明具体原因'),
                  minLines: 3,
                  maxLines: 3,
                  onChanged: (value){
                    licAddrDes = value;
                    checkSecondPageSumit();
                  },
                ) :
                const SizedBox()
              ]
            )
          ),
          const SizedBox(height: 10,),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: const Text('上传身份证照片',style: TextStyle(fontWeight: FontWeight.bold),),
                ),
                const SizedBox(height: 10,),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showOrChooseImage(identityFrontPic, (url){
                            identityFrontPic = url;
                            resetState();
                            checkSecondPageSumit();
                          });
                        },
                        onLongPress: () {
                          chooseImage((url){
                            identityFrontPic = url;
                            resetState();
                            checkSecondPageSumit();
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            border: Border.all(color:Colors.black.withOpacity(0.1)),
                            borderRadius:BorderRadius.circular(4)
                          ),
                          child: identityFrontPic != null ?
                          Image.network(getFullUrl(identityFrontPic!), fit: BoxFit.fitWidth,) :
                          const Text('前',style: TextStyle(color:Colors.black54),)
                        )
                      ),
                      const SizedBox(width: 14,),
                      GestureDetector(
                        onTap: () {
                          showOrChooseImage(identityBackPic, (url){
                            identityBackPic = url;
                            resetState();
                            checkSecondPageSumit();
                          });
                        },
                        onLongPress: () {
                          chooseImage((url){
                            identityBackPic = url;
                            resetState();
                            checkSecondPageSumit();
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            border: Border.all(color:Colors.black.withOpacity(0.1)),
                            borderRadius:BorderRadius.circular(4)
                          ),
                          child: identityBackPic != null ?
                          Image.network(getFullUrl(identityBackPic!), fit: BoxFit.fitWidth,) :
                          const Text('后',style: TextStyle(color:Colors.black54),),
                        )
                      ),
                      const SizedBox(width: 14,),
                      GestureDetector(
                        onTap: () {
                          showOrChooseImage(identityHandPic, (url){
                            identityHandPic = url;
                            resetState();
                            checkSecondPageSumit();
                          });
                        },
                        onLongPress: () {
                          chooseImage((url){
                            identityHandPic = url;
                            resetState();
                            checkSecondPageSumit();
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            border: Border.all(color:Colors.black.withOpacity(0.1)),
                            borderRadius:BorderRadius.circular(4)
                          ),
                          child: identityHandPic != null ?
                          Image.network(getFullUrl(identityHandPic!), fit: BoxFit.fitWidth,) :
                          const Text('手持',style: TextStyle(color:Colors.black54),),
                        )
                      ),
                    ],
                  )
                ),
                const SizedBox(height: 10,),
                Container(
                  alignment: Alignment.centerLeft,
                  child: const Text('以上证件照片是否为营业执照法人？',style: TextStyle(fontWeight: FontWeight.bold),),
                ),
                const SizedBox(height:10),
                Column(
                  children: [
                    Row(
                      children: [
                        getIsIdentityLegalRadio(1, '是'),
                        const SizedBox(width: 30,),
                        getIsIdentityLegalRadio(0, '否'),
                        const Text('（可上传工作证明或加盖公章授权委托书）',style: TextStyle(fontSize: 10,color: Colors.black54))
                      ],
                    ),
                  ]
                ),
                const SizedBox(height: 10,),
                isIdentityLegal == 0 ? 
                Container(
                  alignment: Alignment.centerLeft,
                  width: double.infinity,
                  child: GestureDetector(
                    onTap:() {
                      unFocusAll();
                      showOrChooseImage(grantPic, (url){
                        grantPic = url;
                        resetState();
                        checkSecondPageSumit();
                      });
                    },
                    onLongPress: () {
                      unFocusAll();
                      chooseImage((url){
                        grantPic = url;
                        resetState();
                        checkSecondPageSumit();
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border.all(color:Colors.black.withOpacity(0.1)),
                        borderRadius:BorderRadius.circular(4)
                      ),
                      child: grantPic != null ?
                      Image.network(getFullUrl(grantPic!), fit: BoxFit.fitWidth,) :
                      Stack(
                        children: [
                          const Center(child:Icon(Icons.add,size: 30,color: Colors.black54,)),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(0,0,0,4),
                              child: const Text('添加授权证明',style: TextStyle(fontSize: 11,color: Colors.black54)),
                            )
                          )
                        ]
                      ),
                    )
                  )
                ): const SizedBox(),
                const SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children:[
                    ElevatedButton(
                      onPressed: (){
                        setStep(0);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(4, 182, 221, 1),
                        padding: const EdgeInsets.fromLTRB(40 ,10, 40, 10)
                      ),
                      child: const Text('上一步',style:TextStyle(color:Colors.white)),
                    ),
                    ElevatedButton(
                      onPressed: (){
                        try{
                          isSecondPageChecked = checkSecondPage(true);
                        }
                        catch(e){
                          ToastUtil.warn(e.toString());
                        }
                        if(isSecondPageChecked){
                          setStep(2);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:isSecondPageChecked?submitBtnColorOn:submitBtnColorOff,
                        padding: const EdgeInsets.fromLTRB(40, 10, 40, 10)
                      ),
                      child: const Text('下一步',style:TextStyle(color:Colors.white)),    
                    )
                  ]
                )
              ],
            )
          )
        ]
      )
    );
  }

  getThirdPage() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Container(
        color: Colors.white,
        width: double.infinity,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(14, 20, 14, 12),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("结算周期",style: TextStyle(fontWeight: FontWeight.bold),),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  getPayPeriodRadio(0, '周结'),
                                  const SizedBox(width: 30,),
                                  getPayPeriodRadio(1, '月结'),
                                ],
                              ),
                            ]
                          )
                        )
                      )
                    ]
                  ),
                  const SizedBox(height: 30,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("账户类型",style: TextStyle(fontWeight: FontWeight.bold),),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  getPayAccountTypeRadio(0, '个人'),
                                  const SizedBox(width: 30,),
                                  getPayAccountTypeRadio(1, '公司'),
                                ],
                              ),
                            ]
                          )
                        )
                      )
                    ]
                  ),
                  const SizedBox(height: 40,),
                  Row(
                    children: [
                      const Text("账户名称:",style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8,),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 0, 50, 0),
                          child: TextField(
                            decoration: inputDecoration,
                            onChanged: (value){
                              payAccountName = value.trim();
                              checkThirdPageSubmit();
                            },
                          )
                        )
                      )
                    ],
                  ),
                  const SizedBox(height: 20,),
                  Row(
                    children: [
                      const Text("银行卡号:",style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8,),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 0, 50, 0),
                          child: TextField(
                            decoration: inputDecoration,
                            keyboardType: TextInputType.number,
                            onChanged: (value){
                              payAccountNum = value.trim();
                              checkThirdPageSubmit();
                            },
                          )
                        )
                      )
                    ],
                  ),
                  const SizedBox(height: 20,),
                  Row(
                    children: [
                      const Text("开  户  行:",style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8,),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 0, 50, 0),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap:() async{
                                  Result? result = await CityPickers.showCityPicker(
                                    context: context,
                                  );
                                  if(result != null){
                                    payAccountProvince = result.provinceName;
                                    payAccountCity = result.cityName;
                                    payAccountDist = result.areaName;
                                    checkThirdPageSubmit();
                                  }
                                },
                                child: Container( 
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border: Border.all(color:Colors.black.withOpacity(0.1),),
                                    borderRadius: BorderRadius.circular(4)
                                  ),
                                  child:Text(payAccountProvince != null ? "$payAccountProvince/$payAccountCity/$payAccountDist" : "请选择省/市/区")
                                )
                              ),
                              const SizedBox(height: 8,),
                              TextField(
                                decoration: inputDecoration,
                                onChanged: (value){
                                  payAccountBank = value.trim();
                                  checkThirdPageSubmit();
                                },
                              )
                            ]
                          )
                        )
                      )
                    ],
                  ),
                  const SizedBox(height: 20,),
                  Row(
                    children: [
                      const Text("支  行  名:",style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8,),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 0, 50, 0),
                          child: TextField(
                            decoration: inputDecoration,
                            onChanged: (value){
                              payAccountBankSub = value.trim();
                              checkThirdPageSubmit();
                            },
                          )
                        )
                      )
                    ],
                  ),
                  const SizedBox(height: 20,),
                  Row(
                    children: [
                      const Text("银行行号:",style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8,),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 0, 50, 0),
                          child: TextField(
                            decoration: inputDecoration,
                            keyboardType: TextInputType.number,
                            onChanged: (value){
                              payAccountBankCode = value;
                              checkThirdPageSubmit();
                            },
                          )
                        )
                      )
                    ],
                  ),
                ],
              )
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
              decoration: const BoxDecoration(
                border: Border(top:BorderSide(width: 2,color: Colors.black12)),
                //borderRadius:BorderRadius.circular(6)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: (){
                      setStep(1);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(4, 182, 221, 1),
                      padding: const EdgeInsets.fromLTRB(40 ,10, 40, 10)
                    ),
                    child: const Text('上一步',style:TextStyle(color:Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: (){
                      try{
                        isThirdPageChecked = checkThirdPage(true);
                      }
                      catch(e){
                        ToastUtil.warn(e.toString());
                      }
                      if(isThirdPageChecked) {
                        setStep(3);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:isThirdPageChecked ? submitBtnColorOn : submitBtnColorOff,
                      padding: const EdgeInsets.fromLTRB(40, 10, 40, 10)
                    ),
                    child: const Text('下一步',style:TextStyle(color:Colors.white)),
                  )
                ]
              )
            )
          ],
        ),
      )
    );
  }

  getForthPage() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(14, 20, 14, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text("联系人名称:",style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8,),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 0, 50, 0),
                          child: TextField(
                            decoration: inputDecoration,
                            onChanged: (value){
                              contactName = value.trim();
                              checkForthPage();
                            },
                          )
                        )
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text("联系人电话:",style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8,),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 0, 50, 0),
                          child: TextField(
                            decoration: inputDecoration,
                            keyboardType: TextInputType.number,
                            onChanged: (value){
                              contactPhone = value.trim();
                              checkForthPage();
                            },
                          )
                        )
                      )
                    ],
                  ),
                  const SizedBox(height:20),
                  Row(
                    children: [
                      const Text("联系人邮箱:",style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8,),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 0, 50, 0),
                          child: TextField(
                            decoration: inputDecoration,
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (value){
                              contactEmail = value.trim();
                              checkForthPage();
                            },
                          )
                        )
                      )
                    ],
                  ),
                  const SizedBox(height:20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("合作类型",style: TextStyle(fontWeight: FontWeight.bold),),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  getLicTypeRadio(0, '预付'),
                                ],
                              ),
                            ]
                          )
                        )
                      )
                    ]
                  ),
                ],
              )
            ),
            const SizedBox(height: 10,),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.fromLTRB(14, 20, 14, 20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: (){
                      isAgree = !isAgree;
                      setState(() {
                      });
                      checkForthPage();
                    },
                    child: Row(
                      children:[
                        Icon(isAgree ? Icons.check_circle_rounded : Icons.radio_button_unchecked),
                        const SizedBox(width: 8,),
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: '同意',
                                style: TextStyle(color: ThemeUtil.foregroundColor)
                              ),
                              TextSpan(
                                text: '《商家协议》',
                                recognizer: TapGestureRecognizer()..onTap = (){
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                    return const MerchantTermsPage();
                                  }));
                                },
                                style: const TextStyle(color: Colors.lightBlue)
                              )
                            ]
                          ),
                        )
                      ]
                    )
                  )
                ],
              )
            ),
            const SizedBox(height: 2,),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.fromLTRB(14, 20, 14, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: (){
                      setStep(2);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: submitBtnColorOn,
                      padding: const EdgeInsets.fromLTRB(40 ,10, 40, 10)
                    ),
                    child: const Text('上一步',style:TextStyle(color:Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: (){
                      save();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFirstPageChecked && isSecondPageChecked && isThirdPageChecked && isForthPageChecked ? submitBtnColorOn : submitBtnColorOff,
                      padding: const EdgeInsets.fromLTRB(48, 10, 48, 10)
                    ),
                    child: const Text('确定',style:TextStyle(color:Colors.white)),   
                  )
                ],
              )
            ),
          ]
        )
      )
    );
  }

  getIsLicAddressSameRadio(int value, String name) {
    return GestureDetector(
      onTap: (){
        isLicAddrSame=value;
        checkSecondPageSumit();
      },
      child: Row(
        children: [
          isLicAddrSame == value ? 
          const Icon(Icons.radio_button_checked,size: 16,) : 
          const Icon(Icons.radio_button_off,size: 16,color: Colors.black26,),
          const SizedBox(width: 4,),
          Text(name, style: const TextStyle(color:Colors.black),)
        ],
      )
    );
  }

  getIsIdentityLegalRadio(int value, String name) {
    return GestureDetector(
      onTap: (){
        isIdentityLegal=value;
        checkSecondPageSumit();
      },
      child: Row(
        children: [
          isIdentityLegal==value ? 
          const Icon(Icons.radio_button_checked,size: 16,): 
          const Icon(Icons.radio_button_off,size: 16,color: Colors.black26,),
          const SizedBox(width: 4,),
          Text(name, style: const TextStyle(color:Colors.black),)
        ],
      )
    );
  }

  getPayPeriodRadio(int value, String name) {
    return GestureDetector(
      onTap: (){
        payPeriod = value;
        checkThirdPageSubmit();
      },
      child: Row(
        children: [
          payPeriod == value ?
          const Icon(Icons.radio_button_checked,size: 16,): 
          const Icon(Icons.radio_button_off,size: 16,color: Colors.black26,),
          const SizedBox(width: 4,),
          Text(name, style: const TextStyle(color:Colors.black),)
        ],
      )
    );
  }

  getPayAccountTypeRadio(int value, String name) {
    return GestureDetector(
      onTap: (){
        payAccountType = value;
        checkThirdPageSubmit();
      },
      child: Row(
        children: [
          payAccountType == value ?
          const Icon(Icons.radio_button_checked,size: 16,) : 
          const Icon(Icons.radio_button_off,size: 16,color: Colors.black26,),
          const SizedBox(width: 4,),
          Text(name, style: const TextStyle(color:Colors.black),)
        ],
      )
    );
  }

  getNormalInputDecoration(String hint) {
    final inputDecoration = InputDecoration(
      hintText: hint,
      isDense: true,
      contentPadding: const EdgeInsets.fromLTRB(4, 10, 0, 10),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
        borderSide:  BorderSide(color:Color.fromRGBO(0, 0, 0, 0.1), width: 1)
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
        borderSide:  BorderSide(color:Color.fromRGBO(0, 0, 0, 0.1), width:1)
      )
    );
    return inputDecoration;
  }

  checkFirstPageSumit() {
    if(checkFirstPage()) {
      isFirstPageChecked = true;
    }
    else {
      isFirstPageChecked = false;
    }
    setState(() {
    });
  }

  checkThirdPageSubmit() {
    if(checkThirdPage()) {
      isThirdPageChecked = true;
    }
    else {
      isThirdPageChecked = false;
    }
    setState(() {
    });
  }

  checkSecondPageSumit() {
    if(checkSecondPage()) {
      isSecondPageChecked=true;
    }
    else {
      isSecondPageChecked=false;
    }
    setState(() {
    });
  }

  bool checkFirstPage([bool isThrow=false]) {
    try{
      if(StringUtil.isEmpty(shopName)) {
        throw "店铺名称不能为空";
      }
      if(StringUtil.isEmpty(shopsignPic)) {
        throw "店铺招牌照片不能为空";
      }
      if(StringUtil.isEmpty(frontPic)) {
        throw "前台照片不能为空";
      }
      if(StringUtil.isEmpty(address)) {
        throw "前台照片不能为空";
      }
      if(StringUtil.isEmpty(fixedPhone)) {
        throw "联系方式不能为空";
      }
      if(fixedPhone != null && !RegularUtil.checkPhone(fixedPhone!) && !RegularUtil.checkFixedPhone(fixedPhone!)){
        throw '联系方式格式错误';
      }
    }
    catch(e) {
      if(isThrow) {
          rethrow;
      }
      return false;
    }
    return true;
  }

  bool checkSecondPage([bool isThrow=false]) {
    try{
      if(StringUtil.isEmpty(licPic)) {
        throw "证件图片不能为空";
      }
      if(isLicAddrSame == 0 && StringUtil.isEmpty(licAddrDes)) {
        throw "营业执照和实际地址不一致说明不能为空";
      }
      if(StringUtil.isEmpty(identityFrontPic)) {
        throw "身份证下面照片不能为空";
      }
      if(StringUtil.isEmpty(identityBackPic)) {
        throw "身份证背面照片不能为空";
      }
      if(StringUtil.isEmpty(identityHandPic)) {
        throw "身份证手持照片不能为空";
      }
      if(isIdentityLegal==0 && StringUtil.isEmpty(grantPic)) {
        throw "授权证明不能为空";
      }
    }
    catch(e) {
      if(isThrow) {
        rethrow;
      }
      return false;
    }
    return true;
  }

  bool checkThirdPage([bool isThrow=false]) {
    try{
      if(StringUtil.isEmpty(payAccountName)) {
        throw "账户名称不能为空";
      }
      if(StringUtil.isEmpty(payAccountNum)) {
        throw "银行卡号不能为空";
      }
      if(payAccountNum != null && !RegularUtil.checkBankCard(payAccountNum!)){
        throw '银行卡号格式错误';
      }
      if(StringUtil.isEmpty(payAccountCity)) {
        throw "开户行所在地区不能为空";
      }
      if(StringUtil.isEmpty(payAccountBank)) {
        throw "开户行不能为空";
      }
      if(StringUtil.isEmpty(payAccountBankSub)) {
        throw "支行不能为空";
      }
      if(StringUtil.isEmpty(payAccountBankCode)) {
        throw "银行行号不能为空";
      }
      if(payAccountBankCode != null && payAccountBank!.isNotEmpty && !RegularUtil.checkNumber(payAccountBankCode!)){
        throw '银行行号格式错误';
      }
    }
    catch(e) {
      if(isThrow) {
        rethrow;
      }
      return false;
    }
    return true;
  }

  resetState(){
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }
}
