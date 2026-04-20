import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/mock_data.dart';
import '../models/consult_models.dart';
import '../theme/app_theme.dart';
import '../widgets/avatar.dart';
import 'followers_list_screen.dart';
import 'pet_detail_screen.dart';
import 'private_consult_session_screen.dart';
import 'question_chat_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Author author;
  final bool showBackButton;
  final VoidCallback? onLogout;
  final ValueChanged<Author>? onSwitchAccount;
  const ProfileScreen({
    super.key,
    required this.author,
    this.showBackButton = true,
    this.onLogout,
    this.onSwitchAccount,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Author _author;

  @override
  void initState() {
    super.initState();
    _author = widget.author;
  }

  bool get _isMe => _author.avatarSeed == currentUser.avatarSeed;

  Future<void> _openAccountSwitcher() async {
    final personas = <Author>[
      ownerWaew,
      vetSomchai,
      vetPloy,
      vetMana,
      brandRoyalCanin,
    ];
    final picked = await showModalBottomSheet<Author>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'สลับ Account (Demo)',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'ดูมุมมองของ persona แต่ละแบบ · ข้อมูลใช้ร่วมกัน',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ...personas.map((p) {
                final active = p.avatarSeed == _author.avatarSeed;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      onTap: active
                          ? null
                          : () => Navigator.of(context).pop(p),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primarySoft
                              : AppColors.surface,
                          borderRadius:
                              BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: active
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                        ),
                        child: Row(
                          children: [
                            SeededAvatar(
                              seed: p.avatarSeed,
                              size: 40,
                              role: p.role,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          p.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      if (p.verified) ...[
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.verified,
                                          size: 14,
                                          color: _roleColor(p.role),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_roleLabel(p.role)}${p.specialty != null ? ' · ${p.specialty}' : ''}${p.clinic != null ? ' · ${p.clinic}' : ''}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (active)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.pill),
                                ),
                                child: const Text(
                                  'ACTIVE',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              )
                            else
                              const Icon(Icons.chevron_right,
                                  color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
    if (picked != null) {
      widget.onSwitchAccount?.call(picked);
    }
  }

  Future<void> _openEdit() async {
    final updated = await showModalBottomSheet<Author>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => _EditProfileSheet(author: _author),
    );
    if (updated != null && mounted) {
      setState(() => _author = updated);
      if (_isMe) currentUser = updated;
    }
  }

  @override
  Widget build(BuildContext context) {
    final asked = questionsByAuthor(_author.avatarSeed);
    final given = answersByAuthor(_author.avatarSeed);
    final accepted = acceptedAnswersByAuthor(_author.avatarSeed);
    final followers = followerCountFor(_author.avatarSeed);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: widget.showBackButton,
        title: const Text('Profile'),
        actions: [
          if (_isMe && widget.onSwitchAccount != null)
            IconButton(
              tooltip: 'สลับ Account (Demo)',
              onPressed: _openAccountSwitcher,
              icon: const Icon(Icons.swap_horiz),
            ),
          IconButton(
            tooltip: 'Share profile',
            onPressed: () {},
            icon: const Icon(Icons.share_outlined),
          ),
          IconButton(
            tooltip: 'More options',
            onPressed: () {},
            icon: const Icon(Icons.more_horiz),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
        children: [
          _Header(
            author: _author,
            isMe: _isMe,
            onEdit: _openEdit,
          ),
          const SizedBox(height: AppSpacing.lg),
          _StatsRow(
            author: _author,
            asked: asked.length,
            given: given.length,
            accepted: accepted,
            followers: followers,
            onTapFollowers: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => FollowersListScreen(
                profile: _author,
                totalCount: followers,
              ),
            )),
          ),
          const SizedBox(height: AppSpacing.lg),
          ..._roleSections(context, asked: asked, given: given, accepted: accepted),
          if (_isMe && widget.onLogout != null) ...[
            const SizedBox(height: AppSpacing.xl),
            _LogoutButton(onLogout: () => _confirmLogout(context)),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('คุณต้องการออกจากระบบใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      widget.onLogout?.call();
    }
  }

  List<Widget> _roleSections(
    BuildContext context, {
    required List<Question> asked,
    required List<Answer> given,
    required int accepted,
  }) {
    switch (_author.role) {
      case AuthorRole.owner:
        return [
          if (_isMe) ...[
            _SectionLabel('My pets'),
            const SizedBox(height: AppSpacing.sm),
            _PetStrip(pets: currentUserPets),
            const SizedBox(height: AppSpacing.lg),
            _SectionLabel('Activity · ${myActivities.length}'),
            const SizedBox(height: AppSpacing.sm),
            if (myActivities.isEmpty)
              const _EmptyTile(text: 'ยังไม่มี activity จาก CTA ในแชท')
            else
              ...myActivities.take(8).map((e) => _ActivityTile(entry: e)),
            const SizedBox(height: AppSpacing.lg),
          ],
          _SectionLabel(_isMe ? 'Your recent questions' : 'Recent questions'),
          const SizedBox(height: AppSpacing.sm),
          if (asked.isEmpty)
            const _EmptyTile(text: 'No questions yet')
          else
            ...asked.map((q) => _QuestionTile(question: q)),
        ];
      case AuthorRole.vet:
        return [
          _VetCredentialCard(author: _author, accepted: accepted, totalAnswers: given.length),
          const SizedBox(height: AppSpacing.lg),
          _SectionLabel('Recent answers'),
          const SizedBox(height: AppSpacing.sm),
          if (given.isEmpty)
            const _EmptyTile(text: 'No answers yet')
          else
            ...given.take(5).map((a) => _AnswerTile(answer: a)),
        ];
      case AuthorRole.brand:
        return [
          _BrandCard(author: _author),
          const SizedBox(height: AppSpacing.lg),
          _SectionLabel('Sponsored answers'),
          const SizedBox(height: AppSpacing.sm),
          if (given.isEmpty)
            const _EmptyTile(text: 'No sponsored content yet')
          else
            ...given.map((a) => _AnswerTile(answer: a)),
        ];
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final Author author;
  final bool isMe;
  final VoidCallback? onEdit;
  const _Header({
    required this.author,
    required this.isMe,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final roleLabel = _roleLabel(author.role);
    final roleColor = _roleColor(author.role);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            roleColor.withValues(alpha: 0.08),
            AppColors.accent.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: roleColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SeededAvatar(seed: author.avatarSeed, size: 72, role: author.role),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            author.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (author.verified) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.verified, size: 18, color: roleColor),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: roleColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        roleLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: roleColor,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    if (author.clinic != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        author.clinic!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (author.bio != null && author.bio!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              author.bio!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          if (isMe)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit profile'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            )
          else if (author.role == AuthorRole.vet)
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PrivateConsultSessionScreen(
                          expert: author,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.lock_outline, size: 16),
                    label: const Text(
                      'ขอ Private Consult · ฿500 / 30 นาที',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_active_outlined,
                        size: 16),
                    label: const Text('Follow'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Follow'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.chat_bubble_outline, size: 16),
                    label: const Text('Message'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Stats row (role-aware)
// ─────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final Author author;
  final int asked;
  final int given;
  final int accepted;
  final int followers;
  final VoidCallback? onTapFollowers;
  const _StatsRow({
    required this.author,
    required this.asked,
    required this.given,
    required this.accepted,
    required this.followers,
    this.onTapFollowers,
  });

  @override
  Widget build(BuildContext context) {
    final items = <_Stat>[];
    switch (author.role) {
      case AuthorRole.owner:
        items.addAll([
          _Stat('Questions', '$asked', Icons.forum_outlined),
          _Stat('Pets', '${currentUserPets.length}', Icons.pets),
          _Stat(
            'Followers',
            _formatCompact(followers),
            Icons.people_outline,
            onTap: onTapFollowers,
          ),
        ]);
        break;
      case AuthorRole.vet:
        final rating = vetRatingFor(author.avatarSeed).toStringAsFixed(1);
        items.addAll([
          _Stat('Solutions', '$accepted', Icons.check_circle_outline, highlight: true),
          _Stat('Rating', '★ $rating', Icons.star_border),
          _Stat(
            'Followers',
            _formatCompact(followers),
            Icons.people_outline,
            onTap: onTapFollowers,
          ),
        ]);
        break;
      case AuthorRole.brand:
        items.addAll([
          _Stat('Sponsored', '$given', Icons.workspace_premium_outlined),
          _Stat('Products', '12', Icons.inventory_2_outlined),
          _Stat(
            'Followers',
            _formatCompact(followers),
            Icons.people_outline,
            onTap: onTapFollowers,
          ),
        ]);
        break;
    }

    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          Expanded(child: _StatTile(stat: items[i])),
          if (i < items.length - 1) const SizedBox(width: AppSpacing.sm),
        ],
      ],
    );
  }
}

String _formatCompact(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  return '$n';
}

class _Stat {
  final String label;
  final String value;
  final IconData icon;
  final bool highlight;
  final VoidCallback? onTap;
  const _Stat(
    this.label,
    this.value,
    this.icon, {
    this.highlight = false,
    this.onTap,
  });
}

class _StatTile extends StatelessWidget {
  final _Stat stat;
  const _StatTile({required this.stat});

  @override
  Widget build(BuildContext context) {
    final color = stat.highlight ? AppColors.success : AppColors.primary;
    final content = Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(stat.icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(
            stat.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            stat.label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    if (stat.onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: stat.onTap,
        child: Semantics(
          button: true,
          label: 'View ${stat.label}, ${stat.value}',
          child: content,
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onLogout;
  const _LogoutButton({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onLogout,
        icon: const Icon(Icons.logout, size: 18),
        label: const Text('Log out'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.danger,
          side: BorderSide(color: AppColors.danger.withValues(alpha: 0.4)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Role-specific sections
// ─────────────────────────────────────────────────────────────

class _VetCredentialCard extends StatelessWidget {
  final Author author;
  final int accepted;
  final int totalAnswers;
  const _VetCredentialCard({
    required this.author,
    required this.accepted,
    required this.totalAnswers,
  });

  @override
  Widget build(BuildContext context) {
    final solutionRate = totalAnswers == 0
        ? 0
        : ((accepted / totalAnswers) * 100).round();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.vetBadge.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified, size: 18, color: AppColors.vetBadge),
              const SizedBox(width: 6),
              const Text(
                'VERIFIED VET',
                style: TextStyle(
                  color: AppColors.vetBadge,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              const Spacer(),
              Text(
                '$solutionRate% solution rate',
                style: const TextStyle(
                  color: AppColors.success,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _CeoScoreRow(author: author),
          const SizedBox(height: 10),
          _SpecialtyTagsRow(author: author),
          const SizedBox(height: 10),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 10),
          _CredentialRow(
            icon: Icons.local_hospital_outlined,
            label: 'Clinic',
            value: author.clinic ?? '—',
          ),
          const SizedBox(height: 8),
          _CredentialRow(
            icon: Icons.medical_services_outlined,
            label: 'Specialty',
            value: author.specialty ?? '—',
          ),
          const SizedBox(height: 8),
          _SpeciesTreatedRow(species: author.treatsSpecies),
          const SizedBox(height: 8),
          _CredentialRow(
            icon: Icons.schedule_outlined,
            label: 'Consult hours',
            value: 'Mon–Fri · 9:00–18:00',
          ),
          const SizedBox(height: 8),
          _CredentialRow(
            icon: Icons.videocam_outlined,
            label: 'Telemet',
            value: 'Available · ฿500 / 30 min',
          ),
        ],
      ),
    );
  }
}

class _CeoScoreRow extends StatelessWidget {
  final Author author;
  const _CeoScoreRow({required this.author});

  @override
  Widget build(BuildContext context) {
    final primaryTag = author.specialty ?? 'General';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.accent.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.auto_awesome,
                color: Colors.white, size: 15),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CEO Score · Consult Engine Optimization',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Top 5% · $primaryTag',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: const Text(
              '94',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecialtyTagsRow extends StatelessWidget {
  final Author author;
  const _SpecialtyTagsRow({required this.author});

  @override
  Widget build(BuildContext context) {
    // Mock AI-generated tags based on author seed — in production comes from CEO.
    final tagSets = <String, List<String>>{
      'somchai': ['อ้วก/ท้องเสีย', 'โรคทางเดินอาหาร', 'ฉุกเฉิน'],
      'ploy': ['ผิวหนัง', 'โรคภูมิแพ้', 'ขนร่วง'],
      'mana': ['โภชนาการ', 'ลูกสุนัข', 'อาหารเสริม'],
    };
    final tags = tagSets[author.avatarSeed] ??
        const ['ทั่วไป', 'ตรวจสุขภาพ'];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.sell_outlined,
            size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        const SizedBox(
          width: 82,
          child: Text(
            'AI tags',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: tags
                .map((t) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        t,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _SpeciesTreatedRow extends StatelessWidget {
  final List<String> species;
  const _SpeciesTreatedRow({required this.species});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.pets, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        const SizedBox(
          width: 90,
          child: Text(
            'สายพันธุ์ที่รักษา',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: species.isEmpty
              ? const Text(
                  '—',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: species
                      .map((s) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.pill),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_speciesEmoji(s),
                                    style: const TextStyle(fontSize: 12)),
                                const SizedBox(width: 4),
                                Text(
                                  s,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
        ),
      ],
    );
  }
}

class _CredentialRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _CredentialRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _BrandCard extends StatelessWidget {
  final Author author;
  const _BrandCard({required this.author});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.brandBadge.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.workspace_premium, size: 18, color: AppColors.brandBadge),
              SizedBox(width: 6),
              Text(
                'VERIFIED PARTNER',
                style: TextStyle(
                  color: AppColors.brandBadge,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Official partner in Pet Nutrition. Sponsored answers are reviewed by in-house veterinary nutritionists.',
            style: TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.5),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.storefront_outlined, size: 16),
              label: const Text('Visit official store'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.brandBadge,
                side: const BorderSide(color: AppColors.brandBadge),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Pet strip (for owner)
// ─────────────────────────────────────────────────────────────

class _PetStrip extends StatelessWidget {
  final List<Pet> pets;
  const _PetStrip({required this.pets});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: pets.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          final p = pets[i];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.md),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => PetDetailScreen(pet: p),
              )),
              child: Semantics(
                button: true,
                label:
                    '${p.name}, ${p.species}, ${p.breed}, ${p.ageMonths} months old. Tap to view profile.',
                child: Container(
            width: 140,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                SeededAvatar(seed: p.avatarSeed, size: 44),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        p.breed,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${p.species} · ${p.ageMonths}m',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Tiles
// ─────────────────────────────────────────────────────────────

class _QuestionTile extends StatelessWidget {
  final Question question;
  const _QuestionTile({required this.question});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => QuestionChatScreen(question: question),
          )),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: question.category.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(question.category.emoji, style: const TextStyle(fontSize: 16)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            DateFormat('d MMM').format(question.postedAt),
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.chat_bubble_outline,
                              size: 12,
                              color: question.hasAcceptedAnswer ? AppColors.success : AppColors.textSecondary),
                          const SizedBox(width: 3),
                          Text(
                            '${question.answerCount}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: question.hasAcceptedAnswer ? AppColors.success : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (question.hasAcceptedAnswer)
                  const Icon(Icons.check_circle, size: 16, color: AppColors.success),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnswerTile extends StatelessWidget {
  final Answer answer;
  const _AnswerTile({required this.answer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: answer.accepted
                ? AppColors.success.withValues(alpha: 0.4)
                : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  answer.accepted ? Icons.check_circle : Icons.chat_bubble_outline,
                  size: 14,
                  color: answer.accepted ? AppColors.success : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  answer.accepted ? 'Accepted solution' : 'Answer',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: answer.accepted ? AppColors.success : AppColors.textSecondary,
                    letterSpacing: 0.4,
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('d MMM').format(answer.postedAt),
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              answer.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, height: 1.45, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.thumb_up_alt_outlined, size: 12, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${answer.upvotes}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final ActivityEntry entry;
  const _ActivityTile({required this.entry});

  String _relative(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'เมื่อสักครู่';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    if (d.inDays < 7) return '${d.inDays}d ago';
    return DateFormat('d MMM').format(t);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: entry.type.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(entry.type.icon,
                  size: 17, color: entry.type.color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: entry.type.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          entry.type.label.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: entry.type.color,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _relative(entry.at),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    entry.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (entry.amount != null) ...[
              const SizedBox(width: 8),
              Text(
                entry.amount!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: entry.type.color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyTile extends StatelessWidget {
  final String text;
  const _EmptyTile({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl, horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: 0.2,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────

String _roleLabel(AuthorRole role) {
  switch (role) {
    case AuthorRole.owner:
      return 'PAWRENT';
    case AuthorRole.vet:
      return 'VETERINARIAN';
    case AuthorRole.brand:
      return 'BRAND PARTNER';
  }
}

Color _roleColor(AuthorRole role) {
  switch (role) {
    case AuthorRole.owner:
      return AppColors.primary;
    case AuthorRole.vet:
      return AppColors.vetBadge;
    case AuthorRole.brand:
      return AppColors.brandBadge;
  }
}

void openProfile(BuildContext context, Author author) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => ProfileScreen(author: author),
  ));
}

// ─────────────────────────────────────────────────────────────
// Edit profile sheet
// ─────────────────────────────────────────────────────────────

class _EditProfileSheet extends StatefulWidget {
  final Author author;
  const _EditProfileSheet({required this.author});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _clinicCtrl;
  late final TextEditingController _specialtyCtrl;
  late final Set<String> _species;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.author.name);
    _bioCtrl = TextEditingController(text: widget.author.bio ?? '');
    _clinicCtrl = TextEditingController(text: widget.author.clinic ?? '');
    _specialtyCtrl =
        TextEditingController(text: widget.author.specialty ?? '');
    _species = {...widget.author.treatsSpecies};
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _clinicCtrl.dispose();
    _specialtyCtrl.dispose();
    super.dispose();
  }

  bool get _canSave => _nameCtrl.text.trim().isNotEmpty;

  void _save() {
    final updated = widget.author.copyWith(
      name: _nameCtrl.text.trim(),
      bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
      clinic: _clinicCtrl.text.trim().isEmpty ? null : _clinicCtrl.text.trim(),
      specialty: _specialtyCtrl.text.trim().isEmpty
          ? null
          : _specialtyCtrl.text.trim(),
      treatsSpecies: _species.toList(),
    );
    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets;
    final isVet = widget.author.role == AuthorRole.vet;
    return Padding(
      padding: EdgeInsets.only(bottom: insets.bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  SeededAvatar(
                    seed: widget.author.avatarSeed,
                    size: 40,
                    role: widget.author.role,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Text(
                    'Edit profile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const _FormLabel('Display name'),
              const SizedBox(height: 6),
              TextField(
                controller: _nameCtrl,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(hintText: 'Your name'),
              ),
              const SizedBox(height: AppSpacing.md),
              const _FormLabel('Bio'),
              const SizedBox(height: 6),
              TextField(
                controller: _bioCtrl,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'แนะนำตัวสั้นๆ ให้คนอื่นรู้จัก',
                ),
              ),
              if (isVet) ...[
                const SizedBox(height: AppSpacing.md),
                const _FormLabel('Clinic'),
                const SizedBox(height: 6),
                TextField(
                  controller: _clinicCtrl,
                  decoration:
                      const InputDecoration(hintText: 'Clinic / hospital'),
                ),
                const SizedBox(height: AppSpacing.md),
                const _FormLabel('Specialty'),
                const SizedBox(height: 6),
                TextField(
                  controller: _specialtyCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'เลือก preset หรือพิมพ์เพิ่มเอง',
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: vetSpecialtyPresets.map((p) {
                    final active =
                        _specialtyCtrl.text.trim().toLowerCase() ==
                            p.toLowerCase();
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        onTap: () => setState(() {
                          _specialtyCtrl.text = p;
                          _specialtyCtrl.selection = TextSelection.collapsed(
                              offset: p.length);
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.primary
                                : AppColors.surface,
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                            border: Border.all(
                              color: active
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          child: Text(
                            p,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: active
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    const _FormLabel('สายพันธุ์ที่รักษา'),
                    const SizedBox(width: 6),
                    Text(
                      '${_species.length} เลือก',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: speciesMasterData.map((s) {
                    final selected = _species.contains(s);
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        onTap: () => setState(() {
                          if (selected) {
                            _species.remove(s);
                          } else {
                            _species.add(s);
                          }
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary
                                : AppColors.surface,
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_speciesEmoji(s),
                                  style: const TextStyle(fontSize: 13)),
                              const SizedBox(width: 5),
                              Text(
                                s,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: selected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                              ),
                              if (selected) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.check,
                                    size: 13, color: Colors.white),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _canSave ? _save : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _canSave ? AppColors.primary : AppColors.border,
                        foregroundColor:
                            _canSave ? Colors.white : AppColors.textSecondary,
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _speciesEmoji(String s) {
  switch (s) {
    case 'Dog':
      return '🐶';
    case 'Cat':
      return '🐱';
    case 'Rabbit':
      return '🐰';
    case 'Bird':
      return '🦜';
    case 'Fish':
      return '🐠';
    case 'Reptile':
      return '🦎';
    default:
      return '🐾';
  }
}

class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
      ),
    );
  }
}

