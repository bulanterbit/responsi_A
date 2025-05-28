import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movies.dart';

class ApiService {
  final String _baseUrl =
      "https://tpm-api-responsi-a-h-872136705893.us-central1.run.app/api/v1/";

  Future<List<Movies>> getAllMovies() async {
    final response = await http.get(Uri.parse('$_baseUrl/movies'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['status'] == 'Success' && responseData['data'] != null) {
        final List<dynamic> moviesJson = responseData['data'];
        return moviesJson.map((json) => Movies.fromJson(json)).toList();
      } else {
        throw Exception(responseData['message'] ?? 'Failed to load clothes');
      }
    } else {
      throw Exception(
        'Failed to load movies - Status Code: ${response.statusCode}',
      );
    }
  }

  Future<Movies> getMovieById(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/movies/$id'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['status'] == 'Success' && responseData['data'] != null) {
        return Movies.fromJson(responseData['data']);
      } else {
        throw Exception(
          responseData['message'] ?? 'Failed to load movie details',
        );
      }
    } else if (response.statusCode == 404) {
      throw Exception('Movie not found');
    } else {
      throw Exception(
        'Failed to load movie details - Status Code: ${response.statusCode}',
      );
    }
  }

  Future<Map<String, dynamic>> addMovie(Movies movie) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/movies'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(movie.toJson()),
    );

    final Map<String, dynamic> responseBody = json.decode(response.body);
    if (response.statusCode == 201 && responseBody['status'] == 'Success') {
      return responseBody;
    } else {
      throw Exception(
        responseBody['message'] ??
            'Failed to add movie. Status Code: ${response.statusCode}',
      );
    }
  }

  Future<Map<String, dynamic>> updateMovie(int id, Movies movie) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/movies/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(movie.toJson()),
    );
    final Map<String, dynamic> responseBody = json.decode(response.body);
    if (response.statusCode == 200 && responseBody['status'] == 'Success') {
      return responseBody;
    } else {
      throw Exception(
        responseBody['message'] ??
            'Failed to update movie. Status Code: ${response.statusCode}',
      );
    }
  }

  Future<Map<String, dynamic>> deleteMovie(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/movies/$id'));

    final Map<String, dynamic> responseBody = json.decode(response.body);
    if (response.statusCode == 200 && responseBody['status'] == 'Success') {
      return responseBody;
    } else if (response.statusCode == 404) {
      throw Exception('Movie not found');
    } else {
      throw Exception(
        responseBody['message'] ??
            'Failed to delete movie. Status Code: ${response.statusCode}',
      );
    }
  }
}
