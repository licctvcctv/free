
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/guide_neo/guide_http.dart';
import 'package:freego_flutter/components/guide_neo/guide_map_show.dart';
import 'package:freego_flutter/components/guide_neo/guide_model.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/custom_indicator.dart';
import 'package:freego_flutter/components/view/notify_empty.dart';
import 'package:freego_flutter/components/view/notify_loading.dart';
import 'package:freego_flutter/components/view/search_bar.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';

class GuideHomePage extends StatelessWidget{
  const GuideHomePage({super.key});

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
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: const GuideHomeWidget(),
      ),
    );
  }
  
}

class GuideHomeWidget extends StatefulWidget{
  const GuideHomeWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return GuideHomeState();
  }

}

class GuideHomeState extends State<GuideHomeWidget> with TickerProviderStateMixin{

  List<Guide> guideList = [];

  List<Widget> contents = [];
  List<Widget> topBuffer = [];
  List<Widget> bottomBuffer = [];

  static const int SEARCH_ANIM_MILLI_SECNONDS = 200;
  static const double SEARCH_ICON_SIZE = 36;
  Widget svgSearch = SvgPicture.asset('svg/chat/chat_search.svg');
  Widget svgSearchSubmit = SvgPicture.asset('svg/chat/chat_search_submit.svg');
  String searchKeyword = '';
  bool showSearchNavi = true;
  late AnimationController searchSizeAnim;
  late AnimationController searchOpacityAnim;
  TextEditingController searchTextController = TextEditingController();
  FocusNode searchFocus = FocusNode();
  GlobalKey searchNaviKey = GlobalKey();
  double searchNaviWidth = double.infinity;

  bool inited = false;
  int pageNum = 1;
  static const int pageSize = 10;

  @override
  void initState(){
    super.initState();
    searchSizeAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: SEARCH_ANIM_MILLI_SECNONDS));
    searchSizeAnim.value = 1;
    searchOpacityAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: SEARCH_ANIM_MILLI_SECNONDS), lowerBound: 0.5);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) { 
      RenderBox? box = searchNaviKey.currentContext?.findRenderObject() as RenderBox?;
      if(box != null){
        searchNaviWidth = box.size.width;
        showSearchNavi = false;
        searchSizeAnim.value = 0;
        if(mounted && context.mounted){
          setState(() {
          });
        }
      }
    });

    Future.delayed(Duration.zero, () async{
      await refresh();
      inited = true;
      if(mounted && context.mounted){
        setState(() {
        });
      }
    });
  }

  @override
  void dispose(){
    searchSizeAnim.dispose();
    searchOpacityAnim.dispose();
    searchTextController.dispose();
    searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeUtil.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonHeader(
            center: Text('旅行攻略', style: TextStyle(color: Colors.white, fontSize: 18),),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: showSearchNavi ?
                    AnimatedBuilder(
                      animation: searchSizeAnim, 
                      builder: (context, child) {
                        Widget searchBar = SearchBar(
                          key: searchNaviKey,
                          onSubmit: (val){
                            searchKeyword = val;
                            refresh();
                          },
                          onBlur: (){
                            if(searchTextController.text.trim().isEmpty){
                              searchSizeAnim.reverse().then((value){
                                showSearchNavi = false;
                                if(mounted && context.mounted){
                                  setState(() {
                                  });
                                }
                              });
                            }
                          },
                          focusNode: searchFocus,
                          textController: searchTextController,
                        );
                        double maxWidth = searchSizeAnim.value * searchNaviWidth;
                        double minWidth = SearchBarState.SEARCH_ICON_WIDTH + SearchBarState.SEARCH_BAR_BORDER_RADIUS * 2;
                        if(maxWidth < minWidth){
                          maxWidth = minWidth;
                        }
                        return ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: maxWidth
                          ),
                          child: searchBar
                        );
                      },
                    ) :
                    InkWell(
                      onTap: (){
                        showSearchNavi = true;
                        searchSizeAnim.forward();
                        setState(() {
                        });
                        WidgetsBinding.instance.addPostFrameCallback((timeStamp) { 
                          FocusScope.of(context).requestFocus(searchFocus);
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: SizedBox(
                          width: SEARCH_ICON_SIZE,
                          height: SEARCH_ICON_SIZE,
                          child: svgSearch,
                        ),
                      ),
                    ),
                  )
                ) 
              ],
            ),
          ),
          Expanded(
            child: !inited ?
            const NotifyLoadingWidget() :
            guideList.isEmpty ?
            const NotifyEmptyWidget() :
            AnimatedCustomIndicatorWidget(
              contents: contents,
              topBuffer: topBuffer,
              bottomBuffer: bottomBuffer,
              touchBottom: loadMore,
            ),
          )
        ],
      ),
    );
  }

  List<Widget> getGuideWidgets(List<Guide> guideList){
    List<Widget> widgets = [];
    for(Guide guide in guideList){
      widgets.add(
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width
          ),
          child: GuideShowWidget(
            guide,
            onClick: () async{
              if(guide.id == null){
                ToastUtil.error('数据错误');
                return;
              }
              Guide? result = await GuideHttp().get(id: guide.id!);
              if(result == null){
                ToastUtil.error('目标不存在');
                return;
              }
              if(mounted && context.mounted){
                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                  return GuideMapShowPage(result);
                }));
              }
            },
          ),
        )
      );
    }
    return widgets;
  }

  Future refresh() async{
    List<Guide>? tmpList = await GuideHttp().search(keyword: searchKeyword, pageSize: pageSize);
    if(tmpList != null){
      guideList = tmpList;
      contents = [];
      topBuffer = getGuideWidgets(guideList);
      pageNum = 1;
      if(mounted && context.mounted){
        setState(() {
        });
      }  
    }
  }

  Future loadMore() async{
    List<Guide>? tmpList = await GuideHttp().search(keyword: searchKeyword, pageNum: pageNum + 1, pageSize: pageSize);
    if(tmpList != null){
      if(tmpList.isNotEmpty){
        bottomBuffer = getGuideWidgets(tmpList);
        guideList.addAll(tmpList);
        if(mounted && context.mounted){
          setState(() {
          });
        }
        ++pageNum;
      }
      else{
        ToastUtil.hint('已经没有了呢');
      }
    }
  }
}

class GuideShowWidget extends StatefulWidget{
  final Guide guide;
  final Function()? onClick;
  const GuideShowWidget(this.guide, {this.onClick, super.key});

  @override
  State<StatefulWidget> createState() {
    return GuideShowState();
  }

}

class GuideShowState extends State<GuideShowWidget>{
  @override
  Widget build(BuildContext context) {
    Guide guide = widget.guide;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4
          )
        ]
      ),
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap
        ),
        onPressed: widget.onClick,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                color: Colors.white,
              ),
              clipBehavior: Clip.hardEdge,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: guide.cover == null ?
                Image.asset('assets/guide_default.png') :
                Image.network(getFullUrl(guide.cover!))
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4
                  )
                ]
              ),
              clipBehavior: Clip.hardEdge,
              alignment: Alignment.center,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Text(guide.title ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
            ),
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4
                  )
                ]
              ),
              clipBehavior: Clip.hardEdge,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    alignment: Alignment.centerRight,
                    child: const Text('推荐理由', style: TextStyle(color: ThemeUtil.foregroundColor, fontWeight: FontWeight.bold, fontSize: 16),),
                  ),
                  const SizedBox(width: 16,),
                  Expanded(
                    child: Text(guide.reason ?? '', style: const TextStyle(color: ThemeUtil.foregroundColor),),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

}
