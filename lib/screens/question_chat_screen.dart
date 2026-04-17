import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/consult_models.dart';
import '../theme/app_theme.dart';
import '../widgets/avatar.dart';
import '../widgets/live_atoms.dart';
import 'photo_viewer_screen.dart';
import 'profile_screen.dart';
import 'vet_answer_screen.dart';

const String _meSeed = 'waew';

const Author _incomingVet = Author(
  name: 'Dr. Mana V.',
  clinic: 'Bangkok Vet Center',
  avatarSeed: 'mana',
  role: AuthorRole.vet,
  specialty: 'Internal Medicine',
  verified: true,
);

const String _incomingBody =
    'ขอเสริมจากคุณหมอท่านอื่นนะครับ — ถ้าอ้วกเริ่มมีสีเหลืองปนเขียวหรือเป็นฟองขาว ให้สังเกตว่าน้องแทะของแปลกๆ หรือกินหญ้ามาไหม และถ้าเริ่มซึม ไม่ตอบสนอง แนะนำให้ส่งรูปเหงือกมาดูก่อน จะช่วยประเมินภาวะขาดน้ำได้ครับ';

class _FollowUp {
  final String body;
  final DateTime postedAt;
  const _FollowUp(this.body, this.postedAt);
}

class _TickerItem {
  final String text;
  final Color accent;
  const _TickerItem(this.text, this.accent);
}

class QuestionChatScreen extends StatefulWidget {
  final Question question;
  const QuestionChatScreen({super.key, required this.question});

  @override
  State<QuestionChatScreen> createState() => _QuestionChatScreenState();
}

class _QuestionChatScreenState extends State<QuestionChatScreen> {
  late List<Answer> _answers;
  final List<_FollowUp> _followUps = [];
  String? _acceptedId;

  Answer? _incoming;
  int _revealChars = 0;
  Timer? _revealTimer;

  bool _showTyping = false;
  Author? _typingAuthor;

  int _tickerIndex = 0;
  Timer? _tickerTimer;
  static const List<_TickerItem> _tickerItems = [
    _TickerItem('🟢 4 คุณหมอออนไลน์ · 47 คนอยู่ในห้อง', AppColors.success),
    _TickerItem('👋 คุณแม่น้องมะลิ เข้าร่วมห้อง', AppColors.primary),
    _TickerItem('🔥 กำลัง trending ในหมวด Health', AppColors.secondary),
    _TickerItem('💬 +5 คนเข้าร่วมใน 1 นาทีที่ผ่านมา', AppColors.accent),
    _TickerItem('✨ Dr. Mana กำลังพิมพ์คำตอบ…', AppColors.vetBadge),
  ];

  final ScrollController _scrollCtrl = ScrollController();
  final TextEditingController _composerCtrl = TextEditingController();
  bool _hasComposerText = false;

  @override
  void initState() {
    super.initState();
    _answers = List.of(widget.question.answers);
    for (final a in _answers) {
      if (a.accepted) {
        _acceptedId = a.id;
        break;
      }
    }
    _composerCtrl.addListener(_onComposerChanged);
    _startTicker();
    _scheduleIncoming();
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    _tickerTimer?.cancel();
    _composerCtrl.removeListener(_onComposerChanged);
    _scrollCtrl.dispose();
    _composerCtrl.dispose();
    super.dispose();
  }

  void _onComposerChanged() {
    final has = _composerCtrl.text.trim().isNotEmpty;
    if (has != _hasComposerText) setState(() => _hasComposerText = has);
  }

  void _startTicker() {
    _tickerTimer = Timer.periodic(const Duration(milliseconds: 3200), (_) {
      if (!mounted) return;
      setState(() => _tickerIndex = (_tickerIndex + 1) % _tickerItems.length);
    });
  }

  void _scheduleIncoming() {
    final alreadyAnswered = _answers.any((a) => a.author.avatarSeed == _incomingVet.avatarSeed);
    if (alreadyAnswered) return;

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() {
        _typingAuthor = _incomingVet;
        _showTyping = true;
      });
      _scrollToBottom();
    });
    Future.delayed(const Duration(milliseconds: 4800), () {
      if (!mounted) return;
      setState(() {
        _showTyping = false;
        _incoming = Answer(
          id: 'incoming-sim',
          author: _incomingVet,
          body: _incomingBody,
          upvotes: 0,
          accepted: false,
          postedAt: DateTime.now(),
        );
        _revealChars = 0;
      });
      _revealTimer = Timer.periodic(const Duration(milliseconds: 28), (t) {
        if (!mounted || _incoming == null) {
          t.cancel();
          return;
        }
        final body = _incoming!.body;
        if (_revealChars >= body.length) {
          t.cancel();
          setState(() {
            _answers.add(_incoming!);
            _incoming = null;
            _revealChars = 0;
          });
          _scrollToBottom();
          return;
        }
        setState(() {
          _revealChars = (_revealChars + 2).clamp(0, body.length);
        });
        if (_revealChars % 40 == 0) _scrollToBottom();
      });
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  void _sendFollowUp() {
    final raw = _composerCtrl.text.trim();
    if (raw.isEmpty) return;
    setState(() {
      _followUps.add(_FollowUp(raw, DateTime.now()));
      _composerCtrl.clear();
    });
    _scrollToBottom();
  }

  Future<void> _openVetComposer() async {
    final newAnswer = await Navigator.of(context).push<Answer>(
      MaterialPageRoute(builder: (_) => VetAnswerScreen(question: widget.question)),
    );
    if (newAnswer != null && mounted) {
      setState(() => _answers.add(newAnswer));
      _scrollToBottom();
    }
  }

  void _toggleAccept(String id, bool accept) {
    setState(() {
      _acceptedId = accept ? id : null;
      _answers = _answers
          .map((a) => Answer(
                id: a.id,
                author: a.author,
                body: a.body,
                upvotes: a.upvotes,
                accepted: a.id == _acceptedId,
                postedAt: a.postedAt,
                suggestsClinicVisit: a.suggestsClinicVisit,
                photos: a.photos,
                isBrandSponsored: a.isBrandSponsored,
                brandCta: a.brandCta,
              ))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    final isMeOwner = q.author.avatarSeed == _meSeed;
    final sortedAnswers = List<Answer>.from(_answers)
      ..sort((a, b) => a.postedAt.compareTo(b.postedAt));

    final messages = <Widget>[];
    messages.add(_QuestionBubble(question: q, fromMe: isMeOwner));
    messages.add(_AiSystemBubble(
      text: 'แจ้งคุณหมอ ${q.category.label} 3 คนแล้ว · คาดว่าได้คำตอบใน ~3 นาที',
    ));

    final seen = <String>{q.author.avatarSeed};
    for (final a in sortedAnswers) {
      if (!seen.contains(a.author.avatarSeed)) {
        messages.add(_SystemDivider(
          text: '${a.author.role == AuthorRole.brand ? "🏷️" : "🩺"} ${a.author.name} ร่วมห้องสนทนา',
          time: a.postedAt,
        ));
        seen.add(a.author.avatarSeed);
      }
      messages.add(_AnswerBubble(
        answer: a,
        ownerCanAccept: isMeOwner,
        onAcceptToggle: (v) => _toggleAccept(a.id, v),
      ));
    }

    for (final f in _followUps) {
      messages.add(_FollowUpBubble(followUp: f));
    }

    if (_showTyping && _typingAuthor != null) {
      messages.add(_TypingBubble(author: _typingAuthor!));
    }
    if (_incoming != null) {
      messages.add(_AnswerBubble(
        answer: _incoming!,
        streaming: true,
        revealChars: _revealChars,
        ownerCanAccept: false,
      ));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _ChatAppBar(question: q, onlineCount: 47),
      body: Column(
        children: [
          const _PresenceStrip(activeVets: 4, viewers: 47, avgMinutes: 3),
          Expanded(
            child: ListView(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.sm),
              children: messages,
            ),
          ),
          _ActivityTicker(item: _tickerItems[_tickerIndex]),
          _ChatComposer(
            controller: _composerCtrl,
            hasText: _hasComposerText,
            onSend: _sendFollowUp,
            onAnswerAsVet: _openVetComposer,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// App bar
// ─────────────────────────────────────────────────────────────

class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Question question;
  final int onlineCount;
  const _ChatAppBar({required this.question, required this.onlineCount});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: const Border(bottom: BorderSide(color: AppColors.border)),
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: question.category.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(question.category.emoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  question.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    const PulseDot(color: AppColors.success, size: 6),
                    const SizedBox(width: 6),
                    Text(
                      'live room · $onlineCount คน',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Bookmark question',
          onPressed: () {},
          icon: const Icon(Icons.bookmark_outline, size: 20),
        ),
        IconButton(
          tooltip: 'More options',
          onPressed: () {},
          icon: const Icon(Icons.more_horiz, size: 20),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Presence strip
// ─────────────────────────────────────────────────────────────

class _PresenceStrip extends StatelessWidget {
  final int activeVets;
  final int viewers;
  final int avgMinutes;
  const _PresenceStrip({
    required this.activeVets,
    required this.viewers,
    required this.avgMinutes,
  });

  @override
  Widget build(BuildContext context) {
    const avatars = ['somchai', 'ploy', 'mana', 'nick'];
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 10, AppSpacing.lg, 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            height: 30,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                for (int i = 0; i < avatars.length; i++)
                  Positioned(
                    left: i * 18.0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(1.5),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surface,
                      ),
                      child: SeededAvatar(seed: avatars[i], size: 22),
                    ),
                  ),
                Positioned(
                  left: avatars.length * 18.0,
                  top: 2,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '+43',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified, size: 13, color: AppColors.vetBadge),
                    const SizedBox(width: 4),
                    Text(
                      '$activeVets vets',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.vetBadge,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                        color: AppColors.textSecondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$viewers viewing',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'ตอบเฉลี่ย ~$avgMinutes นาที',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.notifications_active_outlined, size: 14),
            label: const Text('Follow', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              minimumSize: const Size(0, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: const BorderSide(color: AppColors.primary, width: 1.2),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// AI system bubble (center-aligned pill)
// ─────────────────────────────────────────────────────────────

class _AiSystemBubble extends StatelessWidget {
  final String text;
  const _AiSystemBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg, left: 12, right: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.08),
                AppColors.accent.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome, size: 13, color: AppColors.primary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Question bubble (rich first message)
// ─────────────────────────────────────────────────────────────

class _QuestionBubble extends StatelessWidget {
  final Question question;
  final bool fromMe;
  const _QuestionBubble({required this.question, required this.fromMe});

  @override
  Widget build(BuildContext context) {
    final q = question;
    final text = Theme.of(context).textTheme;
    final bubbleColor = fromMe ? AppColors.primary : AppColors.surface;
    final textColor = fromMe ? Colors.white : AppColors.textPrimary;
    final subColor = fromMe ? Colors.white.withValues(alpha: 0.75) : AppColors.textSecondary;

    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 320),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(AppRadius.lg),
          topRight: const Radius.circular(AppRadius.lg),
          bottomLeft: Radius.circular(fromMe ? AppRadius.lg : 4),
          bottomRight: Radius.circular(fromMe ? 4 : AppRadius.lg),
        ),
        border: fromMe ? null : Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (q.isUrgent)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: fromMe
                    ? Colors.white.withValues(alpha: 0.22)
                    : AppColors.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 12,
                    color: fromMe ? Colors.white : AppColors.danger,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'URGENT',
                    style: TextStyle(
                      color: fromMe ? Colors.white : AppColors.danger,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          Text(
            q.title,
            style: text.titleMedium?.copyWith(
              color: textColor,
              height: 1.3,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            q.body,
            style: text.bodyMedium?.copyWith(color: textColor, height: 1.55),
          ),
          if (q.photos.isNotEmpty) ...[
            const SizedBox(height: 10),
            _QuestionPhotoStrip(photos: q.photos, caption: q.title, fromMe: fromMe),
          ],
          if (q.pet != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: fromMe ? Colors.white.withValues(alpha: 0.18) : AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  SeededAvatar(seed: q.pet!.avatarSeed, size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          q.pet!.name,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${q.pet!.species} · ${q.pet!.breed} · ${q.pet!.ageMonths} mo',
                          style: TextStyle(color: subColor, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '#${q.category.label.toLowerCase()}',
                style: TextStyle(
                  color: subColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('HH:mm').format(q.postedAt),
                style: TextStyle(color: subColor, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );

    return _BubbleRow(fromMe: fromMe, author: q.author, bubble: bubble);
  }
}

class _QuestionPhotoStrip extends StatelessWidget {
  final List<String> photos;
  final String caption;
  final bool fromMe;
  const _QuestionPhotoStrip({
    required this.photos,
    required this.caption,
    required this.fromMe,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < photos.length && i < 3; i++) ...[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => PhotoViewerScreen(
                photos: photos,
                initialIndex: i,
                caption: caption,
              ),
            )),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                photos[i],
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (_, __, ___) => Container(
                  width: 72,
                  height: 72,
                  color: fromMe
                      ? Colors.white.withValues(alpha: 0.2)
                      : AppColors.primarySoft,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.broken_image,
                    size: 22,
                    color: fromMe ? Colors.white : AppColors.primary,
                  ),
                ),
                loadingBuilder: (ctx, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    width: 72,
                    height: 72,
                    color: fromMe
                        ? Colors.white.withValues(alpha: 0.15)
                        : AppColors.primarySoft,
                  );
                },
              ),
            ),
          ),
          if (i < photos.length - 1 && i < 2) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Answer bubble (supports streaming)
// ─────────────────────────────────────────────────────────────

class _AnswerBubble extends StatelessWidget {
  final Answer answer;
  final bool streaming;
  final int revealChars;
  final bool ownerCanAccept;
  final ValueChanged<bool>? onAcceptToggle;

  const _AnswerBubble({
    required this.answer,
    this.streaming = false,
    this.revealChars = 0,
    this.ownerCanAccept = false,
    this.onAcceptToggle,
  });

  @override
  Widget build(BuildContext context) {
    final a = answer;
    final text = Theme.of(context).textTheme;
    final isVet = a.author.role == AuthorRole.vet;
    final isBrand = a.isBrandSponsored;
    final accent = isBrand
        ? AppColors.brandBadge
        : isVet
            ? AppColors.vetBadge
            : AppColors.primary;

    final revealed = revealChars.clamp(0, a.body.length);
    final body = streaming ? '${a.body.substring(0, revealed)}▊' : a.body;

    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 320),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.lg),
          topRight: Radius.circular(AppRadius.lg),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(AppRadius.lg),
        ),
        border: Border.all(
          color: a.accepted ? AppColors.success : accent.withValues(alpha: 0.35),
          width: a.accepted ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: a.accepted
                  ? AppColors.success.withValues(alpha: 0.1)
                  : accent.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.lg),
                topRight: Radius.circular(AppRadius.lg),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  a.accepted
                      ? Icons.check_circle
                      : (isBrand ? Icons.workspace_premium : Icons.verified),
                  size: 13,
                  color: a.accepted ? AppColors.success : accent,
                ),
                const SizedBox(width: 4),
                Text(
                  a.accepted
                      ? 'ACCEPTED · Verified Vet'
                      : (isBrand
                          ? 'SPONSORED'
                          : (streaming ? 'LIVE · Verified Vet' : 'Verified Vet')),
                  style: TextStyle(
                    color: a.accepted ? AppColors.success : accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                if (a.author.clinic != null) ...[
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      '· ${a.author.clinic}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                if (streaming) const _LiveDot(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(body, style: text.bodyMedium?.copyWith(height: 1.55)),
                if (a.suggestsClinicVisit && !streaming) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_hospital, color: AppColors.warning, size: 16),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'แนะนำพาน้องมาคลินิก',
                            style: TextStyle(
                              color: AppColors.warning,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.warning,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            minimumSize: const Size(0, 28),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('จอง Telemet', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ],
                if (a.brandCta != null && !streaming) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.shopping_bag_outlined, size: 16),
                      label: Text(a.brandCta!, style: const TextStyle(fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.brandBadge,
                        side: const BorderSide(color: AppColors.brandBadge),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: const Size(0, 32),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    final below = streaming
        ? null
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PillAction(
                icon: Icons.thumb_up_alt_outlined,
                label: '${a.upvotes}',
                onTap: () {},
              ),
              const SizedBox(width: 6),
              _PillAction(
                icon: Icons.reply_outlined,
                label: 'ถามต่อ',
                onTap: () {},
              ),
              if (ownerCanAccept && !a.isBrandSponsored) ...[
                const SizedBox(width: 6),
                _PillAction(
                  icon: a.accepted ? Icons.check_circle : Icons.check_circle_outline,
                  label: a.accepted ? 'Solution' : 'Accept',
                  highlight: a.accepted,
                  onTap: () => onAcceptToggle?.call(!a.accepted),
                ),
              ],
              const SizedBox(width: 8),
              Text(
                DateFormat('HH:mm').format(a.postedAt),
                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ],
          );

    return _BubbleRow(
      fromMe: false,
      author: a.author,
      bubble: bubble,
      below: below,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Follow-up chat bubble (from me)
// ─────────────────────────────────────────────────────────────

class _FollowUpBubble extends StatelessWidget {
  final _FollowUp followUp;
  const _FollowUpBubble({required this.followUp});

  @override
  Widget build(BuildContext context) {
    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.lg),
          topRight: Radius.circular(AppRadius.lg),
          bottomLeft: Radius.circular(AppRadius.lg),
          bottomRight: Radius.circular(4),
        ),
      ),
      child: Text(
        followUp.body,
        style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
      ),
    );
    const me = Author(name: 'You', avatarSeed: _meSeed, role: AuthorRole.owner);
    return _BubbleRow(
      fromMe: true,
      author: me,
      bubble: bubble,
      below: Text(
        DateFormat('HH:mm').format(followUp.postedAt),
        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Typing bubble
// ─────────────────────────────────────────────────────────────

class _TypingBubble extends StatelessWidget {
  final Author author;
  const _TypingBubble({required this.author});

  @override
  Widget build(BuildContext context) {
    final bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.lg),
          topRight: Radius.circular(AppRadius.lg),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(AppRadius.lg),
        ),
        border: Border.all(color: AppColors.vetBadge.withValues(alpha: 0.3)),
      ),
      child: const TypingDots(color: AppColors.vetBadge, dotSize: 8),
    );
    return _BubbleRow(fromMe: false, author: author, bubble: bubble);
  }
}

// ─────────────────────────────────────────────────────────────
// System divider (author joined)
// ─────────────────────────────────────────────────────────────

class _SystemDivider extends StatelessWidget {
  final String text;
  final DateTime? time;
  const _SystemDivider({required this.text, this.time});

  @override
  Widget build(BuildContext context) {
    final label = time != null ? '$text · ${_relativeTime(time!)}' : text;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.border, height: 1)),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(child: Divider(color: AppColors.border, height: 1)),
        ],
      ),
    );
  }
}

String _relativeTime(DateTime t) {
  final d = DateTime.now().difference(t);
  if (d.inMinutes < 1) return 'เมื่อสักครู่';
  if (d.inMinutes < 60) return '${d.inMinutes}m ago';
  if (d.inHours < 24) return '${d.inHours}h ago';
  return '${d.inDays}d ago';
}

// ─────────────────────────────────────────────────────────────
// Shared bubble row layout
// ─────────────────────────────────────────────────────────────

class _BubbleRow extends StatelessWidget {
  final bool fromMe;
  final Author author;
  final Widget bubble;
  final Widget? below;

  const _BubbleRow({
    required this.fromMe,
    required this.author,
    required this.bubble,
    this.below,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => openProfile(context, author),
      child: SeededAvatar(seed: author.avatarSeed, size: 32, role: author.role),
    );

    final nameRow = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => openProfile(context, author),
      child: Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                author.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (author.role == AuthorRole.vet) ...[
              const SizedBox(width: 4),
              const Icon(Icons.verified, size: 13, color: AppColors.vetBadge),
            ],
            if (author.specialty != null) ...[
              const SizedBox(width: 4),
              Text(
                '· ${author.specialty}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.vetBadge,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    final column = Column(
      crossAxisAlignment: fromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (!fromMe) nameRow,
        bubble,
        if (below != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4, right: 4),
            child: below!,
          ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: fromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!fromMe)
            Padding(padding: const EdgeInsets.only(right: 8), child: avatar),
          Flexible(child: column),
          if (fromMe)
            Padding(padding: const EdgeInsets.only(left: 8), child: avatar),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Live pulsing "LIVE" pill
// ─────────────────────────────────────────────────────────────

class _LiveDot extends StatefulWidget {
  const _LiveDot();
  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.1 + _c.value * 0.2),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.danger.withValues(alpha: 0.6 + _c.value * 0.4),
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'LIVE',
              style: TextStyle(
                color: AppColors.danger,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Activity ticker (above composer)
// ─────────────────────────────────────────────────────────────

class _ActivityTicker extends StatelessWidget {
  final _TickerItem item;
  const _ActivityTicker({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 8),
      color: item.accent.withValues(alpha: 0.08),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(anim),
            child: child,
          ),
        ),
        child: Text(
          item.text,
          key: ValueKey(item.text),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: item.accent,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Small rounded action pill (below bubbles)
// ─────────────────────────────────────────────────────────────

class _PillAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool highlight;
  final VoidCallback onTap;
  const _PillAction({
    required this.icon,
    required this.label,
    this.highlight = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = highlight ? AppColors.success : AppColors.textSecondary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: highlight ? AppColors.success.withValues(alpha: 0.1) : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: highlight
                  ? AppColors.success.withValues(alpha: 0.4)
                  : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Chat composer
// ─────────────────────────────────────────────────────────────

class _ChatComposer extends StatelessWidget {
  final TextEditingController controller;
  final bool hasText;
  final VoidCallback onSend;
  final VoidCallback onAnswerAsVet;
  const _ChatComposer({
    required this.controller,
    required this.hasText,
    required this.onSend,
    required this.onAnswerAsVet,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, 8, AppSpacing.md, 8),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              tooltip: 'Add attachment',
              onPressed: () {},
              icon: const Icon(Icons.add_circle_outline),
              color: AppColors.textSecondary,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        minLines: 1,
                        maxLines: 5,
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'ถามติดตามอาการ…',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Take a photo',
                      onPressed: () {},
                      icon: const Icon(Icons.camera_alt_outlined, size: 18),
                      color: AppColors.textSecondary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    ),
                    IconButton(
                      tooltip: 'Voice input',
                      onPressed: () {},
                      icon: const Icon(Icons.mic_none, size: 18),
                      color: AppColors.textSecondary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            if (hasText)
              Material(
                color: AppColors.primary,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: onSend,
                  customBorder: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.send, color: Colors.white, size: 18),
                  ),
                ),
              )
            else
              Material(
                color: AppColors.vetBadge.withValues(alpha: 0.12),
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: onAnswerAsVet,
                  customBorder: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.medical_services_outlined, color: AppColors.vetBadge, size: 18),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
