import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/mock_data.dart';
import '../models/consult_models.dart';
import '../theme/app_theme.dart';
import '../widgets/avatar.dart';
import '../widgets/live_atoms.dart';

/// Private 1:1 paid consult session between owner and expert.
/// Flow: Paywall → Chat → Expert closes → Confirm / Dispute.
/// AI never reads this thread (messages are private).
class PrivateConsultSessionScreen extends StatefulWidget {
  final Author expert;
  final int pricePerSession;
  final int minutesPerSession;
  const PrivateConsultSessionScreen({
    super.key,
    required this.expert,
    this.pricePerSession = 500,
    this.minutesPerSession = 30,
  });

  @override
  State<PrivateConsultSessionScreen> createState() =>
      _PrivateConsultSessionScreenState();
}

enum _SessionStage { paywall, chat, ended }

class _ChatMsg {
  final String body;
  final bool fromMe;
  final DateTime at;
  final String? attachment;
  const _ChatMsg(this.body, this.fromMe, this.at, {this.attachment});
}

class _PrivateConsultSessionScreenState
    extends State<PrivateConsultSessionScreen> {
  _SessionStage _stage = _SessionStage.paywall;
  final _composer = TextEditingController();
  bool _hasText = false;

  final List<_ChatMsg> _messages = [];

  @override
  void initState() {
    super.initState();
    _composer.addListener(() {
      final has = _composer.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  void _pay() {
    logActivity(ActivityEntry(
      type: ActivityType.privateConsult,
      title: 'Private Consult · ${widget.expert.name}',
      subtitle: '${widget.minutesPerSession} นาที · กำลังดำเนินการ',
      amount: '฿${widget.pricePerSession}',
      relatedAvatarSeed: widget.expert.avatarSeed,
      at: DateTime.now(),
    ));
    setState(() {
      _stage = _SessionStage.chat;
      _messages.add(_ChatMsg(
        'สวัสดีครับ ขอทราบอาการเพิ่มเติมได้ไหมครับ? แนบผล lab หรือ X-ray ได้เลยครับ',
        false,
        DateTime.now(),
      ));
    });
  }

  void _send() {
    final raw = _composer.text.trim();
    if (raw.isEmpty) return;
    setState(() {
      _messages.add(_ChatMsg(raw, true, DateTime.now()));
      _composer.clear();
    });
  }

  void _attach() {
    setState(() {
      _messages.add(_ChatMsg(
        'แนบไฟล์: lab-result.pdf',
        true,
        DateTime.now(),
        attachment: 'lab-result.pdf',
      ));
    });
  }

  Future<void> _expertClosesSession() async {
    setState(() => _stage = _SessionStage.ended);
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dctx) => AlertDialog(
        title: const Text('คุณหมอปิด session แล้ว'),
        content: const Text(
          'คุณพอใจกับคำปรึกษาครั้งนี้ไหม?\n'
          '• กด "ยืนยัน" เพื่อปิด session และชำระค่าบริการ\n'
          '• กด "Dispute" หากรู้สึกว่ายังไม่ได้รับคำตอบที่ชัดเจน',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dctx).pop();
              setState(() => _stage = _SessionStage.chat);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Dispute'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('ยืนยัน'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            SeededAvatar(
              seed: widget.expert.avatarSeed,
              size: 32,
              role: widget.expert.role,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.expert.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Row(
                    children: const [
                      Icon(Icons.lock_outline,
                          size: 11, color: AppColors.success),
                      SizedBox(width: 3),
                      Text(
                        'Private · AI ไม่อ่านห้องนี้',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: switch (_stage) {
        _SessionStage.paywall => _Paywall(
            expert: widget.expert,
            price: widget.pricePerSession,
            minutes: widget.minutesPerSession,
            onPay: _pay,
          ),
        _SessionStage.chat || _SessionStage.ended => _ChatView(
            messages: _messages,
            composer: _composer,
            hasText: _hasText,
            onSend: _send,
            onAttach: _attach,
            onExpertClose: _expertClosesSession,
            minutes: widget.minutesPerSession,
            ended: _stage == _SessionStage.ended,
          ),
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Paywall
// ─────────────────────────────────────────────────────────────

class _Paywall extends StatelessWidget {
  final Author expert;
  final int price;
  final int minutes;
  final VoidCallback onPay;
  const _Paywall({
    required this.expert,
    required this.price,
    required this.minutes,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.08),
                AppColors.accent.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border:
                Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              SeededAvatar(
                seed: expert.avatarSeed,
                size: 72,
                role: expert.role,
              ),
              const SizedBox(height: 10),
              Text(
                expert.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              if (expert.specialty != null) ...[
                const SizedBox(height: 2),
                Text(
                  '${expert.specialty}${expert.clinic != null ? ' · ${expert.clinic}' : ''}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.schedule,
                        size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      '฿$price / $minutes นาที',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const _InfoBullet(
          icon: Icons.chat_bubble_outline,
          text: 'แชท 1:1 กับ Expert · ส่งข้อความ + แนบรูป / ผล lab / X-ray',
        ),
        const _InfoBullet(
          icon: Icons.lock_outline,
          text: 'AI ไม่อ่านห้องนี้ · บทสนทนาเป็นส่วนตัวเต็มรูปแบบ',
        ),
        const _InfoBullet(
          icon: Icons.verified_outlined,
          text: 'Expert verified · มีใบประกอบวิชาชีพจริง',
        ),
        const _InfoBullet(
          icon: Icons.replay_outlined,
          text: 'คุณหมอปิด session → คุณยืนยัน/Dispute ก่อนตัดเงิน',
        ),
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onPay,
            icon: const Icon(Icons.lock_outline, size: 18),
            label: Text(
              'จ่าย ฿$price · เริ่ม Private Consult',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Center(
          child: Text(
            'ตัดเงินเมื่อ session ปิดและคุณยืนยันเท่านั้น',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _InfoBullet extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoBullet({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 15, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Chat view
// ─────────────────────────────────────────────────────────────

class _ChatView extends StatelessWidget {
  final List<_ChatMsg> messages;
  final TextEditingController composer;
  final bool hasText;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  final VoidCallback onExpertClose;
  final int minutes;
  final bool ended;

  const _ChatView({
    required this.messages,
    required this.composer,
    required this.hasText,
    required this.onSend,
    required this.onAttach,
    required this.onExpertClose,
    required this.minutes,
    required this.ended,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, 10, AppSpacing.lg, 10),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              const PulseDot(color: AppColors.success, size: 6),
              const SizedBox(width: 6),
              Text(
                'Session active · เหลือ ~$minutes นาที',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onExpertClose,
                icon: const Icon(Icons.stop_circle_outlined, size: 14),
                label: const Text('จำลอง: หมอปิด session',
                    style: TextStyle(fontSize: 11)),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 28),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: messages.length,
            itemBuilder: (_, i) => _Bubble(msg: messages[i]),
          ),
        ),
        if (!ended) _Composer(
          controller: composer,
          hasText: hasText,
          onSend: onSend,
          onAttach: onAttach,
        ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  final _ChatMsg msg;
  const _Bubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final fromMe = msg.fromMe;
    final bg = fromMe ? AppColors.primary : AppColors.surface;
    final fg = fromMe ? Colors.white : AppColors.textPrimary;
    final sub = fromMe ? Colors.white70 : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            fromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 300),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppRadius.lg),
                  topRight: const Radius.circular(AppRadius.lg),
                  bottomLeft: Radius.circular(fromMe ? AppRadius.lg : 4),
                  bottomRight: Radius.circular(fromMe ? 4 : AppRadius.lg),
                ),
                border: fromMe ? null : Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (msg.attachment != null) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.attach_file, size: 14, color: fg),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            msg.attachment!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: fg,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else
                    Text(
                      msg.body,
                      style: TextStyle(
                          fontSize: 14, color: fg, height: 1.45),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('HH:mm').format(msg.at),
                    style: TextStyle(fontSize: 10, color: sub),
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

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final bool hasText;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  const _Composer({
    required this.controller,
    required this.hasText,
    required this.onSend,
    required this.onAttach,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding:
            const EdgeInsets.fromLTRB(AppSpacing.md, 8, AppSpacing.md, 8),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              tooltip: 'แนบไฟล์ (ผล lab · X-ray · ใบวินิจฉัย)',
              onPressed: onAttach,
              icon: const Icon(Icons.attach_file),
              color: AppColors.textSecondary,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 5,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'พิมพ์ข้อความ…',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Material(
              color: hasText ? AppColors.primary : AppColors.border,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: hasText ? onSend : null,
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.send, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
