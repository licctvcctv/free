import 'package:flutter/material.dart';
import 'package:freego_flutter/components/restaurant/restaurant_common.dart';
import 'package:freego_flutter/components/restaurant/restaurant_scenic_detail.dart';
import 'package:freego_flutter/components/view/date_choose_view.dart';
import 'package:freego_flutter/model/user.dart';
import 'package:freego_flutter/util/date_choose_util.dart';
import 'package:freego_flutter/util/local_user.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:intl/intl.dart';

class RestaurantPickingGoPage extends StatelessWidget {
  final Restaurant restaurant;
  final List<RestaurantDish>? dishes;
  final double totalPrice;
  final List<RestaurantDish>? selectedDishes;
  final Map<int, int> dishQuantities;

  const RestaurantPickingGoPage({
    required this.restaurant,
    this.dishes,
    required this.totalPrice,
    required this.selectedDishes,
    required this.dishQuantities,
    super.key,
  });

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
        child: RestaurantPickingGoWidget(
          restaurant: restaurant,
          dishes: dishes,
          totalPrice: totalPrice,
          selectedDishes: selectedDishes,
          dishQuantities: dishQuantities,
        ),
      ),
    );
  }
}

class RestaurantPickingGoWidget extends StatefulWidget {
  final Restaurant restaurant;
  final List<RestaurantDish>? dishes;
  final double totalPrice;
  final List<RestaurantDish>? selectedDishes;
  final Map<int, int> dishQuantities;

  const RestaurantPickingGoWidget({
    required this.restaurant,
    this.dishes,
    required this.totalPrice,
    required this.selectedDishes,
    required this.dishQuantities,
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return RestaurantPickingGoState();
  }
}

class RestaurantPickingGoState extends State<RestaurantPickingGoWidget> {
  late int orderNum;
  TextEditingController numController = TextEditingController();

  late DateTime firstDate;
  late DateTime lastDate;

  DateTime? tourDate;

  int selectedTimeSlotIndex = -1;

  TextEditingController contactNameController = TextEditingController();
  TextEditingController contactPhoneController = TextEditingController();
  TextEditingController contactDinnerTimeController = TextEditingController();
  TextEditingController remarkController = TextEditingController();

  bool isSelectable = false;

  late double totalPrice;

  @override
  void dispose(){
    contactNameController.dispose();
    contactPhoneController.dispose();
    contactDinnerTimeController.dispose();
    remarkController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    firstDate = DateTime.now();
    lastDate = DateTime.now().add(const Duration(days: 30));
    tourDate = DateTime.now();
    orderNum = 1;
    numController.text = '$orderNum';
    UserModel? user = LocalUser.getUser();
    if (user != null) {
      contactNameController.text = user.name ?? '';
      contactPhoneController.text = user.phone ?? '';
    }
  }

  void updateSelectedMealTime(String mealTime) {
    setState(() {});
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
                            icon: const Icon(Icons.arrow_back_ios_new,
                                color: Colors.white),
                          ),
                        ],
                      ),
                      const Text(
                        '取餐登记',
                        style: TextStyle(
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
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    getTargetDateget(),
                    getMealTimeget(),
                    getContactWidget(),
                    getNotesget(),
                  ],
                ),
              ),
              getPriceWidget(widget.totalPrice, widget.selectedDishes,
                  widget.dishQuantities)
            ],
          ),
        ],
      ),
    );
  }

  Widget getTargetDateget() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(16))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '选择日期：',
                style: TextStyle(
                  color: ThemeUtil.foregroundColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              InkWell(
                  onTap: () async {
                    final config = DateChooseConfig(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width,
                        firstDate: DateTime.now().subtract(Duration(
                          hours: DateTime.now().hour,
                          minutes: DateTime.now().minute,
                          seconds: DateTime.now().second,
                          milliseconds: DateTime.now().millisecond,
                          microseconds: DateTime.now().microsecond,
                        )),
                        lastDate: firstDate.add(const Duration(days: 30)),
                        chooseMode: DateChooseMode.single);
                    List<DateTime>? results =
                        await DateChooseUtil.chooseDate(context, config);
                    if (results != null) {
                      tourDate = results.first;
                      if (mounted && context.mounted) {
                        setState(() {});
                      }
                    }
                  },
                  child: tourDate != null
                      ? Text(
                          DateFormat('yyyy年MM月dd日').format(tourDate!),
                          style: const TextStyle(
                              color: ThemeUtil.buttonColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 26,
                              decoration: TextDecoration.underline),
                        )
                      : const Text(
                          '未开放',
                          style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 26),
                        )),
            ],
          ),
        ],
      ),
    );
  }

Widget getMealTimeget() {
  return Container(
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    padding: const EdgeInsets.all(16),
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '用餐时间：',
              style: TextStyle(
                color: ThemeUtil.foregroundColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(width: 100),
            Flexible(
              flex: 2,
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.black12)),
                ),
                child: TextField(
                  keyboardType: TextInputType.datetime,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    hintText: '请输入用餐时间',
                    hintStyle: TextStyle(color: Colors.grey),
                    isDense: true,
                    contentPadding: EdgeInsets.fromLTRB(8, 10, 8, 10),
                    border: InputBorder.none,
                  ),
                  controller: contactDinnerTimeController,
                  onEditingComplete: () {
                    String enteredTime =
                        contactDinnerTimeController.text.trim();
                    if (enteredTime.isNotEmpty) {
                      int? hour = int.tryParse(enteredTime);
                      if (hour != null && hour >= 0 && hour <= 24) {
                        String formattedTime =
                            '${hour.toString().padLeft(2, '0')}:00';
                        contactDinnerTimeController.text = formattedTime;
                      } else {
                        try {
                          String formattedTime = DateFormat('HH:mm').format(
                              DateTime.parse('1970-01-01 $enteredTime'));
                          contactDinnerTimeController.text = formattedTime;
                        } catch (e) {
                          ToastUtil.warn('请输入正确的时间');
                          return;
                        }
                      }
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
  Widget getContactWidget() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(16))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '联系人',
            style: TextStyle(
                color: ThemeUtil.foregroundColor,
                fontWeight: FontWeight.bold,
                fontSize: 20),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black12))),
            child: TextField(
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                hintText: '姓 名',
                hintStyle: TextStyle(color: Colors.grey),
                isDense: true,
                contentPadding: EdgeInsets.fromLTRB(8, 10, 8, 10),
                border: InputBorder.none,
              ),
              controller: contactNameController,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Container(
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black12))),
            child: TextField(
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                hintText: '电 话',
                hintStyle: TextStyle(color: Colors.grey),
                isDense: true,
                contentPadding: EdgeInsets.fromLTRB(8, 10, 8, 10),
                border: InputBorder.none,
              ),
              controller: contactPhoneController,
            ),
          ),
        ],
      ),
    );
  }

  Widget getNotesget() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(16))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '备 注',
            style: TextStyle(
                color: ThemeUtil.foregroundColor,
                fontWeight: FontWeight.bold,
                fontSize: 20),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black12))),
            child: TextField(
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                hintText: '请输入您的要求',
                hintStyle: TextStyle(color: Colors.grey),
                isDense: true,
                contentPadding: EdgeInsets.fromLTRB(8, 10, 8, 10),
                border: InputBorder.none,
              ),
              controller: remarkController,
            ),
          )
        ],
      ),
    );
  }

  Widget getPriceWidget(double totalPrice, List<RestaurantDish>? selectedDishes,Map<int, int> dishQuantities) {
    int? idToShow = widget.restaurant.id; // 获取 travelModel 的 ID
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () async {
                if (idToShow == null) {
                  ToastUtil.error('数据错误');
                  return;
                }
                String dinnerTime = contactDinnerTimeController.text.trim();
                if (dinnerTime.isEmpty) {
                  ToastUtil.warn('请选择用餐时间');
                  return;
                }
                String contactName = contactNameController.text.trim();
                if (contactName.isEmpty) {
                  ToastUtil.warn('请填写联系人姓名');
                  return;
                }
                String contactPhone = contactPhoneController.text.trim();
                if (contactPhone.isEmpty) {
                  ToastUtil.warn('请填写联系人电话');
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RestaurantScenicDetailPage(
                      restaurant: widget.restaurant,
                      dishes: widget.dishes,
                      totalPrice: totalPrice,
                      orderNum: orderNum,
                      tourDate: tourDate,
                      contactDinnerTime:
                      contactDinnerTimeController.text.trim(),
                      contactName: contactNameController.text.trim(),
                      contactPhone: contactPhoneController.text.trim(),
                      contactAsk: remarkController.text.trim(),
                      selectedDishes: selectedDishes,
                      dishQuantities: dishQuantities,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(120, 50), // 设置按钮的最小尺寸
              ),
              child: const Text(
                '预订',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18
                ),
              )
            )
          ],
       ),
    );
  }
}
