
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:freego_flutter/components/hotel_neo/hotel_common.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/util/theme_util.dart';

class HotelDescPage extends StatelessWidget{
  final Hotel hotel;
  const HotelDescPage(this.hotel, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 10,
        backgroundColor: ThemeUtil.backgroundColor,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      resizeToAvoidBottomInset: false,
      body: HotelDescWidget(hotel),
    );
  }

}

class HotelDescWidget extends StatefulWidget{
  final Hotel hotel;
  const HotelDescWidget(this.hotel, {super.key});

  @override
  State<StatefulWidget> createState() {
    return HotelDescState();
  }

}

class HotelDescState extends State<HotelDescWidget>{
  @override
  Widget build(BuildContext context) {
    Hotel hotel = widget.hotel;
    return Container(
      color: ThemeUtil.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonHeader(
            center: Text(hotel.name ?? '', overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 18),),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              physics: const ClampingScrollPhysics(),
              children: [
                getDetailWidget()
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget getDetailWidget(){
    Hotel hotel = widget.hotel;
    List<Widget> serviceItems = [];
    for(HotelService service in hotel.serviceList ?? []){
      serviceItems.add(
        Text(service.name ?? ''),
      );
    }
    List<Widget> facilityItems = [];
    for(HotelFacility facility in hotel.facilityList ?? []){
      facilityItems.add(
        Text(facility.name ?? ''),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(16))
            ),
            clipBehavior: Clip.hardEdge,
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 7),
                  child: Text('酒店介绍', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
                ),
                Html(
                  data: '<html>${hotel.description}</html>',
                  style: {
                    'html': Style(
                      fontSize: FontSize(15),
                      lineHeight: LineHeight.number(1.5)
                    )
                  },
                )
              ],
            )
            ,
          ),
          const SizedBox(height: 10,),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('酒店服务', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
                const SizedBox(height: 10,),
                Wrap(
                  direction: Axis.vertical,
                  spacing: 10,
                  runSpacing: 10,
                  children: serviceItems,
                )
              ],
            )
          ),
          const SizedBox(height: 10,),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('酒店设施', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 18),),
                const SizedBox(height: 10,),
                Wrap(
                  direction: Axis.vertical,
                  spacing: 10,
                  runSpacing: 10,
                  children: facilityItems,
                )
              ],
            )
          ),
        ],
      ),
    );
  }
}