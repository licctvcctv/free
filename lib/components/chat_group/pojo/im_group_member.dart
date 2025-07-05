
class ImGroupMember{

  int? id;
  int? groupId;
  int? memberRank;
  int? memberId;
  String? memberName;
  String? memberHead;
  String? memberRemark;
  String? memberRole;
  DateTime? joinTime;
  DateTime? leaveTime;
  bool? isLeft;

  ImGroupMember.fromJson(dynamic json){
    id = json['id'];
    groupId = json['groupId'];
    memberRank = json['memberRank'];
    memberId = json['memberId'];
    memberName = json['memberName'];
    memberHead = json['memberHead'];
    memberRemark = json['memberRemark'];
    memberRole = json['memberRole'];
    if(json['joinTime'] is String){
      joinTime = DateTime.tryParse(json['joinTime']);
    }
    if(json['leaveTime'] is String){
      leaveTime = DateTime.tryParse(json['leaveTime']);
    }
    isLeft = json['isLeft'];
  }
}
