import 'package:chat/model/user.dart';

class Message {
  final String id;
  final String chatId;
  final User owner;
  final String text;
  final Uri? imageUrl;
  final DateTime createdAt;

  Message(
      {required this.id, required this.chatId, required this.owner, required this.text, required this.imageUrl, required this.createdAt});
}
