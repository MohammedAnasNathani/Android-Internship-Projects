class Birthday {
  String date;
  String message;
  String cakeAsset;
  String musicAsset;

  Birthday({
    required this.date,
    required this.message,
    required this.cakeAsset,
    required this.musicAsset,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'message': message,
      'cake_asset': cakeAsset,
      'music_asset': musicAsset,
    };
  }

  factory Birthday.fromJson(Map<String, dynamic> json) {
    return Birthday(
      date: json['date'] ?? '',
      message: json['message'] ?? 'Happy Birthday',
      cakeAsset: json['cake_asset'] ?? 'assets/images/birthday_cake.gif',
      musicAsset: json['music_asset'] ?? 'assets/audio/birthday.mp3',
    );
  }
}