import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../theme/app_theme.dart';
import '../utils/extensions.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _chatService = ChatService();

  @override
  void initState() {
    super.initState();
    _chatService.seedConversations();
  }

  @override
  Widget build(BuildContext context) {
    final convs = _chatService.conversations;

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: convs.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.message_outlined, size: 64, color: AppColors.grey.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text('Aucune conversation', style: TextStyle(color: AppColors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: convs.length,
              itemBuilder: (_, i) {
                final conv = convs[i];
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => _ChatDetailScreen(conversation: conv, chatService: _chatService),
                  )),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: conv.unreadCount > 0
                          ? AppColors.green.withValues(alpha: 0.05)
                          : AppColors.softBlack,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: conv.unreadCount > 0
                            ? AppColors.green.withValues(alpha: 0.2)
                            : AppColors.glassBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.green.withValues(alpha: 0.15),
                            image: conv.otherUserPhotoUrl != null
                                ? DecorationImage(image: NetworkImage(conv.otherUserPhotoUrl!), fit: BoxFit.cover)
                                : null,
                          ),
                          child: conv.otherUserPhotoUrl == null
                              ? Icon(Icons.person_rounded, color: AppColors.green, size: 24)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(conv.otherUserName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  ),
                                  Text(conv.lastMessageTime.toRelative(), style: const TextStyle(color: AppColors.grey, fontSize: 11)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                conv.lastMessage,
                                style: const TextStyle(color: AppColors.grey, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (conv.unreadCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('${conv.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _ChatDetailScreen extends StatefulWidget {
  final ChatConversation conversation;
  final ChatService chatService;
  const _ChatDetailScreen({required this.conversation, required this.chatService});

  @override
  State<_ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<_ChatDetailScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conv = widget.conversation;

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.green.withValues(alpha: 0.15),
                image: conv.otherUserPhotoUrl != null
                    ? DecorationImage(image: NetworkImage(conv.otherUserPhotoUrl!), fit: BoxFit.cover)
                    : null,
              ),
              child: conv.otherUserPhotoUrl == null
                  ? Icon(Icons.person_rounded, color: AppColors.green, size: 18)
                  : null,
            ),
            const SizedBox(width: 10),
            Text(conv.otherUserName),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: conv.messages.length,
              itemBuilder: (_, i) {
                final msg = conv.messages[i];
                final isMine = msg.isMine;
                return Align(
                  alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMine ? AppColors.green : AppColors.softBlack,
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: isMine ? const Radius.circular(4) : null,
                        bottomLeft: !isMine ? const Radius.circular(4) : null,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(msg.text, style: TextStyle(color: isMine ? Colors.white : AppColors.white)),
                        const SizedBox(height: 4),
                        Text(
                          '${msg.time.hour}:${msg.time.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(color: isMine ? Colors.white60 : AppColors.grey, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.glassBorder)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Écrire un message...',
                      border: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.chatService.sendMessage(widget.conversation.id, text);
    _controller.clear();
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
