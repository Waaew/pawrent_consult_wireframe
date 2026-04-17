import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/consult_models.dart';
import '../theme/app_theme.dart';
import '../widgets/answer_card.dart';
import '../widgets/avatar.dart';
import '../widgets/category_pill.dart';
import 'vet_answer_screen.dart';

class QuestionDetailScreen extends StatefulWidget {
  final Question question;
  const QuestionDetailScreen({super.key, required this.question});

  @override
  State<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  late List<Answer> _answers;
  String? _acceptedId;

  @override
  void initState() {
    super.initState();
    _answers = List.of(widget.question.answers);
    Answer? accepted;
    for (final a in _answers) {
      if (a.accepted) {
        accepted = a;
        break;
      }
    }
    _acceptedId = accepted?.id;
    _sortAnswers();
  }

  void _sortAnswers() {
    _answers.sort((a, b) {
      if (a.id == _acceptedId) return -1;
      if (b.id == _acceptedId) return 1;
      return b.upvotes.compareTo(a.upvotes);
    });
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
      _sortAnswers();
    });
  }

  Future<void> _openVetComposer() async {
    final newAnswer = await Navigator.of(context).push<Answer>(
      MaterialPageRoute(builder: (_) => VetAnswerScreen(question: widget.question)),
    );
    if (newAnswer != null) {
      setState(() {
        _answers.insert(0, newAnswer);
        _sortAnswers();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Question'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_outline)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 120),
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SeededAvatar(seed: q.author.avatarSeed, size: 40, role: q.author.role),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(q.author.name, style: text.titleMedium),
                          Text(
                            DateFormat('d MMM yyyy · HH:mm').format(q.postedAt),
                            style: text.bodySmall?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    CategoryPill(category: q.category, selected: true, compact: true),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                if (q.isUrgent)
                  Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AppColors.danger),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Marked urgent — answer prioritized to verified vets',
                            style: text.bodySmall?.copyWith(
                              color: AppColors.danger,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Text(q.title, style: text.titleLarge?.copyWith(height: 1.3)),
                const SizedBox(height: AppSpacing.md),
                Text(q.body, style: text.bodyMedium?.copyWith(height: 1.6)),
                if (q.photos.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    height: 160,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: q.photos.length,
                      separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                      itemBuilder: (_, i) => Container(
                        width: 200,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary.withValues(alpha: 0.2),
                              AppColors.accent.withValues(alpha: 0.3),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.photo_library, size: 36, color: Colors.white),
                      ),
                    ),
                  ),
                ],
                if (q.pet != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      children: [
                        SeededAvatar(seed: q.pet!.avatarSeed, size: 40),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(q.pet!.name,
                                  style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                              Text(
                                '${q.pet!.species} · ${q.pet!.breed} · ${q.pet!.ageMonths} mo',
                                style: text.bodySmall?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('View profile'),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.thumb_up_alt_outlined, size: 16),
                      label: Text('Upvote · ${q.upvotes}'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_active_outlined, size: 16),
                      label: const Text('Follow'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Text('${_answers.length} Answers', style: text.titleMedium),
              const SizedBox(width: AppSpacing.sm),
              if (_answers.any((a) => a.author.role == AuthorRole.vet))
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.vetBadge.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Text(
                    'Verified vet replied',
                    style: TextStyle(
                      color: AppColors.vetBadge,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.sort, size: 16),
                label: const Text('Sort'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (_answers.isEmpty)
            _EmptyAnswers(onVetAnswer: _openVetComposer)
          else
            ..._answers.expand((a) => [
                  AnswerCard(
                    answer: a,
                    onAcceptToggle: (v) => _toggleAccept(a.id, v),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ]),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _openVetComposer,
                  icon: const Icon(Icons.medical_services_outlined, size: 18),
                  label: const Text('Answer as Vet'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                child: const Icon(Icons.video_call_outlined, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyAnswers extends StatelessWidget {
  final VoidCallback onVetAnswer;
  const _EmptyAnswers({required this.onVetAnswer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.primarySoft.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.medical_services_outlined, size: 36, color: AppColors.primary),
          const SizedBox(height: AppSpacing.sm),
          Text('No answers yet',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Average answer time: 28 minutes',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton.icon(
            onPressed: onVetAnswer,
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Be the first to answer'),
          ),
        ],
      ),
    );
  }
}
