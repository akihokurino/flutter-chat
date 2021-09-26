import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/model/chat.dart';
import 'package:chat/model/message.dart';
import 'package:chat/model/user.dart';
import 'package:chat/provider/chat.dart';
import 'package:chat/ui/dialog.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import "package:intl/intl.dart";
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class ChatDetail extends ConsumerWidget {
  final GlobalKey<DashChatState> _chatViewKey = GlobalKey<DashChatState>();
  final _textInputCtl = TextEditingController();
  final _scrollCtl = ScrollController(initialScrollOffset: 0.0);
  final Chat chat;

  ChatDetail({Key? key, required this.chat}) : super(key: key);

  ChatUser _userFrom(User user) {
    return ChatUser(uid: user.id, name: user.name, avatar: user.iconUrl?.toString() ?? "");
  }

  ChatMessage _messageFrom(Message message) {
    return ChatMessage(
        id: message.id,
        text: message.text,
        createdAt: message.createdAt,
        user: _userFrom(message.owner),
        image: message.imageUrl?.toString());
  }

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final state = watch(chatProvider);
    final action = context.read(chatProvider.notifier);

    if (!state.isInitChatUI) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 1000)).then((_) {
          _scrollCtl.animateTo(0, duration: const Duration(milliseconds: 10), curve: Curves.easeInOut);

          Future.delayed(const Duration(milliseconds: 1000)).then((_) {
            action.initChatUI();
          });
        });
      });
    }

    final dashChat = DashChat(
      key: _chatViewKey,
      textController: _textInputCtl,
      scrollController: _scrollCtl,
      user: _userFrom(state.me),
      messages: state.messages.map((element) {
        return _messageFrom(element);
      }).toList(),
      dateFormat: DateFormat('yyyy/MM/dd'),
      timeFormat: DateFormat('HH:mm'),
      inverted: true,
      showUserAvatar: false,
      showAvatarForEveryMessage: false,
      scrollToBottom: false,
      alwaysShowSend: true,
      shouldShowLoadEarlier: false,
      showTraillingBeforeSend: true,
      inputMaxLines: 5,
      messageContainerPadding: const EdgeInsets.only(left: 5.0, right: 5.0),
      inputToolbarPadding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      inputTextStyle: const TextStyle(fontSize: 16.0),
      inputDecoration: const InputDecoration.collapsed(hintText: "テキスト..."),
      inputContainerStyle: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: ThemeData.dark().backgroundColor,
            width: 1.0,
          ),
        ),
        color: ThemeData.dark().primaryColor,
      ),
      onLoadEarlier: () {
        action.prevMessage(chat);
      },
      onQuickReply: (Reply reply) {},
      messageBuilder: (ChatMessage message) {
        return MessageCell(message: message, me: state.me);
      },
      sendButtonBuilder: (Function click) {
        return IconButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          icon: const Icon(Icons.send, color: Colors.blueAccent),
          onPressed: () {
            click();
          },
        );
      },
      avatarBuilder: (ChatUser user) {
        return Container();
      },
      dateBuilder: (val) {
        return Container();
      },
      onSend: (ChatMessage val) {
        if (val.image != null) {
          return;
        }

        final text = val.text ?? "";
        if (text.isEmpty) {
          return;
        }

        action.sendTextMessage(chat, text);

        Future.delayed(const Duration(milliseconds: 500)).then((_) {
          _scrollCtl.animateTo(0, duration: const Duration(milliseconds: 10), curve: Curves.easeInOut);
        });
      },
      trailing: <Widget>[
        IconButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          icon: const Icon(Icons.photo, color: Colors.blueAccent),
          onPressed: () async {
            final file = await ImagePicker().pickImage(
              source: ImageSource.gallery,
              imageQuality: 100,
            );

            if (file == null) {
              return;
            }

            action.sendImageMessage(chat, File(file.path));

            Future.delayed(const Duration(milliseconds: 500)).then((_) {
              _scrollCtl.animateTo(_scrollCtl.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 10), curve: Curves.easeInOut);
            });
          },
        )
      ],
      onPressAvatar: (ChatUser user) {},
      onLongPressAvatar: (ChatUser user) {},
      onLongPressMessage: (ChatMessage message) {
        if (message.user.uid != state.me.id) {
          return;
        }
        AppDialog().showConfirm(context, "確認", "メッセージを削除します。", () {
          action.deleteMessage(chat, message.id!);
        });
      },
    );

    return Scaffold(
      key: key,
      appBar: AppBar(
        title: const Text("メッセージ"),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        shadowColor: Colors.transparent,
      ),
      backgroundColor: ThemeData.dark().primaryColor,
      body: ModalProgressHUD(
          progressIndicator: const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          child: dashChat,
          color: ThemeData.dark().primaryColor,
          opacity: 1.0,
          inAsyncCall: !state.isInitChatUI),
    );
  }
}

class MessageCell extends StatelessWidget {
  final ChatMessage message;
  final User me;

  const MessageCell({Key? key, required this.message, required this.me}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMe = message.user.uid == me.id;

    if (isMe) {
      return Container(
        margin: const EdgeInsets.only(top: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(right: 5),
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                _createdAtString(),
                style: ThemeData.dark().textTheme.caption,
              ),
            ),
            _buildMessage()
          ],
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.only(top: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(fit: BoxFit.fill, image: CachedNetworkImageProvider(message.user.avatar ?? ""))),
            ),
            _buildMessage(),
            Container(
              margin: const EdgeInsets.only(left: 5),
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                _createdAtString(),
                style: ThemeData.dark().textTheme.caption,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildMessage() {
    final isMe = message.user.uid == me.id;
    final image = message.image;

    if (image != null && image.isNotEmpty) {
      return Container(
        constraints: const BoxConstraints(minWidth: 0, maxWidth: 250),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        child: GestureDetector(
          onTap: () {},
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5.0),
            child: CachedNetworkImage(
              fit: BoxFit.fitHeight,
              height: 200,
              alignment: Alignment.center,
              imageUrl: image,
            ),
          ),
        ),
      );
    } else {
      return Container(
        constraints: const BoxConstraints(minWidth: 0, maxWidth: 250),
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          color: isMe ? ThemeData.dark().backgroundColor : Colors.greenAccent.withOpacity(0.5),
        ),
        child: Text(
          message.text ?? "",
          style: ThemeData.dark().textTheme.bodyText1,
        ),
      );
    }
  }

  String _createdAtString() {
    var formatter = DateFormat('MM/dd', "ja_JP");
    return formatter.format(message.createdAt);
  }
}
