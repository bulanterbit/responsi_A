class Movies {
  int? id;
  String? title;
  int? year;
  String? genre;
  String? director;
  double? rating;
  String? synopsis;
  String? imgUrl;
  String? movieUrl;

  Movies({
    this.id,
    this.title,
    this.year,
    this.genre,
    this.director,
    this.rating,
    this.synopsis,
    this.imgUrl,
    this.movieUrl,
  });

  Movies.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    year = json['year'];
    genre = json['genre'];
    director = json['director'];
    rating = json['rating'];
    synopsis = json['synopsis'];
    imgUrl = json['imgUrl'];
    movieUrl = json['movieUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['year'] = year;
    data['genre'] = genre;
    data['director'] = director;
    data['rating'] = rating;
    data['synopsis'] = synopsis;
    data['imgUrl'] = imgUrl;
    data['movieUrl'] = movieUrl;
    return data;
  }
}
