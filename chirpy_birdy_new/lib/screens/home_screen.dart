import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'chat_screen.dart'; // Import the ChatScreen

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver{
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late String currentUserId;
  List<Map<String, dynamic>> _users = [];
  StreamSubscription<ConnectivityResult>? connectivitySubscription;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    currentUserId = _auth.currentUser!.uid;
    WidgetsBinding.instance.addObserver(this);
    _updateUserStatus(true);
    _loadUsers();
    connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        _updateUserStatus(false);
      }else{
        _updateUserStatus(true);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    connectivitySubscription?.cancel();
    super.dispose();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.resumed){
      _updateUserStatus(true);
    }else {
      _updateUserStatus(false);
    }
  }


  Future<void> _updateUserStatus(bool isOnline) async {
    if (currentUserId != null && currentUserId.isNotEmpty) {
      try{
        final userDoc = await _firestore.collection('users').doc(currentUserId).get();
        if(userDoc.exists){
          await _firestore.collection('users').doc(currentUserId).update({"status" : isOnline ? "online" : "offline"});
        }else{
          print("Document does not exist with user id: $currentUserId");
        }
      }catch (e){
        print("Error updating user status: $e");
      }
    }
  }

  Future<void> _loadUsers() async {
    print("Loading users started!");
    try {
      final userSnapshot = await _firestore.collection('users').get();
      print("userSnapshot: $userSnapshot");

      List<Map<String, dynamic>> users = [];
      for (var doc in userSnapshot.docs){
        final userData = doc.data();
        if (userData != null && userData.containsKey('email') && userData.containsKey("uid")) {
          print("Adding user ${userData["email"]} with status ${userData["status"]}");
          users.add(userData);
        }
      }
      print("Users before set state: $users");
      setState(() {
        _users = users;
        _isLoading = false;
      });
      print("Users after set state: $_users");
      print("Loading users finished!");
    } catch (e){
      print("Error loading users: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    print("Length of user is ${_users.length}");
    if(_isLoading){
      return const Center(child: CircularProgressIndicator(),);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Chats'), actions: [
        IconButton(onPressed: () {
          _auth.signOut();
          Navigator.pop(context);
        }, icon: const Icon(Icons.logout))
      ],),
      body: _users.isEmpty ? const Center(child: Text("No users found"),) : ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          if(user["uid"] == currentUserId){
            return const SizedBox();
          }
          return ListTile(
            title: Text(user["email"]),
            subtitle: Text(user["status"] ?? "offline"),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ChatScreen(receiverId: user["uid"], receiverName: user["email"]),
              ));
            },
          );
        },
      ),
    );
  }
}


