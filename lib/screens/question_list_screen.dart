import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/consult_models.dart';
import '../theme/app_theme.dart';
import 'question_chat_screen.dart';

class QuestionListScreen extends StatefulWidget {
  final String title;
  final List<Question> questions;
  final String? emptyText;

  const QuestionListScreen({
    super.key,
    required this.title,
    required this.questions,
    this.emptyText,
  });

  @override
  State<QuestionListScreen> createState() => _QuestionListScreenState();
}

class _QuestionListScreenState extends State<QuestionListScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Question> get _filtered {
    if (_query.trim().isEmpty) return widget.questions;
    final q = _query.trim().toLowerCase();
    return widget.questions
        .where((x) =>
            x.title.toLowerCase().contains(q) ||
            x.body.toLowerCase().contains(q) ||
            (x.pet?.name.toLowerCase().contains(q) ?? false) ||
            (x.pet?.breed.toLowerCase().contains(q) ?? false))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
            child: Semantics(
              label: 'Search questions',
              textField: true,
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'ค้นหาคำถาม, อาการ, ชื่อน้อง…',
                  prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          icon: const Icon(Icons.close, color: AppColors.textSecondary),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _query = '');
                          },
                        ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
            child: Row(
              children: [
                Text(
                  '${filtered.length} ${filtered.length == 1 ? "result" : "results"}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? _EmptyState(query: _query, fallbackText: widget.emptyText)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (_, i) => _QuestionRow(question: filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String query;
  final String? fallbackText;
  const _EmptyState({required this.query, this.fallbackText});

  @override
  Widget build(BuildContext context) {
    final text = query.isEmpty
        ? (fallbackText ?? 'ยังไม่มีคำถามในรายการนี้')
        : 'ไม่พบคำถามที่ตรงกับ "$query"';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.search_off, size: 28, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionRow extends StatelessWidget {
  final Question question;
  const _QuestionRow({required this.question});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => QuestionChatScreen(question: question),
        )),
        child: Semantics(
          button: true,
          label:
              'Open question: ${question.title}${question.hasAcceptedAnswer ? ", solved" : ", awaiting vet"}',
          child: Container(
            padding: const EdgeInsets.all(12),
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
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: question.category.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(question.category.emoji, style: const TextStyle(fontSize: 14)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              height: 1.3,
                            ),
                          ),
                          if (question.pet != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              '${question.pet!.name} · ${question.pet!.breed}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      question.hasAcceptedAnswer ? Icons.check_circle : Icons.schedule,
                      size: 12,
                      color: question.hasAcceptedAnswer ? AppColors.success : AppColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      question.hasAcceptedAnswer ? 'Solved' : 'Awaiting vet',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: question.hasAcceptedAnswer ? AppColors.success : AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('d MMM').format(question.postedAt),
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                    const Spacer(),
                    Icon(Icons.chat_bubble_outline, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 3),
                    Text(
                      '${question.answerCount}',
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
        ),
      ),
    );
  }
}
