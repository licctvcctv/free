
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/merchent/merchant_model.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/image_viewer.dart';
import 'package:freego_flutter/components/web_views/merchant_terms.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/util/theme_util.dart';

class MerchantShowPage extends StatelessWidget{
  final Merchant merchant;
  const MerchantShowPage({required this.merchant, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 10,
        backgroundColor: ThemeUtil.backgroundColor,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      body: MerchantShowWidget(merchant: merchant),
    );
  }
  
}

class MerchantShowWidget extends StatefulWidget{
  final Merchant merchant;
  const MerchantShowWidget({required this.merchant, super.key});

  @override
  State<StatefulWidget> createState() {
    return MerchantShowState();
  }
  
}

class MerchantShowState extends State<MerchantShowWidget>{

  static Color tabColorOn = const Color.fromRGBO(4, 182, 221, 1);
  static Color tabColorOff = Colors.white;
  static Color submitBtnColorOn = const Color.fromRGBO(4, 182, 221, 1);

  int step = 0;

  setStep(int step) {
    this.step = step;
    setState(() {
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
            center: Text('商家申请', style: TextStyle(color: Colors.white, fontSize: 18),),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(0, 20, 0,20),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: (){
                      setStep(0);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color:step >= 0 ? tabColorOn: tabColorOff,
                        borderRadius: const BorderRadius.horizontal(left:Radius.circular(6))
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Text('商家类型', style: TextStyle(color: step >= 0 ? Colors.white: Colors.black),)
                    ),
                  )
                ),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: (){
                      setStep(1);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: step >= 1 ? tabColorOn : tabColorOff,
                      ),
                      child: Text('认证信息',style: TextStyle(color:step>=1?Colors.white: Colors.black))
                    ),
                  )
                ),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: (){
                      setStep(2);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:step >= 2 ? tabColorOn : tabColorOff,
                      ),
                      child: Text('结算信息',style: TextStyle(color: step >= 2 ?Colors.white: Colors.black))
                    ),
                  )
                ),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: (){
                      setStep(3);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:step >= 3 ? tabColorOn : tabColorOff,
                        borderRadius: const BorderRadius.horizontal(right:Radius.circular(6))
                      ),
                      child: Text('合同信息',style: TextStyle(color:step>=3?Colors.white: Colors.black))
                    ),
                  )
                )
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: IndexedStack(
              index: step,
              children: [
                getFirstPage(),
                getSecondPage(),
                getThirdPage(),
                getForthPage()
              ]
            )
          ),
        ],
      ),
    );
  }

  getFirstPage() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("选择类型",style: TextStyle(fontWeight: FontWeight.bold),),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            getTypeRadio(1, '酒店'),
                            const SizedBox(width: 30,),
                            getTypeRadio(2, '美食'),
                            const SizedBox(width: 30,),
                            getTypeRadio(3, '景点'),
                          ],
                        ),
                        const SizedBox(height: 10,),
                        Row(
                          children: [
                            getTypeRadio(4, '旅行社'),
                            const SizedBox(width: 16,),
                            getTypeRadio(5, '其他'),
                          ],
                        ),
                      ],
                    ),
                  )
                )
              ],
            )
          ),
          const SizedBox(height: 10,),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text("店铺名称:",style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8,),
                    Expanded(
                      flex: 1,
                      child: Text(widget.merchant.shopName ?? '')
                    )
                  ],
                ),
                const SizedBox(height: 10,),
                const SizedBox(
                  width: double.infinity,
                  child: Text("店招/前台照片:",style:TextStyle(fontWeight: FontWeight.bold))
                ),
                const SizedBox(height: 10,),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Row(
                    children: [
                      Column(
                        children:[
                          Container(
                            alignment: Alignment.center,
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              border: Border.all(color:Colors.black.withOpacity(0.1)),
                              borderRadius:BorderRadius.circular(4)
                            ),
                            child: widget.merchant.shopsignPic != null ?
                            InkWell(
                              onTap: (){
                                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                  return ImageViewer(getFullUrl(widget.merchant.shopsignPic!));
                                }));
                              },
                              child: Image.network(getFullUrl(widget.merchant.shopsignPic!), fit: BoxFit.fitWidth,),
                            ):
                            const Icon(Icons.add, size: 30, color:Colors.black54,),
                          ),
                          const SizedBox(height: 8,),
                          const Text('店招照片',style: TextStyle(fontSize:12),)
                        ]
                      ),
                      const SizedBox(width: 20,),
                      Column(
                        children:[
                          Container(
                            alignment: Alignment.center,
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              border: Border.all(color:Colors.black.withOpacity(0.1)),
                              borderRadius: BorderRadius.circular(4)
                            ),
                            child: widget.merchant.frontPic != null ?
                            InkWell(
                              onTap: (){
                                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                  return ImageViewer(getFullUrl(widget.merchant.frontPic!));
                                }));
                              },
                              child: Image.network(getFullUrl(widget.merchant.frontPic!), fit: BoxFit.fitWidth,),
                            ):
                            const Icon(Icons.add, size: 30, color:Colors.black54,),
                          ),
                          const SizedBox(height: 8,),
                          const Text('前台照片',style: TextStyle(fontSize:12),)
                        ]
                      )
                    ],
                  )
                ),
              ],
            ),
          ),
          const SizedBox(height: 10,),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text("店铺地址:",style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8,),
                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color:Colors.black.withOpacity(0.1),),
                          borderRadius: BorderRadius.circular(4)
                        ),
                        child: Text(widget.merchant.address ?? '')
                      )
                    ),
                    const SizedBox(width: 40,)
                  ]
                ),
                const SizedBox(height: 10,),
                Row(
                  children: [
                    const Text("联系方式:",style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8,),
                    Expanded(
                      flex: 1,
                      child: Text(widget.merchant.fixedPhone ?? '')
                    ),
                    const SizedBox(width: 40,)
                  ]
                )
              ]
            )
          ),
          const SizedBox(height: 20,),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: ElevatedButton(
              onPressed: (){
                setStep(1);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: submitBtnColorOn,
                padding: const EdgeInsets.fromLTRB(0, 14, 0, 14)),
              child: const Text('下一步',style:TextStyle(color:Colors.white)),
            )
          ),
          const SizedBox(height: 20,)
        ],
      )
    );
  }

  Widget getTypeRadio(int value, String name) {
    return Row(
      children: [
        widget.merchant.businessType == value ? 
        const Icon(Icons.radio_button_checked,size: 16,) : 
        const Icon(Icons.radio_button_off,size: 16,color: Colors.black26,),
        const SizedBox(width: 4,),
        Text(name,style: const TextStyle(color:Colors.black),)
      ],
    );
  }

  Widget getSecondPage() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children:[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("资质证件",style: TextStyle(fontWeight: FontWeight.bold),),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                getLicTypeRadio(0, '营业执照'),
                                const SizedBox(width: 30,),
                                getLicTypeRadio(1, '其他'),
                              ],
                            ),
                          ]
                        )
                      )
                    )
                  ]
                ),
                const SizedBox(height: 20,),
                Container(
                  alignment: Alignment.centerLeft,
                  width: double.infinity,
                  child: Container(
                    alignment: Alignment.center,
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border.all(color:Colors.black.withOpacity(0.1)),
                      borderRadius:BorderRadius.circular(4)
                    ),
                    child: widget.merchant.licPic != null ? 
                    InkWell(
                      onTap: (){
                        Navigator.of(context).push(MaterialPageRoute(builder: (context){
                          return ImageViewer(getFullUrl(widget.merchant.licPic!));
                        }));
                      },
                      child: Image.network(getFullUrl(widget.merchant.licPic!), fit: BoxFit.fitWidth,),
                    ): 
                    const Icon(Icons.add,size: 30,color:Colors.black54),
                  )
                ),
                const SizedBox(height: 10,),
                Container(
                  alignment: Alignment.centerLeft,
                  child: const Text('营业执照和实际地址是否不一致?', style: TextStyle(fontWeight: FontWeight.bold),),
                ),
                const SizedBox(height: 10,),
                Column(
                  children: [
                    Row(
                      children: [
                        getIsLicAddressSameRadio(1, '是'),
                        const SizedBox(width: 30,),
                        getIsLicAddressSameRadio(0, '否'),
                      ],
                    ),
                  ]
                ),
                const SizedBox(height: 10,),
                if(widget.merchant.isLicAddrSame == 0) 
                Row(
                  children: [
                    const Text('具体原因 '),
                    Expanded(
                      child: Text(widget.merchant.licAddrDes ?? ''),
                    )
                  ],
                )
              ]
            )
          ),
          const SizedBox(height: 10,),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: const Text('上传身份证照片',style: TextStyle(fontWeight: FontWeight.bold),),
                ),
                const SizedBox(height: 10,),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                  child: Row(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(color:Colors.black.withOpacity(0.1)),
                          borderRadius:BorderRadius.circular(4)
                        ),
                        child: widget.merchant.identityFrontPic != null ?
                        InkWell(
                          onTap: (){
                            Navigator.of(context).push(MaterialPageRoute(builder: (context){
                              return ImageViewer(getFullUrl(widget.merchant.identityFrontPic!));
                            }));
                          },
                          child: Image.network(getFullUrl(widget.merchant.identityFrontPic!), fit: BoxFit.fitWidth,),
                        ):
                        const Text('前',style: TextStyle(color:Colors.black54),)
                      ),
                      const SizedBox(width: 14,),
                      Container(
                        alignment: Alignment.center,
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(color:Colors.black.withOpacity(0.1)),
                          borderRadius:BorderRadius.circular(4)
                        ),
                        child: widget.merchant.identityBackPic != null ?
                        InkWell(
                          onTap: (){
                            Navigator.of(context).push(MaterialPageRoute(builder: (context){
                              return ImageViewer(getFullUrl(widget.merchant.identityBackPic!));
                            }));
                          },
                          child: Image.network(getFullUrl(widget.merchant.identityBackPic!), fit: BoxFit.fitWidth,),
                        ):
                        const Text('后',style: TextStyle(color:Colors.black54),),
                      ),
                      const SizedBox(width: 14,),
                      Container(
                        alignment: Alignment.center,
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(color:Colors.black.withOpacity(0.1)),
                          borderRadius:BorderRadius.circular(4)
                        ),
                        child: widget.merchant.identityHandPic != null ?
                        InkWell(
                          onTap: (){
                            Navigator.of(context).push(MaterialPageRoute(builder: (context){
                              return ImageViewer(getFullUrl(widget.merchant.identityHandPic!));
                            }));
                          },
                          child: Image.network(getFullUrl(widget.merchant.identityHandPic!), fit: BoxFit.fitWidth,),
                        ):
                        const Text('手持',style: TextStyle(color:Colors.black54),),
                      )
                    ],
                  )
                ),
                const SizedBox(height: 10,),
                Container(
                  alignment: Alignment.centerLeft,
                  child: const Text('以上证件照片是否为营业执照法人？',style: TextStyle(fontWeight: FontWeight.bold),),
                ),
                const SizedBox(height:10),
                Column(
                  children: [
                    Row(
                      children: [
                        getIsIdentityLegalRadio(1, '是'),
                        const SizedBox(width: 30,),
                        getIsIdentityLegalRadio(0, '否'),
                        const Text('（可上传工作证明或加盖公章授权委托书）',style: TextStyle(fontSize: 10,color: Colors.black54))
                      ],
                    ),
                  ]
                ),
                const SizedBox(height: 10,),
                widget.merchant.isIdentityLegal == 0 ? 
                Container(
                  alignment: Alignment.centerLeft,
                  width: double.infinity,
                  child: GestureDetector(
                    child: Container(
                      alignment: Alignment.center,
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border.all(color:Colors.black.withOpacity(0.1)),
                        borderRadius:BorderRadius.circular(4)
                      ),
                      child: widget.merchant.grantPic != null ?
                      InkWell(
                        onTap: (){
                          Navigator.of(context).push(MaterialPageRoute(builder: (context){
                            return ImageViewer(getFullUrl(widget.merchant.grantPic!));
                          }));
                        },
                        child: Image.network(getFullUrl(widget.merchant.grantPic!), fit: BoxFit.fitWidth,),
                      ):
                      Stack(
                        children: [
                          const Center(child:Icon(Icons.add,size: 30,color: Colors.black54,)),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(0,0,0,4),
                              child: const Text('无授权证明',style: TextStyle(fontSize: 11,color: Colors.black54)),
                            )
                          )
                        ]
                      ),
                    )
                  )
                ): const SizedBox(),
                const SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children:[
                    ElevatedButton(
                      onPressed: (){
                        setStep(0);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(4, 182, 221, 1),
                        padding: const EdgeInsets.fromLTRB(40 ,10, 40, 10)
                      ),
                      child: const Text('上一步',style:TextStyle(color:Colors.white)),
                    ),
                    ElevatedButton(
                      onPressed: (){
                        setStep(2);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: submitBtnColorOn,
                        padding: const EdgeInsets.fromLTRB(40, 10, 40, 10)
                      ),
                      child: const Text('下一步',style:TextStyle(color:Colors.white)),    
                    )
                  ]
                )
              ],
            )
          )
        ]
      )
    );
  }

  Widget getLicTypeRadio(int value, String name) {
    return Row(
      children: [
        widget.merchant.licType == value ? 
        const Icon(Icons.radio_button_checked,size: 16,) : 
        const Icon(Icons.radio_button_off,size: 16,color: Colors.black26,),
        const SizedBox(width: 4,),
        Text(name, style: const TextStyle(color:Colors.black),)
      ],
    );
  }

  Widget getIsLicAddressSameRadio(int value, String name) {
    return Row(
      children: [
        widget.merchant.isLicAddrSame == value ? 
        const Icon(Icons.radio_button_checked,size: 16,) : 
        const Icon(Icons.radio_button_off,size: 16,color: Colors.black26,),
        const SizedBox(width: 4,),
        Text(name, style: const TextStyle(color:Colors.black),)
      ],
    );
  }
  
  Widget getIsIdentityLegalRadio(int value, String name) {
    return Row(
      children: [
        widget.merchant.isIdentityLegal==value ? 
        const Icon(Icons.radio_button_checked,size: 16,): 
        const Icon(Icons.radio_button_off,size: 16,color: Colors.black26,),
        const SizedBox(width: 4,),
        Text(name, style: const TextStyle(color:Colors.black),)
      ],
    );
  }

  Widget getThirdPage() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Container(
        color: Colors.white,
        width: double.infinity,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(14, 20, 14, 12),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("结算周期",style: TextStyle(fontWeight: FontWeight.bold),),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  getPayPeriodRadio(0, '周结'),
                                  const SizedBox(width: 30,),
                                  getPayPeriodRadio(1, '月结'),
                                ],
                              ),
                            ]
                          )
                        )
                      )
                    ]
                  ),
                  const SizedBox(height: 30,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("账户类型",style: TextStyle(fontWeight: FontWeight.bold),),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  getPayAccountTypeRadio(0, '个人'),
                                  const SizedBox(width: 30,),
                                  getPayAccountTypeRadio(1, '公司'),
                                ],
                              ),
                            ]
                          )
                        )
                      )
                    ]
                  ),
                  const SizedBox(height: 40,),
                  Row(
                    children: [
                      const Text("账户名称:",style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8,),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 0, 50, 0),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              border: Border.fromBorderSide(BorderSide(color: Color.fromRGBO(0, 0, 0, 0.1))),
                              borderRadius: BorderRadius.all(Radius.circular(4))
                            ),
                            child: Text(widget.merchant.payAccountName ?? ''),
                          )
                        )
                      )
                    ],
                  ),
                  const SizedBox(height: 20,),
                  Row(
                    children: [
                      const Text("银行卡号:",style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8,),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 0, 50, 0),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              border: Border.fromBorderSide(BorderSide(color: Color.fromRGBO(0, 0, 0, 0.1))),
                              borderRadius: BorderRadius.all(Radius.circular(4))
                            ),
                            child: Text(widget.merchant.payAccountNum ?? ''),
                          )
                        )
                      )
                    ],
                  ),
                  const SizedBox(height: 20,),
                  Row(
                    children: [
                      const Text("开  户  行:",style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8,),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 0, 50, 0),
                          child: Column(
                            children: [
                              Container( 
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black.withOpacity(0.1),),
                                  borderRadius: BorderRadius.circular(4)
                                ),
                                child: Text(widget.merchant.payAccountProvince != null ? 
                                  "${widget.merchant.payAccountProvince}/${widget.merchant.payAccountCity}/${widget.merchant.payAccountDist}" : 
                                  "请选择省/市/区")
                              ),
                              const SizedBox(height: 8,),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  border: Border.fromBorderSide(BorderSide(color: Color.fromRGBO(0, 0, 0, 0.1))),
                                  borderRadius: BorderRadius.all(Radius.circular(4))
                                ),
                                child: Text(widget.merchant.payAccountBank ?? ''),
                              ),
                            ]
                          )
                        )
                      )
                    ],
                  ),
                  const SizedBox(height: 20,),
                  Row(
                    children: [
                      const Text("支  行  名:",style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8,),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 0, 50, 0),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              border: Border.fromBorderSide(BorderSide(color: Color.fromRGBO(0, 0, 0, 0.1))),
                              borderRadius: BorderRadius.all(Radius.circular(4))
                            ),
                            child: Text(widget.merchant.payAccountBankSub ?? ''),
                          )
                        )
                      )
                    ],
                  ),
                  const SizedBox(height: 20,),
                  Row(
                    children: [
                      const Text("银行行号:",style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8,),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 0, 50, 0),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              border: Border.fromBorderSide(BorderSide(color: Color.fromRGBO(0, 0, 0, 0.1))),
                              borderRadius: BorderRadius.all(Radius.circular(4))
                            ),
                            child: Text(widget.merchant.payAccountBankCode ?? ''),
                          )
                        )
                      )
                    ],
                  ),
                ],
              )
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
              decoration: const BoxDecoration(
                border: Border(top:BorderSide(width: 2,color: Colors.black12)),
                //borderRadius:BorderRadius.circular(6)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: (){
                      setStep(1);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(4, 182, 221, 1),
                      padding: const EdgeInsets.fromLTRB(40 ,10, 40, 10)
                    ),
                    child: const Text('上一步',style:TextStyle(color:Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: (){
                      setStep(3);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: submitBtnColorOn,
                      padding: const EdgeInsets.fromLTRB(40, 10, 40, 10)
                    ),
                    child: const Text('下一步',style:TextStyle(color:Colors.white)),
                  )
                ]
              )
            )
          ],
        ),
      )
    );
  }

  Widget getPayPeriodRadio(int value, String name) {
    return Row(
      children: [
        widget.merchant.payPeriod == value ?
        const Icon(Icons.radio_button_checked,size: 16,): 
        const Icon(Icons.radio_button_off,size: 16,color: Colors.black26,),
        const SizedBox(width: 4,),
        Text(name, style: const TextStyle(color:Colors.black),)
      ],
    );
  }

  Widget getPayAccountTypeRadio(int value, String name) {
    return Row(
      children: [
        widget.merchant.payAccountType == value ?
        const Icon(Icons.radio_button_checked,size: 16,) : 
        const Icon(Icons.radio_button_off,size: 16,color: Colors.black26,),
        const SizedBox(width: 4,),
        Text(name, style: const TextStyle(color:Colors.black),)
      ],
    );
  }

  Widget getForthPage() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(14, 20, 14, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text("联系人名称:",style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8,),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 0, 50, 0),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              border: Border.fromBorderSide(BorderSide(color: Color.fromRGBO(0, 0, 0, 0.1))),
                              borderRadius: BorderRadius.all(Radius.circular(4))
                            ),
                            child: Text(widget.merchant.contactName ?? ''),
                          )
                        )
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text("联系人电话:",style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8,),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 0, 50, 0),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              border: Border.fromBorderSide(BorderSide(color: Color.fromRGBO(0, 0, 0, 0.1))),
                              borderRadius: BorderRadius.all(Radius.circular(4))
                            ),
                            child: Text(widget.merchant.contactPhone ?? ''),
                          )
                        )
                      )
                    ],
                  ),
                  const SizedBox(height:20),
                  Row(
                    children: [
                      const Text("联系人邮箱:",style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8,),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 0, 50, 0),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              border: Border.fromBorderSide(BorderSide(color: Color.fromRGBO(0, 0, 0, 0.1))),
                              borderRadius: BorderRadius.all(Radius.circular(4))
                            ),
                            child: Text(widget.merchant.contactEmail ?? ''),
                          )
                        )
                      )
                    ],
                  ),
                  const SizedBox(height:20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("合作类型",style: TextStyle(fontWeight: FontWeight.bold),),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  getLicTypeRadio(0, '预付'),
                                ],
                              ),
                            ]
                          )
                        )
                      )
                    ]
                  ),
                  const SizedBox(height:20),
                  Row(
                    children: const [
                      Text("佣金支付:",style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 8,),
                      Text("1%")
                    ]
                  )
                ],
              )
            ),
            const SizedBox(height: 10,),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.fromLTRB(14, 20, 14, 20),
              child: RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: '查看',
                      style: TextStyle(color: ThemeUtil.foregroundColor)
                    ),
                    TextSpan(
                      text: '《商家协议》',
                      recognizer: TapGestureRecognizer()..onTap = (){
                        Navigator.of(context).push(MaterialPageRoute(builder: (context){
                          return const MerchantTermsPage();
                        }));
                      },
                      style: const TextStyle(color: Colors.lightBlue)
                    )
                  ]
                ),
              )
            ),
            const SizedBox(height: 2,),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.fromLTRB(14, 20, 14, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: (){
                      setStep(2);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:submitBtnColorOn,
                      padding: const EdgeInsets.fromLTRB(40 ,10, 40, 10)
                    ),
                    child: const Text('上一步',style:TextStyle(color:Colors.white)),
                  ),
                ],
              )
            ),
          ]
        )
      )
    );
  }
}
