
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freego_flutter/components/video/video_api.dart';
import 'package:freego_flutter/components/video/video_home.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/custom_indicator.dart';
import 'package:freego_flutter/components/view/notify_empty.dart';
import 'package:freego_flutter/components/view/notify_loading.dart';
import 'package:freego_flutter/components/view/search_bar.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/http/http_keyword.dart';
import 'package:freego_flutter/components/video/video_model.dart';
import 'package:freego_flutter/util/storage.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';

class VideoSearchPage extends StatelessWidget{
  const VideoSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 10,
        backgroundColor: ThemeUtil.backgroundColor,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      body: const VideoSearchWidget(),
    );
  }
}

class VideoSearchWidget extends ConsumerStatefulWidget {
  const VideoSearchWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return VideoSearchState();
  }
}

class VideoSearchState extends ConsumerState{

  String searchHint = '';
  TextEditingController textController = TextEditingController();

  List<Map<String,String>> hotList =[];
  List<String> historyList = [];
  
  bool isGettingMore = false;
  bool searchBegin = false;

  List<int>? videoIds;
  List<VideoModel>? videoList;
  int page = 1;

  static const int pageSize = 20;

  List<Widget> topBuffer = [];
  List<Widget> contentWidgets = [];
  List<Widget> bottomBuffer = [];

  @override
  void initState() {
    super.initState();
    getHotSearchWord();
    getHistoryWords();
  }

  @override
  void dispose(){
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Color.fromRGBO(242,245,250,1)
        ),
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.zero,
        child: Stack(
          children: [
            Column(
              children: [
                CommonHeader(
                  center: SimpleSearchBar(
                    controller: textController,
                    hintText: searchHint,
                    onSumbit: (val){
                      esSearch();
                    },
                  ),
                ),
                Expanded(
                  child: AnimatedCustomIndicatorWidget(
                    header: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                      child: Column(
                        children: [
                          SizedBox(
                            width:double.infinity,
                            child: Wrap(
                              direction: Axis.horizontal,
                              children: getHistoryWordViews(),
                            ),
                          ),
                          const SizedBox(height: 10,),
                          const SizedBox(
                            width: double.infinity,
                            child: Text("热门搜索榜"),
                          ),
                          const SizedBox(height: 10,),
                          SizedBox(
                            width: double.infinity,
                            child: Column(
                              children: getHotViews(),
                            ),
                          ),
                          if(videoIds != null && videoIds!.isNotEmpty && (videoList == null || videoList!.isEmpty))
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              SizedBox(height: 10,),
                              NotifyLoadingWidget(),
                            ],
                          )
                        ]
                      )
                    ),
                    topBuffer: topBuffer,
                    contents: contentWidgets,
                    bottomBuffer: bottomBuffer,
                    touchBottom: videoIds != null && videoIds!.isNotEmpty ? getVideos : null,
                  )
                )
              ],
            ),
          ]
        )
      )
    );
  }

  List<Widget> getVideoWidgets(List<VideoModel> videos){
    List<Widget> widgets = [];
    for(int i = 0; i < videos.length / 2; ++i){
      widgets.add(
        const SizedBox(
          height: 10,
        )
      );
      VideoModel video1 = videos[i * 2];
      VideoModel? video2;
      if(i * 2 + 1 < videos.length){
        video2 = videos[i * 2 + 1];
      }
      widgets.add(
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              Flexible(
                flex: 1,
                child: InkWell(
                  onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context){
                      return VideoHomePage(
                        initVideo: video1,
                      );
                    }));
                  },
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      child: Column(
                        children: [
                          Expanded(
                            child: 
                            Container(
                              color: const Color.fromRGBO(0, 0, 0, 0.8),
                              alignment: Alignment.center,
                              child: 
                              video1.pic != null ?
                              Image.network(
                                getFullUrl(video1.pic!)
                              ) :
                              ThemeUtil.defaultCover
                            )
                          ),
                          Container(
                            width: double.infinity,
                            height: 40,
                            padding: const EdgeInsets.only(left: 4, right: 4),
                            decoration: const BoxDecoration(
                              color: Color.fromRGBO(0, 0, 0, 0.3)
                            ),
                            alignment: Alignment.center,
                            child: Text(video1.name ?? '', style: const TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis, maxLines: 2,),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Flexible(
                flex: 1,
                child: InkWell(
                  onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context){
                      return VideoHomePage(
                        initVideo: video2,
                      );
                    }));
                  },
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: video2 == null ?
                    const SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                    ) :
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      child: Column(
                        children: [
                          Expanded(
                            child: 
                            Container(
                              color: const Color.fromRGBO(0, 0, 0, 0.8),
                              alignment: Alignment.center,
                              child: 
                              video2.pic != null ?
                              Image.network(
                                getFullUrl(video2.pic!)
                              ) :
                              ThemeUtil.defaultCover
                            )
                          ),
                          Container(
                            width: double.infinity,
                            height: 40,
                            padding: const EdgeInsets.only(left: 4, right: 4),
                            decoration: const BoxDecoration(
                              color: Color.fromRGBO(0, 0, 0, 0.3)
                            ),
                            alignment: Alignment.center,
                            child: Text(video2.name ?? '', style: const TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis, maxLines: 2,),
                          )
                        ],
                      ),
                    )
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
        )
      );
    }
    return widgets;
  }

  Future esSearch() async{
    if(textController.text.trim().isEmpty){
      textController.text = searchHint;
    }
    topBuffer = [];
    contentWidgets = [];
    bottomBuffer = [];
    videoList = [];
    videoIds = await VideoApi().search(
      text: textController.text, 
      fail: (response){
        ToastUtil.hint('好像出了点小问题');
      },
      success: (response){
        page = 1;
        if(mounted && context.mounted){
          setState(() {
          });
        }
      }
    );
    if(videoIds == null || videoIds!.isEmpty){
      bottomBuffer.add(
        const NotifyEmptyWidget()
      );
    }
    else{
      getVideos();
    }
  }

  Future getVideos() async{
    if(isGettingMore){
      return;
    }
    int start = (page - 1) * pageSize;
    if(videoIds == null || start >= videoIds!.length){
      ToastUtil.hint('已经没有了呢');
      return;
    }
    int end = start + pageSize;
    if(end > videoIds!.length){
      end = videoIds!.length;
    }
    List<int> ids = videoIds!.sublist(start, end);
    if(ids.isEmpty){
      ToastUtil.hint('已经没有了呢');
      return;
    }
    isGettingMore = true;
    List<VideoModel>? list = await VideoApi().listByIds(
      ids: ids,
      fail: (response){
        ToastUtil.hint('好像出了点小问题');
      },
    );
    if(list == null || list.isEmpty){
      ToastUtil.hint('已经没有了呢');
    }
    else{
      List<Widget> widgets = getVideoWidgets(list);
      bottomBuffer = widgets;
      videoList ??= [];
      videoList!.addAll(list);
      ++page;
      searchBegin = true;
      if(mounted && context.mounted){
        setState(() {
        });
      }
    }
    isGettingMore = false;
  }

  List<Widget> getHotViews() {
    var views = <Widget>[];
    for(var i = 0;i < hotList.length; i++) {
      var num = i + 1;
      String searchNum = hotList[i]['num']!;
      var decoration = i < 3 ? 
      BoxDecoration(
        image: DecorationImage(
          image: Image.asset("images/fire_$num.png").image, 
          fit: BoxFit.cover
        ),
      ) : 
      const BoxDecoration();
      views.add(
        GestureDetector(
          onTap: (){
            chooseKeyword(hotList[i]['word']!);
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(0, 6, 0, 6),
            child: Row(
              children: [
                Container(
                  alignment: Alignment.center,
                  width: 20,
                  height: 20,
                  decoration: decoration,
                  child: Text(num.toString()),
                ),
                const SizedBox(width: 10,),
                Text(hotList[i]['word']!),
                Expanded(flex:1, child: Container()),
                Text('$searchNum热度')
              ],
            )
          )
        )
      );
    }
    return views;
  }

  void chooseKeyword(String keyword) {
    textController.text = keyword;
    esSearch();
  }

  List<Widget> getHistoryWordViews() {
    var views = <Widget>[];
    for(var i = 0;i < historyList.length;i++) {
      views.add(
        GestureDetector(
          onTap: (){
            chooseKeyword(historyList[i]);
          },
          child:Container(
            margin: const EdgeInsets.fromLTRB(0, 4, 8, 4),
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
            decoration: const BoxDecoration(
              color: Color.fromRGBO(101,211,235,1),
              borderRadius: BorderRadius.all(Radius.circular(20))
            ),
            child: Text(historyList[i], style: const TextStyle(color: Colors.white),)
          )
        )
      );  // views.add(SizedBox(width: 20,));
    }
    return views;
  }

  void getHistoryWords() async {
    List<String>? tmpList =  await Storage.getSearchHistory();
    if(tmpList != null){
      historyList = tmpList;
      if(textController.text.isEmpty && searchHint.isEmpty){
        if(historyList.isNotEmpty){
          searchHint = historyList.first;
        }
      }
      if(mounted && context.mounted){
        setState(() {
        });
      }
    }
  }

  void getHotSearchWord() {
    HttpKeyword.getHotSearch((isSuccess, data, msg, code) {
      if(isSuccess) {
        var list =  data as List<dynamic>;
        list.forEach((element) {
          hotList.add({'word':element['word'],'num':element['num'].toString()});
          if(textController.text.isEmpty && searchHint.isEmpty){
            String word = element['word'];
            if(word.isNotEmpty){
              searchHint = word;
            }
          }
        });
        resetState();
      }
    });
  }

  void resetState(){
    if(mounted && context.mounted){
      setState(() {
      });
    }
  }
}
