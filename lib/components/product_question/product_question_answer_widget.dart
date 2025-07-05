
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/product_question/product_question_common.dart';

class ProductQuestionAnswerWidget extends StatefulWidget{
  final ProductQuestion question;
  final int? merchantId;
  const ProductQuestionAnswerWidget(this.question, {this.merchantId, super.key});

  @override
  State<StatefulWidget> createState() {
    return ProductQuestionAnswerState();
  }
  
}

class ProductQuestionAnswerState extends State<ProductQuestionAnswerWidget>{
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 4
          )
        ]
      ),
      
    );
  }

}