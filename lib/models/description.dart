class Description {
  final int id;
  final String name;
  final String description;

  Description({
    this.id,
    this.name,
    this.description,
  });

  factory Description.fromJson({ Map<String, dynamic> description }) {
    return Description(
      id: int.parse(description['desid']),
      name: description['name'],
      description: description['description'],
    );
  }
}
