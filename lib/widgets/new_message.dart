import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _msgController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _msgController.dispose();
  }

  _sendMsg() async{
    final enteredMsg = _msgController.text;

    if (enteredMsg.trim().isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();
    _msgController.clear();

    final User user = FirebaseAuth.instance.currentUser!;

    final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    try {
       await FirebaseFirestore.instance.collection('chats').add({
      'text': enteredMsg,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      // 'userName': userData.data()!['userName'],
      // 'userImage': userData.data()!['image_url'],
    }).onError((e, x){
      print(x.toString());
      return Future.value();
    });
    } catch (e) {
      print(e.toString());
    }
   
  }
  void _handleError (Exception e, StackTrace stackTrace) {
    
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          Expanded(child: TextField(
            controller: _msgController,
            decoration: InputDecoration(
              labelText: 'Send a message',
            ),
            autocorrect: true,
            enableSuggestions: true,
            textCapitalization: TextCapitalization.sentences,
          )),
          IconButton(
            onPressed: _sendMsg,
            icon: Icon(
              Icons.send,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
