import 'package:flutter/material.dart';

class Comic {
  final String title;
  final String description;
  final String latestChapter;
  final String thumbnail;
  final String param;
  final String detailUrl;

  const Comic({
    required this.title,
    required this.description,
    required this.latestChapter,
    required this.thumbnail,
    required this.param,
    required this.detailUrl,
  });

  factory Comic.fromJson(Map<String, dynamic> json) {
    return Comic(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      latestChapter: json['latest_chapter'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      param: json['param'] ?? '',
      detailUrl: json['detail_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'latest_chapter': latestChapter,
      'thumbnail': thumbnail,
      'param': param,
      'detail_url': detailUrl,
    };
  }
}
