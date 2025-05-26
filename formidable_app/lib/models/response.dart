class ResponseModel {
  String? id;
  String formId;
  List<Answer> answers;
  DateTime? submittedAt;
  String? name;
  String? email;

  ResponseModel({
    this.id,
    required this.formId,
    required this.answers,
    this.submittedAt,
    this.name,
    this.email,
  });


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'formId': formId,
      'answers': answers.map((a) => a.toJson()).toList(),
      'submittedAt': submittedAt?.toIso8601String(),
      'name': name,
      'email': email,
    };
  }

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    return ResponseModel(
      id: json['id'],
      formId: json['formId'],
      answers: (json['answers'] as List)
          .map((a) => Answer.fromJson(a))
          .toList(),
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'])
          : null,
      name: json['name'],
      email: json['email'],
    );
  }
}

class Answer {
  String questionId;
  dynamic value;

  Answer({
    required this.questionId,
    required this.value,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'value': value,
    };
  }

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      questionId: json['questionId'] ?? '',
      value: json['value'] ?? '',
    );
  }
}