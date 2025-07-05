
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MerchantTermsPage extends StatelessWidget{
  const MerchantTermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    /*WebViewController controller = WebViewController()..loadRequest(Uri.parse('http://freego.freemen.work/merchant_terms.html'));
    controller.clearLocalStorage();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 10,
        backgroundColor: ThemeUtil.backgroundColor,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      body: WillPopScope(
        onWillPop: () async{
          if(await controller.canGoBack()){
            controller.goBack();
            return false;
          }
          return true;
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CommonHeader(
              center: Text('商家协议', style: TextStyle(color: Colors.white),),
            ),
            Expanded(
              child: WebViewWidget(
                controller: controller,
              ),
            )
          ],
        ),
      ),
    );*/
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 10,
        backgroundColor: ThemeUtil.backgroundColor,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonHeader(
            center: Text('商家协议', style: TextStyle(color: Colors.white)),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("[freego] 商家合作协议"),
                  const SizedBox(height: 16),
                  _buildParagraph('欢迎您申请成为 [freego] 的合作商家！在您提交申请前，请仔细阅读本合作协议（以下简称"本协议"），本协议包含了您与 [freego] 之间的重要权利义务约定。通过提交申请，即表示您已充分阅读、理解并同意接受本协议的全部条款。'),
                  
                  _buildSectionTitle("一、合作主体与期限"),
                  _buildSubTitle("合作主体："),
                  _buildParagraph('本协议由 [杭州玛亚科技有限公司]（以下简称"平台"）与申请入驻平台的商家（以下简称"您"或"商家"）签订。'),
                  
                  _buildSubTitle("合作期限："),
                  _buildParagraph('本协议自商家通过平台审核并完成入驻流程之日起生效，有效期为一年。协议期满前一个月，双方如无异议，则自动延续一年。'),
                  
                  _buildSectionTitle("二、商家入驻资格与审核"),
                  _buildSubTitle("入驻资格："),
                  _buildParagraph('商家必须是依法设立且有效存续的企业法人或其他组织，具备提供住宿、景点、美食、旅行社等相关产品或服务的合法资质，并符合平台不时更新公布的入驻标准。'),
                  
                  _buildSubTitle("审核流程："),
                  _buildParagraph('平台将对商家提交的入驻申请资料进行审核，包括但不限于营业执照、相关经营许可证、法人身份证明、产品或服务信息等。审核时间一般为五个工作日，特殊情况下可能延长。审核通过后，商家方可正式入驻平台开展业务。'),
                  
                  _buildSectionTitle("三、双方权利与义务"),
                  _buildSubTitle("（一）平台权利与义务"),
                  _buildSubTitle("平台权利"),
                  _buildBulletPoint('根据市场情况和平台运营需要，制定和调整平台规则、收费标准等，并在平台上进行公示。'),
                  _buildBulletPoint('对商家的经营活动进行监督和管理，包括但不限于对商家提供的产品或服务信息进行审核、检查，对违规行为进行处理。'),
                  _buildBulletPoint('有权根据商家的经营状况、信用评级等，调整商家产品或服务在平台上的展示位置、排序等。'),
                  
                  _buildSubTitle("平台义务"),
                  _buildBulletPoint('为商家提供平台技术支持，确保平台的正常运行，保障商家能够顺利发布产品或服务信息、处理订单等业务操作。'),
                  _buildBulletPoint('通过平台的市场推广活动，提升平台的知名度和流量，为商家带来潜在客户。'),
                  _buildBulletPoint('对商家的商业秘密和用户信息进行保密，未经商家书面同意，不得向第三方披露，但法律法规另有规定或监管部门要求的除外。'),
                  _buildBulletPoint('及时向商家反馈用户的评价、投诉等信息，并协助商家处理相关问题。'),
                  
                  _buildSubTitle("（二）商家权利与义务"),
                  _buildSubTitle("商家权利"),
                  _buildBulletPoint('有权在平台上按照平台规则展示和销售符合规定的产品或服务。'),
                  _buildBulletPoint('有权获得平台提供的技术支持、市场推广等服务。'),
                  _buildBulletPoint('有权对平台的服务和管理提出意见和建议。'),
                  
                  _buildSubTitle("商家义务"),
                  _buildBulletPoint('确保向平台提供的所有信息真实、准确、完整且合法有效，并及时更新信息。包括但不限于企业基本信息、产品或服务详情、价格、库存等信息。'),
                  _buildBulletPoint('严格按照平台规则开展经营活动，不得从事任何损害平台声誉、利益或违反法律法规的行为。'),
                  _buildBulletPoint('保证所提供的产品或服务质量符合国家相关标准和行业规范，以及商家在平台上承诺的标准。及时处理用户的订单、咨询、投诉等，确保用户的合法权益得到保障。'),
                  _buildBulletPoint('按照平台规定的收费标准和结算周期，向平台支付相关费用。'),
                  _buildBulletPoint('对在经营过程中知悉的平台商业秘密、用户信息等进行保密，不得泄露给第三方。'),
                  _buildBulletPoint('配合平台开展的各类促销活动、市场调研等工作，并按照活动要求提供相应的支持和资源。'),
                  
                  _buildSectionTitle("四、产品与服务管理"),
                  _buildSubTitle("信息发布："),
                  _buildParagraph('商家应按照平台要求的格式和内容规范，准确、详细地发布产品或服务信息，包括但不限于名称、描述、图片、价格、服务内容、使用规则等。信息应真实反映产品或服务的实际情况，不得含有虚假、误导性内容。'),
                  
                  _buildSubTitle("价格管理："),
                  _buildParagraph('商家应确保在平台上设置的产品或服务价格具有竞争力且合理。价格调整应提前通知平台，并按照平台规定的流程进行操作。在促销活动期间，商家应遵守活动的价格约定，不得随意涨价或变相涨价。'),
                  
                  _buildSubTitle("库存管理："),
                  _buildParagraph('商家需实时更新产品或服务的库存信息，确保库存数量准确。如因库存不足导致无法履行订单，商家应承担相应责任，并及时通知用户和平台。'),
                  
                  _buildSubTitle("服务质量："),
                  _buildParagraph('商家应提供优质的服务，确保用户能够按照约定享受产品或服务。对于用户的反馈和投诉，商家应积极响应并妥善处理，在规定时间内给予用户满意的答复。如因商家服务质量问题导致用户向平台投诉或索赔，商家应负责解决并承担相应损失。'),
                  
                  _buildSectionTitle("五、订单处理与履行"),
                  _buildSubTitle("订单接收与确认："),
                  _buildParagraph('平台将用户下单信息及时传递给商家，平台有权根据情况自动确认订单'),
                  
                  _buildSubTitle("订单履行："),
                  _buildParagraph('商家应按照订单约定的时间、地点和方式，为用户提供产品或服务。确保产品或服务的质量和数量符合订单要求，不得擅自变更或减少服务内容。如因不可抗力等特殊原因无法按时履行订单，商家应及时通知用户和平台，并协商解决方案。'),
                  
                  _buildSubTitle("订单变更与取消："),
                  _buildParagraph('用户提出订单变更或取消申请时，商家应根据平台规则和实际情况进行处理。如订单变更或取消是由于商家原因导致的，商家应承担相应责任，如给用户造成损失，应予以赔偿。'),
                  
                  _buildSectionTitle("六、收益结算"),
                  _buildSubTitle("结算周期："),
                  _buildParagraph('平台与商家的收益结算为完成订单后次日进行。订单完成以用户实际消费完毕或服务履约结束，且无争议确认为准。'),
                  
                  _buildSubTitle("结算方式："),
                  _buildParagraph('平台将根据商家在平台上的实际交易金额，扣除平台规定的佣金及其他费用后，将剩余款项结算至商家指定的账户。结算金额以平台系统记录的数据为准，商家如有异议，应在结算日后五个工作日内提出，逾期视为无异议。'),
                  
                  _buildSubTitle("发票开具："),
                  _buildParagraph('商家应按照平台要求，及时向平台开具合法有效的发票。如商家未按时开具发票或发票不符合规定，平台有权暂停结算或扣除相应款项。'),
                  
                  _buildSectionTitle("七、促销与推广"),
                  _buildSubTitle("平台促销活动："),
                  _buildParagraph('平台将不定期组织各类促销活动，商家应积极参与。参与活动的商家应按照活动规则提供相应的优惠、折扣等，并确保活动期间产品或服务的供应和质量。平台有权根据活动效果和商家参与情况，对参与活动的商家进行筛选和调整。'),
                  
                  _buildSubTitle("商家自主推广："),
                  _buildParagraph('商家可以在平台规则允许的范围内，自主开展推广活动。推广活动的策划、执行和费用由商家自行承担。商家应确保推广活动内容合法、合规，不得对用户进行骚扰或欺诈。如因商家自主推广活动给平台或用户造成损失，商家应承担赔偿责任。'),
                  
                  _buildSectionTitle("八、保密条款"),
                  _buildSubTitle("保密信息："),
                  _buildParagraph('双方应对在合作过程中知悉的对方商业秘密、技术秘密、用户信息等保密信息予以保密。保密信息包括但不限于产品或服务信息、价格策略、运营数据、客户名单等。'),
                  
                  _buildSubTitle("保密义务："),
                  _buildParagraph('未经对方书面同意，任何一方不得向第三方披露、使用或允许第三方使用保密信息。保密义务在本协议终止后一年内仍然有效。'),
                  
                  _buildSubTitle("违约责任："),
                  _buildParagraph('如一方违反保密条款，应向对方支付违约金，并赔偿对方因此遭受的全部损失。如违约金不足以弥补损失的，违约方还应继续赔偿。'),
                  
                  _buildSectionTitle("九、违约责任"),
                  _buildSubTitle("商家违约："),
                  _buildParagraph('如商家违反本协议约定，平台有权采取以下一种或多种措施：'),
                  _buildBulletPoint('警告：对商家的违规行为进行书面警告，要求其立即整改。'),
                  _buildBulletPoint('扣除保证金：根据违规情节轻重，扣除商家一定金额的保证金。'),
                  _buildBulletPoint('暂停业务：暂停商家在平台上的部分或全部业务，直至商家整改完成。'),
                  _buildBulletPoint('终止协议：对于严重违反本协议或多次违规的商家，平台有权单方面终止本协议，并扣除全部保证金。同时，商家应承担因其违约行为给平台和用户造成的全部损失，包括但不限于直接损失、间接损失、诉讼费、律师费等。'),
                  
                  _buildSubTitle("平台违约："),
                  _buildParagraph('如平台违反本协议约定，给商家造成损失的，平台应承担赔偿责任。赔偿范围包括商家的直接损失，但不包括商家的预期利润损失。如因不可抗力等不可预见、不可避免且不可克服的原因导致平台违约的，平台不承担责任，但应及时通知商家并提供相关证明。'),
                  
                  _buildSectionTitle("十、协议变更与终止"),
                  _buildSubTitle("协议变更："),
                  _buildParagraph('平台有权根据法律法规变化、市场情况调整或平台运营需要，对本协议进行修订。修订后的协议将在平台上进行公示，公示期为十天。如商家在公示期内未提出异议，则视为同意接受修订后的协议。如商家不同意修订后的协议，有权在公示期届满前书面通知平台终止本协议。'),
                  
                  _buildSubTitle("协议终止"),
                  _buildBulletPoint('自然终止：本协议在合作期限届满且双方未续签的情况下自然终止。'),
                  _buildBulletPoint('提前终止：如一方违反本协议约定，严重影响对方利益或导致协议无法继续履行的，另一方有权提前终止本协议。此外，如因法律法规调整或不可抗力等原因导致本协议无法继续履行的，双方可协商提前终止本协议。'),
                  
                  _buildSubTitle("终止后的处理："),
                  _buildParagraph('协议终止后，双方应按照法律法规和本协议约定，进行清算和交接工作。商家应及时将平台提供的相关账号、资料等归还平台，平台应将剩余保证金（如有）及未结算款项按照约定支付给商家。双方应对在合作期间知悉的对方保密信息继续履行保密义务。'),
                  
                  _buildSectionTitle("十一、争议解决"),
                  _buildSubTitle("协商解决："),
                  _buildParagraph('双方在履行本协议过程中如发生争议，应首先通过友好协商解决。协商不成的，任何一方均可向有管辖权的人民法院提起诉讼。'),
                  
                  _buildSubTitle("法律适用："),
                  _buildParagraph('本协议的签订、履行、解释及争议解决均适用 [中华人民共和国民法典] 法律。'),
                  
                  _buildSectionTitle("十二、其他条款"),
                  _buildSubTitle("完整性："),
                  _buildParagraph('本协议构成双方就合作事宜达成的完整协议，取代双方之前就同一事项达成的所有口头或书面协议。'),
                  
                  _buildSubTitle("可分割性："),
                  _buildParagraph('如本协议的任何条款被认定为无效或不可执行，不影响其他条款的有效性和可执行性。双方应协商对无效或不可执行的条款进行修改或调整，使其合法有效。'),
                  
                  _buildSubTitle("通知："),
                  _buildParagraph('双方之间的通知应采用书面形式，通过专人送达、挂号信、快递或电子邮件等方式发送至本协议约定的地址或电子邮箱。通知在送达对方或发送至对方电子邮箱后视为已送达。如一方地址或电子邮箱发生变更，应在变更后 [10] 个工作日内书面通知对方，否则视为未变更。'),
                  
                  _buildSubTitle("附件："),
                  _buildParagraph('本协议的附件包括但不限于平台规则、商家入驻标准、收费标准等，是本协议的重要组成部分，与本协议具有同等法律效力。附件内容如有更新，以平台最新发布的版本为准。'),
                  
                  _buildParagraph('请您再次确认已充分阅读并理解本协议的所有条款，如有任何疑问，请联系平台客服咨询。一旦您提交入驻申请，即视为您已同意接受本协议的约束。'),
                  
                  const SizedBox(height: 32),
                  _buildParagraph('[杭州玛亚科技有限公司]'),
                  _buildParagraph('[2024-1-1]'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSubTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black54,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 15)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
}
