class Ingredient {
  final int? id;
  final String? aisle;
  final String? image;
  final String? consistency;
  final String? name;
  final String? nameClean;
  final String? original;
  final String? originalName;
  final double? amount;
  final String? unit;
  final List<String>? meta;

  Ingredient({
    this.id,
    this.aisle,
    this.image,
    this.consistency,
    required this.name,
    this.nameClean,
    this.original,
    this.originalName,
    this.amount,
    this.unit,
    this.meta
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'],
      aisle: json['aisle'],
      image: json['image'],
      consistency: json['consistency'],
      name: json['name'],
      nameClean: json['nameClean'],
      original: json['original'],
      originalName: json['originalName'],
      amount: json['amount'],
      unit: json['unit'],
      meta: (json['meta'] as List?)?.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'aisle': aisle,
      'image': image,
      'consistency': consistency,
      'name': name,
      'nameClean': nameClean,
      'original': original,
      'originalName': originalName,
      'amount': amount,
      'unit': unit,
      'meta': meta
    };
  }
}