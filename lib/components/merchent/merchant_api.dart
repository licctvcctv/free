import 'dart:convert';
import 'dart:io';

import 'package:city_pickers/modal/base_citys.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:freego_flutter/components/merchent/merchant_common.dart';
import 'package:freego_flutter/components/merchent/merchant_model.dart';
import 'package:freego_flutter/components/order_neo/order_common.dart';
import 'package:freego_flutter/http/http_tool.dart';

class MerchantApi{

  MerchantApi._internal();
  static final MerchantApi _instance = MerchantApi._internal();
  factory MerchantApi(){
    return _instance;
  }

  Future<Merchant?> getMerchant({required int id, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/user/merchantView';
    Merchant? merchant = await HttpTool.get(url, {
      'id': id
    }, (response){
      return Merchant.fromJson(response.data['data']);
    }, fail: fail, success: success);
    return merchant;
  }

  Future<bool> apply({required MerchantApplyParam param, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/merchant_apply';
    bool? result = await HttpTool.post(url, param.toJson(), (response){
      return true;
    }, fail: fail, success: success);
    return result ?? false;
  }

  /// 获取当前用户的商家申请信息
  Future<Map<String, dynamic>?> getApplyByMerchantId(int merchantId) async {
    const String url = '/merchant_apply/by-merchant';
    try {
      final response = await HttpTool.get(
        url,
        {'merchantId' : merchantId},
        (response) {
          if (response.data['code'] == 10200) {
            return response.data['data'] as Map<String, dynamic>?;
          } else if (response.data['code'] == 404) {
            return null;
          } else {
            //throw MerchantApplyException(response.data['message']);
          }
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PayType>?> listPayTypes({required int merchantId, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/merchant/payTypes';
    List<PayType>? list = await HttpTool.get(url, {
      'merchantId': merchantId
    }, (response){
      List<PayType> list = [];
      for(dynamic item in response.data['data']){
        if(item is String){
          PayType? payType = PayTypeExt.getTypeByName(item);
          if(payType != null){
            list.add(payType);
          }
        }
      }
      return list;
    }, fail: fail, success: success);
    return list;
  }


/// 查询支持个人业务的银行列表
Future<PersonalBankingResult?> getPersonalBanks({
  int offset = 0,
  int limit = 20,
}) async {
  const String url = '/merchant/wechat/personal-banking';
  
  try {
    final response = await HttpTool.get(
      url,
      {
        'offset': offset.toString(),
        'limit': limit.toString(),
      },
      (response) {
        return PersonalBankingResult.fromJson(response.data);
      },
    );

    return response;
  } catch (e, stackTrace) {
    return null;
  }
}

/// 查询支持对公业务的银行列表
Future<CorporateBankingResult?> getCorporateBanks({
  int offset = 0,
  int limit = 20,
}) async {
  const String url = '/merchant/wechat/corporate-banking';
  
  try {
    final response = await HttpTool.get(
      url,
      {
        'offset': offset.toString(),
        'limit': limit.toString(),
      },
      (response) {
        return CorporateBankingResult.fromJson(response.data);
      },
    );

    return response;
  } catch (e, stackTrace) {
    return null;
  }
}


/// 提交微信商户申请
Future<bool> applyWeChatMerchant({
  required WeChatMerchantInfo weChatMerchantInfo,
  Function(DioException)? onError,
  Function(Response)? onSuccess,
}) async {
  const String url = '/merchant/wechat/applyment/submit';
  
  try {
    final response = await HttpTool.post(
      url,
      weChatMerchantInfo.toJson(),
      (response) {
        // 检查返回的 code 是否为 10200（成功）
        if (response.data['code'] == 10200) {
          return true;
        } else {
          // 如果 code 不是 10200，抛出异常，携带错误信息
          final errorMessage = response.data['message'] ?? '提交失败';
          throw DioException(
            requestOptions: RequestOptions(path: url),
            response: response,
            error: errorMessage,
          );
        }
      },
    );

    if (response == true) {
      onSuccess?.call(Response(
        requestOptions: RequestOptions(path: url),
        data: {'message': '申请提交成功'},
      ));
      return true;
    } else {
      onError?.call(DioException(
        requestOptions: RequestOptions(path: url),
        error: '提交失败',
      ));
      return false;
    }
  } on DioException catch (e) {
    // 捕获 DioException，优先显示后端返回的 message
    final errorMessage = e.response?.data['message'] ?? e.message ?? '提交失败';    
    // 调用 onError 回调，传递错误信息
    onError?.call(DioException(
      requestOptions: RequestOptions(path: url),
      response: e.response,
      error: errorMessage,
    ));
    return false;
  } catch (e) {
    onError?.call(DioException(
      requestOptions: RequestOptions(path: url),
      error: '未知错误: $e',
    ));
    return false;
  }
}
/// 刷新审核状态
Future<bool> refreshApplyStatus({
  Function(DioException)? onError,
  Function(Response)? onSuccess,
}) async {
  const String url = '/merchant/wechat/applyment/refresh';
  
  try {
    final response = await HttpTool.post(
      url,
      {},
      (response) {
        if (response.data['code'] == 10200) {
          return true;
        } else {
          final errorMessage = response.data['message'] ?? '刷新失败';
          throw DioException(
            requestOptions: RequestOptions(path: url),
            response: response,
            error: errorMessage,
          );
        }
      },
    );

    if (response == true) {
      onSuccess?.call(Response(
        requestOptions: RequestOptions(path: url),
        data: {'message': '刷新成功'},
      ));
      return true;
    } else {
      onError?.call(DioException(
        requestOptions: RequestOptions(path: url),
        error: '刷新失败',
      ));
      return false;
    }
  } on DioException catch (e) {
    final errorMessage = e.response?.data['message'] ?? e.message ?? '刷新失败';
    onError?.call(DioException(
      requestOptions: RequestOptions(path: url),
      response: e.response,
      error: errorMessage,
    ));
    return false;
  } catch (e) {
    onError?.call(DioException(
      requestOptions: RequestOptions(path: url),
      error: '未知错误: $e',
    ));
    return false;
  }
}
    /// 上传商户资质文件
Future<String?> uploadMerchantFile({
  required File file,
  String? filename,
  Function(DioException)? onError,
  Function(Response)? onSuccess,
}) async {
  const String url = '/merchant/wechat/file-upload';
  
  try {
    // 修改：将formData改为直接传递文件路径
    final response = await HttpTool.upload(
      url,
      file.path, // 直接传递文件路径
      (response) {
        final mediaId = response.data['data']['media_id'] as String?;
        if (mediaId != null) {
          print('media_id: $mediaId'); // 打印media_id
        }
        return mediaId;
      },
      name: filename ?? file.path.split('/').last, // 使用name参数传递文件名
    );

    if (response != null) {
      onSuccess?.call(Response(
        requestOptions: RequestOptions(path: url),
        data: {'message': '文件上传成功', 'media_id': response},
      ));
      return response;
    } else {
      onError?.call(DioException(
        requestOptions: RequestOptions(path: url),
        response: Response(
          requestOptions: RequestOptions(path: url),
          data: {'message': '文件上传失败'},
        ),
      ));
      return null;
    }
  } on DioException catch (e) {
    onError?.call(e);
    return null;
  } catch (e) {
    onError?.call(DioException(
      requestOptions: RequestOptions(path: url),
      error: '未知错误: $e',
    ));
    return null;
  }
}

/// 查询银行支行列表
Future<List<BankBranchResult>?> getBankBranches({
  required String bankAliasCode,
  required String cityCode,
  int offset = 0,
  int limit = 20,
}) async {
  const String url = '/merchant/wechat/branches';
  
  try {
    // 打印请求参数便于调试    
    final response = await HttpTool.get(
      url,
      {
        'bankAliasCode': bankAliasCode,
        'cityCode': cityCode,
        'offset': offset.toString(),
        'limit': limit.toString(),
      },
      (response) {
        final data = response.data['data']['data']  as List;

        return data.map((e) => BankBranchResult.fromJson(e)).toList();        
      },
    );
    
    return response;
  } on DioException catch (e) {
    if (e.response != null) {
    }
    return null;
  } catch (e, stackTrace) {
    return null;
  }
}

  Future<List<ProvinceResult>?> getProvinces() async {
    const String url = '/merchant/wechat/provinces';
    try {
      // 打印请求信息便于调试
      final response = await HttpTool.get(
        url,
        {}, // 不需要参数
        (response) {
          // 解析响应数据
          final data = response.data['data']['data'] as List;
          return data.map((e) => ProvinceResult.fromJson(e)).toList();
        },
      );

      return response;
    } on DioException catch (e) {
      return null;
    } catch (e, stackTrace) {
      return null;
    }
  }

Future<List<CityResult>?> getCities(String provinceCode) async {
  const String url = '/merchant/wechat/cities';
  try {
    final response = await HttpTool.get(
      url,
      {
        'provinceCode': provinceCode,
      },
      (response) {
        final data = response.data['data']['data'] as List;
        return data.map((e) => CityResult.fromJson(e)).toList();
      },
    );

    return response;
  } on DioException catch (e) {
    if (e.response != null) {
    }
    return null;
  } catch (e, stackTrace) {
    return null;
  }
}

Future<Map<String, dynamic>?> getMerchantWeChat(int userId) async {
  const String url = '/merchant/wechat/merchantWeChat';
  try {
    final response = await HttpTool.get(url, {
      'userId': userId,
    }, (response) {
      if (response.data['code'] == 10200) {
        return response.data['data'] as Map<String, dynamic>?;
      } else {
        return null;
      }
    });
    return response;
  } catch (e) {
    return null;
  }
}

Future<Map<String, dynamic>?> getMerchantData() async {  // 移除userId参数
  final String url = '/merchant';  // 直接访问/merchant端点
  try {
    final response = await HttpTool.get(
      url,
      {}, 
      (response) {
        if (response.data['code'] == 10200 || response.data['code'] == 200) {
          return response.data['data'] as Map<String, dynamic>?;
        } else {
          throw Exception(response.data['message']);  // 抛出错误让上层处理
        }
      },
    );
    return response;
  } catch (e) {
    rethrow;  // 重新抛出异常
  }
}

  /// 发送验证码到邮箱
  Future<bool> sendVerificationCode({
    required String email,
    Function(DioException)? onError,
    Function(Response)? onSuccess,
  }) async {
    const String url = '/mail/code';
    try {
      final response = await HttpTool.post(
        url,
        {'email': email},
        (response) {
          if (response.data['code'] == 10200) {
            return true;
          } else {
            final errorMessage = response.data['message'] ?? '发送验证码失败';
            throw DioException(
              requestOptions: RequestOptions(path: url),
              response: response,
              error: errorMessage,
            );
          }
        },
      );

      if (response == true) {
        onSuccess?.call(Response(
          requestOptions: RequestOptions(path: url),
          data: {'message': '验证码发送成功'},
        ));
        return true;
      } else {
        onError?.call(DioException(
          requestOptions: RequestOptions(path: url),
          error: '发送验证码失败',
        ));
        return false;
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? e.message ?? '发送验证码失败';
      onError?.call(DioException(
        requestOptions: RequestOptions(path: url),
        response: e.response,
        error: errorMessage,
      ));
      return false;
    } catch (e) {
      onError?.call(DioException(
        requestOptions: RequestOptions(path: url),
        error: '未知错误: $e',
      ));
      return false;
    }
  }

  Future<bool> verifyEmailCode({
  required String email,
  required String code,
  Function(DioException)? onError,
  Function(Response)? onSuccess,
}) async {
  const String url = '/mail/verify';
  try {
    final response = await HttpTool.post(
      url,
      {'email': email, 'code': code},
      (response) {
        if (response.data['code'] == 10200) {
          return true;
        } else {
          final errorMessage = response.data['message'] ?? '验证码验证失败';
          throw DioException(
            requestOptions: RequestOptions(path: url),
            response: response,
            error: errorMessage,
          );
        }
      },
    );

    if (response == true) {
      onSuccess?.call(Response(
        requestOptions: RequestOptions(path: url),
        data: {'message': '验证码验证成功'},
      ));
      return true;
    } else {
      onError?.call(DioException(
        requestOptions: RequestOptions(path: url),
        error: '验证码验证失败',
      ));
      return false;
    }
  } on DioException catch (e) {
    final errorMessage = e.response?.data['message'] ?? e.message ?? '验证码验证失败';
    onError?.call(DioException(
      requestOptions: RequestOptions(path: url),
      response: e.response,
      error: errorMessage,
    ));
    return false;
  } catch (e) {
    onError?.call(DioException(
      requestOptions: RequestOptions(path: url),
      error: '未知错误: $e',
    ));
    return false;
  }
}
}


