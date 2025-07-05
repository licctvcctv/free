
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/util/local_file_util.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:freego_flutter/util/toast_util.dart';

class FileViewerPage extends StatelessWidget{
  const FileViewerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 10,
        elevation: 0,
        backgroundColor: ThemeUtil.backgroundColor,
        systemOverlayStyle: ThemeUtil.statusBarThemeDark,
      ),
      body: const FileViewerWidget(),
    );
  }

}

class FileViewerWidget extends StatefulWidget{
  const FileViewerWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    return FileViewerState();
  }

}

class FileViewerState extends State<FileViewerWidget>{

  static const double FILE_ICON_SIZE = 40;

  late Directory parent;
  List<FileSystemEntity> childs = [];
  ScrollController scrollController = ScrollController();

  @override
  void initState(){
    super.initState();
    if(Platform.isAndroid){
      try{
        parent = Directory(LocalFileUtil.androidRoot);
        getChilds();
      }
      catch(e){
        ToastUtil.error('打开根目录失败');
        Navigator.of(context).pop();
      }
    }
    else{
      ToastUtil.error('不支持的系统');
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose(){
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        if(parent.path == LocalFileUtil.androidRoot){
          return true;
        }
        backUpper();
        return false;
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonHeader(
            center: Text('选择文件', style: TextStyle(color: Colors.white),),
          ),
          Expanded(
            child: ListView.builder(
              physics: const ClampingScrollPhysics(),
              controller: scrollController,
              padding: EdgeInsets.zero,
              itemCount: childs.length + 1,
              itemBuilder: (context, index){
                if(index == 0){
                  if(parent.path == LocalFileUtil.androidRoot){
                    return const SizedBox();
                  }
                  return TextButton(
                    onPressed: (){
                      backUpper();
                    },
                    child: Row(
                      children: [
                        SizedBox(
                          width: FILE_ICON_SIZE,
                          height: FILE_ICON_SIZE,
                          child: Image.asset('assets/file/folder.png'),
                        ),
                        const SizedBox(width: 10,),
                        const Text('上级目录'),
                      ],
                    )
                  );
                }
                FileSystemEntity child = childs[index - 1];
                String name = LocalFileUtil.getFileName(child.path);
                return TextButton(
                  onPressed: (){
                    if(FileSystemEntity.isDirectorySync(child.path)){
                      enter(child.path);
                    }
                    else{
                      Navigator.of(context).pop(child.path);
                    }
                  }, 
                  child: Row(
                    children: [
                      SizedBox(
                        width: FILE_ICON_SIZE,
                        height: FILE_ICON_SIZE,
                        child: getFileIcon(child.path),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(name),
                      )
                    ]
                  )
                );
              }
            ),
          )
        ],
      ),
    );
  }

  void enter(String path){
    try{
      parent = Directory(path);
      getChilds();
      setState(() {
      });
      scrollController.jumpTo(0);
    }
    catch(e){
      //
    }
  }

  void backUpper(){
    try{
      parent = parent.parent;
      getChilds();
      setState(() {
      });
      scrollController.jumpTo(0);
    }
    catch(e){
      //
    }
  }

  void getChilds(){
    childs = parent.listSync();
    childs = childs.where((element) => !LocalFileUtil.getFileName(element.path).startsWith('.')).toList();
    childs.sort((a, b){
      bool isAdir = FileSystemEntity.isDirectorySync(a.path);
      bool isBdir = FileSystemEntity.isDirectorySync(b.path);
      if(isAdir && isBdir || !isAdir && !isBdir){
        return a.path.compareTo(b.path);
      }
      if(isAdir){
        return -1;
      }
      return 1;
    });
  }

  Widget getFileIcon(String path){
    if(FileSystemEntity.isDirectorySync(path)){
      return Image.asset('assets/file/folder.png');
    }
    return Image.asset('assets/file/file.png');
  }

}
