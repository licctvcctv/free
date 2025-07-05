
enum MemberRole{
  ownner,
  monitor,
  member
}

extension MemberRoleExt on MemberRole{

  String getName(){
    switch(this){
      case MemberRole.ownner:
        return 'ownner';
      case MemberRole.monitor:
        return 'monitor';
      case MemberRole.member:
        return 'member';
    }
  }

  static MemberRole? getRole(String name){
    for(MemberRole role in MemberRole.values){
      if(name == role.getName()){
        return role;
      }
    }
    return null;
  }
}
