import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/consult_models.dart';
import '../theme/app_theme.dart';
import 'avatar.dart';

class AnswerCard extends StatefulWidget {
  final Answer answer;
  final bool ownerView;
  final ValueChanged<bool>? onAcceptToggle;

  const AnswerCard({
    super.key,
    required this.answer,
    this.ownerView = true,
    this.onAcceptToggle,
  });

  @override
  State<AnswerCard> createState() => _AnswerCardState();
}

class _AnswerCardState extends State<AnswerCard> {
  int _voteDelta = 0;
  int _userVote = 0;

  void _vote(int dir) {
    setState(() {
      if (_userVote == dir) {
        _userVote = 0;
        _voteDelta -= dir;
      } else {
        _voteDelta += dir - _userVote;
        _userVote = dir;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final a = widget.answer;
    final isBrand = a.isBrandSponsored;
    final isVet = a.author.role == AuthorRole.vet;

    final borderColor = a.accepted
        ? AppColors.success
        : isBrand
            ? AppColors.brandBadge.withValues(alpha: 0.5)
            : isVet
                ? AppColors.vetBadge.withValues(alpha: 0.3)
                : AppColors.border;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: borderColor, width: a.accepted ? 1.5 : 1),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (a.accepted)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.check_circle, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text('ACCEPTED ANSWER',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (isBrand)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.brandBadge.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.workspace_premium, size: 14, color: AppColors.brandBadge),
                    const SizedBox(width: 6),
                    Text('Sponsored Official Answer',
                        style: text.bodySmall?.copyWith(
                          color: AppColors.brandBadge,
                          fontWeight: FontWeight.w700,
                        )),
                  ],
                ),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SeededAvatar(seed: a.author.avatarSeed, size: 44, role: a.author.role),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(a.author.name,
                              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        ),
                        if (isVet) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.verified, size: 16, color: AppColors.vetBadge),
                        ],
                      ],
                    ),
                    if (a.author.clinic != null)
                      Text(a.author.clinic!,
                          style: text.bodySmall?.copyWith(color: AppColors.textSecondary)),
                    if (a.author.specialty != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.vetBadge.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(a.author.specialty!,
                              style: text.bodySmall?.copyWith(
                                color: AppColors.vetBadge,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              )),
                        ),
                      ),
                  ],
                ),
              ),
              Text(DateFormat('d MMM, HH:mm').format(a.postedAt),
                  style: text.bodySmall?.copyWith(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(a.body, style: text.bodyMedium?.copyWith(height: 1.6)),
          if (a.suggestsClinicVisit) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_hospital, color: AppColors.warning, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text('Vet recommends an in-clinic visit',
                        style: text.bodySmall?.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w700,
                        )),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.warning,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text('Book Telemet'),
                  ),
                ],
              ),
            ),
          ],
          if (isBrand && a.brandCta != null) ...[
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                label: Text(a.brandCta!),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.brandBadge,
                  side: const BorderSide(color: AppColors.brandBadge),
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _VoteCluster(
                upvotes: a.upvotes + _voteDelta,
                userVote: _userVote,
                onUp: () => _vote(1),
                onDown: () => _vote(-1),
              ),
              const Spacer(),
              if (widget.ownerView && !isBrand)
                TextButton.icon(
                  onPressed: () => widget.onAcceptToggle?.call(!a.accepted),
                  icon: Icon(
                    a.accepted ? Icons.check_circle : Icons.check_circle_outline,
                    size: 18,
                    color: a.accepted ? AppColors.success : AppColors.textSecondary,
                  ),
                  label: Text(
                    a.accepted ? 'Accepted' : 'Accept as solution',
                    style: TextStyle(
                      color: a.accepted ? AppColors.success : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.flag_outlined, size: 18, color: AppColors.textSecondary),
                tooltip: 'Report',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VoteCluster extends StatelessWidget {
  final int upvotes;
  final int userVote;
  final VoidCallback onUp;
  final VoidCallback onDown;

  const _VoteCluster({
    required this.upvotes,
    required this.userVote,
    required this.onUp,
    required this.onDown,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onUp,
            icon: Icon(
              Icons.arrow_upward,
              size: 18,
              color: userVote == 1 ? AppColors.primary : AppColors.textSecondary,
            ),
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text('$upvotes',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: userVote != 0 ? AppColors.primary : AppColors.textPrimary,
                )),
          ),
          IconButton(
            onPressed: onDown,
            icon: Icon(
              Icons.arrow_downward,
              size: 18,
              color: userVote == -1 ? AppColors.danger : AppColors.textSecondary,
            ),
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
