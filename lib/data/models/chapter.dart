class Chapter {
  final String title;
  final String url;
  final String releaseDate;
  final String param;

  Chapter({
    required this.title,
    required this.url,
    required this.releaseDate,
    required this.param,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      title: json['chapter'] ?? '',
      url: json['detail_url'] ?? '',
      releaseDate: json['release'] ?? '',
      param: json['param'] ?? '',
    );
  }
}
