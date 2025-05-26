


import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:uuid/uuid.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import '../models/message_model.dart';

class ChatScreen extends StatefulWidget {
final String receiverId;
final String receiverName;

ChatScreen({Key? key, required this.receiverId, required this.receiverName})
    : super(key: key);

@override
_ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
final _auth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;
final _storage = FirebaseStorage.instance;
final _audioRecorder = FlutterSoundRecorder();
late String currentUserId;
final _messageController = TextEditingController();
List<MessageModel> _messages = [];
bool _isLoading = false;
String? _errorMessage;
final ScrollController _scrollController = ScrollController();
StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userStatusSubscription;
String _receiverStatus = "offline";
bool _isTyping = false;


@override
void initState() {
super.initState();
currentUserId = _auth.currentUser!.uid;
WidgetsBinding.instance.addPostFrameCallback((_) {
_scrollToBottom();
});
_listenToMessages();
_listenToUserStatus();
_audioRecorder.openRecorder();
}
void _listenToUserStatus() {
_userStatusSubscription = _firestore.collection('users').doc(widget.receiverId).snapshots().listen((snapshot) {
if(snapshot.exists){
setState(() {
_receiverStatus = snapshot.data()!["status"] ?? "offline";
});
}
});
}

void _listenToMessages() {
_firestore
    .collection('chats')
    .doc(_getChatId())
    .collection('messages')
    .orderBy('timestamp', descending: false)
    .snapshots()
    .listen((snapshot) {
List<MessageModel> newMessages = snapshot.docs.map((doc) => MessageModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id)).toList();

setState(() {
_messages = newMessages;
});
WidgetsBinding.instance.addPostFrameCallback((_) {
_scrollToBottom();
});
});
}
void _scrollToBottom() {
if (_scrollController.hasClients) {
_scrollController.jumpTo(_scrollController.position.maxScrollExtent);
}
}

String _getChatId() {
if (currentUserId.compareTo(widget.receiverId) > 0) {
return '$currentUserId-${widget.receiverId}';
} else {
return '${widget.receiverId}-$currentUserId';
}
}
void _updateTypingStatus(bool isTyping) async {
setState(() {
_isTyping = isTyping;
});
}

void _sendMessage() async {
String text = _messageController.text.trim();
if (text.isNotEmpty) {
try {
final messageDocRef =  _firestore.collection('chats').doc(_getChatId()).collection('messages').doc();
final message = MessageModel(text: text, senderId: currentUserId, timestamp: Timestamp.now(), id: messageDocRef.id);
await messageDocRef.set(message.toFirestore());
_messageController.clear();
} catch (e) {
print("Error sending message $e");
setState(() {
_errorMessage = "Failed to send message";
});
}
}
_updateTypingStatus(false);
}

void _sendImage() async {
final ImagePicker picker = ImagePicker();
final XFile? image = await picker.pickImage(source: ImageSource.gallery);
if(image != null){
setState(() {
_isLoading = true;
_errorMessage = null;
});
print("Starting image upload...");
try {
File imageFile = File(image.path);
print("Image picked: ${image.path}");
final compressedFile = await FlutterImageCompress.compressAndGetFile(imageFile.path, "${imageFile.path}.compressed.jpg", quality: 80);
if (compressedFile != null) {
File compressedImageFile = File(compressedFile.path);
print("Compressed image path: ${compressedFile.path}");
String imageName = const Uuid().v4();
final storageRef = _storage.ref().child("chat_images/$imageName.jpg");
print("Storage ref path: ${storageRef.fullPath}");
final uploadTask = storageRef.putFile(
compressedImageFile,
SettableMetadata(contentType: "image/jpeg"),
);
print("Upload task started...");
TaskSnapshot snapshot = await uploadTask;
print("Upload task state: ${snapshot.state}");
if (snapshot.state == TaskState.success){
final imageUrl = await snapshot.ref.getDownloadURL();
print("Image URL: $imageUrl");
final messageDocRef =  _firestore.collection('chats').doc(_getChatId()).collection('messages').doc();
final message = MessageModel(imageUrl: imageUrl, senderId: currentUserId, timestamp: Timestamp.now(), id: messageDocRef.id, text: "");
await messageDocRef.set(message.toFirestore());
} else{
print("Upload Failed!  ${snapshot.state}");
setState(() {
_errorMessage = "Failed to send image.";
});
}
}
}
on FirebaseException catch (e) {
print("Firebase Exception: ${e.message}");
setState(() {
_errorMessage = e.message;
});
}catch(e){
print("Generic Exception: $e");
print("Error sending image: $e");
setState(() {
_errorMessage = "Failed to send image. Please try again later.";
});
}finally{
setState(() {
_isLoading = false;
});
}
}
}

void _sendGif() async {
showMaterialModalBottomSheet(
context: context,
builder: (context) => SizedBox(
height: MediaQuery.of(context).size.height * 0.7,
child: FutureBuilder(
future: http.get(Uri.parse("https://api.giphy.com/v1/gifs/trending?api_key=66daAClVrdvHl7hjXXyPyyq4lyERmsww&limit=20")),
builder: (context, snapshot){
if(snapshot.hasData){
try{
final response = json.decode(snapshot.data!.body);
if (response["data"] is List) {
return GridView.builder(
gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
crossAxisCount: 3,
),
itemCount: response["data"].length,
itemBuilder: (context, index){
final gif = response["data"][index];
return GestureDetector(
onTap: () async {
final gifUrl = gif["images"]["fixed_width"]["url"];
setState(() {
_isLoading = true;
_errorMessage = null;
});
try{
final messageDocRef =  _firestore.collection('chats').doc(_getChatId()).collection('messages').doc();
final message = MessageModel(gifUrl: gifUrl, senderId: currentUserId, timestamp: Timestamp.now(), id: messageDocRef.id, text: "");
await messageDocRef.set(message.toFirestore());
}on FirebaseException catch (e) {
setState(() {
_errorMessage = e.message;
});
} catch(e){
print("Error sending gif $e");
setState(() {
_errorMessage = "Failed to send GIF. Please try again later";
});
}
finally {
setState(() {
_isLoading = false;
});
Navigator.of(context).pop();
}
},
child: CachedNetworkImage(imageUrl: gif["images"]["fixed_width"]["url"]!, fit: BoxFit.cover,),
);
},
);
}
else {
print("The data is not a list.");
return const Center(child: Text("Error loading Gifs - response is not a list"),);
}
}catch(e){
print("Error decoding JSON: $e");
return const Center(child: Text("Error loading Gifs - Error in decoding JSON"),);
}
}
if(snapshot.hasError){
print("Snapshot error: ${snapshot.error}");
return const Center(child: Text("Error loading Gifs"),);
}
return const Center(child: CircularProgressIndicator(),);
},
),
)
);
}


@override
void dispose(){
super.dispose();
_messageController.dispose();
_scrollController.dispose();
_userStatusSubscription?.cancel();
_audioRecorder.closeRecorder();
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: Text(widget.receiverName),
bottom: PreferredSize(
preferredSize: const Size.fromHeight(20),
child: Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
if(_isTyping)
const Text("typing...", style: TextStyle(fontSize: 12)),
Text(" ($_receiverStatus)", style: const TextStyle(fontSize: 12),),
],
),
),
),
body: SafeArea(
child: Column(
children: [
if(_errorMessage!= null)
Container(
padding: const EdgeInsets.all(8.0),
color: Colors.red[100],
child: Text(_errorMessage!, style: const TextStyle(color: Colors.red),),
),
Expanded(
child: _messages.isEmpty ? const Center(child: Text("No messages yet!")) :  ListView.builder(
controller: _scrollController,
itemCount: _messages.length,
itemBuilder: (context, index){
final message = _messages[index];
bool isMe = message.senderId == currentUserId;
return ChatBubble(isMe: isMe, message: message);
}
)
),
if (_isLoading)
const LinearProgressIndicator(),
Container(
padding: const EdgeInsets.all(8.0),
child: Row(
children: [
Expanded(
child: TextField(
controller: _messageController,
onChanged: (value) => _updateTypingStatus(value.trim().isNotEmpty),
onEditingComplete: () => _updateTypingStatus(false),
decoration: InputDecoration(
hintText: 'Type a message...',
border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
),
),
),
IconButton(
icon: const Icon(Icons.send),
onPressed: _sendMessage,
),
IconButton(
onPressed: _sendImage,
icon: const Icon(Icons.image),
),
IconButton(
onPressed: _sendGif,
icon: const Icon(Icons.gif),
),
],
),
)
],
),
),
);
}
}

class ChatBubble extends StatelessWidget {
final bool isMe;
final MessageModel message;
const ChatBubble({super.key, required this.isMe, required this.message});
@override
Widget build(BuildContext context) {
return Container(
alignment: isMe ? Alignment.topRight : Alignment.topLeft,
padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
child:  ConstrainedBox(
constraints: BoxConstraints(
maxWidth: MediaQuery.of(context).size.width * 0.75
),
child:  Card(
elevation: 1,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
color: isMe ? Colors.lightBlue[100] : Colors.grey[200],
child: Padding(
padding: const EdgeInsets.all(12),
child: Builder(
builder: (context){
if(message.imageUrl != null){
return CachedNetworkImage(imageUrl: message.imageUrl!, fit: BoxFit.contain,);
}
if(message.gifUrl != null){
return CachedNetworkImage(imageUrl: message.gifUrl!, fit: BoxFit.contain,);
}
return Text(message.text);
}
)
)
)
),
);
}
}

