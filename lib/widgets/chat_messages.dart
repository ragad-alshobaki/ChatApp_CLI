import 'package:chat_app_cli/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream:
          FirebaseFirestore.instance
              .collection('chat')
              .orderBy('createdAt', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No message Found.'));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong...'));
        }

        final loadMessages = snapshot.data!.docs;

        return ListView.builder(
          padding: EdgeInsets.only(bottom: 40, left: 13, right: 13),
          reverse: true,
          itemCount: loadMessages.length,
          // itemBuilder: (context, index) => Text(loadMessages[index].data()['text'],),
          itemBuilder: (context, index) {
            final chatMessage = loadMessages[index].data();
            final nextMessage =
                index + 1 < loadMessages.length
                    ? loadMessages[index].data()
                    : null;
            final currentMessageUserId = chatMessage['userId'];
            final nextMessageUserId =
                nextMessage != null ? nextMessage['userId'] : null;
            final bool nextUserIsSame =
                nextMessageUserId == currentMessageUserId;

            if (nextUserIsSame) {
              MessageBubble.next(
                message: chatMessage['text'],
                isMe: authUser.uid == currentMessageUserId,
              );
            } else {
              return MessageBubble.first(
                userImage: chatMessage['userImage'],
                username: chatMessage['userName'],
                message: chatMessage['text'],
                isMe: authUser.uid == currentMessageUserId,
              );
            }
          },
        );
      },
    );
  }
}
