import 'description.dart';
import 'location.dart';
import 'package:platyplus_app/constants.dart' as Constants;

class Event {
  final int id;
  final int descriptionId;
  final int locationId;
  final DateTime startsAt;
  final DateTime endsAt;
  final String state;
  final String reason;
  final Description description;
  final Location location;
  double tileHeight;
  int tileWidth;
  double spacing;
  double bottomSpacing;

  double get staggeredTileHeight => this.tileHeight + this.bottomSpacing;

  Event({
    this.id,
    this.descriptionId,
    this.locationId,
    this.startsAt,
    this.endsAt,
    this.state,
    this.reason,
    this.description,
    this.location,
    this.tileWidth = 0,
    this.spacing = 0,
    this.bottomSpacing = 0,
  }) {
    _setTileHeight();
  }

  factory Event.fromJson({
    Map<String, dynamic> event,
    Map<String, dynamic> description,
    Map<String, dynamic> location,
  }) {
    return Event(
      id: int.parse(event['eid']),
      descriptionId: int.parse(event['desid']),
      locationId: int.parse(event['locid']),
      startsAt: DateTime.parse(event['begin']),
      endsAt: DateTime.parse(event['end']),
      state: event['state'],
      reason: event['reason'],
      description: Description.fromJson(description: description),
      location: Location.fromJson(location: location),
    );
  }

  void _setTileHeight() {
    int minutes = this.endsAt.difference(this.startsAt).inMinutes;
    this.tileHeight =
        (minutes / Constants.TIME_INTERVAL) * Constants.TIME_HEIGHT;
  }
}
