import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:platyplus_app/models/event.dart';
import 'package:platyplus_app/menu.dart';
import 'package:platyplus_app/event_page.dart';
import 'package:platyplus_app/constants.dart' as Constants;
import 'package:platyplus_app/widgets/time_speed_dial.dart';

class VerticalSchedulePage extends StatefulWidget {
  VerticalSchedulePage({Key key, this.title}) : super(key: key);

  final String title;

  static _VerticalScheduleState of(BuildContext context) =>
      context.findAncestorStateOfType<_VerticalScheduleState>();
  @override
  _VerticalScheduleState createState() => _VerticalScheduleState();
}

class _VerticalScheduleState extends State<VerticalSchedulePage> {
  ScrollController _eventController;
  ScrollController _timeController;
  DateTime _selectedDay = DateTime.parse('2019-11-20 00:00:00');
  bool _eventPageOpen = false;
  bool _dialVisible = false;
  final AsyncMemoizer _memoizer = AsyncMemoizer();

  _scrollListener() {
    if (!_timeController.position.isScrollingNotifier.value) {
      _timeController.jumpTo(_eventController.offset);
    }

    setSelectedDayByPosition(_eventController.position.pixels);
  }

  _timeScrollListener() {
    if (!_eventController.position.isScrollingNotifier.value) {
      _eventController.jumpTo(_timeController.offset);
    }
  }

  setSelectedDayByPosition(double position) {
    DateTime startDay = DateTime.parse('2019-11-20 07:30:00');
    int minutes =
        ((position * Constants.TIME_INTERVAL) / Constants.TIME_HEIGHT).floor();
    DateTime selectedDay = startDay.add(Duration(minutes: minutes));

    if (_selectedDay.day != selectedDay.day) {
      setSelectedDay(selectedDay);
    }
  }

  setSelectedDay(DateTime selectedDay) {
    setState(() {
      _selectedDay = selectedDay;
    });
  }

  jumpTo(DateTime startTime, DateTime targetTime) {
    int minutes = targetTime.difference(startTime).inMinutes;
    double position =
        (minutes / Constants.TIME_INTERVAL) * Constants.TIME_HEIGHT;

    this._eventController.jumpTo(position);
  }

  _fetchEvents() {
    return this._memoizer.runOnce(() async {
      var response = await http.get(Constants.API_URL);
      if (response.statusCode == 200) {
        List<Event> result = [];

        var data = convert.json.decode(response.body);
        var jsonEvents = data['events'];

        jsonEvents.forEach((key, jsonEvent) {
          // get descriptions
          String descriptionId = jsonEvent['desid'];
          Map<String, dynamic> descriptionJson = convert
              .jsonDecode(response.body)['descriptions']['$descriptionId'];

          // get locations
          String locationId = jsonEvent['locid'];
          Map<String, dynamic> locationJson =
              convert.jsonDecode(response.body)['localisations']['$locationId'];

          // create the event
          Event event = Event.fromJson(
            event: jsonEvent,
            description: descriptionJson,
            location: locationJson,
          );

          // add the event to the results
          result.add(event);
        });

        showDial();

        return _eventsStaggeredTiles(result);
      } else {
        throw Exception('Failed to fetch events');
      }
    });
  }

  List<Event> _eventsStaggeredTiles(List<Event> events) {
    events.sort((a, b) => a.startsAt.compareTo(b.startsAt));

    List<Event> result = [];
    List<Event> buffer = [];

    // untill everything has been processed
    // -----------------------------------
    while (events.isNotEmpty) {
      // add first event to buffer if the buffer is empty
      // -----------------------------------------------
      if (buffer.isEmpty) {
        // set max width to event
        events.first.tileWidth = Constants.SCHEDULE_WIDTH;

        // move event to buffer
        buffer.add(events.removeAt(0));
      }

      // process 1 event
      // --------------
      bool newRow = false;
      int i = 0;

      while (i < buffer.length) {
        if (!overlaps(buffer[i], events.first)) {
          // set width if it was not set
          if (buffer[i].tileWidth == 0) {
            buffer[i].tileWidth = Constants.SCHEDULE_WIDTH;
          }

          // set the spacing
          buffer[i].bottomSpacing =
              spacing(events.first.startsAt, buffer[i].endsAt);

          // move event in buffer to result
          result.add(buffer.removeAt(i));

          // set new row flag
          newRow = true;
        } else {
          i += 1;
        }
      }

      if (newRow) {
        // set width
        if (buffer.isNotEmpty) {
          events.first.tileWidth = buffer.last.tileWidth;
        }
        // add event to buffer
        buffer.add(events.removeAt(0));
      } else {
        // set spacing
        if (buffer.isNotEmpty) {
          events.first.spacing =
              spacing(events.first.startsAt, buffer.last.startsAt);
        }

        // add event to buffer
        buffer.add(events.removeAt(0));
      }

      // set buffered events width
      int width = tileWidth(buffer);
      buffer.forEach((event) {
        event.tileWidth = width;
      });
    }

    result.addAll(buffer);

    result.sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return result;
  }

  bool overlaps(Event a, Event b) {
    bool result = false;
    if (a.startsAt.compareTo(b.startsAt) == 0 ||
        (a.startsAt.isBefore(b.startsAt) && a.endsAt.isAfter(b.endsAt)) ||
        a.endsAt.isAfter(b.startsAt)) {
      result = true;
    }

    return result;
  }

  int tileWidth(List<Event> buffer) {
    return (Constants.SCHEDULE_WIDTH / buffer.length).floor();
  }

  double spacing(DateTime a, DateTime b) {
    int minutes = a.difference(b).inMinutes;
    return (minutes / Constants.TIME_INTERVAL) * Constants.TIME_HEIGHT;
  }

  @override
  void initState() {
    _eventController = ScrollController();
    _eventController.addListener(_scrollListener);

    _timeController = ScrollController();
    _timeController.addListener(_timeScrollListener);

    super.initState();
  }

  openedEventPage() => setState(() => _eventPageOpen = true);
  closedEventPage() => setState(() => _eventPageOpen = false);
  showDial() => setState(() => _dialVisible = true);
  hideDial() => setState(() => _dialVisible = false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: TimeSpeedDial(
          visible: _dialVisible,
          selectedDay: _selectedDay,
          days: [
            DateTime.parse('2019-11-20 07:30:00'),
            DateTime.parse('2019-11-21 07:30:00'),
            DateTime.parse('2019-11-22 07:30:00'),
            DateTime.parse('2019-11-23 07:30:00'),
            DateTime.parse('2019-11-24 07:30:00'),
          ],
        ),
        body: Menu(
          onCollapsed: () {
            if (!_eventPageOpen) {
              showDial();
            }
          },
          onExpanded: hideDial,
          child: EventPage(
            onCollapsed: () {
              showDial();
              closedEventPage();
            },
            onExpanded: () {
              hideDial();
              openedEventPage();
            },
            child: FutureBuilder(
              future: _fetchEvents(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Loader();

                final List<Event> events = snapshot.data;
                return Row(
                  children: [
                    _TimeList(
                        controller: _timeController,
                        times: generateTimes(
                          start: events.first.startsAt,
                          end: events.last.endsAt,
                          interval: Duration(minutes: Constants.TIME_INTERVAL),
                        )),
                    Expanded(
                      flex: 2,
                      child: EventsGrid(
                          events: events, controller: _eventController),
                    ),
                  ],
                );
              },
            ),
          ),
        ));
  }
}

class _TimeList extends StatelessWidget {
  const _TimeList({this.controller, this.times});

  final ScrollController controller;
  final List<String> times;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 45,
        color: Colors.orange,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 24, bottom: 65),
          controller: controller,
          itemCount: times.length,
          itemBuilder: (context, index) => _TimeItem(time: times[index]),
        ));
  }
}

List<String> generateTimes({controller, start, end, interval}) {
  List<String> result = [];
  DateTime addedTime = start;
  while (addedTime.isBefore(end)) {
    result.add(DateFormat.Hm().format(addedTime));
    addedTime = addedTime.add(interval);
  }

  return result;
}

class _TimeItem extends StatelessWidget {
  const _TimeItem({this.time});
  final String time;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 6,
          right: 0,
          child: SvgPicture.asset(
            'assets/images/timeline.svg',
            color: Colors.white,
            height: Constants.TIME_HEIGHT,
          ),
        ),
        Container(
            height: Constants.TIME_HEIGHT,
            padding: const EdgeInsets.only(left: 2.0),
            child: Text(
              time,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 12,
              ),
            )),
      ],
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({
    this.event,
    this.backgroundColor,
  });

  final Event event;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(
          right: 3, bottom: 3 + event.bottomSpacing, top: event.spacing),
      color: backgroundColor,
      child: InkWell(
        onTap: () {
          EventPage.of(context).setEvent(event);
          EventPage.of(context).animationController.expand();
        },
        child: Center(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 10.0, left: 3.0, right: 3.0),
                child: Text(
                  event.description.name,
                  maxLines: 3,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Loader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 80.0,
        height: 80.0,
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/loading.gif'),
              fit: BoxFit.scaleDown,
            ),
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              new BoxShadow(
                color: Colors.black,
                blurRadius: 3.0,
              ),
            ]),
      ),
    );
  }
}

class EventsGrid extends StatelessWidget {
  const EventsGrid({
    this.events,
    this.controller,
  });

  final List<Event> events;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return StaggeredGridView.countBuilder(
      physics: ClampingScrollPhysics(),
      controller: controller,
      itemCount: events.length,
      itemBuilder: (context, index) => _EventTile(
        event: events[index],
        backgroundColor: Colors.lightBlue,
      ),
      staggeredTileBuilder: (index) => StaggeredTile.extent(
        events[index].tileWidth,
        events[index].staggeredTileHeight + events[index].spacing,
      ),
      crossAxisCount: Constants.SCHEDULE_WIDTH,
      mainAxisSpacing: 0.0,
      crossAxisSpacing: 0.0,
      padding: const EdgeInsets.only(left: 3.0, top: 30, bottom: 60),
    );
  }
}
