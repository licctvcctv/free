import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freego_flutter/util/route_observer.dart';
import 'package:freego_flutter/util/theme_util.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

enum VideoSourceType { remote, local }

class VideoCtrlController extends ChangeNotifier {
  VideoCtrlAction? _action;
  void show() {
    _action = VideoCtrlAction.show;
    notifyListeners();
  }

  void hide() {
    _action = VideoCtrlAction.hide;
    notifyListeners();
  }

  void suddenHide() {
    _action = VideoCtrlAction.suddenHide;
    notifyListeners();
  }

  void reset() {
    _action = null;
  }
}

class VideoPlayController extends ChangeNotifier {
  VideoPlayAction? _action;
  bool? isPlaying;
  bool? isEnded;
  void pause() {
    _action = VideoPlayAction.pause;
    notifyListeners();
  }

  void play() {
    _action = VideoPlayAction.play;
    notifyListeners();
  }

  void stop() {
    _action = VideoPlayAction.stop;
    notifyListeners();
  }
}

enum VideoCtrlAction { show, hide, suddenHide }

enum VideoPlayAction { pause, play, stop }

class VideoPlayerPage extends StatelessWidget {
  final String path;
  final VideoSourceType sourceType;
  final VideoCtrlController? ctrlController;
  final VideoPlayController? playController;

  const VideoPlayerPage(this.path,
      {this.sourceType = VideoSourceType.remote,
      this.ctrlController,
      this.playController,
      super.key});

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    final hasDynamicIsland = padding.top > 50;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: ThemeUtil.statusBarThemeLight,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        color: Colors.black,
        child: Stack(
          children: [
            VideoPlayerWidget(
              path,
              sourceType: sourceType,
              ctrlController: ctrlController,
            ),
            if (hasDynamicIsland)
              Positioned(
                top: padding.top - 30, // 调整位置避开灵动岛
                left: 0,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: const BoxDecoration(
                        color: Color.fromRGBO(204, 204, 204, 0.5),
                        borderRadius: BorderRadius.horizontal(
                            right: Radius.circular(20))),
                    alignment: Alignment.centerLeft,
                    child: const Padding(
                      padding: EdgeInsets.only(left: 16),
                      child:
                          Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    ),
                  ),
                ),
              )
            else
              Positioned(
                top: 10,
                left: 0,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: const BoxDecoration(
                        color: Color.fromRGBO(204, 204, 204, 0.5),
                        borderRadius: BorderRadius.horizontal(
                            right: Radius.circular(20))),
                    alignment: Alignment.centerLeft,
                    child: const Padding(
                      padding: EdgeInsets.only(left: 16),
                      child:
                          Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String path;
  final VideoSourceType sourceType;
  final VideoCtrlController? ctrlController;
  final VideoPlayController? playController;
  final Function()? onTap;
  final Function(Duration, Duration?)? onPlay;
  final Function(VideoPlayerController)? onCreated;

  final Widget Function()? playBuilder;
  final Widget Function()? replayBuilder;
  final Widget Function()? bottomBuilder;

  const VideoPlayerWidget(this.path,
      {this.sourceType = VideoSourceType.remote,
      this.ctrlController,
      this.playController,
      this.onTap,
      this.onPlay,
      this.onCreated,
      this.playBuilder,
      this.replayBuilder,
      this.bottomBuilder,
      super.key});

  @override
  State<StatefulWidget> createState() {
    return VideoPlayerState();
  }
}

class VideoPlayerState extends State<VideoPlayerWidget>
    with RouteAware, SingleTickerProviderStateMixin {
  static const double PROGRESS_BAR_HEIGHT = 50;
  static const int ANIM_MILLI_SECONDS = 350;
  static const double LOCAL_ICON_SIZE = 60;

  bool _showControl = false;
  bool _showControlReal = false;
  Duration _position = const Duration(seconds: 0);
  VideoPlayerController? insetPlayerController;
  late AnimationController controlAnimation;

  double screentRatio = 16 / 9;
  Widget svgPlayWidget = SvgPicture.asset(
    'svg/play_arrow.svg',
    color: const Color.fromRGBO(255, 255, 255, 0.7),
  );
  Widget svgReplayWidget = SvgPicture.asset(
    'svg/replay.svg',
    color: const Color.fromRGBO(255, 255, 255, 0.7),
  );

  bool _isPlaying = true;
  bool _isEnded = false;
  bool _isLoading = false;

  double screenRatio = 16 / 9;

  @override
  void didPushNext() {
    insetPlayerController?.pause();
    Wakelock.disable();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    RouteObserverUtil()
        .routeObserver
        .subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    Wakelock.disable();
    insetPlayerController?.removeListener(videoProgressListen);
    insetPlayerController?.dispose();
    RouteObserverUtil().routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.sourceType == VideoSourceType.remote) {
      var uri = Uri.parse(widget.path);
      insetPlayerController ??= VideoPlayerController.networkUrl(uri)
        ..initialize().then((value) {
          resetState();
          insetPlayerController!.addListener(videoProgressListen);
          play();
        });
    } else {
      insetPlayerController ??= VideoPlayerController.file(File(widget.path))
        ..initialize().then((value) {
          resetState();
          insetPlayerController!.addListener(videoProgressListen);
          play();
        });
    }
    controlAnimation = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: ANIM_MILLI_SECONDS));
    VideoCtrlController? ctrlController = widget.ctrlController;
    if (ctrlController != null) {
      ctrlController.addListener(() {
        if (mounted && context.mounted) {
          switch (ctrlController._action) {
            case VideoCtrlAction.show:
              _showControl = true;
              _showControlReal = true;
              controlAnimation.forward().then((value) {
                ctrlController.reset();
              });
              break;
            case VideoCtrlAction.hide:
              _showControl = false;
              controlAnimation.reverse().then((value) {
                _showControlReal = false;
                ctrlController.reset();
              });
              break;
            case VideoCtrlAction.suddenHide:
              _showControl = false;
              _showControlReal = false;
              controlAnimation.reset();
              ctrlController.reset();
              break;
            default:
          }
        }
      });
    }
    VideoPlayController? playController = widget.playController;
    if (playController != null) {
      playController.isEnded = _isEnded;
      playController.isPlaying = _isPlaying;
      playController.addListener(() {
        switch (playController._action) {
          case VideoPlayAction.pause:
            pause();
            break;
          case VideoPlayAction.play:
            play();
            break;
          case VideoPlayAction.stop:
            stop();
            insetPlayerController?.seekTo(Duration.zero);
            break;
          default:
        }
      });
    }
    if (insetPlayerController != null) {
      widget.onCreated?.call(insetPlayerController!);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenRatio = size.width / size.height;
    final videoAspectRatio = insetPlayerController?.value.aspectRatio ?? 1.0;
    final isPortraitVideo = videoAspectRatio <= 0.6; 
    BoxFit chooseFit() {
      if (videoAspectRatio < screenRatio) {
        return BoxFit.fitWidth; 
      } else if (videoAspectRatio > screenRatio) {
        return BoxFit.fitHeight;
      } else {
        return BoxFit.cover;
      }
    }
    return insetPlayerController != null &&
            insetPlayerController!.value.isInitialized
        ? isPortraitVideo
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: GestureDetector(
                            onTap: widget.onTap ?? shiftControl,
                          ),
                        ),
                        GestureDetector(
                          onTap: widget.onTap ?? shiftControl,
                          child: SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: FittedBox(
                              fit: chooseFit(),
                              alignment: Alignment.center,
                              child: SizedBox(
                                width: size.width,
                                height: size.width / videoAspectRatio,
                                child: VideoPlayer(insetPlayerController!),
                              ),
                            ),
                          ),
                        ),
                        if (_isEnded)
                          widget.replayBuilder?.call() ?? const SizedBox(),
                        if (!_isEnded && !_isPlaying && !_isLoading)
                          widget.playBuilder?.call() ??
                              InkWell(
                                onTap: shiftPlay,
                                child: SizedBox(
                                  width: LOCAL_ICON_SIZE * 1.2,
                                  height: LOCAL_ICON_SIZE * 1.2,
                                  child: svgPlayWidget,
                                ),
                              ),
                        if (!_isEnded && _isLoading)
                          const SizedBox(
                            width: LOCAL_ICON_SIZE * 0.8,
                            height: LOCAL_ICON_SIZE * 0.8,
                            child: CircularProgressIndicator(
                                color: Color.fromRGBO(255, 255, 255, 0.7)),
                          )
                      ],
                    ),
                  ),
                  getProgressWidget()
                ],
              )
            : Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: GestureDetector(
                      onTap: widget.onTap ?? shiftControl,
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onTap ?? shiftControl,
                    child: AspectRatio(
                      aspectRatio: videoAspectRatio,
                      child: VideoPlayer(insetPlayerController!),
                    ),
                  ),
                  if (_isEnded)
                    widget.replayBuilder?.call() ?? const SizedBox(),
                  if (!_isEnded && !_isPlaying)
                    widget.playBuilder?.call() ??
                        InkWell(
                          onTap: shiftPlay,
                          child: SizedBox(
                            width: LOCAL_ICON_SIZE,
                            height: LOCAL_ICON_SIZE,
                            child: svgPlayWidget,
                          ),
                        ),
                  if (!_isEnded && _isLoading)
                    const SizedBox(
                      width: LOCAL_ICON_SIZE,
                      height: LOCAL_ICON_SIZE,
                      child: CircularProgressIndicator(
                          color: Color.fromRGBO(255, 255, 255, 0.7)),
                    ),
                  Positioned(
                    bottom: 0,
                    child: getProgressWidget(),
                  ),
                ],
              )
        : getBlankWidget();
  }

  Widget getProgressWidget() {
    Widget inner = Container(
        height: PROGRESS_BAR_HEIGHT,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(color: Colors.grey),
        child: insetPlayerController == null
            ? const SizedBox()
            : Row(
                children: [
                  IconButton(
                      onPressed: shiftPlay,
                      icon: Icon(insetPlayerController!.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow)),
                  Expanded(
                      child: VideoProgressIndicator(
                    insetPlayerController!,
                    allowScrubbing: true,
                    padding: const EdgeInsets.all(8),
                    colors: VideoProgressColors(
                        playedColor: Theme.of(context).primaryColor,
                        bufferedColor: const Color.fromRGBO(255, 255, 255, 0.6),
                        backgroundColor:
                            const Color.fromRGBO(224, 224, 224, 0.6)),
                  )),
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    child: Text(
                      '${durationToTime(_position)}/${durationToTime(insetPlayerController!.value.duration)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ));
    if (widget.bottomBuilder != null) {
      return AnimatedBuilder(
        animation: controlAnimation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Offstage(
                offstage: _showControl,
                child: Opacity(
                  opacity: (1 - controlAnimation.value) * 0.8,
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(maxHeight: PROGRESS_BAR_HEIGHT),
                    child: Wrap(
                      clipBehavior: Clip.hardEdge,
                      children: [widget.bottomBuilder!.call()],
                    ),
                  ),
                ),
              ),
              Offstage(
                offstage: !_showControlReal,
                child: Opacity(
                  opacity: controlAnimation.value * 0.8,
                  child: inner,
                ),
              )
            ],
          );
        },
      );
    }
    return AnimatedBuilder(
      animation: controlAnimation,
      builder: (context, child) {
        return Offstage(
          offstage: !_showControlReal,
          child: Opacity(
            opacity: controlAnimation.value * 0.8,
            child: inner,
          ),
        );
      },
    );
  }

  Widget getBlankWidget() {
    return GestureDetector(
      onTap: widget.onTap ?? shiftControl,
      child: Container(
        color: Colors.black,
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }

  Future play() {
    return insetPlayerController!.play().then((value) {
      widget.playController?.isPlaying = true;
      widget.playController?.isEnded = false;
      _isPlaying = true;
      _isEnded = false;
      Wakelock.enable();
      resetState();
    });
  }

  Future pause() {
    return insetPlayerController!.pause().then((value) {
      widget.playController?.isPlaying = false;
      _isPlaying = false;
      Wakelock.disable();
      resetState();
    });
  }

  Future stop() {
    return pause().then((value) {
      return insetPlayerController!.seekTo(Duration.zero);
    });
  }

  void videoProgressListen() {
    Duration? res = insetPlayerController?.value.position;
    if (res == null) {
      return;
    }
    if (insetPlayerController!.value.duration.compareTo(res) <= 0) {
      pause();
      widget.playController?.isEnded = true;
      _isEnded = true;
    }
    _isLoading = insetPlayerController!.value.isBuffering;
    _position = res;
    setState(() {});
    widget.onPlay?.call(res, insetPlayerController?.value.duration);
  }

  void showControl() {
    _showControl = true;
    _showControlReal = true;
    controlAnimation.forward();
    setState(() {});
  }

  void hideControl() {
    _showControl = false;
    controlAnimation.reverse().then((value) {
      _showControlReal = false;
      resetState();
    });
    setState(() {});
  }

  void shiftControl() {
    if (!_showControl) {
      showControl();
    } else {
      hideControl();
    }
  }

  void shiftPlay() async {
    if (_isPlaying) {
      pause();
    } else {
      play();
    }
  }

  String durationToTime(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;
    int seconds = duration.inSeconds % 60;
    String str = '';
    if (hours > 0) {
      str += '$hours';
      str += ':';
    }
    if (minutes < 10) {
      str += '0$minutes';
    } else {
      str += '$minutes';
    }
    str += ':';
    if (seconds < 10) {
      str += '0$seconds';
    } else {
      str += '$seconds';
    }
    return str;
  }

  void resetState() {
    if (mounted && context.mounted) {
      setState(() {});
    }
  }
}
