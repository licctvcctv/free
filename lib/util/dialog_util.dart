
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/user/login.dart';
import 'package:freego_flutter/components/view/simple_input.dart';
import 'package:freego_flutter/config/callbacks.dart';
import 'package:freego_flutter/data/complain_type.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/http/http_complain.dart';
import 'package:freego_flutter/model/order_customer.dart';
import 'package:freego_flutter/util/context_util.dart';
import 'package:freego_flutter/util/file_upload_util.dart';
import 'package:freego_flutter/util/local_user.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' as foundation;

typedef OnVideoBtnCallback = void Function();

class DialogUtil {
  static BuildContext? progressContext;

  static Future<void> showEmojiModal(TextEditingController controller) async{
    BuildContext? context = ContextUtil.getContext();
    if(context == null){
      return;
    }
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context){
      return SizedBox(
        height: SimpleInputState.EMOJI_LIST_HEIGHT,
        child: EmojiPicker(
          textEditingController: controller,
          config: Config(
            columns: 7,
            emojiSizeMax: 32 * (foundation.defaultTargetPlatform == TargetPlatform.iOS ? 1.30 : 1.0), // Issue: https://github.com/flutter/flutter/issues/28894
            verticalSpacing: 0,
            horizontalSpacing: 0,
            gridPadding: EdgeInsets.zero,
            initCategory: Category.RECENT,
            indicatorColor: Colors.blue,
            iconColor: Colors.grey,
            iconColorSelected: Colors.blue,
            backspaceColor: Colors.blue,
            skinToneDialogBgColor: Colors.white,
            skinToneIndicatorColor: Colors.grey,
            enableSkinTones: true,
            recentTabBehavior: RecentTabBehavior.RECENT,
            recentsLimit: 28,
            noRecents: const Text(
              '暂无历史记录',
              style: TextStyle(fontSize: 20, color: Colors.black26),
              textAlign: TextAlign.center,
            ), // Needs to be const Widget
            loadingIndicator: const SizedBox.shrink(), // Needs to be const Widget
            tabIndicatorAnimDuration: kTabScrollDuration,
            categoryIcons: const CategoryIcons(),
            buttonMode: ButtonMode.MATERIAL,
          ),
        ),
      );
    });
  }

  static Future<bool> showConfirm(BuildContext context, {required String info, Function? fail, Function? success, String confirmText = '确认', String cancelText = '取消'}) async{
    bool result= false;
    if(context.mounted){
      await showGeneralDialog(
        barrierColor: Colors.transparent,
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
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 4
                      )
                    ]
                  ),
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(info, style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 22),),
                      const SizedBox(height: 18,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: (){
                              Navigator.of(context).pop();
                              fail?.call();
                            },
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 4
                                  )
                                ]
                              ),
                              alignment: Alignment.center,
                              child: Text(cancelText, style: const TextStyle(color: ThemeUtil.buttonColor, fontSize: 16),),
                            ),
                          ),
                          TextButton(
                            onPressed: (){
                              Navigator.of(context).pop();
                              success?.call();
                            },
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                              decoration: const BoxDecoration(
                                color: ThemeUtil.buttonColor,
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 4
                                  )
                                ]
                              ),
                              alignment: Alignment.center,
                              child: Text(confirmText, style: const TextStyle(color: Colors.white, fontSize: 16),),
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
    }
    return result;
  }

  static showVideoDlg(BuildContext context,OnVideoBtnCallback uploadVideo,OnVideoBtnCallback takeVideo) {
    showDialog(context: context,builder: (BuildContext buildContext){
      return Center(
        child: Container(
          decoration: const BoxDecoration(
            color:Color.fromRGBO(255, 255, 255, 0.5),
            borderRadius: BorderRadius.all(Radius.circular(6))
          ),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child:Column(
            // direction: Axis.vertical,
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: (){
                  Navigator.of(buildContext).pop();
                  uploadVideo();
                },
                child: Wrap(
                  direction: Axis.horizontal,
                  children: const [
                    Icon(Icons.upload),
                    SizedBox(width: 10,),
                    Text('上传视频')
                  ],    
                ),
              ),
              const SizedBox(height: 10,),
              ElevatedButton(
                onPressed: (){
                  Navigator.of(buildContext).pop();
                  takeVideo();
                },
                child: Wrap(
                  direction: Axis.horizontal,
                  children: const[
                    Icon(Icons.video_call),
                    SizedBox(width: 10,),
                    Text('拍摄视频')
                  ],      
                ),
              ),
            ],
          )
        )
      );
    });
  }

  static showProgressDlg(BuildContext context) {
    showDialog(
      barrierColor: Colors.transparent,
      context: context,
      builder: (BuildContext buildContext){
        progressContext = buildContext;
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          child: const Center( child:CircularProgressIndicator()
        )
      );
    });
  }

  static closeProgressDlg() {
    if(progressContext!=null) {
      Navigator.of(progressContext!).pop();
      progressContext = null;
    }
  }

  static Future<bool> loginRedirectConfirm(BuildContext context, {String? hint, OnLoginCallback? callback}) async {
    bool isLogin =  LocalUser.isLogined();
    callback?.call(isLogin);
    if(isLogin) {
      return true;
    }
    hint ??= "需要登录后才能进入，是否登录？";
    if(context.mounted){
      await showDialog(
        context: context,
        builder: (buildContext){
          return AlertDialog(
            title: const Text('提示'),
            content: Text(hint!),
            actions: [
              FilledButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith((states) {
                    return Colors.grey;
                  }),
                ),
                onPressed: (){
                  Navigator.of(buildContext).pop();
                },
                child: const Text('取消')
              ),
              FilledButton(
                onPressed: () async{
                  Navigator.of(buildContext).pop();
                  await Navigator.push(context, MaterialPageRoute(
                    builder: (type) {
                      return const LoginPage();
                  }));
                  callback?.call(LocalUser.isLogined());
                }, 
                child: const Text('确定')
              )
            ],
          );
        }
      );
    }
    return isLogin;
  }

  static showComplainDialog(BuildContext context,int productType,int productId) async {

    List<ComplainType> complainTypeList = [
      ComplainType(1,'色情低俗'),
      ComplainType(2,'政治敏感'),
      ComplainType(3, '造谣宣传'),
      ComplainType(4,'涉嫌欺诈'),
      ComplainType(5, '侵犯权益'),
      ComplainType(6, '违法犯罪'),
      ComplainType(7, '其他')
    ];
    List<DropdownMenuItem<ComplainType>> itemList = complainTypeList.map<DropdownMenuItem<ComplainType>>((ComplainType value) {
      return DropdownMenuItem<ComplainType>(
        value: value,
        child: Text(value.name,),
      );
    }).toList();
    ComplainType? complainType2;
    List<String> imageList = [];
    String content='';
    await showModalBottomSheet(context: context,isScrollControlled:true,backgroundColor: Colors.transparent,
      builder: (buildContext) {
        return  Padding(
          padding: EdgeInsets.only(
            bottom:  MediaQuery.of(buildContext).viewInsets.bottom,
          ),//,
          child: StatefulBuilder(builder: (context2,setState){
            List<Widget> imageViews = imageList.map<Widget>((imagePath) =>
              Container(
                height: 50,
                width: 50,                         
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4)
                ),
                margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child:Image.network(getFullUrl(imagePath),width: 50,height: 50,)
              )
            ).toList();
            return Container(
              width: double.infinity,
              height: 400,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              decoration: const BoxDecoration(
                color:Color.fromRGBO(242, 245, 250, 1),
                  borderRadius: BorderRadius.vertical(top:Radius.circular(8))
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                    ),
                    Container(
                      width: double.infinity,
                      child: const Text('举报类型',)
                    ),
                    const SizedBox(height: 8,),
                    Container(
                      height: 36,
                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black.withOpacity(0.1),width: 2),
                        color:Colors.white,
                        borderRadius: BorderRadius.circular(4)
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<ComplainType>(
                          value: complainType2,
                          onChanged:(value){
                            setState((){
                              complainType2 = value;
                            });
                          } ,
                          items: itemList,
                        )
                      )
                    ),
                    const SizedBox(height: 8,),
                    Container(
                      width: double.infinity,
                      child: const Text('详细描投述原因',)
                    ),
                    const SizedBox(height: 8,),
                    Container(
                      width: double.infinity,
                      child: TextField(
                        minLines: 4,
                        maxLines: 4,
                        onChanged: (value){
                          if(value.trim().length>400) {
                            return;
                          }
                          setState((){
                            content = value.trim();
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Colors.white)),
                                    //获取焦点情况下。
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Colors.white))
                        ),
                      )
                    ),
                    Container(
                      width: double.infinity,
                      alignment: Alignment.centerRight,
                      child:Text("${content.length}/400")
                    ),
                    const SizedBox(height: 10,),
                    Container(
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap:() async{
                              if(imageList.length>=4) {
                                ToastUtil.error("只能上传4张图片");
                                return;
                              }
                              final ImagePicker picker = ImagePicker();
                              final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                              if(image != null) {
                                String fileName = image.name;
                                String? imageUrl = await FileUploadUtil().upload(path: image.path);
                                if(imageUrl!=null) {
                                  setState((){
                                    imageList.add(imageUrl);
                                  });
                                }
                              }
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4)
                              ),
                              child:Column(
                                mainAxisSize:MainAxisSize.min,
                                children: [
                                  const Icon(Icons.camera_alt_outlined),
                                  Text('${imageList.length}/4',style: const TextStyle(fontSize: 12),)
                                ],
                              )
                            )
                          ),
                          Row(
                            children: imageViews,
                          )
                        ],
                      )
                    ),
                    const SizedBox(height: 10,),
                    Container(
                      alignment: Alignment.center,
                      child:  ElevatedButton(
                        onPressed: (){
                          try{
                            if(complainType2==null) {
                              throw "投诉类型不能为空";
                            }
                            if(StringUtil.isEmpty(content)) {
                              throw "详细描述不能为空";
                            }
                          }
                          catch(e) {
                            ToastUtil.error(e.toString());
                            return;
                          }
                          HttpComplain.add(complainType2!.id,productType, productId,imageList.join(','), content, (isSuccess,data,msg,code){
                            if(isSuccess) {
                              ToastUtil.hint("投诉成功");
                              Navigator.pop(buildContext);
                              return;
                            }
                            else {
                              ToastUtil.hint(msg??"投诉失败");
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(4, 182, 221, 1),
                          padding: const EdgeInsets.fromLTRB(40 ,10, 40, 10)
                        ),
                        child: const Text('提交',style:TextStyle(color:Colors.white)),
                      )
                    ),
                  ],
                )
              );
            }
          )
        );
      }
    );
  }

  static customerAddDlg(BuildContext context, OrderCustomer? customer) async {
    OrderCustomer result = await showModalBottomSheet(
      context: context, 
      isScrollControlled:true, 
      backgroundColor: Colors.transparent,
      builder: (buildContext) {
        return CustomerAddDialog(customer);
      }
    );
    return result;
  }

}

class CustomerAddDialog extends StatefulWidget{
  final OrderCustomer? customer;
  const CustomerAddDialog(this.customer, {super.key});

  @override
  State<StatefulWidget> createState() {
    return CustomerAddDialogState();
  }

}

class CustomerAddDialogState extends State<CustomerAddDialog>{

  late OrderCustomer customer;

  TextEditingController nameController = TextEditingController();
  TextEditingController identityNumController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  void initState(){
    super.initState();
    customer = widget.customer ?? OrderCustomer('', '', '');
    nameController.text = customer.name;
    identityNumController.text = customer.identityNum;
    phoneController.text = customer.phone;
  }

  @override
  void dispose(){
    nameController.dispose();
    identityNumController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom:  MediaQuery.of(context).viewInsets.bottom,
      ),
      child: StatefulBuilder(builder: (context2, setState){
        return GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Container(
            width: double.infinity,
            height: 400,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top:Radius.circular(8))
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.arrow_back_ios_new,size: 20,)
                      ),
                      Text(widget.customer == null ? '新增游客':'修改游客', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                      TextButton(
                        onPressed: (){
                          try{
                            if(StringUtil.isEmpty(customer.name)) {
                              throw "请填写姓名";
                            }
                            if(StringUtil.isEmpty(customer.identityNum)) {
                              throw "请填写身份证信息";
                            }
                            if(StringUtil.isEmpty(customer.phone)) {
                              throw "请填写电话";
                            }
                          }
                          catch(e) {
                            ToastUtil.error(e.toString());
                            return;
                          }
                          Navigator.pop(context, customer);
                        }, 
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('保存'), 
                      )
                    ],
                  )
                ),
                const SizedBox(height: 20,),
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: Row(
                    children: const [
                      Text('证件类型:',style: TextStyle(fontWeight: FontWeight.bold),),
                      SizedBox(width: 10,),
                      Text('身份证')
                    ],
                  )
                ),
                Divider(color: Colors.black.withOpacity(0.1),),
                Container(
                  child: Row(
                    children: [
                      const Text('姓       名:',style: TextStyle(fontWeight: FontWeight.bold),),
                      const SizedBox(width: 10,),
                      Expanded(
                        child: TextField(
                          controller: nameController,
                          onChanged: (val){
                            customer.name = val.trim();
                          },
                          decoration: const InputDecoration(
                            hintText: "与证件姓名一致",
                            border: InputBorder.none
                          ),
                        )
                      )
                    ],
                  )
                ),
                Divider(color: Colors.black.withOpacity(0.1),),
                Container(
                  padding: const EdgeInsets.fromLTRB(0,6,0,6),
                  child: Row(
                    children: [
                      const Text('证  件  号:',style: TextStyle(fontWeight: FontWeight.bold),),
                      const SizedBox(width: 10,),
                      Expanded(
                        child: TextField(
                          controller: identityNumController,
                          onChanged: (val){
                            customer.identityNum = val.trim();
                          },
                          decoration: const InputDecoration(
                            hintText: "身份证号码",
                            border: InputBorder.none
                          ),
                        )
                      )
                    ],
                  )
                ),
                Divider(color: Colors.black.withOpacity(0.1),),
                Container(
                  child: Row(
                    children: [
                      const Text('联系电话:' ,style: TextStyle(fontWeight: FontWeight.bold),),
                      const SizedBox(width: 10,),
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.phone,
                          controller: phoneController,
                          onChanged: (val){
                            customer.phone = val.trim();
                          },
                          decoration: const InputDecoration(
                            hintText: "该游客的手机号码",
                            border: InputBorder.none
                          ),
                        )
                      )
                    ],
                  )
                ),
              ],
            )
          )
        );
      })
    );
  }
  
}
