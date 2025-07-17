// API Service for Jikan API
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'model.dart';

class ApiService {
  static const String baseUrl = 'https://api.jikan.moe/v4';

  static Future<List<Anime>> fetchTopMovies() async {
    final response = await http.get(Uri.parse('$baseUrl/top/anime?type=movie'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body)['data'];
      return data.map((e) => Anime.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load top anime');
    }
  }

  static Future<List<Anime>> searchAnime(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/anime?q=$query'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body)['data'];
      return data.map((e) => Anime.fromJson(e)).toList();
    } else {
      throw Exception('Failed to search anime');
    }
  }

  static Future<Anime> fetchAnimeDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/anime/$id'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return Anime.fromJson(data);
    } else {
      throw Exception('Failed to load anime details');
    }
  }

  static Future<List<Anime>> fetchUpcomingAnime() async {
    final response = await http.get(Uri.parse('$baseUrl/seasons/upcoming'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body)['data'];
      return data.map((e) => Anime.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load upcoming anime');
    }
  }
}
