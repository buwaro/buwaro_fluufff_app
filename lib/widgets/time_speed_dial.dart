import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';

import 'package:platyplus_app/vertical_schedule.dart';

class TimeSpeedDial extends StatefulWidget {
  TimeSpeedDial({this.days, this.visible, this.selectedDay});

  final List<DateTime> days;
  final bool visible;
  final DateTime selectedDay;

  static _TimeSpeedDialState of(BuildContext context) =>
      context.findAncestorStateOfType<_TimeSpeedDialState>();

  @override
  _TimeSpeedDialState createState() => _TimeSpeedDialState();
}

class _TimeSpeedDialState extends State<TimeSpeedDial> {
  bool _open = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      onOpen: () => setState(() => _open = true),
      onClose: () => setState(() => _open = false),
      visible: widget.visible,
      overlayColor: Colors.grey,
      backgroundColor: Colors.orange,
      marginBottom: 75,
      child: _bigTimeButton(widget.selectedDay),
      children: speedDialChildren(widget.days, context),
    );
  }

  List<SpeedDialChild> speedDialChildren(
      List<DateTime> days, BuildContext context) {
    List<SpeedDialChild> result = [];
    days.reversed.forEach((day) => result.add(_smallTimeButton(day, context)));
    return result;
  }

  Widget _bigTimeButton(DateTime selectedDay) {
    if (this._open) {
      return Icon(Icons.close);
    } else {
      return Column(
        children: [
          Flexible(
            child: Container(
              color: Colors.transparent,
              margin: const EdgeInsets.only(top: 8.0),
              child: Container(
                color: Colors.transparent,
                child: Text(
                    '${DateFormat('EEEE').format(selectedDay).substring(0, 3)}'),
              ),
            ),
          ),
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(top: 20.0),
              child: Text(
                '${selectedDay.day}',
                style: TextStyle(
                  height: 0,
                  fontSize: 25,
                  fontFamily: 'PlatyPlus',
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  SpeedDialChild _smallTimeButton(DateTime day, BuildContext context) {
    return SpeedDialChild(
        backgroundColor: Colors.orange,
        label: '${DateFormat("EEEE").format(day)}',
        onTap: () {
          VerticalSchedulePage.of(context).setSelectedDay(day);
          VerticalSchedulePage.of(context).jumpTo(widget.days.first, day);
        },
        child: Center(
          child: Text(
            '${day.day}',
            style: TextStyle(
              fontSize: 25,
              fontFamily: 'PlatyPlus',
            ),
          ),
        ));
  }
}
