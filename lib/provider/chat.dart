import 'dart:math';

import 'package:chat/model/chat.dart';
import 'package:chat/model/message.dart';
import 'package:chat/model/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final chatProvider = StateNotifierProvider<_Provider, _State>((ref) {
  return _Provider();
});

final _me = User(id: const Uuid().v4(), name: "あなた", iconUrl: Uri.parse("https://via.placeholder.com/50x50"));

class _Provider extends StateNotifier<_State> {
  _Provider() : super(_State.init());

  void initChatUI() {
    state = state.initChatUI();
  }

  void initMessage(Chat chat) {
    final me = _me;
    final other = chat.owners.where((element) => element.id != me.id).first;

    List<Message> messages = [];
    for (var i = 0; i < 100; i++) {
      final seed = Random().nextInt(10);

      messages.add(Message(
          id: const Uuid().v4(),
          chatId: chat.id,
          owner: i % 2 == 0 ? me : other,
          text: i % 2 == 0 ? "自分です自分です自分です自分です自分です自分です自分です" : "相手です相手です相手です相手です相手です相手です相手です相手です相手です相手です相手です相手です相手です相手です相手です相手です相手です相手です",
          imageUrl: seed < 5 ? Uri.parse("https://via.placeholder.com/250x200") : null,
          createdAt: DateTime.now()));
    }

    state = state.initMessage(messages);
  }
}

class _State {
  final User me;
  final List<Chat> chats;
  final List<Message> messages;
  final bool isInitChatUI;

  _State({required this.me, required this.chats, required this.messages, required this.isInitChatUI});

  _State initChatUI() {
    return _State(me: me, chats: chats, messages: messages, isInitChatUI: true);
  }

  _State initMessage(List<Message> messages) {
    return _State(me: me, chats: chats, messages: messages, isInitChatUI: false);
  }

  static _State init() {
    final me = _me;

    final other1 = User(id: const Uuid().v4(), name: "Aさん", iconUrl: Uri.parse("https://via.placeholder.com/50x50"));
    final other2 = User(id: const Uuid().v4(), name: "Bさん", iconUrl: Uri.parse("https://via.placeholder.com/50x50"));

    List<Chat> chats = [];
    chats.add(Chat(id: const Uuid().v4(), owners: [me, other1], lastUpdatedAt: DateTime.now()));
    chats.add(Chat(id: const Uuid().v4(), owners: [me, other2], lastUpdatedAt: DateTime.now()));

    return _State(me: me, chats: chats, messages: [], isInitChatUI: false);
  }
}
