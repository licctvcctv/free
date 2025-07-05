
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/wallet/cash_log_search.dart';
import 'package:freego_flutter/components/wallet/wallet_http.dart';
import 'package:freego_flutter/http/http_cash.dart';
import 'package:freego_flutter/model/cash.dart';
import 'package:freego_flutter/model/customer.dart';
import 'package:freego_flutter/util/regular_util.dart';
import 'package:freego_flutter/util/string_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:intl/intl.dart';

class WalletPage extends StatelessWidget{
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 10,
        backgroundColor: ThemeUtil.backgroundColor,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      body: GestureDetector(
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: const WalletWidget(),
      ),
    );
  }
  
}

class WalletWidget extends StatefulWidget{
  const WalletWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return WalletState();
  }

}

class WalletState extends State<WalletWidget>{

  static const double DOLLAR_SIZE = 100;

  Cash? cash;
  Customer? customer;
  List<CashLog>? cashLogs;
  bool hasMore = false;
  static const int CASH_LOGS_PAGE_SIZE = 10;

  @override
  void initState(){
    super.initState();
    initData();
  }

  void initData(){
    Future.delayed(Duration.zero, () async{
      cash = await HttpCash.getCash();
      resetState();
    });
    Future.delayed(Duration.zero, () async{
      customer = await HttpCash.getCustomer();
      resetState();
    });
    Future.delayed(Duration.zero, () async{
      cashLogs = await HttpCash.getCashLog(pageSize: CASH_LOGS_PAGE_SIZE);
      if(cashLogs != null){
        hasMore = cashLogs!.length < CASH_LOGS_PAGE_SIZE;
      }
      resetState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeUtil.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonHeader(
            center: Text('我的钱包', style: TextStyle(color: Colors.white, fontSize: 18),),
          ),
          Expanded(
            child: ListView(
              physics: const ClampingScrollPhysics(),
              children: [
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    color: Colors.white,
                  ),
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Image.asset(
                        'images/dollar.png',
                        width: DOLLAR_SIZE,
                        height: DOLLAR_SIZE,
                        fit: BoxFit.fill,
                      ),
                      const SizedBox(height: 20,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('￥${StringUtil.getPriceStr(cash?.totalAmount) ?? ''}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18))
                        ],
                      ),
                      const SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap
                            ),
                            onPressed: (){
                              if(cash == null){
                                return;
                              }
                              showGeneralDialog(
                                barrierDismissible: true,
                                barrierLabel: '',
                                context: context,
                                pageBuilder:(context, animation, secondaryAnimation) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Material(
                                        color: Colors.transparent,
                                        child: CashWithdrawWidget(
                                          cash: cash!,
                                          customer: customer,
                                          onSubmit: ({required amount, required bankAccount, required bankName, required realName}) async{
                                            bool result = await WalletHttp().cashWithdraw(amount: amount, realName: realName, bankName: bankName, bankAccount: bankAccount, fail: (response){
                                              String? message = response.data['message'];
                                              ToastUtil.error(message ?? '提现申请失败');
                                            });
                                            if(!result){
                                              return;
                                            }
                                            ToastUtil.hint('提现申请成功');
                                            initData();
                                          },
                                        ),
                                      )
                                    ],
                                  );
                                },
                              );
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: ThemeUtil.buttonColor,
                                border: Border.fromBorderSide(BorderSide(color: ThemeUtil.buttonColor)),
                                borderRadius: BorderRadius.all(Radius.circular(8))
                              ),
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: const Text('提 现', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                getCustomerWidget(),
                getCashLogWidget(),
              ],
            ),
          )
        ],
      ),
    );
  }

  getCustomerWidget(){
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('我的账户', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
          const SizedBox(height: 12,),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0xee, 0xee, 0xee, 1),
                  offset: Offset(0, 2),
                  blurRadius: 2
                )
              ]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('真实姓名：', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
                    Text(customer?.realName ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),)
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('开户银行：', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
                    Text(customer?.billAccountBank ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),)
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('银行账户：', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
                    Text(customer?.billAccount ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),)
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap
                      ),
                      onPressed: (){
                        if(customer == null){
                          return;
                        }
                        showGeneralDialog(
                          barrierDismissible: true,
                          barrierLabel: '',
                          context: context,
                          pageBuilder:(context, animation, secondaryAnimation) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  child: CustomerEditWidget(
                                    customer: customer!,
                                    onSubmit: ({required bankAccount, required bankName, required realName}) async{
                                      bool result = await HttpCash.modifyCustomer(realName: realName, bankName: bankName, bankAccount: bankAccount);
                                      if(result){
                                        customer?.realName = realName;
                                        customer?.billAccountBank = bankName;
                                        customer?.billAccount = bankAccount;
                                        if(mounted && context.mounted){
                                          setState(() {
                                          });
                                        }
                                      }
                                    },
                                  ),
                                )
                              ],
                            );
                          },
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.fromLTRB(8, 2, 8, 2),
                        child: Text('修改', style: TextStyle(color: ThemeUtil.buttonColor),),
                      )
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  getCashLogWidget(){
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('流水', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
          const SizedBox(height: 12,),
          cashLogs == null || cashLogs!.isEmpty ?
          const Center(
            child: Text('您还没有流水记录', style: TextStyle(color: Colors.grey),),
          ) :
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0xee, 0xee, 0xee, 1),
                  offset: Offset(0, 2),
                  blurRadius: 2
                )
              ]
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: getCashLogList(),
              ),
            ),
          ),
          hasMore ?
          Center(
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
                padding: const EdgeInsets.all(8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap
              ),
              onPressed: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                  return const CashLogPage();
                }));
              },
              child: const Text('查看更多'),
            ),
          ):
          const SizedBox(),
          const SizedBox(height: 40,)
        ],
      ),
    );
  }

  List<Widget> getCashLogList(){
    List<Widget> widgets = [];
    DateFormat format = DateFormat("yyyy年MM月dd HH:mm");
    for(int i = 0; i < (cashLogs ?? []).length; ++i){
      CashLog cashLog = cashLogs![i];
      widgets.add(
        TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minimumSize: const Size(double.infinity, 0)
          ),
          onPressed: (){

          },
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${cashLog.description}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
                const SizedBox(height: 8,),
                cashLog.type == CashLogType.entry.getNum() ?
                Text('+ ￥${(cashLog.amount! / 100).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),) :
                Text('- ￥${(cashLog.amount! / 100).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),),
                const SizedBox(height: 8,),
                Text(format.format(cashLog.createTime!), style: const TextStyle(color: Colors.grey),)
              ],
            ),
          ),
        ),
      );
      if(i < cashLogs!.length - 1){
        widgets.add(
          const Divider()
        );
      }
    }
    return widgets;
  }

  void resetState(){
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }
}

class CustomerEditWidget extends StatefulWidget{
  final Customer customer;
  final Function({required String realName, required String bankName, required String bankAccount})? onSubmit;
  const CustomerEditWidget({required this.customer, this.onSubmit, super.key});

  @override
  State<StatefulWidget> createState() {
    return CustomerEditState();
  }
  
}

class CustomerEditState extends State<CustomerEditWidget>{

  TextEditingController realNameController = TextEditingController();
  TextEditingController bankNameController = TextEditingController();
  TextEditingController bankAccountController = TextEditingController();

  @override
  void dispose(){
    realNameController.dispose();
    bankNameController.dispose();
    bankAccountController.dispose();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    realNameController.text = widget.customer.realName ?? '';
    bankNameController.text = widget.customer.billAccountBank ?? '';
    bankAccountController.text = widget.customer.billAccount ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 2
          )
        ]
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('真实姓名：', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 4
                      )
                    ]
                  ),
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.end,
                    decoration: const InputDecoration(
                      hintText: '',
                      hintStyle: TextStyle(color: Color.fromRGBO(0xc5, 0xc5, 0xc6, 1)),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none
                    ),
                    controller: realNameController,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 12,),
          Row(
            children: [
              const Text('开户银行：', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 4
                      )
                    ]
                  ),
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.end,
                    decoration: const InputDecoration(
                      hintText: '',
                      hintStyle: TextStyle(color: Color.fromRGBO(0xc5, 0xc5, 0xc6, 1)),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none
                    ),
                    controller: bankNameController,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 12,),
          Row(
            children: [
              const Text('银行账户：', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 4
                      )
                    ]
                  ),
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.end,
                    decoration: const InputDecoration(
                      hintText: '',
                      hintStyle: TextStyle(color: Color.fromRGBO(0xc5, 0xc5, 0xc6, 1)),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none
                    ),
                    controller: bankAccountController,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 12,),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap
                ),
                onPressed: (){
                  String realName = realNameController.text;
                  String bankName = bankNameController.text;
                  String bankAccount = bankAccountController.text;
                  if(realName.isEmpty){
                    ToastUtil.warn('真实姓名不能为空');
                    return;
                  }
                  if(bankName.isEmpty){
                    ToastUtil.warn('开户银行不能为空');
                    return;
                  }
                  if(bankAccount.isEmpty){
                    ToastUtil.warn('银行账户不能为空');
                    return;
                  }
                  if(!RegularUtil.checkBankCard(bankAccount)){
                    ToastUtil.warn('银行账户格式错误');
                    return;
                  }
                  Navigator.of(context).pop();
                  widget.onSubmit?.call(realName: realNameController.text, bankName: bankNameController.text, bankAccount: bankAccountController.text);
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  decoration: const BoxDecoration(
                    color: ThemeUtil.buttonColor,
                    borderRadius: BorderRadius.all(Radius.circular(12))
                  ),
                  child: const Text('确 认', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
  
  void resetState(){
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }
}

class CashWithdrawWidget extends StatefulWidget{
  final Cash cash;
  final Customer? customer;
  final Function({required int amount, required String realName, required String bankName, required String bankAccount})? onSubmit;
  const CashWithdrawWidget({required this.cash, this.customer, this.onSubmit, super.key});

  @override
  State<StatefulWidget> createState() {
    return CashWithdrawState();
  }
  
}

class CashWithdrawState extends State<CashWithdrawWidget>{

  TextEditingController amountController = TextEditingController();
  TextEditingController realNameController = TextEditingController();
  TextEditingController bankNameController = TextEditingController();
  TextEditingController bankAccountController = TextEditingController();

  @override
  void initState(){
    super.initState();
    realNameController.text = widget.customer?.realName ?? '';
    bankNameController.text = widget.customer?.billAccountBank ?? '';
    bankAccountController.text = widget.customer?.billAccount ?? '';
  }

  @override
  void dispose(){
    amountController.dispose();
    realNameController.dispose();
    bankNameController.dispose();
    bankAccountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 2
          )
        ]
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('提现金额：', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 4
                      )
                    ]
                  ),
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.end,
                    decoration: const InputDecoration(
                      hintText: '',
                      hintStyle: TextStyle(color: Color.fromRGBO(0xc5, 0xc5, 0xc6, 1)),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none
                    ),
                    controller: amountController,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 12,),
          Row(
            children: [
              const Text('真实姓名：', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 4
                      )
                    ]
                  ),
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.end,
                    decoration: const InputDecoration(
                      hintText: '',
                      hintStyle: TextStyle(color: Color.fromRGBO(0xc5, 0xc5, 0xc6, 1)),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none
                    ),
                    controller: realNameController,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 12,),
          Row(
            children: [
              const Text('开户银行：', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 4
                      )
                    ]
                  ),
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.end,
                    decoration: const InputDecoration(
                      hintText: '',
                      hintStyle: TextStyle(color: Color.fromRGBO(0xc5, 0xc5, 0xc6, 1)),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none
                    ),
                    controller: bankNameController,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 12,),
          Row(
            children: [
              const Text('银行账户：', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 4
                      )
                    ]
                  ),
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.end,
                    decoration: const InputDecoration(
                      hintText: '',
                      hintStyle: TextStyle(color: Color.fromRGBO(0xc5, 0xc5, 0xc6, 1)),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none
                    ),
                    controller: bankAccountController,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 12,),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap
                ),
                onPressed: (){
                  if(amountController.text.isEmpty){
                    ToastUtil.error('金额不能为空');
                    return;
                  }
                  double? amount = double.tryParse(amountController.text);
                  if(amount == null){
                    ToastUtil.error('金额错误');
                    return;
                  }
                  if(amount <= 0){
                    ToastUtil.error('金额必须大于0');
                    return;
                  }
                  int amountVal = (amount * 100).toInt();
                  if(amountVal > (widget.cash.totalAmount ?? 0)){
                    ToastUtil.error('超出提现上限');
                    return;
                  }
                  String realName = realNameController.text;
                  String bankName = bankNameController.text;
                  String bankAccount = bankAccountController.text;
                  if(realName.isEmpty){
                    ToastUtil.warn('真实姓名不能为空');
                    return;
                  }
                  if(bankName.isEmpty){
                    ToastUtil.warn('开户银行不能为空');
                    return;
                  }
                  if(bankAccount.isEmpty){
                    ToastUtil.warn('银行账户不能为空');
                    return;
                  }
                  if(!RegularUtil.checkBankCard(bankAccount)){
                    ToastUtil.warn('银行账户格式错误');
                    return;
                  }
                  Navigator.of(context).pop();
                  widget.onSubmit?.call(amount: amountVal, realName: realName, bankName: bankName, bankAccount: bankAccount);
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  decoration: const BoxDecoration(
                    color: ThemeUtil.buttonColor,
                    borderRadius: BorderRadius.all(Radius.circular(12))
                  ),
                  child: const Text('确认提现', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
  
  void resetState(){
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }
}
