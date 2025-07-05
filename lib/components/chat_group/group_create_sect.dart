
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/components/chat_group/api/group_api.dart';
import 'package:freego_flutter/components/friend_neo/friend_list.dart';
import 'package:freego_flutter/components/view/alphabetic_navi.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/local_storage/model/local_friend.dart';
import 'package:freego_flutter/util/dictionary_util.dart';
import 'package:freego_flutter/util/local_user.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';

class GroupCreateSectPage extends StatelessWidget{
  const GroupCreateSectPage({super.key});

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
      body: const GroupCreateSectWidget(),
    );
  }

}

class GroupCreateSectWidget extends StatefulWidget{
  const GroupCreateSectWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return GroupCreateSectState();
  }

}

class GroupCreateSectState extends State<GroupCreateSectWidget> with SingleTickerProviderStateMixin{

  static const int AUTO_NAME_MEMBER_MAX = 5;

  TextEditingController nameController = TextEditingController();
  bool autoName = true;
  List<LocalFriendVo> choosedFriendList = [];

  Widget svgSearch = SvgPicture.asset('svg/search.svg', color: ThemeUtil.foregroundColor,);

  bool createable = false;

  late AnimationController _searchAnim;
  TextEditingController keywordController = TextEditingController();
  bool _showSearchBar = false;
  bool _showSearchIcon = true;
  FocusNode keywordFocus = FocusNode();

  FriendSearchController searchController = FriendSearchController();

  @override
  void dispose(){
    nameController.dispose();
    _searchAnim.dispose();
    keywordController.dispose();
    keywordFocus.dispose();
    searchController.dispose();
    super.dispose();
  }

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

  void makeGroupName(){
    if(!autoName){
      return;
    }
    if(choosedFriendList.isEmpty){
      nameController.text = '';
      return;
    }
    String? localName = LocalUser.getUser()?.name;
    StringBuffer name = StringBuffer();
    int i = 0;
    if(localName != null){
      name.write(localName);
    }
    for(LocalFriendVo friend in choosedFriendList){
      name.write('、');
      name.write(friend.getShowName());
      ++i;
      if(i >= AUTO_NAME_MEMBER_MAX){
        if(choosedFriendList.length > i){
          name.write('等');
        }
        break;
      }
    }
    nameController.text = name.toString();
  }

  void checkCreateble(){
    createable = choosedFriendList.isNotEmpty;
    setState(() {
    });
  }

  Future<int?> submit() async{
    if(!createable){
      return null;
    }
    List<int> friendIds = [];
    for(LocalFriendVo friend in choosedFriendList){
      if(friend.friendId != null){
        friendIds.add(friend.friendId!);
      }
    }
    int? newId = await GroupApi().createSect(
      name: nameController.text.trim(), 
      friendIds: friendIds,
      fail: (response){
        String? message = response.data['message'];
        message ??= '操作失败';
        ToastUtil.error(message);
      },
      success: (response){
        ToastUtil.hint('创建成功');
        Timer.periodic(const Duration(seconds: 3), (timer) { 

          timer.cancel();
        });
      }
    );
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
            const CommonHeader(
              center: Text('创建群聊', style: TextStyle(color: Colors.white, fontSize: 18),),
            ),
            const SizedBox(height: 10,),
            getNameWidget(),
            const SizedBox(height: 10,),
            getSearchWidget(),
            const SizedBox(height: 6,),
            Expanded(
              child: getFriendChooseWidget()
            ),
            getSubmitWidget(),
          ],
        ),
      ),
    );
  }

  void showSearchBar(){
    _showSearchBar = true;
    _searchAnim.forward().then((value){
      keywordFocus.requestFocus();
      _showSearchIcon = false;
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
                            hintText: '搜索群聊',
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

  Widget getSubmitWidget(){
    const double height = 60;
    return Container(
      color: const Color.fromRGBO(208, 208, 208, 1),
      height: height,
      padding: const EdgeInsets.only(right: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: createable ? ThemeUtil.buttonColor : Colors.grey
            ),
            onPressed: submit,
            child: const Text('创建', style: TextStyle(color: Colors.white, fontSize: 18),),
          )
        ],
      ),
    );
  }

  Widget getFriendChooseWidget(){
    return FriendListWrapper(
      isSelected: (friend){
        return choosedFriendList.contains(friend);
      },
      onClick: (friend){
        if(choosedFriendList.contains(friend)){
          choosedFriendList.remove(friend);
        }
        else{
          choosedFriendList.add(friend);
        }
        setState(() {
        });
        makeGroupName();
        checkCreateble();
      },
      searchController: searchController,
    );
  }

  Widget getNameWidget(){
    const double height = 48;
    return Container(
      height: height,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 0),
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
        controller: nameController,
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.fromLTRB(10, 4, 8, 4),
          counterText: '',
          hintText: '群名称',
          hintStyle: TextStyle(color: Colors.grey)
        ),
        onChanged: (val){
          val = val.trim();
          autoName = val.isEmpty;
        },
        maxLength: DictionaryUtil.GROUP_DESCRIPTION_MAX_LENGTH,
        style: const TextStyle(color: ThemeUtil.foregroundColor, fontSize: 18),
      )
    );
  }

  void resetState(){
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }
}

class FriendListWrapper extends StatefulWidget{

  final bool Function(LocalFriendVo)? isSelected;
  final Function(LocalFriendVo)? onClick;
  final FriendSearchController? searchController;

  const FriendListWrapper({this.isSelected, this.onClick, this.searchController, super.key});

  @override
  State<StatefulWidget> createState() {
    return FriendListWrapperState();
  }
  
}

class FriendListWrapperState extends State<FriendListWrapper> with SingleTickerProviderStateMixin, WidgetsBindingObserver{

  late AnimationController _keyboardAnim;

  AlphabeticNaviController naviController = AlphabeticNaviController();
  FriendNaviController friendNaviController = FriendNaviController();

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _keyboardAnim = AnimationController(vsync: this, lowerBound: 0, upperBound: double.infinity);
  }

  @override
  void dispose(){
    WidgetsBinding.instance.removeObserver(this);
    _keyboardAnim.dispose();
    naviController.dispose();
    friendNaviController.dispose();
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
                child: FriendListWidget(
                  isSelected: widget.isSelected,
                  onClick: widget.onClick,
                  naviController: friendNaviController,
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
              friendNaviController.jumpTo(idx);
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
    _keyboardAnim.value = keyboardHeight - 60;
  }
  
}