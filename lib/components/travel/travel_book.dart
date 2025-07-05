
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freego_flutter/components/travel/travel_common.dart';
import 'package:freego_flutter/http/http_user.dart';
import 'package:freego_flutter/model/order.dart';
import 'package:freego_flutter/model/user_fo.dart';
import 'package:freego_flutter/util/dialog_util.dart';
import 'package:freego_flutter/util/pay_util.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:intl/intl.dart';

import '../../http/http_travel.dart';
import '../../model/order_customer.dart';

import '../../model/travel_suit.dart';
import '../../model/travel_suit_price.dart';
import '../../provider/user_provider.dart';

class TravelBookPage extends StatelessWidget{

  final Travel spot;
  final TravelSuitModel ticket;
  final TravelSuitPriceModel price;

  const TravelBookPage(this.spot,this.ticket,this.price, {super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: TravelBookWidget(spot, ticket, price),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0), 
        child: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.white, // <-- SEE HERE
          )

        ),
      )
    );
  }
}

class TravelBookWidget extends ConsumerStatefulWidget {

  final Travel spot;
  final TravelSuitModel ticket;
  final TravelSuitPriceModel price;

  const TravelBookWidget(this.spot,this.ticket,this.price, {super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return TravelBookState(this.spot,this.ticket,this.price);
  }
}

class TravelBookState extends ConsumerState{
  Travel spot;
  TravelSuitModel ticket;
  TravelSuitPriceModel priceModel;
  List<OrderCustomer> customerList = [];
  int totalPrice = 0;
  int adultNum = 1;
  int childNum = 0;

  Order? tempOrder;

  TravelBookState(this.spot,this.ticket,this.priceModel) {
    calculateTotalPrice();
  }

  BoxDecoration decoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8)
  );

  var addMinusBtnStyle = TextButton.styleFrom(
    backgroundColor: Colors.black.withOpacity(0.1), 
    padding: const EdgeInsets.fromLTRB(2, 2, 2, 2),
    minimumSize: Size.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap
  );
  var minusCustomerBtnStyle = TextButton.styleFrom(
    padding: const EdgeInsets.fromLTRB(2, 2, 2, 2),
    minimumSize: Size.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap
  );

  void calculateTotalPrice() {
    totalPrice = priceModel.price!*adultNum+(priceModel.childPrice??0)*childNum;
  }

  @override
  Widget build(BuildContext context) {
    var statusHeight = MediaQuery.of(context).viewPadding.top;
    var leftCustomerNum =  adultNum+childNum-customerList.length;
    return Container(
      decoration: const BoxDecoration( color:Color.fromRGBO(242,245,250,1)),
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: statusHeight,),
              Container(
                height: 50,
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(203,211,220,1)
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: (){
                        Navigator.pop(context);
                      }, 
                      icon: const Icon(Icons.arrow_back_ios_new,color: Colors.white,)
                    ),
                    const SizedBox(width: 10,),
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        child: const Text('旅游预订',style: TextStyle(color:Colors.white,fontWeight: FontWeight.bold,fontSize: 18),),
                      )
                    ),
                    const SizedBox(width: 10,),
                    const Icon(Icons.more_horiz,color: Colors.white, size: 30,)
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: SingleChildScrollView(
                    child:Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10) ,
                          decoration: decoration,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(spot.name!, style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                              const SizedBox(height: 14,),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_month,size: 18,),
                                  const SizedBox(width: 4,),
                                  Text(DateFormat('yyyy-MM-dd').format(priceModel.day!)),
                                ],
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 10,),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10) ,
                          decoration: decoration,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(ticket.name!, style: const TextStyle(fontSize: 16),),
                              const SizedBox(height: 14,),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: getPriceRowViews()
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 10,),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10) ,
                          decoration: decoration,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('出行人',style: TextStyle(fontSize: 16),),
                                  const SizedBox(width: 10,),
                                  leftCustomerNum > 0 ? Text('(还需要添加$leftCustomerNum人)', style: const TextStyle(fontSize: 12,color: Colors.red),) : const SizedBox()
                                ]
                              ),
                              const SizedBox(height: 8,),
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                direction: Axis.horizontal,
                                children: getCustomerViews()
                              ),
                              const SizedBox(height: 8,),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: getCustomerDetailViews(),
                              )
                            ]
                          )
                        )
                      ],
                    ),
                  )
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                decoration: const BoxDecoration(
                  color: Colors.white
                ),
                child: Row(
                  children: [
                    const Text('￥', style: TextStyle(color: Colors.orange, fontSize: 12),),
                    Text(StringUtil.getPriceStr(totalPrice)!, style: const TextStyle(color:Colors.orange,fontSize: 18)),
                    Expanded(
                      flex: 1,
                      child: Container()
                    ),
                    TextButton(
                      onPressed: (){
                        showDetailDlg();
                      }, 
                      child: Row(
                        children: const [
                          Text('明细', style: TextStyle(color: Colors.black87),),
                          Icon(Icons.keyboard_arrow_up, color: Colors.black,)
                        ]
                      )
                    ),
                    const SizedBox(width: 16,),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(43, 142, 233, 1),
                      ),
                      onPressed: (){
                        goOrder();
                      }, 
                      child: const Text('提交'),
                    )
                  ],
                ),
              )
            ],
          ),
        ],
      )
    );
  }

  getPriceRowViews() {
    var viewList = <Widget>[];
    if(priceModel.price != null && priceModel.price! > 0) {
      viewList.add(getAdultView());
    }
    if(priceModel.childPrice != null && priceModel.childPrice! > 0) {
      viewList.add(getChildView());
    }
    return viewList;
  }

  getAdultView() {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 4, 0, 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('成人'),
          const SizedBox(width: 8,),
          const Text('￥', style: TextStyle(color: Colors.orange, fontSize: 12),),
          Text(StringUtil.getPriceStr(priceModel.price)!, style: const TextStyle(color:Colors.orange)),
          Expanded(flex:1,child: Container()),
          TextButton(
            style: addMinusBtnStyle,
            onPressed: (){
              if(adultNum>1) {
                adultNum--;
                calculateTotalPrice();
                setState(() {
                });
              }
            }, 
            child: Icon(Icons.remove,color: adultNum==1?Colors.black12:Colors.black87,),
          ),
          const SizedBox(width: 10,),
          Text(adultNum.toString(), style: const TextStyle(fontSize: 18),),
          const SizedBox(width: 10,),
          TextButton(
            style: addMinusBtnStyle,
            onPressed: (){
              adultNum++;
              calculateTotalPrice();
              setState(() {
              });
            }, 
            child: const Icon(Icons.add, color: Colors.black87),
          ),
        ]
      )
    );
  }

  getChildView() {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 4, 0, 4),
      child: Row(
        children:  [
          const Text('儿童'),
          const SizedBox(width: 8,),
          const Text('￥', style: TextStyle(color:Colors.orange,fontSize: 12),),
          Text(StringUtil.getPriceStr(priceModel.childPrice)!, style: const TextStyle(color:Colors.orange)),
          Expanded(
            flex:1,
            child: Container()
          ),
          TextButton(
            style: addMinusBtnStyle,
            onPressed: (){
              if(childNum > 0) {
                childNum--;
                calculateTotalPrice();
                setState(() {
                });
              }
            }, 
            child: Icon(Icons.remove, color: childNum == 0 ? Colors.black12 : Colors.black87,),
          ),
          const SizedBox(width: 10,),
          Text(childNum.toString(), style: const TextStyle(fontSize: 18),),
          const SizedBox(width: 10,),
          TextButton(
            style: addMinusBtnStyle,
            onPressed: (){
              childNum++;
              calculateTotalPrice();
              setState(() {
              });
            }, 
            child: const Icon(Icons.add,color: Colors.black87),
          ),
        ]
      )
    );
  }


  List<Widget> getCustomerViews() {
    var list = <Widget>[];
    for (var i = 0; i < customerList.length; i++) {
      var customer = customerList[i];
      list.add(
        Container(
          decoration: const BoxDecoration(
            color: Color.fromRGBO(236, 243, 253, 1),
            borderRadius: BorderRadius.all(Radius.circular(4))
          ),
          padding: const EdgeInsets.fromLTRB(8, 4, 4, 8),
          margin: const EdgeInsets.fromLTRB(0, 4, 10, 4),
          child: Text(customer.name)
        )
      );
    }
    if (customerList.length < adultNum + childNum) {
      list.add(
        TextButton(
          style: TextButton.styleFrom(backgroundColor: const Color.fromRGBO(246,247,251,1)),
          onPressed: () async {
            OrderCustomer? customer = await DialogUtil.customerAddDlg(context, null);
            if(customer != null) {
              customerList.add(customer);
              setState(() {
              });
            }
          }, 
          child: const Text('新增>'),
        )
      );
    }
    return list;
  }

  getCustomerDetailViews() {
    var list = <Widget>[];
    for(var i = 0; i < customerList.length; i++) {
      OrderCustomer cus = customerList[i];
      var index = i + 1;
      list.add(
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  TextButton(
                    style: minusCustomerBtnStyle,
                    onPressed: (){
                      customerList.removeAt(i);
                      setState(() {
                      });
                    }, 
                    child: const Icon(Icons.remove_circle_outline,color: Colors.black,),
                  ),
                  Text('游客$index')
                ],
              ),
              const SizedBox(width: 20,),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cus.name),
                    const SizedBox(height: 4,),
                    Text('身份证 ${cus.identityNum}', style: const TextStyle(fontSize: 12,color:Colors.black54),),
                    const SizedBox(height: 4,),
                    Text('手机 ${cus.phone}',style: const TextStyle(fontSize: 12,color:Colors.black54),)
                  ],
                )
              ),
              IconButton(
                onPressed: () async{
                  var newCus = await DialogUtil.customerAddDlg(context, cus);
                  if(newCus != null) {
                    customerList[i] = newCus;
                    setState(() {
                    });
                  }
                }, 
                icon: const Icon(Icons.mode_edit,size: 22,)
              )
            ],
          ),
        )
      );
    }
    return list;
  }

  showDetailDlg() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (buildContext) {
        return Container(
          color: Colors.white,
          height: 200,
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          width: double.infinity,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 40,
                child: Stack(
                  children: [
                    const Center(
                      child: Text('金额明细',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                        ),
                      )
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: GestureDetector(
                        onTap: (){
                          Navigator.pop(buildContext);
                        },
                        child: const Icon(Icons.close)
                      )
                    )
                  ],
                )
              ),
              const SizedBox(height: 10,),
              Row(
                children: [
                  const Text('成人'),
                  const Expanded(
                    flex:1,
                    child: SizedBox(),
                  ),
                  const Text('￥',style: TextStyle(color: Colors.orange, fontSize: 12),),
                  Text(StringUtil.getPriceStr(priceModel.price!)!, style: const TextStyle(color:Colors.orange),),
                  const SizedBox(width: 6,),
                  Text("x$adultNum")
                ],
              ),
              const SizedBox(height: 10,),
              priceModel.childPrice != null && priceModel.childPrice !> 0 ?
              Row(
                children: [
                  const Text('儿童'),
                  const Expanded(
                    flex:1,
                    child: SizedBox(),
                  ),
                  const Text('￥',style: TextStyle(color:Colors.orange, fontSize: 12),),
                  Text(StringUtil.getPriceStr(priceModel.childPrice!)!, style: const TextStyle(color:Colors.orange),),
                  const SizedBox(width: 6,),
                  Text("x$childNum")
                ],
              ) :
              const SizedBox(),
            ],
          ),
        );
      }
    );
  }

  @override
  void initState() {
    super.initState;
    loadUser();
  }
  
  void goOrder() {
    if(customerList.length < adultNum + childNum) {
      ToastUtil.error("请添加出行人");
      return;
    }
    DialogUtil.showProgressDlg(context);
    HttpTravel.book(ticket.id, DateFormat('yyyy-MM-dd').format(priceModel.day!), adultNum,childNum, customerList, (isSuccess, data, msg, code) {
      DialogUtil.closeProgressDlg();
      if(isSuccess) {
        Order order = Order.fromJson(data);
        tempOrder = order;
        PayUtil.showPayDlg(context, tempOrder!);
      }
    });
  }

  void loadUser() {
    HttpUser.loginedUserDetail((isSuccess, data, msg, code) {
      if(isSuccess) {
        UserFoModel fo = UserFoModel.fromJson(data);
        ref.read(userFoProvider.notifier).state = fo;
        if(!StringUtil.isEmpty(fo.realName) || !StringUtil.isEmpty(fo.phone) || !StringUtil.isEmpty(fo.identityNum)) {
          customerList.add(OrderCustomer(fo.realName!, fo.phone!, fo.identityNum!));
          setState(() {
          });
        }
      }
    });
  }

}
