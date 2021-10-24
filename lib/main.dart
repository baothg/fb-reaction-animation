import 'package:flutter/material.dart';

import 'reaction.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Facebook Reaction Animation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Facebook Reaction Animation'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final double _reactSize = 32;
  final double _reactMargin = 2;
  final double _reactBarBotMargin = 44;
  final double _reactBarPadding = 4;

  //resouce
  List<Map> _news = [];
  List<Reaction> _reactions = [];
  final Map<String, Color> _reactColors = {
    "like": Colors.blueAccent,
    "love": Colors.red,
    "haha": Colors.yellow,
    "wow": Colors.amber,
    "sad": Colors.amberAccent,
    "angry": Colors.deepOrange
  };

  //news selected
  int _newsSelected = -1;
  LongPressStartDetails _newsPosition = const LongPressStartDetails();
  late AnimationController _newsCtr;
  late Animation<double> _newsAni;

  //react selected
  int _reactSelected = -1;
  Path _reactPath = Path();
  Rect _reactRect = Rect.zero;
  late AnimationController _reactCtr;
  late Animation<double> _reactAni;

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  double get reactSize => _reactSize + _reactMargin * 2;

  double get reactScale => 1.5;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initReactions();
    _initNews();
    var _itemDuration = const Duration(milliseconds: 300);
    _newsCtr = AnimationController(vsync: this, duration: _itemDuration);
    _newsAni = CurvedAnimation(parent: _newsCtr, curve: Curves.fastOutSlowIn);
    var _reactDuration = const Duration(milliseconds: 1000);
    _reactCtr = AnimationController(vsync: this, duration: _reactDuration);
    _reactAni = CurvedAnimation(parent: _reactCtr, curve: Curves.fastOutSlowIn);
  }

  _initReactions() {
    _reactions = List.generate(_reactColors.length, (index) {
      var duration = const Duration(milliseconds: 300);
      var ctrl = AnimationController(vsync: this, duration: duration);
      var ani = CurvedAnimation(parent: ctrl, curve: Curves.fastOutSlowIn);
      return Reaction(_reactColors.keys.toList()[index],
          color: _reactColors.values.toList()[index],
          controller: ctrl,
          animation: ani);
    });
  }

  _initNews() {
    _news = List.generate(50, (index) {
      return {
        "avatar": "${index + 1}",
        "title": "Title ${index + 1}",
        "content":
            "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. ",
        "reaction": null,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Stack(
          children: [
            ListView.builder(
              itemCount: _news.length,
              itemBuilder: _buildItem,
            ),
            _buildReactAnimation(),
            // if (_reactPath.computeMetrics().isNotEmpty)
            //   ...List.generate(40, (index) {
            //     var length = _reactPath.computeMetrics().first.length;
            //     var unit = length * index / 40;
            //     var f = _reactPath.computeMetrics().first;
            //     var p = f.extractPath(unit, unit);
            //     return Positioned(
            //         top: p.getBounds().center.dy,
            //         left: p.getBounds().center.dx,
            //         child: Container(height: 2, width: 2, color: Colors.black));
            //   })
          ],
        ));
  }

  Widget _buildReactAnimation() {
    return AnimatedBuilder(
        animation: _reactAni,
        builder: (context, _) {
          if (_reactPath.computeMetrics().isEmpty) {
            return const SizedBox();
          }
          var length = _reactPath.computeMetrics().first.length;
          var unit = length * _reactAni.value * 0.6;
          double opacity = _reactAni.value > 0.8 ? 0 : 1;
          double bigSize = _reactSize + _reactSize * reactScale;
          double size = bigSize - bigSize * 0.8 * _reactAni.value;
          var f = _reactPath.computeMetrics().first;
          var p = f.extractPath(unit, unit);
          return Positioned(
              top: p.getBounds().center.dy - size / 2,
              left: p.getBounds().center.dx - size / 2,
              child: AnimatedOpacity(
                opacity: opacity,
                duration: const Duration(milliseconds: 200),
                child: _reactSelected == -1
                    ? const SizedBox()
                    : Image.asset(_reactions[_reactSelected].gif,
                        height: size, width: size),
              ));
        });
  }

  Widget _buildItem(BuildContext context, int index) {
    return Card(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          _buildNewItem(context, index),
          Visibility(
              visible: _newsSelected == index,
              child: ScaleTransition(
                scale: _newsAni,
                child: Center(
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      _buildReactBar(),
                      _buildAnimatedReactBar(),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  _buildReactBar() {
    var circular = (reactSize + _reactBarPadding) / 2;
    var radius = BorderRadius.circular(circular);
    var shadow = const [
      BoxShadow(
          offset: Offset(5, 5),
          color: Colors.black38,
          blurRadius: 24,
          spreadRadius: -12)
    ];
    return Container(
      margin: EdgeInsets.only(bottom: _reactBarBotMargin),
      padding: EdgeInsets.all(_reactBarPadding),
      decoration: BoxDecoration(
        borderRadius: radius,
        color: Colors.white,
        boxShadow: shadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_reactions.length, (index) {
          return Padding(
            padding: EdgeInsets.all(_reactMargin),
            child: AnimatedBuilder(
                animation: _reactions[index].animation,
                builder: (context, _) {
                  double scale = reactScale * _reactions[index].animation.value;
                  double bigSize = _reactSize + _reactSize * scale;
                  return SizedBox(height: _reactSize, width: bigSize);
                }),
          );
        }),
      ),
    );
  }

  _buildAnimatedReactBar() {
    return Container(
      margin: EdgeInsets.only(bottom: _reactBarBotMargin),
      padding: EdgeInsets.all(_reactBarPadding),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(_reactions.length, (index) {
          return Padding(
            padding: EdgeInsets.all(_reactMargin),
            child: AnimatedBuilder(
                animation: _reactions[index].animation,
                builder: (context, _) {
                  var gif = _reactions[index].gif;
                  var text = _reactions[index].text;
                  double animation = _reactions[index].animation.value;
                  double scale = reactScale * animation;
                  double bigSize = _reactSize + _reactSize * scale;
                  return Column(
                    children: [
                      ScaleTransition(
                          scale: _reactions[index].animation,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Material(
                              color: Colors.black54,
                              shape: const StadiumBorder(),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 5),
                                child: Text(
                                  text,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 10),
                                ),
                              ),
                            ),
                          )),
                      Image.asset(gif, width: bigSize, height: bigSize)
                    ],
                  );
                }),
          );
        }),
      ),
    );
  }

  _buildNewItem(BuildContext context, int index) {
    String title = _news[index]["title"];
    String avatar = _news[index]["avatar"];
    String content = _news[index]["content"];
    return ListTile(
      title: Row(
        children: [
          CircleAvatar(
            child: Text(avatar),
            backgroundColor: Colors.accents[index % Colors.accents.length],
          ),
          Flexible(
              child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(title),
          ))
        ],
      ),
      subtitle: Column(
        children: [Text(content), _buildLikeButton(context, index)],
      ),
    );
  }

  Widget _buildLikeButton(BuildContext context, int index) {
    Reaction? reaction = _news[index]["reaction"];
    String text = "Like";
    Color color = Colors.transparent;
    Color textColor = Colors.black;
    if (reaction != null) {
      text = reaction.text;
      color = reaction.color;
      textColor = Colors.white;
    }
    var padding = const EdgeInsets.symmetric(vertical: 4, horizontal: 12);
    double icSize = 24;

    return GestureDetector(
        onTap: () => setState(() => _news[index]["reaction"] = null),
        onLongPressMoveUpdate: _updatePointer,
        onLongPressStart: _savePointer,
        onLongPressEnd: _clearPointer,
        onLongPress: () => _showReacts(index),
        onLongPressUp: _hideReacts,
        child: Container(
          color: Colors.transparent,
          alignment: Alignment.center,
          child: Material(
            shape: const StadiumBorder(),
            color: color,
            child: Padding(
              padding: padding,
              child: SizedBox(
                height: icSize,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (reaction != null) ...[
                      Image.asset(reaction.png, height: icSize, width: icSize),
                      const SizedBox(width: 8),
                    ],
                    Text(text, style: TextStyle(color: textColor))
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  void _hideReacts() => _newsCtr.reverse();

  void _showReacts(int index) {
    if (!_newsCtr.isAnimating && !_reactCtr.isAnimating) {
      setState(() => _newsSelected = index);
      _newsCtr.forward(from: 0);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    for (var element in _reactions) {
      element.controller.dispose();
    }
    _reactCtr.dispose();
    _newsCtr.dispose();
    super.dispose();
  }

  void _savePointer(LongPressStartDetails details) {
    _newsPosition = details;
  }

  void _updatePointer(LongPressMoveUpdateDetails details) {
    var _globalOrigin = _newsPosition.globalPosition;
    var _newLongPress = _globalOrigin + details.offsetFromOrigin;

    List<Rect> rects = _generateRects(details);

    int index = -1;
    for (int i = 0; i < rects.length; i++) {
      if (rects[i].contains(_newLongPress)) {
        index = i;
        break;
      }
    }
    if (index == -1) {
      if (_reactSelected != -1) {
        //renew
        _reactions[_reactSelected].reverse();
        _reactSelected = -1;
        _reactRect = Rect.zero;
      }
    } else {
      if (index != _reactSelected) {
        if (_reactSelected != -1) {
          _reactions[_reactSelected].reverse();
        }
        _reactRect = rects[index];
        _reactSelected = index;
        _reactions[_reactSelected].forward();
      }
    }
  }

  List<Rect> _generateRects(LongPressMoveUpdateDetails details) {
    var _globalOrigin = _newsPosition.globalPosition;
    var _localOrigin = _newsPosition.localPosition;
    double width = MediaQuery.of(context).size.width;

    var dy = _globalOrigin.dy - _localOrigin.dy - _reactBarBotMargin;
    dy = dy - _reactBarPadding;
    dy = dy - _reactMargin;

    if (_reactSelected == -1) {
      var wBar = reactSize * _reactions.length;
      var x = (width - wBar) / 2.0;
      Offset cursor = Offset(x, dy);
      return List.generate(_reactions.length, (index) {
        double size = reactSize;

        Offset start = cursor;
        Offset end = start + Offset(size, size);
        cursor = cursor + Offset(size, 0);

        return Rect.fromPoints(start, end);
      });
    } else {
      var wBar = reactSize * _reactions.length + reactScale * reactSize;
      var x = (width - wBar) / 2.0;
      Offset cursor = Offset(x, dy);
      return List.generate(_reactions.length, (index) {
        double bigSize = (reactScale + 1) * reactSize;
        double size = index == _reactSelected ? bigSize : reactSize;

        Offset start = cursor - Offset(0, size - reactSize);
        Offset end = start + Offset(size, size);
        cursor = cursor + Offset(size, 0);

        return Rect.fromPoints(start, end);
      });
    }
  }

  void _clearPointer(LongPressEndDetails details) {
    Offset start = _reactRect.center;
    start = start - Offset(0, scaffoldKey.currentState?.appBarMaxHeight ?? 0);

    Offset end = _newsPosition.globalPosition;
    end = Offset(MediaQuery.of(context).size.width / 2.0, end.dy);
    end = end - Offset(0, scaffoldKey.currentState?.appBarMaxHeight ?? 0);

    if (_reactSelected != -1) {
      for (var element in _reactions) {
        element.reverse();
      }
      if (_reactSelected < _reactions.length / 2) {
        _initAnimationPathLeft(start, end);
      } else {
        _initAnimationPathRight(start, end);
      }

      //animate
      var milliseconds = (_reactCtr.duration!.inMilliseconds * 0.7).floor();
      Future.delayed(Duration(milliseconds: milliseconds)).then((_) {
        setState(() =>
            _news[_newsSelected]["reaction"] = _reactions[_reactSelected]);
      });
      _reactCtr.forward(from: 0).then((_) {
        //renew
        _newsSelected = -1;
        _reactSelected = -1;
        _reactRect = Rect.zero;
        _newsPosition = const LongPressStartDetails();
      });
    }
  }

  _initAnimationPathLeft(Offset s, Offset e) {
    setState(() {
      _reactPath = Path();
      _reactPath.moveTo(s.dx, s.dy);
      _reactPath.conicTo(s.dx + 10, s.dy - 30, s.dx + 30, s.dy - 20, 2);
      _reactPath.conicTo(s.dx + 40, s.dy - 15, e.dx, e.dy, 10);
      _reactPath.close();
    });
  }

  _initAnimationPathRight(Offset s, Offset e) {
    setState(() {
      _reactPath = Path();
      _reactPath.moveTo(s.dx, s.dy);
      _reactPath.conicTo(s.dx - 10, s.dy - 30, s.dx - 30, s.dy - 20, 2);
      _reactPath.conicTo(s.dx - 40, s.dy - 15, e.dx, e.dy, 10);
      _reactPath.close();
    });
  }
}
