
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/circle_neo/circle_common.dart';
import 'package:freego_flutter/components/circle_neo/detail/circle_activity_apply_http.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/http/http_tool.dart';
import 'package:freego_flutter/util/dictionary_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';

class CircleActivityApplyPage extends StatelessWidget{
  final CircleActivity circle;
  const CircleActivityApplyPage(this.circle, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 10,
        backgroundColor: ThemeUtil.backgroundColor,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: CircleActivityApplyWidget(circle),
      ),
    );
  }
  
}

class CircleActivityApplyWidget extends StatefulWidget{
  final CircleActivity circle;
  const CircleActivityApplyWidget(this.circle, {super.key});

  @override
  State<StatefulWidget> createState() {
    return CircleActivityApplyState();
  }

}

class CircleActivityApplyState extends State<CircleActivityApplyWidget>{

  static const double PADDING_TOP = 120;
  static const double AVATAR_SIZE = 80;
  static const double BACKUP_PADDING_VERTICAL = 50;
  static const double BACKUP_HEIGHT = 50;
  static const double SUBMIT_HEIGHT = 50;
  static const double SUBMIT_WIDTH = 200;

  TextEditingController textController = TextEditingController();

  @override
  void dispose(){
    textController.dispose();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    textController.text = '我对这次旅行很感兴趣，希望能够加入~';
  }

  @override
  Widget build(BuildContext context) {
    CircleActivity circle = widget.circle;
    return Container(
      color: ThemeUtil.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonHeader(
            center: Text('报 名', style: TextStyle(color: Colors.white, fontSize: 18),),
          ),
          ListView(
            padding: EdgeInsets.zero,
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            children: [
              Column(
                children: [
                  const SizedBox(height: PADDING_TOP,),
                  ClipOval(
                    child: SizedBox(
                      width: AVATAR_SIZE,
                      height: AVATAR_SIZE,
                      child: circle.authorHead == null ?
                      ThemeUtil.defaultUserHead :
                      Image.network(getFullUrl(circle.authorHead!), width: double.infinity, height: double.infinity, fit: BoxFit.fill,)
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Text(circle.authorName ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor),)
                ],
              ),
              const SizedBox(height: 60,),
              Container(
                padding: const EdgeInsets.fromLTRB(BACKUP_PADDING_VERTICAL, 0, BACKUP_PADDING_VERTICAL, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('备注信息：', style: TextStyle(color: Colors.grey),),
                    const SizedBox(height: 10,),
                    Container(
                      height: BACKUP_HEIGHT,
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
                        controller: textController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.all(4),
                          counterText: '',
                        ),
                        maxLength: DictionaryUtil.FRIEND_APPLY_BACKUP_MAX_LENGTH,
                        style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 15),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 40,),
              Column(
                children: [
                  SizedBox(
                    width: SUBMIT_WIDTH,
                    height: SUBMIT_HEIGHT,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: Colors.lightBlue,
                      ),
                      onPressed: (){
                        if(circle.id == null){
                          ToastUtil.error('数据错误');
                          return;
                        }
                        CircleActivityApplyHttp().apply(circleId: circle.id!, remark: textController.text, success: (response){
                          int? code = response.data['code'];
                          if(code == ResultCode.RES_OK){
                            ToastUtil.hint('报名成功');
                          }
                        }, fail: (response){
                          int? code = response.data['code'];
                          if(code == ResultCode.RES_CREATED){
                            ToastUtil.hint('已报名');
                          }
                          else if(code == ResultCode.RES_DOING){
                            ToastUtil.hint('报名处理中');
                          }
                          else{
                            ToastUtil.error('报名失败');
                          }
                        });
                      }, 
                      child: const Text('发 送', style: TextStyle(color: Colors.white),),
                    ),
                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  }

}