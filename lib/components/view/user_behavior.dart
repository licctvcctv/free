
import 'package:flutter/material.dart';

const Color COLOR_ACTIVE = Color.fromRGBO(0xd8, 0x1e, 0x06, 1);
const Color COLOR_INACTIVE = Colors.grey;

class UserBehaviorBench extends StatefulWidget{
  final bool isLiked;
  final bool isFavorited;
  final int commentNum;
  final int likeNum;
  final int favoriteNum;
  final Function()? onComment;
  final Function()? onLike;
  final Function()? onFavorite;
  const UserBehaviorBench({
    this.isLiked = false, this.isFavorited = false,
    this.commentNum = 0, this.likeNum = 0, this.favoriteNum = 0,
    this.onComment, this.onLike, this.onFavorite, super.key});

  @override
  State<StatefulWidget> createState() {
    return UserBehaviorBenchState();
  }

}

class UserBehaviorBenchState extends State<UserBehaviorBench>{

  static const double FOOTER_HEIGHT = 60;
  
  @override
  Widget build(BuildContext context) {
    double width = (MediaQuery.of(context).size.width - 24) / 3;
    return Container(
      height: FOOTER_HEIGHT,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: widget.onComment,
                  icon: const Icon(Icons.comment, size: 28, color: COLOR_INACTIVE,),
                ),
                widget.commentNum > 0 ?
                Text('${widget.commentNum}') :
                const SizedBox(),
              ],
            ) 
          ),
          SizedBox(
            width: width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: widget.onFavorite,
                  icon: widget.isFavorited ?
                  const Icon(Icons.favorite_rounded, size: 28, color: COLOR_ACTIVE,):
                  const Icon(Icons.favorite_rounded, size: 28, color: COLOR_INACTIVE,)
                ),
                widget.favoriteNum > 0 ?
                Text('${widget.favoriteNum}') :
                const SizedBox()
              ],
            )
          ),
          SizedBox(
            width: width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: widget.onLike,
                  icon: widget.isLiked ?
                  const Icon(Icons.thumb_up_rounded, size: 28, color: COLOR_ACTIVE,):
                  const Icon(Icons.thumb_up_rounded, size: 28, color: COLOR_INACTIVE,)
                ),
                widget.likeNum > 0 ?
                Text('${widget.likeNum}') :
                const SizedBox()
              ],
              )
          ),
        ],
      ),
    );
  }

}

class UserBehaviorFloat extends StatefulWidget{
  final bool isLiked;
  final bool isFavorited;
  final int commentNum;
  final int likeNum;
  final int favoriteNum;
  final Function()? onComment;
  final Function()? onLike;
  final Function()? onFavorite;
  const UserBehaviorFloat({
    this.isLiked = false, this.isFavorited = false,
    this.commentNum = 0, this.likeNum = 0, this.favoriteNum = 0,
    this.onComment, this.onLike, this.onFavorite, super.key});
    
  @override
  State<StatefulWidget> createState() {
    return UserBehaviorFloatState();
  }
}

class UserBehaviorFloatState extends State<UserBehaviorFloat>{
  static const Color COLOR_ACTIVE = Color.fromRGBO(0xd8, 0x1e, 0x06, 1);
  static const Color COLOR_INACTIVE = Colors.grey;
  static const double FLOATING_WIDTH = 50;

  @override
  Widget build(BuildContext context) {
    double width = FLOATING_WIDTH;
    double height = MediaQuery.of(context).size.height / 3;
    return Container(
      height: height,
      width: width,
      decoration: const BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.4),
        borderRadius: BorderRadius.all(Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0xee, 0xee, 0xee, 0.4),
            offset: Offset(-2, 0),
            blurRadius: 2
          )
        ]
      ),
      child: Column(
        children: [
          SizedBox(
            height: height / 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(0),
                    minimumSize: Size.zero
                  ),
                  onPressed: widget.onComment,
                  icon: const Icon(Icons.comment, size: 28, color: COLOR_INACTIVE,),
                ),
                widget.commentNum <= 0 ?
                const SizedBox() :
                Text('${widget.commentNum}', style: const TextStyle(color: Colors.grey),)
              ],
            )
          ),
          SizedBox(
            height: height / 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(0),
                    minimumSize: Size.zero
                  ),
                  alignment: Alignment.center,
                  onPressed: widget.onFavorite,
                  icon: widget.isFavorited ?
                  const Icon(Icons.favorite_rounded, size: 28, color: COLOR_ACTIVE,):
                  const Icon(Icons.favorite_rounded, size: 28, color: COLOR_INACTIVE,)
                ),
                widget.favoriteNum <= 0 ?
                const SizedBox() :
                Text('${widget.favoriteNum}', style: const TextStyle(color: Colors.grey),)
              ],
            ),
          ),
          SizedBox(
            height: height / 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(0),
                    minimumSize: Size.zero
                  ),
                  onPressed: widget.onLike,
                  icon: widget.isLiked ?
                  const Icon(Icons.thumb_up_rounded, size: 28, color: COLOR_ACTIVE,):
                  const Icon(Icons.thumb_up_rounded, size: 28, color: COLOR_INACTIVE,)
                ),
                widget.likeNum <= 0 ?
                const SizedBox() :
                Text('${widget.likeNum}', style: const TextStyle(color: Colors.grey),)
              ],
            ),
          )
        ],
      ),
    );
  }

}
