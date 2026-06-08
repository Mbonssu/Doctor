import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/color_extensions.dart';

class ChatScreen extends StatefulWidget {
  final String doctorName;
  final String specialty;
  final String initials;
  final Color color;

  const ChatScreen({
    super.key,
    this.doctorName = 'Dr. Amine Toure',
    this.specialty = 'Cardiologie',
    this.initials = 'AT',
    this.color = AppColors.cardio,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _isTyping = false;

  final List<_Message> _messages = [
    _Message(text: 'Bonjour Docteur, j\'ai une question concernant mon traitement à l\'Amlodipine.', isMe: true, time: '14h05'),
    _Message(text: 'Bonjour Jean ! Bien sûr, je vous écoute. Quelle est votre question ?', isMe: false, time: '14h07'),
    _Message(text: 'Depuis 3 jours, je ressens une légère sensation de gonflement aux chevilles. Est-ce un effet secondaire connu ?', isMe: true, time: '14h09'),
    _Message(
      text: 'Oui, c\'est un effet secondaire relativement fréquent de l\'Amlodipine — appelé œdème périphérique. C\'est généralement bénin.\n\nQuelques conseils :\n• Surélevez les jambes le soir\n• Réduisez les apports en sel\n• Marchez 20-30 min par jour\n\nSi le gonflement persiste ou s\'aggrave, contactez-moi. Pouvez-vous me donner une photo dans quelques jours ?',
      isMe: false, time: '14h12',
    ),
    _Message(text: 'Merci beaucoup Docteur ! Je vais suivre vos conseils et vous envoyer une photo dans 48h.', isMe: true, time: '14h14'),
    _Message(text: 'Parfait. N\'hésitez pas si vous avez d\'autres questions. Bonne journée ! 🙂', isMe: false, time: '14h15'),
  ];

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Message(text: text, isMe: true, time: _currentTime()));
      _msgCtrl.clear();
      _isTyping = true;
    });
    _scrollToBottom();
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add(_Message(
          text: 'Merci pour votre message. Je vous réponds dès que possible.',
          isMe: false, time: _currentTime(),
        ));
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  String _currentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}h${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // final _isDark = context.isDark;

    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                border: Border(bottom: BorderSide(color: context.borderColor, width: 1)),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                  ),
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: Text(widget.initials,
                        style: TextStyle(color: widget.color, fontWeight: FontWeight.w800, fontSize: 14))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.doctorName,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimary)),
                      Row(children: [
                        Container(width: 6, height: 6,
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.success)),
                        const SizedBox(width: 5),
                        Text(widget.specialty,
                            style: TextStyle(fontSize: 11, color: context.textMuted)),
                      ]),
                    ],
                  )),
                  IconButton(onPressed: () {}, icon: Icon(Icons.more_vert_rounded, color: context.textMuted)),
                ],
              ),
            ),

            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i == _messages.length && _isTyping) {
                    return _TypingBubble(initials: widget.initials, color: widget.color);
                  }
                  final m = _messages[i];
                  return _MessageBubble(message: m, color: widget.color, initials: widget.initials);
                },
              ),
            ),

            // Input bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                border: Border(top: BorderSide(color: context.borderColor, width: 1)),
              ),
              child: Row(
                children: [
                  // Pièce jointe
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.borderColor, width: 1),
                      ),
                      child: Icon(Icons.attach_file_rounded, color: context.textMuted, size: 20),
                    ),
                  ),
                  const SizedBox(width: 10),

                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: context.borderColor, width: 1),
                      ),
                      child: TextField(
                        controller: _msgCtrl,
                        maxLines: 4,
                        minLines: 1,
                        decoration: InputDecoration(
                          hintText: 'Écrivez votre message…',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          hintStyle: TextStyle(fontSize: 14, color: context.textMuted),
                        ),
                        onChanged: (v) => setState(() {}),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Envoyer
                  GestureDetector(
                    onTap: _sendMessage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: _msgCtrl.text.trim().isNotEmpty ? AppColors.primary : AppColors.border,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final _Message message;
  final Color color;
  final String initials;

  const _MessageBubble({required this.message, required this.color, required this.initials});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Center(child: Text(initials, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 10))),
            ),
            const SizedBox(width: 8),
          ],
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.primary : context.surfaceColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(4),
                      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
                    ),
                    border: isMe ? null : Border.all(color: AppColors.border, width: 1),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                  child: Text(message.text,
                      style: TextStyle(
                        fontSize: 14,
                        color: isMe ? Colors.white : context.textPrimary,
                        height: 1.45,
                      )),
                ),
                const SizedBox(height: 4),
                Text(message.time,
                    style: TextStyle(fontSize: 10, color: context.textMuted)),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  final String initials;
  final Color color;
  const _TypingBubble({required this.initials, required this.color});

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this)..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: widget.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(widget.initials, style: TextStyle(color: widget.color, fontWeight: FontWeight.w800, fontSize: 10))),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18), topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4), bottomRight: Radius.circular(18),
              ),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, _) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final t = ((_ctrl.value - i * 0.2) % 1.0).clamp(0.0, 1.0);
                  final scale = 0.6 + 0.4 * (t < 0.5 ? 2 * t : 2 * (1 - t));
                  return Container(
                    margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.textMuted.withValues(alpha: 0.4 + 0.6 * scale),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Message {
  final String text, time;
  final bool isMe;
  const _Message({required this.text, required this.isMe, required this.time});
}
