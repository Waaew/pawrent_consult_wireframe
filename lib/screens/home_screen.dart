import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/mock_data.dart';
import '../models/consult_models.dart';
import '../theme/app_theme.dart';
import '../widgets/avatar.dart';
import '../widgets/live_atoms.dart';
import 'pet_detail_screen.dart';
import 'post_question_screen.dart';
import 'profile_screen.dart';
import 'question_chat_screen.dart';
import 'question_list_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToProfile;
  const HomeScreen({super.key, this.onNavigateToProfile});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _openAddPet() async {
    final newPet = await showModalBottomSheet<Pet>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => const _AddPetSheet(),
    );
    if (newPet != null && mounted) {
      setState(() => myPets.add(newPet));
    }
  }

  Future<void> _openAsk() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PostQuestionScreen()),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final me = currentUser;
    final asked = questionsByAuthor(me.avatarSeed);
    final given = answersByAuthor(me.avatarSeed);
    final accepted = acceptedAnswersByAuthor(me.avatarSeed);
    final followedVets = [vetSomchai, vetPloy, vetMana];
    final isVet = me.role == AuthorRole.vet;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          children: [
            _HeroGreeting(
              author: me,
              onTapAvatar: widget.onNavigateToProfile,
            ),
            const SizedBox(height: AppSpacing.md),
            _DashboardStats(
              author: me,
              asked: asked.length,
              given: given.length,
              accepted: accepted,
              onTapQuestions: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => QuestionListScreen(
                  title: 'Your questions',
                  questions: asked,
                  emptyText: 'ยังไม่เคยถามคำถาม',
                ),
              )),
              onTapAnswered: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => QuestionListScreen(
                  title: 'Answered',
                  questions: asked.where((q) => q.hasAcceptedAnswer).toList(),
                  emptyText: 'ยังไม่มีคำถามที่ได้รับคำตอบ',
                ),
              )),
            ),
            const SizedBox(height: AppSpacing.md),
            if (isVet) ...[
              _VetEarningsCard(author: me),
              const SizedBox(height: AppSpacing.lg),
              _SectionHeader(
                title: 'คำขอ Private Consult',
                count: _mockConsultRequests.length,
              ),
              const SizedBox(height: AppSpacing.sm),
              ..._mockConsultRequests.map(
                (r) => _ConsultRequestCard(request: r),
              ),
              const SizedBox(height: AppSpacing.lg),
              _SectionHeader(
                title: 'คำถามในห้องที่ควรตอบ',
                count: _suggestedForVet(me).length,
              ),
              const SizedBox(height: AppSpacing.sm),
              ..._suggestedForVet(me)
                  .take(3)
                  .map((q) => _RecentQuestionCard(question: q)),
            ] else ...[
              _AskVetHero(onTap: _openAsk),
              const SizedBox(height: AppSpacing.lg),
              _SectionHeader(title: 'Your pets', count: myPets.length),
              const SizedBox(height: AppSpacing.sm),
              _PetsStrip(pets: myPets, onAddPet: _openAddPet),
              const SizedBox(height: AppSpacing.lg),
              _SectionHeader(title: 'Recent questions', count: asked.length),
              const SizedBox(height: AppSpacing.sm),
              if (asked.isEmpty)
                const _EmptyCard(
                  icon: Icons.help_outline,
                  text: 'ยังไม่เคยถามคำถาม · กด Ask เพื่อเริ่ม',
                )
              else
                ...asked.take(3).map((q) => _RecentQuestionCard(question: q)),
              const SizedBox(height: AppSpacing.lg),
              _SectionHeader(
                  title: 'Verified experts', count: followedVets.length),
              const SizedBox(height: AppSpacing.sm),
              _VetList(vets: followedVets),
            ],
          ],
        ),
      ),
    );
  }
}

List<Question> _suggestedForVet(Author vet) =>
    mockQuestions.where((q) => !q.hasAcceptedAnswer).toList();

// ─────────────────────────────────────────────────────────────
// Hero greeting (avatar tappable → Profile tab)
// ─────────────────────────────────────────────────────────────

class _HeroGreeting extends StatelessWidget {
  final Author author;
  final VoidCallback? onTapAvatar;
  const _HeroGreeting({required this.author, this.onTapAvatar});

  @override
  Widget build(BuildContext context) {
    final firstName = author.name.split(' ').first;
    return Row(
      children: [
        Semantics(
          button: true,
          label: 'Open profile',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTapAvatar,
            child: Tooltip(
              message: 'Open profile',
              child: SeededAvatar(seed: author.avatarSeed, size: 44, role: author.role),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'สวัสดี, $firstName 👋',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 1),
              Row(
                children: [
                  const PulseDot(color: AppColors.success, size: 5),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      myPets.isEmpty
                          ? 'Ready to help your pets'
                          : myPets.length == 1
                              ? '${myPets.first.name} พร้อมรับคำปรึกษา'
                              : '${myPets.first.name} และอีก ${myPets.length - 1} ตัว',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        _CoinBadge(
          balance: 320,
          onTap: () => openCoinSheet(context, author),
        ),
        const SizedBox(width: 4),
        IconButton(
          tooltip: 'Notifications',
          onPressed: () => openNotificationsSheet(context, author),
          icon: Stack(
            clipBehavior: Clip.none,
            children: const [
              Icon(Icons.notifications_outlined),
              Positioned(
                right: -2,
                top: -2,
                child: CircleAvatar(
                  radius: 4,
                  backgroundColor: AppColors.danger,
                ),
              ),
            ],
          ),
          color: AppColors.textSecondary,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}

class _CoinBadge extends StatelessWidget {
  final int balance;
  final VoidCallback onTap;
  const _CoinBadge({required this.balance, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🪙', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 4),
              Text(
                '$balance',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.warning,
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
// Dashboard stats (big numbers)
// ─────────────────────────────────────────────────────────────

class _DashboardStats extends StatelessWidget {
  final Author author;
  final int asked;
  final int given;
  final int accepted;
  final VoidCallback? onTapQuestions;
  final VoidCallback? onTapAnswered;
  const _DashboardStats({
    required this.author,
    required this.asked,
    required this.given,
    required this.accepted,
    this.onTapQuestions,
    this.onTapAnswered,
  });

  @override
  Widget build(BuildContext context) {
    final isVet = author.role == AuthorRole.vet;
    final items = isVet
        ? <_DashStat>[
            _DashStat('Answers', '$given', Icons.reply_outlined, AppColors.primary),
            _DashStat('Solutions', '$accepted', Icons.check_circle_outline, AppColors.success),
            _DashStat('Verified', author.verified ? 'Yes' : 'No', Icons.verified, AppColors.vetBadge),
          ]
        : <_DashStat>[
            _DashStat(
              'Questions',
              '$asked',
              Icons.forum_outlined,
              AppColors.primary,
              onTap: onTapQuestions,
            ),
            _DashStat(
              'Answered',
              '${questionsByAuthor(author.avatarSeed).where((q) => q.hasAcceptedAnswer).length}',
              Icons.check_circle_outline,
              AppColors.success,
              onTap: onTapAnswered,
            ),
            _DashStat(
              'Verified',
              author.verified ? 'Yes' : 'No',
              Icons.verified,
              author.verified
                  ? AppColors.vetBadge
                  : AppColors.textSecondary,
            ),
          ];

    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          Expanded(child: _DashStatCard(stat: items[i])),
          if (i < items.length - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class _DashStat {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const _DashStat(this.label, this.value, this.icon, this.color, {this.onTap});
}

class _DashStatCard extends StatelessWidget {
  final _DashStat stat;
  const _DashStatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: stat.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(stat.icon, size: 14, color: stat.color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.1,
                  ),
                ),
                Text(
                  stat.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (stat.onTap != null)
            const Icon(Icons.chevron_right, size: 14, color: AppColors.textSecondary),
        ],
      ),
    );

    if (stat.onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
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

// ─────────────────────────────────────────────────────────────
// Ask Vet hero — prominent standalone module
// ─────────────────────────────────────────────────────────────

class _AskVetHero extends StatelessWidget {
  final VoidCallback onTap;
  const _AskVetHero({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.accent],
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'ขอ Second Opinion ได้เลย',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Expert verified ตอบใน ~3 นาที',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Ask',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, color: AppColors.primary, size: 14),
                  ],
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
// Section header
// ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final int? count;
  const _SectionHeader({required this.title, this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Pets strip + Add pet
// ─────────────────────────────────────────────────────────────

class _PetsStrip extends StatelessWidget {
  final List<Pet> pets;
  final VoidCallback onAddPet;
  const _PetsStrip({required this.pets, required this.onAddPet});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: pets.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          if (i == pets.length) return _AddPetTile(onTap: onAddPet);
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
                  width: 110,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SeededAvatar(seed: p.avatarSeed, size: 30),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              p.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        p.breed,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
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
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AddPetTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddPetTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Add a new pet',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onTap,
          child: Container(
            width: 84,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.add_circle_outline, size: 22, color: AppColors.primary),
                SizedBox(height: 4),
                Text(
                  'Add pet',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Add pet sheet
// ─────────────────────────────────────────────────────────────

class _AddPetSheet extends StatefulWidget {
  const _AddPetSheet();

  @override
  State<_AddPetSheet> createState() => _AddPetSheetState();
}

class _AddPetSheetState extends State<_AddPetSheet> {
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController(text: '0');
  String _species = speciesMasterData.first;
  String? _breed;

  static String _speciesEmoji(String species) {
    switch (species) {
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

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _nameCtrl.text.trim().isNotEmpty && _breed != null && _breed!.isNotEmpty;

  void _save() {
    final pet = Pet(
      name: _nameCtrl.text.trim(),
      breed: _breed ?? 'Other',
      species: _species,
      ageMonths: int.tryParse(_ageCtrl.text.trim()) ?? 0,
      avatarSeed: 'pet-${DateTime.now().millisecondsSinceEpoch}',
    );
    Navigator.of(context).pop(pet);
  }

  void _onSpeciesChanged(String species) {
    setState(() {
      _species = species;
      _breed = null;
    });
  }

  Future<void> _pickBreed() async {
    final breeds = breedsBySpecies[_species] ?? const ['Other'];
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => _BreedPickerSheet(species: _species, breeds: breeds),
    );
    if (selected != null) setState(() => _breed = selected);
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets;
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
              const Text(
                'Add a pet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const _FieldLabel('Name'),
              const SizedBox(height: 6),
              TextField(
                controller: _nameCtrl,
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(hintText: 'Luna, Moji…'),
              ),
              const SizedBox(height: AppSpacing.md),
              const _FieldLabel('Species'),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: speciesMasterData.map((s) {
                  final selected = _species == s;
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      onTap: () => _onSpeciesChanged(s),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(
                            color: selected ? AppColors.primary : AppColors.border,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_speciesEmoji(s), style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              s,
                              style: TextStyle(
                                color: selected ? Colors.white : AppColors.textSecondary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.md),
              const _FieldLabel('Breed'),
              const SizedBox(height: 6),
              Semantics(
                button: true,
                label: 'Select breed',
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  onTap: _pickBreed,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _breed ?? 'เลือกสายพันธุ์…',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _breed == null
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const Icon(Icons.expand_more, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const _FieldLabel('Age (months)'),
              const SizedBox(height: 6),
              TextField(
                controller: _ageCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: '0'),
              ),
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
                      child: const Text('Save pet'),
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

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

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

class _BreedPickerSheet extends StatefulWidget {
  final String species;
  final List<String> breeds;
  const _BreedPickerSheet({required this.species, required this.breeds});

  @override
  State<_BreedPickerSheet> createState() => _BreedPickerSheetState();
}

class _BreedPickerSheetState extends State<_BreedPickerSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<String> get _filtered {
    if (_query.trim().isEmpty) return widget.breeds;
    final q = _query.trim().toLowerCase();
    return widget.breeds.where((b) => b.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: media.size.height * 0.75),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.md),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'เลือกสายพันธุ์ · ${widget.species}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: const InputDecoration(
                    hintText: 'ค้นหาสายพันธุ์…',
                    prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Flexible(
                child: _filtered.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: Text(
                          'ไม่พบสายพันธุ์ที่ตรงกับคำค้นหา',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, color: AppColors.border),
                        itemBuilder: (_, i) {
                          final b = _filtered[i];
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Navigator.of(context).pop(b),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                child: Row(
                                  children: [
                                    const Icon(Icons.pets, size: 16, color: AppColors.textSecondary),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        b,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
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
// Recent question
// ─────────────────────────────────────────────────────────────

class _RecentQuestionCard extends StatelessWidget {
  final Question question;
  const _RecentQuestionCard({required this.question});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => QuestionChatScreen(question: question),
          )),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: question.category.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: Text(question.category.emoji, style: const TextStyle(fontSize: 15)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            question.hasAcceptedAnswer ? Icons.check_circle : Icons.schedule,
                            size: 11,
                            color: question.hasAcceptedAnswer ? AppColors.success : AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            question.hasAcceptedAnswer ? 'Solved' : 'Awaiting vet',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: question.hasAcceptedAnswer ? AppColors.success : AppColors.warning,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '· ${DateFormat('d MMM').format(question.postedAt)}',
                            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Vet list
// ─────────────────────────────────────────────────────────────

class _VetList extends StatelessWidget {
  final List<Author> vets;
  const _VetList({required this.vets});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final v in vets) _VetRow(vet: v),
      ],
    );
  }
}

class _VetRow extends StatelessWidget {
  final Author vet;
  const _VetRow({required this.vet});

  @override
  Widget build(BuildContext context) {
    final rating = vetRatingFor(vet.avatarSeed).toStringAsFixed(1);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: () => openProfile(context, vet),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                SeededAvatar(seed: vet.avatarSeed, size: 36, role: vet.role),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              vet.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, size: 12, color: AppColors.vetBadge),
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${vet.specialty} · ${vet.clinic}',
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 10, color: AppColors.warning),
                      const SizedBox(width: 2),
                      Text(
                        rating,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.warning,
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
  }
}

// ─────────────────────────────────────────────────────────────
// Empty card
// ─────────────────────────────────────────────────────────────

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String text;
  const _EmptyCard({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Vet-only: earnings card + paid consult requests
// ─────────────────────────────────────────────────────────────

class _ConsultRequest {
  final Author owner;
  final Pet pet;
  final String summary;
  final int price;
  final DateTime requestedAt;
  const _ConsultRequest({
    required this.owner,
    required this.pet,
    required this.summary,
    required this.price,
    required this.requestedAt,
  });
}

final _mockConsultRequests = <_ConsultRequest>[
  _ConsultRequest(
    owner: ownerWaew,
    pet: myPets[0],
    summary: 'โมจิอ้วกต่อเนื่อง อยากขอ Second Opinion เร่งด่วน',
    price: 500,
    requestedAt: DateTime.now().subtract(const Duration(minutes: 8)),
  ),
  _ConsultRequest(
    owner: ownerMint,
    pet: myPets[1],
    summary: 'Luna ขนร่วงเป็นหย่อม อยากตรวจเพิ่ม',
    price: 500,
    requestedAt: DateTime.now().subtract(const Duration(hours: 1)),
  ),
  _ConsultRequest(
    owner: ownerNick,
    pet: myPets[0],
    summary: 'ขอคำแนะนำเรื่องอาหารลูกสุนัข',
    price: 500,
    requestedAt: DateTime.now().subtract(const Duration(hours: 4)),
  ),
];

class _VetEarningsCard extends StatelessWidget {
  final Author author;
  const _VetEarningsCard({required this.author});

  @override
  Widget build(BuildContext context) {
    // Mock earnings derived from seed for demo variance
    final base = author.avatarSeed.codeUnits.fold<int>(0, (a, b) => a + b);
    final monthTotal = 12500 + (base % 9) * 1500;
    final pendingPayout = 3500 + (base % 5) * 500;
    final sessions = 12 + (base % 8);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.accent],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.savings_outlined,
                  color: Colors.white, size: 18),
              const SizedBox(width: 6),
              const Text(
                'ยอดรายได้เดือนนี้',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  '$sessions sessions',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '฿${_fmtMoney(monthTotal)}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule,
                    size: 13, color: Colors.white70),
                const SizedBox(width: 6),
                Text(
                  'รอโอน ฿${_fmtMoney(pendingPayout)} · โอน 25 ${_thaiMonth(DateTime.now().month)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _fmtMoney(int v) {
    final s = v.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }

  static String _thaiMonth(int m) {
    const mm = [
      'ม.ค.','ก.พ.','มี.ค.','เม.ย.','พ.ค.','มิ.ย.',
      'ก.ค.','ส.ค.','ก.ย.','ต.ค.','พ.ย.','ธ.ค.',
    ];
    return mm[(m - 1).clamp(0, 11)];
  }
}

// ─────────────────────────────────────────────────────────────
// Notifications sheet — events where others interacted with me
// ─────────────────────────────────────────────────────────────

class _NotifEvent {
  final String title;
  final String body;
  final IconData icon;
  final Color color;
  final String avatarSeed;
  final DateTime at;
  const _NotifEvent({
    required this.title,
    required this.body,
    required this.icon,
    required this.color,
    required this.avatarSeed,
    required this.at,
  });
}

List<_NotifEvent> _notificationsFor(Author me) {
  if (me.role == AuthorRole.vet) {
    return [
      _NotifEvent(
        title: 'ลูกค้าใหม่ขอ Private Consult',
        body: '${ownerWaew.name} · เรื่องโมจิอ้วก · ฿500',
        icon: Icons.lock_outline,
        color: AppColors.primary,
        avatarSeed: ownerWaew.avatarSeed,
        at: DateTime.now().subtract(const Duration(minutes: 8)),
      ),
      _NotifEvent(
        title: 'คำตอบของคุณถูก Accept',
        body: '${ownerWaew.name} accept "อ้วก 3 ครั้ง…" · +50 coin',
        icon: Icons.check_circle,
        color: AppColors.success,
        avatarSeed: ownerWaew.avatarSeed,
        at: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      _NotifEvent(
        title: '12 คน upvote คำตอบของคุณ',
        body: '"เลียขนเยอะ…" · trending ในหมวด Behavior',
        icon: Icons.thumb_up_alt_outlined,
        color: AppColors.vetBadge,
        avatarSeed: ownerMint.avatarSeed,
        at: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      _NotifEvent(
        title: 'Telemet booking ใหม่',
        body: '${ownerNick.name} · Thu 24 เม.ย. 10:30',
        icon: Icons.videocam_outlined,
        color: AppColors.primary,
        avatarSeed: ownerNick.avatarSeed,
        at: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ];
  }
  return [
    _NotifEvent(
      title: '${vetSomchai.name} ตอบคำถามของคุณ',
      body: '"โมจิอ้วก 3 ครั้ง…" · กดดูคำตอบ',
      icon: Icons.reply,
      color: AppColors.primary,
      avatarSeed: vetSomchai.avatarSeed,
      at: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
    _NotifEvent(
      title: '${vetPloy.name} กำลังพิมพ์คำตอบ',
      body: 'ในคำถาม "เลียขนเยอะ…"',
      icon: Icons.edit_note,
      color: AppColors.vetBadge,
      avatarSeed: vetPloy.avatarSeed,
      at: DateTime.now().subtract(const Duration(minutes: 32)),
    ),
    _NotifEvent(
      title: '3 คน upvote คำถามของคุณ',
      body: '"โมจิอ้วก 3 ครั้ง…" · trending ในหมวด Health',
      icon: Icons.thumb_up_alt_outlined,
      color: AppColors.success,
      avatarSeed: ownerMint.avatarSeed,
      at: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    _NotifEvent(
      title: 'Royal Canin ตอบเสริมคำถามของคุณ',
      body: 'แนะนำ Maxi Puppy · Sponsored',
      icon: Icons.workspace_premium,
      color: AppColors.accent,
      avatarSeed: brandRoyalCanin.avatarSeed,
      at: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];
}

Future<void> openNotificationsSheet(
    BuildContext context, Author me) async {
  final events = _notificationsFor(me);
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (_) => SafeArea(
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
                const Icon(Icons.notifications_outlined,
                    color: AppColors.primary),
                const SizedBox(width: 6),
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('อ่านทั้งหมด'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ...events.map((e) => _NotifTile(event: e)),
          ],
        ),
      ),
    ),
  );
}

class _NotifTile extends StatelessWidget {
  final _NotifEvent event;
  const _NotifTile({required this.event});

  String _rel(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'now';
    if (d.inMinutes < 60) return '${d.inMinutes}m';
    if (d.inHours < 24) return '${d.inHours}h';
    return '${d.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                SeededAvatar(seed: event.avatarSeed, size: 36),
                Positioned(
                  right: -3,
                  bottom: -3,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: event.color,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: AppColors.surface, width: 1.5),
                    ),
                    child: Icon(event.icon, size: 10, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
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
                    event.body,
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
            Text(
              _rel(event.at),
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Coin sheet — transactions tied to activity sources
// ─────────────────────────────────────────────────────────────

class _CoinTx {
  final String title;
  final String source;
  final int delta; // + earn, − spend
  final IconData icon;
  final DateTime at;
  const _CoinTx({
    required this.title,
    required this.source,
    required this.delta,
    required this.icon,
    required this.at,
  });
}

List<_CoinTx> _coinTxFor(Author me) {
  if (me.role == AuthorRole.vet) {
    return [
      _CoinTx(
        title: '+฿500',
        source: 'Private Consult · ${ownerWaew.name}',
        delta: 500,
        icon: Icons.lock_outline,
        at: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      _CoinTx(
        title: '+฿500',
        source: 'Telemet booking · ${ownerNick.name}',
        delta: 500,
        icon: Icons.videocam_outlined,
        at: DateTime.now().subtract(const Duration(days: 1)),
      ),
      _CoinTx(
        title: '+฿50',
        source: 'Accepted answer bonus',
        delta: 50,
        icon: Icons.check_circle,
        at: DateTime.now().subtract(const Duration(days: 2)),
      ),
      _CoinTx(
        title: '−฿250',
        source: 'Platform fee (5%)',
        delta: -250,
        icon: Icons.percent,
        at: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }
  return [
    _CoinTx(
      title: '+50 coins',
      source: 'Accept คำตอบของ Dr. Somchai',
      delta: 50,
      icon: Icons.check_circle,
      at: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    _CoinTx(
      title: '+20 coins',
      source: 'ตั้งคำถาม "โมจิอ้วก 3 ครั้ง"',
      delta: 20,
      icon: Icons.forum_outlined,
      at: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    _CoinTx(
      title: '−500 coins',
      source: 'Private Consult · Dr. Somchai',
      delta: -500,
      icon: Icons.lock_outline,
      at: DateTime.now().subtract(const Duration(days: 5)),
    ),
    _CoinTx(
      title: '+300 coins',
      source: 'Weekly bonus · active user',
      delta: 300,
      icon: Icons.star_border,
      at: DateTime.now().subtract(const Duration(days: 7)),
    ),
    _CoinTx(
      title: '+100 coins',
      source: 'Welcome bonus',
      delta: 100,
      icon: Icons.card_giftcard,
      at: DateTime.now().subtract(const Duration(days: 30)),
    ),
  ];
}

Future<void> openCoinSheet(BuildContext context, Author me) async {
  final txs = _coinTxFor(me);
  final balance = txs.fold<int>(0, (a, t) => a + t.delta).abs();
  final isVet = me.role == AuthorRole.vet;
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (_) => SafeArea(
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                ),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isVet ? 'ยอดสะสม (Withdrawable)' : 'Coin balance',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white70,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        isVet ? '฿${_fmt(balance)}' : '$balance 🪙',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      const Spacer(),
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.5)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 0),
                          minimumSize: const Size(0, 32),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          isVet ? 'ถอนเงิน' : 'แลกรางวัล',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Transactions',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 6),
            ...txs.map((t) => _CoinTxTile(tx: t)),
          ],
        ),
      ),
    ),
  );
}

String _fmt(int v) {
  final s = v.toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}

class _CoinTxTile extends StatelessWidget {
  final _CoinTx tx;
  const _CoinTxTile({required this.tx});

  String _rel(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 60) return '${d.inMinutes}m';
    if (d.inHours < 24) return '${d.inHours}h';
    return '${d.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    final positive = tx.delta >= 0;
    final c = positive ? AppColors.success : AppColors.danger;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Icon(tx.icon, size: 15, color: c),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.source,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    _rel(tx.at),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              tx.title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: c,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsultRequestCard extends StatelessWidget {
  final _ConsultRequest request;
  const _ConsultRequestCard({required this.request});

  String _timeAgo(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border:
              Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SeededAvatar(seed: request.owner.avatarSeed, size: 36),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.owner.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.pets,
                              size: 11,
                              color: AppColors.textSecondary),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              '${request.pet.name} · ${request.pet.species} · ${request.pet.breed}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    '฿${request.price}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              request.summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule,
                    size: 11, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  _timeAgo(request.requestedAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side:
                        const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 0),
                    minimumSize: const Size(0, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child:
                      const Text('ปฏิเสธ', style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 6),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        content: Text('รับเคส ${request.owner.name} แล้ว'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check, size: 14),
                  label: const Text('รับเคส',
                      style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 0),
                    minimumSize: const Size(0, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
