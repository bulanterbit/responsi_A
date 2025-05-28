import 'package:flutter/material.dart';
import '../../models/movies.dart';
import '../../services/api_service.dart';
import 'add_edit_movies_screen.dart';

class MoviesDetailScreen extends StatefulWidget {
  final int movieId;

  const MoviesDetailScreen({super.key, required this.movieId});

  @override
  State<MoviesDetailScreen> createState() => _MoviesDetailScreenState();
}

class _MoviesDetailScreenState extends State<MoviesDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<Movies> _movieDetailFuture;

  @override
  void initState() {
    super.initState();
    _loadMovieDetails();
  }

  void _loadMovieDetails() {
    setState(() {
      _movieDetailFuture = _apiService.getMovieById(widget.movieId);
    });
  }

  void _navigateToEditScreen(Movies movie) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditMoviesScreen(movie: movie),
      ),
    );
    if (result == true) {
      _loadMovieDetails();
    }
  }

  Future<void> _deleteMovie(BuildContext context, int id) async {
    try {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      await _apiService.deleteMovie(id);
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Movie deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete movie: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Movie Details')),
      body: FutureBuilder<Movies>(
        future: _movieDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Movie not found.'));
          }

          final movie = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Hero(
                  tag: 'movieImage_${movie.id}',
                  child: Container(
                    height: 350,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child:
                        movie.imgUrl != null && movie.imgUrl!.isNotEmpty
                            ? Image.network(
                              movie.imgUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Text(
                                    movie.title != null &&
                                            movie.title!.isNotEmpty
                                        ? movie.title![0].toUpperCase()
                                        : 'M',
                                    style: const TextStyle(
                                      fontSize: 100,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              },
                              loadingBuilder: (
                                BuildContext context,
                                Widget child,
                                ImageChunkEvent? loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                  ),
                                );
                              },
                            )
                            : Center(
                              child: Text(
                                movie.title != null && movie.title!.isNotEmpty
                                    ? movie.title![0].toUpperCase()
                                    : 'M',
                                style: const TextStyle(
                                  fontSize: 100,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  movie.title ?? 'No Title',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Year: ${movie.year?.toString() ?? 'N/A'}', // Menggunakan movie.year
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Genre: ${movie.genre ?? 'N/A'}', // Menggunakan movie.genre
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (movie.director != null)
                  Text(
                    'Director: ${movie.director}', // Menggunakan movie.director
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                const SizedBox(height: 8),
                Text(
                  'Rating: ${movie.rating?.toStringAsFixed(1) ?? 'N/A'} ⭐', // Menggunakan movie.rating
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 12),
                if (movie.synopsis != null && movie.synopsis!.isNotEmpty) ...[
                  Text(
                    'Synopsis:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    movie.synopsis!, // Menggunakan movie.synopsis
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.justify,
                  ),
                ],
                if (movie.movieUrl != null && movie.movieUrl!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Movie URL: ${movie.movieUrl}', // Menampilkan movie.movieUrl
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                    // Tambahkan onTap untuk membuka URL jika diinginkan
                  ),
                ],
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      onPressed:
                          () =>
                              _navigateToEditScreen(movie), // Menggunakan movie
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor:
                            Colors.white, // Teks putih agar kontras
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('Delete'),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext ctx) {
                            return AlertDialog(
                              title: const Text('Please Confirm'),
                              content: const Text(
                                'Are you sure you want to delete this movie?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(ctx).pop(true);
                                    _deleteMovie(context, movie.id!);
                                  },
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
