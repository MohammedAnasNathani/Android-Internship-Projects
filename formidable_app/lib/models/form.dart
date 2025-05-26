import 'package:formidable_app/models/question.dart';

class FormModel {
  String? id;
  String title;
  String? description;
  List<Question> questions;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? shareableId;

  FormModel({
    this.id,
    required this.title,
    this.description,
    required this.questions,
    this.createdAt,
    this.updatedAt,
    this.shareableId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'shareableId': shareableId,
    };
  }

  factory FormModel.fromJson(Map<String, dynamic> json) {
    return FormModel(
      id: json['_id'] ?? json['id'],
      title: json['title'],
      description: json['description'],
      questions: (json['questions'] as List)
          .map((q) => Question.fromJson(q))
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      shareableId: json['shareableId'],
    );
  }
}