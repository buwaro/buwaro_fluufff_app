class Location {
  final int id;
  final String name;
  final String description;

  Location({
    this.id,
    this.name,
    this.description,
  });

  factory Location.fromJson({ Map<String, dynamic> location }) {
    return Location(
      id: int.parse(location['locid']),
      name: location['name'],
      description: location['description'],
    );
  }
}
