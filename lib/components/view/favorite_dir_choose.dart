
import 'package:flutter/material.dart';
import 'package:freego_flutter/components/view/notify_empty.dart';
import 'package:freego_flutter/model/favorite.dart';
import 'package:freego_flutter/util/favorite_util.dart';
import 'package:freego_flutter/util/toast_util.dart';

class FavoriteDirChooseWidget extends StatefulWidget{
  final List<Favorite> favorites;
  final Function(List<Favorite>) onSubmit;
  final Future<bool> Function(Favorite)? onRemove;
  final Favorite? current;
  const FavoriteDirChooseWidget(this.favorites, {required this.onSubmit, this.current, this.onRemove, super.key});

  @override
  State<StatefulWidget> createState() {
    return FavoriteDirChooseState();
  }

}

class FavoriteDirChooseState extends State<FavoriteDirChooseWidget> with WidgetsBindingObserver{

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<Favorite> _stack = [];
  late List<Favorite> _showList;
  bool _onCreate = false;
  Favorite? _current;
  double _bottom = 0.0;

  @override
  void didChangeMetrics(){
    super.didChangeMetrics();
    double keyboardHeight = EdgeInsets.fromWindowPadding(
      WidgetsBinding.instance.window.viewInsets, 
      WidgetsBinding.instance.window.devicePixelRatio).bottom;
    _bottom = keyboardHeight;
  }

  @override
  void initState() {
    super.initState();
    _showList = widget.favorites;

    if(widget.current != null){
      for(Favorite item in widget.favorites){
        if(getStack(item)){
          break;
        }
      }
      if(_stack.isNotEmpty){
        _current = _stack.last;
        _showList = _current!.children ?? [];
      }
    }

    WidgetsBinding.instance.addObserver(this);
    _focusNode.addListener(() {
      if(!_focusNode.hasFocus){
        setState(() {
          _onCreate = false;
        });
      }
    });
  }

  bool getStack(Favorite item){
    _stack.add(item);
    if(item == widget.current){
      return true;
    }
    if(item.children != null){
      for(Favorite child in item.children!){
        bool tmp = getStack(child);
        return tmp;
      }
    }
    _stack.removeLast();
    return false;
  }

  @override
  void dispose(){
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Align(
              child: Text('请选择目录'),
            ),
            const SizedBox(height: 6,),
            Row(
              children: [
                const Icon(Icons.arrow_forward_ios_rounded, color: Color.fromRGBO(107, 120, 255, 1), size: 32,),
                Expanded(
                  child: SizedBox(
                    height: 32,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: getNavs(),
                    ),
                  ) 
                )  
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: getItems(),
              )
            ),
            const Divider(),
            _onCreate ?
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 36,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color:Color.fromRGBO(243, 243, 243, 1),
                      borderRadius: BorderRadius.all(Radius.circular(8))
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      decoration: const InputDecoration(
                        hintText: '请输入目录名',
                        isDense: true,
                        contentPadding: EdgeInsets.fromLTRB(18, 0, 8, 0),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10,),
                ElevatedButton(
                  onPressed: () async{
                    String name = _controller.text;
                    if(name.trim().isEmpty){
                      ToastUtil.hint('请输入文件夹名称');
                      return;
                    }
                    int pid = _current == null ? 0 : _current!.id;
                    Favorite? favorite = await FavoriteUtil.createDir(pid, name);
                    if(favorite == null){
                      return;
                    }
                    ToastUtil.hint('创建成功');
                    _onCreate = false;
                    _controller.text = '';
                    setState(() {
                    });
                  },
                  child: const Text('提交'),
                )
              ],
            ) :
            Row(
              children: [
                ElevatedButton(
                  onPressed: (){
                    setState(() {
                      _onCreate = true;
                    });
                    _controller.text = '';
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                      FocusScope.of(context).requestFocus(_focusNode);
                    });
                  },
                  child: const Text('新建'),
                ),
                const Expanded(child: SizedBox()),
                ElevatedButton(
                  onPressed: () async{
                    widget.onSubmit(_stack);
                  },
                  child: const Text('确认'),
                )
              ],
            ),
            SizedBox(
              height: _bottom,
            )
          ],
        ),
      ),
    );
  }

  List<Widget> getNavs(){
    List<Widget> widgets = [];
    for(int i = 0; i < _stack.length; ++i){
      Favorite favorite = _stack[i];
      widgets.add(
        TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero
          ),
          onPressed: (){
            while(_current != favorite){
              _stack.removeLast();
              _current = _stack.last;
              _showList = _current!.children ?? [];
            }
            setState(() {
            });
          },
          child: Text(favorite.name!),
        )
      );
      if(i < _stack.length - 1){
        widgets.add(const Icon(Icons.arrow_forward_ios_rounded, size: 12,),);
      }
    }
    return widgets;
  }

  List<Widget> getItems(){
    List<Widget> widgets = [];
    if(_current != null){
      widgets.add(
        DirItemWidget('（上一级）', 
        onClick: (){
          _stack.removeLast();
          if(_stack.isNotEmpty){
            _current = _stack.last;
            _showList = _current!.children ?? [];
          }
          else{
            _current = null;
            _showList = widget.favorites;
          }
          setState(() {
            _current = _current;
          });
        })
      );
    }
    bool empty = true;
    for(int i = 0; i < _showList.length; ++i){
      Favorite favorite = _showList[i];
      FavoriteType? type = FavoriteTypeExt.getType(favorite.productType!);
      if(type == FavoriteType.dir){
        empty = false;
        widgets.add(
          DirItemWidget(favorite.name!, 
            onClick: (){
              _stack.add(favorite);
              _current = favorite;
              _showList = favorite.children ?? [];
              setState(() {
                _current = _current;
              });
            },
            onRemove: () async{
              if(widget.onRemove == null){
                return;
              }
              bool result = await widget.onRemove!(favorite);
              if(result){
                _showList.remove(favorite);
              }
              setState(() {
              });
            },
          )
        );
      }
    }
    if(empty){
      widgets.add(const NotifyEmptyWidget(info: '当前目录下没有子目录'));
    }
    return widgets;
  }
}

class DirItemWidget extends StatelessWidget{
  final String name;
  final Function() onClick;
  final Function()? onRemove;
  const DirItemWidget(this.name, {required this.onClick, this.onRemove, super.key});
  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
      ),
      onPressed: onClick,
      child: Row(
        children: [
          const SizedBox(width: 6,),
          SizedBox(
            width: 32,
            height: 32,
            child: Image.asset('images/folder.png', fit: BoxFit.cover),
          ),
          const SizedBox(width: 6,),
          Expanded(
            child: Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black), overflow: TextOverflow.ellipsis,),
          ),
          onRemove == null ?
          const SizedBox() :
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_rounded, color: Colors.grey,),
          )
        ],
      ),
    );
  }

}
