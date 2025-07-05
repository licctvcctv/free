

class CircleQuestionAnswerModel{
   late int id;
   int? questionId;
   int? userId;
   String? content;
   String? createTime;

   String? userName;
   String? userHead;

   CircleQuestionAnswerModel(this.id);
   CircleQuestionAnswerModel.fromJson(dynamic json) {
     id= json['id'];
     questionId = json['questionId'];
     userId = json['userId'];
     userName = json['userName'];
     userHead = json['userHead'];
     content = json['content'];
     createTime = json['createTime'];

   }
}