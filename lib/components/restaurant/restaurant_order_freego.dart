
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/restaurant/restaurant_book_freego.dart';
import 'package:freego_flutter/components/restaurant/restaurant_common.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';

class RestaurantOrderGoPage extends StatelessWidget {
  final Restaurant restaurant;
  const RestaurantOrderGoPage(this.restaurant, {super.key});

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
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: RestaurantOrderGoWidget(
          restaurant,
        ),
      ),
    );
  }
}

class RestaurantOrderGoWidget extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantOrderGoWidget(this.restaurant, {super.key});

  @override
  State<StatefulWidget> createState() {
    return RestaurantOrderGoState();
  }
}

class RestaurantOrderGoState extends State<RestaurantOrderGoWidget> {
  late int orderNum;
  TextEditingController numController = TextEditingController();

  late String selectedMealTime;

  int selectedTimeSlotIndex = -1;

  bool isSelectable = false;
  late int dishNum;
  late int priceTemp;
  late int priceOldTemp;

  Map<int, int> dishQuantities = {};

  @override
  void initState() {
    super.initState();
    orderNum = 1;
    dishNum = 0;
    priceTemp = 0;
    priceOldTemp = 0;
  }

  void updateSelectedMealTime(String mealTime) {
    setState(() {
      selectedMealTime = mealTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color.fromRGBO(242, 245, 250, 1)),
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: 50,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(203, 211, 220, 1),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                          ),
                        ],
                      ),
                      Text(
                        widget.restaurant.name ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        physics: const ClampingScrollPhysics(),
                        children: [
                          getDishesWidget(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              getPriceWidget()
            ],
          ),
        ],
      ),
    );
  }

  Widget getDishesWidget() {
    if (widget.restaurant.dishList != null && widget.restaurant.dishList!.isNotEmpty) {
      return Column(
        children: widget.restaurant.dishList!.map((dish) {
          int dishId = dish.id;
          int dishNum = dishQuantities[dishId] ?? 0;
          //int dishNum = 0; // 添加菜品数量变量
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 16), // 调整垂直间距
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Image.network(
                  getFullUrl(dish.pic!), // 构建完整的图片 URL
                  width: 80, // 设置图片宽度
                  height: 80, // 设置图片高度
                  fit: BoxFit.cover, // 调整图片适应框大小
                ),
                const SizedBox(width: 10), // 添加间距
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dish.name ?? '', // 显示菜名
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(80, 244, 210, 87), // 淡黄色背景
                              borderRadius: BorderRadius.circular(8), // 可选：圆角边框
                            ),
                            child: Text(
                              dish.tags ?? '', // 显示菜系
                              style: const TextStyle(
                                color: Colors.amber, // 深黄色文本
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: (() {
                                    if (dish.price != null) {
                                      return '￥${dish.price! / 100}';
                                    } else if (dish.price == null &&
                                        dish.priceOld != null) {
                                      return '￥${dish.priceOld! / 100}';
                                    } else {
                                      return '暂无价格';
                                    }
                                  })(),
                                  style: TextStyle(
                                    color: (() {
                                      if (dish.price != null ||
                                          dish.priceOld != null) {
                                        return Colors.red;
                                      } else {
                                        return Colors.grey;
                                      }
                                    })(),
                                    fontSize: 20, // 调整价格文字大小的数值
                                  ),
                                ),
                                if (dish.price != null && dish.priceOld != null)
                                  TextSpan(
                                    text: ' ￥${dish.priceOld! / 100}',
                                    style: const TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey,
                                      fontSize: 12, // 调整删除线上文字大小的数值
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              if (dishNum > 0) {
                                setState(() {
                                  dishQuantities[dishId] = dishNum - 1; // 减少数量
                                });
                              }
                            },
                            child: Icon(
                              Icons.remove_rounded,
                              color: dishNum > 0 ? Theme.of(context).accentColor : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '$dishNum', // 显示菜品数量
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () {
                              setState(() {
                                dishQuantities[dishId] = dishNum + 1;
                              });
                            },
                            child: Icon(
                              Icons.add_rounded,
                              color: (() {
                                if (dish.price != null || dish.priceOld != null) {
                                  return Theme.of(context).accentColor;
                                } else {
                                  return Colors.grey;
                                }
                              })(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    } 
    else {
      return const Center(
        child: Text(
          '暂无菜单',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 18,
          ),
        ),
      );
    }
  }

  int getTotalPrice() {
    int totalPrice = 0;
    widget.restaurant.dishList!.forEach((dish) {
      int dishId = dish.id;
      int dishNum = dishQuantities[dishId] ?? 0;
      if (dish.price != null) {
        totalPrice += dish.price! * dishNum;
      }
    });
    return totalPrice;
  }

  int getTotalItems() {
    int totalItems = 0;
    widget.restaurant.dishList!.forEach((dish) {
      int dishId = dish.id;
      int dishNum = dishQuantities[dishId] ?? 0;
      totalItems += dishNum;
    });
    return totalItems;
  }

  Widget getPriceWidget() {
    int totalPrice = getTotalPrice();
    int totalItems = getTotalItems();
    int diningMethods = 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '共 $totalItems 件',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '总价：￥${StringUtil.getPriceStr(totalPrice)}',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () async {
              if (totalItems == 0) {
                ToastUtil.warn('请选择菜品');
                return;
              }
              await showModalBottomSheet<Map<int, int>>(
                context: context,
                builder: (BuildContext context) {
                  double screenHeight = MediaQuery.of(context).size.height;
                  double dialogHeight = screenHeight * 0.2;
                  return StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      //    return SingleChildScrollView(
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Colors.lightBlueAccent,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const SizedBox(width: 10),
                                    ElevatedButton(
                                      onPressed: returnMenu,
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                      ),
                                      child: const Text(
                                        '返回',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Text(
                                  '订单详情',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: clearMenu, // Call the clearMenu function
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                      ),
                                      child: const Text('清空菜单',style: TextStyle(color: Colors.white,fontSize: 18,),),
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const ClampingScrollPhysics(),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: const [
                                        BoxShadow(color: Colors.black12, blurRadius: 4)
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:CrossAxisAlignment.start,
                                      children: [
                                        SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment:CrossAxisAlignment.start,
                                            children: [
                                              for (var dish in widget.restaurant.dishList!)
                                              if (dishQuantities[dish.id] != null && dishQuantities[dish.id]! > 0)
                                              Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          '${dish.name ?? ''} x ${dishQuantities[dish.id]}',
                                                          style:const TextStyle(fontSize:18),
                                                        ),
                                                      ),
                                                      Row(
                                                        children: [
                                                          IconButton(
                                                            icon: const Icon(Icons.remove),
                                                            onPressed: () {
                                                              if (dishQuantities[dish.id]! > 0) {
                                                                setState(() {
                                                                  dishQuantities[dish.id] = dishQuantities[dish.id]! - 1;
                                                                });
                                                              }
                                                            },
                                                          ),
                                                          Text('${dishQuantities[dish.id]}'),
                                                          IconButton(
                                                            icon: const Icon(Icons.add),
                                                            onPressed: () {
                                                              setState(() {
                                                                dishQuantities[dish.id] = dishQuantities[dish.id]! + 1;
                                                              });
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        '小计：￥${(dish.price ?? 0) * dishQuantities[dish.id]! / 100}',
                                                        style:const TextStyle(fontSize: 16),
                                                      ),
                                                      IconButton(
                                                        icon: const Icon( Icons.delete),
                                                        onPressed: () {
                                                          setState(() {
                                                            dishQuantities[dish.id] = 0;
                                                          });
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  const Divider(), // 可以添加分隔线
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      ]
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '共 ${getTotalItems()} 件',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                '总价：￥${StringUtil.getPriceStr(getTotalPrice())}',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ]
                              )
                            )
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16.0),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>RestaurantBookGoPage(
                                              restaurant: widget.restaurant,
                                              dishes: widget.restaurant.dishList,
                                              totalPrice: getTotalPrice(),
                                              selectedDishes: widget.restaurant.dishList!.where((dish) =>
                                                dishQuantities[dish.id] != null && dishQuantities[dish.id]! >0
                                              ).toList(),
                                              dishQuantities: dishQuantities,
                                              diningMethods: DiningType.packed,
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: const Size(120, 50),
                                        primary: Colors.lightBlueAccent,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(30),
                                            bottomLeft: Radius.circular(30),
                                            topRight: Radius.zero,
                                            bottomRight: Radius.zero,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        '打包带走',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => RestaurantBookGoPage(
                                              restaurant: widget.restaurant,
                                              dishes: widget.restaurant.dishList,
                                              totalPrice: getTotalPrice(),
                                              selectedDishes: widget.restaurant.dishList!.where((dish) =>
                                                dishQuantities[dish.id] != null && dishQuantities[dish.id]! >0
                                              ).toList(),
                                              dishQuantities: dishQuantities,
                                              diningMethods: DiningType.inStore,
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: const Size(120, 50),
                                        primary: Colors.blue,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.zero,
                                            bottomLeft: Radius.zero,
                                            topRight: Radius.circular(30),
                                            bottomRight: Radius.circular(30),
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        '到店用餐',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                        //      )
                      );
                    },
                  );
                },
              );
              if(mounted && context.mounted){
                setState(() {
                });
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(120, 50),
            ),
            child: const Text(
              '确定',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void returnMenu() {
    Navigator.pop(context, dishQuantities);
  }

  void clearMenu() {
    setState(() {
      dishQuantities.clear();
    });
    Navigator.pop(context);
  }
}
