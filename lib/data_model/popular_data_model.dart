class PopularDataModel {
  List<Results>? results;

  PopularDataModel({this.results});

  PopularDataModel.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <Results>[];
      json['results'].forEach((v) {
        results!.add(Results.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (results != null) {
      data['results'] = results!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Results {
  String? publishedDate;
  String? title;

  Results({
    this.publishedDate,
    this.title,
  });

  Results.fromJson(Map<String, dynamic> json) {
    publishedDate = json['published_date'];

    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['publishedDate'] = publishedDate;
    data['title'] = title;

    return data;
  }
}
