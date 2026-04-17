import 'dart:async';
import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/consult_models.dart';
import '../theme/app_theme.dart';
import '../widgets/avatar.dart';
import '../widgets/live_atoms.dart';
import '../widgets/question_card.dart';
import 'question_chat_screen.dart';
import 'post_question_screen.dart';

enum _Sort { latest, trending, follows }

enum _Species {
  all('All', '🐾'),
  dog('Dog', '🐶'),
  cat('Cat', '🐱'),
  rabbit('Rabbit', '🐰');

  final String label;
  final String emoji;
  const _Species(this.label, this.emoji);
}

const _liveReplyingByQuestion = <String, Author>{
  'q2': Author(
    name: 'Dr. Mana V.',
    clinic: 'Bangkok Vet Center',
    avatarSeed: 'mana',
    role: AuthorRole.vet,
    specialty: 'Dermatology',
    verified: true,
  ),
  'q4': Author(
    name: 'Dr. Somchai R.',
    clinic: 'Arak Animal Hospital',
    avatarSeed: 'somchai',
    role: AuthorRole.vet,
    specialty: 'Internal Medicine',
    verified: true,
  ),
};

class _TickerItem {
  final String text;
  final Color accent;
  final IconData icon;
  const _TickerItem(this.text, this.accent, this.icon);
}

const _feedTickerItems = <_TickerItem>[
  _TickerItem('4 คุณหมอออนไลน์ · ตอบเฉลี่ย 12 นาที', AppColors.vetBadge, Icons.verified),
  _TickerItem('Dr. Mana เพิ่งตอบคำถามเรื่องอาหารน้องแมว', AppColors.primary, Icons.forum),
  _TickerItem('+12 คำถามใหม่วันนี้ · มากกว่าเมื่อวาน 40%', AppColors.accent, Icons.trending_up),
  _TickerItem('287 คนกำลังอ่านคำถามในห้อง', AppColors.success, Icons.visibility),
  _TickerItem('คำถามสุขภาพได้คำตอบภายใน ~3 นาที ตอนนี้', AppColors.secondary, Icons.bolt),
];

class ConsultBoardScreen extends StatefulWidget {
  const ConsultBoardScreen({super.key});

  @override
  State<ConsultBoardScreen> createState() => _ConsultBoardScreenState();
}

class _ConsultBoardScreenState extends State<ConsultBoardScreen> {
  _Sort _sort = _Sort.latest;
  _Species _species = _Species.all;
  final _searchCtrl = TextEditingController();

  int _tickerIndex = 0;
  Timer? _tickerTimer;

  @override
  void initState() {
    super.initState();
    _tickerTimer = Timer.periodic(const Duration(milliseconds: 3400), (_) {
      if (!mounted) return;
      setState(() => _tickerIndex = (_tickerIndex + 1) % _feedTickerItems.length);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _tickerTimer?.cancel();
    super.dispose();
  }

  List<Question> get _filtered {
    var list = mockQuestions.toList();
    if (_species != _Species.all) {
      list = list.where((q) {
        final s = q.pet?.species.toLowerCase();
        return s == _species.label.toLowerCase();
      }).toList();
    }
    if (_searchCtrl.text.trim().isNotEmpty) {
      final q = _searchCtrl.text.trim().toLowerCase();
      list = list.where((x) => x.title.toLowerCase().contains(q) || x.body.toLowerCase().contains(q)).toList();
    }
    switch (_sort) {
      case _Sort.latest:
        list.sort((a, b) => b.postedAt.compareTo(a.postedAt));
        break;
      case _Sort.trending:
        list.sort((a, b) => (b.upvotes + b.answerCount * 3).compareTo(a.upvotes + a.answerCount * 3));
        break;
      case _Sort.follows:
        break;
    }
    return list;
  }

  void _openPost() async {
    final created = await Navigator.of(context).push<Question>(
      MaterialPageRoute(builder: (_) => const PostQuestionScreen()),
    );
    if (created != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          content: Text('Posted "${created.title}" — vets will be notified'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              automaticallyImplyLeading: false,
              titleSpacing: AppSpacing.lg,
              title: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.pets, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Text('Consult'),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: 'Notifications',
                  onPressed: () {},
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: const [
                      Icon(Icons.notifications_outlined),
                      Positioned(
                        right: -2,
                        top: -2,
                        child: CircleAvatar(radius: 5, backgroundColor: AppColors.danger),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
            ),
            const SliverToBoxAdapter(child: _FeedPresenceBar()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ask vets anything',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Verified vets answer most questions within 30 minutes.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _searchCtrl,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search questions, symptoms…',
                        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.mic_none, color: AppColors.textSecondary),
                          onPressed: () {},
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  0,
                  AppSpacing.sm,
                  0,
                  AppSpacing.xs,
                ),
                child: SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    children: [
                      for (final s in _Species.values) ...[
                        _SpeciesPill(
                          species: s,
                          selected: _species == s,
                          onTap: () => setState(() => _species = s),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  0,
                ),
                child: _FeedTicker(item: _feedTickerItems[_tickerIndex]),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    _SortTab(
                      label: 'Latest',
                      selected: _sort == _Sort.latest,
                      onTap: () => setState(() => _sort = _Sort.latest),
                    ),
                    const SizedBox(width: 6),
                    _SortTab(
                      label: 'Trending',
                      selected: _sort == _Sort.trending,
                      onTap: () => setState(() => _sort = _Sort.trending),
                    ),
                    const SizedBox(width: 6),
                    _SortTab(
                      label: 'My Follows',
                      selected: _sort == _Sort.follows,
                      onTap: () => setState(() => _sort = _Sort.follows),
                    ),
                    const Spacer(),
                    Text('${_filtered.length} results',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            )),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                100,
              ),
              sliver: _filtered.isEmpty
                  ? const SliverToBoxAdapter(child: _EmptyState())
                  : SliverList.separated(
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (_, i) {
                        final q = _filtered[i];
                        return QuestionCard(
                          question: q,
                          liveReplyingAuthor: _liveReplyingByQuestion[q.id],
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => QuestionChatScreen(question: q),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openPost,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Ask'),
      ),
    );
  }

}

class _SortTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SortTab({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.primarySoft : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _SpeciesPill extends StatelessWidget {
  final _Species species;
  final bool selected;
  final VoidCallback onTap;

  const _SpeciesPill({
    required this.species,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
              Text(species.emoji, style: const TextStyle(fontSize: 15)),
              const SizedBox(width: 6),
              Text(
                species.label,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedPresenceBar extends StatelessWidget {
  const _FeedPresenceBar();

  @override
  Widget build(BuildContext context) {
    const avatars = ['somchai', 'ploy', 'mana', 'nick'];
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.accent.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            height: 30,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                for (int i = 0; i < avatars.length; i++)
                  Positioned(
                    left: i * 16.0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(1.5),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.background,
                      ),
                      child: SeededAvatar(seed: avatars[i], size: 22),
                    ),
                  ),
                Positioned(
                  left: avatars.length * 16.0,
                  top: 3,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.background, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '+42',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
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
                    const PulseDot(color: AppColors.success, size: 6),
                    const SizedBox(width: 6),
                    const Text(
                      '4 vets',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '· 287 viewing',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'ตอบเฉลี่ย ~3 นาที',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.flash_on, size: 12, color: AppColors.primary),
                SizedBox(width: 4),
                Text(
                  'LIVE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedTicker extends StatelessWidget {
  final _TickerItem item;
  const _FeedTicker({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: item.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: item.accent.withValues(alpha: 0.18)),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(anim),
            child: child,
          ),
        ),
        layoutBuilder: (currentChild, previousChildren) => Stack(
          alignment: Alignment.centerLeft,
          children: [
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        ),
        child: SizedBox(
          key: ValueKey(item.text),
          width: double.infinity,
          child: Row(
            children: [
              Icon(item.icon, size: 14, color: item.accent),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  item.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: item.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.search_off, size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('No matching questions',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Try a different category or be the first to ask.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  )),
        ],
      ),
    );
  }
}
