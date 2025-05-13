import 'package:chat_app/widgets/message.bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticateduser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
      stream:
          FirebaseFirestore.instance
              .collection('chat')
              .orderBy('createdAt', descending: true)
              .snapshots(),
      builder: (context, chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
          return const Center(child: Text('No messages found.'));
        }
        if (!chatSnapshots.hasError) {
          return const Center(child: Text('Something went wrong.'));
        }

        final loadedMessages = chatSnapshots.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
          reverse: true,
          itemCount: loadedMessages.length,
          itemBuilder: (context, index) {
            final ChatMessages = loadedMessages[index].data();
            final nextChatMessage =
                index + 1 < loadedMessages.length
                    ? loadedMessages[index + 1].data()
                    : null;

            final currentMessageUsername = ChatMessages['username'];
            final nextMessageUsername =
                nextChatMessage != null ? nextChatMessage['username'] : null;

            final currentMessageUserId = ChatMessages['userId'];
            final nextMessageUserId =
                nextChatMessage != null ? nextChatMessage['userId'] : null;

            final nextUserIsSame = nextMessageUserId == currentMessageUserId;

            if (nextUserIsSame) {
              return MessageBubble.next(
                message: ChatMessages['text'],
                isMe: authenticateduser.uid == currentMessageUserId,
              );
            } else {
              return MessageBubble.first(
                userImage: ChatMessages['userImage'],
                username: ChatMessages['username'],
                message: ChatMessages['text'],
                isMe: authenticateduser.uid == currentMessageUserId,
              );
            }
          },
        );
      },
    );
  }
}
