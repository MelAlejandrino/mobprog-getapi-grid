class Album {
  final String id;
  final String title;
  final String imageUrl;

  Album({
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'],
      title: json['message'] ?? 'No title',
      imageUrl: json['full_picture'] ?? '',
    );
  }
}