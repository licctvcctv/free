
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:freego_flutter/components/comment/comment_dict.dart';
import 'package:freego_flutter/components/comment/comment_model.dart';
import 'package:freego_flutter/components/comment/comment_util.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/image_input.dart';
import 'package:freego_flutter/components/view/stars_picker.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';

class CommentCreatePage extends StatelessWidget{
  final int productId;
  final ProductType type;
  final String? productName;
  const CommentCreatePage(this.productId, this.type, {this.productName, super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 10,
        backgroundColor: ThemeUtil.backgroundColor,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: CommentCreateWidget(productId, type, productName: productName,),
      ),
    );
  }
  
}

class CommentCreateWidget extends StatefulWidget{
  final int productId;
  final ProductType productType;
  final String? productName;
  const CommentCreateWidget(this.productId, this.productType, {this.productName, super.key});

  @override
  State<StatefulWidget> createState() {
    return CommentCreateState();
  }

}

class CommentCreateState extends State<CommentCreateWidget>{

  final TextEditingController _controller = TextEditingController();
  int stars = 10;
  List<String> pics = [];
  bool onSubmit = false;

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeUtil.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonHeader(
            center: Text(widget.productName ?? '写评论', style: const TextStyle(color: Colors.white, fontSize: 18),),
          ),
          Expanded(
            child: Stack(
              children: [
                ListView(
                  padding: EdgeInsets.zero,
                  physics: const ClampingScrollPhysics(),
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(12))
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('        评分 ', style: TextStyle(color: Color.fromRGBO(0xc5, 0xc5, 0xc6, 1), fontSize: 18),),
                              StarsPickerWidget(afterPick: (rank){
                                stars = rank;
                                setState(() {
                                });
                              }),
                              Text('  ${CommentDict().tagList[(stars - 1) ~/ 2]}', style: const TextStyle(color: ThemeUtil.foregroundColor),)
                            ],
                          ),
                          const Divider(),
                          Container(
                            height: 60,
                            padding: const EdgeInsets.only(left: 40),
                            alignment: Alignment.centerLeft,
                            child: const Text('内容', style: TextStyle(color: Color.fromRGBO(0xc5, 0xc5, 0xc5, 1), fontSize: 18),),
                          ),
                          Container(
                            height: 180,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(0xf3, 0xf3, 0xf3, 1),
                              borderRadius: BorderRadius.circular(12)
                            ),
                            child: TextField(
                              controller: _controller,
                              decoration: const InputDecoration(
                                hintText: '        你感觉怎么样呢？',
                                hintStyle: TextStyle(color: Color.fromRGBO(0xc5, 0xc5, 0xc6, 1)),
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                border: InputBorder.none,
                              ),
                              minLines: 1,
                              maxLines: 9999,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ImageInputWidget(
                      maxLength: 9,
                      onChange: (pics){
                        this.pics = pics;
                      },
                    ),
                    const SizedBox(
                      height: 40,
                    )
                  ],
                ),
                Positioned(
                  right: 0,
                  bottom: 40,
                  child: InkWell(
                    onTap: submit,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: ThemeUtil.buttonColor,
                        borderRadius: BorderRadius.horizontal(left: Radius.circular(40))
                      ),
                      width: 104,
                      height: 56,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.post_add_outlined, color: Colors.white,),
                          Text('发 表', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),)
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future submit() async{
    String content = _controller.text.trim();
    if(content.isEmpty){
      ToastUtil.warn('请填写评论内容');
      return;
    }
    if(onSubmit){
      return;
    }
    onSubmit = true;
    Comment comment = Comment();
    comment.productId = widget.productId;
    comment.typeId = widget.productType.getNum();
    comment.content = _controller.text;
    comment.stars = stars * 10;
    if(pics.isNotEmpty){
      comment.pics = pics.join(',');
    }
    comment.tags = CommentDict().tagList[(stars - 1) ~/ 2];
    Comment? result = await CommentUtil().postComment(comment);
    if(result != null){
      ToastUtil.hint('发表评论成功');
      Timer.periodic(const Duration(seconds: 3), (timer) { 
        if(context.mounted){
          Navigator.of(context).pop(true);
        }
        timer.cancel();
      });
    }
    else{
      ToastUtil.error('评论失败');
    }
    onSubmit = false;
  }
}
