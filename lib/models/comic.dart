import 'package:flutter/material.dart';

class Comic {
  final String id;
  final String title;
  final String genre;
  final String rating;
  final String chapter;
  final Color color;

  const Comic({
    required this.id,
    required this.title,
    required this.genre,
    required this.rating,
    required this.chapter,
    required this.color,
  });

  get description => null;
}

final List<Comic> dummyComics = [
  Comic(
    id: '1',
    title: 'Solo Leveling',
    genre: 'Action',
    rating: '9.2',
    chapter: 'Ch. 179',
    color: Color(0xFF1565C0),
  ),
  Comic(
    id: '2',
    title: 'One Piece',
    genre: 'Adventure',
    rating: '9.5',
    chapter: 'Ch. 1100',
    color: Color(0xFFE65100),
  ),
  Comic(
    id: '3',
    title: 'Demon Slayer',
    genre: 'Action',
    rating: '9.0',
    chapter: 'Ch. 205',
    color: Color(0xFF6A1B9A),
  ),
  Comic(
    id: '4',
    title: 'Attack on Titan',
    genre: 'Drama',
    rating: '9.8',
    chapter: 'Ch. 139',
    color: Color(0xFF37474F),
  ),
  Comic(
    id: '5',
    title: 'Jujutsu Kaisen',
    genre: 'Action',
    rating: '8.9',
    chapter: 'Ch. 250',
    color: Color(0xFF1B5E20),
  ),
  Comic(
    id: '6',
    title: 'Spy x Family',
    genre: 'Comedy',
    rating: '8.7',
    chapter: 'Ch. 95',
    color: Color(0xFFF57F17),
  ),
  Comic(
    id: '7',
    title: 'Chainsaw Man',
    genre: 'Horror',
    rating: '8.8',
    chapter: 'Ch. 160',
    color: Color(0xFFB71C1C),
  ),
  Comic(
    id: '8',
    title: 'Vinland Saga',
    genre: 'Historical',
    rating: '9.1',
    chapter: 'Ch. 200',
    color: Color(0xFF4E342E),
  ),
  Comic(
    id: '9',
    title: 'Blue Lock',
    genre: 'Sports',
    rating: '8.6',
    chapter: 'Ch. 250',
    color: Color(0xFF0D47A1),
  ),
  Comic(
    id: '10',
    title: 'Mushishi',
    genre: 'Fantasy',
    rating: '9.3',
    chapter: 'Ch. 50',
    color: Color(0xFF2E7D32),
  ),
];

final List<Comic> bookmarkedComics = [
  dummyComics[0],
  dummyComics[2],
  dummyComics[5],
  dummyComics[8],
];
