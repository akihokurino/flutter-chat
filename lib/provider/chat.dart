import 'dart:io';
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

_sampleMessages(Chat chat) {
  final me = _me;
  final other = chat.owners.where((element) => element.id != me.id).first;

  List<Message> messages = [];
  for (var i = 0; i < 20; i++) {
    final seed = Random().nextInt(10);
    messages.add(Message(
        id: const Uuid().v4(),
        chatId: chat.id,
        owner: i % 2 == 0 ? me : other,
        text: i % 2 == 0
            ? "自分です自分です自分です自分です自分です自分です自分です（$i）"
            : "相手です相手です相手です相手です相手です相手です相手です相手です相手です相手です相手です相手です相手です相手です相手です相手です相手です相手です（$i）",
        imageUrl: seed < 5 ? Uri.parse("https://via.placeholder.com/250x200") : null,
        createdAt: DateTime.now().add(const Duration(days: -1)).add(Duration(minutes: i))));
  }

  return messages.reversed.toList();
}

class _Provider extends StateNotifier<_State> {
  _Provider() : super(_State.init());

  void initChatUI() {
    state = state.initChatUI();
  }

  void initMessage(Chat chat) {
    if (state.messages.isNotEmpty && state.messages.first.chatId == chat.id) {
      state = state.initMessage(chat, state.messages);
      return;
    }

    state = state.initMessage(chat, _sampleMessages(chat));
  }

  void prevMessage(Chat chat) {
    state = state.prevMessage(_sampleMessages(chat));
  }

  void sendTextMessage(Chat chat, String text) {
    final me = _me;
    state = state.addMessage(
        chat, Message(id: const Uuid().v4(), chatId: chat.id, owner: me, text: text, imageUrl: null, createdAt: DateTime.now()));
  }

  void sendImageMessage(Chat chat, File file) {
    final me = _me;
    final imageUrl = Uri.parse("https://via.placeholder.com/250x200");
    state = state.addMessage(
        chat, Message(id: const Uuid().v4(), chatId: chat.id, owner: me, text: "", imageUrl: imageUrl, createdAt: DateTime.now()));
  }

  void deleteMessage(Chat chat, String id) {
    state = state.deleteMessage(chat, id);
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

  _State initMessage(Chat chat, List<Message> items) {
    Message? first;
    try {
      first = items.first;
    } catch (_) {}

    return _State(
        me: me,
        chats: chats.map((element) {
          if (element.id == chat.id) {
            return element.updateMessage(first);
          } else {
            return element;
          }
        }).toList(),
        messages: items,
        isInitChatUI: false);
  }

  _State prevMessage(List<Message> items) {
    List<Message> next = messages;
    next.addAll(items);

    return _State(me: me, chats: chats, messages: next, isInitChatUI: isInitChatUI);
  }

  _State addMessage(Chat chat, Message item) {
    final next = messages;
    next.insert(0, item);

    return _State(
        me: me,
        chats: chats.map((element) {
          if (element.id == chat.id) {
            return element.updateMessage(item);
          } else {
            return element;
          }
        }).toList(),
        messages: next,
        isInitChatUI: isInitChatUI);
  }

  _State deleteMessage(Chat chat, String id) {
    final current = messages;
    current.removeWhere((element) => element.id == id);

    Message? first;
    try {
      first = current.first;
    } catch (_) {}

    return _State(
        me: me,
        chats: chats.map((element) {
          if (element.id == chat.id) {
            return element.updateMessage(first);
          } else {
            return element;
          }
        }).toList(),
        messages: current,
        isInitChatUI: isInitChatUI);
  }

  static _State init() {
    final me = _me;

    final other1 = User(id: const Uuid().v4(), name: "Aさん", iconUrl: Uri.parse("https://via.placeholder.com/50x50"));
    final other2 = User(id: const Uuid().v4(), name: "Bさん", iconUrl: Uri.parse("https://via.placeholder.com/50x50"));

    List<Chat> chats = [];
    chats.add(Chat(id: const Uuid().v4(), owners: [me, other1]));
    chats.add(Chat(id: const Uuid().v4(), owners: [me, other2]));

    return _State(me: me, chats: chats, messages: [], isInitChatUI: false);
  }
}
