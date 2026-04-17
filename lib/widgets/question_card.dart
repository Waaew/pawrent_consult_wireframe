import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/consult_models.dart';
import '../screens/photo_viewer_screen.dart';
import '../screens/profile_screen.dart';
import '../theme/app_theme.dart';
import 'avatar.dart';
import 'category_pill.dart';
import 'live_atoms.dart';

class QuestionCard extends StatelessWidget {
  final Question question;
  final VoidCallback? onTap;
  final Author? liveReplyingAuthor;

  const QuestionCard({
    super.key,
    required this.question,
    this.onTap,
    this.liveReplyingAuthor,
  });

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return DateFormat('d MMM').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => openProfile(context, question.author),
                    child: SeededAvatar(
                      seed: question.author.avatarSeed,
                      size: 32,
                      role: question.author.role,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => openProfile(context, question.author),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question.author.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            _timeAgo(question.postedAt),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  CategoryPill(category: question.category, selected: true, compact: true),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (question.isUrgent)
                    Padding(
                      padding: const EdgeInsets.only(right: 6, top: 2),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: const Text('URGENT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.danger,
                            )),
                      ),
                    ),
                  Expanded(
                    child: Text(
                      question.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                question.body,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (question.photos.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 72,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: question.photos.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (ctx, i) => GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(ctx).push(MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (_) => PhotoViewerScreen(
                          photos: question.photos,
                          initialIndex: i,
                          caption: question.title,
                        ),
                      )),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          question.photos[i],
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                          errorBuilder: (_, __, ___) => Container(
                            width: 72,
                            height: 72,
                            color: AppColors.primarySoft,
                            alignment: Alignment.center,
                            child: const Icon(Icons.broken_image,
                                color: AppColors.primary, size: 22),
                          ),
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              width: 72,
                              height: 72,
                              color: AppColors.primarySoft,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              if (liveReplyingAuthor != null) ...[
                const SizedBox(height: AppSpacing.sm),
                _LiveReplyingRow(author: liveReplyingAuthor!),
              ],
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  if (question.pet != null) ...[
                    const Icon(Icons.pets, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${question.pet!.name} · ${question.pet!.breed}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  _MetaIcon(
                    icon: Icons.thumb_up_alt_outlined,
                    label: '${question.upvotes}',
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _MetaIcon(
                    icon: Icons.chat_bubble_outline,
                    label: '${question.answerCount}',
                    highlight: question.hasAcceptedAnswer,
                  ),
                  const Spacer(),
                  if (question.hasAcceptedAnswer)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.check_circle, size: 12, color: AppColors.success),
                          SizedBox(width: 4),
                          Text('Solved',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                              )),
                        ],
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

class _LiveReplyingRow extends StatelessWidget {
  final Author author;
  const _LiveReplyingRow({required this.author});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.vetBadge.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.vetBadge.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          SeededAvatar(seed: author.avatarSeed, size: 24, role: author.role),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
                children: [
                  TextSpan(
                    text: author.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.vetBadge,
                    ),
                  ),
                  const TextSpan(
                    text: ' กำลังพิมพ์คำตอบ',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          const TypingDots(color: AppColors.vetBadge, dotSize: 5),
        ],
      ),
    );
  }
}

class _MetaIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool highlight;
  const _MetaIcon({required this.icon, required this.label, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final color = highlight ? AppColors.success : AppColors.textSecondary;
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
