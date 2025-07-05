
class DictionaryUtil{

  static DictionaryUtil instance = DictionaryUtil._internal();
  DictionaryUtil._internal();
  factory DictionaryUtil(){
    return instance;
  }

  static const int USERNAME_MAX_LENGTH = 14;
  static const int FRIEND_APPLY_BACKUP_MAX_LENGTH = 255;

  static const int GROUP_NAME_MAX_LENGTH = 80;
  static const int GROUP_DESCRIPTION_MAX_LENGTH = 100;
}
