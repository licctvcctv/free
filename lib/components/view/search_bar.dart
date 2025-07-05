
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/util/theme_util.dart';

class SearchBar extends StatefulWidget{

  final Function(String) onSubmit;
  final Function(String)? onChange;
  final Function()? onFocus;
  final Function()? onBlur;
  final TextEditingController? textController;
  final FocusNode? focusNode;
  const SearchBar({required this.onSubmit, this.onChange, this.onFocus, this.onBlur, this.textController, this.focusNode, super.key});
  
  @override
  State<StatefulWidget> createState() {
    return SearchBarState();
  }

}

class SearchBarState extends State<SearchBar>{

  static const double SEARCH_BAR_HEIGHT = 36;
  static const double SEARCH_BAR_BORDER_RADIUS = 18;
  static const double SEARCH_ICON_WIDTH = 50;

  late final TextEditingController _textController;
  late final FocusNode _focusNode;

  bool isHintShow = true;

  @override
  void initState(){
    super.initState();

    _textController = widget.textController ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();

    if(widget.onFocus != null || widget.onBlur != null){
      _focusNode.addListener(() {
        if(_focusNode.hasFocus){
          widget.onFocus?.call();
        }
        else{
          widget.onBlur?.call();
        }
      });
    }
  }

  @override
  void dispose(){
    if(widget.textController == null){
      _textController.dispose();
    }
    if(widget.focusNode == null){
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SEARCH_BAR_HEIGHT,
      width: double.infinity,
      alignment: Alignment.center,
      constraints: const BoxConstraints(
        minWidth: SEARCH_ICON_WIDTH
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(SEARCH_BAR_BORDER_RADIUS)),
        boxShadow: [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 4
          )
        ]
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(SEARCH_BAR_BORDER_RADIUS, 0, SEARCH_BAR_BORDER_RADIUS, 0),
        child: GestureDetector(
          onTap: (){},
          child: Listener(
            onPointerDown: (evt){
              FocusScope.of(context).requestFocus(_focusNode);
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: SEARCH_ICON_WIDTH,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: SEARCH_BAR_HEIGHT * 0.8,
                          height: SEARCH_BAR_HEIGHT * 0.8,
                          child: Image.asset('assets/icon_search.png'),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        onChanged: (val){
                          isHintShow = val == '';
                          setState(() {
                          });
                          if(widget.onChange != null){
                            widget.onChange!(val);
                          }
                        },
                        onSubmitted: widget.onSubmit,
                        textInputAction: TextInputAction.search,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '',
                          isDense: true,
                          contentPadding: EdgeInsets.zero
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ],
                ),
                isHintShow ?
                Wrap(
                  direction: Axis.vertical,
                  children: const [
                    Text('搜索', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),)
                  ],
                ):
                const SizedBox()
              ],
            ),
          ),
        ),
      ),
    );
  }

}

class SimpleSearchBar extends StatefulWidget{
  final Function(String)? onChange;
  final Function(String)? onSumbit;
  final Function(String)? onFocus;
  final Function(String)? onBlur;
  final bool hasButton;
  final Color? backgroundColor;
  final String hintText;
  final TextEditingController? controller;
  const SimpleSearchBar({this.onSumbit, this.onFocus, this.onBlur, this.onChange, this.hasButton = true, this.hintText = '搜索', this.backgroundColor, this.controller, super.key});

  @override
  State<StatefulWidget> createState() {
    return SimpleSearchBarState();
  }

}

class SimpleSearchBarState extends State<SimpleSearchBar> {
  // ========== 原样式参数 ==========
  static const double _height = 30;         // 原 SEARCH_BAR_HEIGHT
  static const double _radius = 12;         // 原 SEARCH_BAR_BORDER_RADIUS
  static const double _submitWidth = 64;    // 原 SEARCH_SUBMIT_ICON_WIDTH
  static const TextStyle _hintStyle = TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.grey,
  );
  static const TextStyle _inputStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 15,
  );

  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isHintVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_updateHintVisibility);
    _focusNode.addListener(_handleFocusChange);
  }

  void _updateHintVisibility() {
    setState(() => _isHintVisible = _controller.text.isEmpty);
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      widget.onFocus?.call(_controller.text);
    } else {
      widget.onBlur?.call(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      child: ClipRRect(
        // ========== 原圆角阴影样式 ==========
        borderRadius: BorderRadius.circular(_radius),
        child: Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? Colors.grey[200],
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
              ),
            ],
          ),
          child: Row(
            children: [
              // ========== 输入框区域（保留原背景色和布局） ==========
              Expanded(
                child: Container(
                  color: widget.backgroundColor ?? Colors.grey[200],
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // ========== 核心输入框（保留原样式） ==========
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: _radius),
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          enableInteractiveSelection: true, // 启用长按
                          onChanged: (text) {
                            widget.onChange?.call(text);
                            _updateHintVisibility();
                          },
                          onSubmitted: widget.onSumbit,
                          textInputAction: TextInputAction.search,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: _inputStyle, // 原输入文字样式
                        ),
                      ),

                      // ========== 提示文字（视觉完全还原） ==========
                      if (_isHintVisible)
                        IgnorePointer(
                          child: Padding(
                            padding: const EdgeInsets.only(left: _radius),
                            child: Text(
                              widget.hintText,
                              style: _hintStyle, // 原提示文字样式
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ========== 提交按钮（保留原SVG和布局） ==========
              if (widget.hasButton)
                Container(
                  width: _submitWidth,
                  height: _height,
                  color: Colors.white,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: SvgPicture.asset(
                      'assets/search_submit.svg',
                      width: _submitWidth * 0.6,
                      height: _height * 0.6,
                    ),
                    onPressed: () => widget.onSumbit?.call(_controller.text),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}