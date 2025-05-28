import 'package:flutter/material.dart';
import '../../models/movies.dart';
import '../../services/api_service.dart';

class AddEditMoviesScreen extends StatefulWidget {
  final Movies? movie;

  const AddEditMoviesScreen({super.key, this.movie});

  @override
  State<AddEditMoviesScreen> createState() => _AddEditMoviesScreenState();
}

class _AddEditMoviesScreenState extends State<AddEditMoviesScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  late TextEditingController _titleController;
  late TextEditingController _yearController;
  late TextEditingController _genreController;
  late TextEditingController _directorController;
  late TextEditingController _synopsisController;
  late TextEditingController _ratingController;
  late TextEditingController _imgUrlController;
  late TextEditingController _movieUrlController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.movie?.title ?? '');
    _yearController = TextEditingController(
      text: widget.movie?.year?.toString() ?? '',
    );
    _genreController = TextEditingController(text: widget.movie?.genre ?? '');
    _directorController = TextEditingController(
      text: widget.movie?.director ?? '',
    );
    _ratingController = TextEditingController(
      text: widget.movie?.rating?.toString() ?? '',
    );
    _synopsisController = TextEditingController(
      text: widget.movie?.synopsis ?? '',
    );
    _imgUrlController = TextEditingController(text: widget.movie?.imgUrl ?? '');
    _movieUrlController = TextEditingController(
      text: widget.movie?.movieUrl?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _yearController.dispose();
    _genreController.dispose();
    _directorController.dispose();
    _synopsisController.dispose();
    _ratingController.dispose();
    _imgUrlController.dispose();
    _movieUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveMovies() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final movieData = Movies(
        id: widget.movie?.id,
        title: _titleController.text,
        year: int.parse(_yearController.text),
        genre: _genreController.text,
        director: _directorController.text,
        synopsis: _synopsisController.text,
        rating: double.parse(_ratingController.text),
        imgUrl: _imgUrlController.text,
        movieUrl: _movieUrlController.text,
      );

      try {
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        if (widget.movie == null) {
          await _apiService.addMovie(movieData);
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Moviesing added successfully! ✨'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          await _apiService.updateMovie(widget.movie!.id!, movieData);
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('Moviesing updated successfully! 👍'),
              backgroundColor: Colors.green,
            ),
          );
        }
        if (mounted) Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.movie == null ? '➕ Add New Movies' : '✏️ Edit Movies',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              _buildTextField(_titleController, 'Name', isRequired: true),
              _buildTextField(
                _yearController,
                'Price',
                inputType: TextInputType.number,
                isRequired: true,
              ),
              _buildTextField(_genreController, 'Category', isRequired: true),
              _buildTextField(
                _ratingController,
                'Rating (0.0 - 5.0)',
                inputType: TextInputType.numberWithOptions(decimal: true),
                isRequired: true,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Rating is required.';
                  final rating = double.tryParse(value);
                  if (rating == null || rating < 0 || rating > 5) {
                    return 'Rating must be between 0 and 5.';
                  }
                  return null;
                },
              ),
              _buildTextField(
                _movieUrlController,
                'Year Released (e.g., 2018 - ${DateTime.now().year})',
                inputType: TextInputType.number,
                isRequired: true,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Year released is required.';
                  final year = int.tryParse(value);
                  if (year == null ||
                      year < 2018 ||
                      year > DateTime.now().year) {
                    return 'Year must be between 2018 and ${DateTime.now().year}.';
                  }
                  return null;
                },
              ),
              _buildTextField(_directorController, 'Brand (Optional)'),
              _buildTextField(
                _imgUrlController,
                'Stock (Optional)',
                inputType: TextInputType.number,
              ),
              _buildTextField(
                _synopsisController,
                'Sold (Optional)',
                inputType: TextInputType.number,
              ),

              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: _saveMovies,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      widget.movie == null ? 'Add Movies' : 'Save Changes',
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType inputType = TextInputType.text,
    bool isRequired = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        keyboardType: inputType,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return '$label is required.';
          }
          if (validator != null) {
            return validator(value);
          }
          if ((label == 'Price' ||
                  label == 'Stock' ||
                  label == 'Sold' ||
                  label.startsWith('Year Released')) &&
              value != null &&
              value.isNotEmpty) {
            if (int.tryParse(value) == null)
              return 'Please enter a valid number for $label.';
          }
          if (label.startsWith('Rating') && value != null && value.isNotEmpty) {
            if (double.tryParse(value) == null)
              return 'Please enter a valid decimal for $label.';
          }
          return null;
        },
      ),
    );
  }
}
