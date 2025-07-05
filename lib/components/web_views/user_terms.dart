
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:webview_flutter/webview_flutter.dart';

class UserTermsPage extends StatelessWidget{
  const UserTermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    /*WebViewController controller = WebViewController()..loadRequest(Uri.parse('http://freego.freemen.work/user_terms.html'));
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
              center: Text('用户协议', style: TextStyle(color: Colors.white),),
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
            center: Text('用户协议', style: TextStyle(color: Colors.white)),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("[freego] 服务协议"),
                  const SizedBox(height: 16),
                  _buildParagraph("欢迎您使用 [freego]（以下简称“本平台”）提供的服务！本服务协议（以下简称“本协议”）是您与本平台运营方之间就您使用本平台服务所达成的协议，请您仔细阅读本协议的所有条款，特别是以加粗字体显示的条款，这些条款可能会对您的权利和义务产生重大影响。您使用本平台服务，即视为您已阅读、理解并同意接受本协议的约束。如果您不同意本协议的任何条款，请不要使用本平台服务。"),
                  
                  _buildSectionTitle("一、定义"),
                  _buildParagraph("本平台：指由 [平台运营方名称] 运营的在线旅游服务平台，包括但不限于本平台的网站（网址为 [具体网址]）、移动应用程序及后续可能开发的其他客户端形式。"),
                  _buildParagraph("用户：指访问或使用本平台服务的自然人、法人或其他组织。"),
                  _buildParagraph("服务：指本平台基于互联网为用户提供的在线旅游相关服务，包括但不限于酒店预订、门票预订、旅游度假产品预订以及其他相关的信息展示、搜索、咨询、交易等服务。"),
                  
                  _buildSectionTitle("二、服务内容"),
                  _buildParagraph("本平台致力于为用户提供丰富、便捷的在线旅游服务，协助用户预订各类旅游产品和服务，并提供相关的信息查询、比较、预订确认等功能。"),
                  _buildParagraph("本平台有权根据自身业务发展情况、法律法规变化、市场需求等因素，随时调整、变更或终止部分或全部服务内容，但应提前通过本平台显著位置公告或其他合理方式通知用户。若用户在服务变更或终止后继续使用本平台服务，视为用户同意变更后的服务内容；若用户不同意服务变更或终止，有权停止使用本平台服务。"),
                  
                  _buildSectionTitle("三、用户注册与账户管理"),                  
                  _buildSubTitle("1. 账户安全："),
                  _buildParagraph("您应对您注册的账户及设置的密码负责，妥善保管账户信息，不得向任何第三方透露。因您保管不善导致账户被他人使用或遭受损失的，本平台不承担责任。如您发现账户存在异常或被盗用等情况，应立即通知本平台，并按照本平台要求采取相应措施。在您通知本平台并按照要求采取措施之前，因账户使用所产生的一切后果由您自行承担。"),
                  
                  _buildSubTitle("2. 账户使用限制："),
                  _buildParagraph("您不得将注册账户用于任何非法目的，或从事任何违反法律法规、本协议约定及社会公序良俗的行为。未经本平台书面同意，您不得转让、出租、出借账户，或利用账户进行刷单、恶意下单、虚假交易、扰乱平台秩序等行为。若本平台发现您存在上述违规行为，有权采取包括但不限于暂停或终止服务、冻结或注销账户、追究法律责任等措施。"),
                  
                  _buildSectionTitle("四、服务使用规则"),
                  _buildSubTitle("1. 遵守法律法规："),
                  _buildParagraph("您在使用本平台服务过程中，应严格遵守中华人民共和国及其他相关国家和地区的法律法规，不得利用本平台服务从事任何违法犯罪活动，包括但不限于："),
                  _buildBulletPoint("发布、传播含有淫秽、色情、暴力、恐怖、反动、侮辱、诽谤、欺诈、虚假广告等违法或有害内容的信息；"),
                  _buildBulletPoint("侵犯他人知识产权、隐私权、名誉权等合法权益；"),
                  _buildBulletPoint("从事网络诈骗、非法集资、传销等违法金融活动；"),
                  _buildBulletPoint("恶意攻击本平台服务器、破坏本平台数据或妨碍本平台正常运营的行为。"),
                  
                  _buildSubTitle("2. 诚信使用服务："),
                  _buildParagraph("您应秉持诚实信用原则使用本平台服务，不得进行任何恶意行为干扰本平台的正常运行，包括但不限于："),
                  _buildBulletPoint("使用机器人程序、网络爬虫或其他自动化工具大量抓取本平台数据，影响本平台服务器性能和其他用户体验；"),
                  _buildBulletPoint("恶意刷取积分、优惠券、评价等，破坏本平台的公平交易环境和信誉评价体系；"),
                  _buildBulletPoint("故意制造虚假订单或滥用本平台的取消、退款政策，给本平台或其他用户造成损失。"),
                  
                  _buildSubTitle("3. 信息发布规范："),
                  _buildParagraph("若您在本平台发布评论、攻略、提问等用户生成内容，应确保内容真实、客观、合法，不得包含任何违法、违规或侵犯他人权益的信息。本平台有权对用户发布的内容进行审核，对于不符合要求的内容，本平台有权不予发布、删除或屏蔽，并有权对违规用户采取相应的处罚措施。同时，您授予本平台一项全球范围内、免费、永久、非独家、可再许可的权利，允许本平台使用、复制、修改、翻译、传播、展示、推广您发布的内容，用于本平台的运营、宣传及其他合法目的。"),
                  
                  _buildSectionTitle("五、产品与服务预订"),
                  _buildSubTitle("1. 预订流程："),
                  _buildParagraph("您在本平台预订酒店、门票、旅游度假产品等服务时，应仔细阅读相关产品或服务的介绍、价格、预订条款、退改政策等信息，并按照本平台提示的流程进行操作。在您提交预订订单并完成支付后，本平台将尽力为您确认预订。若预订成功，本平台将向您发送预订确认信息；若预订失败，本平台将按照原支付渠道退还您已支付的款项。"),
                  
                  _buildSubTitle("2. 价格与支付："),
                  _buildParagraph("本平台展示的产品和服务价格可能因市场波动、季节变化、库存情况等因素而有所不同，最终价格以您下单时系统显示的价格为准。您应按照本平台支持的支付方式及时支付预订款项，若您未在规定时间内完成支付，订单可能会自动取消。如因支付问题导致预订失败或产生其他纠纷，您应自行与支付机构协商解决，本平台将提供必要的协助。"),
                  
                  _buildSubTitle("3. 退改政策："),
                  _buildParagraph("不同的产品和服务可能有不同的退改政策，具体以产品或服务详情页面展示的退改规则为准。您在预订前应仔细了解并确认退改政策，若您需要取消或修改预订，应按照退改政策的规定操作。因您自身原因导致无法按照退改政策进行退改而产生的损失，由您自行承担。若产品或服务供应商因不可抗力等原因无法履行合同义务，导致您的预订需要取消或变更的，本平台将协助您与供应商协商解决方案，但不承担因供应商原因给您造成的直接或间接损失。"),
                  
                  _buildSectionTitle("六、隐私保护"),
                  _buildSubTitle("1. 信息收集："),
                  _buildParagraph("本平台会在您使用服务过程中收集必要的个人信息，包括但不限于注册信息、订单信息、支付信息、浏览记录等，以提供服务、改进产品、保障交易安全及遵守法律法规的要求。本平台收集信息的方式包括但不限于您主动填写、系统自动记录、第三方共享等。"),
                  
                  _buildSubTitle("2. 信息使用："),
                  _buildParagraph("本平台仅将收集的个人信息用于与提供服务相关的目的，包括但不限于为您提供个性化的服务推荐、处理订单、提供客户支持、开展市场调研、进行数据分析以优化服务等。未经您的明确同意，本平台不会将您的个人信息用于其他目的，也不会向任何第三方出售、出租或泄露您的个人信息，但以下情况除外："),
                  _buildBulletPoint("法律法规要求或政府部门的合法要求；"),
                  _buildBulletPoint("为维护本平台或其他用户的合法权益，如防止欺诈、保护账户安全等；"),
                  _buildBulletPoint("您同意本平台将信息共享给特定的合作伙伴，以便为您提供更全面的服务。"),
                  
                  _buildSubTitle("3. 信息安全："),
                  _buildParagraph("本平台采取合理的技术和管理措施，保护您的个人信息安全，防止信息被泄露、篡改或丢失。但由于互联网环境的复杂性，无法完全保证信息的绝对安全。如发生个人信息安全事件，本平台将及时通知您，并按照法律法规的要求采取相应的措施进行处理。"),
                  
                  _buildSubTitle("4. 您的权利："),
                  _buildParagraph("您有权查阅、更正、删除您在本平台的个人信息，有权拒绝本平台继续收集您的部分信息（但可能会影响您使用部分服务），有权要求本平台对您的个人信息进行转移等。您可以通过本平台提供的设置功能或联系客服等方式行使上述权利。"),
                  
                  _buildSectionTitle("七、知识产权"),
                  _buildParagraph("本平台及平台上的所有内容，包括但不限于文字、图片、音频、视频、软件、数据、页面设计、编排等，均受中华人民共和国及其他相关国家和地区的知识产权法律法规保护，本平台享有上述内容的知识产权（包括但不限于著作权、商标权、专利权等）。未经本平台书面许可，您不得复制、传播、修改、展示、出售、转让或以其他方式使用本平台的任何内容。"),
                  _buildParagraph("您在本平台上传、发布的内容，您应保证拥有合法的知识产权或已获得相关权利人的授权。您授予本平台一项全球范围内、免费、永久、非独家、可再许可的权利，允许本平台使用、复制、修改、翻译、传播、展示、推广您上传、发布的内容，用于本平台的运营、宣传及其他合法目的。若您上传、发布的内容侵犯了他人的知识产权或其他合法权益，您应承担全部法律责任，本平台有权删除相关内容，并对您采取相应的处罚措施，如因此给本平台造成损失的，您应予以赔偿。"),
                  
                  _buildSectionTitle("八、免责声明"),
                  _buildSubTitle("1. 不可抗力："),
                  _buildParagraph("因不可抗力（包括但不限于自然灾害、政府行为、社会异常事件、战争、罢工、网络攻击、通信线路故障、服务器故障等）导致本平台无法提供服务或给您造成损失的，本平台不承担责任。但本平台将尽力在不可抗力事件发生后及时通知您，并采取合理措施减少损失。"),
                  
                  _buildSubTitle("2. 服务中断与维护："),
                  _buildParagraph("本平台需要定期或不定期地对提供服务的平台、服务器或相关设备进行检修、维护、升级等工作，如因此类情况而造成服务在合理时间内的中断，本平台无需为此承担责任，但将尽可能提前通知您。同时，由于互联网及移动通讯等服务的特殊性，可能会受到各个环节不稳定因素的影响，导致服务出现延迟、中断、错误等情况，本平台对此不承担责任。"),
                  
                  _buildSubTitle("3. 第三方服务："),
                  _buildParagraph("本平台可能会链接到第三方网站或使用第三方提供的服务（如支付机构、酒店预订系统、机票预订系统等），对于第三方服务的可用性、安全性、准确性及内容，本平台不承担责任。您在使用第三方服务时，应遵守第三方的相关规定和协议，若因第三方原因给您造成损失的，您应自行与第三方协商解决，本平台将提供必要的协助。"),
                  
                  _buildSubTitle("4. 用户自身原因："),
                  _buildParagraph("因您自身的过错（包括但不限于提供错误的信息、违反本协议约定、未按照本平台提示操作、未及时关注平台通知等）导致无法使用本平台服务或遭受损失的，本平台不承担责任。同时，您应对您在本平台上的行为负责，若您的行为给本平台或其他用户造成损失的，您应承担相应的赔偿责任。"),
                  
                  _buildSectionTitle("九、协议变更与终止"),
                  _buildSubTitle("1. 协议变更："),
                  _buildParagraph("本平台有权根据法律法规变化、业务发展需要、市场环境变化等因素，随时对本协议进行修改或更新。变更后的协议将在本平台显著位置公布，公布日期即为变更生效日期。若您在协议变更后继续使用本平台服务，视为您已接受变更后的协议；若您不同意协议变更，有权停止使用本平台服务。"),
                  
                  _buildSubTitle("2. 服务终止："),
                  _buildParagraph("在以下情况下，本平台有权单方面终止向您提供服务，且无需向您承担任何责任："),
                  _buildBulletPoint("您违反本协议约定，且在本平台通知后未在规定时间内改正；"),
                  _buildBulletPoint("您从事违法犯罪活动或严重违反社会公序良俗，利用本平台服务进行非法活动；"),
                  _buildBulletPoint("本平台因业务调整、技术升级等原因，决定停止提供部分或全部服务；"),
                  _buildBulletPoint("法律法规规定的其他情形。"),
                  _buildParagraph("服务终止后，本平台有权删除您在本平台的账户及相关信息，但法律法规另有规定或监管部门另有要求的除外。"),
                  
                  _buildSectionTitle("十、争议解决"),
                  _buildParagraph("本协议的签订、履行、解释及争议解决均适用中华人民共和国法律（为本协议之目的，不包括香港特别行政区、澳门特别行政区和台湾地区法律）。"),
                  _buildParagraph("如您与本平台在本协议履行过程中发生争议，应首先通过友好协商解决；协商不成的，任何一方均有权向本平台运营方所在地有管辖权的人民法院提起诉讼。"),
                  
                  _buildSectionTitle("十一、其他条款"),
                  _buildParagraph("本协议构成您与本平台之间关于使用本平台服务的完整协议，取代之前双方就同一事项达成的所有口头或书面协议。"),
                  _buildParagraph("若本协议的任何条款被认定为无效、违法或不可执行，不影响其他条款的有效性、合法性和可执行性，其他条款应继续履行。"),
                  _buildParagraph("本平台未行使或执行本协议任何权利或条款，不构成对该权利或条款的放弃。本平台对您的违约行为未采取行动，不代表本平台放弃对后续违约行为采取行动的权利。"),
                  _buildParagraph("本协议中的标题仅为方便阅读而设，不具有法律或合同效力。"),
                  
                  const SizedBox(height: 32),
                  _buildParagraph("最后更新日期：[2024-01-01]"),
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
