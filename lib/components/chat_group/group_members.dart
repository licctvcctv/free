
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/chat_group/group_member_list.dart';
import 'package:freego_flutter/components/view/alphabetic_navi.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/local_storage/model/local_group.dart';
import 'package:freego_flutter/local_storage/model/local_group_member.dart';
import 'package:freego_flutter/util/dictionary_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/user_home_director.dart';

class GroupMembersPage extends StatelessWidget{
  final LocalGroup group;
  const GroupMembersPage({required this.group, super.key});

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
      body: GroupMemberWidget(group: group),
    );
  }
  
}

class GroupMemberWidget extends StatefulWidget{
  final LocalGroup group;
  const GroupMemberWidget({required this.group, super.key});

  @override
  State<StatefulWidget> createState() {
    return GroupMemberState();
  }
  
}

class GroupMemberState extends State<GroupMemberWidget> with SingleTickerProviderStateMixin{

  Widget svgSearch = SvgPicture.asset('svg/search.svg', color: ThemeUtil.foregroundColor,);

  late AnimationController _searchAnim;
  TextEditingController keywordController = TextEditingController();
  bool _showSearchBar = false;
  bool _showSearchIcon = true;
  FocusNode keywordFocus = FocusNode();

  GroupMemberSearchController searchController = GroupMemberSearchController();

  @override
  void initState(){
    super.initState();
    _searchAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    keywordFocus.addListener(() {
      if(!keywordFocus.hasFocus){
        if(keywordController.text.trim().isEmpty){
          hideSearchBar();
        }
      }
    });
  }

  @override
  void dispose(){
    searchController.dispose();
    _searchAnim.dispose();
    keywordController.dispose();
    keywordFocus.dispose();
    super.dispose();
  }

  void showSearchBar(){
    _showSearchBar = true;
    _searchAnim.forward().then((value){
      _showSearchIcon = false;
      keywordFocus.requestFocus();
      resetState();
    });
    setState(() {
    });
  }

  void hideSearchBar(){
    _showSearchIcon = true;
    _searchAnim.reverse().then((value){
      _showSearchBar = false;
      resetState();
    });
    setState(() {
    });
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Container(
        color: ThemeUtil.backgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonHeader(
              center: Text(widget.group.getShowName(), style: const TextStyle(color: Colors.white, fontSize: 18),),
            ),
            const SizedBox(height: 10,),
            getSearchWidget(),
            const SizedBox(height: 10,),
            Expanded(
              child: getMemberListWidget(),
            )
          ],
        ),
      ),
    );
  }

  Widget getSearchWidget(){
    const double height = 48;
    double width = MediaQuery.of(context).size.width - 24;
    return Container(
      height: height,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      color: ThemeUtil.backgroundColor,
      child: Stack(
        children: [
          if(_showSearchBar)
          AnimatedBuilder(
            animation: _searchAnim,
            builder:(context, child) {
              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: width * _searchAnim.value
                ),
                child: Wrap(
                  direction: Axis.vertical,
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Opacity(
                      opacity: _searchAnim.value,
                      child: Container(
                        height: height,
                        width: width,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4
                            )
                          ]
                        ),
                        alignment: Alignment.center,
                        child: TextField(
                          controller: keywordController,
                          focusNode: keywordFocus,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.fromLTRB(10, 4, 8, 4),
                            counterText: '',
                            hintText: '搜索用户',
                            hintStyle: TextStyle(color: Colors.grey)
                          ),
                          onChanged: (val){
                            val = val.trim();
                            searchController.search(val);
                          },
                          maxLength: DictionaryUtil.GROUP_NAME_MAX_LENGTH,
                          style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 18),
                        )
                      ),
                    )
                  ],
                ),
              );
            },
          ),
          if(_showSearchIcon)
          InkWell(
            onTap: showSearchBar,
            child: AnimatedBuilder(
              animation: _searchAnim,
              builder:(context, child) {
                return Opacity(
                  opacity: 1 - _searchAnim.value,
                  child: SizedBox(
                    width: height,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: height * 0.8,
                        height: height * 0.8,
                        child: svgSearch,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget getMemberListWidget(){
    return GroupMemberListWrapper(
      group: widget.group,
      onClick: (member){
        int? userId = member.memberId;
        if(userId == null){
          return;
        }
        UserHomeDirector().goUserHome(context: context, userId: userId);
      },
      searchController: searchController,
    );
  }

  void resetState(){
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }
}

class GroupMemberListWrapper extends StatefulWidget{

  final LocalGroup group;
  final bool Function(LocalGroupMemberVo)? isSelected;
  final Function(LocalGroupMemberVo)? onClick;
  final GroupMemberSearchController? searchController;

  const GroupMemberListWrapper({required this.group, this.isSelected, this.onClick, this.searchController, super.key});

  @override
  State<StatefulWidget> createState() {
    return GroupMemberListWrapperState();
  }
  
}

class GroupMemberListWrapperState extends State<GroupMemberListWrapper> with SingleTickerProviderStateMixin, WidgetsBindingObserver{

  late AnimationController _keyboardAnim;

  AlphabeticNaviController naviController = AlphabeticNaviController();
  GroupMemberNaviController groupMemberNaviController = GroupMemberNaviController();

  @override
  void initState(){
    super.initState();
    _keyboardAnim = AnimationController(vsync: this, lowerBound: 0, upperBound: double.infinity);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose(){
    _keyboardAnim.dispose();
    WidgetsBinding.instance.removeObserver(this);
    naviController.dispose();
    groupMemberNaviController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: ThemeUtil.backgroundColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GroupMemberListWidget(
                  group: widget.group,
                  onClick: widget.onClick,
                  naviController: groupMemberNaviController,
                  searchController: widget.searchController,
                ),
              ),
              AnimatedBuilder(
                animation: _keyboardAnim,
                builder:(context, child) {
                  return Container(
                    height: _keyboardAnim.value,
                    color: ThemeUtil.backgroundColor,
                  );
                },
              )
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: AlphabeticNaviWidget(
            controller: naviController,
            onClickNavi: (idx){
              groupMemberNaviController.jumpTo(idx);
            },
          ),
        )
      ],
    );
  }

  @override
  void didChangeMetrics(){
    super.didChangeMetrics();
    double keyboardHeight = EdgeInsets.fromWindowPadding(
      WidgetsBinding.instance.window.viewInsets, 
      WidgetsBinding.instance.window.devicePixelRatio).bottom;
    _keyboardAnim.value = keyboardHeight;
  }
}

extension _LocalGroupExt on LocalGroup{

  String getShowName(){
    if(remark != null && remark!.isNotEmpty){
      return remark!;
    }
    return name ?? '';
  }
}
