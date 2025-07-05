import 'dart:convert';

class MerchantApplyParam {
  MerchantApplyParam();

  String? merchantName;
  String? showName;
  String? merchantType;
  String? phone;
  String? mobile;
  String? email;
  String? accountWechat;
  String? licenseType;
  String? licenseUrl;
  String? foodSafetyCertificate;

  Map<String, Object?> toJson() {
    Map<String, Object?> map = {};
    map['merchantName'] = merchantName;
    map['showName'] = showName;
    map['merchantType'] = merchantType;
    map['phone'] = phone;
    map['mobile'] = mobile;
    map['email'] = email;
    map['accountWechat'] = accountWechat;
    map['licenseType'] = licenseType;
    map['licenseUrl'] = licenseUrl;
    map['foodSafetyCertificate'] = foodSafetyCertificate;
    return map;
  }
}

class MerchantApply {
  MerchantApply();

  int? id;
  int? merchantId;
  String? merchantName;
  String? showName;
  String? merchantType;
  String? phone;
  String? mobile;
  String? email;
  String? accountWechat;
  String? licenseType;
  String? licenseUrl;
  String? applyStatus;
  String? reason;
  DateTime? createdAt;
  DateTime? updatedAt;

  MerchantApply.fromJson(dynamic json) {
    id = json['id'];
    merchantId = json['merchantId'];
    showName = json['showName'];
    merchantType = json['merchantType'];
    phone = json['phone'];
    mobile = json['mobile'];
    email = json['email'];
    accountWechat = json['accountWechat'];
    licenseType = json['licenseType'];
    licenseUrl = json['licenseUrl'];
    applyStatus = json['applyStatus'];
    reason = json['reason'];
    if (json['createdAt'] is String) {
      createdAt = DateTime.tryParse(json['createdAt']);
    }
    if (json['updatedAt'] is String) {
      updatedAt = DateTime.tryParse(json['updatedAt']);
    }
  }
}

enum ApplyStatus {
  auditing,
  passed,
  failed
}

extension ApplyStatusExt on ApplyStatus {
  String getVal() {
    switch (this) {
      case ApplyStatus.auditing:
        return 'AUDITING';
      case ApplyStatus.passed:
        return 'PASSED';
      case ApplyStatus.failed:
        return 'FAILED';
    }
  }

  String getDesc() {
    switch (this) {
      case ApplyStatus.auditing:
        return '审核中';
      case ApplyStatus.passed:
        return '审核通过';
      case ApplyStatus.failed:
        return '审核失败';
    }
  }

  static ApplyStatus? getStatus(String val) {
    for (ApplyStatus status in ApplyStatus.values) {
      if (status.getVal() == val) {
        return status;
      }
    }
    return null;
  }
}

enum ApplymentState {
  checking,
  accountNeedVerify,
  auditing,
  rejected,
  needSign,
  finish,
  frozen,
  canceled
}

extension ApplymentStateExt on ApplymentState {
  String getVal() {
    switch (this) {
      case ApplymentState.checking:
        return 'CHECKING';
      case ApplymentState.accountNeedVerify:
        return 'ACCOUNT_NEED_VERIFY';
      case ApplymentState.auditing:
        return 'AUDITING';
      case ApplymentState.rejected:
        return 'REJECTED';
      case ApplymentState.needSign:
        return 'NEED_SIGN';
      case ApplymentState.finish:
        return 'FINISH';
      case ApplymentState.frozen:
        return 'FROZEN';
      case ApplymentState.canceled:
        return 'CANCELED';
    }
  }

  String getDesc() {
    switch (this) {
      case ApplymentState.checking:
        return '资料校验中';
      case ApplymentState.accountNeedVerify:
        return '待账户验证';
      case ApplymentState.auditing:
        return '审核中';
      case ApplymentState.rejected:
        return '已驳回';
      case ApplymentState.needSign:
        return '待签约';
      case ApplymentState.finish:
        return '完成';
      case ApplymentState.frozen:
        return '已冻结';
      case ApplymentState.canceled:
        return '已作废';
    }
  }

  static ApplymentState? getStatus(String val) {
    for (ApplymentState status in ApplymentState.values) {
      if (status.getVal() == val) {
        return status;
      }
    }
    return null;
  }
}


enum LicenseType {
  mainlandIdCard,
  businessLicense,
}

extension LicenseTypeExt on LicenseType {
  String getVal() {
    switch (this) {
      case LicenseType.mainlandIdCard:
        return 'mainland_id_card';
      case LicenseType.businessLicense:
        return 'business_license';
    }
  }

  String getDesc() {
    switch (this) {
      case LicenseType.mainlandIdCard:
        return '大陆身份证';
      case LicenseType.businessLicense:
        return '营业执照';
    }
  }

  static LicenseType? getType(String val) {
    for (LicenseType type in LicenseType.values) {
      if (type.getVal() == val) {
        return type;
      }
    }
    return null;
  }
}

enum MerchantType {
  hotel,
  group,
  homestay, 
  scenic,
  dining,
  travelAgency
}

extension MerchantTypeExt on MerchantType {
  String getVal() {
    switch (this) {
      case MerchantType.hotel:
        return 'HOTEL';
      case MerchantType.group:
        return 'GROUP';
      case MerchantType.homestay:
        return 'HOMESTAY';
      case MerchantType.scenic:
        return 'SCENIC';
      case MerchantType.dining:
        return 'DINING';
      case MerchantType.travelAgency:
        return 'TRAVEL_AGENCY';
    }
  }

  String getDesc() {
    switch (this) {
      case MerchantType.hotel:
        return '住宿';
      case MerchantType.group:
        return '集团';
      case MerchantType.homestay:
        return '民宿';
      case MerchantType.scenic:
        return '景点';
      case MerchantType.dining:
        return '美食';
      case MerchantType.travelAgency:
        return '旅行社';
    }
  }

  static MerchantType? getType(String val) {
    for (MerchantType type in MerchantType.values) {
      if (type.getVal() == val) {
        return type;
      }
    }
    return null;
  }
}

class  WeChatMerchantInfo {
  String? organizationType;
  bool? financeInstitution;
  BusinessLicenseInfo? businessLicenseInfo;
  FinanceInstitutionInfo? financeInstitutionInfo;
  String? idHolderType;
  String? idDocType;
  String? authorizeLetterCopy;
  IdCardInfo? idCardInfo;
  IdDocInfo? idDocInfo;
  bool? owner;
  AccountInfo? accountInfo;
  ContactInfo? contactInfo;
  SalesSceneInfo? salesSceneInfo;
  SettlementInfo? settlementInfo;
  String? merchantShortname;
  String? qualifications;
  String? businessAdditionPics;
  String? businessAdditionDesc;
  List<UboInfo>? uboInfoList;

  WeChatMerchantInfo({
    this.organizationType,
    this.financeInstitution,
    this.businessLicenseInfo,
    this.financeInstitutionInfo,
    this.idHolderType,
    this.idDocType,
    this.authorizeLetterCopy,
    this.idCardInfo,
    this.idDocInfo,
    this.owner,
    this.accountInfo,
    this.contactInfo,
    this.salesSceneInfo,
    this.settlementInfo,
    this.merchantShortname,
    this.qualifications,
    this.businessAdditionPics,
    this.businessAdditionDesc,
    this.uboInfoList,
  });

  Map<String, dynamic> toJson() {
    return {
      'organization_type': organizationType,
      'finance_institution': financeInstitution ?? false,
      'business_license_info': businessLicenseInfo?.toJson(),
      'finance_institution_info': financeInstitutionInfo?.toJson(),
      'id_holder_type': idHolderType,
      'id_doc_type': idDocType,
      'authorize_letter_copy': authorizeLetterCopy,
      'id_card_info': idCardInfo?.toJson(),
      'id_doc_info': idDocInfo?.toJson(),
      'owner': owner,
      'account_info': accountInfo?.toJson(),
      'contact_info': contactInfo?.toJson(),
      'sales_scene_info': salesSceneInfo?.toJson(),
      'settlement_info': settlementInfo?.toJson(),
      'merchant_shortname': merchantShortname,
      'qualifications': qualifications,
      'business_addition_pics': businessAdditionPics,
      'business_addition_desc': businessAdditionDesc,
      'ubo_info_list': uboInfoList?.map((ubo) => ubo.toJson()).toList(),
    };
  }

  static String getBusinessLicenseHint(String? selectedOrganizationType) {
    switch (selectedOrganizationType) {
      case '2401': // 小微商户
      case '2500': // 个人卖家
        return '无需填写';
      case '4': // 个体工商户
      case '2': // 企业
        return '请上传营业执照';
      case '3': // 事业单位
      case '2502': // 政府机关
      case '1708': // 社会组织
        return '请上传登记证书';
      default:
        return '请选择主体类型';
    }
  }
}

class BusinessLicenseInfo {
  String? certType;
  String? businessLicenseCopyUrl;
  String? businessLicenseCopy;
  String? businessLicenseNumber;
  String? merchantName;
  String? legalPerson;
  String? companyAddress;
  String? businessTime;

  BusinessLicenseInfo({
    this.certType,
    this.businessLicenseCopyUrl,
    this.businessLicenseCopy,    
    this.businessLicenseNumber,
    this.merchantName,
    this.legalPerson,
    this.companyAddress,
    this.businessTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'cert_type': certType,
      'business_license_copy_url': businessLicenseCopyUrl,
      'business_license_copy': businessLicenseCopy,
      'business_license_number': businessLicenseNumber,
      'merchant_name': merchantName,
      'legal_person': legalPerson,
      'company_address': companyAddress,
      'business_time': businessTime,
    };
  }
}

class FinanceInstitutionInfo {
  String? financeType;
  String? financeLicensePicsUrl;
  String? financeLicensePics;

  FinanceInstitutionInfo({
    this.financeType,
    this.financeLicensePicsUrl,
    this.financeLicensePics,
  });

  Map<String, dynamic> toJson() {
    return {
      'finance_type': financeType,
      'finance_license_pics_url': financeLicensePicsUrl,
      'finance_license_pics': financeLicensePics,
    };
  }
}

class IdCardInfo {
  String? idCardCopyUrl;
  String? idCardCopy;
  String? idCardNationalUrl;
  String? idCardNational;
  String? idCardName;
  String? idCardNumber;
  String? idCardValidTimeBegin;
  String? idCardValidTime;

  IdCardInfo({
    this.idCardCopyUrl,
    this.idCardCopy,
    this.idCardNationalUrl,
    this.idCardNational,
    this.idCardName,
    this.idCardNumber,
    this.idCardValidTimeBegin,
    this.idCardValidTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_card_copy_url': idCardCopyUrl,
      'id_card_copy': idCardCopy,
      'id_card_national_url': idCardNationalUrl,
      'id_card_national': idCardNational,
      'id_card_name': idCardName,
      'id_card_number': idCardNumber,
      'id_card_valid_time_begin': idCardValidTimeBegin,
      'id_card_valid_time': idCardValidTime,
    };
  }
}

class IdDocInfo {
  String? idDocName;
  String? idDocNumber;
  String? idDocCopyUrl;
  String? idDocCopy;
  String? idDocCopyBackUrl;
  String? idDocCopyBack;
  String? docPeriodBegin;
  String? docPeriodEnd;

  IdDocInfo({
    this.idDocName,
    this.idDocNumber,
    this.idDocCopyUrl,
    this.idDocCopy,
    this.idDocCopyBackUrl,
    this.idDocCopyBack,
    this.docPeriodBegin,
    this.docPeriodEnd,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_doc_name': idDocName,
      'id_doc_number': idDocNumber,
      'id_doc_copy_url': idDocCopyUrl,
      'id_doc_copy': idDocCopy,
      'id_doc_copy_back_url': idDocCopyBackUrl,
      'id_doc_copy_back': idDocCopyBack,
      'doc_period_begin': docPeriodBegin,
      'doc_period_end': docPeriodEnd,
    };
  }
}

class AccountInfo {
  String? bankAccountType;
  String? accountBank;
  String? accountName;
  String? bankAddressCode;
  String? bankBranchId;
  String? bankName;
  String? accountNumber;

  AccountInfo({
    this.bankAccountType,
    this.accountBank,
    this.accountName,
    this.bankAddressCode,
    this.bankBranchId,
    this.bankName,
    this.accountNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'bank_account_type': bankAccountType,
      'account_bank': accountBank,
      'account_name': accountName,
      'bank_address_code': bankAddressCode,
      'bank_branch_id': bankBranchId,
      'bank_name': bankName,
      'account_number': accountNumber,
    };
  }
}

class ContactInfo {
  String? contactType;
  String? contactName;
  String? contactIdDocType;
  String? contactIdCardNumber;
  String? contactIdDocCopyUrl;
  String? contactIdDocCopy;
  String? contactIdDocCopyBackUrl;
  String? contactIdDocCopyBack;
  String? contactPeriodBegin;
  String? contactPeriodEnd;
  String? businessAuthorizationLetterUrl;
  String? businessAuthorizationLetter;
  String? mobilePhone;

  ContactInfo({
    this.contactType,
    this.contactName,
    this.contactIdDocType,
    this.contactIdCardNumber,
    this.contactIdDocCopyUrl,
    this.contactIdDocCopy,
    this.contactIdDocCopyBackUrl,
    this.contactIdDocCopyBack,
    this.contactPeriodBegin,
    this.contactPeriodEnd,
    this.businessAuthorizationLetterUrl,
    this.businessAuthorizationLetter,
    this.mobilePhone,
  });

  Map<String, dynamic> toJson() {
    return {
      'contact_type': contactType,
      'contact_name': contactName,
      'contact_id_doc_type': contactIdDocType,
      'contact_id_card_number': contactIdCardNumber,
      'contact_id_doc_copy_url': contactIdDocCopyUrl,
      'contact_id_doc_copy': contactIdDocCopy,
      'contact_id_doc_copy_back_url': contactIdDocCopyBackUrl,
      'contact_id_doc_copy_back': contactIdDocCopyBack,
      'contact_period_begin': contactPeriodBegin,
      'contact_period_end': contactPeriodEnd,
      'business_authorization_letter_url': businessAuthorizationLetterUrl,
      'business_authorization_letter': businessAuthorizationLetter,
      'mobile_phone': mobilePhone,
    };
  }
}

class SalesSceneInfo {
  String? storeName;
  String? storeUrl;
  String? storeQrCodeUrl;
  String? storeQrCode;
  String? miniProgramSubAppid;

  SalesSceneInfo({
    this.storeName,
    this.storeUrl,
    this.storeQrCodeUrl,
    this.storeQrCode,
    this.miniProgramSubAppid,
  });

  Map<String, dynamic> toJson() {
    return {
      'store_name': storeName,
      'store_url': storeUrl,
      'store_qr_code_url': storeQrCodeUrl,
      'store_qr_code': storeQrCode,
      'mini_program_sub_appid': miniProgramSubAppid,
    };
  }
}

class SettlementInfo {
  int? settlementId;
  String? qualificationType;

  SettlementInfo({
    this.settlementId,
    this.qualificationType,
  });

  Map<String, dynamic> toJson() {
    return {
      'settlement_id': settlementId,
      'qualification_type': qualificationType,
    };
  }
}

class UboInfo {
  String? uboIdDocType;
  String? uboIdDocCopy;
  String? uboIdDocCopyBack;
  String? uboIdDocName;
  String? uboIdDocNumber;
  String? uboIdDocAddress;
  String? uboIdDocPeriodBegin;
  String? uboIdDocPeriodEnd;

  UboInfo({
    this.uboIdDocType,
    this.uboIdDocCopy,
    this.uboIdDocCopyBack,
    this.uboIdDocName,
    this.uboIdDocNumber,
    this.uboIdDocAddress,
    this.uboIdDocPeriodBegin,
    this.uboIdDocPeriodEnd,
  });

  Map<String, dynamic> toJson() {
    return {
      'ubo_id_doc_type': uboIdDocType,
      'ubo_id_doc_copy': uboIdDocCopy,
      'ubo_id_doc_copy_back': uboIdDocCopyBack,
      'ubo_id_doc_name': uboIdDocName,
      'ubo_id_doc_number': uboIdDocNumber,
      'ubo_id_doc_address': uboIdDocAddress,
      'ubo_id_doc_period_begin': uboIdDocPeriodBegin,
      'ubo_id_doc_period_end': uboIdDocPeriodEnd,
    };
  }
}
// 在 merchant_common.dart 文件中添加以下内容

class OrganizationType {
  static const List<Map<String, String>> organizationTypes = [
    {'value': '2401', 'label': '小微商户'},
    {'value': '2500', 'label': '个人卖家'},
    {'value': '4', 'label': '个体工商户'},
    {'value': '2', 'label': '企业'},
    {'value': '3', 'label': '事业单位'},
    {'value': '2502', 'label': '政府机关'},
    {'value': '1708', 'label': '社会组织'},
  ];

  static String? getType(String value) {
    for (var type in organizationTypes) {
      if (type['value'] == value) {
        return type['label'];
      }
    }
    return null;
  }
}

class CertificateType {
  static const List<Map<String, String>> certificateTypes = [
    {'value': 'CERTIFICATE_TYPE_2388', 'label': '事业单位法人证书'},
    {'value': 'CERTIFICATE_TYPE_2389', 'label': '统一社会信用代码证书'},
    {'value': 'CERTIFICATE_TYPE_2394', 'label': '社会团体法人登记证书'},
    {'value': 'CERTIFICATE_TYPE_2395', 'label': '民办非企业单位登记证书'},
    {'value': 'CERTIFICATE_TYPE_2396', 'label': '基金会法人登记证书'},
    {'value': 'CERTIFICATE_TYPE_2399', 'label': '宗教活动场所登记证'},
    {'value': 'CERTIFICATE_TYPE_2400', 'label': '政府部门下发的其他有效证明文件'},
    {'value': 'CERTIFICATE_TYPE_2520', 'label': '执业许可证/执业证'},
    {'value': 'CERTIFICATE_TYPE_2521', 'label': '基层群众性自治组织特别法人统一社会信用代码证'},
    {'value': 'CERTIFICATE_TYPE_2522', 'label': '农村集体经济组织登记证'},
  ];

  // 新增证件类型列表
  static const List<Map<String, String>> idDocTypes = [
    {'value': 'IDENTIFICATION_TYPE_MAINLAND_IDCARD', 'label': '中国大陆居民-身份证'},
    {'value': 'IDENTIFICATION_TYPE_OVERSEA_PASSPORT', 'label': '其他国家或地区居民-护照'},
    {'value': 'IDENTIFICATION_TYPE_HONGKONG', 'label': '中国香港居民--来往内地通行证'},
    {'value': 'IDENTIFICATION_TYPE_MACAO', 'label': '中国澳门居民--来往内地通行证'},
    {'value': 'IDENTIFICATION_TYPE_TAIWAN', 'label': '中国台湾居民--来往大陆通行证'},
    {'value': 'IDENTIFICATION_TYPE_FOREIGN_RESIDENT', 'label': '外国人居留证'},
    {'value': 'IDENTIFICATION_TYPE_HONGKONG_MACAO_RESIDENT', 'label': '港澳居民证'},
    {'value': 'IDENTIFICATION_TYPE_TAIWAN_RESIDENT', 'label': '台湾居民证'},
  ];
}

enum FinanceInstitutionType {
  bankAgent,
  paymentAgent,
  insurance,
  tradeAndSettle,
  other
}

extension FinanceInstitutionTypeExt on FinanceInstitutionType {
  String getVal() {
    switch (this) {
      case FinanceInstitutionType.bankAgent:
        return 'BANK_AGENT';
      case FinanceInstitutionType.paymentAgent:
        return 'PAYMENT_AGENT';
      case FinanceInstitutionType.insurance:
        return 'INSURANCE';
      case FinanceInstitutionType.tradeAndSettle:
        return 'TRADE_AND_SETTLE';
      case FinanceInstitutionType.other:
        return 'OTHER';
    }
  }

  String getDesc() {
    switch (this) {
      case FinanceInstitutionType.bankAgent:
        return '商业银行、政策性银行、农村合作银行、村镇银行、开发性金融机构等';
      case FinanceInstitutionType.paymentAgent:
        return '非银行类支付机构';
      case FinanceInstitutionType.insurance:
        return '保险、保险中介、保险代理、保险经纪等保险类业务';
      case FinanceInstitutionType.tradeAndSettle:
        return '交易所、登记结算类机构、银行卡清算机构、资金清算中心等';
      case FinanceInstitutionType.other:
        return '财务公司、信托公司、金融资产管理公司、金融租赁公司、汽车金融公司、贷款公司、货币经纪公司、消费金融公司、证券业、金融控股公司、股票、期货、货币兑换、小额贷款公司、金融资产管理、担保公司、商业保理公司、典当行、融资租赁公司、财经咨询等其他金融业务';
    }
  }

  static FinanceInstitutionType? getType(String val) {
    for (FinanceInstitutionType type in FinanceInstitutionType.values) {
      if (type.getVal() == val) {
        return type;
      }
    }
    return null;
  }

}

/// 银行信息模型
class BankInfo {
  final String bankAlias;
  final String bankAliasCode;
  final String accountBank;
  final String accountBankCode;
  final bool needBankBranch;

  BankInfo({
    required this.bankAlias,
    required this.bankAliasCode,
    required this.accountBank,
    required this.accountBankCode,
    required this.needBankBranch,
  });
}

/// 银行列表响应模型
// 在 merchant_common.dart 文件中
class PersonalBankingResult {
  final List<Bank> banks;
  final int totalCount;
  final int count;
  final String message;
  final int code;

  PersonalBankingResult({
    required this.banks,
    required this.totalCount,
    required this.count,
    required this.message,
    required this.code,
  });

  factory PersonalBankingResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final banksData = data['data'] as List<dynamic>;
    
    return PersonalBankingResult(
      banks: banksData.map((bank) => Bank.fromJson(bank)).toList(),
      totalCount: data['total_count'] as int,
      count: data['count'] as int,
      message: json['message'] as String,
      code: json['code'] as int,
    );
  }
}

class Bank {
  final String bankAlias;
  final String bankAliasCode;
  final String accountBank;
  final String accountBankCode;
  final bool needBankBranch;

  Bank({
    required this.bankAlias,
    required this.bankAliasCode,
    required this.accountBank,
    required this.accountBankCode,
    required this.needBankBranch,
  });

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      bankAlias: json['bank_alias'] as String,
      bankAliasCode: json['bank_alias_code'].toString(),
      accountBank: json['account_bank'] as String,
      accountBankCode: json['account_bank_code'].toString(),
      needBankBranch: json['need_bank_branch'] as bool,
    );
  }
}
/// 对公银行列表响应模型
class CorporateBankingResult {
  final List<Bank> banks;
  final int totalCount;
  final int count;
  final String message;
  final int code;

  CorporateBankingResult({
    required this.banks,
    required this.totalCount,
    required this.count,
    required this.message,
    required this.code,
  });

  factory CorporateBankingResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final banksData = data['data'] as List<dynamic>;
    
    return CorporateBankingResult(
      banks: banksData.map((bank) => Bank.fromJson(bank)).toList(),
      totalCount: data['total_count'] as int,
      count: data['count'] as int,
      message: json['message'] as String,
      code: json['code'] as int,
    );
  }
}

class BankBranchResult {
  final String bankBranchName;
  final String bankBranchId;

  BankBranchResult({
    required this.bankBranchName,
    required this.bankBranchId,
  });

  factory BankBranchResult.fromJson(Map<String, dynamic> json) {
    return BankBranchResult(
      bankBranchName:  json['bank_branch_name'] as String,
      bankBranchId: json['bank_branch_id'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'bank_branch_name': bankBranchName,
      'bank_branch_id': bankBranchId,
    };
  }
  @override
  String toString() {
    return 'bank_branch_name: $bankBranchName, bank_branch_id: $bankBranchId';
  }
}

class ProvinceResult {
  final String provinceName;
  final String provinceCode;

  ProvinceResult({
    required this.provinceName,
    required this.provinceCode,
  });

  factory ProvinceResult.fromJson(Map<String, dynamic> json) {
    return ProvinceResult(
      provinceName: json['province_name'] as String,
      provinceCode: json['province_code'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'province_name': provinceName,
      'province_code': provinceCode,
    };
  }
}

class CityResult {
  final String cityName;
  final String cityCode;

  CityResult({
    required this.cityName,
    required this.cityCode,
  });

  factory CityResult.fromJson(Map<String, dynamic> json) {
    return CityResult(
      cityName: json['city_name'] as String,
      cityCode: json['city_code'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city_name': cityName,
      'city_code': cityCode,
    };
  }
}

class MerchantWeChatData {
  final int? merchantId;
  final String? outRequestNo;
  final String? organizationType;
  final String? certType;
  final String? licenseCopyUrl;
  final String? licenseNumber;
  final String? merchantName;
  final String? legalPerson;
  final String? companyAddress;
  final String? businessTime;
  final bool? isFinanceInstitution;
  final String? financeType;
  final String? financeLicenseUrls;
  final String? idHolderType;
  final String? authorizeLetterUrl;
  final String? idCardUrl;
  final String? idCard;
  final String? idCardNationalUrl;
  final String? idCardName;
  final String? idCardNumber;
  final String? idCardAddress;
  final String? idCardValidTimeBegin;
  final String? idCardValidTimeEnd;
  final String? idDocType;
  final String? idDocName;
  final String? idDocNumber;
  final String? idDocCopyUrl;
  final String? idDocCopyBackUrl;
  final String? idDocAddress;
  final String? idDocPeriodBegin;
  final String? idDocPeriodEnd;
  final bool? isOwnner;
  final String? bankAccountType;
  final String? accountBankName;
  final String? accountPersonName;
  final String? bankAddressCode;
  final String? bankBranchId;
  final String? bankFullName;
  final String? accountNumber;
  final String? contactType;
  final String? contactName;
  final String? contactIdDocType;
  final String? contactIdDocNumber;
  final String? contactIdDocCopyUrl;
  final String? contactIdDocCopyBackUrl;
  final String? contactIdDocPeriodBegin;
  final String? contactIdDocPeriodEnd;
  final String? businessAuthorizeLetterUrl;
  final String? contactMobilePhone;
  final String? contactEmail;
  final String? storeName;
  final String? storeUrl;
  final String? storeQrCode;
  final String? miniProgramSubAppid;
  final int? settlementId;
  final String? qualificationType;
  final String? merchantShortName;
  final String? qualificationUrls;
  final String? businessAdditionPicUrls;
  final String? businessAdditionDesc;
  final String? createdAt;
  final String? updatedAt;
  final String? applymentState;
  final String? applymentStateDesc;
  final String? signUrl;
  final String? subMchid;
  final String? validationAccountName;
  final String? validationAccountNo;
  final int? validationPayAmount;
  final String? validationDestinationAccountNo;
  final String? validationDestinationAccountName;
  final String? validationDestinationAccountBank;
  final String? validationDestinationCity;
  final String? validationRemark;
  final String? validationDeadline;
  final String? auditInfo;
  final String? legalValidationUrl;
  final String? signState;

  MerchantWeChatData({
    this.merchantId,
    this.outRequestNo,
    this.organizationType,
    this.certType,
    this.licenseCopyUrl,
    this.licenseNumber,
    this.merchantName,
    this.legalPerson,
    this.companyAddress,
    this.businessTime,
    this.isFinanceInstitution,
    this.financeType,
    this.financeLicenseUrls,
    this.idHolderType,
    this.authorizeLetterUrl,
    this.idCardUrl,
    this.idCard,
    this.idCardNationalUrl,
    this.idCardName,
    this.idCardNumber,
    this.idCardAddress,
    this.idCardValidTimeBegin,
    this.idCardValidTimeEnd,
    this.idDocType,
    this.idDocName,
    this.idDocNumber,
    this.idDocCopyUrl,
    this.idDocCopyBackUrl,
    this.idDocAddress,
    this.idDocPeriodBegin,
    this.idDocPeriodEnd,
    this.isOwnner,
    this.bankAccountType,
    this.accountBankName,
    this.accountPersonName,
    this.bankAddressCode,
    this.bankBranchId,
    this.bankFullName,
    this.accountNumber,
    this.contactType,
    this.contactName,
    this.contactIdDocType,
    this.contactIdDocNumber,
    this.contactIdDocCopyUrl,
    this.contactIdDocCopyBackUrl,
    this.contactIdDocPeriodBegin,
    this.contactIdDocPeriodEnd,
    this.businessAuthorizeLetterUrl,
    this.contactMobilePhone,
    this.contactEmail,
    this.storeName,
    this.storeUrl,
    this.storeQrCode,
    this.miniProgramSubAppid,
    this.settlementId,
    this.qualificationType,
    this.merchantShortName,
    this.qualificationUrls,
    this.businessAdditionPicUrls,
    this.businessAdditionDesc,
    this.createdAt,
    this.updatedAt,
    this.applymentState,
    this.applymentStateDesc,
    this.signUrl,
    this.subMchid,
    this.validationAccountName,
    this.validationAccountNo,
    this.validationPayAmount,
    this.validationDestinationAccountNo,
    this.validationDestinationAccountName,
    this.validationDestinationAccountBank,
    this.validationDestinationCity,
    this.validationRemark,
    this.validationDeadline,
    this.auditInfo,
    this.legalValidationUrl,
    this.signState,
  });

factory MerchantWeChatData.fromJson(Map<String, dynamic> json) {
  return MerchantWeChatData(
    merchantId: json['merchantId'] as int?,
    outRequestNo: json['outRequestNo'] as String?,
    organizationType: json['organizationType'] as String?,
    certType: json['certType'] as String?,
    licenseCopyUrl: json['licenseCopyUrl'] as String?,
    licenseNumber: json['licenseNumber'] as String?,
    merchantName: json['merchantName'] as String?,
    legalPerson: json['legalPerson'] as String?,
    companyAddress: json['companyAddress'] as String?,
    businessTime: json['businessTime'] as String?,
    isFinanceInstitution: json['isFinanceInstitution'] as bool?,
    financeType: json['financeType'] as String?,
    financeLicenseUrls: json['financeLicenseUrls'] as String?,
    idHolderType: json['idHolderType'] as String?,
    authorizeLetterUrl: json['authorizeLetterUrl'] as String?,
    idCardUrl: json['idCardUrl'] as String?,
    idCard: json['idCard'] as String?,
    idCardNationalUrl: json['idCardNationalUrl'] as String?,
    idCardName: json['idCardName'] as String?,
    idCardNumber: json['idCardNumber'] as String?,
    idCardAddress: json['idCardAddress'] as String?,
    idCardValidTimeBegin: json['idCardValidTimeBegin'] as String?,
    idCardValidTimeEnd: json['idCardValidTimeEnd'] as String?,
    idDocType: json['idDocType'] as String?,
    idDocName: json['idDocName'] as String?,
    idDocNumber: json['idDocNumber'] as String?,
    idDocCopyUrl: json['idDocCopyUrl'] as String?,
    idDocCopyBackUrl: json['idDocCopyBackUrl'] as String?,
    idDocAddress: json['idDocAddress'] as String?,
    idDocPeriodBegin: json['idDocPeriodBegin'] as String?,
    idDocPeriodEnd: json['idDocPeriodEnd'] as String?,
    isOwnner: json['isOwnner'] as bool?,
    bankAccountType: json['bankAccountType'] as String?,
    accountBankName: json['accountBankName'] as String?,
    accountPersonName: json['accountPersonName'] as String?,
    bankAddressCode: json['bankAddressCode'] as String?,
    bankBranchId: json['bankBranchId'] as String?,
    bankFullName: json['bankFullName'] as String?,
    accountNumber: json['accountNumber'] as String?,
    contactType: json['contactType'] as String?,
    contactName: json['contactName'] as String?,
    contactIdDocType: json['contactIdDocType'] as String?,
    contactIdDocNumber: json['contactIdDocNumber'] as String?,
    contactIdDocCopyUrl: json['contactIdDocCopyUrl'] as String?,
    contactIdDocCopyBackUrl: json['contactIdDocCopyBackUrl'] as String?,
    contactIdDocPeriodBegin: json['contactIdDocPeriodBegin'] as String?,
    contactIdDocPeriodEnd: json['contactIdDocPeriodEnd'] as String?,
    businessAuthorizeLetterUrl: json['businessAuthorizeLetterUrl'] as String?,
    contactMobilePhone: json['contactMobilePhone'] as String?,
    contactEmail: json['contactEmail'] as String?,
    storeName: json['storeName'] as String?,
    storeUrl: json['storeUrl'] as String?,
    storeQrCode: json['storeQrCode'] as String?,
    miniProgramSubAppid: json['miniProgramSubAppid'] as String?,
    settlementId: json['settlementId'] as int?,
    qualificationType: json['qualificationType'] as String?,
    merchantShortName: json['merchantShortName'] as String?,
    qualificationUrls: json['qualificationUrls'] as String?,
    businessAdditionPicUrls: json['businessAdditionPicUrls'] as String?,
    businessAdditionDesc: json['businessAdditionDesc'] as String?,
    createdAt: json['createdAt'] as String?,
    updatedAt: json['updatedAt'] as String?,
    applymentState: json['applymentState'] as String? ?? '未申请',
    applymentStateDesc: json['applymentStateDesc'] as String?,
    signUrl: json['signUrl'] as String?,
    subMchid: json['subMchid'] as String?,
    validationAccountName: json['validationAccountName'] as String?,
    validationAccountNo: json['validationAccountNo'] as String?,
    validationPayAmount: json['validationPayAmount'] as int?,
    validationDestinationAccountNo: json['validationDestinationAccountNo'] as String?,
    validationDestinationAccountName: json['validationDestinationAccountName'] as String?,
    validationDestinationAccountBank: json['validationDestinationAccountBank'] as String?,
    validationDestinationCity: json['validationDestinationCity'] as String?,
    validationRemark: json['validationRemark'] as String?,
    validationDeadline: json['validationDeadline'] as String?,
    auditInfo: json['auditInfo'] as String?, // 直接保留原始JSON字符串
    legalValidationUrl: json['legalValidationUrl'] as String?,
    signState: json['signState'] as String?,
  );
}

Map<String, dynamic> toJson() {
  return {
    'merchantId': merchantId,
    'outRequestNo': outRequestNo,
    'organizationType': organizationType,
    'certType': certType,
    'licenseCopyUrl': licenseCopyUrl,
    'licenseNumber': licenseNumber,
    'merchantName': merchantName,
    'legalPerson': legalPerson,
    'companyAddress': companyAddress,
    'businessTime': businessTime,
    'isFinanceInstitution': isFinanceInstitution,
    'financeType': financeType,
    'financeLicenseUrls': financeLicenseUrls,
    'idHolderType': idHolderType,
    'authorizeLetterUrl': authorizeLetterUrl,
    'idCardUrl': idCardUrl,
    'idCard': idCard,
    'idCardNationalUrl': idCardNationalUrl,
    'idCardName': idCardName,
    'idCardNumber': idCardNumber,
    'idCardAddress': idCardAddress,
    'idCardValidTimeBegin': idCardValidTimeBegin,
    'idCardValidTimeEnd': idCardValidTimeEnd,
    'idDocType': idDocType,
    'idDocName': idDocName,
    'idDocNumber': idDocNumber,
    'idDocCopyUrl': idDocCopyUrl,
    'idDocCopyBackUrl': idDocCopyBackUrl,
    'idDocAddress': idDocAddress,
    'idDocPeriodBegin': idDocPeriodBegin,
    'idDocPeriodEnd': idDocPeriodEnd,
    'isOwnner': isOwnner,
    'bankAccountType': bankAccountType,
    'accountBankName': accountBankName,
    'accountPersonName': accountPersonName,
    'bankAddressCode': bankAddressCode,
    'bankBranchId': bankBranchId,
    'bankFullName': bankFullName,
    'accountNumber': accountNumber,
    'contactType': contactType,
    'contactName': contactName,
    'contactIdDocType': contactIdDocType,
    'contactIdDocNumber': contactIdDocNumber,
    'contactIdDocCopyUrl': contactIdDocCopyUrl,
    'contactIdDocCopyBackUrl': contactIdDocCopyBackUrl,
    'contactIdDocPeriodBegin': contactIdDocPeriodBegin,
    'contactIdDocPeriodEnd': contactIdDocPeriodEnd,
    'businessAuthorizeLetterUrl': businessAuthorizeLetterUrl,
    'contactMobilePhone': contactMobilePhone,
    'contactEmail': contactEmail,
    'storeName': storeName,
    'storeUrl': storeUrl,
    'storeQrCode': storeQrCode,
    'miniProgramSubAppid': miniProgramSubAppid,
    'settlementId': settlementId,
    'qualificationType': qualificationType,
    'merchantShortName': merchantShortName,
    'qualificationUrls': qualificationUrls,
    'businessAdditionPicUrls': businessAdditionPicUrls,
    'businessAdditionDesc': businessAdditionDesc,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'applymentState': applymentState,
    'applymentStateDesc': applymentStateDesc,
    'signUrl': signUrl,
    'subMchid': subMchid,
    'validationAccountName': validationAccountName,
    'validationAccountNo': validationAccountNo,
    'validationPayAmount': validationPayAmount,
    'validationDestinationAccountNo': validationDestinationAccountNo,
    'validationDestinationAccountName': validationDestinationAccountName,
    'validationDestinationAccountBank': validationDestinationAccountBank,
    'validationDestinationCity': validationDestinationCity,
    'validationRemark': validationRemark,
    'validationDeadline': validationDeadline,
    'auditInfo': auditInfo, // 直接保留原始JSON字符串
    'legalValidationUrl': legalValidationUrl,
    'signState': signState,
  };
}
  // 重写 toString() 方便调试
  /**@override
  String toString() {
    return JsonEncoder.withIndent('  ').convert(toJson());
  }**/
}