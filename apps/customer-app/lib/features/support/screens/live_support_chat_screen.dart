import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/kisan_header.dart';

/// Implements Stitch `live_farm_support_chat`.
class LiveSupportChatScreen extends StatefulWidget {
  const LiveSupportChatScreen({super.key});

  @override
  State<LiveSupportChatScreen> createState() => _LiveSupportChatScreenState();
}

class _LiveSupportChatScreenState extends State<LiveSupportChatScreen> {
  final _ctrl = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'fromUser': false,
      'text': 'Namaste! Welcome to Kisan Setu Farm Support. How can we help with your harvest basket today?',
    },
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add({'fromUser': true, 'text': text.trim()});
      _messages.add({
        'fromUser': false,
        'text': 'Thanks for reaching out! A Pune FPO coordinator has received your message regarding "$text".',
      });
    });
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const KisanStackAppBar(title: 'Live Farm Support Chat'),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.margin),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                final fromUser = m['fromUser'] == true;
                return Align(
                  alignment:
                      fromUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 280),
                    decoration: BoxDecoration(
                      color: fromUser
                          ? AppColors.primaryContainer
                          : AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: fromUser ? null : Border.all(color: AppColors.cardBorder),
                    ),
                    child: Text(
                      m['text'] as String,
                      style: TextStyle(
                        color: fromUser ? Colors.white : AppColors.onSurface,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () => _send(_ctrl.text),
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
