import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  String text;
  String senderId;
  Timestamp? timestamp;
  String? id;
  String? imageUrl;
  String? gifUrl;


  MessageModel({required this.text, required this.senderId, this.timestamp, this.id, this.imageUrl, this.gifUrl});

  factory MessageModel.fromFirestore(Map<String, dynamic> firestore, String id) {
    return MessageModel(
        text: firestore["text"] ?? "",
        senderId: firestore["senderId"] ?? "",
        timestamp: firestore["timestamp"],
        imageUrl: firestore["imageUrl"],
        gifUrl: firestore["gifUrl"],
        id: id
    );
  }

  Map<String, dynamic> toFirestore(){
    return {
      "text" : text,
      "senderId" : senderId,
      "timestamp" : timestamp,
      "imageUrl" : imageUrl,
      "gifUrl": gifUrl,
    };
  }
}
