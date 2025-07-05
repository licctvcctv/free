
import 'package:location/location.dart';

class LocalServiceUtil{

  static Future<bool> checkGpsEnabled() async{
    Location location = Location();
    return location.serviceEnabled();
  }
}
