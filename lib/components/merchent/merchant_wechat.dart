import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/merchent/merchant_api.dart';
import 'package:freego_flutter/components/merchent/merchant_common.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/http/http_file.dart';
import 'package:freego_flutter/util/image_util.dart';
import 'package:freego_flutter/util/permission_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../data/city_neo.dart';

class MerchantWeChatPage extends StatelessWidget {
  final MerchantWeChatData? merchantWeChatData;
  const MerchantWeChatPage({super.key, this.merchantWeChatData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 10,
        elevation: 0,
        backgroundColor: ThemeUtil.backgroundColor,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      body: MerchantWeChatWidget(merchantWeChatData: merchantWeChatData!),
    );
  }
}

class MerchantWeChatWidget extends StatefulWidget {
  final MerchantWeChatData merchantWeChatData;
  const MerchantWeChatWidget({super.key, required this.merchantWeChatData});

  @override
  State<StatefulWidget> createState() {
    return MerchantWeChatState();
  }
}

class MerchantWeChatState extends State<MerchantWeChatWidget> {
  File? _tempBusinessLicenseFile;
  File? _tempIdCardCopyFile;
  File? _tempIdCardNationalFile;
  File? _tempFinanceLicenseFile;
  File? _tempAuthorizeLetterFile;
  File? _tempidDocCopyFile;
  File? _tempidDocCopyBackFile;
  File? _tempContactIdCardCopyFile;
  File? _tempContactIdCardCopyBackFile;
  File? _tempBusinessAuthorizationLetterFile;
  File? _tempstoreQrCodeFile;

  bool _isLoadingBranches = false;
  String? _selectedBranchCode;
  String? _selectedBranchName;
  String? _selectedCityCode;
  String? _selectedProvinceCode;
  String? _selectedBranchId;
  OverlayEntry? _branchOverlayEntry;
  final LayerLink _branchLayerLink = LayerLink();

  Map<String, File?> _tempFiles = {};
  Map<String, String?> _mediaIds = {};

  String? _selectedProvince;
  String? _selectedCity;
  String? _selectedArea;
  List<Map<String, dynamic>> _provinces = [];
  List<Map<String, dynamic>> _cities = [];
  List<Map<String, dynamic>> _areas = [];
  bool _isProvinceExpanded = false;
  bool _isCityExpanded = false;
  bool _isAreaExpanded = false;
  final LayerLink _provinceLayerLink = LayerLink();
  final LayerLink _cityLayerLink = LayerLink();
  final LayerLink _areaLayerLink = LayerLink();
  OverlayEntry? _provinceOverlayEntry;
  OverlayEntry? _cityOverlayEntry;
  OverlayEntry? _areaOverlayEntry;
  BankInfo? selectedBank;

  TextEditingController businessLicenseNumberController =
  TextEditingController();
  TextEditingController merchantNameController = TextEditingController();
  TextEditingController legalPersonController = TextEditingController();
  TextEditingController companyAddressController = TextEditingController();

  String? startDate;
  String? endDate;
  bool isLongTerm = false;

List<BankBranchResult> _bankBranches = [];
int _branchOffset = 0;
final int _branchLimit = 20;
bool _hasMoreBranches = true;
bool _isLoadingMoreBranches = false;
ScrollController _branchScrollController = ScrollController();

  void _initProvinces() {
    _provinces = City.CITY_LIST;
  }

  void _initializeFinanceType() {
    if (widget.merchantWeChatData.financeType != null) {
      selectedFinanceType = FinanceInstitutionTypeExt.getType(
          widget.merchantWeChatData.financeType!);
    }
  }

  void _showProvinceList() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('选择省份'),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _provinces.length,
              itemBuilder: (context, index) {
                final province = _provinces[index];
                return ListTile(
                  title: Text(province['name']),
                  onTap: () async {
                    Navigator.pop(context);
                    // 获取默认编码（原始代码中的方式）
                    final defaultCode =
                        province['code'].substring(0, 2) + '0000';

                    // 无论API是否成功，都先设置默认编码
                    weChatMerchantInfo.accountInfo ??= AccountInfo();
                    weChatMerchantInfo.accountInfo!.bankAddressCode =
                        defaultCode;

                    // 获取省份列表
                    final provinces = await MerchantApi().getProvinces();

                    if (provinces != null) {
                      // 查找匹配的省份
                      final matchedProvince = provinces.firstWhere(
                        (p) => p.provinceName == province['name'],
                        orElse: () => ProvinceResult(
                            provinceName: '', provinceCode: defaultCode),
                      );

                      // 使用API返回的省份编码（如果有）
                      _selectedProvinceCode = matchedProvince.provinceCode;

                      // 获取城市列表
                      final cities =
                          await MerchantApi().getCities(_selectedProvinceCode!);

                      setState(() {
                        _selectedProvince = province['name'];
                        _selectedCity = null;
                        _selectedArea = null;
                        _cities = province['areaList'] ?? [];
                        //_cities = cities ?.map((city) => { 'name': city.cityName, 'code': city.cityCode }) .toList() ?? [];
                        _areas = [];
                      });
                    } else {
                      // API调用失败时
                      setState(() {
                        _selectedProvince = province['name'];
                        _selectedCity = null;
                        _selectedArea = null;
                        _cities = province['areaList'] ?? [];
                        _areas = [];
                      });
                    }
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showCityList() {
    if (_selectedProvince == null || _cities.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('选择城市'),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _cities.length,
              itemBuilder: (context, index) {
                final city = _cities[index];
                return ListTile(
                  title: Text(city['name']),
                  onTap: () async {
                    Navigator.pop(context);
                    // 设置6位城市编码：前4位 + "00"
                    weChatMerchantInfo.accountInfo ??= AccountInfo();
                    weChatMerchantInfo.accountInfo!.bankAddressCode =
                        city['code'].substring(0, 4) + '00';

                    final cities =
                        await MerchantApi().getCities(_selectedProvinceCode!);

                    if (cities != null) {
                      final matchedCity = cities.firstWhere(
                        (c) => c.cityName == city['name'],
                        orElse: () =>
                            CityResult(cityName: '', cityCode: city['code']),
                      );
                      _selectedCityCode = matchedCity.cityCode;
                      setState(() {
                        _selectedCity = city['name'];
                        _selectedArea = null;
                        _areas = city['cityAreaList'] ?? [];
                      });
                    }
                    setState(() {
                      _selectedCity = city['name'];
                      _selectedArea = null;
                      _areas = city['cityAreaList'] ?? [];
                    });
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showAreaList() {
    if (_selectedCity == null || _areas.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('选择区县'),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _areas.length,
              itemBuilder: (context, index) {
                final area = _areas[index];
                return ListTile(
                  title: Text(area['name']),
                  onTap: () async {
                    Navigator.pop(context);

                    setState(() {
                      _selectedArea = area['name'];
                      // 设置6位区县编码：直接使用区县代码
                      weChatMerchantInfo.accountInfo ??= AccountInfo();
                      weChatMerchantInfo.accountInfo!.bankAddressCode =
                          area['code'];
                      //_selectedCityCode =
                      //    weChatMerchantInfo.accountInfo!.bankAddressCode;
                    });
                    // 2. 获取银行支行信息
                    final List<BankBranchResult>? branches =
                        await MerchantApi().getBankBranches(
                      bankAliasCode: _selectedBankCode!,
                      cityCode: _selectedCityCode!,
                    );

                    // 3. 处理返回的支行数据
                    if (branches == null) {
                    } else if (branches.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('该城市下没有找到支行信息')),
                      );
                    }
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _removeAllOverlays() {
    _provinceOverlayEntry?.remove();
    _cityOverlayEntry?.remove();
    _areaOverlayEntry?.remove();
    _branchOverlayEntry?.remove();
    _provinceOverlayEntry = null;
    _cityOverlayEntry = null;
    _areaOverlayEntry = null;
    _branchOverlayEntry = null;
  }

  List<BankInfo> _bankList = [];
  bool _isLoadingBanks = false;
  String? _selectedBankCode;
  String? _selectedBankName;
  bool _selectedNeedBankBranch = true;

  TextEditingController wechatAccountController = TextEditingController();
  WeChatMerchantInfo weChatMerchantInfo = WeChatMerchantInfo()
    ..idHolderType = 'LEGAL'; // 默认值为法人
  String? selectedOrganizationType;
  bool isFinanceInstitution = false;
  String? selectedCertificateType;
  FinanceInstitutionType? selectedFinanceType;
  bool isLegalPerson = true;

  final List<Map<String, String>> organizationTypes =
      OrganizationType.organizationTypes;
  final List<Map<String, String>> certificateTypes =
      CertificateType.certificateTypes;

  // 在State类中添加分页相关变量
  int _bankOffset = 0;
  final int _bankLimit = 20;
  bool _hasMoreBanks = true;

  // 添加这个方法到状态类中

// 在State类中添加
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();


    businessLicenseNumberController = TextEditingController(
      text: weChatMerchantInfo.businessLicenseInfo?.businessLicenseNumber ?? '',
    );
    merchantNameController = TextEditingController(
        text: weChatMerchantInfo.businessLicenseInfo?.merchantName ?? '');

    legalPersonController = TextEditingController(
        text: weChatMerchantInfo.businessLicenseInfo?.legalPerson ?? '');

    companyAddressController = TextEditingController(
        text: weChatMerchantInfo.businessLicenseInfo?.companyAddress ?? '');

    _scrollController.addListener(_scrollListener);
    _branchScrollController.addListener(_branchScrollListener);

    if (widget.merchantWeChatData.organizationType != null) {
      selectedOrganizationType = widget.merchantWeChatData.organizationType;
    }//主体类型
    if (widget.merchantWeChatData.isFinanceInstitution == 1) {
      isFinanceInstitution = true;
    }//是否金融机构
    if (widget.merchantWeChatData.certType != null) {
      selectedCertificateType = widget.merchantWeChatData.certType;
    }//营业执照信息/证书类型
    if (widget.merchantWeChatData.licenseCopyUrl != null) {
      //_tempBusinessLicenseFile = widget.merchantWeChatData.licenseCopyUrl;
      weChatMerchantInfo.businessLicenseInfo ??= BusinessLicenseInfo();
      weChatMerchantInfo.businessLicenseInfo!.businessLicenseCopy = widget.merchantWeChatData.licenseCopyUrl;
    }//营业执照信息/营业执照扫描件
    if (widget.merchantWeChatData.licenseNumber != null) {
      businessLicenseNumberController.text = widget.merchantWeChatData.licenseNumber!;
    }//营业执照信息/营业执照注册号
    if (widget.merchantWeChatData.merchantName != null) {
      //weChatMerchantInfo.businessLicenseInfo ??= BusinessLicenseInfo();
      merchantNameController.text = widget.merchantWeChatData.licenseNumber ?? '';
    }//营业执照信息/商户名称
    if (widget.merchantWeChatData.legalPerson != null) {
      merchantNameController.text = widget.merchantWeChatData.legalPerson!;
    }//营业执照信息/经营者/法定代表人姓名
    if (widget.merchantWeChatData.companyAddress != null) {
      companyAddressController.text = widget.merchantWeChatData.companyAddress!;
    }//营业执照信息/注册地址
    if (widget.merchantWeChatData.businessTime != null) {
      weChatMerchantInfo.businessLicenseInfo ??= BusinessLicenseInfo();
      weChatMerchantInfo.businessLicenseInfo!.businessTime = 
        widget.merchantWeChatData.businessTime;
      try {
        if (widget.merchantWeChatData.businessTime == "长期") {
          isLongTerm = true;
        } else {
          final jsonString = widget.merchantWeChatData.businessTime!;
          final dates = jsonDecode(jsonString) as List;
          startDate = dates[0].toString().replaceAll('"', '');
          if (dates[1].toString() == "长期") {
            endDate = "长期";
            isLongTerm = true;
          } else {
            endDate = dates[1].toString().replaceAll('"', '');
          }
        }
      } catch (e) {
        print("营业期限数据解析错误: $e");
      }
    }//营业执照信息/营业期限
    _initializeFinanceType();
    //金融机构许可证信息/金融机构类型
    if (widget.merchantWeChatData.financeLicenseUrls != null) {
      weChatMerchantInfo.financeInstitutionInfo ??= FinanceInstitutionInfo();
      weChatMerchantInfo.financeInstitutionInfo!.financeLicensePics = 
        widget.merchantWeChatData.financeLicenseUrls;
    } //金融机构许可证信息/金融机构许可证图片
    if (widget.merchantWeChatData.idHolderType != null) {
      weChatMerchantInfo.idHolderType = widget.merchantWeChatData.idHolderType!;
    }//证件持有人类型
    if (widget.merchantWeChatData.idDocType != null) {
      weChatMerchantInfo.idDocType = widget.merchantWeChatData.idDocType!;
    }//经营者/法人证件类型
    if (widget.merchantWeChatData.authorizeLetterUrl != null) {
      weChatMerchantInfo.authorizeLetterCopy = widget.merchantWeChatData.authorizeLetterUrl!;
    }//法定代表人说明函
    if (widget.merchantWeChatData.idCardUrl != null || 
        widget.merchantWeChatData.idCardNationalUrl != null ||
        widget.merchantWeChatData.idCardName != null ||
        widget.merchantWeChatData.idCardNumber  != null  ||
        widget.merchantWeChatData.idCardValidTimeBegin != null ||
        widget.merchantWeChatData.idCardValidTimeEnd != null) {
      weChatMerchantInfo.idCardInfo ??= IdCardInfo(); // 确保idCardInfo不为null
      if (widget.merchantWeChatData.idCardUrl != null) {
        weChatMerchantInfo.idCardInfo!.idCardCopyUrl = widget.merchantWeChatData.idCardUrl!;
      }
      if (widget.merchantWeChatData.idCardNationalUrl != null) {
        weChatMerchantInfo.idCardInfo!.idCardNational = widget.merchantWeChatData.idCardNationalUrl!;
      }
      if (widget.merchantWeChatData.idCardName != null) {
        weChatMerchantInfo.idCardInfo!.idCardName = widget.merchantWeChatData.idCardName!;
      }
      if (widget.merchantWeChatData.idCardNumber != null) {
        weChatMerchantInfo.idCardInfo!.idCardNumber = widget.merchantWeChatData.idCardNumber!;
      }
      if (widget.merchantWeChatData.idCardValidTimeBegin != null) {
        weChatMerchantInfo.idCardInfo!.idCardValidTimeBegin = widget.merchantWeChatData.idCardValidTimeBegin!;
      }
      if (widget.merchantWeChatData.idCardValidTimeEnd != null) {
        weChatMerchantInfo.idCardInfo!.idCardValidTime = widget.merchantWeChatData.idCardValidTimeEnd!;
      }
    }//经营者/法人身份证信息
    if (widget.merchantWeChatData.idDocName != null || 
        widget.merchantWeChatData.idDocNumber != null ||
        widget.merchantWeChatData.idDocCopyUrl != null ||
        widget.merchantWeChatData.idDocCopyBackUrl  != null  ||
        widget.merchantWeChatData.idDocPeriodBegin != null ||
        widget.merchantWeChatData.idDocPeriodEnd != null) {
      weChatMerchantInfo.idDocInfo ??= IdDocInfo(); 
      if (widget.merchantWeChatData.idDocName != null) {
        weChatMerchantInfo.idDocInfo!.idDocName = widget.merchantWeChatData.idDocName!;
      }
      if (widget.merchantWeChatData.idDocNumber != null) {
        weChatMerchantInfo.idDocInfo!.idDocNumber = widget.merchantWeChatData.idDocNumber!;
      }
      if (widget.merchantWeChatData.idDocCopyUrl != null) {
        weChatMerchantInfo.idDocInfo!.idDocCopy = widget.merchantWeChatData.idDocCopyUrl!;
      }
      if (widget.merchantWeChatData.idDocCopyBackUrl != null) {
        weChatMerchantInfo.idDocInfo!.idDocCopyBack = widget.merchantWeChatData.idDocCopyBackUrl!;
      }
      if (widget.merchantWeChatData.idDocPeriodBegin != null) {
        weChatMerchantInfo.idDocInfo!.docPeriodBegin = widget.merchantWeChatData.idDocPeriodBegin!;
      }
      if (widget.merchantWeChatData.idDocPeriodEnd != null) {
        weChatMerchantInfo.idDocInfo!.docPeriodEnd = widget.merchantWeChatData.idDocPeriodEnd!;
      }
    }//经营者/法人其他类型证件信息
    if (widget.merchantWeChatData.isOwnner != null) {
      weChatMerchantInfo.owner = widget.merchantWeChatData.isOwnner!;
    }//经营者/法人是否为受益人
   

    // 最终受益人信息列表



    if (widget.merchantWeChatData.bankAccountType != null ||
        widget.merchantWeChatData.accountBankName != null ||
        widget.merchantWeChatData.accountPersonName != null ||
        widget.merchantWeChatData.bankAddressCode != null ||
        widget.merchantWeChatData.bankBranchId != null ||
        widget.merchantWeChatData.bankFullName != null ||
        widget.merchantWeChatData.accountNumber != null 
    ){
      weChatMerchantInfo.accountInfo ??= AccountInfo();
      if (widget.merchantWeChatData.bankAccountType != null) {
        weChatMerchantInfo.accountInfo!.bankAccountType = widget.merchantWeChatData.bankAccountType!;
      }
      if (widget.merchantWeChatData.accountBankName != null) {
        _selectedBankCode = weChatMerchantInfo.accountInfo!.accountBank;
        _selectedBankName = widget.merchantWeChatData.accountBankName!;
      }
      if (widget.merchantWeChatData.accountPersonName != null) {
        weChatMerchantInfo.accountInfo!.accountName = widget.merchantWeChatData.accountPersonName!;
      }
      if (widget.merchantWeChatData.bankAddressCode != null) {
        _initAddressFromCode(widget.merchantWeChatData.bankAddressCode!);
      }
      if (widget.merchantWeChatData.bankBranchId != null) {
        weChatMerchantInfo.accountInfo!.bankBranchId = widget.merchantWeChatData.bankBranchId!;
      }
      if (widget.merchantWeChatData.bankFullName != null) {
        weChatMerchantInfo.accountInfo!.bankName = widget.merchantWeChatData.bankFullName!;
      }
      if (widget.merchantWeChatData.accountNumber != null) {
        weChatMerchantInfo.accountInfo!.accountNumber = widget.merchantWeChatData.accountNumber!;
      }
    }//结算账户信息
    if (widget.merchantWeChatData.contactType != null ||
        widget.merchantWeChatData.contactName != null ||
        widget.merchantWeChatData.contactIdDocType != null ||
        widget.merchantWeChatData.contactIdDocNumber != null ||
        widget.merchantWeChatData.contactIdDocCopyUrl != null ||
        widget.merchantWeChatData.contactIdDocCopyBackUrl != null ||
        widget.merchantWeChatData.contactIdDocPeriodBegin != null ||
        widget.merchantWeChatData.contactIdDocPeriodEnd != null ||
        widget.merchantWeChatData.businessAuthorizeLetterUrl != null ||
        widget.merchantWeChatData.contactMobilePhone != null
    ){
      weChatMerchantInfo.contactInfo ??= ContactInfo();
      if (widget.merchantWeChatData.contactType != null) {
        weChatMerchantInfo.contactInfo!.contactType = widget.merchantWeChatData.contactType!;
      }
      if (widget.merchantWeChatData.contactName != null) {
        weChatMerchantInfo.contactInfo!.contactName = widget.merchantWeChatData.contactName!;
      }
      if (widget.merchantWeChatData.contactIdDocType != null) {
        weChatMerchantInfo.contactInfo!.contactIdDocType = widget.merchantWeChatData.contactIdDocType!;
      }
      if (widget.merchantWeChatData.contactIdDocNumber != null) {
        weChatMerchantInfo.contactInfo!.contactIdCardNumber = widget.merchantWeChatData.contactIdDocNumber!;
      }
      if (widget.merchantWeChatData.contactIdDocCopyUrl != null) {
        weChatMerchantInfo.contactInfo!.contactIdDocCopy = widget.merchantWeChatData.contactIdDocCopyUrl!;
      }
      if (widget.merchantWeChatData.contactIdDocCopyBackUrl != null) {
        weChatMerchantInfo.contactInfo!.contactIdDocCopyBack = widget.merchantWeChatData.contactIdDocCopyBackUrl!;
      }
      if (widget.merchantWeChatData.contactIdDocPeriodBegin != null) {
        weChatMerchantInfo.contactInfo!.contactPeriodBegin = widget.merchantWeChatData.contactIdDocPeriodBegin!;
      }
      if (widget.merchantWeChatData.contactIdDocPeriodEnd != null) {
        weChatMerchantInfo.contactInfo!.contactPeriodEnd = widget.merchantWeChatData.contactIdDocPeriodEnd!;
      }
      if (widget.merchantWeChatData.businessAuthorizeLetterUrl != null) {
        weChatMerchantInfo.contactInfo!.businessAuthorizationLetter = widget.merchantWeChatData.businessAuthorizeLetterUrl!;
      }
      if (widget.merchantWeChatData.contactMobilePhone != null) {
        weChatMerchantInfo.contactInfo!.mobilePhone = widget.merchantWeChatData.contactMobilePhone!;
      }
    }//超级管理员信息
    if (widget.merchantWeChatData.storeName != null ||
        widget.merchantWeChatData.storeUrl != null ||
        widget.merchantWeChatData.storeQrCode != null ||
        widget.merchantWeChatData.miniProgramSubAppid != null 
    ){
      weChatMerchantInfo.salesSceneInfo ??= SalesSceneInfo();
      if (widget.merchantWeChatData.storeName != null) {
        weChatMerchantInfo.salesSceneInfo!.storeName = widget.merchantWeChatData.storeName!;
      }
      if (widget.merchantWeChatData.storeUrl != null) {
        weChatMerchantInfo.salesSceneInfo!.storeUrl = widget.merchantWeChatData.storeUrl!;
      }
      if (widget.merchantWeChatData.storeQrCode != null) {
        weChatMerchantInfo.salesSceneInfo!.storeQrCode = widget.merchantWeChatData.storeQrCode!;
      }
      if (widget.merchantWeChatData.miniProgramSubAppid != null) {
        weChatMerchantInfo.salesSceneInfo!.miniProgramSubAppid = widget.merchantWeChatData.miniProgramSubAppid!;
      }
    }//经营场景信息
    if (widget.merchantWeChatData.settlementId != null ||
        widget.merchantWeChatData.qualificationType != null 
    ){
      weChatMerchantInfo.settlementInfo ??= SettlementInfo();
      if (widget.merchantWeChatData.settlementId != null) {
        weChatMerchantInfo.settlementInfo!.settlementId = widget.merchantWeChatData.settlementId!;
      }
      if (widget.merchantWeChatData.qualificationType != null) {
        weChatMerchantInfo.settlementInfo!.qualificationType = widget.merchantWeChatData.qualificationType!;
      }
    }//结算规则
    if (widget.merchantWeChatData.merchantShortName != null
    ){
      weChatMerchantInfo.merchantShortname = widget.merchantWeChatData.merchantShortName!;
    }//商户简称
    if (widget.merchantWeChatData.qualificationUrls != null
    ){
      weChatMerchantInfo.qualifications = widget.merchantWeChatData.qualificationUrls!;
    }//特殊资质
    if (widget.merchantWeChatData.businessAdditionPicUrls != null 
    ){
      weChatMerchantInfo.businessAdditionPics = widget.merchantWeChatData.businessAdditionPicUrls!;
    }//补充材料
    if (widget.merchantWeChatData.businessAdditionDesc != null
    ){
      weChatMerchantInfo.businessAdditionDesc = widget.merchantWeChatData.businessAdditionDesc!;
    }//补充说明

    _fetchBanks();
    _initProvinces(); // 初始化省份数据
  }

void _initAddressFromCode(String bankAddressCode) {
  if (bankAddressCode.length != 6) return;
  
  // 解析省份代码 (前2位)
  final provinceCode = bankAddressCode.substring(0, 2) + '0000';
  
  // 解析城市代码 (前4位)
  final cityCode = bankAddressCode.substring(0, 4) + '00';
  
  // 在省份列表中查找
  final province = _provinces.firstWhere(
    (p) => p['code'] == provinceCode,
    orElse: () => {'name': null, 'code': null},
  );
  
  if (province['name'] != null) {
    setState(() {
      _selectedProvince = province['name'];
      _selectedProvinceCode = provinceCode;
      _cities = province['areaList'] ?? [];
    });
    
    // 在城市列表中查找
    final city = _cities.firstWhere(
      (c) => c['code'] == cityCode,
      orElse: () => {'name': null, 'code': null},
    );
    
    if (city['name'] != null) {
      setState(() {
        _selectedCity = city['name'];
        _selectedCityCode = cityCode;
        _areas = city['cityAreaList'] ?? [];
      });
      
      // 在区县列表中查找
      final area = _areas.firstWhere(
        (a) => a['code'] == bankAddressCode,
        orElse: () => {'name': null, 'code': null},
      );
      
      if (area['name'] != null) {
        setState(() {
          _selectedArea = area['name'];
        });
      }
    }
  }
}

  @override
  void dispose() {
    _scrollController.dispose();
    _branchScrollController.dispose();
    _removeOverlay();
    businessLicenseNumberController.dispose();
    merchantNameController.dispose();
    legalPersonController.dispose();
    companyAddressController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore &&
        _hasMoreBanks) {
      _fetchBanks(loadMore: true);
    }
  }

  void _showBankList() {
  // 重置分页状态
  _bankOffset = 0;
  _hasMoreBanks = true;
  _bankList.clear();

  _removeOverlay();

  _overlayEntry = OverlayEntry(
    builder: (context) => GestureDetector(
      onTap: _removeOverlay,
      behavior: HitTestBehavior.translucent,
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.only(top: 100),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          '请选择银行',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (scrollNotification) {
                            if (scrollNotification is ScrollEndNotification &&
                                _scrollController.position.pixels ==
                                    _scrollController.position.maxScrollExtent &&
                                !_isLoadingMore &&
                                _hasMoreBanks) {
                              _fetchBanks(loadMore: true);
                            }
                            return false;
                          },
                          child: _buildBankListPopup(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    ),
  );

  Overlay.of(context).insert(_overlayEntry!);
  _fetchBanks();
}

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

void _branchScrollListener() {
  if (_branchScrollController.position.pixels == 
      _branchScrollController.position.maxScrollExtent &&
      !_isLoadingMoreBranches && 
      _hasMoreBranches) {
    _fetchBranches(loadMore: true);
  }
}
  @override
  Widget build(BuildContext context) {
    final bool showCertificateAndLicense = selectedOrganizationType == '4' ||
        selectedOrganizationType == '2' ||
        selectedOrganizationType == '3' ||
        selectedOrganizationType == '2502' ||
        selectedOrganizationType == '1708';

    final bool showIdHolderType = selectedOrganizationType == '3' ||
        selectedOrganizationType == '2502'; // 政府机关或事业单位时显示

    final bool companyType = selectedOrganizationType == '2';// 企业时显示
  
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        color: ThemeUtil.backgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CommonHeader(
              center: Text('微信商户申请',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                physics: const ClampingScrollPhysics(),
                children: [
                  _buildOrganizationTypeWidget(),
                  if (showCertificateAndLicense) _buildCertificateTypeWidget(),
                  if (showCertificateAndLicense)
                    _buildBusinessLicenseNumberWidget(),
                  if (showCertificateAndLicense) _buildMerchantNameWidget(),
                  if (showCertificateAndLicense) _buildLegalPersonWidget(),
                  if (showCertificateAndLicense) _buildCompanyAddressWidget(),
                  if (showCertificateAndLicense) _buildBusinessTimeWidget(),
                  if (companyType) _buildOwnerWidget(),
                  _buildFinanceInstitutionWidget(),
                  if (isFinanceInstitution)
                    _buildFinanceTypeWidget(), // 新增：显示金融机构类型输入
                  if (isFinanceInstitution)
                    _buildFinanceLicenseWidget(), // 新增：显示金融机构类型输入
                  if (showIdHolderType) _buildIdHolderTypeWidget(),
                  if (weChatMerchantInfo.idHolderType == 'LEGAL')
                    _buildIdDocTypeWidget(),
                  _buildIdCardInfoWidget(),
                  _buildOtherIdDocInfoWidget(),
                  _builDauthorizeLetterCopyWidget(),
                  _buildAccountInfoWidget(),
                  _buildContactInfoWidget(),
                  _buildSalesSceneInfoWidget(),
                  _buildMerchantShortNameWidget(),
                  _buildQualificationsWidget(),
                  _buildSubmitWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificateTypeWidget() {

    String hintText;
    List<Map<String, String>> availableCertificateTypes = [];

    if (selectedOrganizationType == '4' || selectedOrganizationType == '2') {
      hintText = '请上传营业执照';
    } else if (selectedOrganizationType == '3' ||
        selectedOrganizationType == '2502' ||
        selectedOrganizationType == '1708') {
      hintText = '请上传登记证书';
      if (selectedOrganizationType == '3') {
        availableCertificateTypes = certificateTypes
            .where((type) => type['value'] == 'CERTIFICATE_TYPE_2388')
            .toList();
      } else if (selectedOrganizationType == '2502') {
        availableCertificateTypes = certificateTypes
            .where((type) => type['value'] == 'CERTIFICATE_TYPE_2389')
            .toList();
      } else if (selectedOrganizationType == '1708') {
        availableCertificateTypes = certificateTypes;
      }
    } else {
      hintText = '请上传证件照片';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (availableCertificateTypes.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '证书类型',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: DropdownButton<String>(
                  value: selectedCertificateType,
                  isExpanded: true,
                  underline: const SizedBox(),
                  hint: const Text('请选择证书类型',
                      style: TextStyle(color: Colors.grey)),
                  items:
                      availableCertificateTypes.map((Map<String, String> type) {
                    return DropdownMenuItem<String>(
                      value: type['value'],
                      child: Text(type['label'] ?? ''),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedCertificateType = value;
                      weChatMerchantInfo.idDocType = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        Text(
          hintText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            // 1. 检查权限
            bool hasPermission = await PermissionUtil().requestPermission(
              context: context,
              permission: Permission.storage,
              info: '希望获取存储权限用于选择证件照片',
            );

            if (!hasPermission) return;

            // 2. 选择图片
            final List<AssetEntity>? results = await AssetPicker.pickAssets(
              context,
              pickerConfig: ImageUtil.buildDefaultImagePickerConfig(),
            );

            if (results == null || results.isEmpty) return;

            File? file = await results.first.file;
            if (file == null) return;

            // 3. 立即显示临时图片
            setState(() => _tempBusinessLicenseFile = file);

            // 4. 调用API上传
            String? mediaId = await MerchantApi().uploadMerchantFile(
              file: file,
              filename: file.path.split('/').last,
              onError: (error) {
                ToastUtil.error('上传失败');
                setState(() => _tempBusinessLicenseFile = null);
              },
            );

            // 5. 上传成功后的处理
            if (mediaId != null) {
              setState(() {
                weChatMerchantInfo.businessLicenseInfo ??=
                    BusinessLicenseInfo();
                weChatMerchantInfo.businessLicenseInfo!.businessLicenseCopy =
                    mediaId;
                // 保留临时文件直到页面刷新或关闭
              });
            }
          },
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: _buildImageDisplay(
              tempFile: _tempBusinessLicenseFile,
              networkUrl:
                  weChatMerchantInfo.businessLicenseInfo?.businessLicenseCopy,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildImageDisplay({File? tempFile, String? networkUrl}) {
    if (tempFile != null) {
      return Image.file(tempFile, fit: BoxFit.cover);
    } else if (networkUrl != null) {
      return FutureBuilder(
        future: _checkImageUrl(networkUrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data == true) {
            return Image.network(getFullUrl(networkUrl), fit: BoxFit.cover);
          } else {
            return _buildUploadPlaceholder();
          }
        },
      );
    } else {
      return _buildUploadPlaceholder();
    }
  }

  Future<bool> _checkImageUrl(String url) async {
    try {
      final response = await Dio().head(getFullUrl(url));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Widget _buildUploadPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.add_a_photo, size: 40),
          Text('点击上传照片'),
        ],
      ),
    );
  }

  Widget _buildFinanceInstitutionWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '是否为金融机构',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              const Text('是'),
              Checkbox(
                value: isFinanceInstitution,
                onChanged: (bool? value) {
                  setState(() {
                    isFinanceInstitution = value ?? false;
                    weChatMerchantInfo.financeInstitution = value;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildOrganizationTypeWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '主体类型',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: DropdownButton<String>(
            value: selectedOrganizationType,
            isExpanded: true,
            underline: const SizedBox(),
            hint: const Text('请选择主体类型', style: TextStyle(color: Colors.grey)),
            items: organizationTypes.map((Map<String, String> type) {
              return DropdownMenuItem<String>(
                value: type['value'],
                child: Text(type['label'] ?? ''),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                selectedOrganizationType = value;
                weChatMerchantInfo.organizationType = value;
                weChatMerchantInfo.idDocType = null;
              });
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBusinessLicenseNumberWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '执照注册号',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: TextFormField(
            controller: businessLicenseNumberController,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: '请输入注册号/统一社会信用代码',
              hintStyle: TextStyle(color: Colors.grey),
            ),
            //maxLength: 30,
            onChanged: (value) {
              weChatMerchantInfo.businessLicenseInfo?.businessLicenseNumber =
                  value;
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSubmitWidget() {

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
      child: GestureDetector(
        onTap: () async {
          bool isValid = true;
          String errorMessage = '';

          // 1. Validate organization type
          if (selectedOrganizationType == null) {
            isValid = false;
            errorMessage = '请选择主体类型';
          } else {
            final orgType = OrganizationType.getType(selectedOrganizationType!);
            if (orgType == null) {
              isValid = false;
              errorMessage = '不支持的主体类型';
            }
          }

          // 2. Validate business license info based on organization type
          if (isValid &&
              (selectedOrganizationType == '4' || // 个体工商户
                  selectedOrganizationType == '2' || // 企业
                  selectedOrganizationType == '3' || // 政府机关
                  selectedOrganizationType == '2502' || // 事业单位
                  selectedOrganizationType == '1708')) {
            // 社会组织

            if (weChatMerchantInfo.businessLicenseInfo == null) {
              isValid = false;
              errorMessage = '需要填写营业执照信息';
            } else {
              final bizInfo = weChatMerchantInfo.businessLicenseInfo!;

              // Validate certificate type for specific organization types
              if (selectedOrganizationType == '3' || // 政府机关
                  selectedOrganizationType == '2502') {
                // 事业单位
                if (bizInfo.certType == null) {
                  isValid = false;
                  errorMessage = selectedOrganizationType == '3'
                      ? '政府机关必须使用统一社会信用代码证书'
                      : '事业单位必须使用事业单位法人证书';
                }
              }

              // Validate required fields
              if (bizInfo.businessLicenseCopy == null) {
                isValid = false;
                errorMessage = '请上传营业执照/登记证书照片';
              } else if (bizInfo.businessLicenseNumber == null ||
                  bizInfo.businessLicenseNumber!.isEmpty) {
                isValid = false;
                errorMessage = '请输入执照注册号/统一社会信用代码';
              } else if (bizInfo.merchantName == null ||
                  bizInfo.merchantName!.isEmpty) {
                isValid = false;
                errorMessage = '请输入商户名称';
              } else if (bizInfo.legalPerson == null ||
                  bizInfo.legalPerson!.isEmpty) {
                isValid = false;
                errorMessage = '请输入法定代表人姓名';
              } else if (bizInfo.companyAddress == null ||
                  bizInfo.companyAddress!.isEmpty) {
                isValid = false;
                errorMessage = '请输入注册地址';
              } else if (bizInfo.businessTime == null ||
                  bizInfo.businessTime!.isEmpty) {
                isValid = false;
                errorMessage = '请选择营业期限';
              }
            }
          }

          // 3. Validate finance institution info if applicable
          if (isValid && isFinanceInstitution) {
            if (selectedFinanceType == null) {
              isValid = false;
              errorMessage = '请选择金融机构类型';
            } else if (weChatMerchantInfo
                    .financeInstitutionInfo?.financeLicensePics ==
                null) {
              isValid = false;
              errorMessage = '请上传金融机构许可证';
            }
          }

          // 4. Validate ID holder info
          if (isValid) {
            if (weChatMerchantInfo.idHolderType == 'LEGAL') {
              // Validate ID document type
              if (weChatMerchantInfo.idDocType == null) {
                isValid = false;
                errorMessage = '请选择证件类型';
              } else if (weChatMerchantInfo.idDocType ==
                  'IDENTIFICATION_TYPE_MAINLAND_IDCARD') {
                // Validate mainland ID card
                if (weChatMerchantInfo.idCardInfo?.idCardCopyUrl == null) {
                  isValid = false;
                  errorMessage = '请上传身份证人像面照片';
                } else if (weChatMerchantInfo.idCardInfo?.idCardNational ==
                    null) {
                  isValid = false;
                  errorMessage = '请上传身份证国徽面照片';
                } else if (weChatMerchantInfo.idCardInfo?.idCardName == null ||
                    weChatMerchantInfo.idCardInfo!.idCardName!.isEmpty) {
                  isValid = false;
                  errorMessage = '请输入身份证姓名';
                } else if (weChatMerchantInfo.idCardInfo?.idCardNumber ==
                        null ||
                    !RegExp(r'^\d{17}[\dXx]$').hasMatch(
                        weChatMerchantInfo.idCardInfo!.idCardNumber!)) {
                  isValid = false;
                  errorMessage = '请输入有效的身份证号码';
                } else if (weChatMerchantInfo
                            .idCardInfo?.idCardValidTimeBegin ==
                        null ||
                    weChatMerchantInfo
                        .idCardInfo!.idCardValidTimeBegin!.isEmpty) {
                  isValid = false;
                  errorMessage = '请选择身份证开始时间';
                } else if (weChatMerchantInfo.idCardInfo?.idCardValidTime ==
                        null ||
                    weChatMerchantInfo.idCardInfo!.idCardValidTime!.isEmpty) {
                  isValid = false;
                  errorMessage = '请选择身份证结束时间';
                }
              } else {
                // Validate other ID documents
                if (weChatMerchantInfo.idDocInfo?.idDocName == null ||
                    weChatMerchantInfo.idDocInfo!.idDocName!.isEmpty) {
                  isValid = false;
                  errorMessage = '请输入证件姓名';
                } else if (weChatMerchantInfo.idDocInfo?.idDocNumber == null ||
                    weChatMerchantInfo.idDocInfo!.idDocNumber!.isEmpty) {
                  isValid = false;
                  errorMessage = '请输入证件号码';
                } else if (weChatMerchantInfo.idDocInfo?.idDocCopy == null) {
                  isValid = false;
                  errorMessage = '请上传证件正面照片';
                } else if (weChatMerchantInfo.idDocType !=
                        'IDENTIFICATION_TYPE_OVERSEA_PASSPORT' &&
                    weChatMerchantInfo.idDocInfo?.idDocCopyBack == null) {
                  isValid = false;
                  errorMessage = '请上传证件反面照片';
                } else if (weChatMerchantInfo.idDocInfo?.docPeriodBegin ==
                        null ||
                    weChatMerchantInfo.idDocInfo!.docPeriodBegin!.isEmpty) {
                  isValid = false;
                  errorMessage = '请选择证件开始日期';
                } else if (weChatMerchantInfo.idDocInfo?.docPeriodEnd == null ||
                    weChatMerchantInfo.idDocInfo!.docPeriodEnd!.isEmpty) {
                  isValid = false;
                  errorMessage = '请选择证件结束日期';
                }
              }
            } else if (weChatMerchantInfo.idHolderType == 'SUPER') {
              // Validate authorize letter for super holder
              if (weChatMerchantInfo.authorizeLetterCopy == null) {
                isValid = false;
                errorMessage = '请上传法定代表人说明函';
              }
            }
          }

          // 5. Validate account info
          if (isValid) {
            if (weChatMerchantInfo.accountInfo?.bankAccountType == null) {
              isValid = false;
              errorMessage = '请选择账户类型';
            } else if (weChatMerchantInfo.accountInfo?.accountBank == null) {
              isValid = false;
              errorMessage = '请选择开户银行';
            } else if (weChatMerchantInfo.accountInfo?.accountName == null ||
                weChatMerchantInfo.accountInfo!.accountName!.isEmpty) {
              isValid = false;
              errorMessage = '请输入开户名称';
            } else if (weChatMerchantInfo.accountInfo?.accountNumber == null ||
                weChatMerchantInfo.accountInfo!.accountNumber!.isEmpty) {
              isValid = false;
              errorMessage = '请输入银行账号';
            } else if (weChatMerchantInfo.accountInfo?.bankName == null ||
                weChatMerchantInfo.accountInfo!.bankName!.isEmpty) {
              isValid = false;
              errorMessage = '请输入开户银行全称（含支行）';
            } else {
              // Validate account name matches ID or business name
              if (weChatMerchantInfo.accountInfo!.bankAccountType == '75') {
                // 对私账户
                final idName = weChatMerchantInfo.idHolderType == 'LEGAL'
                    ? (weChatMerchantInfo.idDocType ==
                            'IDENTIFICATION_TYPE_MAINLAND_IDCARD'
                        ? weChatMerchantInfo.idCardInfo?.idCardName
                        : weChatMerchantInfo.idDocInfo?.idDocName)
                    : null;

                if (idName != weChatMerchantInfo.accountInfo!.accountName) {
                  isValid = false;
                  errorMessage = '对私账户开户名称必须与身份证姓名一致';
                }
              } else {
                // 对公账户
                final bizName =
                    weChatMerchantInfo.businessLicenseInfo?.merchantName;
                if (bizName != weChatMerchantInfo.accountInfo!.accountName) {
                  isValid = false;
                  errorMessage = '对公账户开户名称必须与营业执照上的商户名称一致';
                }
              }
            }
          }
          // 6. Validate contact info
          if (isValid) {
            if (weChatMerchantInfo.contactInfo?.contactType == null) {
              isValid = false;
              errorMessage = '请选择超级管理员类型';
            } else if (weChatMerchantInfo.contactInfo?.contactName == null ||
                weChatMerchantInfo.contactInfo!.contactName!.isEmpty) {
              isValid = false;
              errorMessage = '请输入超级管理员姓名';
            } else if (weChatMerchantInfo.contactInfo?.mobilePhone == null ||
                weChatMerchantInfo.contactInfo!.mobilePhone!.isEmpty) {
              isValid = false;
              errorMessage = '请输入超级管理员手机';
            } else if (weChatMerchantInfo.contactInfo?.contactType == '66') {
              // 经办人
              if (weChatMerchantInfo.contactInfo?.contactIdDocType == null) {
                isValid = false;
                errorMessage = '请选择经办人证件类型';
              } else if (weChatMerchantInfo.contactInfo?.contactIdCardNumber ==
                      null ||
                  weChatMerchantInfo
                      .contactInfo!.contactIdCardNumber!.isEmpty) {
                isValid = false;
                errorMessage = '请输入经办人证件号码';
              } else if (weChatMerchantInfo.contactInfo?.contactIdDocCopy ==
                  null) {
                isValid = false;
                errorMessage = '请上传经办人证件正面照片';
              } else if (weChatMerchantInfo.contactInfo?.contactIdDocType !=
                      'IDENTIFICATION_TYPE_OVERSEA_PASSPORT' &&
                  weChatMerchantInfo.contactInfo?.contactIdDocCopyBack ==
                      null) {
                isValid = false;
                errorMessage = '请上传经办人证件反面照片';
              } else if (weChatMerchantInfo
                      .contactInfo?.businessAuthorizationLetter ==
                  null) {
                isValid = false;
                errorMessage = '请上传业务办理授权函';
              }
            }
          }
          // 7. Validate merchant short name
          if (isValid &&
              (weChatMerchantInfo.merchantShortname == null ||
                  weChatMerchantInfo.merchantShortname!.isEmpty)) {
            isValid = false;
            errorMessage = '请输入商户简称';
          }
          // 8. Special validation for personal sellers
          if (isValid &&
              selectedOrganizationType == '2500' &&
              (weChatMerchantInfo.businessAdditionDesc == null ||
                  weChatMerchantInfo.businessAdditionDesc!.isEmpty)) {
            isValid = false;
            errorMessage = '个人卖家必须填写补充说明';
          }
          if (!isValid) {
            ToastUtil.error(errorMessage);
            return;
          }
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          ); // 提交到后端
          try {
            final result = await MerchantApi().applyWeChatMerchant(
              weChatMerchantInfo: weChatMerchantInfo,
              onError: (error) {
                Navigator.pop(context); // 关闭加载中
                //ToastUtil.error(error.response?.data['message'] ?? '提交失败1');
                ToastUtil.error(error.error?.toString() ?? '提交失败');
              },
              onSuccess: (response) {
                Navigator.pop(context); // 关闭加载中
                ToastUtil.hint('提交成功');
               // Navigator.of(context).pop(); // 返回上一页
              },
            );

            if (!result) {
              //Navigator.pop(context); // 关闭加载中
              ToastUtil.error('提交失败3');
            }
          } catch (e) {
            Navigator.pop(context); // 关闭加载中
            ToastUtil.error('网络错误: $e');
          }
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(48, 0, 48, 0),
          decoration: const BoxDecoration(
            color: Colors.lightBlue,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          width: double.infinity,
          height: 48,
          alignment: Alignment.center,
          child: const Text('提 交',
              style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
      ),
    );
  }

  Widget _buildMerchantNameWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '商户名称',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: TextFormField(
            controller: merchantNameController,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: '请填写商户名称',
              hintStyle: TextStyle(color: Colors.grey),
            ),
            //maxLength: 30,
            onChanged: (value) {
              weChatMerchantInfo.businessLicenseInfo?.merchantName = value;
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLegalPersonWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '法定代表人',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: TextFormField(
            controller: legalPersonController,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: '请填写法定代表人姓名',
              hintStyle: TextStyle(color: Colors.grey),
            ),
            //maxLength: 30,
            onChanged: (value) {
              weChatMerchantInfo.businessLicenseInfo?.legalPerson = value;
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCompanyAddressWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '注册地址',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: TextFormField(
            controller: companyAddressController,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: '请填写注册地址',
              hintStyle: TextStyle(color: Colors.grey),
            ),
            //maxLength: 30,
            onChanged: (value) {
              weChatMerchantInfo.businessLicenseInfo?.companyAddress = value;
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
Widget _buildOwnerWidget() {

  return Column(
  );
}




Widget _buildBusinessTimeWidget() {
  // 解析营业时间数据
  final businessTime = weChatMerchantInfo.businessLicenseInfo?.businessTime;
  final parsedDates = _parseBusinessTime(businessTime);
  final startDate = parsedDates['start'];
  final endDate = parsedDates['end'];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildBusinessDateField(
        label: "营业开始日期",
        value: startDate,
        onChanged: (value) {
          setState(() {
            weChatMerchantInfo.businessLicenseInfo ??= BusinessLicenseInfo();
            _updateBusinessTime(value, endDate);
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) return '请选择开始日期';
          final date = DateTime.tryParse(value);
          if (date == null) return '日期格式不正确';
          if (date.isBefore(DateTime(1900, 1, 1))) {
            return '开始时间不能小于1900-01-01';
          }
          if (!date.isBefore(DateTime.now())) {
            return '开始时间必须小于当前日期';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      _buildBusinessDateField(
        label: "营业结束日期",
        value: endDate,
        onChanged: (value) {
          setState(() {
            weChatMerchantInfo.businessLicenseInfo ??= BusinessLicenseInfo();
            _updateBusinessTime(startDate, value);
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) return '请选择结束日期';
          if (value == '长期') return null;

          final endDate = DateTime.tryParse(value);
          if (endDate == null) return '日期格式不正确';

          if (startDate != null) {
            final start = DateTime.tryParse(startDate);
            if (start != null && endDate.isBefore(start)) {
              return '结束时间必须大于开始时间';
            }
          }
          return null;
        },
        allowLongTerm: true,
      ),
      const SizedBox(height: 16),
    ],
  );
}

Widget _buildBusinessDateField({
  required String label,
  required String? value,
  required Function(String) onChanged,
  required String? Function(String?) validator,
  bool allowLongTerm = false,
  String? startDate, // 添加startDate参数用于结束日期的范围限制
}) {
  final controller = TextEditingController(text: value);
  final focusNode = FocusNode();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      if (allowLongTerm && value == '长期')
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                onChanged('');
                controller.text = '';
              },
              child: const Text('选择日期'),
            ),
          ],
        )
      else
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                focusNode: focusNode,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'YYYY-MM-DD',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: value != null && value.isNotEmpty
                        ? DateTime.parse(value)
                        : DateTime.now(),
                    firstDate: label.contains('开始') 
                        ? DateTime(1900, 1, 1)
                        : (startDate != null && startDate.isNotEmpty
                            ? DateTime.parse(startDate).add(const Duration(days: 1))
                            : DateTime.now()),
                    lastDate: label.contains('开始') 
                        ? DateTime.now()
                        : DateTime(2100),
                  );
                  if (picked != null) {
                    final newValue = picked.toString().split(' ')[0];
                    onChanged(newValue);
                    controller.text = newValue;
                  }
                },
                validator: validator,
              ),
            ),
            if (allowLongTerm)
              TextButton(
                onPressed: () {
                  onChanged('长期');
                  controller.text = '长期';
                  focusNode.unfocus();
                  FocusScope.of(context).requestFocus(focusNode);
                },
                child: const Text('长期'),
              ),
          ],
        ),
    ],
  );
}
// 解析营业时间
Map<String, String?> _parseBusinessTime(String? businessTime) {
  if (businessTime == null) return {'start': null, 'end': null};
  
  try {
    // 处理格式如：[\\"2014-01-01\\",\\"长期\\"]
    final cleanStr = businessTime
        .replaceAll(r'\"', '"')
        .replaceAll(r'[', '')
        .replaceAll(r']', '')
        .split(',');
    
    return {
      'start': cleanStr[0].replaceAll('"', '').trim(),
      'end': cleanStr[1].replaceAll('"', '').trim(),
    };
  } catch (e) {
    return {'start': null, 'end': null};
  }
}

// 更新营业时间
void _updateBusinessTime(String? startDate, String? endDate) {
  final start = startDate ?? '';
  final end = endDate ?? '';
  
  // 生成符合要求的转义格式：[\\"2014-01-01\\",\\"长期\\"]
  weChatMerchantInfo.businessLicenseInfo!.businessTime = 
      '[\\"$start\\",\\"$end\\"]';
}

  Widget _buildFinanceTypeWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '金融机构类型',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: DropdownButton<FinanceInstitutionType>(
            value: selectedFinanceType,
            isExpanded: true,
            underline: const SizedBox(),
            hint: const Text('请选择金融机构类型', style: TextStyle(color: Colors.grey)),
            items: FinanceInstitutionType.values
                .map((FinanceInstitutionType type) {
              return DropdownMenuItem<FinanceInstitutionType>(
                value: type,
                child: Text(type.getDesc()),
              );
            }).toList(),
            onChanged: (FinanceInstitutionType? value) {
              setState(() {
                selectedFinanceType = value;
              });
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFinanceLicenseWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '金融机构许可证',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            // 1. 检查权限
            bool hasPermission = await PermissionUtil().requestPermission(
              context: context,
              permission: Permission.storage,
              info: '希望获取存储权限用于选择金融机构许可证照片',
            );

            if (!hasPermission) return;

            // 2. 选择图片
            //final List<AssetEntity>? results = await AssetPicker.pickAssets(context);
            final List<AssetEntity>? results = await AssetPicker.pickAssets(
              context,
              pickerConfig: ImageUtil.buildDefaultImagePickerConfig(),
            );

            if (results == null || results.isEmpty) return;

            File? file = await results.first.file;
            if (file == null) return;

            // 3. 立即显示临时图片
            setState(() => _tempFinanceLicenseFile = file);

            // 4. 调用API上传
            String? mediaId = await MerchantApi().uploadMerchantFile(
              file: file,
              filename: file.path.split('/').last,
              onError: (error) {
                ToastUtil.error('上传失败');
                setState(() => _tempFinanceLicenseFile = null);
              },
            );

            // 5. 上传成功后的处理
            if (mediaId != null) {
              setState(() {
                weChatMerchantInfo.financeInstitutionInfo ??=
                    FinanceInstitutionInfo();
                weChatMerchantInfo.financeInstitutionInfo!.financeLicensePics =
                    mediaId;
                // 保留临时文件直到页面刷新或关闭
              });
            }
          },
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: _buildImageDisplay(
              tempFile: _tempFinanceLicenseFile,
              networkUrl:
                  weChatMerchantInfo.financeInstitutionInfo?.financeLicensePics,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildIdHolderTypeWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '证件持有人',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  Radio<String>(
                    value: 'LEGAL',
                    groupValue: weChatMerchantInfo.idHolderType,
                    onChanged: (String? value) {
                      setState(() {
                        weChatMerchantInfo.idHolderType = value!;
                      });
                    },
                  ),
                  const Text('法人'),
                ],
              ),
              Row(
                children: [
                  Radio<String>(
                    value: 'SUPER',
                    groupValue: weChatMerchantInfo.idHolderType,
                    onChanged: (String? value) {
                      setState(() {
                        weChatMerchantInfo.idHolderType = value!;
                      });
                    },
                  ),
                  const Text('经办人'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// 经营者/法人证件类型选择组件
  Widget _buildIdDocTypeWidget() {
    // 如果证件持有人类型不是经营者/法人，则不显示该组件
    if (weChatMerchantInfo.idHolderType != 'LEGAL') {
      return const SizedBox();
    }

    // 根据主体类型确定可选的证件类型
    List<Map<String, String>> availableIdDocTypes = [];

    if (selectedOrganizationType == '2401' ||
        selectedOrganizationType == '2500') {
      // 小微/个人卖家，仅支持身份证
      availableIdDocTypes = [
        {'value': 'IDENTIFICATION_TYPE_MAINLAND_IDCARD', 'label': '中国大陆居民-身份证'}
      ];
    } else if (selectedOrganizationType == '3' ||
        selectedOrganizationType == '2502') {
      // 政府机关/事业单位，仅支持身份证
      availableIdDocTypes = [
        {'value': 'IDENTIFICATION_TYPE_MAINLAND_IDCARD', 'label': '中国大陆居民-身份证'}
      ];
    } else {
      // 其他主体类型，支持所有证件类型
      availableIdDocTypes = CertificateType.idDocTypes;
    }

    // 当前选中的值
    String? currentValue = weChatMerchantInfo.idDocType;

    // 如果只有一个选项且当前值为空，则自动选择第一个选项
    if (availableIdDocTypes.length == 1 && currentValue == null) {
      currentValue = availableIdDocTypes.first['value'];
      weChatMerchantInfo.idDocType = currentValue;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '证件类型',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: DropdownButton<String>(
            value: currentValue,
            isExpanded: true,
            underline: const SizedBox(),
            hint: availableIdDocTypes.length > 1
                ? const Text('请选择证件类型', style: TextStyle(color: Colors.grey))
                : null,
            items: availableIdDocTypes.map((Map<String, String> type) {
              return DropdownMenuItem<String>(
                value: type['value'],
                child: Text(type['label'] ?? ''),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                weChatMerchantInfo.idDocType = value;
              });
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _builDauthorizeLetterCopyWidget() {
    if (weChatMerchantInfo.idHolderType != 'SUPER') {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '法定代表人说明函',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '请上传法定代表人说明函照片\n'
          '1、正面拍摄、清晰、四角完整、无反光或遮挡\n'
          '2、不得翻拍、截图、镜像、PS\n'
          '3、请上传彩色照片或彩色扫描件',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            // 1. 检查权限
            bool hasPermission = await PermissionUtil().requestPermission(
              context: context,
              permission: Permission.storage,
              info: '希望获取存储权限用于选择法定代表人说明函照片',
            );

            if (!hasPermission) return;

            // 2. 选择图片
            //final List<AssetEntity>? results = await AssetPicker.pickAssets(context);
            final List<AssetEntity>? results = await AssetPicker.pickAssets(
              context,
              pickerConfig: ImageUtil.buildDefaultImagePickerConfig(),
            );

            if (results == null || results.isEmpty) return;

            File? file = await results.first.file;
            if (file == null) return;

            // 3. 立即显示临时图片
            setState(() => _tempAuthorizeLetterFile = file);

            // 4. 调用API上传
            String? mediaId = await MerchantApi().uploadMerchantFile(
              file: file,
              filename: file.path.split('/').last,
              onError: (error) {
                ToastUtil.error('上传失败');
                setState(() => _tempAuthorizeLetterFile = null);
              },
            );

            // 5. 上传成功后的处理
            if (mediaId != null) {
              setState(() {
                weChatMerchantInfo.authorizeLetterCopy = mediaId;
                // 保留临时文件直到页面刷新或关闭
              });
            }
          },
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: _buildImageDisplay(
              tempFile: _tempAuthorizeLetterFile,
              networkUrl: weChatMerchantInfo.authorizeLetterCopy,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildIdCardInfoWidget() {
    if (weChatMerchantInfo.idHolderType != 'LEGAL' ||
        weChatMerchantInfo.idDocType != 'IDENTIFICATION_TYPE_MAINLAND_IDCARD') {
      return const SizedBox();
    }

    return Column(
      children: [
        const SizedBox(height: 16),
        const Text('经营者/法人身份证信息',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),

        // 身份证人像面照片
        _buildIdCardCopyField(),
        const SizedBox(height: 16),

        // 身份证国徽面照片
        _buildIdCardNationalField(),
        const SizedBox(height: 16),

        // 身份证姓名
        _buildIdCardTextField(
          label: "身份证姓名",
          value: weChatMerchantInfo.idCardInfo?.idCardName,
          onChanged: (value) {
            setState(() {
              weChatMerchantInfo.idCardInfo ??= IdCardInfo();
              weChatMerchantInfo.idCardInfo!.idCardName = value;
            });
          },
          hintText: "请输入经营者/法定代表人身份证姓名",
          validator: (value) {
            if (value == null || value.isEmpty) return '请输入身份证姓名';
            if (value.trim().length < 2 || value.trim().length > 100) {
              return '姓名长度需在2-100个字符之间';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // 身份证号码
        _buildIdCardTextField(
          label: "身份证号码",
          value: weChatMerchantInfo.idCardInfo?.idCardNumber,
          onChanged: (value) {
            setState(() {
              weChatMerchantInfo.idCardInfo ??= IdCardInfo();
              weChatMerchantInfo.idCardInfo!.idCardNumber = value;
            });
          },
          hintText: "请输入经营者/法定代表人身份证号码",
          validator: (value) {
            if (value == null || value.isEmpty) return '请输入身份证号码';
            if (!RegExp(r'^\d{17}[\dXx]$').hasMatch(value)) {
              return '请输入有效的身份证号码';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // 身份证有效期开始时间
        _buildIdCardDateField(
          label: "身份证开始时间",
          value: weChatMerchantInfo.idCardInfo?.idCardValidTimeBegin,
          onChanged: (value) {
            setState(() {
              weChatMerchantInfo.idCardInfo ??= IdCardInfo();
              weChatMerchantInfo.idCardInfo!.idCardValidTimeBegin = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) return '请选择开始时间';
            final date = DateTime.tryParse(value);
            if (date == null) return '日期格式不正确';
            if (date.isBefore(DateTime(1900, 1, 1))) {
              return '开始时间不能小于1900-01-01';
            }
            if (date.isAfter(DateTime.now())) {
              return '开始时间不能大于当前日期';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // 身份证有效期结束时间
        _buildIdCardDateField(
          label: "身份证结束时间",
          value: weChatMerchantInfo.idCardInfo?.idCardValidTime,
          onChanged: (value) {
            setState(() {
              weChatMerchantInfo.idCardInfo ??= IdCardInfo();
              weChatMerchantInfo.idCardInfo!.idCardValidTime = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) return '请选择结束时间';
            if (value == '长期') return null;

            final endDate = DateTime.tryParse(value);
            if (endDate == null) return '日期格式不正确';

            final beginDate =
                weChatMerchantInfo.idCardInfo?.idCardValidTimeBegin;
            if (beginDate != null) {
              final startDate = DateTime.tryParse(beginDate);
              if (startDate != null && endDate.isBefore(startDate)) {
                return '结束时间必须大于开始时间';
              }
            }
            return null;
          },
          allowLongTerm: true,
        ),
      ],
    );
  }

  Widget _buildIdCardCopyField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '身份证人像面照片',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            // 1. 检查权限
            bool hasPermission = await PermissionUtil().requestPermission(
              context: context,
              permission: Permission.storage,
              info: '希望获取存储权限用于选择身份证人像面照片',
            );

            if (!hasPermission) return;

            // 2. 选择图片
            //final List<AssetEntity>? results = await AssetPicker.pickAssets(context);
            final List<AssetEntity>? results = await AssetPicker.pickAssets(
              context,
              pickerConfig: ImageUtil.buildDefaultImagePickerConfig(),
            );

            if (results == null || results.isEmpty) return;

            File? file = await results.first.file;
            if (file == null) return;

            // 3. 立即显示临时图片
            setState(() => _tempIdCardCopyFile = file);

            // 4. 调用API上传
            String? mediaId = await MerchantApi().uploadMerchantFile(
              file: file,
              filename: file.path.split('/').last,
              onError: (error) {
                ToastUtil.error('上传失败');
                setState(() => _tempIdCardCopyFile = null);
              },
            );

            // 5. 上传成功后的处理
            if (mediaId != null) {
              setState(() {
                weChatMerchantInfo.idCardInfo ??= IdCardInfo();
                weChatMerchantInfo.idCardInfo!.idCardCopyUrl = mediaId;
                weChatMerchantInfo.idCardInfo!.idCardCopy = '1234';
                // 保留临时文件直到页面刷新或关闭
              });
            }
          },
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: _buildImageDisplay(
              tempFile: _tempIdCardCopyFile,
              networkUrl: weChatMerchantInfo.idCardInfo?.idCardCopyUrl,
            ),
          ),
        ),
        const Text(
          "请上传个体户经营者/法人的身份证人像面照片\n"
          "1、正面拍摄、清晰、四角完整、无反光或遮挡\n"
          "2、不得翻拍、截图、镜像、PS\n"
          "3、请上传彩色照片或彩色扫描件",
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildIdCardNationalField() {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '身份证国徽面照片',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            // 1. 检查权限
            bool hasPermission = await PermissionUtil().requestPermission(
              context: context,
              permission: Permission.storage,
              info: '希望获取存储权限用于选择身份证国徽面照片',
            );

            if (!hasPermission) return;

            // 2. 选择图片
            //final List<AssetEntity>? results = await AssetPicker.pickAssets(context);
            final List<AssetEntity>? results = await AssetPicker.pickAssets(
              context,
              pickerConfig: ImageUtil.buildDefaultImagePickerConfig(),
            );

            if (results == null || results.isEmpty) return;

            File? file = await results.first.file;
            if (file == null) return;

            // 3. 立即显示临时图片
            setState(() => _tempIdCardNationalFile = file);

            // 4. 调用API上传
            String? mediaId = await MerchantApi().uploadMerchantFile(
              file: file,
              filename: file.path.split('/').last,
              onError: (error) {
                ToastUtil.error('上传失败');
                setState(() => _tempIdCardNationalFile = null);
              },
            );

            // 5. 上传成功后的处理
            if (mediaId != null) {
              setState(() {
                weChatMerchantInfo.idCardInfo ??= IdCardInfo();
                weChatMerchantInfo.idCardInfo!.idCardNational   = mediaId;
                // 保留临时文件直到页面刷新或关闭
              });
            }
          },
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: _buildImageDisplay(
              tempFile: _tempIdCardNationalFile,
              networkUrl: weChatMerchantInfo.idCardInfo?.idCardNational,
            ),
          ),
        ),
        const Text(
          "请上传个体户经营者/法定代表人的身份证国徽面照片\n"
          "1、正面拍摄、清晰、四角完整、无反光或遮挡\n"
          "2、不得翻拍、截图、镜像、PS\n"
          "3、请上传彩色照片或彩色扫描件",
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildIdCardTextField({
    required String label,
    required String? value,
    required Function(String) onChanged,
    required String hintText,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildIdCardDateField({
    required String label,
    required String? value,
    required Function(String) onChanged,
    required String? Function(String?) validator,
    bool allowLongTerm = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (allowLongTerm && value == '长期')
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: '长期',
                  readOnly: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  onChanged('');
                },
                child: const Text('选择日期'),
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: TextEditingController(text: value),
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'YYYY-MM-DD',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900, 1, 1),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      onChanged(picked.toString().split(' ')[0]);
                    }
                  },
                  validator: validator,
                ),
              ),
              if (allowLongTerm)
                TextButton(
                  onPressed: () {
                    onChanged('长期');
                  },
                  child: const Text('长期'),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildOtherIdDocInfoWidget() {
    // 仅当证件类型不是中国大陆身份证时显示
    if (weChatMerchantInfo.idDocType == 'IDENTIFICATION_TYPE_MAINLAND_IDCARD') {
      return const SizedBox();
    }

    return Column(
      children: [
        const SizedBox(height: 16),
        const Text('经营者/法人其他证件信息',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),

        // 证件姓名
        _buildIdCardTextField(
          label: "证件姓名",
          value: weChatMerchantInfo.idDocInfo?.idDocName,
          onChanged: (value) {
            setState(() {
              weChatMerchantInfo.idDocInfo ??= IdDocInfo();
              weChatMerchantInfo.idDocInfo!.idDocName = value;
            });
          },
          hintText: "请输入经营者/法定代表人证件姓名",
          validator: (value) {
            if (value == null || value.isEmpty) return '请输入证件姓名';
            if (value.trim().length < 2 || value.trim().length > 100) {
              return '姓名长度需在2-100个字符之间';
            }
            if (value.trim() != value) {
              return '前后不能有空格、制表符、换行符';
            }
            if (RegExp(r'^[\d\W]+$').hasMatch(value)) {
              return '不能仅含数字、特殊字符';
            }
            if (!RegExp(r'^[\da-zA-Z\u4e00-\u9fa5\-\s]+$').hasMatch(value)) {
              return '仅能填写数字、英文字母、汉字及特殊字符';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // 证件号码
        _buildIdCardTextField(
          label: "证件号码",
          value: weChatMerchantInfo.idDocInfo?.idDocNumber,
          onChanged: (value) {
            setState(() {
              weChatMerchantInfo.idDocInfo ??= IdDocInfo();
              weChatMerchantInfo.idDocInfo!.idDocNumber = value;
            });
          },
          hintText: "请输入经营者/法定代表人证件号码",
          validator: (value) {
            if (value == null || value.isEmpty) return '请输入证件号码';

            // 根据不同类型验证
            switch (weChatMerchantInfo.idDocType) {
              case 'IDENTIFICATION_TYPE_OVERSEA_PASSPORT': // 护照
                if (!RegExp(r'^[\dA-Za-z\-]{4,15}$').hasMatch(value)) {
                  return '护照号码应为4-15位数字/字母/连字符';
                }
                break;
              case 'IDENTIFICATION_TYPE_HONGKONG': // 香港通行证
                if (!RegExp(r'^[Hh][\dA-Za-z]{8,10}$').hasMatch(value)) {
                  return '香港通行证应以H/h开头+8或10位数字/字母';
                }
                break;
              case 'IDENTIFICATION_TYPE_MACAO': // 澳门通行证
                if (!RegExp(r'^[Mm][\dA-Za-z]{8,10}$').hasMatch(value)) {
                  return '澳门通行证应以M/m开头+8或10位数字/字母';
                }
                break;
              case 'IDENTIFICATION_TYPE_TAIWAN': // 台湾通行证
                if (!RegExp(r'^\d{8}$|^\d{10}$').hasMatch(value)) {
                  return '台湾通行证应为8位或10位数字';
                }
                break;
              case 'IDENTIFICATION_TYPE_FOREIGN_RESIDENT': // 外国人居留证
                if (!RegExp(r'^[\dA-Za-z]{15}$').hasMatch(value)) {
                  return '外国人居留证应为15位数字/字母';
                }
                break;
              case 'IDENTIFICATION_TYPE_HONGKONG_MACAO_RESIDENT': // 港澳居住证
              case 'IDENTIFICATION_TYPE_TAIWAN_RESIDENT': // 台湾居住证
                if (!RegExp(r'^\d{17}[\dX]$').hasMatch(value)) {
                  return '居住证应为17位数字+1位数字/X';
                }
                break;
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // 证件正面照片
        _buildIdDocCopyField(),

        const SizedBox(height: 16),

        // 证件反面照片（非护照时需要）
        if (weChatMerchantInfo.idDocType !=
            'IDENTIFICATION_TYPE_OVERSEA_PASSPORT')
          Column(
            children: [
              _buildIdDocCopyBackField(),
              const SizedBox(height: 16),
            ],
          ),

        // 证件开始日期
        _buildIdCardDateField(
          label: "证件开始日期",
          value: weChatMerchantInfo.idDocInfo?.docPeriodBegin,
          onChanged: (value) {
            setState(() {
              weChatMerchantInfo.idDocInfo ??= IdDocInfo();
              weChatMerchantInfo.idDocInfo!.docPeriodBegin = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) return '请选择开始日期';
            final date = DateTime.tryParse(value);
            if (date == null) return '日期格式不正确';
            if (date.isBefore(DateTime(1900, 1, 1))) {
              return '开始时间不能小于1900-01-01';
            }
            if (!date.isBefore(DateTime.now())) {
              return '开始时间必须小于当前日期';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // 证件结束日期
        _buildIdCardDateField(
          label: "证件结束日期",
          value: weChatMerchantInfo.idDocInfo?.docPeriodEnd,
          onChanged: (value) {
            setState(() {
              weChatMerchantInfo.idDocInfo ??= IdDocInfo();
              weChatMerchantInfo.idDocInfo!.docPeriodEnd = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) return '请选择结束日期';
            if (value == '长期') return null;

            final endDate = DateTime.tryParse(value);
            if (endDate == null) return '日期格式不正确';

            final beginDate = weChatMerchantInfo.idDocInfo?.docPeriodBegin;
            if (beginDate != null) {
              final startDate = DateTime.tryParse(beginDate);
              if (startDate != null && endDate.isBefore(startDate)) {
                return '结束时间必须大于开始时间';
              }
            }
            return null;
          },
          allowLongTerm: true,
        ),
      ],
    );
  }

  Widget _buildIdDocCopyField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '证件正面照片',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            // 1. 检查权限
            bool hasPermission = await PermissionUtil().requestPermission(
              context: context,
              permission: Permission.storage,
              info: '希望获取存储权限用于选择证件正面照片',
            );

            if (!hasPermission) return;

            // 2. 选择图片
            //final List<AssetEntity>? results = await AssetPicker.pickAssets(context);
            final List<AssetEntity>? results = await AssetPicker.pickAssets(
              context,
              pickerConfig: ImageUtil.buildDefaultImagePickerConfig(),
            );

            if (results == null || results.isEmpty) return;

            File? file = await results.first.file;
            if (file == null) return;

            // 3. 立即显示临时图片
            setState(() => _tempidDocCopyFile = file);

            // 4. 调用API上传
            String? mediaId = await MerchantApi().uploadMerchantFile(
              file: file,
              filename: file.path.split('/').last,
              onError: (error) {
                ToastUtil.error('上传失败');
                setState(() => _tempidDocCopyFile = null);
              },
            );

            // 5. 上传成功后的处理
            if (mediaId != null) {
              setState(() {
                weChatMerchantInfo.idDocInfo ??= IdDocInfo();
                weChatMerchantInfo.idDocInfo!.idDocCopy = mediaId;
                // 保留临时文件直到页面刷新或关闭
              });
            }
          },
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: _buildImageDisplay(
              tempFile: _tempidDocCopyFile,
              networkUrl: weChatMerchantInfo.idDocInfo?.idDocCopy,
            ),
          ),
        ),
        const Text(
          "请上传证件正面照片\n"
          "1、正面拍摄、清晰、四角完整、无反光或遮挡\n"
          "2、不得翻拍、截图、镜像、PS\n"
          "3、请上传彩色照片或彩色扫描件",
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildIdDocCopyBackField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '证件反面照片',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            // 1. 检查权限
            bool hasPermission = await PermissionUtil().requestPermission(
              context: context,
              permission: Permission.storage,
              info: '希望获取存储权限用于选择证件反面照片',
            );

            if (!hasPermission) return;

            // 2. 选择图片
            //final List<AssetEntity>? results = await AssetPicker.pickAssets(context);
            final List<AssetEntity>? results = await AssetPicker.pickAssets(
              context,
              pickerConfig: ImageUtil.buildDefaultImagePickerConfig(),
            );

            if (results == null || results.isEmpty) return;

            File? file = await results.first.file;
            if (file == null) return;

            // 3. 立即显示临时图片
            setState(() => _tempidDocCopyBackFile = file);

            // 4. 调用API上传
            String? mediaId = await MerchantApi().uploadMerchantFile(
              file: file,
              filename: file.path.split('/').last,
              onError: (error) {
                ToastUtil.error('上传失败');
                setState(() => _tempidDocCopyBackFile = null);
              },
            );

            // 5. 上传成功后的处理
            if (mediaId != null) {
              setState(() {
                weChatMerchantInfo.idDocInfo ??= IdDocInfo();
                weChatMerchantInfo.idDocInfo!.idDocCopyBack = mediaId;
                // 保留临时文件直到页面刷新或关闭
              });
            }
          },
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: _buildImageDisplay(
              tempFile: _tempidDocCopyBackFile,
              networkUrl: weChatMerchantInfo.idDocInfo?.idDocCopyBack,
            ),
          ),
        ),
        const Text(
          "请上传证件反面照片\n"
          "1、正面拍摄、清晰、四角完整、无反光或遮挡\n"
          "2、不得翻拍、截图、镜像、PS\n"
          "3、请上传彩色照片或彩色扫描件",
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAccountInfoWidget() {
    // 根据主体类型确定可选的账户类型
    List<Map<String, String>> availableAccountTypes = [];
    if (selectedOrganizationType == '2401' ||
        selectedOrganizationType == '2500') {
      // 小微/个人卖家，只能选对私账户
      availableAccountTypes = [
        {'value': '75', 'label': '对私账户'}
      ];
    } else if (selectedOrganizationType == '4') {
      // 个体工商户，可对公可对私
      availableAccountTypes = [
        {'value': '74', 'label': '对公账户'},
        {'value': '75', 'label': '对私账户'}
      ];
    } else {
      // 企业/政府机关/事业单位/社会组织，只能选对公账户
      availableAccountTypes = [
        {'value': '74', 'label': '对公账户'}
      ];
    }
  String? currentValue = weChatMerchantInfo.accountInfo?.bankAccountType;
  if (currentValue != null && 
      !availableAccountTypes.any((type) => type['value'] == currentValue)) {
    currentValue = null;
  }
    return Column(
      children: [
        const SizedBox(height: 16),
        const Text('结算账户信息',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),

        // 账户类型
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '账户类型',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: DropdownButton<String>(
                value: currentValue,
                isExpanded: true,
                underline: const SizedBox(),
                hint:
                    const Text('请选择账户类型', style: TextStyle(color: Colors.grey)),
                items: availableAccountTypes.map((Map<String, String> type) {
                  return DropdownMenuItem<String>(
                    value: type['value'],
                    child: Text(type['label'] ?? ''),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    weChatMerchantInfo.accountInfo ??= AccountInfo();
                    weChatMerchantInfo.accountInfo!.bankAccountType = value;
                    // 切换账户类型时清空已选的银行信息并重新加载银行列表
                    weChatMerchantInfo.accountInfo!.accountBank = null;
                    weChatMerchantInfo.accountInfo!.bankName = null;
                    weChatMerchantInfo.accountInfo!.bankBranchId = null;
                    _selectedBankCode = null;
                    _selectedBankName = null;
                    _bankList.clear();
                    _bankOffset = 0;
                    _hasMoreBanks = true;
                    _fetchBanks();
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),

        // 开户银行
        _buildBankDropdown(),
        // 开户名称
        const SizedBox(height: 16),
        if (_selectedBankCode != null) ...[
          // 开户银行省市编码
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "开户银行省市",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // 省份选择
                  Expanded(
                    child: CompositedTransformTarget(
                      link: _provinceLayerLink,
                      child: GestureDetector(
                        onTap: _showProvinceList,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          child: Text(
                            _selectedProvince ?? '请选择省份',
                            style: TextStyle(
                              color: _selectedProvince != null
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 城市选择
                  Expanded(
                    child: CompositedTransformTarget(
                      link: _cityLayerLink,
                      child: GestureDetector(
                        onTap: _selectedProvince == null ? null : _showCityList,
                        child: Container(
                          decoration: BoxDecoration(
                            color: _selectedProvince == null
                                ? Colors.grey[200]
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          child: Text(
                            _selectedCity ?? '请选择城市',
                            style: TextStyle(
                              color: _selectedCity != null
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 区县选择
                  Expanded(
                    child: CompositedTransformTarget(
                      link: _areaLayerLink,
                      child: GestureDetector(
                        onTap: _selectedCity == null ? null : _showAreaList,
                        child: Container(
                          decoration: BoxDecoration(
                            color: _selectedCity == null
                                ? Colors.grey[200]
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          child: Text(
                            _selectedArea ?? '请选择区县',
                            style: TextStyle(
                              color: _selectedArea != null
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),

        // 开户银行支行

        if (_selectedNeedBankBranch == false) ...[
          _buildBranchDropdown(),
          const SizedBox(height: 16),
        ],

        const SizedBox(height: 16),

        // 银行账号
        _buildIdCardTextField(
          label: "银行账号",
          value: weChatMerchantInfo.accountInfo?.accountNumber,
          onChanged: (value) {
            setState(() {
              weChatMerchantInfo.accountInfo ??= AccountInfo();
              weChatMerchantInfo.accountInfo!.accountNumber = value;
            });
          },
          hintText: "请输入银行账号",
          validator: (value) {
            if (value == null || value.isEmpty) return '请输入银行账号';
            if (!RegExp(r'^\d+$').hasMatch(value)) {
              return '银行账号必须为数字';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildIdCardTextField(
          label: "开户名称",
          value: weChatMerchantInfo.accountInfo?.accountName,
          onChanged: (value) {
            setState(() {
              weChatMerchantInfo.accountInfo ??= AccountInfo();
              weChatMerchantInfo.accountInfo!.accountName = value;
            });
          },
          hintText: "请输入开户名称",
          validator: (value) {
            if (value == null || value.isEmpty) return '请输入开户名称';
            if (weChatMerchantInfo.accountInfo?.bankAccountType == '75' &&
                weChatMerchantInfo.idCardInfo?.idCardName != null &&
                value != weChatMerchantInfo.idCardInfo!.idCardName) {
              return '对私账户开户名称必须与身份证姓名一致';
            }
            if (weChatMerchantInfo.accountInfo?.bankAccountType == '74' &&
                weChatMerchantInfo.businessLicenseInfo?.merchantName != null &&
                value != weChatMerchantInfo.businessLicenseInfo!.merchantName) {
              return '对公账户开户名称必须与营业执照上的商户名称一致';
            }
            return null;
          },
        ),
        const SizedBox(height: 4),
        const Text(
          '1、选择对私账户时，开户名称必须与身份证姓名一致。\n'
          '2、选择对公账户时，开户名称必须与营业执照上的"商户名称"一致。',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }
Widget _buildBranchDropdown() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "开户银行支行",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: () {
          if (_selectedBankCode == null || _selectedCityCode == null) {
            ToastUtil.error('请先选择银行和城市');
            return;
          }
          _showBranchList();
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _selectedBranchName ?? '请选择支行',
                  style: TextStyle(
                    color: _selectedBranchName != null 
                      ? Colors.black 
                      : Colors.grey,
                  ),
                ),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
      if (_selectedBranchName != null) ...[
        const SizedBox(height: 8),
        Text(
          '已选支行: $_selectedBranchName',
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    ],
  );
}

void _showBranchList() {
  // 重置分页状态
  _branchOffset = 0;
  _hasMoreBranches = true;
  _bankBranches.clear();

  _removeBranchOverlay();

  _branchOverlayEntry = OverlayEntry(
    builder: (context) => GestureDetector(
      onTap: _removeBranchOverlay,
      behavior: HitTestBehavior.translucent,
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.only(top: 100),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          '请选择支行',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (scrollNotification) {
                            if (scrollNotification is ScrollEndNotification &&
                                _branchScrollController.position.pixels ==
                                    _branchScrollController.position.maxScrollExtent &&
                                !_isLoadingMoreBranches &&
                                _hasMoreBranches) {
                              _fetchBranches(loadMore: true);
                            }
                            return false;
                          },
                          child: _buildBranchListContent(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    ),
  );

  Overlay.of(context).insert(_branchOverlayEntry!);
  _fetchBranches();
}
void _removeBranchOverlay() {
  _branchOverlayEntry?.remove();
  _branchOverlayEntry = null;
}
Future<void> _fetchBranchesAndShowList() async {
  if (_isLoadingBranches) return;

  setState(() => _isLoadingBranches = true);

  try {
    final branches = await MerchantApi().getBankBranches(
      bankAliasCode: _selectedBankCode!,
      cityCode: _selectedCityCode!,
    );

    if (branches == null || branches.isEmpty) {
      ToastUtil.error('该城市下没有找到支行信息');
      return;
    }

    // 显示支行选择弹窗
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '请选择支行',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: branches.length,
                itemBuilder: (context, index) {
                  final branch = branches[index];
                  return ListTile(
                    title: Text(branch.bankBranchName),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _selectedBranchId = branch.bankBranchId;
                        _selectedBranchName = branch.bankBranchName;
                        
                        // 设置到商户信息中
                        weChatMerchantInfo.accountInfo ??= AccountInfo();
                        weChatMerchantInfo.accountInfo!.bankBranchId = branch.bankBranchId;
                        weChatMerchantInfo.accountInfo!.bankName = branch.bankBranchName;
                        
                      });
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  } catch (e) {
    ToastUtil.error('获取支行列表失败');
  } finally {
    setState(() => _isLoadingBranches = false);
  }
}
Widget _buildBranchListContent() {
  if (_isLoadingMoreBranches && _bankBranches.isEmpty) {
    return const Center(child: CircularProgressIndicator());
  }

  return ListView.builder(
    controller: _branchScrollController,
    itemCount: _bankBranches.length + (_hasMoreBranches ? 1 : 0),
    itemBuilder: (context, index) {
      if (index < _bankBranches.length) {
        final branch = _bankBranches[index];
        return ListTile(
          title: Text(branch.bankBranchName),
          onTap: () {
            _removeBranchOverlay();
            setState(() {
              _selectedBranchId = branch.bankBranchId;
              _selectedBranchName = branch.bankBranchName;
              
              weChatMerchantInfo.accountInfo ??= AccountInfo();
              weChatMerchantInfo.accountInfo!.bankBranchId = branch.bankBranchId;
              weChatMerchantInfo.accountInfo!.bankName = branch.bankBranchName;
            });
          },
        );
      } 
    },
  );
}
  Widget _buildContactInfoWidget() {
    // 根据主体类型确定可选的超级管理员类型
    List<Map<String, String>> availableContactTypes = [];
    if (selectedOrganizationType == '2401' ||
        selectedOrganizationType == '2500') {
      // 小微/个人卖家，只能选经营者/法人
      availableContactTypes = [
        {'value': '65', 'label': '经营者/法人'}
      ];
    } else {
      // 其他主体类型，可选经营者/法人或经办人
      availableContactTypes = [
        {'value': '65', 'label': '经营者/法人'},
        {'value': '66', 'label': '经办人'}
      ];
    }

    // 判断是否显示经办人相关字段
    bool isAgent = weChatMerchantInfo.contactInfo?.contactType == '66';

    return Column(
      children: [
        const SizedBox(height: 16),
        const Text('超级管理员信息',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),

        // 超级管理员类型
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '超级管理员类型',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: DropdownButton<String>(
                value: weChatMerchantInfo.contactInfo?.contactType,
                isExpanded: true,
                underline: const SizedBox(),
                hint: const Text('请选择超级管理员类型',
                    style: TextStyle(color: Colors.grey)),
                items: availableContactTypes.map((Map<String, String> type) {
                  return DropdownMenuItem<String>(
                    value: type['value'],
                    child: Text(type['label'] ?? ''),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    weChatMerchantInfo.contactInfo ??= ContactInfo();
                    weChatMerchantInfo.contactInfo!.contactType = value;
                    // 切换类型时重置相关字段
                    if (value == '65') {
                      // 法人类型时自动填充姓名和身份证号
                      weChatMerchantInfo.contactInfo!.contactName =
                          weChatMerchantInfo.idCardInfo?.idCardName;
                      weChatMerchantInfo.contactInfo!.contactIdCardNumber =
                          weChatMerchantInfo.idCardInfo?.idCardNumber;
                    } else {
                      // 经办人类型时清空相关字段
                      weChatMerchantInfo.contactInfo!.contactName = null;
                      weChatMerchantInfo.contactInfo!.contactIdCardNumber =
                          null;
                    }
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),

        // 超级管理员姓名
        _buildIdCardTextField(
          label: "超级管理员姓名",
          value: weChatMerchantInfo.contactInfo?.contactName,
          onChanged: (value) {
            setState(() {
              weChatMerchantInfo.contactInfo ??= ContactInfo();
              weChatMerchantInfo.contactInfo!.contactName = value;
            });
          },
          hintText: "请输入超级管理员姓名",
          validator: (value) {
            if (value == null || value.isEmpty) return '请输入超级管理员姓名';
            if (value.trim().length < 2 || value.trim().length > 100) {
              return '姓名长度需在2-100个字符之间';
            }
            if (value.trim() != value) {
              return '前后不能有空格、制表符、换行符';
            }
            if (RegExp(r'^[\d\W]+$').hasMatch(value)) {
              return '不能仅含数字、特殊字符';
            }
            if (!RegExp(r'^[\da-zA-Z\u4e00-\u9fa5\-\s]+$').hasMatch(value)) {
              return '仅能填写数字、英文字母、汉字及特殊字符';
            }
            // 如果是法人，验证姓名是否与身份证一致
            if (weChatMerchantInfo.contactInfo?.contactType == '65' &&
                weChatMerchantInfo.idCardInfo?.idCardName != null &&
                value != weChatMerchantInfo.idCardInfo!.idCardName) {
              return '法人姓名必须与身份证姓名一致';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // 仅经办人时显示以下字段
        if (isAgent) ...[
          // 证件类型
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '证件类型',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: DropdownButton<String>(
                  value: weChatMerchantInfo.contactInfo?.contactIdDocType,
                  isExpanded: true,
                  underline: const SizedBox(),
                  hint: const Text('请选择证件类型',
                      style: TextStyle(color: Colors.grey)),
                  items: CertificateType.idDocTypes
                      .map((Map<String, String> type) {
                    return DropdownMenuItem<String>(
                      value: type['value'],
                      child: Text(type['label'] ?? ''),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      weChatMerchantInfo.contactInfo ??= ContactInfo();
                      weChatMerchantInfo.contactInfo!.contactIdDocType = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),

          // 证件号码
          _buildIdCardTextField(
            label: "证件号码",
            value: weChatMerchantInfo.contactInfo?.contactIdCardNumber,
            onChanged: (value) {
              setState(() {
                weChatMerchantInfo.contactInfo ??= ContactInfo();
                weChatMerchantInfo.contactInfo!.contactIdCardNumber = value;
              });
            },
            hintText: "请输入证件号码",
            validator: (value) {
              if (value == null || value.isEmpty) return '请输入证件号码';

              final docType = weChatMerchantInfo.contactInfo?.contactIdDocType;
              if (docType == 'IDENTIFICATION_TYPE_MAINLAND_IDCARD') {
                if (!RegExp(r'^\d{17}[\dXx]$').hasMatch(value)) {
                  return '请输入有效的身份证号码';
                }
              } else if (docType == 'IDENTIFICATION_TYPE_OVERSEA_PASSPORT') {
                if (!RegExp(r'^[\dA-Za-z\-]{4,15}$').hasMatch(value)) {
                  return '护照号码应为4-15位数字/字母/连字符';
                }
              } else if (docType == 'IDENTIFICATION_TYPE_HONGKONG') {
                if (!RegExp(r'^[Hh][\dA-Za-z]{8,10}$').hasMatch(value)) {
                  return '香港通行证应以H/h开头+8或10位数字/字母';
                }
              } else if (docType == 'IDENTIFICATION_TYPE_MACAO') {
                if (!RegExp(r'^[Mm][\dA-Za-z]{8,10}$').hasMatch(value)) {
                  return '澳门通行证应以M/m开头+8或10位数字/字母';
                }
              } else if (docType == 'IDENTIFICATION_TYPE_TAIWAN') {
                if (!RegExp(r'^\d{8}$|^\d{10}$').hasMatch(value)) {
                  return '台湾通行证应为8位或10位数字';
                }
              } else if (docType == 'IDENTIFICATION_TYPE_FOREIGN_RESIDENT') {
                if (!RegExp(r'^[\dA-Za-z]{15}$').hasMatch(value)) {
                  return '外国人居留证应为15位数字/字母';
                }
              } else if (docType ==
                      'IDENTIFICATION_TYPE_HONGKONG_MACAO_RESIDENT' ||
                  docType == 'IDENTIFICATION_TYPE_TAIWAN_RESIDENT') {
                if (!RegExp(r'^\d{17}[\dX]$').hasMatch(value)) {
                  return '居住证应为17位数字+1位数字/X';
                }
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // 证件正面照片
          _buildContactIdDocCopyField(),
          const SizedBox(height: 16),

          // 证件反面照片（非护照时需要）
          if (weChatMerchantInfo.contactInfo?.contactIdDocType !=
              'IDENTIFICATION_TYPE_OVERSEA_PASSPORT')
            Column(
              children: [
                _buildContactIdDocCopyBackField(),
                const SizedBox(height: 16),
              ],
            ),

          // 证件有效期开始时间
          _buildIdCardDateField(
            label: "证件开始日期",
            value: weChatMerchantInfo.contactInfo?.contactPeriodBegin,
            onChanged: (value) {
              setState(() {
                weChatMerchantInfo.contactInfo ??= ContactInfo();
                weChatMerchantInfo.contactInfo!.contactPeriodBegin = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) return '请选择开始日期';
              final date = DateTime.tryParse(value);
              if (date == null) return '日期格式不正确';
              if (date.isBefore(DateTime(1900, 1, 1))) {
                return '开始时间不能小于1900-01-01';
              }
              if (!date.isBefore(DateTime.now())) {
                return '开始时间必须小于当前日期';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // 证件有效期结束时间
          _buildIdCardDateField(
            label: "证件结束日期",
            value: weChatMerchantInfo.contactInfo?.contactPeriodEnd,
            onChanged: (value) {
              setState(() {
                weChatMerchantInfo.contactInfo ??= ContactInfo();
                weChatMerchantInfo.contactInfo!.contactPeriodEnd = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) return '请选择结束日期';
              if (value == '长期') return null;

              final endDate = DateTime.tryParse(value);
              if (endDate == null) return '日期格式不正确';

              final beginDate =
                  weChatMerchantInfo.contactInfo?.contactPeriodBegin;
              if (beginDate != null) {
                final startDate = DateTime.tryParse(beginDate);
                if (startDate != null && endDate.isBefore(startDate)) {
                  return '结束时间必须大于开始时间';
                }
              }
              return null;
            },
            allowLongTerm: true,
          ),

          const SizedBox(height: 16),

          // 业务办理授权函
          _buildBusinessAuthorizationLetterField(),

          const SizedBox(height: 16),
        ],

        // 超级管理员手机
        _buildIdCardTextField(
          label: "超级管理员手机",
          value: weChatMerchantInfo.contactInfo?.mobilePhone,
          onChanged: (value) {
            setState(() {
              weChatMerchantInfo.contactInfo ??= ContactInfo();
              weChatMerchantInfo.contactInfo!.mobilePhone = value;
            });
          },
          hintText: "请输入手机号码",
          validator: (value) {
            if (value == null || value.isEmpty) return '请输入手机号码';
            if (value.trim() != value) {
              return '前后不能有空格、制表符、换行符';
            }
            // 验证手机格式
            if (!RegExp(r'^\d{11}$').hasMatch(value) &&
                !RegExp(r'^[\d\+\-]{5,20}$').hasMatch(value)) {
              return '请输入11位手机号或5-20位数字/连字符/加号';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // 加密提示
        const Text(
          '注意：超级管理员姓名、证件号码和手机字段需要使用微信支付公钥加密',
          style: TextStyle(
            color: Colors.orange,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildContactIdDocCopyField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '超级管理员证件正面照片',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            // 1. 检查权限
            bool hasPermission = await PermissionUtil().requestPermission(
              context: context,
              permission: Permission.storage,
              info: '希望获取存储权限用于选择超级管理员证件正面照片',
            );

            if (!hasPermission) return;

            // 2. 选择图片
            //final List<AssetEntity>? results = await AssetPicker.pickAssets(context);
            final List<AssetEntity>? results = await AssetPicker.pickAssets(
              context,
              pickerConfig: ImageUtil.buildDefaultImagePickerConfig(),
            );

            if (results == null || results.isEmpty) return;

            File? file = await results.first.file;
            if (file == null) return;

            // 3. 立即显示临时图片
            setState(() => _tempContactIdCardCopyFile = file);

            // 4. 调用API上传
            String? mediaId = await MerchantApi().uploadMerchantFile(
              file: file,
              filename: file.path.split('/').last,
              onError: (error) {
                ToastUtil.error('上传失败');
                setState(() => _tempContactIdCardCopyFile = null);
              },
            );

            // 5. 上传成功后的处理
            if (mediaId != null) {
              setState(() {
                weChatMerchantInfo.contactInfo ??= ContactInfo();
                weChatMerchantInfo.contactInfo!.contactIdDocCopy = mediaId;
                // 保留临时文件直到页面刷新或关闭
              });
            }
          },
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: _buildImageDisplay(
              tempFile: _tempContactIdCardCopyFile,
              networkUrl: weChatMerchantInfo.contactInfo?.contactIdDocCopy,
            ),
          ),
        ),
        const Text(
          "请上传超级管理员证件正面照片\n"
          "1、正面拍摄、清晰、四角完整、无反光或遮挡\n"
          "2、不得翻拍、截图、镜像、PS\n"
          "3、请上传彩色照片或彩色扫描件",
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildContactIdDocCopyBackField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '超级管理员证件反面照片',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            // 1. 检查权限
            bool hasPermission = await PermissionUtil().requestPermission(
              context: context,
              permission: Permission.storage,
              info: '希望获取存储权限用于选择超级管理员证件反面照片',
            );

            if (!hasPermission) return;

            // 2. 选择图片
            //final List<AssetEntity>? results = await AssetPicker.pickAssets(context);
            final List<AssetEntity>? results = await AssetPicker.pickAssets(
              context,
              pickerConfig: ImageUtil.buildDefaultImagePickerConfig(),
            );

            if (results == null || results.isEmpty) return;

            File? file = await results.first.file;
            if (file == null) return;

            // 3. 立即显示临时图片
            setState(() => _tempContactIdCardCopyBackFile = file);

            // 4. 调用API上传
            String? mediaId = await MerchantApi().uploadMerchantFile(
              file: file,
              filename: file.path.split('/').last,
              onError: (error) {
                ToastUtil.error('上传失败');
                setState(() => _tempContactIdCardCopyBackFile = null);
              },
            );

            // 5. 上传成功后的处理
            if (mediaId != null) {
              setState(() {
                weChatMerchantInfo.contactInfo ??= ContactInfo();
                weChatMerchantInfo.contactInfo!.contactIdDocCopyBack = mediaId;
                // 保留临时文件直到页面刷新或关闭
              });
            }
          },
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: _buildImageDisplay(
              tempFile: _tempContactIdCardCopyBackFile,
              networkUrl: weChatMerchantInfo.contactInfo?.contactIdDocCopyBack,
            ),
          ),
        ),
        const Text(
          "请上传超级管理员证件反面照片\n"
          "1、正面拍摄、清晰、四角完整、无反光或遮挡\n"
          "2、不得翻拍、截图、镜像、PS\n"
          "3、请上传彩色照片或彩色扫描件",
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBusinessAuthorizationLetterField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '业务办理授权函',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            // 1. 检查权限
            bool hasPermission = await PermissionUtil().requestPermission(
              context: context,
              permission: Permission.storage,
              info: '希望获取存储权限用于选择业务办理授权函',
            );

            if (!hasPermission) return;

            // 2. 选择图片
            //final List<AssetEntity>? results = await AssetPicker.pickAssets(context);
            final List<AssetEntity>? results = await AssetPicker.pickAssets(
              context,
              pickerConfig: ImageUtil.buildDefaultImagePickerConfig(),
            );

            if (results == null || results.isEmpty) return;

            File? file = await results.first.file;
            if (file == null) return;

            // 3. 立即显示临时图片
            setState(() => _tempBusinessAuthorizationLetterFile = file);

            // 4. 调用API上传
            String? mediaId = await MerchantApi().uploadMerchantFile(
              file: file,
              filename: file.path.split('/').last,
              onError: (error) {
                ToastUtil.error('上传失败');
                setState(() => _tempBusinessAuthorizationLetterFile = null);
              },
            );

            // 5. 上传成功后的处理
            if (mediaId != null) {
              setState(() {
                weChatMerchantInfo.contactInfo ??= ContactInfo();
                weChatMerchantInfo.contactInfo!.businessAuthorizationLetter =
                    mediaId;
                // 保留临时文件直到页面刷新或关闭
              });
            }
          },
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: _buildImageDisplay(
              tempFile: _tempBusinessAuthorizationLetterFile,
              networkUrl:
                  weChatMerchantInfo.contactInfo?.businessAuthorizationLetter,
            ),
          ),
        ),
        const Text(
          "请上传业务办理授权函\n"
          "1、全部信息需打印，不支持手写商户信息\n"
          "2、需加盖公章鲜章\n"
          "3、请上传彩色照片或彩色扫描件",
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSalesSceneInfoWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('经营场景信息',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),

        // 店铺名称
        _buildIdCardTextField(
          label: "店铺名称",
          value: weChatMerchantInfo.salesSceneInfo?.storeName,
          onChanged: (value) {
            setState(() {
              weChatMerchantInfo.salesSceneInfo ??= SalesSceneInfo();
              weChatMerchantInfo.salesSceneInfo!.storeName = value;
            });
          },
          hintText: "请输入店铺名称",
          validator: (value) {
            if (value == null || value.isEmpty) return '请输入店铺名称';
            return null;
          },
        ),

        const SizedBox(height: 16),

        // 店铺链接
        _buildIdCardTextField(
          label: "店铺链接（选填）",
          value: weChatMerchantInfo.salesSceneInfo?.storeUrl,
          onChanged: (value) {
            setState(() {
              weChatMerchantInfo.salesSceneInfo ??= SalesSceneInfo();
              weChatMerchantInfo.salesSceneInfo!.storeUrl = value;
            });
          },
          hintText: "https:// 或 http:// 开头",
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (!value.startsWith('https://') &&
                  !value.startsWith('http://')) {
                return '必须以 https:// 或 http:// 开头';
              }
              if (value.length > 1024) {
                return '长度不能超过1024个字符';
              }
            }
            // 如果同时没有填写店铺二维码，则店铺链接必填
            if ((value == null || value.isEmpty) &&
                (weChatMerchantInfo.salesSceneInfo?.storeQrCode == null ||
                    weChatMerchantInfo.salesSceneInfo!.storeQrCode!.isEmpty)) {
              return '店铺链接或二维码必须填写一项';
            }
            return null;
          },
        ),
        const SizedBox(height: 4),
        const Text(
          '1、店铺二维码or店铺链接二选一必填。\n'
          '2、请填写可直接访问店铺主页的链接，需符合网站规范，必须以https://或http://开头，不能有转义字符。',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 16),
        // 店铺二维码
        _buildStoreQrCodeField(),
      ],
    );
  }

  Widget _buildStoreQrCodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '店铺二维码（选填）',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            // 1. 检查权限
            bool hasPermission = await PermissionUtil().requestPermission(
              context: context,
              permission: Permission.storage,
              info: '希望获取存储权限用于选择业务办理授权函',
            );

            if (!hasPermission) return;

            // 2. 选择图片
            //final List<AssetEntity>? results = await AssetPicker.pickAssets(context);
            final List<AssetEntity>? results = await AssetPicker.pickAssets(
              context,
              pickerConfig: ImageUtil.buildDefaultImagePickerConfig(),
            );

            if (results == null || results.isEmpty) return;

            File? file = await results.first.file;
            if (file == null) return;

            // 3. 立即显示临时图片
            setState(() => _tempstoreQrCodeFile = file);

            // 4. 调用API上传
            String? mediaId = await MerchantApi().uploadMerchantFile(
              file: file,
              filename: file.path.split('/').last,
              onError: (error) {
                ToastUtil.error('上传失败');
                setState(() => _tempstoreQrCodeFile = null);
              },
            );

            // 5. 上传成功后的处理
            if (mediaId != null) {
              setState(() {
                weChatMerchantInfo.salesSceneInfo ??= SalesSceneInfo();
                weChatMerchantInfo.salesSceneInfo!.storeQrCode = mediaId;
                // 保留临时文件直到页面刷新或关闭
              });
            }
          },
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: _buildImageDisplay(
              tempFile: _tempstoreQrCodeFile,
              networkUrl: weChatMerchantInfo.salesSceneInfo?.storeQrCode,
            ),
          ),
        ),
        const Text(
          '1、店铺二维码 or 店铺链接二选一必填。\n'
          '2、若为电商小程序，可上传店铺页面的小程序二维码。',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMerchantShortNameWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          '商户简称',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '将在支付完成页向买家展示，需与售卖商品相符',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextFormField(
            controller: TextEditingController(
              text: weChatMerchantInfo.merchantShortname,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: '请输入商户简称(最多21个汉字)',
              hintStyle: TextStyle(color: Colors.grey),
              counterText: '',
            ),
            maxLength: 64, // UTF-8下中文占3字节，21汉字=63字节，留1字节余量
            onChanged: (value) {
              setState(() {
                weChatMerchantInfo.merchantShortname = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) return '请输入商户简称';

              // 计算UTF-8字节长度
              final byteLength = utf8.encode(value).length;
              if (byteLength > 64) {
                return '超过最大长度限制(最多21个汉字)';
              }

              // 检查是否与经营内容相符（需要业务逻辑）
              if (weChatMerchantInfo.businessLicenseInfo?.merchantName !=
                      null &&
                  !value.contains(
                      weChatMerchantInfo.businessLicenseInfo!.merchantName!)) {
                return '简称应与商户名称相关';
              }

              return null;
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildQualificationsWidget() {
    // 判断是否是个人卖家（business_addition_desc必填）
    bool isIndividualSeller = selectedOrganizationType == '2500';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('资质与补充材料',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),

        // 特殊资质
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '特殊资质（可选）',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '根据行业要求提供，最多5张照片',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            _buildMultiImageUploader(
              urls: weChatMerchantInfo.qualifications?.split(',') ?? [],
              maxCount: 5,
              onChanged: (urls) {
                setState(() {
                  weChatMerchantInfo.qualifications = urls.join(',');
                });
              },
            ),
            const SizedBox(height: 16),
          ],
        ),

        // 补充材料
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '补充材料（可选）',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '根据审核要求提供，最多15张照片',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            _buildMultiImageUploader(
              urls: weChatMerchantInfo.businessAdditionPics?.split(',') ?? [],
              maxCount: 15,
              onChanged: (urls) {
                setState(() {
                  weChatMerchantInfo.businessAdditionPics = urls.join(',');
                });
              },
            ),
            const SizedBox(height: 16),
          ],
        ),

        // 补充说明（个人卖家必填）
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '补充说明${isIndividualSeller ? '（必填）' : '（可选）'}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isIndividualSeller) ...[
              const SizedBox(height: 4),
              const Text(
                '个人卖家需说明经营情况',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12), // 修正这里
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black),
              ),
              child: TextFormField(
                controller: TextEditingController(
                    text: weChatMerchantInfo.businessAdditionDesc),
                maxLines: 4,
                maxLength: 512,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: isIndividualSeller
                      ? '该商户已持续从事电子商务经营活动满6个月，且期间经营收入累计超过20万元'
                      : '可填写其他需要说明的内容',
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
                onChanged: (value) {
                  setState(() {
                    weChatMerchantInfo.businessAdditionDesc = value;
                  });
                },
                validator: (value) {
                  if (isIndividualSeller && (value == null || value.isEmpty)) {
                    return '个人卖家必须填写补充说明';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

// 多图上传组件
  Widget _buildMultiImageUploader({
    required List<String> urls,
    required int maxCount,
    required Function(List<String>) onChanged,
  }) {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ...urls.map((url) => _buildImageItem(url, true, () {
                onChanged(urls.where((u) => u != url).toList());
              })),
          if (urls.length < maxCount)
            _buildUploadButton(() async {
              final newUrl = await _pickAndUploadImage();
              if (newUrl != null && !urls.contains(newUrl)) {
                onChanged([...urls, newUrl]);
              }
            }),
        ],
      ),
    );
  }

  Widget _buildImageItem(String url, bool removable, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              getFullUrl(url),
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          if (removable)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUploadButton(VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add, size: 30),
            SizedBox(height: 4),
            Text('添加照片', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Future<String?> _pickAndUploadImage() async {
    bool isGranted = await PermissionUtil().requestPermission(
      context: context,
      permission: Permission.storage,
      info: '需要存储权限来选择照片',
    );
    if (!isGranted) return null;

    final results = await AssetPicker.pickAssets(
      context,
      pickerConfig: ImageUtil.buildDefaultImagePickerConfig(),
    );
    if (results == null || results.isEmpty) return null;

    final file = await results.first.file;
    if (file == null) return null;

    final url = await HttpFile.uploadFile(file.path, file.path.split('/').last);
    return url;
  }

  Widget _buildBankDropdown() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "开户银行",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: () {
          if (weChatMerchantInfo.accountInfo?.bankAccountType == null) {
            ToastUtil.error('请先选择账户类型');
            return;
          }
          _showBankList();
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _selectedBankName ?? '请选择开户银行',
                  style: TextStyle(
                    color: _selectedBankName != null 
                      ? Colors.black 
                      : Colors.grey,
                  ),
                ),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
      if (_selectedBankName != null) ...[
        const SizedBox(height: 8),
        Text(
          '已选银行: $_selectedBankName',
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    ],
  );
}

  Widget _buildBankListPopup() {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollEndNotification &&
            _scrollController.position.pixels ==
                _scrollController.position.maxScrollExtent &&
            !_isLoadingMore &&
            _hasMoreBanks) {
          _fetchBanks(loadMore: true);
        }
        return false;
      },
      child: ListView.builder(
        controller: _scrollController,
        shrinkWrap: true,
        itemCount: _bankList.length + (_hasMoreBanks ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < _bankList.length) {
            final bank = _bankList[index];
            return ListTile(
              title: Text(bank.bankAlias),
              onTap: () async {
                _removeOverlay();
                setState(() {
                  _selectedBankCode = bank.bankAliasCode;
                  _selectedBankName = bank.bankAlias;
                  _selectedNeedBankBranch = bank.needBankBranch;
                  weChatMerchantInfo.accountInfo ??= AccountInfo();
                  weChatMerchantInfo.accountInfo!.accountBank =
                      bank.bankAlias;
                  weChatMerchantInfo.accountInfo!.bankName = bank.bankAlias;
                });
                //try {
                //final provinces = await MerchantApi().getProvinces();
                //debugPrint('查询省份列表: ${provinces?.map((p) => '${p.provinceName}-${p.provinceCode}').join(', ')}');
                // } catch (e) {
                //debugPrint('查询省份列表错误: $e');
                //ToastUtil.error('查询省份列表失败');
                // }
              },
            );
          } else {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _isLoadingMore
                    ? const CircularProgressIndicator()
                    : const SizedBox.shrink(),
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _fetchBanks({bool loadMore = false}) async {
    if (_isLoadingMore) return;

    setState(() => _isLoadingMore = true);

    try {
      // 根据账户类型决定调用对公还是对私银行API
      final isCorporateAccount =
          weChatMerchantInfo.accountInfo?.bankAccountType == '74';

      if (isCorporateAccount) {
        final result = await MerchantApi().getCorporateBanks(
          offset: loadMore ? _bankList.length : 0,
          limit: 20,
        );

        if (result != null && result.banks.isNotEmpty) {
          setState(() {
            if (loadMore) {
              _bankList.addAll(result.banks.map((bank) => BankInfo(
                    bankAlias: bank.bankAlias,
                    bankAliasCode: bank.bankAliasCode,
                    accountBank: bank.accountBank,
                    accountBankCode: bank.accountBankCode,
                    needBankBranch: bank.needBankBranch,
                  )));
            } else {
              _bankList = result.banks
                  .map((bank) => BankInfo(
                        bankAlias: bank.bankAlias,
                        bankAliasCode: bank.bankAliasCode,
                        accountBank: bank.accountBank,
                        accountBankCode: bank.accountBankCode,
                        needBankBranch: bank.needBankBranch,
                      ))
                  .toList();
            }

            _hasMoreBanks = _bankList.length < result.totalCount;
            if (_overlayEntry != null) {
              _overlayEntry!.markNeedsBuild();
            }
          });
        }
      } else {
        final result = await MerchantApi().getPersonalBanks(
          offset: loadMore ? _bankList.length : 0,
          limit: 20,
        );

        if (result != null && result.banks.isNotEmpty) {
          setState(() {
            if (loadMore) {
              _bankList.addAll(result.banks.map((bank) => BankInfo(
                    bankAlias: bank.bankAlias,
                    bankAliasCode: bank.bankAliasCode,
                    accountBank: bank.accountBank,
                    accountBankCode: bank.accountBankCode,
                    needBankBranch: bank.needBankBranch,
                  )));
            } else {
              _bankList = result.banks
                  .map((bank) => BankInfo(
                        bankAlias: bank.bankAlias,
                        bankAliasCode: bank.bankAliasCode,
                        accountBank: bank.accountBank,
                        accountBankCode: bank.accountBankCode,
                        needBankBranch: bank.needBankBranch,
                      ))
                  .toList();
            }

            _hasMoreBanks = _bankList.length < result.totalCount;
            if (_overlayEntry != null) {
              _overlayEntry!.markNeedsBuild();
            }
          });
        }
      }
    } catch (e) {
      ToastUtil.error('获取银行列表失败2: ${e.toString()}');
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  // 显示支行列表
// 获取支行列表
  Future<void> _fetchBranches({bool loadMore = false}) async {
  if (_isLoadingMoreBranches) return;

  setState(() => _isLoadingMoreBranches = true);

  try {
    final branches = await MerchantApi().getBankBranches(
      bankAliasCode: _selectedBankCode!,
      cityCode: _selectedCityCode!,
      offset: _branchOffset,
      limit: _branchLimit,
    );

    if (branches == null || branches.isEmpty) {
      setState(() => _hasMoreBranches = false);
      if (!loadMore) {
        ToastUtil.error('该城市下没有找到支行信息');
      }
      return;
    }

    setState(() {
      if (loadMore) {
        _bankBranches.addAll(branches);
      } else {
        _bankBranches = branches;
      }
      _branchOffset = _bankBranches.length;
      _hasMoreBranches = branches.length >= _branchLimit;
    });

    // 强制刷新Overlay内容
    if (_branchOverlayEntry != null) {
      _branchOverlayEntry!.markNeedsBuild();
    }
  } catch (e) {
    if (!loadMore) {
      ToastUtil.error('获取支行列表失败: ${e.toString()}');
    }
  } finally {
    setState(() => _isLoadingMoreBranches = false);
  }
}
}
