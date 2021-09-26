import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/model/chat.dart';
import 'package:chat/model/user.dart';
import 'package:chat/provider/chat.dart';
import 'package:chat/transition.dart';
import 'package:chat/ui/chat_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatList extends ConsumerWidget {
  const ChatList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final state = watch(chatProvider);
    final action = context.read(chatProvider.notifier);

    List<Widget> widgets = state.chats.map((element) {
      return ChatCell(
          chat: element,
          me: state.me,
          onClick: () {
            action.initMessage(element);
            push(context, ChatDetail());
          });
    }).toList();

    return Scaffold(
      key: key,
      appBar: AppBar(
        title: const Text("チャット"),
        backgroundColor: ThemeData.dark().primaryColor,
        elevation: 0.0,
        shadowColor: Colors.transparent,
      ),
      backgroundColor: ThemeData.dark().primaryColor,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 40),
        children: widgets,
      ),
    );
  }
}

class ChatCell extends StatelessWidget {
  final Chat chat;
  final User me;
  final VoidCallback onClick;

  const ChatCell({Key? key, required this.chat, required this.me, required this.onClick}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final other = chat.other(me);
    const double height = 60;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            onClick();
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: height,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(fit: BoxFit.fill, image: CachedNetworkImageProvider(other.iconUrl.toString()))),
                ),
                Expanded(
                    child: Container(
                  height: height,
                  margin: const EdgeInsets.only(right: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          other.name,
                          style: ThemeData.dark().textTheme.bodyText1,
                          maxLines: 1,
                        ),
                      ),
                      Text(
                        chat.displayText(),
                        style: ThemeData.dark().textTheme.caption,
                        maxLines: 1,
                      )
                    ],
                  ),
                )),
                Container(
                  width: 50,
                  height: height,
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    chat.lastUpdatedAtText(),
                    style: ThemeData.dark().textTheme.caption,
                    textAlign: TextAlign.right,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
