class Anime {
  final int id;
  final String title;
  final String imageUrl;
  final String? releaseDate;
  final int? year;
  final String rating;
  final double? score;
  final List<String> genres;
  final String? synopsis;
  final String? trailerUrl;
  final String? trailerThumbnail;

  Anime({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.year,
    this.releaseDate,
    this.score,
    required this.rating,
    required this.genres,
    this.synopsis,
    this.trailerUrl,
    this.trailerThumbnail,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      id: json['mal_id'],
      title: json['title'] ?? 'No Title',
      imageUrl: json['images']?['jpg']?['image_url'] ?? '',
      year: json['year'],
      releaseDate: json['aired']?['from'] ?? json['year']?.toString(),
      score: (json['score'] != null) ? (json['score'] as num).toDouble() : null,
      rating: json['rating'],
      synopsis: json['synopsis'],
      trailerUrl: json['trailer']?['url'],
      trailerThumbnail: json['trailer']?['images']?['maximum_image_url'],
      genres: (json['genres'] as List<dynamic>?)
          ?.map((genre) => genre['name'] as String)
          .toList() ??
          [],
    );
  }
}
