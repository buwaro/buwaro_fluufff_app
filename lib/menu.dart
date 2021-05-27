import 'package:flutter/material.dart';
import 'package:rubber/rubber.dart';
import 'package:platyplus_app/map.dart';
import 'package:platyplus_app/vertical_schedule.dart';

class Menu extends StatefulWidget {
  Menu({
    this.startOpen = false,
    this.child,
    this.onCollapsed,
    this.onExpanded,
  });

  final bool startOpen;
  final Widget child;
  final Function onCollapsed;
  final Function onExpanded;

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> with SingleTickerProviderStateMixin {
  RubberAnimationController _controller;
  ScrollController _scrollController = ScrollController();
  final _menuItems = [
    _MenuItem(name: 'Map', page: MapPage()),
    _MenuItem(name: 'Schedule', page: VerticalSchedulePage()),
  ];
  int _menuArrowRotation = 0;

  @override
  void initState() {
    _controller = RubberAnimationController(
      vsync: this,
      upperBoundValue: AnimationControllerValue(percentage: 0.5),
      duration: Duration(milliseconds: 200),
      lowerBoundValue: AnimationControllerValue(pixel: 60),
      springDescription: SpringDescription.withDampingRatio(
        mass: 1,
        stiffness: Stiffness.MEDIUM,
        ratio: DampingRatio.LOW_BOUNCY,
      ),
    );

    if (widget.startOpen) {
      _controller.expand();
    }

    _controller.animationState.addListener(_controllerAnimationStateListener);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RubberBottomSheet(
      scrollController: _scrollController,
      lowerLayer: _getLowerLayer(),
      header: _getHeader(),
      headerHeight: 60,
      upperLayer: _getUpperLayer(),
      animationController: _controller,
    );
  }

  Widget _getLowerLayer() {
    return Container(
      decoration: BoxDecoration(),
      child: widget.child,
    );
  }

  Widget _getUpperLayer() {
    return Container(
      decoration: BoxDecoration(color: Colors.black87),
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        controller: _scrollController,
        itemBuilder: (BuildContext context, int index) {
          return _menuItems[index];
        },
        itemCount: _menuItems.length,
      ),
    );
  }

  Widget _getHeader() {
    return GestureDetector(
        onTap: () {
          if (_controller.animationState.value == AnimationState.expanded) {
            _controller.collapse();
          } else {
            _controller.expand();
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              stops: [0.0, 1.0],
              colors: [Colors.black87, Colors.transparent],
            ),
          ),
          child: RotatedBox(
            quarterTurns: _menuArrowRotation,
            child: Center(
              child: Icon(
                Icons.keyboard_arrow_up,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ));
  }

  void _controllerAnimationStateListener() {
    print(_controller.animationState.value);
    setState(() {
      if (_controller.animationState.value == AnimationState.expanded) {
        // set arrow rotation
        _menuArrowRotation = 2;

        // hide speed dial
        if (widget.onExpanded != null) {
          widget.onExpanded();
        }
      } else if (_controller.animationState.value == AnimationState.collapsed) {
        // set arrow rotation
        _menuArrowRotation = 0;

        // show speed dial
        if (widget.onCollapsed != null) {
          widget.onCollapsed();
        }
      }
    });
  }
}

class _MenuItem extends StatelessWidget {
  final String name;
  final Widget page;

  _MenuItem({@required this.name, @required this.page});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Spacer(),
        Expanded(
          flex: 2,
          child: OutlinedButton(
            onPressed: () {
              if (Navigator.canPop(context)) Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => page),
              );
            },
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
              side: BorderSide(width: 2, color: Colors.white),
            ),
            child: Text(
              name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
        ),
        Spacer(),
      ],
    );
  }
}
