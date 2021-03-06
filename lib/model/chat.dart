import 'package:chat/model/message.dart';
import 'package:chat/model/user.dart';
import "package:intl/intl.dart";

class Chat {
  final String id;
  final List<User> owners;
  final Message? lastMessage;

  Chat({required this.id, required this.owners, this.lastMessage});

  User other(User me) {
    return owners.where((element) => element.id != me.id).first;
  }

  String displayText() {
    if (lastMessage == null) {
      return "まだメッセージはありません";
    }

    if (lastMessage!.imageUrl != null) {
      return "画像が送信されました";
    }

    return lastMessage!.text;
  }

  String lastUpdatedAtText() {
    if (lastMessage == null) {
      return "";
    }
    var formatter = DateFormat('MM/dd', "ja_JP");
    return formatter.format(lastMessage!.createdAt);
  }

  Chat updateMessage(Message? message) {
    return Chat(id: id, owners: owners, lastMessage: message);
  }
}
