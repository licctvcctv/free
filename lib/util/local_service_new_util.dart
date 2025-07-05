import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:freego_flutter/util/storage.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';

class LocalServiceNewUtil {
  static const String _gpsDeniedKey = "gps_service_denied";
  
  LocalServiceNewUtil._internal();
  static final LocalServiceNewUtil _instance = LocalServiceNewUtil._internal();
  factory LocalServiceNewUtil() => _instance;

  final Location _location = Location();

  /// 检查GPS服务是否已启用
  Future<bool> checkServiceEnabled() async {
    return await _location.serviceEnabled();
  }

  /// 请求开启GPS服务
  Future<bool> requestService({required BuildContext context, String? info}) async {
    // 如果已经开启，直接返回true
    if (await checkServiceEnabled()) {
      await _removeRejectedService();
      return true;
    }

    // 检查是否之前被拒绝过
    if (await _isServiceRejected()) {
      return false;
    }

    // 显示提示对话框
    if (context.mounted) {
      dynamic result = await showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.transparent,
        barrierLabel: '',
        pageBuilder:(context, animation, secondaryAnimation) {
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
                        color: Colors.grey,
                        blurRadius: 4
                      )
                    ]
                  ),
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(info ?? '请开启定位服务以获取精确的位置信息', 
                           style: const TextStyle(color: ThemeUtil.foregroundColor, 
                                                  fontWeight: FontWeight.bold, 
                                                  fontSize: 18)),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: (){
                              _addRejectedService();
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                border: Border.fromBorderSide(BorderSide(color: ThemeUtil.foregroundColor))
                              ),
                              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                              child: const Text('拒 绝', 
                                              style: TextStyle(color: ThemeUtil.foregroundColor, 
                                                             fontSize: 16)),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              bool serviceEnabled = await _location.requestService();
                              if (!serviceEnabled) {
                                _addRejectedService();
                                ToastUtil.error('开启定位服务失败');
                              }
                              if (context.mounted) {
                                Navigator.of(context).pop(serviceEnabled);
                              }
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: ThemeUtil.buttonColor,
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                border: Border.fromBorderSide(BorderSide(color: ThemeUtil.buttonColor))
                              ),
                              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                              child: const Text('同 意', 
                                              style: TextStyle(color: Colors.white, 
                                                             fontSize: 16)),
                            ),
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

      return result == true;
    }
    return false;
  }

  // 以下为存储相关方法
  Future<bool> _isServiceRejected() async {
    return await Storage.readInfo<bool>(_gpsDeniedKey) ?? false;
  }

  Future<void> _addRejectedService() async {
    await Storage.saveInfo<bool>(_gpsDeniedKey, true);
  }

  Future<void> _removeRejectedService() async {
    await Storage.saveInfo<bool>(_gpsDeniedKey, false);
  }
}