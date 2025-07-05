
class ImGroupRoom{

  int? id;
  int? groupId;
  String? groupName;
  String? groupRemark;
  int? memberRank;
  int? memberId;
  String? memberRemark;
  String? memberRole;
  DateTime? joinTime;
  DateTime? leaveTime;
  int? lastMessageId;
  String? lastMessageSenderType;
  String? lastMessageContent;
  String? lastMessageType;
  DateTime? lastMessageTime;
  int? unreadNum;
  bool? notDisturb;
  bool? isGroupBanned;

  ImGroupRoom.fromJson(dynamic json){
    id = json['id'];
    groupId = json['groupId'];
    groupName = json['groupName'];
    groupRemark = json['groupRemark'];
    memberRank = json['memberRank'];
    memberId = json['memberId'];
    memberRole = json['memberRole'];
    if(json['joinTime'] is String){
      joinTime = DateTime.tryParse(json['joinTime']);
    }
    if(json['leaveTime'] is String){
      leaveTime = DateTime.tryParse(json['leaveTime']);
    }
    lastMessageId = json['lastMessageId'];
    lastMessageSenderType = json['lastMessageSenderType'];
    lastMessageContent = json['lastMessageContent'];
    lastMessageType = json['lastMessageType'];
    if(json['lastMessageTime'] is String){
      lastMessageTime = DateTime.tryParse(json['lastMessageTime']);
    }
    unreadNum = json['unreadNum'];
    notDisturb = json['notDisturb'];
    isGroupBanned = json['isGroupBanned'];
  }
}
