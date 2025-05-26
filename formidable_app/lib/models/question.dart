class Question {
  String? id;
  String type;
  String title;
  bool isRequired;
  List<String>? options;

  Question({
    this.id,
    required this.type,
    required this.title,
    this.isRequired = false,
    this.options,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'isRequired': isRequired,
      'options': options,
    };
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      isRequired: json['isRequired'] ?? false,
      options: json['options'] != null ? List<String>.from(json['options']) : null,
    );
  }
}