import 'package:flutter/material.dart';
import 'package:rubber/rubber.dart';
import 'package:intl/intl.dart';

import 'package:platyplus_app/models/event.dart';

class EventPage extends StatefulWidget {
  EventPage({
    this.child,
    this.onCollapsed,
    this.onExpanded,
  });

  static _EventPageState of(BuildContext context) =>
      context.findAncestorStateOfType<_EventPageState>();

  final Widget child;
  final Function onCollapsed;
  final Function onExpanded;

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage>
    with SingleTickerProviderStateMixin {
  Event event;
  RubberAnimationController animationController;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    animationController = RubberAnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
      upperBoundValue: AnimationControllerValue(percentage: 1),
      lowerBoundValue: AnimationControllerValue(percentage: 0),
    );
    animationController.addListener(_statusListener);

    super.initState();
  }

  _statusListener() {
    if (animationController.animationState.value == AnimationState.collapsed) {
      widget.onCollapsed();
    }

    if (animationController.animationState.value == AnimationState.expanded) {
      widget.onExpanded();
    }
  }

  Future<bool> _onWillPop() {
    Future<bool> result = Future.value(true);
    if (animationController.animationState.value == AnimationState.expanded) {
      animationController.collapse();
      result = Future.value(false);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: RubberBottomSheet(
        scrollController: _scrollController,
        animationController: animationController,
        lowerLayer: widget.child,
        upperLayer: _upperLayer(),
      ),
    );
  }

  Widget _upperLayer() {
    if (event == null) {
      return null;
    } else {
      return Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.only(left: 10, right: 10),
        color: Colors.blue.shade900,
        child: SafeArea(
            child: SingleChildScrollView(
          controller: _scrollController,
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              _header(),
              _location(),
              _time(),
              _description(),
            ],
          ),
        )),
      );
    }
  }

  Widget _location() {
    return Container(
      padding: EdgeInsets.only(bottom: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'At the ${event.location.name}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: 'PlatyPlus',
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          event.description.name,
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontFamily: 'PlatyPlus',
          ),
        ),
      ),
    );
  }

  Widget _description() {
    return Container(
      padding: EdgeInsets.only(bottom: 60),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          event.description.description,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _time() {
    return Align(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        child: Text(
          '''
Starts at ${DateFormat.Hm().format(event.startsAt)}
Ends at ${DateFormat.Hm().format(event.endsAt)}
''',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  setEvent(Event event) {
    setState(() {
      this.event = event;
    });
  }
}
