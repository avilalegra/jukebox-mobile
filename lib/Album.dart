class AlbumSummary {
  final String uid;
  final String name;
  final String? year;
  final int duration;
  final bool hasCover;

  const AlbumSummary(
      {required this.uid,
      required this.name,
      required this.year,
      required this.duration,
      required this.hasCover});

  factory AlbumSummary.fromJson(Map<String, dynamic> json) {
    return AlbumSummary(
        uid: json['uid'],
        name: json['name'],
        year: json['year'],
        duration: json['duration'],
        hasCover: json['hasCover']);
  }
}
