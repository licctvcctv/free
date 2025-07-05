
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/merchent/merchant_api.dart';
import 'package:freego_flutter/components/merchent/merchant_common.dart';
import 'package:freego_flutter/components/merchent/merchant_wechat.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/web_views/merchant_terms.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/http/http_file.dart';
import 'package:freego_flutter/util/image_util.dart';
import 'package:freego_flutter/util/permission_util.dart';
import 'package:freego_flutter/util/regular_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';


class MerchantApplyPage extends StatelessWidget{
  final int userId;
  const MerchantApplyPage({super.key, required this.userId});
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 10,
        elevation: 0,
        backgroundColor: ThemeUtil.backgroundColor,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      body: MerchantApplyWidget(userId: userId),
    );
  }
  
}

class MerchantApplyWidget extends StatefulWidget{
  final int userId; 
  const MerchantApplyWidget({super.key, required this.userId});

  @override
  State<StatefulWidget> createState() {
    return MerchantApplyState();
  }
  
}


class MerchantApplyState extends State<MerchantApplyWidget>{
  ApplyStatus? applyStatus; // 申请状态
  String? auditMessage; // 审核消息

  bool get isFormEditable {
    return applyStatus == null || 
           applyStatus == ApplyStatus.failed || 
           applyStatus == ApplyStatus.passed;
  }

  static const double FIELD_WIDTH = 80;
  Widget svgHotel = SvgPicture.asset('svg/icon_hotel.svg', color: ThemeUtil.foregroundColor,);
  Widget svgScenic = SvgPicture.asset('svg/icon_scenic.svg', color: ThemeUtil.foregroundColor,);
  Widget svgRestaurant = SvgPicture.asset('svg/icon_restaurant.svg', color: ThemeUtil.foregroundColor,);
  Widget svgTravel = SvgPicture.asset('svg/icon_travel.svg', color: ThemeUtil.foregroundColor,);

  TextEditingController merchantNameController = TextEditingController();
  TextEditingController showNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController wechatController = TextEditingController();
  TextEditingController licenseTypeController = TextEditingController();

  MerchantApplyParam param = MerchantApplyParam();
  bool isAgree = false;
  String applymentState = '未申请'; // 初始状态为"未申请"
  bool hasMerchantWeChatData = false;
  MerchantWeChatData? merchantWeChatData;
  //Map<String, dynamic>? merchantWeChatData;
  bool hasMerchantData = false;
  Map<String, dynamic>? merchantData;
  
    // 控制器
  final TextEditingController verificationCodeController = TextEditingController();
  final TextEditingController _verificationCodeController = TextEditingController();

  // 倒计时相关状态
  int _countdownSeconds = 0; // 当前剩余秒数
  Timer? _timer;             // 计时器对象
  bool get _isCountingDown => _countdownSeconds > 0; // 是否在倒计时中

  String _verificationStatus = ''; // 验证状态信息
  Color _verificationStatusColor = Colors.transparent; // 状态文字颜色
  bool _isCodeVerified = false; // 验证是否通过
  bool _isVerifying = false;

  @override
  void initState(){
    super.initState();
    fetchMerchantWeChatData();
    fetchMerchantData();
    fetchMerchantApplyData(); 
  }

  @override
  void dispose(){
    super.dispose();
    merchantNameController.dispose();
    showNameController.dispose();
    phoneController.dispose();
    mobileController.dispose();
    emailController.dispose();
    wechatController.dispose();
    licenseTypeController.dispose();
    _verificationCodeController.dispose();
  }

Future<void> fetchMerchantWeChatData() async {
  try {
    var response = await MerchantApi().getMerchantWeChat(widget.userId);
    if (response != null) {
      setState(() {
        merchantWeChatData = MerchantWeChatData.fromJson(response);
        applymentState = merchantWeChatData?.applymentState ?? '未申请';
      });
    }
  } catch (e) {
    ToastUtil.error('查询失败: $e');
  }
}
Future<void> fetchMerchantData() async {
    try {
      var response = await MerchantApi().getMerchantData();
      setState(() {
        hasMerchantData = response != null;
        merchantData = response;
      });
    } catch (e) {
      ToastUtil.error('查询失败: $e');
      setState(() {
        hasMerchantData = false;
        merchantData = null;
      });
    }
}
  Future<void> fetchMerchantApplyData() async {
    try {
      // 调用API获取商户申请数据
      var applicationData = await MerchantApi().getApplyByMerchantId(widget.userId);
      
      if (applicationData != null) {
        setState(() {
          // 将API返回的数据填充到表单中
          merchantNameController.text = applicationData['merchantName'] ?? '';
          showNameController.text = applicationData['showName'] ?? '';
          phoneController.text = applicationData['phone'] ?? '';
          mobileController.text = applicationData['mobile'] ?? '';
          emailController.text = applicationData['email'] ?? '';
          wechatController.text = applicationData['accountWechat'] ?? '';
          //licenseTypeController.text = applicationData['licenseType'] ?? '';
          if (applicationData['licenseType'] != null) {
            String licenseTypeVal = applicationData['licenseType'];
            LicenseType? type = LicenseTypeExt.getType(licenseTypeVal);
            if (type != null) {
              licenseTypeController.text = type.getDesc();
              param.licenseType = type.getVal();
            }
          }
          if (applicationData['applyStatus'] != null) {
            applyStatus = ApplyStatusExt.getStatus(applicationData['applyStatus']);
            auditMessage = applicationData['auditMessage']; // 如果有审核消息
          }
          if (applicationData['merchantType'] != null) {
            param.merchantType = applicationData['merchantType'];
            // 如果需要显示中文，可以在这里设置（根据业务需求）
            // merchantTypeController.text = getMerchantTypeDesc(applicationData['merchantType']);
          }
          // 更新其他字段
          //param = MerchantApplyParam.fromJson(applicationData);
          
          // 如果有类型选择
          //if (applicationData['type'] != null) {
          //  param.type = applicationData['type'];
          //}
          
          // 处理文件URL
          param.licenseUrl = applicationData['licenseUrl']; 
          param.foodSafetyCertificate = applicationData['foodSafetyCertificate'];
        });
      }
    } catch (e) {
      ToastUtil.error('加载申请信息失败，请稍后重试');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        color: ThemeUtil.backgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonHeader(
            center: Text(
              "商家申请",
              //hasMerchantData ? "商家进件" : "商家申请",  // 动态标题
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              physics: const ClampingScrollPhysics(),
              children: [
                  getApplyStatusWidget(), 
                  getNameWidget(),
                  getShowNameWidget(),
                  getTypeWidget(),
                  getFoodSafetyCertificateWidget(),
                  getPhoneWidget(),
                  getMobileWidget(),
                  getEmailWidget(),
                  getAccountWidget(),
                  getLicenseTypeWidget(),
                  getLicenseUrlWidget(),
                  getAgreementWidget(),
                  getSubmitWidget()
                ],
              /*children: hasMerchantData
                  ? [
                      getWeChatWidget(),
                      getAccountWidget(),
                      getAccountRejectedWidget(),
                      getWeChatAuditInfoWidget(),
                      getlegalValidationUrlWidget(),
                    ]  // 有数据时显示商家进件
                  : [                     // 无数据时显示商家申请表单
                      getApplyStatusWidget(), 
                      getNameWidget(),
                      getShowNameWidget(),
                      getTypeWidget(),
                      getFoodSafetyCertificateWidget(),
                      getPhoneWidget(),
                      getMobileWidget(),
                      getEmailWidget(),
                      getLicenseTypeWidget(),
                      getLicenseUrlWidget(),
                      getAgreementWidget(),
                      getSubmitWidget(),
                    ],*/
            ),
          ),

          ],
        ),
      ),
    );
  }

  Widget getApplyStatusWidget() {
  if (applyStatus == null) return const SizedBox(); // 没有状态时不显示
  
  Color statusColor;
  switch (applyStatus) {
    case ApplyStatus.passed:
      statusColor = Colors.green;
      break;
    case ApplyStatus.failed:
      statusColor = Colors.red;
      break;
    case ApplyStatus.auditing:
    default:
      statusColor = Colors.orange;
  }

  return Padding(
    padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
    child: Row(
      children: [
        SizedBox(
          width: FIELD_WIDTH,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('审', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
              Text('核', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
              Text('状', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
              Text('态', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16))
            ],
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            margin: const EdgeInsets.only(left: 16),
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  applyStatus!.getDesc(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (auditMessage != null && auditMessage!.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '($auditMessage)',
                      style: const TextStyle(color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ]
              ],
            ),
          ),
        )
      ],
    ),
  );
}

  Widget getNameWidget(){
    bool isDisabled = applyStatus == ApplyStatus.auditing || applyStatus == ApplyStatus.passed;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
      child: Row(
        children: [
          SizedBox(
            width: FIELD_WIDTH,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('商', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
                Text('家', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
                Text('名', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
                Text('称', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),)
              ],
            )
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDisabled ? Colors.grey[200] : Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(4))
              ),
              margin: const EdgeInsets.only(left: 16),
              padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
              clipBehavior: Clip.hardEdge,
              alignment: Alignment.center,
              child: TextField(
                enabled: !isDisabled,
                style: TextStyle(
                  color: isDisabled ? Colors.grey : Colors.black,
                ),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.only(top: 4),
                  border: InputBorder.none,
                  hintText: '',
                  counter: SizedBox()
                ),
                maxLength: 30,
                textAlign: TextAlign.end,
                onChanged: (val){
                  param.merchantName = val;
                },
                controller: merchantNameController,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget getShowNameWidget(){
    bool isDisabled = applyStatus == ApplyStatus.auditing || applyStatus == ApplyStatus.passed;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
      child: Row(
        children: [
          SizedBox(
            width: FIELD_WIDTH,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('显', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
                Text('示', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
                Text('名', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
                Text('称', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),)
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDisabled ? Colors.grey[200] : Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(4))
              ),
              margin: const EdgeInsets.only(left: 16),
              padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
              clipBehavior: Clip.hardEdge,
              alignment: Alignment.center,
              child: TextField(
                enabled: !isDisabled,
                style: TextStyle(
                  color: isDisabled ? Colors.grey : Colors.black,
                ),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.only(top: 4),
                  border: InputBorder.none,
                  hintText: '',
                  counter: SizedBox()
                ),
                maxLength: 30,
                textAlign: TextAlign.end,
                onChanged: (val){
                  param.showName = val;
                },
                controller: showNameController,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget getTypeWidget(){
    bool isDisabled = applyStatus == ApplyStatus.auditing || applyStatus == ApplyStatus.passed;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: FIELD_WIDTH,
            height: 40,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('经', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
                Text('营', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
                Text('类', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
                Text('型', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Wrap(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        //child: svgHotel,
                        child: isDisabled 
                        ? SvgPicture.asset('svg/icon_hotel.svg', color: Colors.grey)
                        : svgHotel,
                      ),
                      const SizedBox(width: 4,),
                      //const Text('酒店'),
                      Text('酒店', style: TextStyle(color: isDisabled ? Colors.grey : Colors.black)),
                      Radio<String?>(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        value: MerchantType.hotel.getVal(),
                        groupValue: param.merchantType,
                        toggleable: true,
                        onChanged: isDisabled ? null : (val){
                          param.merchantType = MerchantType.hotel.getVal();
                          setState(() {
                          });
                        },
                        fillColor: MaterialStateProperty.resolveWith((states){
                        if (isDisabled) return Colors.grey;
                          return states.contains(MaterialState.selected)
                            ? ThemeUtil.foregroundColor
                            : Colors.grey;
                        })
                      )
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.business, 
                        size: 24, 
                        color: isDisabled ? Colors.grey : null
                      ),
                      const SizedBox(width: 4,),
                      Text('集团', style: TextStyle(color: isDisabled ? Colors.grey : Colors.black)),
                      Radio<String?>(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        value: MerchantType.group.getVal(),
                        groupValue: param.merchantType,
                        toggleable: true,
                        onChanged: isDisabled ? null :  (val){
                          param.merchantType = MerchantType.group.getVal();
                          setState(() {
                          });
                        },
                        fillColor: MaterialStateProperty.resolveWith((states){
                          if (isDisabled) return Colors.grey;
                            return states.contains(MaterialState.selected)
                              ? ThemeUtil.foregroundColor
                              : Colors.grey;
                        })
                      )
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.home_work, 
                        size: 24, 
                        color: isDisabled ? Colors.grey : null
                      ),
                      const SizedBox(width: 4,),
                      Text('民宿', style: TextStyle(color: isDisabled ? Colors.grey : Colors.black)),
                      Radio<String?>(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        value: MerchantType.homestay.getVal(),
                        groupValue: param.merchantType,
                        toggleable: true,
                        onChanged: isDisabled ? null : (val){
                          param.merchantType = MerchantType.homestay.getVal();
                          setState(() {
                          });
                        },
                        fillColor: MaterialStateProperty.resolveWith((states){
                          if (isDisabled) return Colors.grey;
                            return states.contains(MaterialState.selected)
                              ? ThemeUtil.foregroundColor
                              : Colors.grey;
                        })
                      )
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        //child: svgScenic,
                        child: isDisabled 
                        ? SvgPicture.asset('svg/icon_scenic.svg', color: Colors.grey)
                        : svgScenic,
                      ),
                      const SizedBox(width: 4,),
                      Text('景点', style: TextStyle(color: isDisabled ? Colors.grey : Colors.black)),
                      Radio<String?>(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        value: MerchantType.scenic.getVal(),
                        groupValue: param.merchantType,
                        onChanged: isDisabled ? null : (val){
                          param.merchantType = MerchantType.scenic.getVal();
                          setState(() {
                          });
                        },
                        fillColor: MaterialStateProperty.resolveWith((states){
                          if (isDisabled) return Colors.grey;
                            return states.contains(MaterialState.selected)
                              ? ThemeUtil.foregroundColor
                              : Colors.grey;
                        })
                      )
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        //child: svgRestaurant,
                        child: isDisabled 
                          ? SvgPicture.asset('svg/icon_restaurant.svg', color: Colors.grey)
                         : svgRestaurant,
                      ),
                      const SizedBox(width: 4,),
                      Text('美食', style: TextStyle(color: isDisabled ? Colors.grey : Colors.black)),
                      Radio<String?>(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        value: MerchantType.dining.getVal(),
                        groupValue: param.merchantType,
                        onChanged: isDisabled ? null : (val){
                          param.merchantType = MerchantType.dining.getVal();
                          setState(() {
                          });
                        },
                        fillColor: MaterialStateProperty.resolveWith((states){
                          if (isDisabled) return Colors.grey;
                            return states.contains(MaterialState.selected)
                              ? ThemeUtil.foregroundColor
                              : Colors.grey;
                        })
                      )
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: isDisabled 
                          ? SvgPicture.asset('svg/icon_travel.svg', color: Colors.grey)
                          : svgTravel,
                      ),
                      const SizedBox(width: 4,),
                      //const Text('旅行'),
                      Text('旅行', style: TextStyle(color: isDisabled ? Colors.grey : Colors.black)),
                      Radio<String?>(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        value: MerchantType.travelAgency.getVal(),
                        groupValue: param.merchantType,
                        onChanged: isDisabled ? null : (val){
                          param.merchantType = MerchantType.travelAgency.getVal();
                          setState(() {
                          });
                        },
                        fillColor: MaterialStateProperty.resolveWith((states){
                          if (isDisabled) return Colors.grey;
                            return states.contains(MaterialState.selected)
                              ? ThemeUtil.foregroundColor
                              : Colors.grey;
                        })
                      )
                    ],
                  )
                ],
              )
            ),
          )
        ],
      ),
    );
  }
  Widget getFoodSafetyCertificateWidget() {
  // 只有当选择美食类型时才显示这个字段
  if (param.merchantType != MerchantType.dining.getVal()) {
    return const SizedBox.shrink();
  }
  bool isDisabled = applyStatus == ApplyStatus.auditing || applyStatus == ApplyStatus.passed;
  return Padding(
    padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: FIELD_WIDTH,
          height: 40,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('食', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
              Text('品', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
              Text('安', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
              Text('全', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
              Text('证', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),)
            ],
          ),
        ),
        const SizedBox(width: 16,),
        Expanded(
          child: InkWell(
            onTap: isDisabled ? null : () async {
              bool isGranted = await PermissionUtil().requestPermission(
                context: context, 
                permission: Permission.storage, 
                info: '希望获取存储权限用于选择食品经营许可证照片'
              );
              if(!isGranted){
                ToastUtil.error('获取存储权限失败');
                return;
              }

              AssetPickerConfig config = ImageUtil.buildDefaultImagePickerConfig();
              if(mounted && context.mounted){
                final List<AssetEntity>? results = await AssetPicker.pickAssets(
                  context,
                  pickerConfig: config
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
                //foodSafetyCertificateFile = file;
                String path = file.path;
                String name = path.substring(path.lastIndexOf('/') + 1, path.length);
                String? url = await HttpFile.uploadFile(path, name);
                if(url == null){
                  ToastUtil.error('文件上传失败');
                  return;
                }
                param.foodSafetyCertificate = url;
                if(mounted && context.mounted){
                  setState(() {
                  });
                }
              }
            },
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: param.foodSafetyCertificate == null ? 
              Container(
                width: double.infinity,
                height: double.infinity,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(12))
                ),
                child: const Text('选择食品经营许可证照片', 
                  style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),
                ),
              ) :
              Image.network(
                getFullUrl(param.foodSafetyCertificate!), 
                fit: BoxFit.fill, 
                width: double.infinity,
              )
            ),
          )
        )
      ],
    ),
  );
}
  Widget getPhoneWidget(){
    bool isDisabled = applyStatus == ApplyStatus.auditing || applyStatus == ApplyStatus.passed;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
      child: Row(
        children: [
          SizedBox(
            width: FIELD_WIDTH,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('固', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
                Text('定', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
                Text('电', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
                Text('话', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),)
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDisabled ? Colors.grey[200] : Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(4))
              ),
              margin: const EdgeInsets.only(left: 16),
              padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
              clipBehavior: Clip.hardEdge,
              alignment: Alignment.center,
              child: TextField(
                enabled: !isDisabled,
                style: TextStyle(
                  color: isDisabled ? Colors.grey : Colors.black,
                ),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.only(top: 4),
                  border: InputBorder.none,
                  hintText: '',
                  counter: SizedBox()
                ),
                maxLength: 30,
                textAlign: TextAlign.end,
                onChanged: (val){
                  param.phone = val;
                },
                controller: phoneController,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget getMobileWidget(){
    bool isDisabled = applyStatus == ApplyStatus.auditing || applyStatus == ApplyStatus.passed;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
      child: Row(
        children: [
          SizedBox(
            width: FIELD_WIDTH,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('手', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
                Text('机', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
                Text('号', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),)
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDisabled ? Colors.grey[200] : Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(4))
              ),
              margin: const EdgeInsets.only(left: 16),
              padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
              clipBehavior: Clip.hardEdge,
              alignment: Alignment.center,
              child: TextField(
                enabled: !isDisabled,
                style: TextStyle(
                  color: isDisabled ? Colors.grey : Colors.black,
                ),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.only(top: 4),
                  border: InputBorder.none,
                  hintText: '',
                  counter: SizedBox()
                ),
                maxLength: 30,
                textAlign: TextAlign.end,
                onChanged: (val){
                  param.mobile = val;
                },
                controller: mobileController,
              ),
            ),
          )
        ],
      ),
    );
  }

  /*Widget getEmailWidget(){
    bool isDisabled = applyStatus == ApplyStatus.auditing || applyStatus == ApplyStatus.passed;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
      child: Row(
        children: [
          SizedBox(
            width: FIELD_WIDTH,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('电', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
                Text('子', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
                Text('邮', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
                Text('箱', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),)
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDisabled ? Colors.grey[200] : Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(4))
              ),
              margin: const EdgeInsets.only(left: 16),
              padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
              clipBehavior: Clip.hardEdge,
              alignment: Alignment.center,
              child: TextField(
                enabled: !isDisabled,
                style: TextStyle(
                  color: isDisabled ? Colors.grey : Colors.black,
                ),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.only(top: 4),
                  border: InputBorder.none,
                  hintText: '',
                  counter: SizedBox()
                ),
                maxLength: 100,
                textAlign: TextAlign.end,
                onChanged: (val){
                  param.email = val;
                },
                controller: emailController,
              ),
            ),
          )
        ],
      ),
    );
  }*/

  Widget getEmailWidget() {
  bool isDisabled = applyStatus == ApplyStatus.auditing || applyStatus == ApplyStatus.passed;

  return Padding(
    padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
    child: Column(
      children: [
        // 邮箱输入行（保持原样）
        Row(
          children: [
            SizedBox(
              width: FIELD_WIDTH,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('电', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
                  Text('子', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
                  Text('邮', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
                  Text('箱', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDisabled ? Colors.grey[200] : Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
                margin: const EdgeInsets.only(left: 16),
                padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
                clipBehavior: Clip.hardEdge,
                child: TextField(
                  enabled: !isDisabled,
                  style: TextStyle(color: isDisabled ? Colors.grey : Colors.black),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.only(top: 4),
                    border: InputBorder.none,
                    //hintText: '请输入邮箱',
                    counter: SizedBox(),
                  ),
                  maxLength: 100,
                  textAlign: TextAlign.end,
                  onChanged: (val) => param.email = val,
                  controller: emailController,
                ),
              ),
            ),
          ],
        ),

        // 新增验证码行（间距和左侧对齐邮箱输入框）
        if (!isDisabled)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Row(
            children: [
              SizedBox(
                width: FIELD_WIDTH,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('验', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
                    Text('证', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
                    Text('码', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
                    SizedBox(width: 16), // 保持4字宽度
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    // 验证码输入框
                    Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDisabled ? Colors.grey[200] : Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                    ),
                    margin: const EdgeInsets.only(left: 16),
                    padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                    child: TextField(
                      enabled: !isDisabled,
                      controller: _verificationCodeController,
                      style: TextStyle(color: isDisabled ? Colors.grey : Colors.black),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: '',
                        counterText: '',
                        suffixIcon: _isVerifying
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : null,
                      ),
                      maxLength: 6,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (value.length == 6) {
                          _verifyEmailCode();
                        } else {
                          setState(() {
                            _verificationStatus = '';
                            _isCodeVerified = false;
                          });
                        }
                      },
                    ),
                  ),
                ),
                    // 发送验证码按钮
                    if (!isDisabled)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: _isCountingDown 
                                ? Colors.grey 
                                : Colors.blue,
                            ),
                            onPressed: _sendVerificationCode,
                            child: Text(
                              _isCountingDown 
                                ? '$_countdownSeconds秒后重试' 
                                : '获取验证码',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

    // 发送验证码（包含校验）
  void _sendVerificationCode() {
    if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先输入邮箱')));
      return;
    }

    if (_isCountingDown) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_countdownSeconds}秒后可重新发送')));
      return;
    }

    // 调用API发送验证码
    MerchantApi().sendVerificationCode(
      email: emailController.text,
      onError: (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.error.toString())));
      },
      onSuccess: (response) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.data['message'])));
        // 开始倒计时
        _startCountdown();
      },
    );
  }
    // 开始倒计时（60秒）
  void _startCountdown() {
    setState(() {
      _countdownSeconds = 60; // 重置为60秒
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdownSeconds > 0) {
          _countdownSeconds--;
        } else {
          _timer?.cancel(); // 倒计时结束，取消计时器
        }
      });
    });
  }

Future<void> _verifyEmailCode() async {
  if (param.email == null || param.email!.isEmpty) {
    setState(() {
      _verificationStatus = '请先输入邮箱';
      _verificationStatusColor = Colors.red;
      _isCodeVerified = false;
    });
    return;
  }

  setState(() {
    _isVerifying = true;
    _verificationStatus = '验证中...';
    _verificationStatusColor = Colors.blue;
  });

  try {
    final verified = await MerchantApi().verifyEmailCode(
      email: param.email!,
      code: _verificationCodeController.text,
    );

    setState(() {
      _isVerifying = false;
      if (verified) {
        _verificationStatus = '验证码正确';
        _verificationStatusColor = Colors.green;
        _isCodeVerified = true;
      } else {
        _verificationStatus = '验证码错误';
        _verificationStatusColor = Colors.red;
        _isCodeVerified = false;
      }
    });
  } catch (e) {
    setState(() {
      _isVerifying = false;
      _verificationStatus = '验证失败: ${e.toString().replaceAll('DioException: ', '')}';
      _verificationStatusColor = Colors.red;
      _isCodeVerified = false;
    });
  }
}

  Widget getWeChatWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
      child: Row(
        children: [
          SizedBox(
            width: FIELD_WIDTH,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('微', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
                Text('信', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
                Text('申', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
                Text('请', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
              ],
            ),
          ),
          const SizedBox(width: 16,),
        ],
      ),
    );
  }

  Widget getAccountWidget(){
    bool isDisabled = applyStatus == ApplyStatus.auditing || applyStatus == ApplyStatus.passed;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
      child: Row(
        children: [
          SizedBox(
            width: FIELD_WIDTH,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('微', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
                Text('信', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
                Text('号', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),)
              ],
            ),
          ),
          const SizedBox(width: 16,),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDisabled ? Colors.grey[200] : Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(4))
              ),
              padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
              clipBehavior: Clip.hardEdge,
              alignment: Alignment.center,
              child: TextField(
                enabled: !isDisabled,
                style: TextStyle(
                  color: isDisabled ? Colors.grey : Colors.black,
                ),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.only(top: 4),
                  border: InputBorder.none,
                  hintText: '',
                  counter: SizedBox()
                ),
                maxLength: 30,
                textAlign: TextAlign.end,
                onChanged: (val){
                  param.accountWechat = val;
                },
                controller: wechatController,
              ),
            ),
          )
        ],
      ),
    );
  }
  /*Widget getAccountWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
      child: Row(
        children: [
          SizedBox(
            width: FIELD_WIDTH,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('申', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
                Text('请', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
                Text('状', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
                Text('态', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),)
              ],
            ),
          ),
          const SizedBox(width: 16,),
          Expanded(
            child: InkWell(
              onTap: () {
      if (applymentState == '未申请') {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MerchantWeChatPage(
              merchantWeChatData: MerchantWeChatData(), // 传递空数据或默认值
            ),
          ),
        ).then((_) {
          fetchMerchantWeChatData();
        });
      }
    },
              child: Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(4))),
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Builder(
                      builder: (context) {
                        return SizedBox.shrink();
                      },
                    ),
                    Text(
                      _getStatusText(applymentState),
                      style: TextStyle(
                        color: _getStatusColor(applymentState),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }*/


Widget getWeChatAuditInfoWidget() {
  if (applymentState == 'REJECTED') {
    try {
      // 解析 JSON 格式的驳回原因
      final List<dynamic> rejectReasons = json.decode(merchantWeChatData?.auditInfo ?? '[]');
      
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: FIELD_WIDTH,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('驳', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
                      Text('回', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
                      Text('原', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
                      Text('因', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
            const SizedBox(height: 8),
            // 显示每条驳回原因
            ...rejectReasons.map((reason) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '• ${reason['reject_reason']}',
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            )).toList(),
          ],
        ),
      );
    } catch (e) {
      // 如果解析失败，显示原始信息
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: FIELD_WIDTH,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('驳', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
                      Text('回', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
                      Text('原', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
                      Text('因', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              merchantWeChatData?.auditInfo ?? '无驳回原因',
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ],
        ),
      );
    }
  }
  return const SizedBox.shrink(); // 如果不是驳回状态，返回空组件
}

  Widget getAccountRejectedWidget() {
    if (applymentState == 'REJECTED') {
              print('前往修改:');
              print(merchantWeChatData.runtimeType);
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MerchantWeChatPage(
          merchantWeChatData: merchantWeChatData,  // 转换数据
        ),
      ),
    ).then((_) {
      fetchMerchantWeChatData();
    });
},
              child: Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(4))),
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Builder(
                      builder: (context) {
                        return SizedBox.shrink();
                      },
                    ),
                    Text(
                      '前往修改',
                      style: TextStyle(
                        color: _getStatusColor(applymentState),
                        fontSize: 16,
                      ),
                    ),
                    /*Text(
                      _getStatusText(applymentState),
                      style: TextStyle(
                        color: _getStatusColor(applymentState),
                        fontSize: 16,
                      ),
                    ),*/
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
    return const SizedBox.shrink(); // 如果不是驳回状态，返回空组件
  }


Widget getlegalValidationUrlWidget() {
  if (applymentState == 'NEED_SIGN') {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              final url = merchantWeChatData?.signUrl;
              print('signUrl: $url');
              if (url != null && url.isNotEmpty) {
                // 尝试使用微信URL Scheme打开
                final wechatUrl = 'weixin://dl/business/?t=$url';
                if (await canLaunchUrl(Uri.parse(wechatUrl))) {
                  await launchUrl(Uri.parse(wechatUrl));
                } else {
                  // 如果微信没安装，直接打开原始URL
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('无法打开链接')),
                    );
                  }
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('签约链接无效，请联系客服')),
                );
              }
            },
            child: const Text('立即签约', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(FIELD_WIDTH, 48),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
  return const SizedBox.shrink();
}

  String _getStatusText(String status) {
    final state = ApplymentStateExt.getStatus(status);
    return state?.getDesc() ?? '未申请';
  }

  Color _getStatusColor(String status) {
    final state = ApplymentStateExt.getStatus(status);
    if (state == null) return ThemeUtil.foregroundColor;
    
    switch (state) {
      case ApplymentState.checking:
      case ApplymentState.accountNeedVerify:
      case ApplymentState.auditing:
        return Colors.orange;
      case ApplymentState.rejected:
      case ApplymentState.frozen:
      case ApplymentState.canceled:
        return Colors.red;
      case ApplymentState.needSign:
        return Colors.blue;
      case ApplymentState.finish:
        return Colors.green;
    }
  }

  Widget getLicenseTypeWidget(){
    bool isDisabled = applyStatus == ApplyStatus.auditing || applyStatus == ApplyStatus.passed;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
      child: Row(
        children: [
          SizedBox(
            width: FIELD_WIDTH,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('证', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
                Text('件', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
                Text('类', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
                Text('型', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),)
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDisabled ? Colors.grey[200] : Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(4))
              ),
              margin: const EdgeInsets.only(left: 16),
              padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
              /*clipBehavior: Clip.hardEdge,
              alignment: Alignment.center,
              child: Listener(
                onPointerDown: (e) async{
                  LicenseType? type = await chooseLicenseType();
                  if(type != null){
                    licenseTypeController.text = type.getDesc();
                    param.licenseType = type.getVal();
                  }
                },
                child: TextField(
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.only(top: 4),
                    border: InputBorder.none,
                    hintText: '',
                    counter: SizedBox()
                  ),
                  maxLength: 30,
                  textAlign: TextAlign.end,
                  readOnly: true,
                  controller: licenseTypeController,
                ),
              ),*/
              child: AbsorbPointer(
                absorbing: isDisabled,
                child: GestureDetector(
                  onTap: isDisabled ? null : () async {
                    LicenseType? type = await chooseLicenseType();
                    if (type != null && mounted) {
                      setState(() {
                        licenseTypeController.text = type.getDesc();
                        param.licenseType = type.getVal();
                      });
                    }
                  },
                  child: TextField(
                    enabled: false, // 保持禁用状态以显示灰色文本
                    style: TextStyle(
                      color: isDisabled ? Colors.grey : Colors.black,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.only(top: 4),
                      border: InputBorder.none,
                      hintText: '',
                      counter: SizedBox()
                    ),
                    maxLength: 30,
                    textAlign: TextAlign.end,
                    readOnly: true,
                    controller: licenseTypeController,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget getLicenseUrlWidget(){
    bool isDisabled = applyStatus == ApplyStatus.auditing || applyStatus == ApplyStatus.passed;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: FIELD_WIDTH,
            height: 40,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('证', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
                Text('件', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
                Text('照', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
                Text('片', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),)
              ],
            ),
          ),
          const SizedBox(width: 16,),
          Expanded(
            child: InkWell(
              onTap: isDisabled ? null : () async{
                bool isGranted = await PermissionUtil().requestPermission(context: context, permission: Permission.storage, info: '希望获取存储权限用于选择证件照片');
                if(!isGranted){
                  ToastUtil.error('获取存储权限失败');
                  return;
                }
                AssetPickerConfig config = ImageUtil.buildDefaultImagePickerConfig();
                if(mounted && context.mounted){
                  final List<AssetEntity>? results = await AssetPicker.pickAssets(
                    context,
                    pickerConfig: config
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
                  String path = file.path;
                  String name = path.substring(path.lastIndexOf('/') + 1, path.length);
                  String? url = await HttpFile.uploadFile(path, name);
                  if(url == null){
                    ToastUtil.error('文件上传失败');
                    return;
                  }
                  param.licenseUrl = url;
                  if(mounted && context.mounted){
                    setState(() {
                    });
                  }
                }
              },
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: param.licenseUrl == null ? 
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(12))
                  ),
                  child: const Text('选择照片', style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16),),
                ) :
                Image.network(getFullUrl(param.licenseUrl!), fit: BoxFit.fill, width: double.infinity,)
              ),
            )
          )
        ],
      ),
    );
  }

  Widget getAgreementWidget(){
    bool isDisabled = applyStatus == ApplyStatus.auditing || applyStatus == ApplyStatus.passed;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        isDisabled
          ? const Icon(Icons.check_circle_rounded, 
                color: Colors.grey) // 禁用状态下显示灰色已选中图标
          : InkWell(
              onTap: () {
                isAgree = !isAgree;
                setState(() {});
              },
              child: Icon(
                isAgree ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                color: ThemeUtil.foregroundColor,
              ),
            ),
        const SizedBox(width: 8,),
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: '同意',
                style: TextStyle(color: ThemeUtil.foregroundColor, fontSize: 16)
              ),
              TextSpan(
                text: '《商家协议》',
                recognizer: TapGestureRecognizer()..onTap = (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context){
                    return const MerchantTermsPage();
                  }));
                },
                style: const TextStyle(color: Colors.lightBlue, fontSize: 16)
              )
            ]
          ),
        )
      ],
    );
  }


  Widget getSubmitWidget(){
    bool isReturnButton = applyStatus == ApplyStatus.auditing || applyStatus == ApplyStatus.passed;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
      child: GestureDetector(
        onTap: (){
          if (isReturnButton) {
            Navigator.of(context).pop(); // 返回上一页
            return;
          }
          if(param.merchantName == null || param.merchantName!.trim().isEmpty){
            ToastUtil.warn('商家名称不能为空');
            return;
          }
          if(param.showName == null || param.showName!.trim().isEmpty){
            ToastUtil.warn('显示名称不能为空');
            return;
          }
          if(param.merchantType == null){
            ToastUtil.warn('经营类型不能为空');
            return;
          }
          if(param.foodSafetyCertificate == MerchantType.dining.getVal() && 
            (param.foodSafetyCertificate == null || param.foodSafetyCertificate!.isEmpty)) {
            ToastUtil.warn('请上传食品经营许可证');
            return;
          }
          if ((param.phone == null || param.phone == '') && (param.mobile == null || param.mobile == '')) {
            ToastUtil.warn('请至少填写固定电话或手机号中的一个');
            return;
          }
          if(param.phone != null && param.phone!.isNotEmpty){
            if(!RegularUtil.checkFixedPhone(param.phone ?? '')){
              ToastUtil.warn('固定电话格式错误');
              return;
            }
          }
          if(param.phone != null && param.phone!.length != 0){
            if(!RegularUtil.checkFixedPhone(param.phone!)){
              ToastUtil.warn('固定电话格式错误');
              return;
            }
          }
          if(param.mobile != null && param.mobile != ''){
            if(!RegularUtil.checkPhone(param.mobile ?? '')){
              ToastUtil.warn('手机号格式错误');
              return;
            }
          }
          if(param.email != null && param.email != ''){
            if(!RegularUtil.checkEmail(param.email ?? '')){
              ToastUtil.warn('邮箱格式错误');
              return;
            }
          }
            if(_verificationCodeController.text.isEmpty){
    ToastUtil.warn('请输入验证码');
    return;
  }
  if(!_isCodeVerified){
    ToastUtil.warn('验证码错误');
    return;
  }
          if(param.licenseType == null){
            ToastUtil.warn('证件类型不能为空');
            return;
          }
          if(param.licenseUrl == null){
            ToastUtil.warn('证件照片不能为空');
            return;
          }
          if(!isAgree){
            ToastUtil.warn('请同意《商家协议》');
            return;
          }
          MerchantApi().apply(param: param,
            fail: (response){
              ToastUtil.error(response.data['message'] ?? '申请失败');
            },
            success: (response){
              ToastUtil.hint('申请成功');
              Future.delayed(const Duration(seconds: 3), (){
                if(mounted && context.mounted){
                  Navigator.of(context).pop();
                }
              });
            }
          );
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(48, 0, 48, 0),
          decoration: const BoxDecoration(
            color: Colors.lightBlue,
            borderRadius: BorderRadius.all(Radius.circular(12))
          ),
          width: double.infinity,
          height: 48,
          alignment: Alignment.center,
          child: Text(
            isReturnButton ? '返 回' : '申 请',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      )
    );
  }

  Future<LicenseType?> chooseLicenseType() async{
    LicenseType? licenseType = LicenseType.values[0];
    return await showModalBottomSheet(
      isScrollControlled: true,
      context: context, 
      builder: (context){
        return StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              height: 240,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              '取消',
                              style: TextStyle(
                                color: ThemeUtil.buttonColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pop(licenseType);
                            },
                            child: const Text(
                              '确认',
                              style: TextStyle(
                                color: ThemeUtil.buttonColor,
                                fontSize: 16,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 180,
                      child: Stack(
                        children: [
                          ListWheelScrollView(
                            diameterRatio: 1.5,
                            itemExtent: 40,
                            onSelectedItemChanged: (index) {
                              licenseType = LicenseType.values[index];
                            },
                            physics: const FixedExtentScrollPhysics(),
                            children: List.generate(
                              LicenseType.values.length,
                              (index) {
                                LicenseType type = LicenseType.values[index];
                                return Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    type.getDesc(),
                                    style: const TextStyle(
                                      color: ThemeUtil.foregroundColor,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            top: 68,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 1,
                              color: Colors.grey[300],
                            ),
                          ),
                          Positioned(
                            bottom: 68,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 1,
                              color: Colors.grey[300],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                )
              ),
            );
          },
        );
      }
    );
  }


  
}
