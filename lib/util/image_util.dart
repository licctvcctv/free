import 'dart:io';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class ImageUtil {
  ImageUtil._(); // 私有构造函数

  /// 获取通用的 AssetPickerConfig 配置
  static AssetPickerConfig buildDefaultImagePickerConfig({int maxAssets = 1}) {
    return AssetPickerConfig(
      maxAssets: maxAssets,
      requestType: RequestType.image,
      pathNameBuilder: (AssetPathEntity path) {
        print("选择器目录: ${path.name}");
        switch (path.name) {
          case 'Recent':
          case 'Recents':
            return Platform.isIOS ? '最近项目' : '图片';
          case 'Camera':
            return '相机';
          case 'Screenshots':
            return '截屏';
          case 'Live Photos':
            return '实况照片';
          case 'Panoramas':
            return '全景照片';
          case 'Favorites':
            return '个人收藏';
          case 'Selfies':
            return '自拍';
          case 'Portrait':
            return '人像';
          case 'Bursts':
            return '连拍';
          case 'WeiXin':
            return '微信';
          case 'Download':
            return '下载';
          default:
            return path.name;
        }
      },
    );
  }
}
