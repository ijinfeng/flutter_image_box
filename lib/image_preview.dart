import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

typedef PreviewCoverBuilder = Widget Function(
    BuildContext context, int page, int total);

class ImagePreview extends StatefulWidget {
  ImagePreview(
      {Key? key,
      required this.children,
      this.initializeIndex = 0,
      this.viewportFraction = 1.0,
      this.onPageChange,
      this.coverBuilder})
      : _controller = PageController(
            initialPage: initializeIndex, viewportFraction: viewportFraction),
        super(key: key);

  final List<Widget> children;

  final int initializeIndex;

  final double viewportFraction;

  final PageController _controller;

  final ValueChanged<int>? onPageChange;

  final PreviewCoverBuilder? coverBuilder;

  @override
  State<StatefulWidget> createState() {
    return ImagePreviewState();
  }
}

class ImagePreviewState extends State<ImagePreview>
    with TickerProviderStateMixin {
  late int _currentPage;
  Offset _offset = Offset.zero;
  double _scale = 1.0;
  double _opacity = 1.0;
  bool _resetInAnimation = false;
  late AnimationController _controller;
  late CurvedAnimation _curve;
  Animation<Offset>? _offsetAn;
  Animation<double>? _scaleAn;
  Animation<Color?>? _colorAn;

  /// 交互中，如用户正在拖拽，正在缩放
  bool _inInteraction = false;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initializeIndex;
    _controller =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    _curve = CurvedAnimation(parent: _controller, curve: Curves.ease);
    _controller.addStatusListener((status) {
      // 动画结束，回复原状
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _resetInAnimation = false;
        // 这句很关键，否则第二次动画将不执行
        _controller.reset();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void onPageChange(int index) {
      _currentPage = index;
      if (widget.onPageChange != null) {
        widget.onPageChange!(index);
        if (widget.coverBuilder != null) {
          setState(() {});
        }
      }
    }

    List<Widget> heros = [];
    for (int i = 0; i < widget.children.length; i++) {
      Widget current = widget.children[i];
      String tag = 'ImagesBox_$i';
      current = Hero(
        tag: tag,
        child: current,
      );
      current = GestureDetector(
        child: current,
        onTap: () {
          _changeCoverStateIfNeeded(true);
          _dismiss(context);
        },
        onPanCancel: () {
          _dragEnd(context);
        },
        onPanStart: (DragStartDetails details) {
          _changeCoverStateIfNeeded(true);
        },
        onPanUpdate: (DragUpdateDetails details) {
          _changeCoverStateIfNeeded(true);
          Offset preparOffset = _offset + details.delta;
          if (preparOffset.dy <= 0) return;
          setState(() {
            _offset += details.delta;
            double scaleHeight = MediaQuery.of(context).size.height * 2;
            double scale = (scaleHeight - _offset.dy) / scaleHeight;
            _scale = scale < 0 ? 0 : scale;
            _opacity = (scaleHeight - _offset.dy) / scaleHeight;
          });
        },
        onPanEnd: (DragEndDetails details) {
          _dragEnd(context);
        },
      );

      current = GestureDetector(
        child: current,
        onScaleStart: (ScaleStartDetails details) {
          print('缩放开始');
        },
        onScaleUpdate: (ScaleUpdateDetails details) {
          print(details.scale.clamp(0.5, 3.0));
        },
        onScaleEnd: (ScaleEndDetails details) {
          print('缩放结束');
        },
      );

      heros.add(AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            if (_isTarget(i)) {
              return FittedBox(
                fit: BoxFit.fitWidth,
                child: Transform.scale(
                  scale: _resetInAnimation ? _scaleAn?.value : _scale,
                  child: Transform.translate(
                    offset: _resetInAnimation
                        ? _offsetAn!.value
                        : (_offset / _scale),
                    child: current,
                  ),
                ),
              );
            } else {
              return FittedBox(
                child: Transform.translate(
                  offset: Offset.zero,
                  child: Transform.scale(
                    scale: 1.0,
                    child: current,
                  ),
                ),
                fit: BoxFit.fitWidth,
              );
            }
          }));
    }

    Widget current = AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            color: _resetInAnimation
                ? (_colorAn?.value ?? Colors.black)
                : Colors.black.withOpacity(_opacity),
            child: PageView(
              controller: widget._controller,
              onPageChanged: onPageChange,
              children: heros,
            ),
          );
        });

    if (widget.coverBuilder != null) {
      current = Stack(
        children: [
          current,
          Offstage(
            offstage: _inInteraction,
            child: widget.coverBuilder!(context, _currentPage, heros.length),
          )
        ],
      );
    }
    return Material(color: Colors.transparent, child: Center(child: current));
  }

  void _changeCoverStateIfNeeded(bool userInteraction) {
    if (_inInteraction == userInteraction) return;
    _inInteraction = userInteraction;
    if (widget.coverBuilder == null) return;
    setState(() {});
  }

  bool _isTarget(int index) {
    return _currentPage == index;
  }

  _dismiss(BuildContext context) {
    Navigator.of(context).pop(widget._controller.page);
  }

  _dragEnd(BuildContext context) {
    double scaleHeight = MediaQuery.of(context).size.height / 2;
    if (_offset.dy >= scaleHeight) {
      // 拖拽超过屏幕1/4位置
      _changeCoverStateIfNeeded(true);
      _dismiss(context);
    } else {
      _changeCoverStateIfNeeded(false);
      // 回到原位
      _resetInAnimation = true;
      _initializeRecoverAnimation();
      _scale = 1.0;
      _offset = Offset.zero;
      _opacity = 1.0;
      _controller.forward();
    }
  }

  /// 初始化动画对象
  _initializeRecoverAnimation() {
    _offsetAn = Tween<Offset>(begin: _offset / _scale, end: Offset.zero)
        .animate(_curve);
    _colorAn =
        ColorTween(begin: Colors.black.withOpacity(_opacity), end: Colors.black)
            .animate(_curve);
    _scaleAn = Tween<double>(begin: _scale, end: 1.0).animate(_curve);
  }
}
