import 'package:flutter/cupertino.dart';

import 'Common.dart';

class VerticalPageView extends StatefulWidget {
  final IndexedWidgetBuilder builder;
  final BoolCallback onTop;
  final BoolCallback onEnd;
  final OnPageChangeCallback onPageChange;
  final OnPageChangeCallback onTap;
  final int count;
  final int index;
  final bool left;
  final bool right;
  final double hitBox;
  final bool debug;
  final bool refreshState;
  final double range;

  VerticalPageView(
      {Key key,
      @required this.builder,
      @required this.refreshState,
      this.count,
      this.onTop,
      this.onEnd,
      this.index: 1,
      this.left,
      this.right,
      this.onPageChange,
      this.onTap,
      this.hitBox: 100,
      this.debug: false, this.range:500})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _VerticalPageView();
  }
}

class _VerticalPageView extends State<VerticalPageView> {
  ScrollController _controller;
  CustomDelegate _delegate;
  int index = 0;
  double position = 100;
  bool loading=false;

  _VerticalPageView() {
    _controller = new ScrollController(initialScrollOffset: 100);
    _delegate = new CustomDelegate((context, index) {
      return Common.builder(context, index, widget.count, widget.builder,
          widget.left, widget.right,
          dense: true);
    });
    _controller.addListener(() async {
      if (_controller.hasClients) {
        if ((_controller.position.pixels - position).abs() > 500) {
          if (widget.onPageChange != null) {
            widget.onPageChange(_delegate.last);
          }
          setState(() {
            position = _controller.position.pixels;
            index = _delegate.last - 1;
          });
        }
        if (_controller.position.maxScrollExtent >
                500 &&
            _controller.position.pixels >=
                _controller.position.maxScrollExtent &&
            widget.onEnd != null &&
            !widget.refreshState&&!loading) {
          setState(() {
            loading=true;
          });
          bool flag = await widget.onEnd();
          if(flag){
            await Future.delayed(Duration(seconds: 1));
            if(mounted){
              setState(() {
                loading=false;
              });
            }
          }
        } else if (_controller.position.maxScrollExtent >
            500&&
            _controller.position.pixels <
                _controller.position.minScrollExtent &&
            widget.onTop != null &&
            !widget.refreshState&&!loading) {
          setState(() {
            loading=true;
          });
          bool flag = await widget.onTop();
          if(flag){
            await Future.delayed(Duration(seconds: 1));
            if(mounted){
              setState(() {
                loading=false;
              });
            }
          }
        }
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Stack(
      children: [
        ListView.custom(
          padding: EdgeInsets.zero,
          controller: _controller,
          childrenDelegate: _delegate,
        ),
        Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              child: SizedBox(
                height: widget.hitBox,
                child: widget.debug
                    ? Container(
                        color: Color.fromARGB(70, 0, 0, 0),
                      )
                    : null,
              ),
              onTap: () {
                if (_controller.hasClients) {
                  _controller.animateTo(_controller.position.pixels - widget.range,
                      duration: Duration(milliseconds: 200),
                      curve: Curves.decelerate);
                }
              },
            )),
        Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              child: SizedBox(
                height: widget.hitBox,
                child: widget.debug
                    ? Container(
                        color: Color.fromARGB(70, 0, 0, 0),
                      )
                    : null,
              ),
              onTap: () {
                if (_controller.hasClients) {
                  _controller.animateTo(_controller.position.pixels + widget.range,
                      duration: Duration(milliseconds: 200),
                      curve: Curves.decelerate);
                }
              },
            )),
        Positioned(
          left: 0,
          right: 0,
          bottom: widget.hitBox,
          top: widget.hitBox,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: widget.debug
                ? Container(
                    color: Color.fromARGB(70, 0, 100, 255),
                  )
                : null,
            onTap: () {
              if (widget.onTap != null) {
                widget.onTap(_delegate.last);
              }
            },
          ),
        )
      ],
    );
  }
}

class CustomDelegate extends SliverChildBuilderDelegate {
  int last = 0;
  int first = 0;

  CustomDelegate(builder) : super(builder);

  @override
  double estimateMaxScrollOffset(int firstIndex, int lastIndex,
      double leadingScrollOffset, double trailingScrollOffset) {
    // TODO: implement estimateMaxScrollOffset
    return super.estimateMaxScrollOffset(
        firstIndex, lastIndex, leadingScrollOffset, trailingScrollOffset);
  }

  @override
  void didFinishLayout(int firstIndex, int lastIndex) {
    // TODO: implement didFinishLayout
    if (lastIndex != last) {
      last = lastIndex;
    }
    if (firstIndex != first) {
      first = firstIndex;
    }
    super.didFinishLayout(firstIndex, lastIndex);
  }

  @override
  // TODO: implement addAutomaticKeepAlives
  bool get addAutomaticKeepAlives => true;

  @override
  // TODO: implement addRepaintBoundaries
  bool get addRepaintBoundaries => true;

  @override
  // TODO: implement addSemanticIndexes
  bool get addSemanticIndexes => true;
}