import 'package:flutter/material.dart';
import '../models/movies.dart';
import '../services/api_service.dart';
import 'movies_detail_screen.dart';
import 'add_edit_movies_screen.dart';

class ClothesListScreen extends StatefulWidget {
  const ClothesListScreen({super.key});

  @override
  State<ClothesListScreen> createState() => _ClothesListScreenState();
}

class _ClothesListScreenState extends State<ClothesListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Movies>> _movieFuture;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  void _loadMovies() {
    setState(() {
      _movieFuture = _apiService.getAllMovies();
    });
  }

  void _navigateToAddScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditMoviesScreen()),
    );
    if (result == true) {
      _loadMovies();
    }
  }

  void _navigateToDetailScreen(Movies movie) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MoviesDetailScreen(movieId: movie.id!),
      ),
    );
    if (result == true) {
      _loadMovies();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Film'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadMovies),
        ],
      ),
      body: FutureBuilder<List<Movies>>(
        future: _movieFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No movies found.'));
          }

          final movie = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 0.75,
            ),
            itemCount: movie.length,
            itemBuilder: (context, index) {
              final cloth = movie[index];
              return Card(
                elevation: 3,
                child: InkWell(
                  onTap: () => _navigateToDetailScreen(cloth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Hero(
                          tag: "", //'movieImage_${movie.id}',
                          child: Container(
                            color: Colors.grey[300],
                            child: Center(
                              child: Text(
                                "", //movie.title.isNotEmpty
                                // ? movie.title[0].toUpperCase()
                                // : '?',
                                style: const TextStyle(
                                  fontSize: 40,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "", //movie.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "", //'$movie.genre',
                              style: TextStyle(color: Colors.green[700]),
                            ),
                            Text(
                              "", // movie.genre,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddScreen,
        tooltip: 'Add Movies',
        child: const Icon(Icons.add),
      ),
    );
  }
}
