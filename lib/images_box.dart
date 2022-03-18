import 'package:flutter/material.dart';
import 'image_preview.dart';

/// 九宫格
class ImagesBox extends StatefulWidget {
  ImagesBox(
      {Key? key,
      required this.children,
      this.format4rect = false,
      this.crossAxisSpacing = 2.5,
      this.mainAxisSpacing = 2.5,
      this.padding,
      this.enablePreview = true,
      this.coverBuilder})
      : urls = [],
        fit = null,
        borderRadius = null,
        super(key: key);

  ImagesBox.url(
      {Key? key,
      required this.urls,
      this.fit,
      this.format4rect = false,
      this.borderRadius,
      this.crossAxisSpacing = 2.5,
      this.mainAxisSpacing = 2.5,
      this.padding,
      this.enablePreview = true,
      this.coverBuilder})
      : children = [],
        super(key: key);

  final List<Widget> children;

  final List<String> urls;

  /// 只适用于`ImagesBox.url`初始化方式
  final BoxFit? fit;

  /// 4个的时候矩形排列
  final bool format4rect;

  final BorderRadius? borderRadius;

  final double crossAxisSpacing;

  final double mainAxisSpacing;

  final EdgeInsetsGeometry? padding;

  /// 是否能打开大图浏览
  final bool enablePreview;

  /// 图片浏览界面的覆盖层
  final PreviewCoverBuilder? coverBuilder;

  @override
  State<StatefulWidget> createState() => _ImagesBoxState();
}

class _ImagesBoxState extends State<ImagesBox> {
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _setPreviewState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _heros;
    if (widget.children.isNotEmpty) {
      if (widget.enablePreview) {
        _heros = [];
        for (int i = 0; i < widget.children.length; i++) {
          Widget current = widget.children[i];
          if ((_previewing && _currentPage == i) || !_previewing) {
            String tag = 'ImagesBox_$i';
            current = Hero(tag: tag, child: current);
          }
          current = GestureDetector(
            child: current,
            onTap: () {
              _pushImagePreview(i, context, widget.children);
            },
          );
          current = Offstage(
            offstage: _currentPage == i,
            child: current,
          );
          _heros.add(current);
        }
      } else {
        _heros = widget.children;
      }
    } else if (widget.urls.isNotEmpty) {
      _heros = [];
      List<Widget> images = [];
      for (int i = 0; i < widget.urls.length; i++) {
        String url = widget.urls[i];
        Widget current;
        if (url.startsWith('http://') || url.startsWith('https://')) {
          current = Image.network(
            url,
            fit: widget.fit,
          );
        } else {
          current = Image.asset(
            url,
            fit: widget.fit,
          );
        }
        if (widget.borderRadius != null) {
          current = ClipRRect(
            child: current,
            borderRadius: widget.borderRadius,
          );
        }
        images.add(current);
        if (widget.enablePreview) {
          if ((_previewing && _currentPage == i) || !_previewing) {
            String tag = 'ImagesBox_$i';
            current = Hero(tag: tag, child: current);
          }
          current = GestureDetector(
            child: current,
            onTap: () {
              _pushImagePreview(i, context, images);
            },
          );
          current = Offstage(
            offstage: _currentPage == i,
            child: current,
          );
        }
        _heros.add(current);
      }
    } else {
      _heros = [];
    }
    if (_heros.length == 4 && widget.format4rect) {
      _heros.insert(2, SizedBox());
    }
    return GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        crossAxisCount: 3,
        crossAxisSpacing: widget.crossAxisSpacing,
        mainAxisSpacing: widget.mainAxisSpacing,
        padding: widget.padding,
        childAspectRatio: 1.0,
        children: _heros);
  }

  /// 是否正在预览肿
  bool get _previewing => _currentPage >= 0;

  void _setPreviewState() {
    _currentPage = -1;
  }

  _pushImagePreview(int index, BuildContext context, List<Widget> children) {
    Future ret = Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        barrierDismissible: true,
        pageBuilder: ((context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: ImagePreview(
                children: children,
                initializeIndex: index,
                onPageChange: (page) {
                  _currentPage = page;
                  setState(() {});
                },
                coverBuilder: widget.coverBuilder),
          );
        })));
    ret.then((value) {
      _setPreviewState();
      setState(() {});
    });
  }
}
