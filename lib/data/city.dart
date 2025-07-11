
import 'package:lpinyin/lpinyin.dart';

class City {
  static final CITY_LIST = [
    {
      "code": "110000",
      "name": "北京市"
    },
    {
      "code": "310000",
      "name": "上海市"
    },
    {
      "code": "120000",
      "name": "天津市"
    },
    {
      "code": "500000",
      "name": "重庆市"
    },
    {
      "code": "810000",
      "name": "香港特别行政区"
    },
    {
      "code": "820000",
      "name": "澳门特别行政区"
    },
    {
      "code": "130100",
      "name": "石家庄市",
      "province": "13",
      "city": "01"
    },
    {
      "code": "130200",
      "name": "唐山市",
      "province": "13",
      "city": "02"
    },
    {
      "code": "130300",
      "name": "秦皇岛市",
      "province": "13",
      "city": "03"
    },
    {
      "code": "130400",
      "name": "邯郸市",
      "province": "13",
      "city": "04"
    },
    {
      "code": "130500",
      "name": "邢台市",
      "province": "13",
      "city": "05"
    },
    {
      "code": "130600",
      "name": "保定市",
      "province": "13",
      "city": "06"
    },
    {
      "code": "130700",
      "name": "张家口市",
      "province": "13",
      "city": "07"
    },
    {
      "code": "130800",
      "name": "承德市",
      "province": "13",
      "city": "08"
    },
    {
      "code": "130900",
      "name": "沧州市",
      "province": "13",
      "city": "09"
    },
    {
      "code": "131000",
      "name": "廊坊市",
      "province": "13",
      "city": "10"
    },
    {
      "code": "131100",
      "name": "衡水市",
      "province": "13",
      "city": "11"
    },
    {
      "code": "140100",
      "name": "太原市",
      "province": "14",
      "city": "01"
    },
    {
      "code": "140200",
      "name": "大同市",
      "province": "14",
      "city": "02"
    },
    {
      "code": "140300",
      "name": "阳泉市",
      "province": "14",
      "city": "03"
    },
    {
      "code": "140400",
      "name": "长治市",
      "province": "14",
      "city": "04"
    },
    {
      "code": "140500",
      "name": "晋城市",
      "province": "14",
      "city": "05"
    },
    {
      "code": "140600",
      "name": "朔州市",
      "province": "14",
      "city": "06"
    },
    {
      "code": "140700",
      "name": "晋中市",
      "province": "14",
      "city": "07"
    },
    {
      "code": "140800",
      "name": "运城市",
      "province": "14",
      "city": "08"
    },
    {
      "code": "140900",
      "name": "忻州市",
      "province": "14",
      "city": "09"
    },
    {
      "code": "141000",
      "name": "临汾市",
      "province": "14",
      "city": "10"
    },
    {
      "code": "141100",
      "name": "吕梁市",
      "province": "14",
      "city": "11"
    },
    {
      "code": "150100",
      "name": "呼和浩特市",
      "province": "15",
      "city": "01"
    },
    {
      "code": "150200",
      "name": "包头市",
      "province": "15",
      "city": "02"
    },
    {
      "code": "150300",
      "name": "乌海市",
      "province": "15",
      "city": "03"
    },
    {
      "code": "150400",
      "name": "赤峰市",
      "province": "15",
      "city": "04"
    },
    {
      "code": "150500",
      "name": "通辽市",
      "province": "15",
      "city": "05"
    },
    {
      "code": "150600",
      "name": "鄂尔多斯市",
      "province": "15",
      "city": "06"
    },
    {
      "code": "150700",
      "name": "呼伦贝尔市",
      "province": "15",
      "city": "07"
    },
    {
      "code": "150800",
      "name": "巴彦淖尔市",
      "province": "15",
      "city": "08"
    },
    {
      "code": "150900",
      "name": "乌兰察布市",
      "province": "15",
      "city": "09"
    },
    {
      "code": "152200",
      "name": "兴安盟",
      "province": "15",
      "city": "22"
    },
    {
      "code": "152500",
      "name": "锡林郭勒盟",
      "province": "15",
      "city": "25"
    },
    {
      "code": "152900",
      "name": "阿拉善盟",
      "province": "15",
      "city": "29"
    },
    {
      "code": "210100",
      "name": "沈阳市",
      "province": "21",
      "city": "01"
    },
    {
      "code": "210200",
      "name": "大连市",
      "province": "21",
      "city": "02"
    },
    {
      "code": "210300",
      "name": "鞍山市",
      "province": "21",
      "city": "03"
    },
    {
      "code": "210400",
      "name": "抚顺市",
      "province": "21",
      "city": "04"
    },
    {
      "code": "210500",
      "name": "本溪市",
      "province": "21",
      "city": "05"
    },
    {
      "code": "210600",
      "name": "丹东市",
      "province": "21",
      "city": "06"
    },
    {
      "code": "210700",
      "name": "锦州市",
      "province": "21",
      "city": "07"
    },
    {
      "code": "210800",
      "name": "营口市",
      "province": "21",
      "city": "08"
    },
    {
      "code": "210900",
      "name": "阜新市",
      "province": "21",
      "city": "09"
    },
    {
      "code": "211000",
      "name": "辽阳市",
      "province": "21",
      "city": "10"
    },
    {
      "code": "211100",
      "name": "盘锦市",
      "province": "21",
      "city": "11"
    },
    {
      "code": "211200",
      "name": "铁岭市",
      "province": "21",
      "city": "12"
    },
    {
      "code": "211300",
      "name": "朝阳市",
      "province": "21",
      "city": "13"
    },
    {
      "code": "211400",
      "name": "葫芦岛市",
      "province": "21",
      "city": "14"
    },
    {
      "code": "220100",
      "name": "长春市",
      "province": "22",
      "city": "01"
    },
    {
      "code": "220200",
      "name": "吉林市",
      "province": "22",
      "city": "02"
    },
    {
      "code": "220300",
      "name": "四平市",
      "province": "22",
      "city": "03"
    },
    {
      "code": "220400",
      "name": "辽源市",
      "province": "22",
      "city": "04"
    },
    {
      "code": "220500",
      "name": "通化市",
      "province": "22",
      "city": "05"
    },
    {
      "code": "220600",
      "name": "白山市",
      "province": "22",
      "city": "06"
    },
    {
      "code": "220700",
      "name": "松原市",
      "province": "22",
      "city": "07"
    },
    {
      "code": "220800",
      "name": "白城市",
      "province": "22",
      "city": "08"
    },
    {
      "code": "222400",
      "name": "延边朝鲜族自治州",
      "province": "22",
      "city": "24"
    },
    {
      "code": "230100",
      "name": "哈尔滨市",
      "province": "23",
      "city": "01"
    },
    {
      "code": "230200",
      "name": "齐齐哈尔市",
      "province": "23",
      "city": "02"
    },
    {
      "code": "230300",
      "name": "鸡西市",
      "province": "23",
      "city": "03"
    },
    {
      "code": "230400",
      "name": "鹤岗市",
      "province": "23",
      "city": "04"
    },
    {
      "code": "230500",
      "name": "双鸭山市",
      "province": "23",
      "city": "05"
    },
    {
      "code": "230600",
      "name": "大庆市",
      "province": "23",
      "city": "06"
    },
    {
      "code": "230700",
      "name": "伊春市",
      "province": "23",
      "city": "07"
    },
    {
      "code": "230800",
      "name": "佳木斯市",
      "province": "23",
      "city": "08"
    },
    {
      "code": "230900",
      "name": "七台河市",
      "province": "23",
      "city": "09"
    },
    {
      "code": "231000",
      "name": "牡丹江市",
      "province": "23",
      "city": "10"
    },
    {
      "code": "231100",
      "name": "黑河市",
      "province": "23",
      "city": "11"
    },
    {
      "code": "231200",
      "name": "绥化市",
      "province": "23",
      "city": "12"
    },
    {
      "code": "232700",
      "name": "大兴安岭地区",
      "province": "23",
      "city": "27"
    },
    {
      "code": "320100",
      "name": "南京市",
      "province": "32",
      "city": "01"
    },
    {
      "code": "320200",
      "name": "无锡市",
      "province": "32",
      "city": "02"
    },
    {
      "code": "320300",
      "name": "徐州市",
      "province": "32",
      "city": "03"
    },
    {
      "code": "320400",
      "name": "常州市",
      "province": "32",
      "city": "04"
    },
    {
      "code": "320500",
      "name": "苏州市",
      "province": "32",
      "city": "05"
    },
    {
      "code": "320600",
      "name": "南通市",
      "province": "32",
      "city": "06"
    },
    {
      "code": "320700",
      "name": "连云港市",
      "province": "32",
      "city": "07"
    },
    {
      "code": "320800",
      "name": "淮安市",
      "province": "32",
      "city": "08"
    },
    {
      "code": "320900",
      "name": "盐城市",
      "province": "32",
      "city": "09"
    },
    {
      "code": "321000",
      "name": "扬州市",
      "province": "32",
      "city": "10"
    },
    {
      "code": "321100",
      "name": "镇江市",
      "province": "32",
      "city": "11"
    },
    {
      "code": "321200",
      "name": "泰州市",
      "province": "32",
      "city": "12"
    },
    {
      "code": "321300",
      "name": "宿迁市",
      "province": "32",
      "city": "13"
    },
    {
      "code": "330100",
      "name": "杭州市",
      "province": "33",
      "city": "01"
    },
    {
      "code": "330200",
      "name": "宁波市",
      "province": "33",
      "city": "02"
    },
    {
      "code": "330300",
      "name": "温州市",
      "province": "33",
      "city": "03"
    },
    {
      "code": "330400",
      "name": "嘉兴市",
      "province": "33",
      "city": "04"
    },
    {
      "code": "330500",
      "name": "湖州市",
      "province": "33",
      "city": "05"
    },
    {
      "code": "330600",
      "name": "绍兴市",
      "province": "33",
      "city": "06"
    },
    {
      "code": "330700",
      "name": "金华市",
      "province": "33",
      "city": "07"
    },
    {
      "code": "330800",
      "name": "衢州市",
      "province": "33",
      "city": "08"
    },
    {
      "code": "330900",
      "name": "舟山市",
      "province": "33",
      "city": "09"
    },
    {
      "code": "331000",
      "name": "台州市",
      "province": "33",
      "city": "10"
    },
    {
      "code": "331100",
      "name": "丽水市",
      "province": "33",
      "city": "11"
    },
    {
      "code": "340100",
      "name": "合肥市",
      "province": "34",
      "city": "01"
    },
    {
      "code": "340200",
      "name": "芜湖市",
      "province": "34",
      "city": "02"
    },
    {
      "code": "340300",
      "name": "蚌埠市",
      "province": "34",
      "city": "03"
    },
    {
      "code": "340400",
      "name": "淮南市",
      "province": "34",
      "city": "04"
    },
    {
      "code": "340500",
      "name": "马鞍山市",
      "province": "34",
      "city": "05"
    },
    {
      "code": "340600",
      "name": "淮北市",
      "province": "34",
      "city": "06"
    },
    {
      "code": "340700",
      "name": "铜陵市",
      "province": "34",
      "city": "07"
    },
    {
      "code": "340800",
      "name": "安庆市",
      "province": "34",
      "city": "08"
    },
    {
      "code": "341000",
      "name": "黄山市",
      "province": "34",
      "city": "10"
    },
    {
      "code": "341100",
      "name": "滁州市",
      "province": "34",
      "city": "11"
    },
    {
      "code": "341200",
      "name": "阜阳市",
      "province": "34",
      "city": "12"
    },
    {
      "code": "341300",
      "name": "宿州市",
      "province": "34",
      "city": "13"
    },
    {
      "code": "341500",
      "name": "六安市",
      "province": "34",
      "city": "15"
    },
    {
      "code": "341600",
      "name": "亳州市",
      "province": "34",
      "city": "16"
    },
    {
      "code": "341700",
      "name": "池州市",
      "province": "34",
      "city": "17"
    },
    {
      "code": "341800",
      "name": "宣城市",
      "province": "34",
      "city": "18"
    },
    {
      "code": "350100",
      "name": "福州市",
      "province": "35",
      "city": "01"
    },
    {
      "code": "350200",
      "name": "厦门市",
      "province": "35",
      "city": "02"
    },
    {
      "code": "350300",
      "name": "莆田市",
      "province": "35",
      "city": "03"
    },
    {
      "code": "350400",
      "name": "三明市",
      "province": "35",
      "city": "04"
    },
    {
      "code": "350500",
      "name": "泉州市",
      "province": "35",
      "city": "05"
    },
    {
      "code": "350600",
      "name": "漳州市",
      "province": "35",
      "city": "06"
    },
    {
      "code": "350700",
      "name": "南平市",
      "province": "35",
      "city": "07"
    },
    {
      "code": "350800",
      "name": "龙岩市",
      "province": "35",
      "city": "08"
    },
    {
      "code": "350900",
      "name": "宁德市",
      "province": "35",
      "city": "09"
    },
    {
      "code": "360100",
      "name": "南昌市",
      "province": "36",
      "city": "01"
    },
    {
      "code": "360200",
      "name": "景德镇市",
      "province": "36",
      "city": "02"
    },
    {
      "code": "360300",
      "name": "萍乡市",
      "province": "36",
      "city": "03"
    },
    {
      "code": "360400",
      "name": "九江市",
      "province": "36",
      "city": "04"
    },
    {
      "code": "360500",
      "name": "新余市",
      "province": "36",
      "city": "05"
    },
    {
      "code": "360600",
      "name": "鹰潭市",
      "province": "36",
      "city": "06"
    },
    {
      "code": "360700",
      "name": "赣州市",
      "province": "36",
      "city": "07"
    },
    {
      "code": "360800",
      "name": "吉安市",
      "province": "36",
      "city": "08"
    },
    {
      "code": "360900",
      "name": "宜春市",
      "province": "36",
      "city": "09"
    },
    {
      "code": "361000",
      "name": "抚州市",
      "province": "36",
      "city": "10"
    },
    {
      "code": "361100",
      "name": "上饶市",
      "province": "36",
      "city": "11"
    },
    {
      "code": "370100",
      "name": "济南市",
      "province": "37",
      "city": "01"
    },
    {
      "code": "370200",
      "name": "青岛市",
      "province": "37",
      "city": "02"
    },
    {
      "code": "370300",
      "name": "淄博市",
      "province": "37",
      "city": "03"
    },
    {
      "code": "370400",
      "name": "枣庄市",
      "province": "37",
      "city": "04"
    },
    {
      "code": "370500",
      "name": "东营市",
      "province": "37",
      "city": "05"
    },
    {
      "code": "370600",
      "name": "烟台市",
      "province": "37",
      "city": "06"
    },
    {
      "code": "370700",
      "name": "潍坊市",
      "province": "37",
      "city": "07"
    },
    {
      "code": "370800",
      "name": "济宁市",
      "province": "37",
      "city": "08"
    },
    {
      "code": "370900",
      "name": "泰安市",
      "province": "37",
      "city": "09"
    },
    {
      "code": "371000",
      "name": "威海市",
      "province": "37",
      "city": "10"
    },
    {
      "code": "371100",
      "name": "日照市",
      "province": "37",
      "city": "11"
    },
    {
      "code": "371300",
      "name": "临沂市",
      "province": "37",
      "city": "13"
    },
    {
      "code": "371400",
      "name": "德州市",
      "province": "37",
      "city": "14"
    },
    {
      "code": "371500",
      "name": "聊城市",
      "province": "37",
      "city": "15"
    },
    {
      "code": "371600",
      "name": "滨州市",
      "province": "37",
      "city": "16"
    },
    {
      "code": "371700",
      "name": "菏泽市",
      "province": "37",
      "city": "17"
    },
    {
      "code": "410100",
      "name": "郑州市",
      "province": "41",
      "city": "01"
    },
    {
      "code": "410200",
      "name": "开封市",
      "province": "41",
      "city": "02"
    },
    {
      "code": "410300",
      "name": "洛阳市",
      "province": "41",
      "city": "03"
    },
    {
      "code": "410400",
      "name": "平顶山市",
      "province": "41",
      "city": "04"
    },
    {
      "code": "410500",
      "name": "安阳市",
      "province": "41",
      "city": "05"
    },
    {
      "code": "410600",
      "name": "鹤壁市",
      "province": "41",
      "city": "06"
    },
    {
      "code": "410700",
      "name": "新乡市",
      "province": "41",
      "city": "07"
    },
    {
      "code": "410800",
      "name": "焦作市",
      "province": "41",
      "city": "08"
    },
    {
      "code": "410900",
      "name": "濮阳市",
      "province": "41",
      "city": "09"
    },
    {
      "code": "411000",
      "name": "许昌市",
      "province": "41",
      "city": "10"
    },
    {
      "code": "411100",
      "name": "漯河市",
      "province": "41",
      "city": "11"
    },
    {
      "code": "411200",
      "name": "三门峡市",
      "province": "41",
      "city": "12"
    },
    {
      "code": "411300",
      "name": "南阳市",
      "province": "41",
      "city": "13"
    },
    {
      "code": "411400",
      "name": "商丘市",
      "province": "41",
      "city": "14"
    },
    {
      "code": "411500",
      "name": "信阳市",
      "province": "41",
      "city": "15"
    },
    {
      "code": "411600",
      "name": "周口市",
      "province": "41",
      "city": "16"
    },
    {
      "code": "411700",
      "name": "驻马店市",
      "province": "41",
      "city": "17"
    },
    {
      "code": "420100",
      "name": "武汉市",
      "province": "42",
      "city": "01"
    },
    {
      "code": "420200",
      "name": "黄石市",
      "province": "42",
      "city": "02"
    },
    {
      "code": "420300",
      "name": "十堰市",
      "province": "42",
      "city": "03"
    },
    {
      "code": "420500",
      "name": "宜昌市",
      "province": "42",
      "city": "05"
    },
    {
      "code": "420600",
      "name": "襄阳市",
      "province": "42",
      "city": "06"
    },
    {
      "code": "420700",
      "name": "鄂州市",
      "province": "42",
      "city": "07"
    },
    {
      "code": "420800",
      "name": "荆门市",
      "province": "42",
      "city": "08"
    },
    {
      "code": "420900",
      "name": "孝感市",
      "province": "42",
      "city": "09"
    },
    {
      "code": "421000",
      "name": "荆州市",
      "province": "42",
      "city": "10"
    },
    {
      "code": "421100",
      "name": "黄冈市",
      "province": "42",
      "city": "11"
    },
    {
      "code": "421200",
      "name": "咸宁市",
      "province": "42",
      "city": "12"
    },
    {
      "code": "421300",
      "name": "随州市",
      "province": "42",
      "city": "13"
    },
    {
      "code": "422800",
      "name": "恩施土家族苗族自治州",
      "province": "42",
      "city": "28"
    },
    {
      "code": "430100",
      "name": "长沙市",
      "province": "43",
      "city": "01"
    },
    {
      "code": "430200",
      "name": "株洲市",
      "province": "43",
      "city": "02"
    },
    {
      "code": "430300",
      "name": "湘潭市",
      "province": "43",
      "city": "03"
    },
    {
      "code": "430400",
      "name": "衡阳市",
      "province": "43",
      "city": "04"
    },
    {
      "code": "430500",
      "name": "邵阳市",
      "province": "43",
      "city": "05"
    },
    {
      "code": "430600",
      "name": "岳阳市",
      "province": "43",
      "city": "06"
    },
    {
      "code": "430700",
      "name": "常德市",
      "province": "43",
      "city": "07"
    },
    {
      "code": "430800",
      "name": "张家界市",
      "province": "43",
      "city": "08"
    },
    {
      "code": "430900",
      "name": "益阳市",
      "province": "43",
      "city": "09"
    },
    {
      "code": "431000",
      "name": "郴州市",
      "province": "43",
      "city": "10"
    },
    {
      "code": "431100",
      "name": "永州市",
      "province": "43",
      "city": "11"
    },
    {
      "code": "431200",
      "name": "怀化市",
      "province": "43",
      "city": "12"
    },
    {
      "code": "431300",
      "name": "娄底市",
      "province": "43",
      "city": "13"
    },
    {
      "code": "433100",
      "name": "湘西土家族苗族自治州",
      "province": "43",
      "city": "31"
    },
    {
      "code": "440100",
      "name": "广州市",
      "province": "44",
      "city": "01"
    },
    {
      "code": "440200",
      "name": "韶关市",
      "province": "44",
      "city": "02"
    },
    {
      "code": "440300",
      "name": "深圳市",
      "province": "44",
      "city": "03"
    },
    {
      "code": "440400",
      "name": "珠海市",
      "province": "44",
      "city": "04"
    },
    {
      "code": "440500",
      "name": "汕头市",
      "province": "44",
      "city": "05"
    },
    {
      "code": "440600",
      "name": "佛山市",
      "province": "44",
      "city": "06"
    },
    {
      "code": "440700",
      "name": "江门市",
      "province": "44",
      "city": "07"
    },
    {
      "code": "440800",
      "name": "湛江市",
      "province": "44",
      "city": "08"
    },
    {
      "code": "440900",
      "name": "茂名市",
      "province": "44",
      "city": "09"
    },
    {
      "code": "441200",
      "name": "肇庆市",
      "province": "44",
      "city": "12"
    },
    {
      "code": "441300",
      "name": "惠州市",
      "province": "44",
      "city": "13"
    },
    {
      "code": "441400",
      "name": "梅州市",
      "province": "44",
      "city": "14"
    },
    {
      "code": "441500",
      "name": "汕尾市",
      "province": "44",
      "city": "15"
    },
    {
      "code": "441600",
      "name": "河源市",
      "province": "44",
      "city": "16"
    },
    {
      "code": "441700",
      "name": "阳江市",
      "province": "44",
      "city": "17"
    },
    {
      "code": "441800",
      "name": "清远市",
      "province": "44",
      "city": "18"
    },
    {
      "code": "441900",
      "name": "东莞市",
      "province": "44",
      "city": "19"
    },
    {
      "code": "442000",
      "name": "中山市",
      "province": "44",
      "city": "20"
    },
    {
      "code": "445100",
      "name": "潮州市",
      "province": "44",
      "city": "51"
    },
    {
      "code": "445200",
      "name": "揭阳市",
      "province": "44",
      "city": "52"
    },
    {
      "code": "445300",
      "name": "云浮市",
      "province": "44",
      "city": "53"
    },
    {
      "code": "450100",
      "name": "南宁市",
      "province": "45",
      "city": "01"
    },
    {
      "code": "450200",
      "name": "柳州市",
      "province": "45",
      "city": "02"
    },
    {
      "code": "450300",
      "name": "桂林市",
      "province": "45",
      "city": "03"
    },
    {
      "code": "450400",
      "name": "梧州市",
      "province": "45",
      "city": "04"
    },
    {
      "code": "450500",
      "name": "北海市",
      "province": "45",
      "city": "05"
    },
    {
      "code": "450600",
      "name": "防城港市",
      "province": "45",
      "city": "06"
    },
    {
      "code": "450700",
      "name": "钦州市",
      "province": "45",
      "city": "07"
    },
    {
      "code": "450800",
      "name": "贵港市",
      "province": "45",
      "city": "08"
    },
    {
      "code": "450900",
      "name": "玉林市",
      "province": "45",
      "city": "09"
    },
    {
      "code": "451000",
      "name": "百色市",
      "province": "45",
      "city": "10"
    },
    {
      "code": "451100",
      "name": "贺州市",
      "province": "45",
      "city": "11"
    },
    {
      "code": "451200",
      "name": "河池市",
      "province": "45",
      "city": "12"
    },
    {
      "code": "451300",
      "name": "来宾市",
      "province": "45",
      "city": "13"
    },
    {
      "code": "451400",
      "name": "崇左市",
      "province": "45",
      "city": "14"
    },
    {
      "code": "460100",
      "name": "海口市",
      "province": "46",
      "city": "01"
    },
    {
      "code": "460200",
      "name": "三亚市",
      "province": "46",
      "city": "02"
    },
    {
      "code": "460300",
      "name": "三沙市",
      "province": "46",
      "city": "03"
    },
    {
      "code": "460400",
      "name": "儋州市",
      "province": "46",
      "city": "04"
    },
    {
      "code": "510100",
      "name": "成都市",
      "province": "51",
      "city": "01"
    },
    {
      "code": "510300",
      "name": "自贡市",
      "province": "51",
      "city": "03"
    },
    {
      "code": "510400",
      "name": "攀枝花市",
      "province": "51",
      "city": "04"
    },
    {
      "code": "510500",
      "name": "泸州市",
      "province": "51",
      "city": "05"
    },
    {
      "code": "510600",
      "name": "德阳市",
      "province": "51",
      "city": "06"
    },
    {
      "code": "510700",
      "name": "绵阳市",
      "province": "51",
      "city": "07"
    },
    {
      "code": "510800",
      "name": "广元市",
      "province": "51",
      "city": "08"
    },
    {
      "code": "510900",
      "name": "遂宁市",
      "province": "51",
      "city": "09"
    },
    {
      "code": "511000",
      "name": "内江市",
      "province": "51",
      "city": "10"
    },
    {
      "code": "511100",
      "name": "乐山市",
      "province": "51",
      "city": "11"
    },
    {
      "code": "511300",
      "name": "南充市",
      "province": "51",
      "city": "13"
    },
    {
      "code": "511400",
      "name": "眉山市",
      "province": "51",
      "city": "14"
    },
    {
      "code": "511500",
      "name": "宜宾市",
      "province": "51",
      "city": "15"
    },
    {
      "code": "511600",
      "name": "广安市",
      "province": "51",
      "city": "16"
    },
    {
      "code": "511700",
      "name": "达州市",
      "province": "51",
      "city": "17"
    },
    {
      "code": "511800",
      "name": "雅安市",
      "province": "51",
      "city": "18"
    },
    {
      "code": "511900",
      "name": "巴中市",
      "province": "51",
      "city": "19"
    },
    {
      "code": "512000",
      "name": "资阳市",
      "province": "51",
      "city": "20"
    },
    {
      "code": "513200",
      "name": "阿坝藏族羌族自治州",
      "province": "51",
      "city": "32"
    },
    {
      "code": "513300",
      "name": "甘孜藏族自治州",
      "province": "51",
      "city": "33"
    },
    {
      "code": "513400",
      "name": "凉山彝族自治州",
      "province": "51",
      "city": "34"
    },
    {
      "code": "520100",
      "name": "贵阳市",
      "province": "52",
      "city": "01"
    },
    {
      "code": "520200",
      "name": "六盘水市",
      "province": "52",
      "city": "02"
    },
    {
      "code": "520300",
      "name": "遵义市",
      "province": "52",
      "city": "03"
    },
    {
      "code": "520400",
      "name": "安顺市",
      "province": "52",
      "city": "04"
    },
    {
      "code": "520500",
      "name": "毕节市",
      "province": "52",
      "city": "05"
    },
    {
      "code": "520600",
      "name": "铜仁市",
      "province": "52",
      "city": "06"
    },
    {
      "code": "522300",
      "name": "黔西南布依族苗族自治州",
      "province": "52",
      "city": "23"
    },
    {
      "code": "522600",
      "name": "黔东南苗族侗族自治州",
      "province": "52",
      "city": "26"
    },
    {
      "code": "522700",
      "name": "黔南布依族苗族自治州",
      "province": "52",
      "city": "27"
    },
    {
      "code": "530100",
      "name": "昆明市",
      "province": "53",
      "city": "01"
    },
    {
      "code": "530300",
      "name": "曲靖市",
      "province": "53",
      "city": "03"
    },
    {
      "code": "530400",
      "name": "玉溪市",
      "province": "53",
      "city": "04"
    },
    {
      "code": "530500",
      "name": "保山市",
      "province": "53",
      "city": "05"
    },
    {
      "code": "530600",
      "name": "昭通市",
      "province": "53",
      "city": "06"
    },
    {
      "code": "530700",
      "name": "丽江市",
      "province": "53",
      "city": "07"
    },
    {
      "code": "530800",
      "name": "普洱市",
      "province": "53",
      "city": "08"
    },
    {
      "code": "530900",
      "name": "临沧市",
      "province": "53",
      "city": "09"
    },
    {
      "code": "532300",
      "name": "楚雄彝族自治州",
      "province": "53",
      "city": "23"
    },
    {
      "code": "532500",
      "name": "红河哈尼族彝族自治州",
      "province": "53",
      "city": "25"
    },
    {
      "code": "532600",
      "name": "文山壮族苗族自治州",
      "province": "53",
      "city": "26"
    },
    {
      "code": "532800",
      "name": "西双版纳傣族自治州",
      "province": "53",
      "city": "28"
    },
    {
      "code": "532900",
      "name": "大理白族自治州",
      "province": "53",
      "city": "29"
    },
    {
      "code": "533100",
      "name": "德宏傣族景颇族自治州",
      "province": "53",
      "city": "31"
    },
    {
      "code": "533300",
      "name": "怒江傈僳族自治州",
      "province": "53",
      "city": "33"
    },
    {
      "code": "533400",
      "name": "迪庆藏族自治州",
      "province": "53",
      "city": "34"
    },
    {
      "code": "540100",
      "name": "拉萨市",
      "province": "54",
      "city": "01"
    },
    {
      "code": "540200",
      "name": "日喀则市",
      "province": "54",
      "city": "02"
    },
    {
      "code": "540300",
      "name": "昌都市",
      "province": "54",
      "city": "03"
    },
    {
      "code": "540400",
      "name": "林芝市",
      "province": "54",
      "city": "04"
    },
    {
      "code": "540500",
      "name": "山南市",
      "province": "54",
      "city": "05"
    },
    {
      "code": "540600",
      "name": "那曲市",
      "province": "54",
      "city": "06"
    },
    {
      "code": "542500",
      "name": "阿里地区",
      "province": "54",
      "city": "25"
    },
    {
      "code": "610100",
      "name": "西安市",
      "province": "61",
      "city": "01"
    },
    {
      "code": "610200",
      "name": "铜川市",
      "province": "61",
      "city": "02"
    },
    {
      "code": "610300",
      "name": "宝鸡市",
      "province": "61",
      "city": "03"
    },
    {
      "code": "610400",
      "name": "咸阳市",
      "province": "61",
      "city": "04"
    },
    {
      "code": "610500",
      "name": "渭南市",
      "province": "61",
      "city": "05"
    },
    {
      "code": "610600",
      "name": "延安市",
      "province": "61",
      "city": "06"
    },
    {
      "code": "610700",
      "name": "汉中市",
      "province": "61",
      "city": "07"
    },
    {
      "code": "610800",
      "name": "榆林市",
      "province": "61",
      "city": "08"
    },
    {
      "code": "610900",
      "name": "安康市",
      "province": "61",
      "city": "09"
    },
    {
      "code": "611000",
      "name": "商洛市",
      "province": "61",
      "city": "10"
    },
    {
      "code": "620100",
      "name": "兰州市",
      "province": "62",
      "city": "01"
    },
    {
      "code": "620200",
      "name": "嘉峪关市",
      "province": "62",
      "city": "02"
    },
    {
      "code": "620300",
      "name": "金昌市",
      "province": "62",
      "city": "03"
    },
    {
      "code": "620400",
      "name": "白银市",
      "province": "62",
      "city": "04"
    },
    {
      "code": "620500",
      "name": "天水市",
      "province": "62",
      "city": "05"
    },
    {
      "code": "620600",
      "name": "武威市",
      "province": "62",
      "city": "06"
    },
    {
      "code": "620700",
      "name": "张掖市",
      "province": "62",
      "city": "07"
    },
    {
      "code": "620800",
      "name": "平凉市",
      "province": "62",
      "city": "08"
    },
    {
      "code": "620900",
      "name": "酒泉市",
      "province": "62",
      "city": "09"
    },
    {
      "code": "621000",
      "name": "庆阳市",
      "province": "62",
      "city": "10"
    },
    {
      "code": "621100",
      "name": "定西市",
      "province": "62",
      "city": "11"
    },
    {
      "code": "621200",
      "name": "陇南市",
      "province": "62",
      "city": "12"
    },
    {
      "code": "622900",
      "name": "临夏回族自治州",
      "province": "62",
      "city": "29"
    },
    {
      "code": "623000",
      "name": "甘南藏族自治州",
      "province": "62",
      "city": "30"
    },
    {
      "code": "630100",
      "name": "西宁市",
      "province": "63",
      "city": "01"
    },
    {
      "code": "630200",
      "name": "海东市",
      "province": "63",
      "city": "02"
    },
    {
      "code": "632200",
      "name": "海北藏族自治州",
      "province": "63",
      "city": "22"
    },
    {
      "code": "632300",
      "name": "黄南藏族自治州",
      "province": "63",
      "city": "23"
    },
    {
      "code": "632500",
      "name": "海南藏族自治州",
      "province": "63",
      "city": "25"
    },
    {
      "code": "632600",
      "name": "果洛藏族自治州",
      "province": "63",
      "city": "26"
    },
    {
      "code": "632700",
      "name": "玉树藏族自治州",
      "province": "63",
      "city": "27"
    },
    {
      "code": "632800",
      "name": "海西蒙古族藏族自治州",
      "province": "63",
      "city": "28"
    },
    {
      "code": "640100",
      "name": "银川市",
      "province": "64",
      "city": "01"
    },
    {
      "code": "640200",
      "name": "石嘴山市",
      "province": "64",
      "city": "02"
    },
    {
      "code": "640300",
      "name": "吴忠市",
      "province": "64",
      "city": "03"
    },
    {
      "code": "640400",
      "name": "固原市",
      "province": "64",
      "city": "04"
    },
    {
      "code": "640500",
      "name": "中卫市",
      "province": "64",
      "city": "05"
    },
    {
      "code": "650100",
      "name": "乌鲁木齐市",
      "province": "65",
      "city": "01"
    },
    {
      "code": "650200",
      "name": "克拉玛依市",
      "province": "65",
      "city": "02"
    },
    {
      "code": "650400",
      "name": "吐鲁番市",
      "province": "65",
      "city": "04"
    },
    {
      "code": "650500",
      "name": "哈密市",
      "province": "65",
      "city": "05"
    },
    {
      "code": "652300",
      "name": "昌吉回族自治州",
      "province": "65",
      "city": "23"
    },
    {
      "code": "652700",
      "name": "博尔塔拉蒙古自治州",
      "province": "65",
      "city": "27"
    },
    {
      "code": "652800",
      "name": "巴音郭楞蒙古自治州",
      "province": "65",
      "city": "28"
    },
    {
      "code": "652900",
      "name": "阿克苏地区",
      "province": "65",
      "city": "29"
    },
    {
      "code": "653000",
      "name": "克孜勒苏柯尔克孜自治州",
      "province": "65",
      "city": "30"
    },
    {
      "code": "653100",
      "name": "喀什地区",
      "province": "65",
      "city": "31"
    },
    {
      "code": "653200",
      "name": "和田地区",
      "province": "65",
      "city": "32"
    },
    {
      "code": "654000",
      "name": "伊犁哈萨克自治州",
      "province": "65",
      "city": "40"
    },
    {
      "code": "654200",
      "name": "塔城地区",
      "province": "65",
      "city": "42"
    },
    {
      "code": "654300",
      "name": "阿勒泰地区",
      "province": "65",
      "city": "43"
    },
    {
      'code': '429004',
      'name': '仙桃市',
    },
    {
      'code': '429005',
      'name': '潜江市',
    },
    {
      'code': '429006',
      'name': '天门市',
    },
    {
      'code': '429021',
      'name': '神农架林区'
    },
    {
      'code': '469021',
      'name': '定安县'
    },
    {
      'code': '469022',
      'name': '屯昌县'
    },
    {
      'code': '469023',
      'name': '澄迈县'
    },
    {
      'code': '469024',
      'name': '临高县'
    },
    {
      'code': '469025',
      'name': '白沙黎族自治县'
    },
    {
      'code': '469026',
      'name': '昌江黎族自治县'
    },
    {
      'code': '469027',
      'name': '乐东黎族自治县'
    },
    {
      'code': '469028',
      'name': '陵水黎族自治县'
    },
    {
      'code': '469029',
      'name': '保亭黎族苗族自治县'
    },
    {
      'code': '469030',
      'name': '琼中黎族苗族自治县'
    },
    {
      'code': '659001',
      'name': '石河子市'
    },
    {
      'code': '659002',
      'name': '阿拉尔市'
    },
    {
      'code': '659003',
      'name': '图木舒克市'
    },
    {
      'code': '659004',
      'name': '五家渠市'
    },
    {
      'code': '659005',
      'name': '北屯市'
    },
  ];

  static Map<String,List<String>> getAlphabetWithCities([String? keyword]) {
    Map<String,List<String>> alphabetSet = {};
    for (int i = 0; i < CITY_LIST.length; i++) {
      Map<String, String> city = CITY_LIST[i];
      String? name = city['name'];
      if(name == null || name.isEmpty){
        continue;
      }
      String pinyin = PinyinHelper.getPinyinE(name, separator: '', defPinyin: '', format: PinyinFormat.WITHOUT_TONE);
      if(keyword != null) {
        if(name.contains(keyword) || pinyin.contains(keyword.toLowerCase())) {
          String alp = pinyin.substring(0, 1).toUpperCase();
          if(alphabetSet.containsKey(alp)) {
            alphabetSet[alp]!.add(name);
          }
          else {
            alphabetSet[alp] = [name];
          }
        }
      }
      else {
        String alp = pinyin.substring(0, 1).toUpperCase();
        if(alphabetSet.containsKey(alp)) {
          alphabetSet[alp]!.add(name);
        }
        else {
          alphabetSet[alp] = [name];
        }
      }
    }
    List<String> keyList = alphabetSet.keys.toList();
    keyList.sort();
    Map<String, List<String>> result = {};
    for(String key in keyList){
      result[key] = alphabetSet[key] ?? [];
      result[key]?.sort();
    }
    return result;
  }
  
  static List<String> searchCities([String? keyword]) {
    keyword ??= '';
    keyword = keyword.toLowerCase();
    List<String> results = [];
    for(int i = 0; i < CITY_LIST.length; ++i){
      Map<String, String> city = CITY_LIST[i];
      String? name = city['name'];
      if(name == null || name.isEmpty){
        continue;
      }
      String pinyin = PinyinHelper.getPinyinE(name, separator: '', defPinyin: '', format: PinyinFormat.WITHOUT_TONE);
      if(name.contains(keyword) || pinyin.contains(keyword)){
        results.add(name);
      }
    }
    results.sort();
    return results;
  }
}
