
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:webview_flutter/webview_flutter.dart';

class UserPrivaciesPage extends StatelessWidget{
  const UserPrivaciesPage({super.key});

  @override
  Widget build(BuildContext context) {
    /*WebViewController controller = WebViewController()..loadRequest(Uri.parse('http://freego.freemen.work/user_privacies.html'));
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
              center: Text('隐私协议', style: TextStyle(color: Colors.white),),
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
            center: Text('隐私协议', style: TextStyle(color: Colors.white)),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("[freego] 隐私政策"),
                  _buildVersionDate("版本生效日期：[2024-1-1]"),
                  const SizedBox(height: 16),
                  
                  _buildSectionTitle("引言"),
                  _buildParagraph("您的信任对我们至关重要，我们深知个人信息对您的重要性。本隐私政策（以下简称\"本政策\"）将向您详细说明，在您使用我们的 freego APP（以下简称\"本 APP\"或\"我们的服务\"）过程中，我们如何收集、使用、共享、存储和保护您的个人信息，以及您对个人信息所享有的权利。请您在使用我们的服务前，仔细阅读并充分理解本政策内容，特别是以加粗或下划线标识的条款。若您不同意本政策的任何内容，可能影响您对部分或全部服务的正常使用。如您对本政策有任何疑问、意见或建议，可通过本政策提供的联系方式与我们沟通。"),
                  
                  _buildSectionTitle("一、适用范围"),
                  _buildSubTitle("本政策适用范围："),
                  _buildParagraph("本政策适用于本 APP 提供的所有产品和服务。无论您是通过手机、平板电脑等移动设备访问本 APP，还是使用我们提供的相关小程序等，均适用本政策。"),
                  
                  _buildSubTitle("不适用范围："),
                  _buildParagraph("本政策不适用于通过本 APP 链接至第三方提供的产品或服务，该等第三方服务有其独立的隐私政策，您使用第三方服务时需遵循其相应的隐私政策规定。例如，当您在本 APP 中点击跳转到某航空公司官网购买机票，该航空公司对您个人信息的收集、使用等行为受其自身隐私政策约束。"),
                  
                  _buildSectionTitle("二、信息收集及使用"),
                  _buildParagraph("在您使用我们产品及/或服务时，我们需要或可能需要收集和使用的您的个人信息分为以下两类："),
                  _buildBulletPoint("必要信息：为实现向您提供我们产品及/或服务的基本功能，及履行法律法规规定的义务，您须授权我们收集、使用的必要的信息。如您拒绝提供相应信息，您将无法正常使用我们的产品及/或服务。"),
                  _buildBulletPoint("附加信息：为实现向您提供我们产品及/或服务的附加功能，您可选择授权我们收集、使用的信息。如您拒绝提供，您将无法正常使用相关附加功能或无法达到我们拟达到的功能效果，但并不会影响您正常使用我们产品及/或服务的基本功能。"),
                  
                  _buildSubTitle("（一）帮助您注册与管理账户"),
                  _buildBulletPoint("注册：若您想使用我们的服务，您需要注册一个账户。注册时，您至少需提供手机号码，并设置密码。"),
                  _buildBulletPoint("账户登录：您可通过注册时使用的手机号码/邮箱地址加密码方式登录账户。此外，我们也支持使用第三方账号（如微信、支付宝等）授权登录。当您选择第三方账号登录时，经您同意，我们会从第三方获取您授权共享的相关信息（如头像、昵称等），用于在本 APP 创建对应的账户并实现快速登录。"),
                  _buildBulletPoint("资料维护与账户管理：为提升您的服务体验，您可以选择补充完善更多个人信息，如姓名、性别、出生日期、地址等。您还可以设置头像、修改密码、绑定其他联系方式等。其中，您设置的头像、昵称等信息可能会在您使用部分社区交流、评论等功能时公开显示，以便其他用户识别与交流。"),
                  
                  _buildSubTitle("（二）帮助您使用浏览、搜索和个性化推荐功能"),
                  _buildBulletPoint("浏览：当您浏览本 APP 时，我们会自动收集您的设备信息（如设备型号、操作系统版本、设备标识符等）、网络信息（如 IP 地址、网络接入方式等）以及浏览记录（如您浏览的页面、停留时间、点击行为等）。这些信息有助于我们优化 APP 的性能与用户体验，例如根据您的设备信息适配页面显示，根据浏览记录改进页面布局与内容推荐。"),
                  _buildBulletPoint("个性化推荐：基于您的浏览记录、搜索历史、购买行为以及您主动设置的偏好信息（如出行目的地偏好、酒店星级偏好等），我们会运用算法为您提供个性化的产品推荐。例如，若您经常预订高星级酒店，我们可能会优先向您推荐符合您星级偏好的酒店产品；若您近期多次搜索某旅游目的地，我们会为您推送该目的地的相关旅游攻略、景点门票等产品。您可以在 APP 的相关设置中选择关闭个性化推荐功能，关闭后我们将不再基于上述信息为您提供个性化推荐，但仍会为您展示通用的产品与服务信息。"),
                  
                  _buildSubTitle("（三）帮助您预订产品与服务"),
                  _buildBulletPoint("订单信息：当您预订酒店、旅游套餐等产品或服务时，我们需要收集您的订单信息，包括但不限于预订的产品或服务类型、出发地、目的地、出行日期、入住日期、退房日期、住客信息（姓名、身份证件号码、联系方式等）、支付信息（支付方式、支付金额、支付时间等）。这些信息是完成订单交易、为您提供相应服务以及处理售后问题所必需的。例如，我们需要根据乘客信息为您出票，根据支付信息确认交易完成。"),
                  
                  _buildSubTitle("（四）帮助您使用客户服务功能"),
                  _buildBulletPoint("沟通记录：当您通过在线客服、电话客服等方式联系我们时，我们会记录您与客服人员的沟通内容，包括文字聊天记录、通话录音等。这些记录有助于我们更好地理解您的问题与需求，为您提供更有效的解决方案，同时也可作为处理纠纷、改进服务质量的依据。"),
                  _buildBulletPoint("问题反馈：若您在使用过程中向我们反馈问题或提出建议，我们会收集您反馈的内容、反馈时间以及您提供的相关截图、视频等辅助信息，以便我们深入分析问题，及时采取措施改进产品与服务。"),
                  
                  _buildSubTitle("（五）其他信息收集情况"),
                  _buildBulletPoint("基于位置的服务：当您开启设备的位置权限并同意我们获取位置信息时，我们可以为您提供基于位置的服务，如为您推荐附近的酒店、景点、餐厅，或根据您所在位置为您提供实时的交通信息等。您可以随时在设备设置中关闭位置权限，关闭后我们将无法获取您的实时位置，但可能影响部分基于位置的服务功能的正常使用。"),
                  _buildBulletPoint("设备权限调用：为实现某些特定功能，我们可能会调用您设备的一些权限，如相机权限用于拍摄证件照片进行身份验证、相册权限用于上传图片分享旅游经历、麦克风权限用于语音搜索或与客服进行语音沟通等。每次调用权限时，我们会向您弹窗提示，说明调用权限的目的，您可选择同意或拒绝。您一旦关闭任一权限即代表您取消了授权，我们将不再基于对应权限继续收集和使用相关个人信息，也无法为您提供该权限所对应的服务。但您关闭权限的决定不会影响此前基于您的授权所进行的信息收集及使用。"),
                  
                  _buildSectionTitle("三、数据使用过程中涉及的合作方及转移、公开用户信息"),
                  _buildSubTitle("（一）合作方"),
                  _buildBulletPoint("业务合作伙伴：我们会与酒店、旅游景点等业务合作伙伴共享您的必要个人信息，以完成您所预订的产品或服务的提供。例如，将您的酒店预订信息共享给酒店，用于安排房间入住等。我们仅会共享为实现业务目的所必需的信息，并且会与合作伙伴签署相关协议，要求他们严格遵守保密义务及相关数据保护法律法规，妥善处理您的个人信息。"),
                  _buildBulletPoint("第三方服务提供商：我们可能会聘请第三方服务提供商为我们提供技术支持、数据分析、支付处理、客户服务等服务。在提供服务过程中，第三方服务提供商可能会接触到您的个人信息。例如，支付机构需要获取您的支付信息以完成支付交易；数据分析公司可能会对您的使用行为数据进行分析，帮助我们优化产品与服务。同样，我们会与第三方服务提供商签订严格的合同，要求他们按照我们的指示以及相关法律法规的要求处理您的个人信息，不得将您的信息用于任何其他未经您同意的目的。"),
                  
                  _buildSubTitle("（二）转移"),
                  _buildBulletPoint("公司内部转移：在我们公司内部，为了实现业务协同、数据统一管理等目的，您的个人信息可能会在我们的关联公司之间进行转移。例如，当您在本 APP 预订了旅游套餐，其中涉及我们关联的旅行社提供旅游服务时，您的相关预订信息可能会转移至该旅行社。我们会确保在内部转移过程中对您的个人信息进行妥善保护，且该转移行为符合相关法律法规规定。"),
                  _buildBulletPoint("业务转让中的转移：若发生公司业务合并、分立、出售、资产转让等情况，您的个人信息可能会作为交易的一部分被转移至相关受让方。在转移前，我们会要求受让方遵守与我们同等严格的数据保护标准，并在合理范围内通知您相关转移事宜（若法律法规有要求）。"),
                  
                  _buildSubTitle("（三）公开披露"),
                  _buildBulletPoint("法定情形下的公开披露：在法律、法规要求的情况下，或为了遵守法院的判决、裁定、其他法律程序的规定，或为了响应政府机关、监管机构的要求，我们可能会依法公开披露您的个人信息。例如，在涉及违法犯罪调查、税务审计等情况下，我们可能需要根据执法部门的合法要求提供您的相关信息。"),
                  _buildBulletPoint("经您同意的公开披露：在获得您明确同意的情况下，我们会按照您同意的方式和范围公开披露您的个人信息。例如，您参与我们组织的线上活动并同意将您的获奖信息在活动页面公开展示时，我们会按照约定进行披露。"),
                  
                  _buildSectionTitle("四、信息的存储"),
                  _buildBulletPoint("存储地点：我们会将您的个人信息存储在中国境内。如因业务需要，确需将您的个人信息转移至境外，我们会按照法律法规的规定，事先征得您的明确同意，并采取有效措施保障您的个人信息安全，确保境外接收方具备相应的数据保护能力和水平。"),
                  _buildBulletPoint("存储期限：我们仅在为实现本政策所述目的所必需的期限内保留您的个人信息，法律、法规另有规定的除外。例如，对于订单信息，我们会在订单完成后的一定期限内保存，以便处理售后问题、满足财务审计等需求；对于您的浏览记录、搜索历史等信息，我们会根据业务需求和数据管理策略，在合理期限内进行存储和清理。当您的个人信息超出存储期限后，我们会采取删除、匿名化处理等方式进行妥善处置。"),
                  
                  _buildSectionTitle("五、信息安全与保护"),
                  _buildBulletPoint("安全措施：我们高度重视信息安全，采取了一系列技术和管理措施来保护您的个人信息安全。技术方面，我们采用加密技术对您的敏感信息进行加密存储与传输，如对您的支付信息、身份证件号码等进行加密处理；设置访问控制机制，严格限制对您个人信息的访问权限，确保只有经过授权的人员才能访问。管理方面，我们建立了完善的信息安全管理制度，对员工进行信息安全培训，提高员工的信息安全意识与合规操作水平；定期对信息系统进行安全评估与检测，及时发现并修复安全漏洞。"),
                  _buildBulletPoint("安全事件处置：如不幸发生个人信息安全事件，我们将立即启动应急预案，采取措施尽可能降低事件造成的影响。我们会及时向您告知安全事件的基本情况（如事件发生时间、可能涉及的个人信息类型等）、我们已采取或将要采取的处置措施、您可以采取的防范建议等。若事件涉及您的敏感个人信息，我们会在法律法规规定的时限内以短信、推送通知、站内信等方式通知您。同时，我们会按照相关法律法规的要求，向有关监管部门报告安全事件情况。"),
                  
                  _buildSectionTitle("六、未成年人保护"),
                  _buildBulletPoint("未成年人信息收集：我们非常重视对未成年人个人信息的保护。若您是未成年人，在使用我们的服务前，请您在监护人的陪同下仔细阅读本政策，并在监护人的同意和指导下使用我们的服务、提交个人信息。对于不满十四周岁的儿童，我们仅在监护人明确同意的情况下，收集和使用其必要的个人信息，以提供适合儿童的服务。"),
                  _buildBulletPoint("监护人权利：监护人有权对儿童的个人信息进行管理，如访问、更正、删除儿童的个人信息。若监护人发现我们收集、使用了儿童的个人信息但未经监护人同意，或对我们处理儿童个人信息的行为有任何疑问或意见，可通过本政策提供的联系方式与我们联系，我们将及时处理并反馈。"),
                  
                  _buildSectionTitle("七、用户个人信息管理"),
                  _buildBulletPoint("访问与更正：您有权访问您在我们平台上的个人信息，包括账户信息、订单信息、个人资料等。您可以通过登录本 APP，在相应的账户设置、订单管理等功能模块中查看和修改您的个人信息。若您发现我们收集、存储的您的个人信息存在错误或不完整，您可随时进行更正或补充。"),
                  _buildBulletPoint("删除：在符合法律法规规定及本政策约定的情况下，您有权要求我们删除您的个人信息。例如，当您的账户不再使用且您要求注销账户时，我们会按照规定删除与您账户相关的个人信息；当我们处理您的个人信息的行为违反法律法规或超出了本政策约定的目的与范围时，您也有权要求删除。您可以通过 APP 内的相关功能或联系我们的客服申请删除个人信息。"),
                  _buildBulletPoint("注销账户：您可以随时在 APP 内申请注销您的账户。注销账户后，我们将停止为您提供服务，并按照法律法规规定和本政策约定删除或匿名化处理您的个人信息。但请注意，注销账户是不可逆的操作，注销前请谨慎考虑。注销账户后，您可能无法恢复已注销的账户及相关信息，且可能影响您使用一些依赖该账户的历史服务记录查询等功能。"),
                  _buildBulletPoint("获取个人信息副本：在技术可行的前提下，您有权获取您个人信息的副本。您可以通过联系我们的客服，按照我们指定的流程申请获取您的个人信息副本，我们将在合理期限内为您提供。"),
                  _buildBulletPoint("撤回同意：您有权随时撤回您对我们收集和使用您个人信息的同意。您可以通过修改设备权限设置（如关闭位置权限、相机权限等）、在 APP 内的相关设置中调整隐私选项或联系我们的客服等方式撤回同意。撤回同意后，我们将不再基于您撤回同意的事项继续收集和使用您的个人信息，但不影响此前基于您的同意所进行的信息收集及使用行为的合法性。"),
                  
                  _buildSectionTitle("八、隐私政策的修改"),
                  _buildBulletPoint("政策更新：我们可能会根据法律法规的变化、业务发展需求或其他合理原因对本政策进行修改。政策修改后，我们会在 APP 内显著位置发布更新后的政策内容，并更新版本生效日期。若修改内容涉及对您个人信息的收集、使用、共享等重要方面的变更，我们会以弹窗、推送通知等方式向您提示，确保您及时了解政策变化。"),
                  _buildBulletPoint("继续使用视为同意：若您在本政策更新后继续使用我们的服务，即视为您接受更新后的政策内容。若您不同意更新后的政策，您可选择停止使用我们的服务，并按照本政策规定处理您的个人信息，如申请注销账户等。"),
                  
                  _buildSectionTitle("九、法律"),
                  _buildParagraph("本政策的签订、履行、解释及争议解决均适用 [具体国家/地区] 法律。若您与我们之间因本政策或使用我们的服务发生任何争议，双方应首先友好协商解决；协商不成的，任何一方均有权向有管辖权的人民法院提起诉讼。"),
                  
                  _buildSectionTitle("十、联系我们"),
                  _buildParagraph("如果您对本隐私政策有任何疑问、意见或建议，或者在使用我们的服务过程中对个人信息保护方面有任何问题，您可以通过以下方式联系我们："),
                  _buildBulletPoint("客服电话：[(0571) 8510 9006]"),
                  _buildBulletPoint("电子邮箱：[kai.wang@maya-group.com.cn]"),
                  _buildParagraph("我们将在收到您的反馈后，在合理期限内与您联系并处理您的问题。"),
                  
                  const SizedBox(height: 32),
                  _buildParagraph("[杭州玛亚科技有限公司]"),
                  _buildParagraph("[2024-01-01]"),
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

  Widget _buildVersionDate(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
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
